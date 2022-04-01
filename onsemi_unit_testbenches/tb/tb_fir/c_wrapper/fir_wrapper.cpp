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
#include "svdpi.h"
#include "dpiheader.h"
#include <vector>
#include <array>
#include <cassert>
#include <cstdio>
#include <iostream>
#include <string>
#include <fstream>
using namespace std;

#define COSIM_BIN
#include "decFIR.h"
#include "shared/fxp_precisions.h"
//COSIM
#include "control/dumper.cpp"
#include "base/string_utils.cpp"
#include "config/settings_parser.cpp"
#include "base/data.cpp"
#include "base/param.cpp"
#include "config/cfg.cpp"
#include "shared/cosim/cosim_interface.h"
#include "shared/cosim/cosim_logger.h"
#include "shared/cosim/dpiheader.h"
#include "control/hierarchy_tag.cpp"
#include "shared/cosim/cosim_interface.cpp"
#include "shared/cosim/cosim_logger.cpp"

using decfir_data_fix = fxp::s1r1<NBITS_COMMON, POS_COMMON>;
using decfir_coef_fix = fxp::s1r1<8, 7>;
using decfir_mult_fix = fxp::s1r1<decfir_data_fix::nbits + decfir_coef_fix::nbits - 1, decfir_data_fix::pos + decfir_coef_fix::pos>;
using decfir_acc_fix  = fxp::s1r1<decfir_mult_fix::nbits + 8, decfir_mult_fix::pos>;
using decfir_macc_fix = fxp::def_macc<decfir_coef_fix, decfir_mult_fix, decfir_acc_fix>;
using decfir_filter_t = decFIRStrct<decfir_data_fix, decfir_macc_fix>; 
using td_sample_cfix = fxp::complex<12, 11, 1, 1>;

extern "C" int push_aux_chkp(
    int64_t    val,
    const char* id
);


int fir_wrapper(
    const svOpenArrayHandle data_i,
    const svOpenArrayHandle data_q,
    int   in_sampl,
    int   en_logger
) {
    int Out_Samp;
    int rx_coef_0 =   6;
    int rx_coef_1 =  -20;
    int rx_coef_2 =   78;
    int rx_coef_3 =  127;
    char chkpoint_id_rx [5] = "RX";
    typedef struct {
        int32_t re;
        int32_t im;
    } cmplx_t;

    union out_val_t {
        cmplx_t    cmplx;
        int64_t    val;
    } out_val;

    std::vector<int> coef = {rx_coef_0, 0, rx_coef_1, 0, rx_coef_2, rx_coef_3, rx_coef_2, 0, rx_coef_1, 0, rx_coef_0};
    decfir_filter_t FIR;
    FIR.init(coef,2); //init model
    td_sample_cfix res [in_sampl];
    td_sample_cfix out_lp [in_sampl/2];
    td_sample_cfix out_hp [in_sampl/2]; //

    for (int i = 0; i < in_sampl; ++i) {
        res[i].init_from_int(*((int*) svGetArrElemPtr1(data_i, i)), *((int*) svGetArrElemPtr1(data_q, i)));
    }

    FIR.process(res, out_lp, out_hp, in_sampl, &Out_Samp);

    for (int k = 0; k < Out_Samp; ++k) {
        out_val.cmplx.re = (int32_t)out_lp[k].re.data();
        out_val.cmplx.im = (int32_t)out_lp[k].im.data();

        push_aux_chkp((long long) out_val.val, (const char*) chkpoint_id_rx);
    }
    //---- Debug info
    if(en_logger == 1) {
        ofstream f_log_in;
        ofstream f_log_out;
        //----
        f_log_in.open("c_model_input.log", std::ofstream::app);
        f_log_out.open("c_model_output.log", std::ofstream::app);
        //---- input
        for (int i = 0; i < in_sampl; ++i) {
            f_log_in <<"din_i = " << *((int*) svGetArrElemPtr1(data_i, i)) << "    din_q = " << *((int*) svGetArrElemPtr1(data_q, i)) << endl;
        }
        //---- output
        for (int i = 0; i < Out_Samp; ++i) {
            f_log_out << " dout_i = " << (int32_t)out_lp[i].re.data() << "    dout_q = " << (int32_t)out_lp[i].im.data() << endl;
        }

        f_log_in.close();
        f_log_out.close();
    }
    return 0;
}