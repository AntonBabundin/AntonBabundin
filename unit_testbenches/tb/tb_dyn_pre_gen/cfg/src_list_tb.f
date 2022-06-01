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
+incdir+${TB_DIR}
+incdir+${TB_DIR}/common/report_server

+incdir+${TB_DIR}/uvc/qcs_dyn_pre_gen_in_uvc
+incdir+${TB_DIR}/uvc/qcs_dyn_pre_gen_out_uvc

+incdir+${TB_DIR}/tb_dyn_pre_gen
+incdir+${TB_DIR}/common/svh
+incdir+${TSTS_DIR}/dyn_pre_gen/tsts
+incdir+${EXT_DIR}/qcs-auxiliary-uvcs/qcs_rst_gen_uvc/design
+incdir+${EXT_DIR}/qcs-auxiliary-uvcs/qcs_clk_gen_uvc/design

#----
${EXT_DIR}/qcs-auxiliary-uvcs/qcs_rst_gen_uvc/design/qcs_rst_gen_if.sv
${EXT_DIR}/qcs-auxiliary-uvcs/qcs_rst_gen_uvc/design/qcs_rst_gen_pkg.sv
${EXT_DIR}/qcs-auxiliary-uvcs/qcs_rst_gen_uvc/design/qcs_rst_gen_bfm.sv


${EXT_DIR}/qcs-auxiliary-uvcs/qcs_clk_gen_uvc/design/qcs_clk_gen_if.sv
${EXT_DIR}/qcs-auxiliary-uvcs/qcs_clk_gen_uvc/design/qcs_clk_gen_pkg.sv
${EXT_DIR}/qcs-auxiliary-uvcs/qcs_clk_gen_uvc/design/qcs_clk_gen_bfm.sv

${EXT_DIR}/qcs-auxiliary-uvcs/qcs_gpio_uvc/design/qcs_gpio_if.sv
${EXT_DIR}/qcs-auxiliary-uvcs/qcs_gpio_uvc/design/qcs_gpio_pkg.sv
${EXT_DIR}/qcs-auxiliary-uvcs/qcs_gpio_uvc/design/qcs_gpio_drv_bfm.sv
${EXT_DIR}/qcs-auxiliary-uvcs/qcs_gpio_uvc/design/qcs_gpio_mon_bfm.sv

${TB_DIR}/uvc/qcs_dyn_pre_gen_in_uvc/qcs_dyn_pre_gen_pkg.sv
${TB_DIR}/uvc/qcs_dyn_pre_gen_in_uvc/qcs_dyn_pre_gen_if.sv
${TB_DIR}/uvc/qcs_dyn_pre_gen_in_uvc/qcs_dyn_pre_gen_drv_bfm.sv
${TB_DIR}/uvc/qcs_dyn_pre_gen_in_uvc/qcs_dyn_pre_gen_mon_bfm.sv

${TB_DIR}/uvc/qcs_dyn_pre_gen_out_uvc/qcs_dyn_pre_gen_pkg_out.sv
${TB_DIR}/uvc/qcs_dyn_pre_gen_out_uvc/qcs_dyn_pre_gen_if_out.sv
${TB_DIR}/uvc/qcs_dyn_pre_gen_out_uvc/qcs_dyn_pre_gen_mon_bfm_out.sv


${TB_DIR}/tb_dyn_pre_gen/tb_defines.svh
${TB_DIR}/tb_dyn_pre_gen/tb_globals_pkg.sv
${TB_DIR}/tb_dyn_pre_gen/tb_dpi_pkg.sv

${TB_DIR}/tb_dyn_pre_gen/tb_checkpoints.sv
${TB_DIR}/tb_dyn_pre_gen/tb_hdl_top.sv
${TB_DIR}/tb_dyn_pre_gen/tb_hvl_top.sv
