module artec_dma_header (
	input                            clk           , // Clock
	input                            rstn          , // Asynchronous reset active low
	input  artec_dma_pkg::settings_t settings_i    ,
	output                           stop_o        ,
	artec_vr_if.slave                task_stream_i ,
	artec_vr_if.slave                data_stream_i ,
	artec_axis_if.master             axis_cmd_o    ,
	artec_axis_if.master             axis_data_o   ,
	artec_vr_if.master               header_req_o  ,
	artec_vr_if.slave                header_ack_i  ,
	output [7:0]                     frame_status_o
);

import artec_dma_pkg::*;

// ******************************************************* //
// Localparams 
// ******************************************************* //

localparam NUM_HEADER_STEPS = 34;
localparam NUM_STATUS_STEPS = 2;

// ******************************************************* //
// Types 
// ******************************************************* //

typedef enum logic [2:0] {STOP,PASS,FLUSH,HEADER,STATUS} state_t;

// ******************************************************* //
// Declarations 
// ******************************************************* //

sync_task_o_t task_stream_fmt_i;

state_t state_w;
state_t state_r;

logic stop2pass    ;
logic pass2flush   ;
logic flush2header ;
logic flush2stop   ;
logic header2status;
logic status2pass  ;

logic stop_request;

cnt_cl#(.MAX_VALUE(NUM_HEADER_STEPS))::cnt_t header_cnt ;
cnt_cl#(.MAX_VALUE(NUM_STATUS_STEPS))::cnt_t status_cnt ;

info_t header_info;

cnt_cl#(.MAX_VALUE(32767))::cnt_t data_flush_cnt ;
logic [15:0] data_flush_incr;
logic        data_flush_decr;

logic [PKG_FB_NUM-1:0] frame_status_set;
logic [PKG_FB_NUM-1:0] frame_status_clr;
logic [PKG_FB_NUM-1:0] frame_status;

// ******************************************************* //
// Input FMT
// ******************************************************* //

assign task_stream_fmt_i = task_stream_i.data;

// ******************************************************* //
// FSM 
// ******************************************************* //

assign stop2pass     = settings_i.common.start;
assign pass2flush    = task_stream_i.valid && task_stream_i.ready && task_stream_fmt_i.sync || stop_request;
assign flush2header  = data_flush_cnt.cur==0 && !stop_request;
assign flush2stop    = data_flush_cnt.cur==0 &&  stop_request;
assign header2status = header_cnt.clr;
assign status2pass   = status_cnt.clr;

always_comb begin : proc_state_w

	case (state_r)
		STOP   : state_w = (stop2pass    ) ? PASS   : STOP;
		PASS   : state_w = (pass2flush   ) ? FLUSH  : PASS;
		FLUSH  : state_w = (flush2stop   ) ? STOP   :
						   (flush2header ) ? HEADER : FLUSH;
		HEADER : state_w = (header2status) ? STATUS : HEADER; 
		STATUS : state_w = (status2pass  ) ? PASS   : STATUS; 

		default : state_w = state_r;
	endcase

end

always_ff @(posedge clk `async_rstn(rstn)) begin : proc_state_r
    if(~rstn) begin
        state_r <= STOP;
    end else if (settings_i.common.clear) begin
    	state_r <= STOP;
    end else begin
        state_r <= state_w;
    end
end

// ******************************************************* //
// Stop request
// ******************************************************* //

always_ff @(posedge clk or negedge rstn) begin : proc_
	if(~rstn) begin
		stop_request <= 0;
	end else begin
		stop_request <= (settings_i.common.stop) ? 1'b1 : 
					    (state_r==STOP         ) ? 1'b0 : stop_request;
	end
end

// ******************************************************* //
// Data Wait Cnt 
// ******************************************************* //

assign data_flush_incr = (task_stream_i.valid && task_stream_i.ready) ? task_stream_fmt_i.taskf.data_num : 0;
assign data_flush_decr = (data_stream_i.valid && data_stream_i.ready) ? 1'b1 : 0;

assign data_flush_cnt.incr = |data_flush_incr || |data_flush_decr;
assign data_flush_cnt.next = data_flush_cnt.cur + data_flush_incr - data_flush_decr;
assign data_flush_cnt.last = data_flush_cnt.next==0;
assign data_flush_cnt.clr  = data_flush_cnt.incr && data_flush_cnt.last || settings_i.common.clear;

always_ff @(posedge clk `async_rstn(rstn)) begin : proc_data_flush_cnt
    if(~rstn) begin
        data_flush_cnt.cur <= 0;
    end else begin
        data_flush_cnt.cur <= (data_flush_cnt.clr ) ? 0 :
        					  (data_flush_cnt.incr) ? data_flush_cnt.next : data_flush_cnt.cur;
    end
