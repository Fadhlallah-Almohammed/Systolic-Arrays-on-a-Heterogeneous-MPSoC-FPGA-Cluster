#ifndef SA_GRID_HPP
#define SA_GRID_HPP

#include <ap_int.h>
#include <hls_stream.h>
#include <ap_axi_sdata.h>

// One block of an R x S grid of PE x PE systolic blocks that together form a
// single logical (R*PE) x (S*PE) array. Every instance is the same IP 
//
// A enters the left edge of the whole array and flows right.
// B enters the top edge and flows down.
// Raw operands therefore reach only the edge blocks, so A frames travel down
// while A crosses right, and B frames travel right while B crosses down.
// Frames and crossing are always perpendicular.
//
// Four ports. Each physical link carries three kinds of traffic in sequence:
//
//   out_right :  B frames  ->  A crossing  ->  C
//   out_down  :  A frames  ->  B crossing  ->  C
//
// How a block knows where it is:
//   The first header to arrive is read with read_nb from whichever port raises
//   TVALID, so no port is ever blocked on. That header carries dst_r and dst_s,
//   the position of the block meant to keep it, which is this block. Everything
//   else follows: which ports to read, whether to inject from a buffer or from
//   a neighbour, the skew offset, and where C leaves.
//


#define PE 2                      // PEs per block, per dimension. Must be even.
#define R  2                      // blocks down
#define S  2                      // blocks right
#define K  4                      // accumulation depth

#define N     (R * PE)            // logical array rows
#define NC    (S * PE)            // logical array columns
#define W     (PE * 16)           // bus width, one crossing step per beat
#define STEPS (K + N + NC - 1)    // systolic steps, identical in every block
#define APB   (W / 32)            // accumulators per beat
#define CBEAT ((PE * PE) / APB)   // beats of one block's C tile

//  for the LOOP_TRIPCOUNT hints. A frame group holds at most
// max(R,S) frames, and the block that gathers the most C is the corner one.
// """"These affect the latency report only, never the generated hardware."""" becauyse it gave me question mark in the report in the latency field
#define FRAMES_MAX (((R) > (S)) ? (R) : (S))
#define FWD_MAX    ((FRAMES_MAX - 1) * (1 + K))
#define CPASS_MAX  ((((R) - 1) * (S) + ((S) - 1)) * CBEAT)

typedef ap_int<16> data_t;
typedef ap_int<32> acc_t;

// ap_axiu may only appear on top level AXI-Stream ports. Internal DATAFLOW
// channels use a plain struct, or a plain vector where no terminator is needed.
typedef ap_axiu<W, 0, 0, 0> word_t;
typedef hls::stream<word_t>  stream_t;

struct beat_t {
    ap_uint<W> data;
    bool       last;
};
// Depths are template arguments because a pragma value must be a plain integer
// while a template argument accepts the geometry expression. Sized from the
// worst case traffic on each channel, ""not guessed""" "it is enginnered"
typedef hls::stream<beat_t, FWD_MAX + 2>     fwd_t;    // frames passed along
typedef hls::stream<beat_t, CPASS_MAX + 2>   chan_t;   // C passing through
typedef hls::stream<ap_uint<W>, 4>           cross_t;  // crossing, consumed 1:1

// """The operand buffers are streams, not arrays""". An array between two DATAFLOW
// processes becomes a PIPO, and a PIPO is handed over only when the producer
// returns. load cannot return until it has streamed the crossing beats, and
// those are consumed by compute, so an array here deadlocks. A FIFO is readable
// while the producer is still running, which is what lets th// ap_axiue two overlap.
//
// One beat carries PE packed operands, exactly as it arrives on the wire. A
// stream takes one write per cycle, so unpacking here and writing PE times
// would force II=PE on the load loop. so compute unpacks instead.
typedef hls::stream<ap_uint<W>, K> buf_t;

// header, one full beat:
//   [31:24] magic word "s"   fixed, turns a lost word into a detected error
//   [23:20] type
//   [19:16] dst_r   row of the block that keeps this frame
//   [15:12] dst_s   column of the block that keeps this frame
//   [11: 0] len     payload beats that follow
#define HDR_MAGIC 0x53
#define TYPE_A_FRAME 0
#define TYPE_B_FRAME 1
#define TYPE_A_CROSS 2
#define TYPE_B_CROSS 3
#define TYPE_C_DATA  4

void sa_grid(stream_t &in_left,
             stream_t &in_up,
             stream_t &out_right,
             stream_t &out_down);

#endif
