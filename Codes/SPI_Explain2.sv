// SPI Slave Module Documentation

// Module Overview
/*
    The SPI_Slave module implements a SPI (Serial Peripheral Interface) Slave. 
    It communicates with a SPI Master by receiving and sending bytes of data over the SPI bus. 
    The module is parameterized to support different SPI modes (0, 1, 2, or 3).

# Parameters"
- SPI_MODE: Specifies the SPI mode (0, 1, 2, or 3), which determines the clock polarity (CPOL) and clock phase (CPHA).

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
SPI mode	Clock polarity  Clock phase     Data is shifted out on	                    Data is sampled on
                (CPOL)	      (CPHA)	
    0	        0	            0	            falling SCLK, and when CS activates	        rising SCLK
    1	        0	            1	            rising SCLK	                                falling SCLK
    2	        1	            0	            rising SCLK, and when CS activates	        falling SCLK
    3	        1	            1	            falling SCLK	                            rising SCLK
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

# Ports:
- Control/Data Signals:
  - i_Rst_L: Active low reset signal for the FPGA.
  - i_Clk: FPGA clock signal.
  - o_RX_DV: Data valid pulse indicating that a byte has been received on the MOSI line.
  - o_RX_Byte: Byte received on the MOSI line.
  - i_TX_DV: Data valid pulse indicating that a byte is ready to be sent on the MISO line.
  - i_TX_Byte: Byte to be sent on the MISO line.

- SPI Interface:
  - i_SPI_Clk: SPI clock signal from the master.
  - o_SPI_MISO: SPI data output (MISO) line.
  - i_SPI_MOSI: SPI data input (MOSI) line.
  - i_SPI_CS_n: SPI chip select (active low) signal.

# Internal Signals and Registers:
- SPI Mode Signals:
  - w_CPOL: Clock polarity, derived from SPI_MODE.
  - w_CPHA: Clock phase, derived from SPI_MODE.
  - w_SPI_Clk: Adjusted SPI clock based on the CPHA setting.
  - w_SPI_MISO_Mux: MUX signal to select MISO data.

- Receive Path Signals:
  - r_RX_Bit_Count: Counter to keep track of received bits.
  - r_TX_Bit_Count: Counter to keep track of transmitted bits.
  - r_Temp_RX_Byte: Temporary register to store received bits.
  - r_RX_Byte: Register to store the complete received byte.
  - r_RX_Done, r2_RX_Done, r3_RX_Done: Flags for byte received status, used for clock domain crossing.
  - r_TX_Byte: Register to store the byte to be transmitted from slave to master.
  - r_SPI_MISO_Bit, r_Preload_MISO: Registers for MISO data and preload control.

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Detailed Description of the Logic:

1- Clock Polarity and Phase Assignment
    assign w_CPOL  = (SPI_MODE == 2) | (SPI_MODE == 3);
    assign w_CPHA  = (SPI_MODE == 1) | (SPI_MODE == 3);
    assign w_SPI_Clk = w_CPHA ? ~i_SPI_Clk : i_SPI_Clk;

- w_CPOL and w_CPHA are set based on the SPI_MODE parameter.
- w_SPI_Clk is adjusted according to CPHA, either inverting the SPI clock or not.

// -------------------------------------------------------------------------------------------------------------------

2- SPI Byte Reception:
    always @(posedge w_SPI_Clk or posedge i_SPI_CS_n) begin
        if (i_SPI_CS_n)
        begin
            r_RX_Bit_Count <= 0;
            r_RX_Done      <= 1'b0;
        end
        else begin
            r_RX_Bit_Count <= r_RX_Bit_Count + 1;

            // input data to slave
            r_Temp_RX_Byte <= {r_Temp_RX_Byte[6:0], i_SPI_MOSI};
            
            if (r_RX_Bit_Count == 3'b111) begin
            r_RX_Done <= 1'b1;
            r_RX_Byte <= {r_Temp_RX_Byte[6:0], i_SPI_MOSI};
            end

            // Setting r_RX_Done to 0 at an early bit count like 3'b010 
            // ensures that it doesn’t prematurely signal the completion of 
            // a byte reception during the intermediate states of bit reception.
            else if (r_RX_Bit_Count == 3'b010) begin
            r_RX_Done <= 1'b0;        
            end
        end
    end

- When i_SPI_CS_n is high, the module resets the receive bit count and done flag.
- When i_SPI_CS_n is low, it shifts in the MOSI data on each clock edge, forming a byte.
- When 8 bits are received, r_RX_Done is set, and r_RX_Byte is updated with the received byte.

// -------------------------------------------------------------------------------------------------------------------

This block of code is responsible for synchronizing signals and crossing clock domains 
from the SPI clock domain to the FPGA clock domain:

# Signals and Variables:
- i_Rst_L: Input signal for FPGA reset. It's active low.
- i_Clk: Input signal for the FPGA clock.
- r_RX_Done: Signal indicating the completion of receiving a byte in the SPI clock domain.
- r2_RX_Done and r3_RX_Done: Registers used for synchronizing r_RX_Done from the SPI clock domain to the FPGA clock domain.
- o_RX_DV: Output signal indicating the availability of a new byte in the FPGA clock domain.
- o_RX_Byte: Output signal representing the byte received on the MOSI line.

Functionality:

1. Reset Handling:
   - Upon reset (i_Rst_L is low), all relevant signals and registers are reset to their initial values.
   - r2_RX_Done and r3_RX_Done are set to 0.
   - o_RX_DV is cleared to 0, indicating no new byte is available.
   - o_RX_Byte is set to 0, representing no valid byte data.

2. Clock Domain Crossing:
   - When not in reset, r_RX_Done is synchronized to the FPGA clock domain by passing it through two flip-flops (r2_RX_Done and r3_RX_Done).
   - r2_RX_Done is updated with the value of r_RX_Done.
   - r3_RX_Done is updated with the value of r2_RX_Done.
   
3. Data Valid Assertion:
   - The block checks if the synchronized signal (r3_RX_Done) is transitioning from low to high, indicating the completion of receiving a byte.
   - If the transition occurs, o_RX_DV is asserted high (1'b1) for one clock cycle, indicating that a new byte is available.
   - At the same time, the received byte (r_RX_Byte) is assigned to o_RX_Byte, making it available for use by the receiving system outside the SPI module.

This block ensures that the received data is synchronized to the main FPGA clock domain and that the system is notified when a new byte is available for processing.


3- Crossing Clock Domains for Received Byte:
    always @(posedge i_Clk or negedge i_Rst_L) begin
        if (~i_Rst_L) begin
            r2_RX_Done <= 1'b0;
            r3_RX_Done <= 1'b0;
            o_RX_DV    <= 1'b0;
            o_RX_Byte  <= 8'h00;
        end
        else begin
            r2_RX_Done <= r_RX_Done;
            r3_RX_Done <= r2_RX_Done;
            
            if (r3_RX_Done == 1'b0 && r2_RX_Done == 1'b1) begin
                o_RX_DV   <= 1'b1;
                o_RX_Byte <= r_RX_Byte;
            end
            else begin
                o_RX_DV <= 1'b0;
            end
        end
    end

- This block handles the clock domain crossing from SPI clock to FPGA clock.
- It asserts o_RX_DV for one clock cycle when a new byte is available.

// -------------------------------------------------------------------------------------------------------------------

This block of code controls the r_Preload_MISO signal, 
which determines whether to preload the MISO (Master In Slave Out) line with the top bit of the send data.
# Signals and Variables:

- w_SPI_Clk: Clock signal for the SPI interface.
- i_SPI_CS_n: Chip Select signal for the SPI interface.
- r_Preload_MISO: Register controlling whether to preload the MISO line.

# Functionality:

1. Edge Sensitivity:
   - The sensitivity list of the always block includes a negative edge of w_SPI_Clk\
    and a positive edge of i_SPI_CS_n. 
    This means the block is triggered on the falling edge of w_SPI_Clk and the rising edge of i_SPI_CS_n.

2. Control of Preload Signal:
   - When i_SPI_CS_n is high (inactive), indicating no communication is occurring, r_Preload_MISO is set to 1 (1'b1). This sets the preload signal high, indicating that the MISO line should be preloaded with data.
   - When i_SPI_CS_n transitions low (active), indicating the start of communication, r_Preload_MISO is cleared to 0 (1'b0). This happens on the first clock edge after i_SPI_CS_n goes low. This ensures that the preload signal is active only for the duration of the CS low phase.

This mechanism ensures that the MISO line is prepared with the appropriate data when communication begins, and it synchronizes this action with the SPI clock to ensure proper timing.

# Control Preload Signal:
    always @(negedge w_SPI_Clk or posedge i_SPI_CS_n) begin
        if (i_SPI_CS_n) begin
            r_Preload_MISO <= 1'b1;
        end
        else begin
            r_Preload_MISO <= 1'b0;
        end
    end

- r_Preload_MISO is set to 1 when i_SPI_CS_n is high and goes low on the first clock edge after i_SPI_CS_n goes low.

// -------------------------------------------------------------------------------------------------------------------

# SPI Byte Transmission:
    always @(negedge w_SPI_Clk or posedge i_SPI_CS_n) begin
        if (i_SPI_CS_n) begin
            r_TX_Bit_Count <= w_CPHA ? 3'b111 : 3'b110;
            r_SPI_MISO_Bit <= r_TX_Byte[3'b111];
        end
        else begin
            r_TX_Bit_Count <= r_TX_Bit_Count - 1;
            r_SPI_MISO_Bit <= r_TX_Byte[r_TX_Bit_Count];
        end
    end

- When i_SPI_CS_n is high, the transmit bit count is reset, and r_SPI_MISO_Bit is loaded with the MSB of r_TX_Byte.
- When i_SPI_CS_n is low, the transmit bit count decrements on each clock edge, and r_SPI_MISO_Bit is updated with the next bit to be transmitted.

// -------------------------------------------------------------------------------------------------------------------

# Registering TX Byte:
    always @(posedge i_Clk or negedge i_Rst_L) begin
        if (~i_Rst_L) begin
            r_TX_Byte <= 8'h00;
        end
        else begin
            if (i_TX_DV) begin
                r_TX_Byte <= i_TX_Byte; 
            end
        end
    end

- This block registers the byte to be transmitted when i_TX_DV is asserted.

// -------------------------------------------------------------------------------------------------------------------

# Preload and Tri-state MISO:

assign w_SPI_MISO_Mux = r_Preload_MISO ? r_TX_Byte[3'b111] : r_SPI_MISO_Bit;
assign o_SPI_MISO = i_SPI_CS_n ? 1'bZ : w_SPI_MISO_Mux;

- w_SPI_MISO_Mux selects the MISO data based on r_Preload_MISO.
- o_SPI_MISO is tri-stated when i_SPI_CS_n is high, allowing multiple slaves to share the MISO line.