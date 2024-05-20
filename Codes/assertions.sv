// Assertions

// Assertion: After reset, outputs are in a known state
property reset_check;
  @(negedge i_Rst_L) 1'b1 |-> @(posedge i_Clk) (!o_RX_DV && o_RX_Byte == 8'h00);
endproperty

// Assertion: When data valid is asserted, output ready is deasserted
// ==> This is typically done to avoid data collision or other synchronization issues when both sending and receiving data simultaneously.
// when trasmitting data, the receiving data valid bit should be deasserted
property DV_Ready;
  @(posedge i_Clk) disable iff (!i_Rst_L) i_TX_DV |-> !o_RX_DV;
endproperty

// Assertion: When data valid is asserted, chip select goes low
property DV_CS;
  @(posedge i_Clk) disable iff (!i_Rst_L) i_TX_DV |-> !i_SPI_CS_n;
endproperty

// Assertion: When chip select goes low, it stays low for 34 cycles and then goes up
// it may be incorrect
property CS_low_for34cycles;
  @(posedge i_Clk) disable iff (!i_Rst_L) $fell(i_SPI_CS_n) |-> !i_SPI_CS_n [*34] ##1 i_SPI_CS_n;
endproperty

// Assertion: Data sampled is valid in SPI_MODE 0 and 2
// Here CPHA is 0, so data is sampled on the rising edge of the clock
// MAY BE INCORRECT
property CS_low_knownstate_02;
  @(posedge i_SPI_Clk) disable iff (!i_Rst_L || (SPI_MODE == 1 || SPI_MODE == 3)) (!$isunknown(i_SPI_MOSI) && !$isunknown(o_SPI_MISO));
endproperty

// Assertion: Data sampled is valid in SPI_MODE 1 and 3
// may be incorrect
property CS_low_knownstate_13;
  @(negedge i_SPI_Clk) disable iff (!i_Rst_L || (SPI_MODE == 0 || SPI_MODE == 2)) (!$isunknown(i_SPI_MOSI) && !$isunknown(o_SPI_MISO));
endproperty

// Assertion: When chip select is low, SPI clock switches 8 times during which cs will stay low
property SPI_CLK_8edges;
  @(posedge i_Clk) disable iff (!i_Rst_L) $fell(i_SPI_CS_n) |-> ($rose(i_SPI_Clk) [=8]) within (!i_SPI_CS_n);
endproperty

// Assertions checks
    assert property (reset_check) 
    else $error("Reset check failed");

    assert property (DV_Ready) 
    else $error("DV Ready check failed");

    assert property (DV_CS) 
    else $error("DV CS check failed");

    assert property (CS_low_for34cycles) 
    else $error("CS low for 34 cycles check failed");

    assert property (CS_low_knownstate_02) 
    else $error("CS low known state 0 and 2 check failed");

    assert property (CS_low_knownstate_13) 
    else $error("CS low known state 1 and 3 check failed");

    assert property (SPI_CLK_8edges) 
    else $error("SPI clock 8 edges check failed");
