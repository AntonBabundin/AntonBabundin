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
interface qcs_dyn_pre_gen_mon_bfm_out #(
  parameter int   DW
)(
  qcs_dyn_pre_gen_if_out.mp_monitor port
);
//---- parameters
    localparam time  T_IN_SKEW   = 1;
    localparam time  T_OUT_SKEW  = 1;

    import  qcs_dyn_pre_gen_pkg_out::*;
//---- variables
    bfm_trn_t          mon_trn;
    bit                fl_pkt_collect_en;
    event              e_pkt_rdy;
//----data
    logic              nhtp_re;
    logic [DW-1:0]     data_i_0;
    logic [DW-1:0]     data_q_0;
    logic [DW-1:0]     data_i_1;
    logic [DW-1:0]     data_q_1;
//---- clocking block
    clocking cb @(posedge port.clk);
        default input #T_IN_SKEW output #T_OUT_SKEW;
        input nhtp_re;
        input data_i_0;
        input data_q_0;
        input data_i_1;
        input data_q_1;
    endclocking
//---- logic
    assign nhtp_re   =  port.nhtp_re;
    assign data_i_0  =  port.data_i_0;
    assign data_q_0  =  port.data_q_0;
    assign data_i_1  =  port.data_i_1;
    assign data_q_1  =  port.data_q_1;

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
        mon_trn.data_i_0  = cb.data_i_0;
        mon_trn.data_q_0  = cb.data_q_0;
        mon_trn.data_i_1  = cb.data_i_1;
        mon_trn.data_q_1  = cb.data_q_1;
    endtask

    function bfm_trn_t get_pkt();
        return mon_trn;
    endfunction

endinterface
