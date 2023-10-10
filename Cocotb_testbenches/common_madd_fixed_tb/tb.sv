`timescale  1 ps / 1 ps

module tb #(
    parameter U_WIDTH    = 16 ,
    // Parameter of the A signal
    parameter A_WIDTH    = 32,
    parameter A_POINT    = 16,
    parameter A_SIGNED   = 0 ,
    // Parameter of the B signal
    parameter B_WIDTH    = 32,
    parameter B_POINT    = 16,
    parameter B_SIGNED   = 0 ,
    // Parameter of the C signal
    parameter C_WIDTH    = 32,
    parameter C_POINT    = 16,
    parameter C_SIGNED   = 0 ,
    // Parameter of the Output signal
    parameter OUT_WIDTH  = 32,
    parameter OUT_POINT  = 16,
    parameter OUT_SIGNED = 0,
    // Parameter of the pipelining
    parameter ROUND      = 0,
    parameter XILINX     = 1

);
    logic clk;
    logic rstn;

    logic [A_WIDTH-1:0]   a_i;
    logic [B_WIDTH-1:0]   b_i;
    logic [C_WIDTH-1:0]   c_i;
    logic [U_WIDTH-1:0]   user_i;
    logic [U_WIDTH-1:0]   user_o;
    logic [OUT_WIDTH-1:0] out_o;

    artec_vr_if #(.DW(A_WIDTH + B_WIDTH +  C_WIDTH)) master();
    artec_vr_if #(.DW(OUT_WIDTH)) slave();

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

    assign slave.data = out_o;
    assign {a_i, b_i, c_i} = master.data;

// ******************************************************* //
// DUT 
// ******************************************************* //
    common_madd_fixed #(
        .U_WIDTH    (U_WIDTH),
        .A_WIDTH    (A_WIDTH),
        .A_POINT    (A_POINT),
        .A_SIGNED   (A_SIGNED),
        .B_WIDTH    (B_WIDTH),
        .B_POINT    (B_POINT),
        .B_SIGNED   (B_SIGNED),
        .C_WIDTH    (C_WIDTH),
        .C_POINT    (C_POINT),
        .C_SIGNED   (C_SIGNED),
        .OUT_WIDTH  (OUT_WIDTH),
        .OUT_POINT  (OUT_POINT),
        .OUT_SIGNED (OUT_SIGNED),
        .ROUND      (ROUND),
        .XILINX     (XILINX)
    )
    i_dut (
        .clk      (clk  ),
        .rstn     (rstn ),
        .a_i      (a_i), //master
        .b_i      (b_i),  //slave
        .c_i      (c_i),
        .user_i   (user_i),
        .valid_i  (master.master.valid),
        .ready_o  (master.master.ready),
        .out_o    (slave.slave.data),
        .user_o   (user_o),
        .valid_o  (slave.slave.valid),
        .ready_i  (slave.slave.ready)
    );
endmodule
