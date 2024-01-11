module artec_dma_top #(parameter APB_ID = 32'hA3D_0000) (
	input               clk            , // Clock
	input               rstn           , // Asynchronous reset active low
	input               apb_clk        ,
	input               apb_rstn       ,
	artec_apb_if.slave  apb_i          ,
	artec_axis_if.slave axis_bus_i[5:0],
	artec_axi_if.master axi_o          ,
	artec_vr_if.master  header_req_o   ,
	artec_vr_if.slave   header_ack_i
);

artec_axis_if #(.DW(32),.UW(5)) axis_tmp();

import artec_dma_pkg::*;

// ******************************************************* //
// Signals
// ******************************************************* //

artec_vr_if #(.DW($bits(artec_dma_pkg::cnv_o_t))) cnv_stream [PKG_CH_NUM-1:0]();

artec_vr_if #(.DW($bits(artec_dma_pkg::ch_task_o_t))) channel_task [PKG_CH_NUM-1:0]();
artec_vr_if #(.DW($bits(artec_dma_pkg::ch_data_o_t))) channel_data [PKG_CH_NUM-1:0]();

artec_vr_if #(.DW($bits(artec_dma_pkg::arb_task_o_t))) arbiter_task();
artec_vr_if #(.DW($bits(artec_dma_pkg::arb_data_o_t))) arbiter_data();

artec_vr_if #(.DW($bits(artec_dma_pkg::sync_task_o_t))) sync_task();
artec_vr_if #(.DW($bits(artec_dma_pkg::sync_data_o_t))) sync_data();

artec_axis_if #(.DW($bits(artec_dma_pkg::axis_cmd_t))) axis_cmd();
artec_axis_if #(.DW($bits(artec_dma_pkg::axis_data_t))) axis_data();

logic [PKG_CH_NUM-1:0][PKG_REQ_WIDTH-1:0] channel_occ;

artec_dma_pkg::settings_t settings;
artec_dma_pkg::status_t   status  ;

// ******************************************************* //
// APB
// ******************************************************* //

artec_dma_apb_top #(.APB_ID(APB_ID)) i_APB (
	.apb_clk   (apb_clk ),
	.apb_rstn  (apb_rstn),
	.clk       (clk     ),
	.rstn      (rstn    ),
	.apb_i     (apb_i   ),
	.settings_o(settings),
	.status_i  (status  )
);

// ******************************************************* //
// DMA Channels
// ******************************************************* //

// ******************************************************* //
// Width conversion
// ******************************************************* //

for (genvar i = 0; i < PKG_CH_NUM; i++) begin : CNV_GEN

	artec_dma_cnv #(
		.INPUT_WIDTH (PKG_CH_INPUT_WIDTH[i]),
		.OUTPUT_WIDTH(PKG_AXI_DATA_WIDTH   )
	) i_CONVERTER (
		.clk        (clk                   ),
		.rstn       (rstn                  ),
		.settings_i (settings              ),
		.axis_i     (axis_bus_i[i]         ),
		.stream_o   (cnv_stream[i]         ),
		.frame_num_o(status.frame_number[i])
	);

end

// ******************************************************* //
// Packet generator generator & Buffer
// ******************************************************* //

for (genvar i = 0; i < PKG_CH_NUM; i++) begin : CHANNEL_GEN

	artec_dma_channel #(
		.PACKET_SIZE (PKG_CH_PACKET_SIZE[i] ),
		.BUFFER_DEPTH(PKG_CH_BUFFER_DEPTH[i]),
		.BUFFER_WIDTH(PKG_AXI_DATA_WIDTH    ),
		.REQ_WIDTH   (PKG_REQ_WIDTH         )
	) i_CHANNEL (
		.clk               (clk                 ),
		.rstn              (rstn                ),
		.settings_channel_i(settings.channel[i] ),
		.settings_common_i (settings.common     ),
		.stream_i          (cnv_stream[i]       ),
		.stream_task_o     (channel_task[i]     ),
		.stream_data_o     (channel_data[i]     ),
		.occ               (channel_occ[i]      ),
		.fifo_flags_o      (status.fifo_flags[i])
	);

end

// ******************************************************* //
// Arbiter with Modified Round Robin
// ******************************************************* //

artec_dma_arb #(
	.CH_NUM          (PKG_CH_NUM           ),
	.CH_NUM_L        (PKG_CH_NUM_L         ),
	.REQ_WIDTH       (PKG_REQ_WIDTH        ),
	.RR_PRIORITY_TRIG(PKG_ARB_PRIORITY_TRIG),
	.RR_LAST_CNT_TRIG(PKG_ARB_LAST_CNT_TRIG)
) i_ARBITER (
	.clk          (clk         ),
	.rstn         (rstn        ),
	.settings_i   (settings    ),
	.stream_task_i(channel_task),
	.stream_data_i(channel_data),
	.req_i        (channel_occ ),
	.stream_task_o(arbiter_task),
	.stream_data_o(arbiter_data)
);

// ******************************************************* //
// Channel Sync Search
// ******************************************************* //

artec_dma_sync #(.CH_NUM(PKG_CH_NUM),.FB_NUM(PKG_FB_NUM)) i_SYNC (
	.clk          (clk         ),
	.rstn         (rstn        ),
	.settings_i   (settings    ),
	.stream_task_i(arbiter_task),
	.stream_data_i(arbiter_data),
	.stream_task_o(sync_task   ),
	.stream_data_o(sync_data   )
);

// ******************************************************* //
// Header Generator
// ******************************************************* //

artec_dma_header i_HEADER (
	.clk           (clk                ),
	.rstn          (rstn               ),
	.settings_i    (settings           ),
	.stop_o        (status.stop        ),
	.task_stream_i (sync_task          ),
	.data_stream_i (sync_data          ),
	.axis_cmd_o    (axis_cmd           ),
	.axis_data_o   (axis_data          ),
	.frame_status_o(status.frame_status),
	.header_req_o  (header_req_o       ),
	.header_ack_i  (header_ack_i       )
);

// ******************************************************* //
// AXIS 2 AXI
// ******************************************************* //

axi_datamover_0_wrp i_BRIDGE (
	.clk        (clk      ),
	.rstn       (rstn     ),
	.axis_data_i(axis_data),
	.axis_cmd_i (axis_cmd ),
	.axi_o      (axi_o    )
);

endmodule
