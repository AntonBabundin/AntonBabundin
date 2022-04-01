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
// to use this probe create a module where use the 'bind' command, for example:
//
// bind alu
// qcs_chkp_probe_if #(.ID("CHKP_OP"), .DATA_T(wire), .DATA_T(wire [15:0]))
// if_chkp (.rst(rst), .clk(clk), .valid(done_o), .data(result_o));
//------------------------------------------------------------------------------
interface qcs_chkp_probe_if #(
  parameter string  ID      = "CHKP_DEFAULT",
  parameter type    VALID_T = logic,
  parameter type    DATA_T  = logic
)
(
  input wire    rst,
  input wire    clk,
  input VALID_T valid,
  input DATA_T  data
);

  //---- uvm components
  import    uvm_pkg::*;
  `include  "uvm_macros.svh"
  import    qcs_chkp_probe_pkg::*;

  //----
  class collector #(type D_T = logic) implements chkp_probe_collector #(D_T);
    extern virtual task catch_simple(output D_T sample);
  endclass

  //----
  collector #(DATA_T) probe;

  //----
  initial begin
    probe = new();
    uvm_config_db #(chkp_probe_collector #(DATA_T))::set(null, "*m_env*", ID, probe);
  end

  //----
  task collector::catch_simple(output D_T sample);
    // @(posedge clk);
    // while(!valid) @(posedge clk);
    wait (valid);
    sample = data;
    wait (!valid);
  endtask: catch_simple

endinterface
