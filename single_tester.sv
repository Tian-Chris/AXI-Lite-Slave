class single_tester extends base_tester;
    `uvm_component_utils(single_tester)

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_test();
        byte addr = get_data();
        byte data = get_data();
        axi_lite_if.axi_write(addr, data, 4'hF);
        #50;
        axi_lite_if.axi_read(addr);
        #50;
    endtask

    function byte get_data();
        bit [7:0] zero_ones;
        zero_ones = $random;
        return zero_ones;
    endfunction
endclass
