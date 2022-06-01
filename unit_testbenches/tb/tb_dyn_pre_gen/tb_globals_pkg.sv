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
package tb_globals_pkg;
    import   uvm_pkg::*;
    import   qcs_dyn_pre_gen_pkg::*;
    import   qcs_dyn_pre_gen_pkg_out::*;

    `include  "tb_ext_pkgs_list.svh"
    `include  "c_model_queues.svh"
    `include  "c_model_std_queues.svh"
   
    //---- types
    parameter int  GEN_DW                                = DW;
    parameter int  GEN_ADDR_W                            = ADDR_W;
    parameter int  GEN_BW_W                              = BW_W;
    parameter int  GEN_GAMMA_W                           = GAMMA_W;
    parameter int  GEN_SUBBAND_W                         = SUBBAND_W;

    parameter int  GEN_GPIO_WIDTH                        = 'd12;
    parameter time GENERATOR_CLK_PERIOD                  =  1.5625ns;   // 640 MHz
    parameter int  GEN_CW                                = 'd13;
    parameter int  L_LTF_MEM_SIZE                        = 'd5216;
    parameter int  L_STF_MEM_SIZE                        = 'd5120;

    parameter logic [GEN_CW-1:0] PREHE_SCALE_COEFF_0_0   = 'd2048;
    parameter logic [GEN_CW-1:0] PREHE_SCALE_COEFF_1_0   = 'd1448;
    parameter logic [GEN_CW-1:0] PREHE_SCALE_COEFF_2_0   = 'd1182;
    parameter logic [GEN_CW-1:0] PREHE_SCALE_COEFF_3_0   = 'd1024;
    parameter logic [GEN_CW-1:0] PREHE_SCALE_COEFF_4_0   = 'd916;
    parameter logic [GEN_CW-1:0] PREHE_SCALE_COEFF_5_0   = 'd836;
    parameter logic [GEN_CW-1:0] PREHE_SCALE_COEFF_6_0   = 'd774;
    parameter logic [GEN_CW-1:0] PREHE_SCALE_COEFF_7_0   = 'd724;
    parameter logic [GEN_CW-1:0] PREHE_SCALE_COEFF_8_0   = 'd683;
    parameter logic [GEN_CW-1:0] PREHE_SCALE_COEFF_9_0   = 'd648;
    parameter logic [GEN_CW-1:0] PREHE_SCALE_COEFF_10_0  = 'd617;
    parameter logic [GEN_CW-1:0] PREHE_SCALE_COEFF_11_0  = 'd591;
    parameter logic [GEN_CW-1:0] PREHE_SCALE_COEFF_12_0  = 'd568;
    parameter logic [GEN_CW-1:0] PREHE_SCALE_COEFF_13_0  = 'd547;
    parameter logic [GEN_CW-1:0] PREHE_SCALE_COEFF_14_0  = 'd529;
    parameter logic [GEN_CW-1:0] PREHE_SCALE_COEFF_15_0  = 'd512;
    parameter logic [GEN_CW-1:0] PREHE_SCALE_COEFF_0_1   = 'd2896;
    parameter logic [GEN_CW-1:0] PREHE_SCALE_COEFF_1_1   = 'd2048;
    parameter logic [GEN_CW-1:0] PREHE_SCALE_COEFF_2_1   = 'd1672;
    parameter logic [GEN_CW-1:0] PREHE_SCALE_COEFF_3_1   = 'd1448;
    parameter logic [GEN_CW-1:0] PREHE_SCALE_COEFF_4_1   = 'd1295;
    parameter logic [GEN_CW-1:0] PREHE_SCALE_COEFF_5_1   = 'd1182;
    parameter logic [GEN_CW-1:0] PREHE_SCALE_COEFF_6_1   = 'd1095;
    parameter logic [GEN_CW-1:0] PREHE_SCALE_COEFF_7_1   = 'd1024;
    parameter logic [GEN_CW-1:0] PREHE_SCALE_COEFF_8_1   = 'd965;
    parameter logic [GEN_CW-1:0] PREHE_SCALE_COEFF_9_1   = 'd916;
    parameter logic [GEN_CW-1:0] PREHE_SCALE_COEFF_10_1  = 'd873;
    parameter logic [GEN_CW-1:0] PREHE_SCALE_COEFF_11_1  = 'd836;
    parameter logic [GEN_CW-1:0] PREHE_SCALE_COEFF_12_1  = 'd803;
    parameter logic [GEN_CW-1:0] PREHE_SCALE_COEFF_13_1  = 'd774;
    parameter logic [GEN_CW-1:0] PREHE_SCALE_COEFF_14_1  = 'd748;
    parameter logic [GEN_CW-1:0] PREHE_SCALE_COEFF_15_1  = 'd724;
    parameter logic [GEN_CW-1:0] HE_SCALE_COEFF_0_0      = 'd1974;
    parameter logic [GEN_CW-1:0] HE_SCALE_COEFF_1_0      = 'd1395;
    parameter logic [GEN_CW-1:0] HE_SCALE_COEFF_2_0      = 'd1139;
    parameter logic [GEN_CW-1:0] HE_SCALE_COEFF_3_0      = 'd987;
    parameter logic [GEN_CW-1:0] HE_SCALE_COEFF_4_0      = 'd883;
    parameter logic [GEN_CW-1:0] HE_SCALE_COEFF_5_0      = 'd806;
    parameter logic [GEN_CW-1:0] HE_SCALE_COEFF_6_0      = 'd746;
    parameter logic [GEN_CW-1:0] HE_SCALE_COEFF_7_0      = 'd698;
    parameter logic [GEN_CW-1:0] HE_SCALE_COEFF_8_0      = 'd658;
    parameter logic [GEN_CW-1:0] HE_SCALE_COEFF_9_0      = 'd624;
    parameter logic [GEN_CW-1:0] HE_SCALE_COEFF_10_0     = 'd595;
    parameter logic [GEN_CW-1:0] HE_SCALE_COEFF_11_0     = 'd570;
    parameter logic [GEN_CW-1:0] HE_SCALE_COEFF_12_0     = 'd547;
    parameter logic [GEN_CW-1:0] HE_SCALE_COEFF_13_0     = 'd527;
    parameter logic [GEN_CW-1:0] HE_SCALE_COEFF_14_0     = 'd510;
    parameter logic [GEN_CW-1:0] HE_SCALE_COEFF_15_0     = 'd493;
    parameter logic [GEN_CW-1:0] HE_SCALE_COEFF_0_1      = 'd2791;
    parameter logic [GEN_CW-1:0] HE_SCALE_COEFF_1_1      = 'd1974;
    parameter logic [GEN_CW-1:0] HE_SCALE_COEFF_2_1      = 'd1611;
    parameter logic [GEN_CW-1:0] HE_SCALE_COEFF_3_1      = 'd1395;
    parameter logic [GEN_CW-1:0] HE_SCALE_COEFF_4_1      = 'd1248;
    parameter logic [GEN_CW-1:0] HE_SCALE_COEFF_5_1      = 'd1139;
    parameter logic [GEN_CW-1:0] HE_SCALE_COEFF_6_1      = 'd1055;
    parameter logic [GEN_CW-1:0] HE_SCALE_COEFF_7_1      = 'd987;
    parameter logic [GEN_CW-1:0] HE_SCALE_COEFF_8_1      = 'd930;
    parameter logic [GEN_CW-1:0] HE_SCALE_COEFF_9_1      = 'd883;
    parameter logic [GEN_CW-1:0] HE_SCALE_COEFF_10_1     = 'd842;
    parameter logic [GEN_CW-1:0] HE_SCALE_COEFF_11_1     = 'd806;
    parameter logic [GEN_CW-1:0] HE_SCALE_COEFF_12_1     = 'd774;
    parameter logic [GEN_CW-1:0] HE_SCALE_COEFF_13_1     = 'd746;
    parameter logic [GEN_CW-1:0] HE_SCALE_COEFF_14_1     = 'd721;
    parameter logic [GEN_CW-1:0] HE_SCALE_COEFF_15_1     = 'd698;

    typedef struct packed {
        logic       nhtp_ltf;
        logic       csd_bypass;
        logic [3:0] txconfig_format;
        logic       config_lstf_boost_force;
        logic       config_lltf_boost_force;
        logic       st_STF;
        logic       st_LTF;
        logic       start_nhtp;
        logic       clr_at_ipg;
    } gpio_gen_signals;

    typedef logic signed[GEN_DW - 1:0]  sb_checker_val_t;

    typedef struct {
        bit              match_0;
        bit              match_1;
        sb_checker_val_t expected_re_0;
        sb_checker_val_t expected_im_0;
        sb_checker_val_t expected_re_1;
        sb_checker_val_t expected_im_1;
        sb_checker_val_t observed_re_0;
        sb_checker_val_t observed_im_0;
        sb_checker_val_t observed_re_1;
        sb_checker_val_t observed_im_1;
    } sb_chkpt_cmp_resolution_t;

    typedef struct {
        sb_chkpt_cmp_resolution_t  data;
        int                        error_count;
    } sb_waveform_checker_t;

    parameter qcs_dyn_pre_gen_params_t  QCS_GENERATOR_DYNAMIC_PREAMBULE_ACT_PARAMS = '{
        "m_generator_dynamic_preambule_in_ag",
        GEN_ADDR_W,
        GEN_BW_W,
        GEN_GAMMA_W,
        GEN_SUBBAND_W
    };

    parameter qcs_gpio_param_t  QCS_GPIO_ACT_PARAM = '{
        "gpio_0",
        GEN_GPIO_WIDTH
    };

    parameter qcs_dyn_pre_gen_params_out_t  QCS_GENERATOR_DYNAMIC_PREAMBULE_PSV_PARAMS = '{
        "m_generator_dynamic_preambule_out_ag",
        GEN_DW
    };

    //---- general reports
    parameter string TB_RPTS_CQUEUE_GETTING_FAILURE  = "Cannot get C data queue from the uvm_resource_db";
    parameter string TB_RPTS_CFG_GETTING_FAILURE     = "Cannot get configuration from the uvm_config_db";
    parameter string TB_RPTS_IF_GETTING_FAILURE      = "Cannot get an interface/bfm from the uvm_config_db";
    parameter string TB_RPTS_MM_GETTING_FAILURE      = "Cannot get the memory model from the uvm_config_db";
    parameter string TB_RPTS_CHKP_GETTING_FAILURE    = "Cannot get a check point probe from the uvm_config_db";
    parameter string TB_RPTS_SQI_RND_FAILURE         = "Randomization failure, please check constraints";
    parameter string TB_RPTS_SQI_CAST_FAILURE        = "Cast failure, please check types";

endpackage
