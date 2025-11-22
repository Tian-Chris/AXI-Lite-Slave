class read_sequence extends uvm_sequence #(axi_transaction);
    `uvm_object_utils(read_sequence);
    axi_transaction w_cmd;
    axi_transaction r_cmd;


    function new(string name = "short_random_sequence");
        super.new(name);
    endfunction
    
    task body();
        w_cmd = axi_transaction::type_id::create("cmd");
        start_item(w_cmd);
        w_cmd.random_write();
        r_cmd = w_cmd.get_copy();
        finish_item(w_cmd);
        start_item(r_cmd);
        r_cmd.set_read();
        finish_item(r_cmd);
        `uvm_info("READ", $sformatf("read test: %s", r_cmd.convert2string), UVM_HIGH)
    endtask 
endclass