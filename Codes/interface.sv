
//SPI interface

interface spi_interface(input logic i_Clk,i_SPI_Clk,reset);
  logic o_RX_DV,i_TX_DV;
  logic o_SPI_MISO;
  logic i_SPI_MOSI,i_SPI_CS_n;
  logic [7:0] o_RX_Byte,i_TX_Byte;
  
  
  
  clocking driver_cb @(posedge i_Clk);
    default input #0 output #0;
    output  i_TX_DV;
    output  i_TX_Byte;
    output  i_SPI_MOSI;
    output  i_SPI_CS_n;
    input   o_RX_DV;
    input   o_RX_Byte;
    input   o_SPI_MISO;
  endclocking
  
  clocking monitor_cb @(posedge i_Clk);
    default input #0 output #0;
    input  i_TX_DV;
    input  i_TX_Byte;
    input  i_SPI_MOSI;
    input  i_SPI_CS_n;
    input   o_RX_DV;
    input   o_RX_Byte;
    input   o_SPI_MISO;
  endclocking
  
  modport DRIVER  (clocking driver_cb,input i_Clk,i_SPI_Clk,reset);
  modport MONITOR (clocking monitor_cb,input i_Clk,i_SPI_Clk,reset);
  
endinterface
