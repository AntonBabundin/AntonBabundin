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
// todo -   smarten up formating
//          insert empty lines between blocks
//          delete extra empty lines
//          allign expressions and comments
//          check tabs, somewhere there are not four spaces
//          etc.
interface qcs_fir_mon_bfm #(
  parameter int   DW = -1
)(
  qcs_fir_if.mp_monitor port
);
//---- parameters
    localparam time  T_IN_SKEW   = 1;
    localparam time  T_OUT_SKEW  = 1;

    import  qcs_fir_pkg::bfm_trn_t;
//---- variables
    bfm_trn_t       fir_trn;
//----data
    wire            reset_n;
    wire            data_vld;
    wire  [DW-1:0]  data_i;
    wire  [DW-1:0]  data_q;
    bit             fl_pkt_collect_en;
    event           e_pkt_rdy;

//---- clocking blocks
    clocking cb @(posedge port.clk);
        default input #T_IN_SKEW output #T_OUT_SKEW;
        input data_vld;
        input data_i;
        input data_q;
    endclocking
//---- logic
    assign data_vld  =  port.data_vld;
    assign data_i    =  port.data_i;
    assign data_q    =  port.data_q;
    assign reset_n   =  port.reset_n;

    always_ff @(posedge port.clk) begin : proc_collecting_out
        if(fl_pkt_collect_en && reset_n && cb.data_vld) begin
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
        if (cb.data_vld) begin
            fir_trn.data_re  = cb.data_i;
            fir_trn.data_im  = cb.data_q;
        end
    endtask

    function bfm_trn_t get_pkt();
        return fir_trn;
    endfunction

endinterface
