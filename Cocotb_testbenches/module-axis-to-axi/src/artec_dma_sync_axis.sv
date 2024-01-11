module artec_header_sync #(
	parameter CH_NUM = 5,
	parameter FB_NUM = 8
) (
	input                           clk                , // Clock
	input                           rstn               , // Asynchronous reset active low
	input artec_dma_pkg::settings_t settings_i         ,
	artec_axis_if.monitor           axis_i [CH_NUM-1:0],
	artec_vr_if.master              sync_o
);


info_t [CH_NUM-1:0] tuser_fmt;
logic  [CH_NUM-1:0] eof_valid;

logic [CH_NUM-1:0][FB_NUM-1:0] clear_sync_lost;
logic [CH_NUM-1:0][FB_NUM-1:0] clear_push_away;
logic [CH_NUM-1:0][FB_NUM-1:0] clear_sync_away;
logic [CH_NUM-1:0][FB_NUM-1:0] clear_disable;

logic [CH_NUM-1:0][FB_NUM-1:0] tbl_set;
logic [CH_NUM-1:0][FB_NUM-1:0] tbl_clr;
logic [CH_NUM-1:0][FB_NUM-1:0] tbl;

logic [        CH_NUM-1:0][FB_NUM-1:0] sync_vec_tmp;
logic [        FB_NUM-1:0]             sync_vec    ;
logic [$clog2(FB_NUM)-1:0]             sync_fnum   ;
logic                                  sync        ;

// ******************************************************* //
// Table of Channels and Frame Numbers 
// ******************************************************* //

for (genvar i = 0; i < CH_NUM; i++) begin

	assign tuser_fmt[i] = axis_i[i].m.tuser;

	assign eof_valid[i] = axis_i[i].m.tvalid && axis_i[i].s.tready && tuser_fmt[i].eof;

	for (genvar i = 0; i < FB_NUM; i++) begin

		assign clear_sync_lost[i][j]  = tuser_fmt[i].fnum!=j && (tbl[i][tuser_fmt[i].fnum+1]==1 || tbl[i][tuser_fmt[i].fnum-1]==0);
		
		assign clear_push_away[i][j]  = tuser_fmt[i].fnum!=j || tuser_fmt[i].fnum!=(j-1) || tuser_fmt[i].fnum!=(j-2);

		assign clear_sync_away[i][j]  = sync_fnum==j || sync_fnum==(j-1) || sync_fnum==(j-2);

		assign clear_disable[i][j]    = settings_i.channel[i].enable==0;

		assign tbl_set[i][j] = eof_valid[i] && tuser_fmt[i].fnum==j;

		assign tbl_clr[i][j] = eof_valid[i] && (clear_sync_lost[i][j] || clear_push_away[i][j]) || sync && clear_sync_away[i][j] || clear_disable[i][j];

		always_ff @(posedge clk `async_rstn(rstn)) begin : proc_tbl
		    if(~rstn) begin
		        tbl[i][j] <= 0;
		    end else begin
		        tbl[i][j] <= (tbl_clr[i][j]) ? 0 :
		        			 (tbl_set[i][j]) ? 1 : tbl[i][j];
		    end
		end

	end
end

// ******************************************************* //
// Sync Search 
// ******************************************************* //

always_comb begin : proc_sync_vec

	sync_vec_tmp = 0;
	sync_vec = {FB_NUM{1'b1}};

	for (int i = 0; i < CH_NUM; i++) begin
		sync_vec_tmp[i]   = (settings_i.channel[i].enable) ? tbl[i] : {FB_NUM{1'b1}};
		sync_vec          = sync_vec & sync_vec_tmp[i];
	end
end


assign sync = |sync_vec;

always_comb begin : proc_check

	for (int i = 0; i < CH_NUM; i++) begin
		if (sync_vec[i]) begin
			sync_fnum = i;
			break; 
		end
	end
end

// ******************************************************* //
// Output 
// ******************************************************* //

assign sync_o.valid = sync;
assign sync_o.data  = sync_fnum;

endmodule