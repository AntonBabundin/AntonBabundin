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
interface qcs_gpio_mon_bfm #(parameter int WIDTH = -1) (
    qcs_gpio_if.mp_monitor port
);
//------------------------------------------------------------------------------
//---- parameters
//------------------------------------------------------------------------------
    import qcs_gpio_pkg::QCS_GPIO_UVC_MAX_WIDTH,
           qcs_gpio_pkg::bfm_mon_trn_t;

//------------------------------------------------------------------------------
//---- variables
//------------------------------------------------------------------------------
    event               e_start;
    event               e_resp;
    bfm_mon_trn_t       trn;
    //----
    wire [WIDTH-1:0]    gpio_in;
    logic [WIDTH-1:0]   gpio_prev_state;

//------------------------------------------------------------------------------
//---- clocking blocks
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//---- logic
//------------------------------------------------------------------------------
    //---- check parameters
    initial begin
        CHECK_PARAM_LIMIT: assert (WIDTH <= QCS_GPIO_UVC_MAX_WIDTH)
        else $fatal(0, $sformatf("Maximum possible width = %0d, but current width = %0d exceeds the limit \n", QCS_GPIO_UVC_MAX_WIDTH, WIDTH));
    end

    //----
    initial begin
        @e_start;
        gpio_prev_state = gpio_in;
        forever sample();
    end

    //----
    assign gpio_in = port.gpio;

//------------------------------------------------------------------------------
//---- tasks and functions
//------------------------------------------------------------------------------
    //----
    function void start();
      -> e_start;
    endfunction

    //----
    task sample();
        @(gpio_in);
        foreach (trn.set[i]) begin
            trn.set[i] = (gpio_in[i] && gpio_prev_state[i] !== '1) ? '1 : '0;
        end
        foreach (trn.clear[i]) begin
            trn.clear[i] = (!gpio_in[i] && gpio_prev_state[i] !== '0) ? '1 : '0;
        end
        trn.raw_data = gpio_in;
        gpio_prev_state = gpio_in;
        -> e_resp;
    endtask: sample

    //wait until intrface state changes
    function bfm_mon_trn_t get_values();
        return(trn);
    endfunction : get_values

endinterface
