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
class tb_checkin_sq extends base_sq;
    `uvm_object_utils(tb_checkin_sq)

    extern function      new(string name = "tb_checkin_sq");
    extern task          body();

endclass

function tb_checkin_sq::new(string name = "tb_checkin_sq");
    super.new (name);
endfunction: new

task tb_checkin_sq :: body();
    `uvm_info(get_name(), "Starting", local_vrb_lvl)
    fork
        begin
            generate_rst0(10*GENERATOR_CLK_PERIOD);
            #1000ns;
        end
        set_clk0(GENERATOR_CLK_PERIOD);
    join
    #1000ns;
endtask : body

