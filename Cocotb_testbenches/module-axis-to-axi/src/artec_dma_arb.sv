module artec_dma_arb #(
	parameter                          CH_NUM           = artec_dma_pkg::PKG_CH_NUM           ,
	parameter                          CH_NUM_L         = artec_dma_pkg::PKG_CH_NUM_L         ,
	parameter                          REQ_WIDTH        = artec_dma_pkg::PKG_REQ_WIDTH        ,
	parameter                          RR_LAST_CNT_TRIG = artec_dma_pkg::PKG_ARB_LAST_CNT_TRIG,
	parameter logic [CH_NUM-1:0][31:0] RR_PRIORITY_TRIG = artec_dma_pkg::PKG_ARB_PRIORITY_TRIG
) (
	input                             clk                       , // Clock
	input                             rstn                      , // Asynchronous reset active low
	input artec_dma_pkg::settings_t   settings_i                ,
	artec_vr_if.slave                 stream_task_i [CH_NUM-1:0],
	artec_vr_if.slave                 stream_data_i [CH_NUM-1:0],
	input [CH_NUM-1:0][REQ_WIDTH-1:0] req_i                     ,
	artec_vr_if.master                stream_task_o             ,
	artec_vr_if.master                stream_data_o
);

import artec_dma_pkg::*;

// ******************************************************* //
// Types 
// ******************************************************* //

localparam BUFFER_TASK_EXE_CNT_WIDTH = 8;

typedef struct packed {
	logic [                 CH_NUM_L-1:0] idx;
	logic [BUFFER_TASK_EXE_CNT_WIDTH-1:0] cnt;
} arb_task_exe_t;

// ******************************************************* //
// Localparams 
// ******************************************************* //

localparam BUFFER_TASK_WIDTH = $bits(arb_task_o_t);
localparam BUFFER_TASK_DL    = 4                  ;

localparam BUFFER_TASK_EXE_WIDTH = $bits(arb_task_exe_t);
localparam BUFFER_TASK_EXE_DL    = 4                    ;

localparam BUFFER_DATA_WIDTH = $bits(ch_data_o_t)          ;
localparam BUFFER_DATA_DL    = $clog2(PKG_ARB_BUFFER_DEPTH);

// ******************************************************* //
// Declarations 
// ******************************************************* //

logic [CH_NUM-1:0][REQ_WIDTH-1:0] req_masked;

logic       [CH_NUM-1:0] task_valid_vec;
logic       [CH_NUM-1:0] task_ready_vec;
ch_task_o_t [CH_NUM-1:0] task_data_vec ;

logic       [CH_NUM-1:0] data_valid_vec;
logic       [CH_NUM-1:0] data_ready_vec;
ch_data_o_t [CH_NUM-1:0] data_data_vec ;

logic [CH_NUM_L-1:0] grant      ;
logic                grant_valid;

logic                task_valid_mux;
logic [CH_NUM_L-1:0] task_mux_idx  ;
arb_task_o_t         task_data_mux ;

logic                data_valid_mux;
logic [CH_NUM_L-1:0] data_mux_idx  ;
ch_data_o_t          data_data_mux ;

common_sync_fifo_if #(.DW(BUFFER_TASK_WIDTH),.DL(BUFFER_TASK_DL)) fifo_task();
common_sync_fifo_cnt_if #(.DW(BUFFER_TASK_EXE_WIDTH),.DL(BUFFER_TASK_EXE_DL)) fifo_task_exe();
common_sync_fifo_if #(.DW(BUFFER_DATA_WIDTH),.DL(BUFFER_DATA_DL)) fifo_data();

axis_cmd_t axis_cmd_fmt;

arb_task_o_t   fifo_task_fmt_i    ;
arb_task_exe_t fifo_task_exe_fmt_i;

arb_task_o_t   fifo_task_fmt_o    ;
arb_task_exe_t fifo_task_exe_fmt_o;

// ******************************************************* //
// Body 
// ******************************************************* //

// ******************************************************* //
// RR 
// ******************************************************* //

generate
	for (genvar i = 0; i < CH_NUM; i++) begin
		assign req_masked[i] = (!fifo_task.s.nfull) ? 0 : req_i[i];
	end
endgenerate

artec_dma_arb_rr #(
	.NUM_ELEMENTS (CH_NUM          ),
	.WIDTH_ELEMENT(REQ_WIDTH       ),
	.PRIORITY_TRIG(RR_PRIORITY_TRIG),
	.LAST_CNT_TRIG(RR_LAST_CNT_TRIG)
) i_RR (
	.clk          (clk                    ),
	.rstn         (rstn                   ),
	.clear        (settings_i.common.clear),
	.req_i        (req_masked             ),
	.grant_o      (grant                  ),
	.grant_valid_o(grant_valid            )
);

