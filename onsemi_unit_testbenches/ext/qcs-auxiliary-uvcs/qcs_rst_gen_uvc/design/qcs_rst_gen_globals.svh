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
typedef enum {RST_LVL_ACTIVE, RST_LVL_PASSIVE} rst_level_t;
//---- general reports
parameter string QCS_RST_GEN_RPTS_CFG_GETTING_FAILURE = "Cannot get the configuration from uvm_config_db";
parameter string QCS_RST_GEN_RPTS_IF_GETTING_FAILURE  = "Cannot get the interface from uvm_config_db";
parameter string QCS_RST_GEN_RPTS_SQI_RND_FAILURE     = "Randomization failure, please check constraints";
parameter string QCS_RST_GEN_RPTS_SQI_CAST_FAILURE    = "Cast failure, please check types";
