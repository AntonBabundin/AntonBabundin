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
//          allign expressions
//          check tabs, somewhere there are not four spaces
//          etc.
interface qcs_fir_drv_bfm #(
    parameter int   DW = -1
)
(
   qcs_fir_if.mp_initiator  port
);
//---- parameters
    import  qcs_fir_pkg::bfm_trn_t;
    localparam time  T_OUT_SKEW  = 1;
    localparam time  T_IN_SKEW   = 1;
//---- FIR 'valid' & data in
    bfm_trn_t       drv_req;
    logic           reset_n;
    logic           data_vld;
    logic [DW-1:0]  data_i;
    logic [DW-1:0]  data_q;
//---- clocking blocks
    clocking cb @(posedge port.clk);
        default input #T_IN_SKEW output #T_OUT_SKEW;
        inout data_vld;
        output  data_i;
        output  data_q;
    endclocking
//---- logic
    assign port.data_vld = data_vld;
    assign port.data_i   = data_i;
    assign port.data_q   = data_q;

    always @(negedge port.reset_n) begin
        set_idle_if();
    end
//---- tasks and functions
    task set_dflt_if();
        data_vld     <= 'x;
        cb.data_i    <= 'z;
        cb.data_q    <= 'z;
    endtask

    task set_idle_if();
        cb.data_vld  <= '0;
        cb.data_i    <= 'x;
        cb.data_q    <= 'x;
    endtask

    task set_x_if();
        cb.data_i    <= 'x;
        cb.data_q    <= 'x;
    endtask

    initial begin
        set_dflt_if();
    end

    task drive(bfm_trn_t rqst);
        drv_req = rqst;
        if (port.reset_n) begin
            cb.data_vld <= '1;
            cb.data_i <= drv_req.data_re;
            cb.data_q <= drv_req.data_im;
            @(cb);
            cb.data_vld <= '0;
            set_x_if();

        end
    endtask

endinterface
