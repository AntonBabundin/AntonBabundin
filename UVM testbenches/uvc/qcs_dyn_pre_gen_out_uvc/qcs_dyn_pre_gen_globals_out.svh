//------------------------------------------------------------------------------
//
//  *** *** ***
// *   *   *   *
// *   *    *     Quantenna
// *   *     *    Connectivity
// *   *      *   Solutions
// * * *   *   *
//  *** *** ***
//
//------------------------------------------------------------------------------
//---- parameters
parameter string       ID           = "";
parameter int          DW           = 'd12;

typedef struct {
    string  ID;
    int     DW;
} qcs_dyn_pre_gen_params_out_t;

typedef struct packed {
    logic signed [DW-1:0]  data_i_0;
    logic signed [DW-1:0]  data_q_0;
    logic signed [DW-1:0]  data_i_1;
    logic signed [DW-1:0]  data_q_1;
} bfm_trn_t;
//---- general reports
parameter string QCS_GENERATOR_DYNAMIC_PREAMBULE_RPTS_CFG_GETTING_FAILURE = "Cannot get the configuration from uvm_config_db";
parameter string QCS_GENERATOR_DYNAMIC_PREAMBULE_RPTS_IF_GETTING_FAILURE  = "Cannot get the interface from uvm_config_db";
parameter string QCS_GENERATOR_DYNAMIC_PREAMBULE_RPTS_BFM_GETTING_FAILURE = "Cannot get the BFM from uvm_config_db";
parameter string QCS_GENERATOR_DYNAMIC_PREAMBULE_RPTS_SQI_RND_FAILURE     = "Randomization failure, please check constraints";
parameter string QCS_GENERATOR_DYNAMIC_PREAMBULE_RPTS_SQI_CAST_FAILURE    = "Cast failure, please check types";
