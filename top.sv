module top ();
    import uvm_pkg::*;
    import   axi_test_pkg::*;
    `include "uvm_macros.svh"
    
    axi_lite_if    axi_if();
    axi_lite_slave DUT (.slave_if(axi_if), .dut_mem(axi_if.dut_mem));
    
    initial begin
        uvm_config_db #(virtual axi_lite_if)::set(null, "*", "axi_if", axi_if);
        run_test();
    end
endmodule