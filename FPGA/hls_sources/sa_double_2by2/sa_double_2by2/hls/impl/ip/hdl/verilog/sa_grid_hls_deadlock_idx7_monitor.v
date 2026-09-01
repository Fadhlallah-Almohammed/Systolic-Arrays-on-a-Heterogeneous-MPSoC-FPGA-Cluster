`timescale 1 ns / 1 ps

module sa_grid_hls_deadlock_idx7_monitor ( // for module sa_grid_sa_grid_inst.store_U0
    input wire clock,
    input wire reset,
    input wire [19:0] axis_block_sigs,
    input wire [17:0] inst_idle_sigs,
    input wire [2:0] inst_block_sigs,
    output wire block
);

// signal declare
reg monitor_find_block;
wire idx8_block;
wire idx10_block;
wire idx11_block;
wire idx12_block;
wire idx9_block;
wire idx13_block;
wire idx14_block;
wire sub_parallel_block;
wire all_sub_parallel_has_block;
wire all_sub_single_has_block;
wire cur_axis_has_block;
wire seq_is_axis_block;

assign block = monitor_find_block;
assign idx8_block = axis_block_sigs[12];
assign idx11_block = axis_block_sigs[16];
assign idx12_block = axis_block_sigs[17];
assign idx9_block = axis_block_sigs[13];
assign idx13_block = axis_block_sigs[18];
assign idx14_block = axis_block_sigs[19];
assign all_sub_parallel_has_block = 1'b0;
assign all_sub_single_has_block = 1'b0 | (idx8_block & (axis_block_sigs[12])) | (idx10_block & (axis_block_sigs[14] | axis_block_sigs[15])) | (idx11_block & (axis_block_sigs[16])) | (idx12_block & (axis_block_sigs[17])) | (idx9_block & (axis_block_sigs[13])) | (idx13_block & (axis_block_sigs[18])) | (idx14_block & (axis_block_sigs[19]));
assign cur_axis_has_block = 1'b0 | axis_block_sigs[10] | axis_block_sigs[11];
assign seq_is_axis_block = all_sub_parallel_has_block | all_sub_single_has_block | cur_axis_has_block;

always @(posedge clock) begin
    if (reset == 1'b1)
        monitor_find_block <= 1'b0;
    else if (seq_is_axis_block == 1'b1)
        monitor_find_block <= 1'b1;
    else
        monitor_find_block <= 1'b0;
end


// instant sub module
 sa_grid_hls_deadlock_idx10_monitor sa_grid_hls_deadlock_idx10_monitor_U (
    .clock(clock),
    .reset(reset),
    .axis_block_sigs(axis_block_sigs),
    .inst_idle_sigs(inst_idle_sigs),
    .inst_block_sigs(inst_block_sigs),
    .block(idx10_block)
);

endmodule