end

// ******************************************************* //
// Header Info && counter 
// ******************************************************* //

always_ff @(posedge clk `async_rstn(rstn)) begin : proc_header_info
    if(~rstn) begin
        header_info <= 0;
    end else if (settings_i.common.clear) begin
    	header_info <= 0;
    end else begin
        header_info <= (state_r==PASS && pass2flush && !stop_request) ? task_stream_fmt_i.taskf.info : header_info; 
    end
end

logic header_next_step;

assign header_next_step = header_cnt.cur==0 ? axis_cmd_o.s.tready :
						  header_cnt.cur==1 ? header_req_o.valid && header_req_o.ready : header_ack_i.valid && header_ack_i.ready;

assign header_cnt.incr = state_r==HEADER && header_next_step;
assign header_cnt.next = header_cnt.cur + 1;
assign header_cnt.last = header_cnt.next==NUM_HEADER_STEPS;
assign header_cnt.clr  = header_cnt.incr && header_cnt.last || settings_i.common.clear;

always_ff @(posedge clk `async_rstn(rstn)) begin : proc_header_cnt
    if(~rstn) begin
        header_cnt.cur <= 0;
    end else begin
        header_cnt.cur <= (header_cnt.clr)  ? 0 :
        				  (header_cnt.incr) ? header_cnt.next : header_cnt.cur;
    end
end

// ******************************************************* //
// Status counter 
// ******************************************************* //

assign status_next_step = status_cnt.cur==0 ? axis_cmd_o.s.tready : axis_data_o.s.tready;

assign status_cnt.incr = state_r==STATUS && status_next_step;
assign status_cnt.next = status_cnt.cur + 1;
assign status_cnt.last = status_cnt.next==NUM_STATUS_STEPS;
assign status_cnt.clr  = status_cnt.incr && status_cnt.last || settings_i.common.clear;

always_ff @(posedge clk `async_rstn(rstn)) begin : proc_status_cnt
    if(~rstn) begin
        status_cnt.cur <= 0;
    end else begin
        status_cnt.cur <= (status_cnt.clr)  ? 0 :
        				  (status_cnt.incr) ? status_cnt.next : status_cnt.cur;
    end
end

// ******************************************************* //
// Status frame register 
// ******************************************************* //

logic [2:0] wait_fnum  ;

always_ff @(posedge clk `async_rstn(rstn)) begin : proc_last_fnum
    if(~rstn) begin
        wait_fnum <= 0;
    end else if (settings_i.common.clear) begin
    	wait_fnum <= 0;
    end else begin
        wait_fnum <= state_r==STATUS && status2pass ? header_info.fnum + 1 : wait_fnum;
    end
end

logic [2:0] clear_frame_fnum;

assign clear_frame_fnum = header_info.fnum + 1;

