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
    import   qcs_fir_pkg::*;
    `include  "tb_ext_pkgs_list.svh"
    `include  "c_model_queues.svh"
    `include  "c_model_std_queues.svh"
   
    //---- types
    parameter int  FIR_DW                      = DW;
    parameter int  FIR_CW                      = CW;
    parameter int  FIR_GPIO_WIDTH              = 'd5;

    parameter logic signed [FIR_CW-1:0] FIR_COEFF_0              =   'd6;
    parameter logic signed [FIR_CW-1:0] FIR_COEFF_1              =  -'d20;
    parameter logic signed [FIR_CW-1:0] FIR_COEFF_2              =   'd78;
    parameter logic signed [FIR_CW-1:0] FIR_COEFF_3              =  'd127;


    typedef struct packed {
        logic [1:0] rx_scale;
        logic       rx_en;
        logic       rx_done;
        logic       com_clr;
    } gpio_fir_signals;

    typedef logic signed[FIR_DW - 1:0]  sb_checker_val_t;

    typedef struct {
        bit              match;
        sb_checker_val_t expected_re;
        sb_checker_val_t expected_im;
        sb_checker_val_t observed_re;
        sb_checker_val_t observed_im;
    } sb_chkpt_cmp_resolution_t;

    typedef struct {
        sb_chkpt_cmp_resolution_t  data;
        int                        error_count;
    } sb_waveform_checker_t;

    parameter qcs_gpio_param_t QCS_GPIO_DFLT_PARAMS = '{
        ID:        ID,
        WIDTH:     FIR_GPIO_WIDTH
    };

    parameter qcs_fir_params_t  QCS_FIR_ACT_PARAM = '{
        ID:     "fir_act",
        DW:     FIR_DW
    };

    parameter qcs_gpio_param_t  QCS_GPIO_ACT_PARAM = '{
        ID:     "gpio_0",
        WIDTH:  FIR_GPIO_WIDTH
    };

    parameter qcs_fir_params_t  QCS_FIR_RX_PRI_PSV_PARAM = '{
        ID:     "fir_rx_pri_psv",
        DW:     FIR_DW
    };

    parameter qcs_fir_params_t  QCS_FIR_RX_SEC_PSV_PARAM = '{
        ID:     "fir_rx_sec_psv",
        DW:     FIR_DW
    };

    parameter time FIR_CLK_PERIOD        = 25ns;   // 40 MHz
    parameter time FIR_CLK_RX_PERIOD     = 50ns;   // 20 MHz
    //---- general reports
    parameter string TB_RPTS_CQUEUE_GETTING_FAILURE  = "Cannot get C data queue from the uvm_resource_db";
    parameter string TB_RPTS_CFG_GETTING_FAILURE     = "Cannot get configuration from the uvm_config_db";
    parameter string TB_RPTS_IF_GETTING_FAILURE      = "Cannot get an interface/bfm from the uvm_config_db";
    parameter string TB_RPTS_MM_GETTING_FAILURE      = "Cannot get the memory model from the uvm_config_db";
    parameter string TB_RPTS_CHKP_GETTING_FAILURE    = "Cannot get a check point probe from the uvm_config_db";
    parameter string TB_RPTS_SQI_RND_FAILURE         = "Randomization failure, please check constraints";
    parameter string TB_RPTS_SQI_CAST_FAILURE        = "Cast failure, please check types";

endpackage
