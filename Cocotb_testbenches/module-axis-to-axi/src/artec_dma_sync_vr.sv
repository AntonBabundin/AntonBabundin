module artec_dma_sync #(
	parameter CH_NUM = 5,
	parameter FB_NUM = 8
) (
	input                           clk          , // Clock
	input                           rstn         , // Asynchronous reset active low
	input artec_dma_pkg::settings_t settings_i   ,
	artec_vr_if.slave               stream_task_i,
	artec_vr_if.slave               stream_data_i,
	artec_vr_if.master              stream_task_o,
	artec_vr_if.master              stream_data_o
);

import artec_dma_pkg::*;

// ******************************************************* //
// Typedefs 
// ******************************************************* //

typedef struct packed {
	logic [$clog2(FB_NUM)-1:0] fnum;
	logic                      sync;
} sync_search_t;

// ******************************************************* //
// Functions 
// ******************************************************* //

function sync_search_t sync_search_f (input logic [CH_NUM-1:0][FB_NUM-1:0] tbl, input logic [CH_NUM-1:0] enable);

	logic [CH_NUM-1:0][FB_NUM-1:0] sync_vec_tmp;
	logic [FB_NUM-1:0]             sync_vec    ;
	
	begin

		sync_vec_tmp = 0;
		sync_vec = {FB_NUM{1'b1}};
	
		for (int i = 0; i < CH_NUM; i++) begin
			sync_vec_tmp[i]   = enable[i] ? tbl[i] : {FB_NUM{1'b1}};
			sync_vec          = sync_vec & sync_vec_tmp[i];
		end

		sync_search_f.sync = |sync_vec && |enable;

		for (int i = 0; i < FB_NUM; i++) begin
			if (sync_vec[i]) begin
				sync_search_f.fnum = i;
				break; 
			end
		end
	end

endfunction : sync_search_f

// ******************************************************* //
// Declarations 
// ******************************************************* //

arb_task_o_t in_fmt;

logic [FB_NUM-1:0]             clr_push_init;
logic [       1:0][FB_NUM-1:0] clr_push_tmp ;
logic [FB_NUM-1:0]             clr_push     ;

logic [FB_NUM-1:0]             clr_sync_init;
logic [       1:0][FB_NUM-1:0] clr_sync_tmp ;
logic [FB_NUM-1:0]             clr_sync     ;

logic [$clog2(FB_NUM)-1:0]             clr_wrong_next;
logic                                  clr_wrong_flag;
logic [        FB_NUM-1:0]             clr_wrong_init;
logic [               1:0][FB_NUM-1:0] clr_wrong_tmp ;
logic [        FB_NUM-1:0]             clr_wrong     ;

logic [CH_NUM-1:0] eof_valid;

logic [CH_NUM-1:0][FB_NUM-1:0] clear_fnum_wrong;
logic [CH_NUM-1:0][FB_NUM-1:0] clear_push_away;
logic [CH_NUM-1:0][FB_NUM-1:0] clear_sync_away;
logic [CH_NUM-1:0][FB_NUM-1:0] clear_disable;

logic [CH_NUM-1:0][FB_NUM-1:0] tbl_set;
logic [CH_NUM-1:0][FB_NUM-1:0] tbl_clr;
logic [CH_NUM-1:0][FB_NUM-1:0] tbl;

logic [CH_NUM-1:0][$clog2(FB_NUM)-1:0] last_fnum;

sync_search_t sync_search;

arb_task_o_t  task_pipe_r      ;
logic         task_pipe_valid_r;

sync_task_o_t task_o_fmt       ;

// ******************************************************* //
// Table of Channels and Frame Numbers 
// ******************************************************* //

assign in_fmt = stream_task_i.data;

// When EOF arrived we have to keep only in_fnum, in_fnum-1, in_fnum-2

always_comb begin : proc_clr_push
	clr_push_init  = 1<<in_fmt.taskf.info.fnum;
	clr_push_tmp   = {clr_push_init,clr_push_init} | ({clr_push_init,clr_push_init}>>1) | ({clr_push_init,clr_push_init}>>2);
	clr_push       = ~clr_push_tmp;
end

// When SYNC occurs we have to clear only sync_fnum, sync_fnum-1, sync_fnum-2

always_comb begin : proc_clr_sync
	clr_sync_init  = 1<<sync_search.fnum;
	clr_sync_tmp   = {clr_sync_init,clr_sync_init} | ({clr_sync_init,clr_sync_init}>>1) | ({clr_sync_init,clr_sync_init}>>2);
	clr_sync       = clr_sync_tmp;
end

// When incoming fnum is different from last fnum more then +1 we have to clear all except in_fnum

always_comb begin : proc_clr_wrong
	clr_wrong_next = last_fnum[in_fmt.idx] + 1;
	clr_wrong_flag = in_fmt.taskf.info.fnum != clr_wrong_next;
	clr_wrong_init = clr_wrong_flag<<in_fmt.taskf.info.fnum;
	clr_wrong      = (clr_wrong_flag) ? ~clr_wrong_init : 0;
end

// Table

for (genvar i = 0; i < CH_NUM; i++) begin

	assign eof_valid[i]  = stream_task_i.valid && stream_task_i.ready && in_fmt.taskf.info.eof && in_fmt.idx==i; 

	for (genvar j = 0; j < FB_NUM; j++) begin

		assign clear_fnum_wrong[i][j] = eof_valid[i] && clr_wrong[j];
		assign clear_push_away[i][j]  = eof_valid[i] && clr_push[j];
		assign clear_sync_away[i][j]  = stream_task_o.valid && stream_task_o.ready && sync_search.sync && clr_sync[j];
		assign clear_disable[i][j]    = settings_i.channel[i].enable==0;

		assign tbl_set[i][j] = eof_valid[i] && in_fmt.taskf.info.fnum==j;

		assign tbl_clr[i][j] = clear_push_away[i][j] | clear_sync_away[i][j] | clear_fnum_wrong[i][j] | clear_disable[i][j];

		always_ff @(posedge clk `async_rstn(rstn)) begin : proc_tbl
		    if(~rstn) begin
		        tbl[i][j] <= 0;
		    end else if (settings_i.common.clear) begin
		    	tbl[i][j] <= 0;
		    end else begin
		        tbl[i][j] <= tbl[i][j] & ~tbl_clr[i][j] | tbl_set[i][j];
		    end
		end
	end
end

// Last FNUM

for (genvar i = 0; i < CH_NUM; i++) begin

	always_ff @(posedge clk `async_rstn(rstn)) begin : proc_last_fnum
	    if(~rstn) begin
	        last_fnum[i] <= 0;
	    end else if (settings_i.common.clear) begin
	    	last_fnum[i] <= 0;
	    end else begin
	        last_fnum[i] <= (eof_valid[i]) ? in_fmt.taskf.info.fnum : last_fnum[i];
	    end
	end
	
end

// ******************************************************* //
// Sync Search 
// ******************************************************* //

logic [CH_NUM-1:0] enable_vec;

for (genvar i = 0; i < CH_NUM; i++) begin
	
	assign enable_vec[i] = settings_i.channel[i].enable;

end

assign sync_search = sync_search_f(tbl,enable_vec);

// ******************************************************* //
// Task pipe 
// ******************************************************* //

always_ff @(posedge clk `async_rstn(rstn)) begin : proc_task_pipe_r
	if(~rstn) begin
		task_pipe_r       <= 0;
		task_pipe_valid_r <= 0;
	end else if (settings_i.common.clear) begin
		task_pipe_r       <= 0;
		task_pipe_valid_r <= 0;
	end else begin
		task_pipe_r       <= (stream_task_o.ready) ? stream_task_i.data  : task_pipe_r;
		task_pipe_valid_r <= (stream_task_o.ready) ? stream_task_i.valid : task_pipe_valid_r;
	end
end

// ******************************************************* //
// Output Format 
// ******************************************************* //

assign task_o_fmt.idx   = task_pipe_r.idx;
assign task_o_fmt.taskf = task_pipe_r.taskf;
assign task_o_fmt.sync  = sync_search.sync && sync_search.fnum==task_pipe_r.taskf.info.fnum;

// ******************************************************* //
// Output 
// ******************************************************* //

assign stream_task_o.valid = task_pipe_valid_r;
assign stream_task_o.data  = task_o_fmt;

assign stream_data_o.valid = stream_data_i.valid;
assign stream_data_o.data  = stream_data_i.data;

assign stream_task_i.ready = stream_task_o.ready;
assign stream_data_i.ready = stream_data_o.ready;

endmodule