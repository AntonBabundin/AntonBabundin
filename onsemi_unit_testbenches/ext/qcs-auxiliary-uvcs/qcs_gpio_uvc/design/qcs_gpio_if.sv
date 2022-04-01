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
interface qcs_gpio_if #(parameter int WIDTH = -1) ();

    wire [WIDTH-1:0] gpio;

    //---- modports
    modport mp_initiator (
        output gpio
    );
    //----
    modport mp_monitor (
        input gpio
    );

endinterface
