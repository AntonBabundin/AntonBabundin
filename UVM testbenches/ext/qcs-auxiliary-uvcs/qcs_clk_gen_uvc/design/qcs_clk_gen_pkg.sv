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
`ifndef PKG_QCS_CLK_GEN_SV
`define PKG_QCS_CLK_GEN_SV

package qcs_clk_gen_pkg;
  import   uvm_pkg::*;
  `include "uvm_macros.svh"
  //----
  `include "qcs_clk_gen_globals.svh"
  `include "qcs_clk_gen_cfg.sv"
  `include "qcs_clk_gen_item.sv"
  `include "qcs_clk_gen_sqr.sv"
  `include "qcs_clk_gen_drv.sv"
  `include "qcs_clk_gen_ag.sv"
endpackage

`endif
