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
parameter int QCS_GPIO_UVC_MAX_WIDTH = 'd64;

//---- types
typedef struct packed {
    logic [QCS_GPIO_UVC_MAX_WIDTH-1:0]  clear;
    logic [QCS_GPIO_UVC_MAX_WIDTH-1:0]  set;
} bfm_drv_rqst_trn_t;

typedef struct packed {
    logic [QCS_GPIO_UVC_MAX_WIDTH-1:0]  clear;
    logic [QCS_GPIO_UVC_MAX_WIDTH-1:0]  set;
    logic [QCS_GPIO_UVC_MAX_WIDTH-1:0]  raw_data;
} bfm_mon_trn_t;

typedef struct {
    string ID;
    int    WIDTH;
} qcs_gpio_param_t;

//---- parameters
parameter qcs_gpio_param_t QCS_GPIO_UVC_DFLT_PARAMS = '{
    ID:     "",
    WIDTH:  -1
};

//---- general reports
parameter string QCS_GPIO_RPTS_CFG_GETTING_FAILURE = "Cannot get the configuration from uvm_config_db";
parameter string QCS_GPIO_RPTS_IF_GETTING_FAILURE  = "Cannot get the interface from uvm_config_db";
parameter string QCS_GPIO_RPTS_SQI_RND_FAILURE     = "Randomization failure, please check constraints";
parameter string QCS_GPIO_RPTS_SQI_CAST_FAILURE    = "Cast failure, please check types";