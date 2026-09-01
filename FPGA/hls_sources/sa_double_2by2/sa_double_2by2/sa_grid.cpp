// sa_grid: expandable systolic grid
// Sultanah Almutairi, ICTP STI-MLab & KAUST, 2026
#include "sa_grid.hpp"

typedef hls::stream<acc_t, PE * PE> acc_t_stream;

static word_t make_hdr(int type, int r, int s, int len)
{
    word_t w;
    w.data = 0;
    w.data.range(31, 24) = HDR_MAGIC;
    w.data.range(23, 20) = type;
    w.data.range(19, 16) = r;
    w.data.range(15, 12) = s;
    w.data.range(11,  0) = len;
    w.keep = -1; w.strb = -1; w.last = 0;
    return w;
}

//stage 1
// load owns both input ports for the whole life of the block.
//
//   phase 0  pick      : first header from whichever port has data
//   phase 1  frames    : keep mine, forward the rest
//   phase 2  crossing  : one beat per step, interleaved so neither port starves
//   phase 3  C         : pass through to store

// One TLAST terminated group. `first` is the header already taken by the pick,
// so the group continues from where the pick left off instead of re-reading.
static void frame_group(stream_t &in_left,
                        stream_t &in_up,
                        bool use_up,
                        const word_t &first, bool have_first,
                        int my_r, int my_s,
                        fwd_t &fwd_right,
                        fwd_t &fwd_down,
                        buf_t &bufA,
                        buf_t &bufB)
{
    word_t h = first;
    bool   fresh = have_first;

GROUP:
    while (true) {
#pragma HLS LOOP_TRIPCOUNT min=1 max=2      // FRAMES_MAX for this geometry
        if (!fresh) h = use_up ? in_up.read() : in_left.read(); 
        fresh = false;

        ap_uint<4> type = h.data.range(23, 20);
        ap_uint<4> dr   = h.data.range(19, 16);
        ap_uint<4> ds   = h.data.range(15, 12);
        bool mine = (dr == my_r && ds == my_s);

        if (!mine) {
            beat_t b; b.data = h.data; b.last = false;
            if (type == TYPE_A_FRAME) fwd_down.write(b);
            else                      fwd_right.write(b);
        }

        bool last = false;
    PAYLOAD:
        for (int k = 0; k < K; k++) {          // one beat per k, PE operands packed
#pragma HLS PIPELINE II=1
            word_t w = use_up ? in_up.read() : in_left.read();
            last = w.last;
            if (mine) {
                if (type == TYPE_A_FRAME) bufA.write(w.data);   // one beat, PE operands
                else                      bufB.write(w.data);
            } else {
                beat_t b; b.data = w.data; b.last = w.last;
                if (type == TYPE_A_FRAME) fwd_down.write(b);
                else                      fwd_right.write(b);
            }
        }
        if (last) return;
    }
}

static void port_to_chan(stream_t &in_left, stream_t &in_up, bool use_up,
                         chan_t &dst, bool keep_last){
IN_PASS:
    while (true) {
#pragma HLS LOOP_TRIPCOUNT min=1 max=12     // CPASS_MAX for this geometry
#pragma HLS PIPELINE II=1
        word_t w = use_up ? in_up.read() : in_left.read();
        beat_t b; b.data = w.data; b.last = keep_last ? (bool)w.last : false;
        dst.write(b);
        if (w.last) return;
    }
}

