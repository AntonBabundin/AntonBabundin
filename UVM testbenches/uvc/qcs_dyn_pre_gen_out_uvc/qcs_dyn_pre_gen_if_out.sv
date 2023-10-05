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

interface qcs_dyn_pre_gen_if_out #(
    parameter int   DW
);
    //--System wire's
    wire               clk;
    wire               reset_n;
    //--Input signals
    wire               nhtp_re;
    //--Output data
    wire [DW-1:0]      data_i_0;
    wire [DW-1:0]      data_q_0;
    wire [DW-1:0]      data_i_1;
    wire [DW-1:0]      data_q_1;

    modport mp_monitor(
        input  clk,
        input  reset_n,
        input  nhtp_re,
        input  data_i_0,
        input  data_q_0,
        input  data_i_1,
        input  data_q_1
    );

endinterface