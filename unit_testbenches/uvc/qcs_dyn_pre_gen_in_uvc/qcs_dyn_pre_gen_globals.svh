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
parameter int          ADDR_W       = 'd13;
parameter int          BW_W         = 'd3;
parameter int          GAMMA_W      = 'd3;
parameter int          SUBBAND_W    = 'd16;

typedef struct {
    string ID;
    int    ADDR_W;
    int    BW_W;
    int    GAMMA_W;
    int    SUBBAND_W;
} qcs_dyn_pre_gen_params_t;

parameter qcs_dyn_pre_gen_params_t QCS_GENERATOR_DYNAMIC_PREAMBULE_DFLT_PARAMS = '{
    ID:        ID,
    ADDR_W:    ADDR_W,
    BW_W:      BW_W,
    GAMMA_W:   GAMMA_W,
    SUBBAND_W: SUBBAND_W
};

typedef struct packed {
    logic unsigned [ADDR_W-1:0]     addr;
    logic unsigned [BW_W-1:0]       sys_bw;
    logic unsigned [BW_W-1:0]       pkt_bw;
    logic unsigned [GAMMA_W-1:0]    gamma_rotation;
    logic unsigned [SUBBAND_W-1:0]  mu_subband_punct;
    logic unsigned [3:0]            num_of_tx_chains;
    logic unsigned                  num_4ch;
} bfm_trn_t;
 
//---- general reports
parameter string QCS_GENERATOR_DYNAMIC_PREAMBULE_RPTS_CFG_GETTING_FAILURE = "Cannot get the configuration from uvm_config_db";
parameter string QCS_GENERATOR_DYNAMIC_PREAMBULE_RPTS_IF_GETTING_FAILURE  = "Cannot get the interface from uvm_config_db";
parameter string QCS_GENERATOR_DYNAMIC_PREAMBULE_RPTS_BFM_GETTING_FAILURE = "Cannot get the BFM from uvm_config_db";
parameter string QCS_GENERATOR_DYNAMIC_PREAMBULE_RPTS_SQI_RND_FAILURE     = "Randomization failure, please check constraints";
parameter string QCS_GENERATOR_DYNAMIC_PREAMBULE_RPTS_SQI_CAST_FAILURE    = "Cast failure, please check types";
