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
//---- parameters
//---- types
//---- clases
interface class chkp_probe_collector #(type D_T = logic);
  pure virtual task catch_simple(output D_T sample);
endclass: chkp_probe_collector

//---- general reports
parameter string QCS_CHKP_PROBE_RPTS = "";