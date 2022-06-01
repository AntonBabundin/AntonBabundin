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
interface qcs_dyn_pre_gen_mon_bfm #(
    parameter int   ADDR_DW,
    parameter int   BW_W,
    parameter int   GAMMA_W,
    parameter int   SUBBAND_W
)(
  qcs_dyn_pre_gen_if.mp_monitor port
);
//---- parameters
    localparam time  T_IN_SKEW   = 1;
    localparam time  T_OUT_SKEW  = 1;

    import  qcs_dyn_pre_gen_pkg::bfm_trn_t;
//---- variables
    bfm_trn_t            mon_trn;
//----data
    logic [ADDR_DW-1:0]   nhtp_raddr;
    logic                 nhtp_re;
    logic [BW_W-1:0]      pkt_bw;
    logic [BW_W-1:0]      sys_bw;
    logic [SUBBAND_W-1:0] subband_punct;
    logic [GAMMA_W-1:0]   gamma_rotation;
    logic [3:0]           n_tx;
    logic                 nhtp_4ch;
    bit                   fl_pkt_collect_en;
    event                 e_pkt_rdy;
//---- clocking block
    clocking cb @(posedge port.clk);
        default input #T_IN_SKEW output #T_OUT_SKEW;
        input   nhtp_re;
        input   nhtp_raddr;
        input   pkt_bw;
        input   sys_bw;
        input   subband_punct;
        input   gamma_rotation;
        input   n_tx;
        input   nhtp_4ch;
    endclocking
//---- logic
    assign nhtp_raddr                     = port.nhtp_raddr;
    assign nhtp_re                        = port.nhtp_re;
    assign pkt_bw                         = port.txconfig_bw;
    assign sys_bw                         = port.sys_bw_mode;
    assign subband_punct                  = port.config_mu_subband_present;
    assign gamma_rotation                 = port.config_gamma_rotation;
    assign n_tx                           = port.n_tx;
    assign nhtp_4ch                       = port.nhtp_4ch;

    always_ff @(posedge port.clk) begin : proc_collecting_out
        if(fl_pkt_collect_en && port.reset_n && cb.nhtp_re) begin
            save_data_item();
            -> e_pkt_rdy;
        end
    end: proc_collecting_out
//---- tasks and functions
    task start_mon();
        fl_pkt_collect_en = 1'b1;
    endtask

    task stop_mon();
        fl_pkt_collect_en = 1'b0;
    endtask

    task save_data_item();
        mon_trn.addr              = cb.nhtp_raddr;
        mon_trn.pkt_bw            = cb.pkt_bw;
        mon_trn.sys_bw            = cb.sys_bw;
        mon_trn.mu_subband_punct  = cb.subband_punct;
        mon_trn.gamma_rotation    = cb.gamma_rotation;
        mon_trn.num_of_tx_chains  = cb.n_tx;
        mon_trn.num_4ch           = cb.nhtp_4ch;
    endtask

    function bfm_trn_t get_pkt();
        return mon_trn;
    endfunction

endinterface
