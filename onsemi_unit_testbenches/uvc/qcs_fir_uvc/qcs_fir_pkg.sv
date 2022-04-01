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
`ifndef PKG_QCS_FIR_SV
`define PKG_QCS_FIR_SV

package qcs_fir_pkg;
    import   uvm_pkg::*;
    import   qcs_gpio_pkg::*;
    `include "uvm_macros.svh"
    //
    `include "qcs_fir_globals.svh"
    `include "qcs_fir_cfg.sv"
    `include "qcs_fir_item.sv"
    `include "qcs_fir_sqr.sv"
    `include "qcs_fir_drv.sv"
    `include "qcs_fir_mon.sv"
    `include "qcs_fir_ag.sv"
    
   typedef uvm_event #(qcs_fir_item #(QCS_FIR_DFLT_PARAMS)) qcs_fir_pkt_event_t;
endpackage

`endif
