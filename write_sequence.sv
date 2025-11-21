class write_sequence extends uvm_sequence #(axi_transaction);
    `uvm_object_utils(write_sequence);
    axi_transaction cmd;

    function new(string name = "short_random_sequence");
        super.new(name);
    endfunction
    
    task body();
        cmd = axi_transaction::type_id::create("cmd");
        start_item(cmd);
        cmd.random_write();
        finish_item(cmd);
        `uvm_info("WRITE", $sformatf("write test: %s", command.convert2string), UVM_HIGH)
    endtask 
endclass