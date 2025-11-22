class multi_read_sequence extends uvm_sequence #(axi_transaction);
    `uvm_object_utils(read_sequence);

    axi_transaction cmd;
    axi_transaction written_addr[$];
    rand int num_reads;

    constraint num_reads_range { num_reads inside {[1:10]}; }

    function new(string name = "read_sequence");
        super.new(name);
    endfunction

    task body();
        assert(randomize()) else
            `uvm_error("RAND_FAIL","Failed to randomize num_reads");
        `uvm_info("READ_MULTI", $sformatf("Sequence will run %0d reads", num_reads), UVM_HIGH)

        for (int i = 0; i < num_reads; i++) begin
            cmd = axi_transaction::type_id::create("cmd");
            start_item(cmd);
            cmd.random_write();
            written_addr.push_back(cmd.get_copy());
            finish_item(cmd);
        end
        for (int i = 0; i < num_reads; i++) begin
            written_addr[i].set_read();
            start_item(written_addr[i]);
            finish_item(written_addr[i]);
            `uvm_info("READ_MULTI", $sformatf("read %0d: %s", i, written_addr[i].convert2string()), UVM_HIGH)
        end
    endtask
endclass