static void load(stream_t &in_left,
                 stream_t &in_up,
                 fwd_t &fwd_right,
                 fwd_t &fwd_down,
                 buf_t &bufA,
                 buf_t &bufB,
                 cross_t &xa_in,
                 cross_t &xb_in,
                 chan_t &c_pass,
                 hls::stream<ap_uint<8> > &pos_to_compute,
                 hls::stream<ap_uint<8> > &pos_to_store)
{
    // phase 0: pick 
    // read_nb is non- blocking read so asking two ports in turn cannot lose a beat. In the
    // frame phase exactly one port ever carries data to a given block, so the
    // choice is deterministic becuase the one case where both are ready is an interior
    // block, which reads both anyway.
    word_t h;
    bool from_left = false, from_up = false;
PICK:
    while (!from_left && !from_up) {
        // How long this spins is set by the upstream block, not by this one, so
        // there is no honest bound to give.
#pragma HLS LOOP_TRIPCOUNT min=1 max=1 // this is just becuase i am using " while" 
        from_left = in_left.read_nb(h);
        if (!from_left) from_up = in_up.read_nb(h);
    }

    const int  my_r       = h.data.range(19, 16);
    const int  my_s       = h.data.range(15, 12);
    const bool is_row0    = (my_r == 0);
    const bool is_col0    = (my_s == 0);
    const bool is_lastrow = (my_r == R - 1);
    const bool is_lastcol = (my_s == S - 1);

    // compute and store are separate DATAFLOW processes and cannot see a local
    // variable, so the position discovered here is handed to each of them "i am just let both of them knows the same info"
    pos_to_compute.write((ap_uint<8>)((my_r << 4) | my_s));
    pos_to_store.write((ap_uint<8>)((my_r << 4) | my_s));

    // phase 1: frames 
    // Row 0 receives its B frames on in_left; the rest of column 0 receives its
    // A frames on in_up. Block (0,0) gets both groups on in_left, because one
    // MM2S channel feeds the whole grid. An interior block gets no frames at
    // all, so its picked header was already a crossing header.
    const ap_uint<4> first_type = h.data.range(23, 20);
    const bool picked_frame = (first_type == TYPE_A_FRAME) ||
                              (first_type == TYPE_B_FRAME);
    if (is_row0) {
        frame_group(in_left, in_up, false, h, picked_frame, my_r, my_s,
                    fwd_right, fwd_down, bufA, bufB);
        if (is_col0)
            frame_group(in_left, in_up, false, h, false, my_r, my_s,
                        fwd_right, fwd_down, bufA, bufB);
    } else if (is_col0) {
        frame_group(in_left, in_up, true,  h, picked_frame, my_r, my_s,
                    fwd_right, fwd_down, bufA, bufB);
    }

    // phase 2: crossing 
    // An interior block already holds one crossing header from the pick, so it
    // must not read that one again.
    bool have_left_hdr = !picked_frame && from_left;
    bool have_up_hdr   = !picked_frame && from_up;
    if (!is_col0 && !have_left_hdr) in_left.read();
    if (!is_row0 && !have_up_hdr)   in_up.read();
CROSS:
    for (int t = 0; t < STEPS; t++) {
#pragma HLS PIPELINE II=1
        if (!is_col0) xa_in.write(in_left.read().data);
        if (!is_row0) xb_in.write(in_up.read().data);
    }

    //  phase 3: C 
    // Complete rows from above first, then the earlier blocks of my own row, so
    // the gathered order stays block row major. Each incoming group carries its
    // own header: drop it, store writes one in front of the whole result.
    bool from_up_c   = is_lastcol && !is_row0;
    bool from_left_c = !is_col0;
    if (from_up_c)   { in_up.read();   port_to_chan(in_left, in_up, true,  c_pass, !from_left_c); }
    if (from_left_c) { in_left.read(); port_to_chan(in_left, in_up, false, c_pass, true); }
}

