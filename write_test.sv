class write_test extends base_test;
    `uvm_component_utils(full_test);
    write_sequence w_seq;

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info("WRITE TEST STARTED", UVM_MEDIUM)
        for (i = 0; i<1000; i=i+1) begin
            w_seq = new("w_seq");
            w_seq.start(null);
        end
        phase.drop_objection(this);
    endtask

    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction
endclass