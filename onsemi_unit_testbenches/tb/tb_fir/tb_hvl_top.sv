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
module tb_hvl_top;
    //---- uvm components
    import    uvm_pkg::*;
    `include  "uvm_macros.svh"

    //---- test environment components
    import    tb_dpi_pkg::*;
    import    tb_globals_pkg::*;
    `include  "tb_ext_pkgs_list.svh"
    `include  "qcs_uvm_rpt_srv.sv"
    `include  "tb_cfg.sv"
    `include  "tb_sb.sv"
    `include  "tb_dpi_pkg.sv"
    `include  "tb_vsqr.sv"
    `include  "tb_env.sv"
    //---- general test list
    `include  "tests_inc_list.sv"
    `include  "tb_checkpoints.sv"
//------------------------------------------------------------------------------
//---- test start
//------------------------------------------------------------------------------
    initial begin
        run_test();
        $finish;
    end
endmodule
