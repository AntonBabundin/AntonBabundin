//------------------------------------------------------------------------------
//
//  *** *** ***
// *   *   *   *
// *   *    *     Quantenna
// *   *     *    Connectivity
// *   *      *   Solutions
// * * *   *   *
//  *** *** ***
//     *
//------------------------------------------------------------------------------

interface qcs_fir_if #(
    parameter int   DW
);
    wire           clk;
    wire           clk_rx;
    wire           reset_n;
    //--Input data
    wire           data_vld;
    wire [DW-1:0]  data_i;
    wire [DW-1:0]  data_q;

    modport mp_initiator (
        input   clk,
        input   reset_n,
        output  data_vld,
        output  data_i,
        output  data_q
    );

    modport mp_monitor (
        input  clk,
        input  reset_n,
        input  data_vld,
        input  data_i,
        input  data_q
    );

endinterface