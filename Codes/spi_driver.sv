`include "uvm_macros.svh"

class spi_slave_driver extends uvm_driver#(spi_seq_item);

   `uvm_component_utils(spi_slave_driver)
   spi_seq_item trans;
   
   // Virtual interface to interact with SPI Slave DUT
   virtual spi_interface vif;

   // Constructor
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction

   // Build phase
   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual spi_interface)::get(this, "", "vif", vif))
         `uvm_error("build_phase", "driver virtual interface failed");
   endfunction

   // Run Phase
   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);     

   // Main driver loop
   forever begin
      // Get the next transaction from the sequencer
      seq_item_port.get_next_item(trans);

      // Assert chip select
      vif.driver_cb.i_SPI_CS_n <= 0;

      // Load data into SPI Slave
      vif.driver_cb.i_TX_DV <= 1;
      vif.driver_cb.i_TX_Byte <= trans.i_TX_Byte; // Load input data

      // Deassert data valid signal after loading data
      @(posedge vif.driver_cb.i_Clk);
      vif.driver_cb.i_TX_DV <= 0;

      // Simulate SPI data transfer with clock toggling
      for (int i = 0; i < 8; i++) begin
        @(negedge vif.i_SPI_Clk);
        vif.driver_cb.i_SPI_MOSI <= trans.i_TX_Byte[7-i];
      end

      // Deassert chip select after data transfer
      @(posedge vif.driver_cb.i_Clk);
      vif.driver_cb.i_SPI_CS_n <= 1;

      // Inform sequencer that item processing is done
      seq_item_port.item_done();
   end
   endtask

endclass
