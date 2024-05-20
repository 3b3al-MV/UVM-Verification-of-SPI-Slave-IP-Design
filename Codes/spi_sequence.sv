
//SPI Sequence

class spi_sequence extends uvm_sequence#(spi_seq_item);
  
  `uvm_object_utils(spi_sequence)
  
  //Constructor
  function new(string name = "spi_sequence");
    super.new(name);
  endfunction
  
  //Randomizing sequence item
  task body();
    spi_seq_item seq;
    repeat(1000)begin
      seq=new();
      
      start_item(seq);
      assert(seq.randomize());
      finish_item(seq);
    end
  endtask
  
/*covergroup cvr ;
        // Define the coverage points for cross coverage
        i_Rst_L:coverpoint seq.i_Rst_L;
        o_RX_DV:coverpoint seq.o_RX_DV;
  //    o_RX_Byte:coverpoint seq.o_RX_Byte;
        i_TX_DV:coverpoint seq.i_TX_DV;
  //    i_TX_Byte:coverpoint seq.i_TX_Byte;
  //	o_SPI_MISO:coverpoint seq.o_SPI_MISO;
  //     i_SPI_MOSI:coverpoint seq.i_SPI_MOSI;
        i_SPI_CS_n:coverpoint seq.i_SPI_CS_n;
        
    endgroup
*/   
endclass
