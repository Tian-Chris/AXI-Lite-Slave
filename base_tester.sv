import uvm_pkg::*;
`include "uvm_macros.svh"
import axi_test_pkg::*;
    
class base_tester extends uvm_component;
    `uvm_component_utils(base_tester)

    virtual axi_lite_if axi_if;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual axi_lite_if)::get(null, "*", "axi_if", axi_if)) begin
            $fatal(1, "Failed to get axi_if");
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        axi_if.reset();
        repeat (1000) begin
            run_test();   
        end
        #50;
        phase.drop_objection(this);
    endtask

    virtual task run_test();
    endtask
endclass