// stage 2
// It injects from its own buffer on the edges of the grid
// and from a neighbour's beat everywhere else, and emits what leaves its right
// and bottom edges. Every block runs the same STEPS count: one whose useful
// products finish early must keep stepping, because its neighbours consume one
// beat per step.
static void compute(buf_t &bufA_s,
                    buf_t &bufB_s,
                    cross_t &xa_in,
                    cross_t &xb_in,
                    cross_t &xa_out,
                    cross_t &xb_out,
                    acc_t_stream &c_mine,
                    hls::stream<ap_uint<8> > &pos_in)
{
    ap_uint<8> pos = pos_in.read();
    const int  my_r       = pos >> 4;
    const int  my_s       = pos & 0xF;
    const bool is_row0    = (my_r == 0);
    const bool is_col0    = (my_s == 0);
    const bool is_lastrow = (my_r == R - 1);
    const bool is_lastcol = (my_s == S - 1);
    const int  off_r      = my_r * PE;
    const int  off_s      = my_s * PE;

    // Pull my operands out of the load FIFOs into local registers. A block that
    // sits away from an edge receives nothing here and reads nothing.
    data_t bufA[PE][K], bufB[K][PE];
#pragma HLS ARRAY_PARTITION variable=bufA complete dim=0
#pragma HLS ARRAY_PARTITION variable=bufB complete dim=0
RECV_A:
    if (is_col0)
        for (int k = 0; k < K; k++) {
#pragma HLS PIPELINE II=1
            ap_uint<W> v = bufA_s.read();
            for (int n = 0; n < PE; n++) {
#pragma HLS UNROLL
                bufA[n][k] = (data_t)v.range(16*n + 15, 16*n);
            }
        }
RECV_B:
    if (is_row0)
        for (int k = 0; k < K; k++) {
#pragma HLS PIPELINE II=1
            ap_uint<W> v = bufB_s.read();
            for (int n = 0; n < PE; n++) {
#pragma HLS UNROLL
                bufB[k][n] = (data_t)v.range(16*n + 15, 16*n);
            }
        }

    data_t a_pipe[PE][PE], b_pipe[PE][PE];
    acc_t  c_acc[PE][PE];
#pragma HLS ARRAY_PARTITION variable=a_pipe complete dim=0
#pragma HLS ARRAY_PARTITION variable=b_pipe complete dim=0
#pragma HLS ARRAY_PARTITION variable=c_acc  complete dim=0

INIT:
    for (int i = 0; i < PE; i++)
#pragma HLS UNROLL
        for (int j = 0; j < PE; j++) {
#pragma HLS UNROLL
            a_pipe[i][j] = 0; b_pipe[i][j] = 0; c_acc[i][j] = 0;
        }

STEP:
    for (int t = 0; t < STEPS; t++) {
#pragma HLS PIPELINE II=1

        // 1. MAC on every PE
    MAC:
        for (int i = 0; i < PE; i++) {
#pragma HLS UNROLL
            for (int j = 0; j < PE; j++) {
#pragma HLS UNROLL
                c_acc[i][j] += (acc_t)a_pipe[i][j] * (acc_t)b_pipe[i][j];
            }
        }

        // 2. capture the right and bottom edges, before the shift
        ap_uint<W> ea = 0, eb = 0;
    EDGE:
        for (int n = 0; n < PE; n++) {
#pragma HLS UNROLL
            ea.range(16*n + 15, 16*n) = a_pipe[n][PE-1].range(15, 0);
            eb.range(16*n + 15, 16*n) = b_pipe[PE-1][n].range(15, 0);
        }
        if (!is_lastcol) xa_out.write(ea);
        if (!is_lastrow) xb_out.write(eb);

        // 3. systolic shift
    SH_A:
        for (int i = 0; i < PE; i++) {
#pragma HLS UNROLL
            for (int j = PE-1; j > 0; j--) {
#pragma HLS UNROLL
                a_pipe[i][j] = a_pipe[i][j-1];
            }
        }
    SH_B:
        for (int j = 0; j < PE; j++) {
#pragma HLS UNROLL
            for (int i = PE-1; i > 0; i--) {
#pragma HLS UNROLL
                b_pipe[i][j] = b_pipe[i-1][j];
            }
        }

        // 4. inject the left edge: from my buffer if I am in column 0, with the
        //    skew shifted by my position, otherwise from my left neighbour
        if (is_col0) {
        FA:
            for (int i = 0; i < PE; i++) {
#pragma HLS UNROLL
                int k = t - off_r - i;
                a_pipe[i][0] = (k >= 0 && k < K) ? bufA[i][k] : (data_t)0;
            }
        } else {
            ap_uint<W> v = xa_in.read();
        FA_X:
            for (int i = 0; i < PE; i++) {
#pragma HLS UNROLL
                a_pipe[i][0] = (data_t)v.range(16*i + 15, 16*i);
            }
        }

        // 5. inject the top edge, same rule along the other axis
        if (is_row0) {
        FB:
            for (int j = 0; j < PE; j++) {
#pragma HLS UNROLL
                int k = t - off_s - j;
                b_pipe[0][j] = (k >= 0 && k < K) ? bufB[k][j] : (data_t)0;
            }
        } else {
            ap_uint<W> v = xb_in.read();
        FB_X:
            for (int j = 0; j < PE; j++) {
#pragma HLS UNROLL
                b_pipe[0][j] = (data_t)v.range(16*j + 15, 16*j);
            }
        }
    }

DRAIN:
    for (int i = 0; i < PE; i++)
        for (int j = 0; j < PE; j++) {
#pragma HLS PIPELINE II=1
            c_mine.write(c_acc[i][j]);
        }
}

//  stage 3
// store owns both output ports and serialises everything onto them in the order
// the neighbour expects: forwarded frames, then crossing, then C.
template<int D>
static void chan_to_port(hls::stream<beat_t, D> &src, stream_t &dst, bool keep_last)
{
OUT_PASS:
    while (true) {
#pragma HLS LOOP_TRIPCOUNT min=1 max=12     // CPASS_MAX for this geometry
#pragma HLS PIPELINE II=1
        beat_t b = src.read();
        word_t w;
        w.data = b.data; w.keep = -1; w.strb = -1;
        w.last = keep_last ? b.last : 0;
        dst.write(w);
        if (b.last) return;
    }
}

