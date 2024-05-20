`include "uvm_macros.svh"

class spi_monitor extends uvm_monitor;

   `uvm_component_utils(spi_monitor)

   // Virtual interface to interact with SPI Slave DUT
   virtual spi_interface vif;

   // Analysis port declaration
   uvm_analysis_port#(spi_seq_item) ap;

   // Constructor
   function new(string name, uvm_component parent);
      super.new(name, parent);
      ap = new("ap", this);
   endfunction

   // Build phase
   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual spi_interface)::get(this, "", "vif", vif))
         `uvm_error("build_phase", "No virtual interface specified for this monitor instance");
   endfunction

   // Run phase
   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);

      // Main monitoring loop
      forever begin
         spi_seq_item trans = new(); // Create new transaction

         // Wait for load signal to be asserted
         wait(vif.i_TX_DV );

         // Capture input data when load signal is asserted
         trans.i_TX_Byte = vif.i_TX_Byte;

         // Wait for load signal to be de-asserted
         wait(!vif.i_TX_DV );

         // Wait for clock edges to complete shifting
         repeat (8) begin
            @(negedge vif.driver_cb.i_Clk);
         end

         // Wait for read signal to be asserted
         wait(vif.o_RX_DV);

         // Capture output data when read signal is asserted
         trans.o_RX_Byte = vif.o_RX_Byte;

         // Write captured transaction to analysis port
         ap.write(trans);
      end
   endtask

endclass
