class single_test extends uvm_test;
    `uvm_component_utils(single_test);
    env env_h;
    
    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        single_tester::type_id::set_type_override(single_tester::get_type());
        env_h = env::type_id::create("env_h",this);
    endfunction
endclass
    