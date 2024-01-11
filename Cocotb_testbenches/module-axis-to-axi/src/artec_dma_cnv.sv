module artec_dma_cnv #(
	parameter INPUT_WIDTH  = 32 ,
	parameter OUTPUT_WIDTH = 256
) (
	input                                          clk        , // Clock
	input                                          rstn       , // Asynchronous reset active low
	input artec_dma_pkg::settings_t                settings_i ,
	artec_axis_if.slave                            axis_i     ,
	artec_vr_if.master                             stream_o   ,
	// status
	output [$clog2(artec_dma_pkg::PKG_FB_NUM)-1:0] frame_num_o
);

import artec_dma_pkg::*;

localparam CNV_REL = OUTPUT_WIDTH/INPUT_WIDTH;

// ******************************************************* //
// Types 
// ******************************************************* //

typedef struct packed {
	logic [CNV_REL-1:0][INPUT_WIDTH-1:0] data;
	info_t                               info;
} slice_t;

// ******************************************************* //
// Declarations 
// ******************************************************* //

cnt_cl#(.MAX_VALUE(CNV_REL))::cnt_t cnv_cnt;

info_t info_fmt;

slice_t cnv_slice_w      ;
slice_t cnv_slice_r      ;
logic   cnv_slice_valid_r;

// ******************************************************* //
// In fmt 
// ******************************************************* //

assign info_fmt = axis_i.m.tuser;

// ******************************************************* //
// Input Width Converter 
// ******************************************************* //

assign cnv_cnt.incr = axis_i.m.tvalid && axis_i.s.tready;
assign cnv_cnt.next = cnv_cnt.cur + 1;
assign cnv_cnt.last = cnv_cnt.next == CNV_REL;
assign cnv_cnt.clr  = cnv_cnt.incr && (cnv_cnt.last || info_fmt.eof);

always_ff @(posedge clk `async_rstn(rstn)) begin : proc_cnv_cnt
    if(~rstn) begin
        cnv_cnt.cur <= 0;
    end else if (settings_i.common.clear) begin
    	cnv_cnt.cur <= 0;
    end else begin
        cnv_cnt.cur <= (cnv_cnt.clr ) ?            0 :
        			   (cnv_cnt.incr) ? cnv_cnt.next : cnv_cnt.cur;
    end
end

// -------------------------------------------------------- //

always_comb begin : proc_cnv_slice_w

	cnv_slice_w                   = cnv_slice_r;
	cnv_slice_w.info              = axis_i.m.tuser;
	cnv_slice_w.data[cnv_cnt.cur] = axis_i.m.tdata;

end

always_ff @(posedge clk `async_rstn(rstn)) begin : proc_cnv_slice_r
	if(~rstn) begin
		cnv_slice_r       <= 0;
		cnv_slice_valid_r <= 0;
	end else if (settings_i.common.clear) begin
    	cnv_slice_r       <= 0;
		cnv_slice_valid_r <= 0;
	end else begin
		cnv_slice_r       <= (axis_i.s.tready) ? cnv_slice_w : cnv_slice_r;
		cnv_slice_valid_r <= (axis_i.s.tready) ? cnv_cnt.clr : cnv_slice_valid_r;
	end
end

// ******************************************************* //
// Output  
// ******************************************************* //

assign stream_o.valid = cnv_slice_valid_r;
assign stream_o.data  = cnv_slice_r;

assign axis_i.s.tready = stream_o.ready;

assign frame_num_o = cnv_slice_r.info.fnum;

endmodule