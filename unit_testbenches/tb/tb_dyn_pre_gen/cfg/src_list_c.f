#-------------------------------------------------------------------------------
#
#   *** *** ***
#  *   *   *   *
#  *   *    *     Quantenna
#  *   *     *    Connectivity
#  *   *      *   Solutions
#  * * *   *   *
#   *** *** ***
#     *
#-------------------------------------------------------------------------------
-dpicpppath /custom/tools/lang/release6/gcc-8.4.0/bin/g++
-ccflags "-fPIC -g -W -shared -lstdc++ -g $STACK -lm -lstdc++ -std=c++14 -O0  \
-I /proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_3.0_release_2022-05-25/modules/wlan/src/tx/digital/blocks \
-I /proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_3.0_release_2022-05-25/src/include \
-I /proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_3.0_release_2022-05-25/modules/wlan/src/tx \
-I /proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_3.0_release_2022-05-25/modules/wlan/src \
-I /proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_3.0_release_2022-05-25/modules/shared \
-I /proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_3.0_release_2022-05-25/modules/calibration/include \
-I /proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_3.0_release_2022-05-25/modules/calibration/src \
-I /proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_3.0_release_2022-05-25/modules/mmoe/include \
-I /proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_3.0_release_2022-05-25/modules/mmoe/src \
-I /proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_3.0_release_2022-05-25/modules/precoding/include \
-I /proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_3.0_release_2022-05-25/modules/precoding/src \
-I /proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_3.0_release_2022-05-25/modules/shared/src \
-I /proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_3.0_release_2022-05-25/modules/standard/include \
-I /proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_3.0_release_2022-05-25/modules/standard/src \
-I /proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_3.0_release_2022-05-25/modules/wlan/include \
-I /proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_3.0_release_2022-05-25/modules/wlan/src/tx/digital/common \
-I /cad/mgc/questa/2020.4_1/questasim/include \
-I /proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_3.0_release_2022-05-25/modules/wlan/include/shared \
-I ${TB_DIR}/tb_fir/c_wrapper/"

${TB_DIR}/tb_dyn_pre_gen/c_wrapper/dyn_pre_gen_wrapper.cpp
/proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_3.0_release_2022-05-25/modules/wlan/src/tx/digital/blocks/prepare_l_stf_l_ltf.cpp
/proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_3.0_release_2022-05-25/modules/wlan/src/tx/digital/GetSettings.cpp
/proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_3.0_release_2022-05-25/modules/shared/src/stats/stats.cpp
/proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_3.0_release_2022-05-25/modules/wlan/src/tx/tx_hw_registers.cpp
/proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_3.0_release_2022-05-25/modules/wlan/src/tx/digital/tx_config.cpp
/proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_3.0_release_2022-05-25/modules/wlan/src/tx/tx_c_config.cpp
/proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_3.0_release_2022-05-25/modules/wlan/src/tx/tx_analog_config.cpp
/proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_3.0_release_2022-05-25/modules/wlan/src/tx/digital/q_container_config.cpp
/proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_3.0_release_2022-05-25/modules/wlan/src/tx/digital/blocks/ofdmMod11n.cpp
/proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_3.0_release_2022-05-25/modules/standard/src/wifi_tables.cpp
/proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_3.0_release_2022-05-25/modules/wlan/include/shared/td/nco.cpp
/proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_3.0_release_2022-05-25/modules/wlan/src/tx/deriveSettings.cpp
/proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_3.0_release_2022-05-25/modules/shared/src/fft/fft.cpp