generate
	for (genvar i = 0; i < PKG_FB_NUM; i++) begin
			
		assign frame_status_set[i] = state_r==HEADER && header2status && header_info.fnum==i;
		assign frame_status_clr[i] = state_r==HEADER && header2status && (clear_frame_fnum==i || header_info.fnum!=wait_fnum);

		always_ff @(posedge clk `async_rstn(rstn)) begin : proc_frame_status
		    if(~rstn) begin
		        frame_status[i] <= 0;
		    end else if (settings_i.common.clear) begin
		    	frame_status[i] <= 0;
		    end else begin
		        frame_status[i] <= (frame_status_set[i]) ? 1'b1 :
		        				   (frame_status_clr[i]) ? 1'b0 : frame_status[i];
		    end
		end

	end	
endgenerate

// ******************************************************* //
// Frame ID 
// ******************************************************* //

cnt_cl#(.MAX_VALUE((1<<32)-1))::cnt_t frame_id_cnt;

assign frame_id_cnt.incr = state_r==STATUS && status2pass;
assign frame_id_cnt.next = frame_id_cnt.cur + 1;
assign frame_id_cnt.last = 0;
assign frame_id_cnt.clr  = settings_i.common.clear;

always_ff @(posedge clk `async_rstn(rstn)) begin : proc_frame_id_cnt
    if(~rstn) begin
        frame_id_cnt.cur <= 0;
    end else begin
        frame_id_cnt.cur <= (frame_id_cnt.clr)  ? 0 :
        				    (frame_id_cnt.incr) ? frame_id_cnt.next : frame_id_cnt.cur;
    end
end

// ******************************************************* //
// AXIS format 
// ******************************************************* //

// CMD Format

axis_cmd_t  axis_cmd_fmt;

always_comb begin : proc_axis_cmd_fmt

	axis_cmd_fmt = 0;
	axis_cmd_fmt.f_type = 1;

	if (state_r==HEADER && header_cnt.cur==0) begin

		axis_cmd_fmt.f_btt   = (NUM_HEADER_STEPS-2)<<PKG_ADDRESS_SHIFT;
		axis_cmd_fmt.f_saddr = settings_i.common.framebuffer_addr[header_info.fnum] + artec_dma_pkg::PKG_OFFSET_HEADER;

	end else if (state_r==STATUS && status_cnt.cur==0) begin

		axis_cmd_fmt.f_btt   = 16;
		axis_cmd_fmt.f_saddr = settings_i.common.status_addr;

	end else begin

		axis_cmd_fmt.f_btt   = task_stream_fmt_i.taskf.data_num<<PKG_ADDRESS_SHIFT;
		axis_cmd_fmt.f_saddr = task_stream_fmt_i.taskf.address;

	end

end

// DATA format

axis_data_t axis_data_fmt;

always_comb begin : proc_axis_data_fmt

	if (state_r==HEADER) begin
		axis_data_fmt = header_ack_i.data;

	end else if (state_r==STATUS) begin
		axis_data_fmt = {frame_id_cnt.cur,24'h0,frame_status};

	end else begin
		axis_data_fmt = data_stream_i.data;
	end

end

// ******************************************************* //
// Outputs 
// ******************************************************* //

assign task_stream_i.ready = axis_cmd_o.s.tready && state_r==PASS;
assign data_stream_i.ready = axis_data_o.s.tready && (state_r==PASS || state_r==FLUSH && data_flush_cnt.cur != 0);

assign axis_cmd_o.m.tvalid = state_r==PASS && task_stream_i.valid || state_r==HEADER && header_cnt.cur==0 || state_r==STATUS && status_cnt.cur==0;
assign axis_cmd_o.m.tdata  = axis_cmd_fmt;
assign axis_cmd_o.m.tuser  = 0;
assign axis_cmd_o.m.tstrb  = -1;
assign axis_cmd_o.m.tlast  = 0;

assign axis_data_o.m.tvalid = (state_r==PASS || state_r==FLUSH && data_flush_cnt.cur != 0) && data_stream_i.valid || state_r==HEADER && header_ack_i.valid || state_r==STATUS && status_cnt.cur!=0;
assign axis_data_o.m.tdata  = axis_data_fmt;
assign axis_data_o.m.tuser  =  0;
assign axis_data_o.m.tstrb  = -1;
assign axis_data_o.m.tlast  =  0;

assign frame_status_o = frame_status;

assign header_req_o.valid = state_r==HEADER && header_cnt.cur==1;
assign header_req_o.data  = header_info.fnum;

assign header_ack_i.ready = axis_data_o.s.tready;

assign stop_o = state_r==STOP;

endmodule