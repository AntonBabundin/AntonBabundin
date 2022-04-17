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

+incdir+${TB_DIR}/uvc/qcs_fir_uvc
+incdir+${TB_DIR}/tb_fir
+incdir+${TB_DIR}/common/svh
+incdir+${TSTS_DIR}/fir/tsts
+incdir+${EXT_DIR}/qcs-auxiliary-uvcs/qcs_rst_gen_uvc/design
+incdir+${EXT_DIR}/qcs-auxiliary-uvcs/qcs_clk_gen_uvc/design

#----
${EXT_DIR}/qcs-auxiliary-uvcs/qcs_rst_gen_uvc/design/qcs_rst_gen_if.sv
${EXT_DIR}/qcs-auxiliary-uvcs/qcs_rst_gen_uvc/design/qcs_rst_gen_pkg.sv
${EXT_DIR}/qcs-auxiliary-uvcs/qcs_clk_gen_uvc/design/qcs_clk_gen_if.sv
${EXT_DIR}/qcs-auxiliary-uvcs/qcs_clk_gen_uvc/design/qcs_clk_gen_pkg.sv

${EXT_DIR}/qcs-auxiliary-uvcs/qcs_gpio_uvc/design/qcs_gpio_if.sv
${EXT_DIR}/qcs-auxiliary-uvcs/qcs_gpio_uvc/design/qcs_gpio_pkg.sv
${EXT_DIR}/qcs-auxiliary-uvcs/qcs_gpio_uvc/design/qcs_gpio_drv_bfm.sv
${EXT_DIR}/qcs-auxiliary-uvcs/qcs_gpio_uvc/design/qcs_gpio_mon_bfm.sv

${TB_DIR}/uvc/qcs_fir_uvc/qcs_fir_pkg.sv
${TB_DIR}/uvc/qcs_fir_uvc/qcs_fir_if.sv
${TB_DIR}/uvc/qcs_fir_uvc/qcs_fir_drv_bfm.sv
${TB_DIR}/uvc/qcs_fir_uvc/qcs_fir_mon_bfm.sv

${TB_DIR}/tb_fir/tb_defines.svh
${TB_DIR}/tb_fir/tb_globals_pkg.sv
${TB_DIR}/tb_fir/tb_dpi_pkg.sv

${TB_DIR}/tb_fir/tb_checkpoints.sv
${TB_DIR}/tb_fir/tb_hdl_top.sv
${TB_DIR}/tb_fir/tb_hvl_top.sv

// todo -   Move the files below to "src_list_c.f" when the VMT is ready for this
#${TB_DIR}/tb_fft/c_wrapper/fir_wrapper.cpp