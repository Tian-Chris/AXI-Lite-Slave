class command_monitor extends uvm_component;
    `uvm_component_utils(command_monitor);
    uvm_analysis_port #(axi_transaction) ap;

    function void write_to_monitor(axi_transaction cmd);
        axi_transaction copy;
        copy = cmd.get_copy();
        $display("COMMAND MONITOR: addr:0x%2h data:0x%2h op: %s", copy.addr, copy.data, copy.op.name());
        ap.write(copy);
    endfunction
    
    function void build_phase(uvm_phase phase);
        virtual axi_lite_if axi_if;
        if(!uvm_config_db #(virtual axi_lite_if)::get(null, "*","axi_if", axi_if)) begin
            $fatal(1, "Failed to get axi_if");
        end
        axi_if.command_monitor_h = this;
        ap = new("ap",this);
    endfunction
    
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass