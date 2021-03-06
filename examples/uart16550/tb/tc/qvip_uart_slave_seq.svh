class qvip_uart_slave_seq extends qvip_uart_base_seq;
   `uvm_object_utils(qvip_uart_slave_seq )

   function new( string name = "" );
      super.new( name );
   endfunction // new
   
   task body();
      rx_data_char_t rx_data_char = rx_data_char_t::type_id::create("rx_data_char");
      super.body();

      `uvm_info(get_type_name(),"Starting to receive on RX",UVM_MEDIUM);
      forever begin
	 start_item(rx_data_char );
	 finish_item(rx_data_char );
	 `uvm_info(get_type_name(), {"Received Data char: \n", rx_data_char.sprint()}, UVM_MEDIUM );
      end
   endtask // body
endclass // qvip_uart_slave_seq

