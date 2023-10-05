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
parameter int          CW           = 'd8;
parameter int          MAX_PNT_NUM  = 4096;


typedef struct {
    string  ID;
    int     DW;
} qcs_fir_params_t;

parameter qcs_fir_params_t QCS_FIR_DFLT_PARAMS = '{
    ID:        ID,
    DW:        DW
};

typedef struct packed {
    logic signed [DW-1:0]  data_re;
    logic signed [DW-1:0]  data_im;
} bfm_trn_t;

//---- general reports
parameter string QCS_FIR_RPTS_CFG_GETTING_FAILURE = "Cannot get the configuration from uvm_config_db";
parameter string QCS_FIR_RPTS_IF_GETTING_FAILURE  = "Cannot get the interface from uvm_config_db";
parameter string QCS_FIR_RPTS_BFM_GETTING_FAILURE = "Cannot get the BFM from uvm_config_db";
parameter string QCS_FIR_RPTS_SQI_RND_FAILURE     = "Randomization failure, please check constraints";
parameter string QCS_FIR_RPTS_SQI_CAST_FAILURE    = "Cast failure, please check types";
