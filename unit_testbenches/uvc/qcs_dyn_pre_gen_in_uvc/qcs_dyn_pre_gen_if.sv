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

interface qcs_dyn_pre_gen_if #(
    parameter int  ADDR_W,
    parameter int  BW_W,
    parameter int  GAMMA_W,
    parameter int  SUBBAND_W
);
    //--System wire's
    wire                 clk;
    wire                 reset_n;
    //--Input signals
    wire                 nhtp_ltf;
    wire [ADDR_W-1:0]    nhtp_raddr;
    wire                 nhtp_re;
    wire [BW_W-1:0]      txconfig_bw;
    wire [BW_W-1:0]      sys_bw_mode;
    wire [SUBBAND_W-1:0] config_mu_subband_present;
    wire [GAMMA_W-1:0]   config_gamma_rotation;
    wire [3:0]           n_tx;
    wire                 nhtp_4ch;

    modport mp_initiator (
        input   clk,
        input   reset_n,
        output  nhtp_raddr,
        output  nhtp_re,
        output  txconfig_bw,
        output  sys_bw_mode,
        output  config_mu_subband_present,
        output  config_gamma_rotation,
        output  n_tx,
        output  nhtp_4ch
    );

    modport mp_monitor(
        input  clk,
        input  reset_n,
        input  nhtp_raddr,
        input  nhtp_re,
        input  txconfig_bw,
        input  sys_bw_mode,
        input  config_mu_subband_present,
        input  config_gamma_rotation,
        input  n_tx,
        input  nhtp_4ch
    );

endinterface