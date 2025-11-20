class result_monitor extends uvm_component;
    `uvm_component_utils(result_monitor);
    uvm_analysis_port #(command_s) ap;

    function void write_to_monitor(byte addr, byte data, op_code op);
        command_s cmd;
        cmd.addr = addr;
        cmd.data = data;
        cmd.op   = op;
        $display("RESULT MONITOR: addr:0x%2h data:0x%2h op: %s", addr, data, op.name());
        ap.write(cmd);
    endfunction
    
    function void build_phase(uvm_phase phase);
        virtual axi_lite_if axi_if;
        if(!uvm_config_db #(virtual axi_lite_if)::get(null, "*","axi_if", axi_if))
            $fatal(1, "Failed to get axi_if");
        axi_if.result_monitor_h = this;
        ap = new("ap",this);
    endfunction
    
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

endclass