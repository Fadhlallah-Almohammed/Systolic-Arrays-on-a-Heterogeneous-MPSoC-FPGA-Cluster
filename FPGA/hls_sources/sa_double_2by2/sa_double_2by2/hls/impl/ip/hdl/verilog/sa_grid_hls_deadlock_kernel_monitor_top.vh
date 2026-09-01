
wire kernel_monitor_reset;
wire kernel_monitor_clock;
wire kernel_monitor_report;
assign kernel_monitor_reset = ~ap_rst_n;
assign kernel_monitor_clock = ap_clk;
assign kernel_monitor_report = 1'b0;
wire [19:0] axis_block_sigs;
wire [17:0] inst_idle_sigs;
wire [2:0] inst_block_sigs;
wire kernel_block;

assign axis_block_sigs[0] = ~load_U0.in_left_TDATA_blk_n;
assign axis_block_sigs[1] = ~load_U0.in_up_TDATA_blk_n;
assign axis_block_sigs[2] = ~load_U0.grp_frame_group_fu_169.in_left_TDATA_blk_n;
assign axis_block_sigs[3] = ~load_U0.grp_frame_group_fu_169.in_up_TDATA_blk_n;
assign axis_block_sigs[4] = ~load_U0.grp_frame_group_fu_169.grp_frame_group_Pipeline_PAYLOAD_fu_179.in_up_TDATA_blk_n;
assign axis_block_sigs[5] = ~load_U0.grp_frame_group_fu_169.grp_frame_group_Pipeline_PAYLOAD_fu_179.in_left_TDATA_blk_n;
assign axis_block_sigs[6] = ~load_U0.grp_load_Pipeline_CROSS_fu_207.in_left_TDATA_blk_n;
assign axis_block_sigs[7] = ~load_U0.grp_load_Pipeline_CROSS_fu_207.in_up_TDATA_blk_n;
assign axis_block_sigs[8] = ~load_U0.grp_load_Pipeline_IN_PASS_fu_233.in_up_TDATA_blk_n;
assign axis_block_sigs[9] = ~load_U0.grp_load_Pipeline_IN_PASS5_fu_249.in_left_TDATA_blk_n;
assign axis_block_sigs[10] = ~store_U0.out_right_TDATA_blk_n;
assign axis_block_sigs[11] = ~store_U0.out_down_TDATA_blk_n;
assign axis_block_sigs[12] = ~store_U0.grp_store_Pipeline_OUT_PASS_fu_146.out_right_TDATA_blk_n;
assign axis_block_sigs[13] = ~store_U0.grp_store_Pipeline_OUT_PASS1_fu_160.out_down_TDATA_blk_n;
assign axis_block_sigs[14] = ~store_U0.grp_store_Pipeline_XCROSS_fu_174.out_right_TDATA_blk_n;
assign axis_block_sigs[15] = ~store_U0.grp_store_Pipeline_XCROSS_fu_174.out_down_TDATA_blk_n;
assign axis_block_sigs[16] = ~store_U0.grp_store_Pipeline_OUT_PASS3_fu_200.out_right_TDATA_blk_n;
assign axis_block_sigs[17] = ~store_U0.grp_store_Pipeline_MINE4_fu_214.out_right_TDATA_blk_n;
assign axis_block_sigs[18] = ~store_U0.grp_store_Pipeline_OUT_PASS2_fu_228.out_down_TDATA_blk_n;
assign axis_block_sigs[19] = ~store_U0.grp_store_Pipeline_MINE_fu_242.out_down_TDATA_blk_n;

