#include <cstdio>
#include "sa_grid.hpp"

// ONE call, driving sa_grid exactly the way block (1,0) is driven on the board.
//
// in_left  : nothing at all, the same as a port tied off in the block design
// in_up    : the 17 beats that (0,0) sends down
//              1 + K  the A frame addressed to (1,0), TLAST on its last beat
//              1      the B_CROSS header addressed to (1,0)
//              STEPS  crossing beats, TLAST on the last
// out_right: must produce 1 + STEPS crossing + 1 + CBEAT of C = 17 beats
// out_down : nothing, this block is on the last row
//
// Block (1,0) has a code path no other block takes: it reads its frames from
// in_up, it injects A from a buffer while receiving B by crossing, and being
// on the last row it never writes out_down. None of that has ever run in RTL.
// The single-block co-simulation that passed covered (0,0) only.
//
// Hardware measurement says this block consumes fewer than 7 of the 17 beats
// before it stops, so the fault is in the first few beats of this sequence.

int main()
{
    stream_t in_left, in_up, out_right, out_down;

    // --- the A frame for row 1, TLAST on the last payload beat ---------
    word_t h;
    h.data = 0;
    h.data.range(31,24) = HDR_MAGIC;
    h.data.range(23,20) = TYPE_A_FRAME;
    h.data.range(19,16) = 1;              // dst_r = 1
    h.data.range(15,12) = 0;              // dst_s = 0
    h.data.range(11, 0) = K;
    h.keep = -1; h.strb = -1; h.last = 0;
    in_up.write(h);
    for (int k = 0; k < K; k++) {
        word_t w; w.data = 0;
        for (int n = 0; n < PE; n++)
            w.data.range(16*n+15, 16*n) = (k*PE + n + 1) & 0xFFFF;
        w.keep = -1; w.strb = -1;
        w.last = (k == K-1) ? 1 : 0;      // ends the frame group
        in_up.write(w);
    }

    // --- the crossing header, then STEPS beats -------------------------
    word_t c;
    c.data = 0;
    c.data.range(31,24) = HDR_MAGIC;
    c.data.range(23,20) = TYPE_B_CROSS;
    c.data.range(19,16) = 1;              // dst_r = 1
    c.data.range(15,12) = 0;              // dst_s = 0
    c.data.range(11, 0) = STEPS;
    c.keep = -1; c.strb = -1; c.last = 0;
    in_up.write(c);
    for (int t = 0; t < STEPS; t++) {
        word_t w; w.data = 0;
        for (int n = 0; n < PE; n++)
            w.data.range(16*n+15, 16*n) = (t + n) & 0xFFFF;
        w.keep = -1; w.strb = -1;
        w.last = (t == STEPS-1) ? 1 : 0;
        in_up.write(w);
    }

    const int want_in    = (1 + K) + (1 + STEPS);
    const int want_right = (1 + STEPS) + (1 + CBEAT);
    printf("in_up %d beats, in_left empty, expect out_right %d, out_down 0\n",
           want_in, want_right);

    sa_grid(in_left, in_up, out_right, out_down);

    int errors = 0;
    int left_unread = (int)in_up.size();
    printf("consumed %d of %d, out_right %d, out_down %d\n",
           want_in - left_unread, want_in, (int)out_right.size(), (int)out_down.size());

    if (left_unread)               { printf("FAIL: %d beats unread on in_up\n", left_unread); errors++; }
    if ((int)out_right.size() != want_right) { printf("FAIL: out_right count\n"); errors++; }
    if (!out_down.empty())         { printf("FAIL: wrote to out_down on the last row\n"); errors++; }

    if ((int)out_right.size() == want_right) {
        word_t w = out_right.read();
        if ((int)(unsigned long long)w.data.range(23,20) != TYPE_A_CROSS) {
            printf("FAIL: first header is not A_CROSS\n"); errors++; }
        for (int t = 0; t < STEPS; t++) out_right.read();
        w = out_right.read();
        if ((int)(unsigned long long)w.data.range(23,20) != TYPE_C_DATA) {
            printf("FAIL: second header is not C_DATA\n"); errors++; }
    }
    while (!out_right.empty()) out_right.read();

    printf("errors=%d\n%s\n", errors, errors ? "FAIL" : "PASS");
    return errors != 0;
}