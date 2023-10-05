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
-uvmcontrol=all
#-------------------------------------------------------------------------------
# user
#-------------------------------------------------------------------------------
# verbosity levels for UVM environment UVM_FULL UVM_HIGH UVM_LOW
#-------------------------------------------------------------------------------
-dpicpppath /custom/tools/lang/release6/gcc-8.4.0/bin/g++
#-sv_lib ${EXT_DIR}/c_model/analog
#-sv_lib ${EXT_DIR}/c_model/main
+UVM_VERBOSITY="UVM_HIGH"
+UVM_NO_RELNOTES
#+UVM_DEFAULT_SERVER
+UVM_OBJECTION_TRACE
-suppress 8887
-voptargs="+acc"