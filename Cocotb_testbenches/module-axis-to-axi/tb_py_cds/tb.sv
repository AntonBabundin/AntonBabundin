`timescale 1ns / 1ps

module tb;

logic clk; logic rstn;
logic apb_clk; logic apb_rstn;


artec_apb_if apb();

artec_axis_if #(.DW(64),.UW(5)) axis_bus[5:0]();

artec_axi_if #(.DW(128)) axi();


artec_vr_if #(.DW(3))   read_req(); // Slave
artec_vr_if #(.DW(128)) read_ack(); // Master


// ******************************************************* //
// Hack to work with cocotbext-axi                         //
// ******************************************************* //

`COCOTB_AXI_DECLARATION(dma_tb_axi_,32,128,4)
`COCOTB_AXI_CONNECTION_SLAVE(dma_tb_axi_,axi)

`COCOTB_AXIS_DECLARATION(dma_tb_axis0_, 64, 5)
`COCOTB_AXIS_CONNECTION_MASTER(dma_tb_axis0_,axis_bus[0])

`COCOTB_AXIS_DECLARATION(dma_tb_axis1_, 64, 5)
`COCOTB_AXIS_CONNECTION_MASTER(dma_tb_axis1_,axis_bus[1])

`COCOTB_AXIS_DECLARATION(dma_tb_axis2_, 64, 5)
`COCOTB_AXIS_CONNECTION_MASTER(dma_tb_axis2_,axis_bus[2])

`COCOTB_AXIS_DECLARATION(dma_tb_axis3_, 64, 5)
`COCOTB_AXIS_CONNECTION_MASTER(dma_tb_axis3_,axis_bus[3])

`COCOTB_AXIS_DECLARATION(dma_tb_axis4_, 64, 5)
`COCOTB_AXIS_CONNECTION_MASTER(dma_tb_axis4_,axis_bus[4])

`COCOTB_AXIS_DECLARATION(dma_tb_axis5_, 64, 5)
`COCOTB_AXIS_CONNECTION_MASTER(dma_tb_axis5_,axis_bus[5])
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

initial begin
  apb_clk = 1'b0;
  forever begin
    #( 1 );
    apb_clk = ~apb_clk;
  end
end

// ******************************************************* //
// DUT 
// ******************************************************* //

artec_dma_top i_dut (
  .clk         (clk     ),
  .rstn        (rstn    ),
  .apb_clk     (apb_clk ),
  .apb_rstn    (apb_rstn),
  .apb_i       (apb     ),
  .axis_bus_i  (axis_bus),
  .axi_o       (axi     ),
  .header_req_o(read_req),
  .header_ack_i(read_ack)
);

endmodule
