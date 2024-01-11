module artec_dma_arb_rr #(
	parameter                                NUM_ELEMENTS  = artec_dma_pkg::PKG_CH_NUM           ,
	parameter                                WIDTH_ELEMENT = artec_dma_pkg::PKG_REQ_WIDTH        ,
	parameter                                LAST_CNT_TRIG = artec_dma_pkg::PKG_ARB_LAST_CNT_TRIG,
	parameter logic [NUM_ELEMENTS-1:0][31:0] PRIORITY_TRIG = artec_dma_pkg::PKG_ARB_PRIORITY_TRIG
) (
	input                                                clk          , // Clock
	input                                                rstn         , // Asynchronous reset active low
	input                                                clear        ,
	input  [        NUM_ELEMENTS-1:0][WIDTH_ELEMENT-1:0] req_i        ,
	output [$clog2(NUM_ELEMENTS)-1:0]                    grant_o      ,
	output                                               grant_valid_o
);

import artec_dma_pkg::*;

// ******************************************************* //
// Declarations
// ******************************************************* //
localparam RR_GRANT_WIDTH     = $clog2(NUM_ELEMENTS);
localparam RR_REQ_WIDTH_ADOPT = NUM_ELEMENTS;

typedef enum {REQ_PASS,GRANT_PASS} rr_state_t;

rr_state_t state_w;
rr_state_t state_r;

cnt_cl#(.MAX_VALUE(32768))::cnt_t last_cnt [NUM_ELEMENTS-1:0];

logic [      NUM_ELEMENTS-1:0] rr_req_priority;
logic [      NUM_ELEMENTS-1:0] rr_req_common  ;
logic [RR_REQ_WIDTH_ADOPT-1:0] rr_req         ;
logic [    RR_GRANT_WIDTH-1:0] rr_grant       ;

logic [  NUM_ELEMENTS-1:0][WIDTH_ELEMENT-1:0] req_r  ;
logic [RR_GRANT_WIDTH-1:0]                    grant_r;

// ******************************************************* //
// State Machine 
// ******************************************************* //

assign req2grant = state_r == REQ_PASS && req_i!=0;
assign grant2req = state_r == GRANT_PASS;

always_comb begin : proc_state_w
	case (state_r)
		REQ_PASS   : state_w = (req2grant) ? GRANT_PASS : REQ_PASS; 
		GRANT_PASS : state_w = (grant2req) ? REQ_PASS   : GRANT_PASS;	
		default    : state_w = state_r;
	endcase
end

always_ff @(posedge clk `async_rstn(rstn)) begin : proc_state_r
	if(~rstn) begin
		state_r <= REQ_PASS;
	end else if (clear) begin
		state_r <= REQ_PASS;
	end else begin
		state_r <= state_w;
	end
end

always_ff @(posedge clk or negedge rstn) begin : proc_req_r
	if(~rstn) begin
		req_r <= 0;
	end else if (clear) begin
		req_r <= 0;
	end else begin
		req_r <= (req2grant) ? req_i : 0;
	end
end

// ******************************************************* //
// Last Cnt 
// ******************************************************* //

generate
	for (genvar i = 0; i < NUM_ELEMENTS; i++) begin
	
		assign last_cnt[i].incr = req_r[i]!=0 && grant_o!=i && grant_valid_o;
		assign last_cnt[i].next = last_cnt[i].cur + 1;
		assign last_cnt[i].last = 0;
		assign last_cnt[i].clr  = req_r[i]!=0 && grant_o==i && grant_valid_o;

		always_ff @(posedge clk `async_rstn(rstn)) begin : proc_last_cnt
		    if(~rstn) begin
		        last_cnt[i].cur <= 0;
		    end else if (clear) begin
		        last_cnt[i].cur <= 0;
		    end else begin
		        last_cnt[i].cur <= (last_cnt[i].clr ) ? 0 :
		        				   (last_cnt[i].incr) ? last_cnt[i].next : last_cnt[i].cur;
		    end
		end

	end
endgenerate

// ******************************************************* //
// Priority And Common Requests
// ******************************************************* //

for (genvar i = 0; i < NUM_ELEMENTS; i++) begin
	
	assign rr_req_common[i] = state_r == REQ_PASS ? req_i[i] != 0 : 0;

	assign rr_req_priority[i] = state_r == REQ_PASS ? (req_i[i] >= PRIORITY_TRIG[i] || req_i[i] != 0 && last_cnt[i].cur >= LAST_CNT_TRIG) : 0;

end

// ******************************************************* //
// RoundRobin 
// ******************************************************* //

assign rr_req = (|rr_req_priority) ? rr_req_priority : rr_req_common;

artec_common_rr #(.WIDTH(RR_REQ_WIDTH_ADOPT)) i_artec_common_rr (.clk(clk), .rstn(rstn), .clear(clear), .req_i(rr_req), .grant_o(rr_grant));

// ******************************************************* //
// Output grant 
// ******************************************************* //

always_ff @(posedge clk or negedge rstn) begin : proc_grant_r
	if(~rstn) begin
		grant_r <= 0;
	end else if (clear) begin
		grant_r <= 0;
	end else begin
		grant_r <= rr_grant;
	end
end

assign grant_o       = grant_r;
assign grant_valid_o = state_r == GRANT_PASS;

endmodule