// ******************************************************* //
// Vectorize 
// ******************************************************* //

generate
	for (genvar i = 0; i < CH_NUM; i++) begin

		assign stream_task_i[i].ready = fifo_task.s.nfull && grant==i && grant_valid;
		assign stream_data_i[i].ready = fifo_data.s.nfull && fifo_task_exe.s.nempty && fifo_task_exe_fmt_o.idx==i;
		
		assign task_valid_vec[i] = stream_task_i[i].valid;
		assign task_ready_vec[i] = stream_task_i[i].ready;
		assign task_data_vec[i]  = stream_task_i[i].data;

		assign data_valid_vec[i] = stream_data_i[i].valid;
		assign data_ready_vec[i] = stream_data_i[i].ready;
		assign data_data_vec[i]  = stream_data_i[i].data;

	end
endgenerate

// ******************************************************* //
// MUX  
// ******************************************************* //

assign task_mux_idx   = grant;
assign task_valid_mux = task_valid_vec[task_mux_idx];
assign task_ready_mux = task_ready_vec[task_mux_idx];
assign task_data_mux  = task_data_vec[task_mux_idx];

assign data_mux_idx   = fifo_task_exe_fmt_o.idx;
assign data_valid_mux = data_valid_vec[data_mux_idx];
assign data_ready_mux = data_ready_vec[data_mux_idx];
assign data_data_mux  = data_data_vec[data_mux_idx];

// ******************************************************* //
// FIFO_TASK 
// ******************************************************* //

assign fifo_task_fmt_i.idx   = task_mux_idx;
assign fifo_task_fmt_i.taskf = task_data_mux;

assign fifo_task.m.write = task_valid_mux && task_ready_mux;
assign fifo_task.m.wdata = fifo_task_fmt_i;
assign fifo_task.m.read  = stream_task_o.valid && stream_task_o.ready;
assign fifo_task.m.clr   = settings_i.common.clear;

common_sync_fifo #(.DW(BUFFER_TASK_WIDTH), .DL(BUFFER_TASK_DL)) i_FIFO_TASK (
	.clk (clk      ),
	.rstn(rstn     ),
	.fifo(fifo_task)
);

assign fifo_task_fmt_o = fifo_task.s.nempty ? fifo_task.s.rdata : 0;

// ******************************************************* //
// FIFO_TASK_EXE 
// ******************************************************* //

assign fifo_task_exe_fmt_i.idx = fifo_task_fmt_o.idx;
assign fifo_task_exe_fmt_i.cnt = fifo_task_fmt_o.taskf.data_num - 1;

assign fifo_task_exe.m.write = fifo_task.m.read;
assign fifo_task_exe.m.wdata = fifo_task_exe_fmt_i;
assign fifo_task_exe.m.decr  = fifo_data.m.write;
assign fifo_task_exe.m.read  = fifo_task_exe.m.decr && fifo_task_exe_fmt_o.cnt==0;
assign fifo_task_exe.m.clr   = settings_i.common.clear;

common_sync_fifo_cnt #(.DW(BUFFER_TASK_EXE_WIDTH), .DL(BUFFER_TASK_EXE_DL), .CW(BUFFER_TASK_EXE_CNT_WIDTH)) i_FIFO_TASK_EXE (
	.clk (clk          ),
	.rstn(rstn         ),
	.fifo(fifo_task_exe)
);

assign fifo_task_exe_fmt_o = fifo_task_exe.s.nempty ? fifo_task_exe.s.rdata : 0;

// ******************************************************* //
// FIFO_DATA 
// ******************************************************* //

assign fifo_data.m.write = data_valid_mux && data_ready_mux;
assign fifo_data.m.wdata = data_data_mux;
assign fifo_data.m.read  = stream_data_o.valid && stream_data_o.ready; 
assign fifo_data.m.clr   = settings_i.common.clear;

common_sync_fifo_mem #(.DW(BUFFER_DATA_WIDTH), .DL(BUFFER_DATA_DL)) i_FIFO_DATA (
	.clk (clk      ),
	.rstn(rstn     ),
	.fifo(fifo_data)
);

// ******************************************************* //
// OUTPUT 
// ******************************************************* //

assign stream_task_o.valid = fifo_task.s.nempty && fifo_task_exe.s.nfull;
assign stream_task_o.data  = fifo_task.s.rdata;

assign stream_data_o.valid = fifo_data.s.nempty;// && fifo_task_exe.s.nempty;
assign stream_data_o.data  = fifo_data.s.rdata;

endmodule