class seq_read_sequence extends uvm_sequence #(axi_transaction); //sequential
    `uvm_object_utils(read_sequence);

    axi_transaction cmd;
    rand int num_reads;
    int initial_addr;

    constraint num_reads_range { num_reads inside {[1:10]}; }

    function new(string name = "read_sequence");
        super.new(name);
    endfunction

    task body();
        assert(randomize()) else
            `uvm_error("RAND_FAIL","Failed to randomize num_reads");
        `uvm_info("READ_MULTI", $sformatf("Sequence will run %0d reads", num_reads), UVM_HIGH)

        `uvm_info("READ_SEQ", $sformatf("Sequence will run %0d writes", num_writes), UVM_HIGH)
        cmd = axi_transaction::type_id::create("cmd");
        start_item(cmd);
        cmd.random_write();
        initial_addr = cmd.addr;
        finish_item(cmd);
        `uvm_info("READ_SEQ", $sformatf("Write %0d: %s", i, cmd.convert2string()), UVM_HIGH)
        for (int i = 0; i < num_writes; i++) begin
            cmd = axi_transaction::type_id::create("cmd");
            start_item(cmd);
            cmd.random_write();
            cmd.addr = initial_addr + 4 * (i + 1);
            finish_item(cmd);
            `uvm_info("READ_SEQ", $sformatf("Write %0d: %s", i, cmd.convert2string()), UVM_HIGH)
        end
        for (int i = 0; i < num_writes + 1; i++) begin
            cmd = axi_transaction::type_id::create("cmd");
            start_item(cmd);
            cmd.random_read();
            cmd.addr = initial_addr + 4 * i;
            finish_item(cmd);
            `uvm_info("READ_SEQ", $sformatf("READ %0d: %s", i, cmd.convert2string()), UVM_HIGH)
        end
    endtask
endclass
