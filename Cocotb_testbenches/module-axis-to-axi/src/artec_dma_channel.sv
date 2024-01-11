module artec_dma_channel #(
	parameter PACKET_SIZE  = 32  ,
	parameter BUFFER_DEPTH = 1024,
	parameter BUFFER_WIDTH = 512 ,
	parameter REQ_WIDTH    = 8
) (
	input                                    clk               , // Clock
	input                                    rstn              , // Asynchronous reset active low
	input  artec_dma_pkg::settings_channel_t settings_channel_i,
	input  artec_dma_pkg::settings_common_t  settings_common_i ,
	artec_vr_if.slave                        stream_i          ,
	artec_vr_if.master                       stream_task_o     ,
	artec_vr_if.master                       stream_data_o     ,
	output artec_dma_pkg::fifo_flags_t       fifo_flags_o      ,
	output [REQ_WIDTH-1:0]                   occ
);

import artec_dma_pkg::*;

// ******************************************************* //
// Parameters 
// ******************************************************* //

localparam BUFFER_TASK_DEPTH = BUFFER_DEPTH/PACKET_SIZE;
localparam BUFFER_TASK_WIDTH = $bits(ch_task_o_t)      ;

// ******************************************************* //
// Declarations 
// ******************************************************* //

logic channel_size_overflow;

cnv_o_t in_fmt;

cnt_cl#(.MAX_VALUE(PACKET_SIZE))::cnt_t bundle_cnt;
cnt_cl#(.MAX_VALUE((1<<32)-1))::cnt_t address_cnt;

ch_task_o_t task_w;
ch_data_o_t data_w;

common_sync_fifo_if #(.DW(BUFFER_TASK_WIDTH), .DL(BUFFER_TASK_DEPTH)) fifo_task ();

common_sync_fifo_if #(.DW(BUFFER_WIDTH), .DL($clog2(BUFFER_DEPTH))) fifo_data ();

// ******************************************************* //
// Input fmt 
// ******************************************************* //

assign in_fmt = stream_i.data;

// ******************************************************* //
// Task generation
// ******************************************************* //

assign channel_size_overflow = address_cnt.next >= settings_channel_i.channel_size;

// Bundle counter

assign bundle_cnt.incr = stream_i.valid && stream_i.ready && settings_channel_i.enable;
assign bundle_cnt.next = bundle_cnt.cur + 1;
assign bundle_cnt.last = bundle_cnt.next==PACKET_SIZE || in_fmt.info.eof || channel_size_overflow;
assign bundle_cnt.clr  = bundle_cnt.incr && bundle_cnt.last || settings_common_i.clear;

always_ff @(posedge clk `async_rstn(rstn)) begin : proc_bundle_cnt
    if(~rstn) begin
        bundle_cnt.cur <= 0;
    end else begin
        bundle_cnt.cur <= (bundle_cnt.clr ) ? 0 :
        				  (bundle_cnt.incr) ? bundle_cnt.next : bundle_cnt.cur;
    end
end

// Address counter

assign address_cnt.incr = fifo_task.m.write;
assign address_cnt.next = address_cnt.cur + (bundle_cnt.next<<PKG_ADDRESS_SHIFT);
assign address_cnt.last = channel_size_overflow;
assign address_cnt.clr  = address_cnt.incr && in_fmt.info.eof || address_cnt.incr && address_cnt.last || settings_common_i.clear;

always_ff @(posedge clk `async_rstn(rstn)) begin : proc_address
    if(~rstn) begin
        address_cnt.cur <= 0;
    end else begin
        address_cnt.cur <= address_cnt.clr  ? 0 :
	        	           address_cnt.incr ? address_cnt.next : address_cnt.cur;
	end
end

logic [31:0] address_w;

assign address_w = settings_common_i.framebuffer_addr[in_fmt.info.fnum] + settings_channel_i.offset + address_cnt.cur;

// Task format

always_comb begin : proc_task

	task_w.address  = address_w;
	task_w.data_num = bundle_cnt.next;
	task_w.info     = in_fmt.info;

	data_w = in_fmt.data;

end

// ******************************************************* //
// TASK FIFO 
// ******************************************************* //

assign fifo_task.m.write = bundle_cnt.clr;
assign fifo_task.m.wdata = task_w;
assign fifo_task.m.read  = stream_task_o.valid && stream_task_o.ready;
assign fifo_task.m.clr   = settings_common_i.clear;

common_sync_fifo_mem #(
	.DW(BUFFER_TASK_WIDTH        ),
	.DL($clog2(BUFFER_TASK_DEPTH))
) i_FIFO_TASK (
	.clk (clk      ),
	.rstn(rstn     ),
	.fifo(fifo_task)
);

// ******************************************************* //
// DATA FIFO 
// ******************************************************* //

assign fifo_data.m.write = stream_i.valid && stream_i.ready && settings_channel_i.enable;
assign fifo_data.m.read  = stream_data_o.valid && stream_data_o.ready;
assign fifo_data.m.wdata = data_w;
assign fifo_data.m.clr   = settings_common_i.clear;

common_sync_fifo_mem #(
	.RAM_TYPE("ULTRA"             ),
	.DW      (BUFFER_WIDTH        ),
	.DL      ($clog2(BUFFER_DEPTH))
) i_BUFFER (
	.clk (clk      ),
	.rstn(rstn     ),
	.fifo(fifo_data)
);

// ******************************************************* //
// Flags to APB 
// ******************************************************* //

assign fifo_flags_o.dfifo_full = !fifo_data.s.nfull;
assign fifo_flags_o.cfifo_full = !fifo_task.s.nfull;

// ******************************************************* //
// Output 
// ******************************************************* //

assign stream_task_o.data  = fifo_task.s.rdata;
assign stream_task_o.valid = fifo_task.s.nempty;

assign stream_data_o.data  = fifo_data.s.rdata;
assign stream_data_o.valid = fifo_data.s.nempty;

assign stream_i.ready = fifo_task.s.nfull && fifo_data.s.nfull || !settings_channel_i.enable;

assign occ = fifo_task.s.nempty ? fifo_task.s.occ : 0;

endmodule