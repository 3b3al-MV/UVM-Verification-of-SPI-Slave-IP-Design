class spi_scoreboard extends uvm_scoreboard;
  
  `uvm_component_utils(spi_scoreboard)
  
  //Analysis import declaration
  uvm_analysis_imp#(spi_seq_item, spi_scoreboard) mon_imp;
    
  //Constructor
  function new(string name, uvm_component parent);
    super.new(name,parent);
    mon_imp = new("mon_imp", this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
  //Write function implemetation
  function void write(spi_seq_item trans);
    `uvm_info("SPI_SCOREBOARD",$sformatf("------::TRANSACTION DETAILS:: ------"),UVM_LOW)
    `uvm_info("",$sformatf("i_TX_Byte:%0h i_TX_DV:%0h",trans.i_TX_Byte,trans.i_TX_DV),UVM_LOW)
    `uvm_info("",$sformatf("o_RX_DV:%0h o_RX_Byte:%0h",trans.o_RX_DV,trans.o_RX_Byte),UVM_LOW)
    `uvm_info("",$sformatf("o_SPI_MISO:%0h ",trans.o_SPI_MISO),UVM_LOW)
    `uvm_info("",$sformatf("i_SPI_MOSI:%0h ",trans.i_SPI_MOSI),UVM_LOW)
    `uvm_info("",$sformatf("i_SPI_CS_n:%0h ",trans.i_SPI_CS_n),UVM_LOW)
  endfunction 
        
endclass
        