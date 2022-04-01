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
//---- parameters
parameter time  DEFAULT_CLK_PERIOD = 10;
parameter logic DEFAULT_OUPUT_LVL  = '0;

//---- general reports
parameter string QCS_CLK_GEN_RPTS_CFG_GETTING_FAILURE = "Cannot get the configuration from uvm_config_db";
parameter string QCS_CLK_GEN_RPTS_IF_GETTING_FAILURE  = "Cannot get the interface from uvm_config_db";
parameter string QCS_CLK_GEN_RPTS_SQI_RND_FAILURE     = "Randomization failure, please check constraints";
parameter string QCS_CLK_GEN_RPTS_SQI_CAST_FAILURE    = "Cast failure, please check types";
