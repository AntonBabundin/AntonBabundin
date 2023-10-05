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
    logic   clk;
    wire    rst_n;


    //---- interfaces
    gpio_gen_signals                                                                  gpio_connect;
    qcs_clk_gen_if                                                                    clk_gen_if();
    qcs_rst_gen_if                                                                    rst_gen_if();
    qcs_dyn_pre_gen_if          #(GEN_ADDR_W, GEN_BW_W, GEN_GAMMA_W, GEN_SUBBAND_W)   gen_in_if();
    qcs_dyn_pre_gen_if_out      #(GEN_DW)                                             gen_out_if();
    qcs_gpio_if                #(GEN_GPIO_WIDTH)                                      gen_gpio_if();

    //---- BFM's
    qcs_dyn_pre_gen_drv_bfm     #(GEN_ADDR_W, GEN_BW_W, GEN_GAMMA_W, GEN_SUBBAND_W)   gen_in_drv_bfm        (gen_in_if.mp_initiator);
    qcs_dyn_pre_gen_mon_bfm     #(GEN_ADDR_W, GEN_BW_W, GEN_GAMMA_W, GEN_SUBBAND_W)   gen_in_mon_bfm        (gen_in_if.mp_monitor);
    qcs_dyn_pre_gen_mon_bfm_out #(GEN_DW)                                             gen_out_mon_bfm       (gen_out_if.mp_monitor);
    qcs_clk_gen_bfm                                                                   clk_gen_bfm           (clk_gen_if);
    qcs_rst_gen_bfm                                                                   rst_gen_bfm           (rst_gen_if);

    qcs_gpio_drv_bfm            #(GEN_GPIO_WIDTH)                                     gpio_gen_drv_bfm      (gen_gpio_if.mp_initiator);
    qcs_gpio_mon_bfm            #(GEN_GPIO_WIDTH)                                     gpio_gen_mon_bfm      (gen_gpio_if.mp_monitor);

    //---- database
    initial begin
        uvm_config_db #(virtual qcs_rst_gen_bfm)::
            set(null, "*m_env.m_rst_gen*",   "bfm", rst_gen_bfm);
        uvm_config_db #(virtual qcs_clk_gen_bfm)::
            set(null, "*m_env.m_clk_gen0*",  "bfm", clk_gen_bfm);
        //Active agent m_gen_in_ag
        uvm_config_db #(virtual qcs_dyn_pre_gen_drv_bfm #(GEN_ADDR_W, GEN_BW_W, GEN_GAMMA_W, GEN_SUBBAND_W))::
            set(null, "*m_env.m_gen_in_ag.m_drv*", "bfm", gen_in_drv_bfm);
        uvm_config_db #(virtual qcs_dyn_pre_gen_mon_bfm #(GEN_ADDR_W, GEN_BW_W, GEN_GAMMA_W, GEN_SUBBAND_W))::
            set(null, "*m_env.m_gen_in_ag.m_mon*", "bfm", gen_in_mon_bfm);
        //Passive agent m_gen_out_ag
        uvm_config_db #(virtual qcs_dyn_pre_gen_mon_bfm_out #(GEN_DW))::
            set(null, "*m_env.m_gen_out_ag.m_mon*", "bfm", gen_out_mon_bfm);
        //GPIO agent m_gpio_ag
        uvm_config_db #(virtual qcs_gpio_drv_bfm #(GEN_GPIO_WIDTH))::
            set(null, "*m_env.m_gpio_ag.m_drv*", "bfm", gpio_gen_drv_bfm);
        uvm_config_db #(virtual qcs_gpio_mon_bfm #(GEN_GPIO_WIDTH))::
            set(null, "*m_env.m_gpio_ag.m_mon*", "bfm", gpio_gen_mon_bfm);
    end
    //---- commutation
    assign clk                       = clk_gen_if.clk;
    assign rst_n                     = rst_gen_if.rst_n;

    assign gen_in_if.clk             = clk;
    assign gen_in_if.reset_n         = rst_n;

    assign gen_out_if.clk            = clk;
    assign gen_out_if.reset_n        = rst_n;

    assign gpio_connect              = gen_gpio_if.gpio;
    assign gen_out_if.nhtp_re = gen_in_if.nhtp_re;

