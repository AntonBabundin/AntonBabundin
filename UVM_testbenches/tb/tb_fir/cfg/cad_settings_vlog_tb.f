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
# default
#-------------------------------------------------------------------------------
-mfcu=macro
#-------------------------------------------------------------------------------
# QVIP default
#-------------------------------------------------------------------------------
-define MAP_PROT_ATTR
#-------------------------------------------------------------------------------
# user
#-------------------------------------------------------------------------------
-timescale 1ps/1ps
#-dpicpppath /cad/mgc/questa/2020.4_1/questasim/gcc-7.4.0-linux_x86_64/bin/g++
${TB_DIR}/tb_fir/c_wrapper/fir_wrapper.cpp
-ccflags "-fPIC -g -W -shared -lstdc++ -g $STACK -lm -lstdc++ -std=c++14 -O0  \
-I /proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_2.5_release/src/include \
-I /proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_2.5_release/modules/wlan/src/rx/digital/ofdm/Blocks \
-I /proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_2.5_release/modules/wlan/src \
-I /proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_2.5_release/modules/shared \
-I /proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_2.5_release/modules/calibration/include \
-I /proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_2.5_release/modules/calibration/src \
-I /proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_2.5_release/modules/mmoe/include \
-I /proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_2.5_release/modules/mmoe/src \
-I /proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_2.5_release/modules/precoding/include \
-I /proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_2.5_release/modules/precoding/src \
-I /proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_2.5_release/modules/shared/src \
-I /proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_2.5_release/modules/standard/include \
-I /proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_2.5_release/modules/standard/src \
-I /proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_2.5_release/modules/wlan/include \
-I /proj/onyx/workareas/shared/baseband_c_model/BBIC7/bbic7_phase_2.5_release/modules/wlan/src/rx/digital/common \
-o fir_c_model.so \
-DCOSIM"

-define UVM_REPORT_DISABLE_FILE_LINE