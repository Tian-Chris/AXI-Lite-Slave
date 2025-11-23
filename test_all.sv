class test_all extends base_test;
    `uvm_component_utils(test_all);
    write_sequence w_seq;
    read_sequence r_seq;
    multi_write_sequence mw_seq;
    multi_read_sequence mr_seq;
    seq_write_sequence seq_write_seq;
    seq_read_sequence seq_read_seq;

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info("RUN ALL TEST", "STARTED", UVM_LOW)
        
        `uvm_info("RUN ALL TEST", "WRITE STARTED", UVM_MEDIUM)
        for (int i = 0; i<250; i=i+1) begin
            w_seq = new("w_seq");
            w_seq.start(sequencer_h);
        end

        `uvm_info("RUN ALL TEST", "READ STARTED", UVM_MEDIUM)
        for (int i = 0; i<250; i=i+1) begin
            r_seq = new("r_seq");
            r_seq.start(sequencer_h);
        end

        `uvm_info("RUN ALL TEST", "WRITE MULT STARTED", UVM_MEDIUM)
        for (int i = 0; i<250; i=i+1) begin
            mw_seq = new("mw_seq");
            mw_seq.start(sequencer_h);
        end

        `uvm_info("RUN ALL TEST", "READ MULT STARTED", UVM_MEDIUM)
        for (int i = 0; i<250; i=i+1) begin
            mr_seq = new("mr_seq");
            mr_seq.start(sequencer_h);
        end

        `uvm_info("RUN ALL TEST", "SEQ WRITE STARTED", UVM_MEDIUM)
        for (int i = 0; i<250; i=i+1) begin
            seq_write_seq = new("seq_write_seq");
            seq_write_seq.start(sequencer_h);
        end

        `uvm_info("RUN ALL TEST", "SEQ READ STARTED", UVM_MEDIUM)
        for (int i = 0; i<250; i=i+1) begin
            seq_read_seq = new("seq_read_seq");
            seq_read_seq.start(sequencer_h);
        end

        phase.drop_objection(this);
    endtask

    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction
endclass