dyn_pre_gen  #(
    .FREQ_BAND                 ('d5)
)
    dut(
// Output signals
    .nhtp_dout_i_0             (gen_out_if.data_i_0),
    .nhtp_dout_i_1             (gen_out_if.data_i_1),
    .nhtp_dout_q_0             (gen_out_if.data_q_0),
    .nhtp_dout_q_1             (gen_out_if.data_q_1),
// Input signals
    .clr_at_ipg                (gpio_connect.clr_at_ipg),
    .csd_bypass                (gpio_connect.csd_bypass),
    .n_tx                      (gen_in_if.n_tx),
    .nhtp_ltf                  (gpio_connect.nhtp_ltf),
    .nhtp_raddr                (gen_in_if.nhtp_raddr),
    .nhtp_re                   (gen_in_if.nhtp_re),
    .nhtp_4ch                  (gen_in_if.nhtp_4ch),
    .txconfig_bw               (gen_in_if.txconfig_bw),
    .txconfig_format           (gpio_connect.txconfig_format),
    .prehe_scale_coeff_0_0     (PREHE_SCALE_COEFF_0_0),
    .prehe_scale_coeff_1_0     (PREHE_SCALE_COEFF_1_0),
    .prehe_scale_coeff_2_0     (PREHE_SCALE_COEFF_2_0),
    .prehe_scale_coeff_3_0     (PREHE_SCALE_COEFF_3_0),
    .prehe_scale_coeff_4_0     (PREHE_SCALE_COEFF_4_0),
    .prehe_scale_coeff_5_0     (PREHE_SCALE_COEFF_5_0),
    .prehe_scale_coeff_6_0     (PREHE_SCALE_COEFF_6_0),
    .prehe_scale_coeff_7_0     (PREHE_SCALE_COEFF_7_0),
    .prehe_scale_coeff_8_0     (PREHE_SCALE_COEFF_8_0),
    .prehe_scale_coeff_9_0     (PREHE_SCALE_COEFF_9_0),
    .prehe_scale_coeff_10_0    (PREHE_SCALE_COEFF_10_0),
    .prehe_scale_coeff_11_0    (PREHE_SCALE_COEFF_11_0),
    .prehe_scale_coeff_12_0    (PREHE_SCALE_COEFF_12_0),
    .prehe_scale_coeff_13_0    (PREHE_SCALE_COEFF_13_0),
    .prehe_scale_coeff_14_0    (PREHE_SCALE_COEFF_14_0),
    .prehe_scale_coeff_15_0    (PREHE_SCALE_COEFF_15_0),
    .prehe_scale_coeff_0_1     (PREHE_SCALE_COEFF_0_1),
    .prehe_scale_coeff_1_1     (PREHE_SCALE_COEFF_1_1),
    .prehe_scale_coeff_2_1     (PREHE_SCALE_COEFF_2_1),
    .prehe_scale_coeff_3_1     (PREHE_SCALE_COEFF_3_1),
    .prehe_scale_coeff_4_1     (PREHE_SCALE_COEFF_4_1),
    .prehe_scale_coeff_5_1     (PREHE_SCALE_COEFF_5_1),
    .prehe_scale_coeff_6_1     (PREHE_SCALE_COEFF_6_1),
    .prehe_scale_coeff_7_1     (PREHE_SCALE_COEFF_7_1),
    .prehe_scale_coeff_8_1     (PREHE_SCALE_COEFF_8_1),
    .prehe_scale_coeff_9_1     (PREHE_SCALE_COEFF_9_1),
    .prehe_scale_coeff_10_1    (PREHE_SCALE_COEFF_10_1),
    .prehe_scale_coeff_11_1    (PREHE_SCALE_COEFF_11_1),
    .prehe_scale_coeff_12_1    (PREHE_SCALE_COEFF_12_1),
    .prehe_scale_coeff_13_1    (PREHE_SCALE_COEFF_13_1),
    .prehe_scale_coeff_14_1    (PREHE_SCALE_COEFF_14_1),
    .prehe_scale_coeff_15_1    (PREHE_SCALE_COEFF_15_1),
    .he_scale_coeff_0_0        (HE_SCALE_COEFF_0_0),
    .he_scale_coeff_1_0        (HE_SCALE_COEFF_1_0),
    .he_scale_coeff_2_0        (HE_SCALE_COEFF_2_0),
    .he_scale_coeff_3_0        (HE_SCALE_COEFF_3_0),
    .he_scale_coeff_4_0        (HE_SCALE_COEFF_4_0),
    .he_scale_coeff_5_0        (HE_SCALE_COEFF_5_0),
    .he_scale_coeff_6_0        (HE_SCALE_COEFF_6_0),
    .he_scale_coeff_7_0        (HE_SCALE_COEFF_7_0),
    .he_scale_coeff_8_0        (HE_SCALE_COEFF_8_0),
    .he_scale_coeff_9_0        (HE_SCALE_COEFF_9_0),
    .he_scale_coeff_10_0       (HE_SCALE_COEFF_10_0),
    .he_scale_coeff_11_0       (HE_SCALE_COEFF_11_0),
    .he_scale_coeff_12_0       (HE_SCALE_COEFF_12_0),
    .he_scale_coeff_13_0       (HE_SCALE_COEFF_13_0),
    .he_scale_coeff_14_0       (HE_SCALE_COEFF_14_0),
    .he_scale_coeff_15_0       (HE_SCALE_COEFF_15_0),
    .he_scale_coeff_0_1        (HE_SCALE_COEFF_0_1),
    .he_scale_coeff_1_1        (HE_SCALE_COEFF_1_1),
    .he_scale_coeff_2_1        (HE_SCALE_COEFF_2_1),
    .he_scale_coeff_3_1        (HE_SCALE_COEFF_3_1),
    .he_scale_coeff_4_1        (HE_SCALE_COEFF_4_1),
    .he_scale_coeff_5_1        (HE_SCALE_COEFF_5_1),
    .he_scale_coeff_6_1        (HE_SCALE_COEFF_6_1),
    .he_scale_coeff_7_1        (HE_SCALE_COEFF_7_1),
    .he_scale_coeff_8_1        (HE_SCALE_COEFF_8_1),
    .he_scale_coeff_9_1        (HE_SCALE_COEFF_9_1),
    .he_scale_coeff_10_1       (HE_SCALE_COEFF_10_1),
    .he_scale_coeff_11_1       (HE_SCALE_COEFF_11_1),
    .he_scale_coeff_12_1       (HE_SCALE_COEFF_12_1),
    .he_scale_coeff_13_1       (HE_SCALE_COEFF_13_1),
    .he_scale_coeff_14_1       (HE_SCALE_COEFF_14_1),
    .he_scale_coeff_15_1       (HE_SCALE_COEFF_15_1),
    .sys_bw_mode               (gen_in_if.sys_bw_mode),
    .config_mu_subband_present (gen_in_if.config_mu_subband_present),
    .config_gamma_rotation     (gen_in_if.config_gamma_rotation),
    .config_lstf_boost_force   (gpio_connect.config_lstf_boost_force),
    .config_lltf_boost_force   (gpio_connect.config_lltf_boost_force),
    .st_STF                    (gpio_connect.st_STF),
    .st_LTF                    (gpio_connect.st_LTF),
    .start_nhtp                (gpio_connect.start_nhtp),

    .clk                       (clk),
    .reset_n                   (rst_n)
);

endmodule
