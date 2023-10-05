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
+incdir+${SRC_A0_BB_DESIGN_DIR}/rtl/ofdm/td
+incdir+${SRC_A0_BB_DESIGN_DIR}/rtl/ofdm/td/top

${SRC_A0_BB_DESIGN_DIR}/rtl/shared/arith/nco_64ph.v
${SRC_A0_BB_DESIGN_DIR}/rtl/shared/arith/nco_64ph_lut.v
${SRC_A0_BB_DESIGN_DIR}/rtl/shared/arith/chg_sgn_sat.v
${SRC_A0_BB_DESIGN_DIR}/rtl/shared/arith/sat.v
${SRC_A0_BB_DESIGN_DIR}/rtl/shared/arith/rnd.v
${SRC_A0_BB_DESIGN_DIR}/rtl/shared/arith/cmult.v
${SRC_A0_BB_DESIGN_DIR}/rtl/shared/arith/crnd.v
${SRC_A0_BB_DESIGN_DIR}/rtl/ofdm/td/nhtp_onyx/nco_step_gen.v
${SRC_A0_BB_DESIGN_DIR}/rtl/ofdm/td/nhtp_onyx/gamma_rotation.v
${SRC_A0_BB_DESIGN_DIR}/rtl/ofdm/td/nhtp_onyx/beta_rotation.v
${SRC_A0_BB_DESIGN_DIR}/rtl/ofdm/td/nhtp_onyx/subband_mask.v
${SRC_A0_BB_DESIGN_DIR}/rtl/ofdm/td/nhtp_onyx/scale_coeff_mux.v
${SRC_A0_BB_DESIGN_DIR}/rtl/ofdm/td/nhtp_onyx/nhtp_ctl_ph3.v
${SRC_A0_BB_DESIGN_DIR}/rtl/ofdm/td/nhtp_onyx/dyn_pre_glue.v
${SRC_A0_BB_DESIGN_DIR}/rtl/ofdm/td/nhtp_onyx/dyn_pre_gen.v
