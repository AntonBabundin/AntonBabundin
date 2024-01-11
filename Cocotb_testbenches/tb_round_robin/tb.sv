`timescale 1ns / 1ps

module tb;

logic clk; logic rstn;

localparam int NUM_ELEMENTS  = artec_dma_pkg::PKG_CH_NUM;
localparam int WIDTH_ELEMENT  = artec_dma_pkg::PKG_REQ_WIDTH;

logic                                       clear;
logic [NUM_ELEMENTS-1:0][WIDTH_ELEMENT-1:0] req_i;
logic [$clog2(NUM_ELEMENTS)-1:0]            grant_o;
logic                                       grant_valid_o;
// ******************************************************* //
// Clocks
// ******************************************************* //
initial begin
  clk = 1'b0;
  forever begin
    #( 2.5 );
    clk = ~clk;
  end
end
// ******************************************************* //
// DUT 
// ******************************************************* //
artec_dma_arb_rr i_dut (
  .clk           (clk          ),
  .rstn          (rstn         ),
  .clear         (clear        ),
  .req_i         (req_i        ),
  .grant_o       (grant_o      ),
  .grant_valid_o (grant_valid_o)
);

endmodule
