`timescale 1ns/1ps

module artec_dma_apb_top #(parameter APB_ID = 32'hA3D_0000)(
	input                            apb_clk   ,
	input                            apb_rstn  ,
	input                            clk       ,
	input                            rstn      ,
	artec_apb_if.slave               apb_i     ,
	output artec_dma_pkg::settings_t settings_o,
	input  artec_dma_pkg::status_t   status_i
);

artec_apb_if apb_int();

apbA_to_apbB apb_AB (
	.apb_clk_A_i    (apb_clk          ),
	.apb_resetn_A_i (apb_rstn         ),
	.apb_paddr_A_i  (apb_i.m.paddr    ),
	.apb_psel_A_i   (apb_i.m.psel     ),
	.apb_penable_A_i(apb_i.m.penable  ),
	.apb_pwrite_A_i (apb_i.m.pwrite   ),
	.apb_strb_A_i   (apb_i.m.strb     ),
	.apb_pwdata_A_i (apb_i.m.pwdata   ),
	.apb_pready_A_o (apb_i.s.pready   ),
	.apb_prdata_A_o (apb_i.s.prdata   ),
	.apb_clk_B_i    (clk              ),
	.apb_resetn_B_i (rstn             ),
	.apb_paddr_B_o  (apb_int.m.paddr  ),
	.apb_psel_B_o   (apb_int.m.psel   ),
	.apb_penable_B_o(apb_int.m.penable),
	.apb_pwrite_B_o (apb_int.m.pwrite ),
	.apb_strb_B_o   (apb_int.m.strb   ),
	.apb_pwdata_B_o (apb_int.m.pwdata ),
	.apb_pready_B_i (apb_int.s.pready ),
	.apb_prdata_B_i (apb_int.s.prdata )
);

artec_dma_apb #(.APB_ID(APB_ID)) apb_slave (
	.clk       (clk       ),
	.rstn      (rstn      ),
	.apb       (apb_int   ),
	.settings_o(settings_o),
	.status_i  (status_i  )
);

endmodule