assign inst_idle_sigs[0] = load_U0.ap_idle;
assign inst_block_sigs[0] = (load_U0.ap_done & ~load_U0.ap_continue) | ~load_U0.grp_frame_group_fu_169.grp_frame_group_Pipeline_PAYLOAD_fu_179.fwd_right_blk_n | ~load_U0.grp_frame_group_fu_169.fwd_right_blk_n | ~load_U0.grp_frame_group_fu_169.grp_frame_group_Pipeline_PAYLOAD_fu_179.fwd_down_blk_n | ~load_U0.grp_frame_group_fu_169.fwd_down_blk_n | ~load_U0.grp_frame_group_fu_169.grp_frame_group_Pipeline_PAYLOAD_fu_179.bufA_blk_n | ~load_U0.grp_frame_group_fu_169.grp_frame_group_Pipeline_PAYLOAD_fu_179.bufB_blk_n | ~load_U0.grp_load_Pipeline_CROSS_fu_207.xa_in_blk_n | ~load_U0.grp_load_Pipeline_CROSS_fu_207.xb_in_blk_n | ~load_U0.grp_load_Pipeline_IN_PASS_fu_233.c_pass_blk_n | ~load_U0.grp_load_Pipeline_IN_PASS5_fu_249.c_pass_blk_n | ~load_U0.pos_c_blk_n | ~load_U0.pos_s_blk_n;
assign inst_idle_sigs[1] = compute_U0.ap_idle;
assign inst_block_sigs[1] = (compute_U0.ap_done & ~compute_U0.ap_continue) | ~compute_U0.grp_compute_Pipeline_VITIS_LOOP_207_1_fu_332.bufA_blk_n | ~compute_U0.grp_compute_Pipeline_VITIS_LOOP_217_3_fu_346.bufB_blk_n | ~compute_U0.grp_compute_Pipeline_STEP_fu_360.xa_in_blk_n | ~compute_U0.grp_compute_Pipeline_STEP_fu_360.xb_in_blk_n | ~compute_U0.grp_compute_Pipeline_STEP_fu_360.xa_out_blk_n | ~compute_U0.grp_compute_Pipeline_STEP_fu_360.xb_out_blk_n | ~compute_U0.grp_compute_Pipeline_DRAIN_VITIS_LOOP_321_9_fu_412.c_mine_blk_n | ~compute_U0.pos_c_blk_n;
assign inst_idle_sigs[2] = store_U0.ap_idle;
assign inst_block_sigs[2] = (store_U0.ap_done & ~store_U0.ap_continue) | ~store_U0.grp_store_Pipeline_OUT_PASS_fu_146.fwd_right_blk_n | ~store_U0.grp_store_Pipeline_OUT_PASS1_fu_160.fwd_down_blk_n | ~store_U0.grp_store_Pipeline_XCROSS_fu_174.xa_out_blk_n | ~store_U0.grp_store_Pipeline_XCROSS_fu_174.xb_out_blk_n | ~store_U0.grp_store_Pipeline_MINE4_fu_214.c_mine_blk_n | ~store_U0.grp_store_Pipeline_MINE_fu_242.c_mine_blk_n | ~store_U0.grp_store_Pipeline_OUT_PASS3_fu_200.c_pass_blk_n | ~store_U0.grp_store_Pipeline_OUT_PASS2_fu_228.c_pass_blk_n | ~store_U0.pos_s_blk_n;

assign inst_idle_sigs[3] = 1'b0;
assign inst_idle_sigs[4] = load_U0.ap_idle;
assign inst_idle_sigs[5] = load_U0.grp_frame_group_fu_169.ap_idle;
assign inst_idle_sigs[6] = load_U0.grp_frame_group_fu_169.grp_frame_group_Pipeline_PAYLOAD_fu_179.ap_idle;
assign inst_idle_sigs[7] = load_U0.grp_load_Pipeline_CROSS_fu_207.ap_idle;
assign inst_idle_sigs[8] = load_U0.grp_load_Pipeline_IN_PASS_fu_233.ap_idle;
assign inst_idle_sigs[9] = load_U0.grp_load_Pipeline_IN_PASS5_fu_249.ap_idle;
assign inst_idle_sigs[10] = store_U0.ap_idle;
assign inst_idle_sigs[11] = store_U0.grp_store_Pipeline_OUT_PASS_fu_146.ap_idle;
assign inst_idle_sigs[12] = store_U0.grp_store_Pipeline_OUT_PASS1_fu_160.ap_idle;
assign inst_idle_sigs[13] = store_U0.grp_store_Pipeline_XCROSS_fu_174.ap_idle;
assign inst_idle_sigs[14] = store_U0.grp_store_Pipeline_OUT_PASS3_fu_200.ap_idle;
assign inst_idle_sigs[15] = store_U0.grp_store_Pipeline_MINE4_fu_214.ap_idle;
assign inst_idle_sigs[16] = store_U0.grp_store_Pipeline_OUT_PASS2_fu_228.ap_idle;
assign inst_idle_sigs[17] = store_U0.grp_store_Pipeline_MINE_fu_242.ap_idle;

sa_grid_hls_deadlock_idx0_monitor sa_grid_hls_deadlock_idx0_monitor_U (
    .clock(kernel_monitor_clock),
    .reset(kernel_monitor_reset),
    .axis_block_sigs(axis_block_sigs),
    .inst_idle_sigs(inst_idle_sigs),
    .inst_block_sigs(inst_block_sigs),
    .block(kernel_block)
);


always @ (kernel_block or kernel_monitor_reset) begin
    if (kernel_block == 1'b1 && kernel_monitor_reset == 1'b0) begin
        find_kernel_block = 1'b1;
    end
    else begin
        find_kernel_block = 1'b0;
    end
end
