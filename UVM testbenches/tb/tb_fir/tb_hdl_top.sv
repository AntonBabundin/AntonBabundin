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
module tb_hdl_top;
    //---- uvm components
    import    uvm_pkg::*;
    `include  "uvm_macros.svh"
    //---- test environment components
    import   tb_globals_pkg::*;

    //---- variables
    wire    clk;
    wire    rst_n;
    wire    clk_rx;

    //---- interfaces
    gpio_fir_signals                              gpio_connect;
    qcs_clk_gen_if                                clk_gen_if();
    qcs_rst_gen_if                                rst_gen_if();
    qcs_clk_gen_if                                clk_rx_gen_if();
    qcs_fir_if      #(FIR_DW)                     fir_in_if();
    qcs_fir_if      #(FIR_DW)                     fir_out_if();
    qcs_gpio_if     #(FIR_GPIO_WIDTH)             fir_gpio_if();

    //---- BFM's
    qcs_fir_drv_bfm     #(FIR_DW)                 fir_in_drv_bfm        (fir_in_if.mp_initiator);
    qcs_fir_mon_bfm     #(FIR_DW)                 fir_in_mon_bfm        (fir_in_if.mp_monitor);
    qcs_fir_mon_bfm     #(FIR_DW)                 fir_out_mon_bfm       (fir_out_if.mp_monitor);
    qcs_gpio_drv_bfm    #(FIR_GPIO_WIDTH)         gpio_fir_drv_bfm      (fir_gpio_if.mp_initiator);
    qcs_gpio_mon_bfm    #(FIR_GPIO_WIDTH)         gpio_fir_mon_bfm      (fir_gpio_if.mp_monitor);

    //---- database
    initial begin
        uvm_config_db #(virtual qcs_rst_gen_if)::
            set(null, "*m_env.m_rst_gen*",   "vif", rst_gen_if);
        uvm_config_db #(virtual qcs_clk_gen_if)::
            set(null, "*m_env.m_clk_gen0*",  "vif", clk_gen_if);
        uvm_config_db #(virtual qcs_clk_gen_if)::
            set(null, "*m_env.m_clk_rx_gen0*",  "vif", clk_rx_gen_if);
        //Active agent fir0_in
        uvm_config_db #(virtual qcs_fir_drv_bfm #(FIR_DW))::
            set(null, "*m_env.m_fir_in_ag.m_drv*", "bfm", fir_in_drv_bfm);
        uvm_config_db #(virtual qcs_fir_mon_bfm #(FIR_DW))::
            set(null, "*m_env.m_fir_in_ag.m_mon*", "bfm", fir_in_mon_bfm);
        //Passive agent fir0_out_pri
        uvm_config_db #(virtual qcs_fir_mon_bfm #(FIR_DW))::
            set(null, "*m_env.m_fir_out_ag.m_mon*", "bfm", fir_out_mon_bfm);
        //GPIO
        uvm_config_db #(virtual qcs_gpio_drv_bfm #(FIR_GPIO_WIDTH))::
            set(null, "*m_env.m_gpio_ag.m_drv*", "bfm", gpio_fir_drv_bfm);
        uvm_config_db #(virtual qcs_gpio_mon_bfm #(FIR_GPIO_WIDTH))::
            set(null, "*m_env.m_gpio_ag.m_mon*", "bfm", gpio_fir_mon_bfm);
    end
    //---- commutation
    assign clk                       = clk_gen_if.clk;
    assign rst_n                     = rst_gen_if.rst_n;
    assign clk_rx                    = clk_rx_gen_if.clk;

    assign fir_in_if.clk             = clk;
    assign fir_in_if.reset_n         = rst_n;

    assign fir_out_if.clk            = clk_rx;
    assign fir_out_if.reset_n        = rst_n;

    assign gpio_connect              = fir_gpio_if.gpio;

naci_fir #(
    .DW                  (FIR_DW),
    .CW                  (FIR_CW)
)
    dut(
    .rx_dout_vld         (fir_out_if.data_vld),
    .rx_dout_i           (fir_out_if.data_i),
    .rx_dout_q           (fir_out_if.data_q),

    .rx_din_vld          (fir_in_if.data_vld),
    .rx_din_i            (fir_in_if.data_i),
    .rx_din_q            (fir_in_if.data_q),

    .rx_coeff_0          (FIR_COEFF_0),
    .rx_coeff_1          (FIR_COEFF_1),
    .rx_coeff_2          (FIR_COEFF_2),
    .rx_coeff_3          (FIR_COEFF_3),

    .rx_scale            (gpio_connect.rx_scale),
    .rx_en               (gpio_connect.rx_en),
    .rx_done             (gpio_connect.rx_done),
    .com_clr             (gpio_connect.com_clr),

    .clk_in              (clk),
    .clk_out             (clk_rx),
    .reset_n             (rst_n)
);

endmodule
