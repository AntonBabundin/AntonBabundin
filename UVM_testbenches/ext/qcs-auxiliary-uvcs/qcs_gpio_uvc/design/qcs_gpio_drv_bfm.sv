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
interface qcs_gpio_drv_bfm #(parameter int WIDTH = -1) (
    qcs_gpio_if.mp_initiator port
);
//------------------------------------------------------------------------------
//---- parameters
//------------------------------------------------------------------------------
    import qcs_gpio_pkg::QCS_GPIO_UVC_MAX_WIDTH,
           qcs_gpio_pkg::bfm_drv_rqst_trn_t;

//------------------------------------------------------------------------------
//---- variables
//------------------------------------------------------------------------------
    logic [WIDTH-1:0] gpio_out;//into the chip

//------------------------------------------------------------------------------
//---- logic
//------------------------------------------------------------------------------
    //---- check parameters
    initial begin
        CHECK_PARAM_LIMIT: assert (WIDTH <= QCS_GPIO_UVC_MAX_WIDTH)
        else $fatal(0, $sformatf("Maximum possible width = %0d, but current width = %0d exceeds the limit \n", QCS_GPIO_UVC_MAX_WIDTH, WIDTH));
    end

    //----
    assign port.gpio = gpio_out;

//------------------------------------------------------------------------------
//---- tasks and functions
//------------------------------------------------------------------------------
    //---- set default statements
    task set_dflt_if();
        gpio_out = 'z;
    endtask: set_dflt_if

    //---- drive transaction
    task drive(bfm_drv_rqst_trn_t rqst);
        for (int i=0; i < WIDTH; i++) begin
            if (rqst.set[i])        gpio_out[i] = '1;
            else if (rqst.clear[i]) gpio_out[i] = '0;
        end
    endtask: drive

endinterface
