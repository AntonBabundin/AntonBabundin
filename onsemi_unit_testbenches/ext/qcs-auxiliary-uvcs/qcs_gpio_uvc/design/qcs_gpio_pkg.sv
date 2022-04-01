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
`ifndef PKG_QCS_GPIO_SV
`define PKG_QCS_GPIO_SV

package qcs_gpio_pkg;
  import   uvm_pkg::*;
  `include "uvm_macros.svh"
  //----
  `include "qcs_gpio_globals.svh"
  `include "qcs_gpio_cfg.sv"
  `include "qcs_gpio_item.sv"
  `include "qcs_gpio_sqr.sv"
  `include "qcs_gpio_drv.sv"
  `include "qcs_gpio_mon.sv"
  `include "qcs_gpio_ag.sv"
endpackage

`endif
