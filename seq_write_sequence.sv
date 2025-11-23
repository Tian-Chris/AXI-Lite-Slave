class seq_write_sequence extends uvm_sequence #(axi_transaction); //sequential
    `uvm_object_utils(write_sequence);

    axi_transaction cmd;
    rand int num_writes;
    int initial_addr;

    constraint num_writes_range { num_writes inside {[1:10]}; }

    function new(string name = "write_sequence");
        super.new(name);
    endfunction

    task body();
        assert(num_writes.randomize()) else
            `uvm_error("RAND_FAIL","Failed to randomize num_writes");
        `uvm_info("WRITE_SEQ", $sformatf("Sequence will run %0d writes", num_writes), UVM_HIGH)
        cmd = axi_transaction::type_id::create("cmd");
        start_item(cmd);
        cmd.random_write();
        initial_addr = cmd.addr;
        finish_item(cmd);
        for (int i = 0; i < num_writes; i++) begin
            cmd = axi_transaction::type_id::create("cmd");
            start_item(cmd);
            cmd.random_write();
            cmd.addr = initial_addr + 4 * (i + 1);
            finish_item(cmd);
            `uvm_info("WRITE_MULTI", $sformatf("Write %0d: %s", i, cmd.convert2string()), UVM_HIGH)
        end
    endtask
endclass
