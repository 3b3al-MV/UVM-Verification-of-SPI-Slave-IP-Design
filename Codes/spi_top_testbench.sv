import uvm_pkg::*;
`include "uvm_macros.svh"
`include "spi_seq_item.sv"
`include "spi_sequence.sv"
`include "spi_sequencer.sv"
`include "spi_driver.sv"
`include "interface.sv"
`include "spi_monitor.sv"
`include "spi_agent.sv"
`include "spi_scoreboard.sv"
`include "spi_enviroment.sv"
`include "spi_test.sv"
`include "design.sv"

module top_tb;
  
  bit i_Clk;
  bit i_SPI_Clk;
  bit reset;
  parameter mode = 0;
  always #5 i_Clk= ~i_Clk;//clock of fpga
  always #20 i_SPI_Clk = ~i_SPI_Clk;// clock of spi

  initial begin
    reset = 0;
    #20 reset =1;
  end
  
  spi_interface intf(i_Clk,i_SPI_Clk,reset);

  SPI_Slave #(.SPI_MODE(mode))dut(
  .i_Rst_L(reset),
  .i_Clk(i_Clk),
  .o_RX_DV(intf.o_RX_DV),
  .o_RX_Byte(intf.o_RX_Byte),
  .i_TX_DV(intf.i_TX_DV),
  .i_TX_Byte(intf.i_TX_Byte),
  .i_SPI_Clk(i_SPI_Clk),
  .o_SPI_MISO(intf.o_SPI_MISO),
  .i_SPI_MOSI(intf.i_SPI_MOSI),
  .i_SPI_CS_n(intf.i_SPI_CS_n));

   initial begin 
      uvm_config_db#(virtual spi_interface)::set(uvm_root::get(),"*","vif",intf);
      //enable wave dump
      $dumpfile("dump.vcd"); 
      $dumpvars;
    end
  
  //calling test
  initial begin 
    run_test("spi_test");
  end
  
  covergroup SPI_COV @(posedge i_Clk);
	c1: coverpoint intf.o_RX_DV;
	c2: coverpoint intf.i_TX_DV;
	c3: coverpoint intf.i_SPI_CS_n;
	c4: coverpoint intf.i_SPI_MOSI;
	c5: coverpoint i_SPI_Clk;
	c6: coverpoint intf.o_SPI_MISO;
  endgroup : SPI_COV
  
  SPI_COV cover_inst = new();

endmodule
