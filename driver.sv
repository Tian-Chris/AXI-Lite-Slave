class driver extends uvm_driver #(axi_transaction);
   `uvm_component_utils(driver)
   virtual axi_lite_if axi_if;
 
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual axi_lite_if)::get(null, "*","axi_if", axi_if))
            `uvm_fatal("DRIVER", "Failed to get axi_if")
    endfunction
    task run_phase(uvm_phase phase);
        axi_transaction cmd;
        forever begin
            seq_item_port.get_next_item(cmd);
            axi_if.do_op(cmd.data, cmd.addr, cmd.op);
            seq_item_port.item_done();
        end
    endtask 
    
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass