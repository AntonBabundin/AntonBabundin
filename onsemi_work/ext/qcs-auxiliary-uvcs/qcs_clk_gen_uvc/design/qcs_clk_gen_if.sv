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
interface qcs_clk_gen_if();
  wire  clk;
  //----
  logic r_clk;
  //----
  assign clk = r_clk;

  //---- modport
  modport mst (
    output clk
  );

  modport slv (
    input  clk
  );

endinterface
