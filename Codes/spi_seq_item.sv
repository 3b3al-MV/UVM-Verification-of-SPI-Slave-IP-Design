class spi_seq_item extends uvm_sequence_item;
  
  bit o_RX_DV;
  bit [7:0]o_RX_Byte;
  bit i_TX_DV;
  rand bit [7:0]i_TX_Byte;
  bit o_SPI_MISO;
  bit i_SPI_MOSI;
  bit i_SPI_CS_n;
  
  `uvm_object_utils_begin(spi_seq_item)
    `uvm_field_int(i_TX_Byte,UVM_ALL_ON)
  `uvm_object_utils_end
  
  function new(string name="spi_seq_item");
    super.new();
  endfunction
  
  function string convert2string();
    return $psprintf("i_TX_Byte=%0h",i_TX_Byte);
  endfunction
  
endclass