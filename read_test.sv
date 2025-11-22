class read_test extends base_test;
    `uvm_component_utils(read_test);
    read_sequence r_seq;

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info("READ TEST", "READ TEST STARTED", UVM_MEDIUM)
        for (int i = 0; i<1000; i=i+1) begin
            r_seq = new("r_seq");
            r_seq.start(null);
        end
        phase.drop_objection(this);
    endtask

    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction
endclass