static void emit_c(acc_t_stream &c_mine, stream_t &dst)
{
MINE:
    for (int n = 0; n < CBEAT; n++) {
#pragma HLS PIPELINE II=1
        word_t w;
        w.data = 0;
        for (int m = 0; m < APB; m++) {
#pragma HLS UNROLL
            w.data.range(32*m + 31, 32*m) = c_mine.read().range(31, 0);
        }
        w.keep = -1; w.strb = -1;
        w.last = (n == CBEAT - 1);
        dst.write(w);
    }
}

static void store(fwd_t &fwd_right,
                  fwd_t &fwd_down,
                  cross_t &xa_out,
                  cross_t &xb_out,
                  acc_t_stream &c_mine,
                  chan_t &c_pass,
                  stream_t &out_right,
                  stream_t &out_down,
                  hls::stream<ap_uint<8> > &pos_in)
{
    ap_uint<8> pos = pos_in.read();
    const int  my_r       = pos >> 4;
    const int  my_s       = pos & 0xF;
    const bool is_row0    = (my_r == 0);
    const bool is_col0    = (my_s == 0);
    const bool is_lastrow = (my_r == R - 1);
    const bool is_lastcol = (my_s == S - 1);

    // frames forwarded during load
    if (is_row0 && !is_lastcol) chan_to_port(fwd_right, out_right, true);
    if (is_col0 && !is_lastrow) chan_to_port(fwd_down,  out_down,  true);

    // crossing: The header carries the position of the block that will keep it,
    // which is my neighbour, so the receiver learns where it is from this beat
    // alone even if it never receives a frame.
    if (!is_lastcol) out_right.write(make_hdr(TYPE_A_CROSS, my_r, my_s + 1, STEPS));
    if (!is_lastrow) out_down.write (make_hdr(TYPE_B_CROSS, my_r + 1, my_s, STEPS));
XCROSS:
    for (int t = 0; t < STEPS; t++) {
#pragma HLS PIPELINE II=1
        if (!is_lastcol) {
            word_t w; w.data = xa_out.read();
            w.keep = -1; w.strb = -1; w.last = (t == STEPS-1);
            out_right.write(w);
        }
        if (!is_lastrow) {
            word_t w; w.data = xb_out.read();
            w.keep = -1; w.strb = -1; w.last = (t == STEPS-1);
            out_down.write(w);
        }
    }

    // C: whatever the neighbours sent first, then my own tile. The last column
    // sends it down, everyone else sends it right.
    bool from_up_c   = is_lastcol && !is_row0;
    bool from_left_c = !is_col0;
    if (is_lastcol) {
        out_down.write(make_hdr(TYPE_C_DATA, my_r, my_s, 0));
        if (from_up_c || from_left_c) chan_to_port(c_pass, out_down, false);
        emit_c(c_mine, out_down);
    } else {
        out_right.write(make_hdr(TYPE_C_DATA, my_r, my_s, 0));
        if (from_left_c) chan_to_port(c_pass, out_right, false);
        emit_c(c_mine, out_right);
    }
}

//  top
void sa_grid(stream_t &in_left,
             stream_t &in_up,
             stream_t &out_right,
             stream_t &out_down)
{
#pragma HLS INTERFACE axis      port=in_left
#pragma HLS INTERFACE axis      port=in_up
#pragma HLS INTERFACE axis      port=out_right
#pragma HLS INTERFACE axis      port=out_down
#pragma HLS INTERFACE s_axilite port=return bundle=control

#pragma HLS DATAFLOW

    buf_t        bufA, bufB;
    fwd_t        fwd_right, fwd_down;
    chan_t       c_pass;
    cross_t      xa_in, xb_in, xa_out, xb_out;
    acc_t_stream c_mine;
    // load reads the position out of the first header, so compute and store
    // each need to be told. One byte, once per run.
    hls::stream<ap_uint<8> > pos_c, pos_s;

    load(in_left, in_up, fwd_right, fwd_down, bufA, bufB,
         xa_in, xb_in, c_pass, pos_c, pos_s);

    compute(bufA, bufB, xa_in, xb_in, xa_out, xb_out, c_mine, pos_c);

    store(fwd_right, fwd_down, xa_out, xb_out, c_mine, c_pass,
          out_right, out_down, pos_s);
}
