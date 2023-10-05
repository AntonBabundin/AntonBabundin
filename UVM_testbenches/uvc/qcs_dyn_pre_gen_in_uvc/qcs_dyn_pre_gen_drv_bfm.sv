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
interface qcs_dyn_pre_gen_drv_bfm #(
    parameter int   ADDR_DW,
    parameter int   BW_W,
    parameter int   GAMMA_W,
    parameter int   SUBBAND_W
)
(
   qcs_dyn_pre_gen_if.mp_initiator  port
);
//---- parameters
    import  qcs_dyn_pre_gen_pkg::bfm_trn_t;
    localparam time  T_OUT_SKEW  = 1;
    localparam time  T_IN_SKEW   = 1;
    bit              fl_en;
    int              count;
//---- variables
    bfm_trn_t             drv_req;
//----data
    logic                 reset_n;
    logic [ADDR_DW-1:0]   nhtp_raddr;
    logic                 nhtp_re;
    logic [BW_W-1:0]      pkt_bw;
    logic [BW_W-1:0]      sys_bw;
    logic [SUBBAND_W-1:0] subband_punct;
    logic [GAMMA_W-1:0]   gamma_rotation;
    logic [3:0]           n_tx;
    logic                 nhtp_4ch;
    bit                   counter_en;
//---- clocking blocks
    clocking cb @(posedge port.clk);
        default output #T_OUT_SKEW;
        output   nhtp_re;
        output   nhtp_raddr;
        output   pkt_bw;
        output   sys_bw;
        output   subband_punct;
        output   gamma_rotation;
        output   n_tx;
        output   nhtp_4ch;
    endclocking
//---- logic
    assign port.nhtp_raddr                = nhtp_raddr;
    assign port.nhtp_re                   = nhtp_re;
    assign port.txconfig_bw               = pkt_bw;
    assign port.sys_bw_mode               = sys_bw;
    assign port.config_mu_subband_present = subband_punct;
    assign port.config_gamma_rotation     = gamma_rotation;
    assign port.n_tx                      = n_tx;
    assign port.nhtp_4ch                  = nhtp_4ch;

    always @(negedge port.reset_n) begin
        set_idle_if();
    end
//---- tasks and functions
    task set_dflt_if();
        nhtp_re       <= 'x;
    endtask

    task set_idle_if();
        cb.nhtp_re    <= '0;
        cb.nhtp_raddr <= 'x;
    endtask

    task set_x_if();
        cb.nhtp_raddr <= 'x;
    endtask

    initial begin
        set_dflt_if();
    end

    // always_ff @(posedge port.clk) begin : counter_of_trn
    //     if(port.reset_n && counter_en) begin
    //         count++;
    //     end
    //     else if (count == 10336) begin
    //         cb.nhtp_re        <= '0;
    //     end
    // end: counter_of_trn

    task drive(bfm_trn_t rqst);
        drv_req = rqst;            
        if (port.reset_n) begin
            @(cb);
            count++;
            counter_en        <= '1;
            cb.pkt_bw         <= drv_req.pkt_bw;
            cb.sys_bw         <= drv_req.sys_bw;
            cb.subband_punct  <= drv_req.mu_subband_punct;
            cb.gamma_rotation <= drv_req.gamma_rotation;
            cb.n_tx           <= drv_req.num_of_tx_chains;
            cb.nhtp_4ch       <= drv_req.num_4ch;
            cb.nhtp_re        <= '1;
            cb.nhtp_raddr     <= drv_req.addr;
            if(count == 10336) begin
                @(cb);
                cb.nhtp_re        <= '0;
            end

        end
    endtask

endinterface
