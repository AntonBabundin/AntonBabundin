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
#include "tx/digital/blocks/ofdmMod11n.h"
#include "tx/digital/blocks/prepare_l_stf_l_ltf.h"
#include "shared/hw_tables.h"
#include "config/cfg.h"
#include "wifi_tables.h"

#include <list>
#include <iostream>
#include <string>
#include <fstream>

#define COSIM_BIN
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


using param_set_t = std::list<std::pair<std::string, data_t>>;

extern "C" int push_aux_chkp(
    int64_t    val,
    const char* id
);

int dyn_pre_gen_wrapper(
    int sys_bw,
    int pkt_bw,
    int format,
    int gamma_rot,
    int subband_punct,
    int chain_tx,
    int n_4ch
) {

    typedef struct {
        uint32_t im;
        uint32_t re;
    } cmplx_t;

    union out_val_t {
        cmplx_t     cmplx;
        uint64_t    val;
    } out_val;
    //----------------------------------------------------------------------------------------------------------------------------------------------------
    int sampling_rate_for_sysbw_160 = 0;
    int chain_range_min;
    int chain_range_max;
    char chkpoint_id_tx [10];
    tx11bn_settings_t settings_;
    int  puncturing_code = (~subband_punct)&0xFFFF;
    phy_t phy_type;
    ppdu_type he_ppdu_type;

    HTformatType PHY_TX_FORMAT_CFG = HTformatType::FORMAT_HE_EXT_SU;
    std::vector<size_t> punctured_subbands;

    if(n_4ch == 0){
        chain_range_min = 0;
        chain_range_max = 2;
    }
    else
    {
        chain_range_min = 2;
        chain_range_max = 4;
    }

    switch (pkt_bw) {
        case 0:
            settings_.CH_BANDWIDTH = pkt_bw_t::BW_20MHZ;            
            break;
        case 1:
            settings_.CH_BANDWIDTH = pkt_bw_t::BW_40MHZ;            
            break;
        case 2:
            settings_.CH_BANDWIDTH = pkt_bw_t::BW_80MHZ;            
            break;
        case 3:
            settings_.CH_BANDWIDTH = pkt_bw_t::BW_160MHZ;            
            break;
        case 4:
            settings_.CH_BANDWIDTH = pkt_bw_t::BW_320MHZ;            
            break;
        case 5:
            settings_.CH_BANDWIDTH = pkt_bw_t::BW_320MHZ;            
            break;
    }

    size_t num_subbands = num_sub_bands_in_ch_bw.at(settings_.CH_BANDWIDTH);

    switch (format) {
        case 0:
            PHY_TX_FORMAT_CFG = HTformatType::FORMAT_NONHT;
            phy_type = phy_t::NONHT;
            he_ppdu_type = ppdu_type::NON_HE;
            settings_.punctured_subbands = {};
            break;
        case 1:
            PHY_TX_FORMAT_CFG = HTformatType::FORMAT_HTMIXED;
            phy_type = phy_t::HT;
            he_ppdu_type = ppdu_type::NON_HE;
            settings_.punctured_subbands = {};
            break;
        case 2:
            PHY_TX_FORMAT_CFG = HTformatType::FORMAT_HTGREENFIELD;
            phy_type = phy_t::HT;
            he_ppdu_type = ppdu_type::NON_HE;
            settings_.punctured_subbands = {};
            break;
        case 3:
            PHY_TX_FORMAT_CFG = HTformatType::FORMAT_VHT;
            phy_type = phy_t::VHT;
            he_ppdu_type = ppdu_type::NON_HE;
            settings_.punctured_subbands = {};
            break;
        case 4:
            PHY_TX_FORMAT_CFG = HTformatType::FORMAT_HE_SU;
            phy_type = phy_t::HE;
            he_ppdu_type = ppdu_type::SU;
            for (size_t subband = 0; subband < num_subbands; ++subband) {
                if ((puncturing_code >> (num_subbands - subband - 1)) & 1) {
                    punctured_subbands.push_back(subband);
                }
            }
            settings_.punctured_subbands = punctured_subbands;
            break;
        case 5:
            PHY_TX_FORMAT_CFG = HTformatType::FORMAT_HE_MU;
            phy_type = phy_t::HE;
            he_ppdu_type = ppdu_type::MU;
            for (size_t subband = 0; subband < num_subbands; ++subband) {
                if ((puncturing_code >> (num_subbands - subband - 1)) & 1) {
                    punctured_subbands.push_back(subband);
                }
            }
            settings_.punctured_subbands = punctured_subbands;
            break;
        case 6:
            PHY_TX_FORMAT_CFG = HTformatType::FORMAT_HE_EXT_SU;
            phy_type = phy_t::HE;
            he_ppdu_type = ppdu_type::SU_ER;
            for (size_t subband = 0; subband < num_subbands; ++subband) {
                if ((puncturing_code >> (num_subbands - subband - 1)) & 1) {
                    punctured_subbands.push_back(subband);
                }
            }
            settings_.punctured_subbands = punctured_subbands;
            break;
        case 7:
            PHY_TX_FORMAT_CFG = HTformatType::FORMAT_HE_TRIG;
            phy_type = phy_t::HE;
            he_ppdu_type = ppdu_type::TB;
            for (size_t subband = 0; subband < num_subbands; ++subband) {
                if ((puncturing_code >> (num_subbands - subband - 1)) & 1) {
                    punctured_subbands.push_back(subband);
                }
            }
            settings_.punctured_subbands = punctured_subbands;
            break;
        case 8:
            PHY_TX_FORMAT_CFG = HTformatType::FORMAT_EHT_SU;
            phy_type = phy_t::EHT;
            he_ppdu_type = ppdu_type::SU;
            for (size_t subband = 0; subband < num_subbands; ++subband) {
                if ((puncturing_code >> (num_subbands - subband - 1)) & 1) {
                    punctured_subbands.push_back(subband);
                }
            }
            settings_.punctured_subbands = punctured_subbands;
            break;
        case 9:
            PHY_TX_FORMAT_CFG = HTformatType::FORMAT_EHT_MU;
            phy_type = phy_t::EHT;
            he_ppdu_type = ppdu_type::MU;
            for (size_t subband = 0; subband < num_subbands; ++subband) {
                if ((puncturing_code >> (num_subbands - subband - 1)) & 1) {
                    punctured_subbands.push_back(subband);
                }
            }
            settings_.punctured_subbands = punctured_subbands;
            break;
        case 10:
            PHY_TX_FORMAT_CFG = HTformatType::FORMAT_EHT_EXT_SU;
            he_ppdu_type = ppdu_type::SU_ER;
            phy_type = phy_t::EHT;
            for (size_t subband = 0; subband < num_subbands; ++subband) {
                if ((puncturing_code >> (num_subbands - subband - 1)) & 1) {
                    punctured_subbands.push_back(subband);
                }
            }
            settings_.punctured_subbands = punctured_subbands;
            break;
        case 11:
            PHY_TX_FORMAT_CFG = HTformatType::FORMAT_EHT_TRIG;
            phy_type = phy_t::EHT;
            he_ppdu_type = ppdu_type::TB;
            for (size_t subband = 0; subband < num_subbands; ++subband) {
                if ((puncturing_code >> (num_subbands - subband - 1)) & 1) {
                    punctured_subbands.push_back(subband);
                }
            }
            settings_.punctured_subbands = punctured_subbands;
            break;
    }
    /*
    enum HTmodeType {
        NONHT = 0,  // NONHT_11G (20 MHz), NONHT_11A (20MHz), NONHT_DUPLICATE (40, 80, 160, 320 MHz)
        HT20 = 1,
        HT40 = 2,
        VHT20 = 3,
        VHT40 = 4,
        VHT80 = 5,
        VHT160 = 6,

        HE20 = 8,
        HE40 = 9,
        HE80 = 10,
        HE160 = 11,

        EHT20 = 13,
        EHT40 = 14,
        EHT80 = 15,
        EHT160 = 16,
        EHT320 = 17
    };
    */
    switch (sys_bw) {
        case 0:
            settings_.sys_bw = systemBW_cfg::SYSBW_20;            
            break;
        case 1:
            settings_.sys_bw = systemBW_cfg::SYSBW_40;            
            break;
        case 2:
            settings_.sys_bw = systemBW_cfg::SYSBW_80;            
            break;
        case 3:
            settings_.sys_bw = systemBW_cfg::SYSBW_160;            
            sampling_rate_for_sysbw_160 = 320; // 320 (TX TD mode 160x4), 640 (TX TD mode 160x8)
            break;
        case 4:
            settings_.sys_bw = systemBW_cfg::SYSBW_160;            
            sampling_rate_for_sysbw_160 = 640; // 320 (TX TD mode 160x4), 640 (TX TD mode 160x8)
            break;
        case 5:
            settings_.sys_bw = systemBW_cfg::SYSBW_320;            
            break;
    }


    settings_.N_TX = chain_tx; // Number of Tx chains {1, 2, 3, 4}
    //----------------------------------------------------------------------------------------------------------------------------------------------------
    settings_.ch_bw_processed = settings_.CH_BANDWIDTH;
    settings_.N_TXperSegment = settings_.N_TX;

    std::vector<int> sampling_rate = {160, 160, 320, sampling_rate_for_sysbw_160, 640};

    std::shared_ptr<cfg::cfg_t> p_hw_registers =
        std::make_shared<cfg::cfg_t>("OFDMA_OPBAND_POS_IN_BSS_BAND", 0, "TX_OFDM_WIN_LEN_20MHz", std::vector<int>{3, 3, 3, 3, 3});
    std::shared_ptr<cfg::cfg_t> p_tx_cfg = std::make_shared<cfg::cfg_t>("PHY_TX_FORMAT_CFG",
                                                                        PHY_TX_FORMAT_CFG,
                                                                        "PHY_TX_GAMMA_ROT_320",
                                                                        gamma_rot,
                                                                        "LSTF_BOOST_FORCE",
                                                                        false,
                                                                        "LLTF_BOOST_FORCE",
                                                                        false,
                                                                        "bypass_csd",
                                                                        false);
    std::shared_ptr<cfg::cfg_t> p_c_cfg = std::make_shared<cfg::cfg_t>("CORRUPT_L_STF",
                                                                       false,
                                                                       "CORRUPT_L_LTF",
                                                                       false,
                                                                       "PRESTORED_L_STF_L_LTF_SAMPLING_RATE_MHZ",
                                                                       640,
                                                                       "IS_IFFT_INTERPOLATION",
                                                                       true,
                                                                       "PA_inp_level_ofdm_dBFS",
                                                                       -12.0,
                                                                       "IS_NONLINEAR_WINDOWING",
                                                                       true);

    settings_.p_hw_registers = p_hw_registers;
    settings_.p_tx_cfg = p_tx_cfg;
    settings_.p_c_cfg = p_c_cfg;
    settings_.he_ppdu_type = format_to_he_ppdu_type.at(settings_.p_tx_cfg->get<HTformatType>("PHY_TX_FORMAT_CFG"));
    settings_.phy_type = format_to_phy_type.at(settings_.p_tx_cfg->get<HTformatType>("PHY_TX_FORMAT_CFG"));

    preamble_puncturing_t pream_punc_inst;
    gamma_rotation_t      gamma_rotation_inst;

    pream_punc_inst.init(settings_);
    gamma_rotation_inst.init(settings_);

    std::vector<bool>                     subband_presence_pattern = pream_punc_inst.subband_presence_pattern();
    std::vector<fxp::complex<2, 0, 1, 1>> gamma_rot_coeff = gamma_rotation_inst.gamma();

    td_in_chain_sample_t l_stf;
    td_in_chain_sample_t l_ltf;
    td_in_chain_sample_t tail;

    std::tie(l_stf, l_ltf, tail) = prepare_l_stf_l_ltf(settings_,
                                                       sampling_rate[static_cast<int>(SYS2ANALOG_BW.at(settings_.sys_bw))],
                                                       subband_presence_pattern,
                                                       gamma_rot_coeff);

    for (int i = chain_range_min; i < chain_range_max; i++) {
        for (size_t k = 0; k < l_stf[i].size(); k++) {
            out_val.cmplx.re = (int32_t)l_stf[i][k].re.data();
            out_val.cmplx.im = (int32_t)l_stf[i][k].im.data();
            std::sprintf(chkpoint_id_tx, "TX_%d", i);
            push_aux_chkp((long long) out_val.val, (const char*) chkpoint_id_tx);
        }
        for (size_t k = 0; k < l_ltf[i].size(); k++) {
            out_val.cmplx.re = (int32_t)l_ltf[i][k].re.data();
            out_val.cmplx.im = (int32_t)l_ltf[i][k].im.data();
            std::sprintf(chkpoint_id_tx, "TX_%d", i);
            push_aux_chkp((long long) out_val.val, (const char*) chkpoint_id_tx);
        }
        for (size_t k = 0; k < tail[i].size(); k++) {
            out_val.cmplx.re = (int32_t)tail[i][k].re.data();
            out_val.cmplx.im = (int32_t)tail[i][k].im.data();
            std::sprintf(chkpoint_id_tx, "TX_%d", i);
            push_aux_chkp((long long) out_val.val, (const char*) chkpoint_id_tx);
        }
    }
    std::ofstream f_log_out;
    //----
    f_log_out.open("c_model_output.log", std::ofstream::app);
    //----
    f_log_out <<"sys_bw = " << sys_bw << std::endl;
    f_log_out <<"pkt_bw = " << pkt_bw << std::endl;
    f_log_out <<"format = " << format << std::endl;
    f_log_out <<"gamma_rot = " << gamma_rot << std::endl;
    f_log_out <<"subband_punct = " << subband_punct << std::endl;
    f_log_out <<"chain_tx = " << chain_tx << std::endl;
    f_log_out <<"n_4ch = " << n_4ch << std::endl;

    //----
    for (int i = chain_range_min; i<chain_range_max; i++) {
        for (size_t k = 0; k < l_stf[i].size(); k++) {
            f_log_out << "stf_re = " << (int32_t)l_stf[i][k].re.data() << std::endl;
            f_log_out << "stf_im = " << (int32_t)l_stf[i][k].im.data() << std::endl;
        }
        for (size_t k = 0; k < l_ltf[i].size(); k++) {
            f_log_out << "ltf_re = " << (int32_t)l_stf[i][k].re.data() << std::endl;
            f_log_out << "ltf_im = " << (int32_t)l_stf[i][k].im.data() << std::endl;

        }
        for (size_t k = 0; k < tail[i].size(); k++) {
            f_log_out << "tail_re = " << (int32_t)l_stf[i][k].re.data() << std::endl;
            f_log_out << "tail_im = " << (int32_t)l_stf[i][k].im.data() << std::endl;
        }
    }
    f_log_out.close();
    return 0;
}