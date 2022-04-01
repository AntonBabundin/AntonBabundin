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
interface qcs_rst_gen_if ();

  wire  rst;
  wire  rst_n;
  //----
  logic r_rst;
  logic r_rst_n;
  //----
  assign rst = r_rst;
  assign rst_n = r_rst_n;

  //---- modport
  modport mst (
    output rst,
    output rst_n
  );

  modport slv (
    input  rst,
    input  rst_n
  );

endinterface
