library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
entity FPGA_Master is
Generic (
        CLK_FREQ    : natural := 250e6; -- set system clock frequency in Hz
        WORD_SIZE   : natural := 10;    -- size of transfer word in bits, must be power of two
        SLAVE_COUNT : natural := 1     -- count of SPI slaves
    );
port(
    -- CLOCK:
    clk_50: in std_logic; -- 50 MHz FPGA clock
 
 
    -- SPI SIGNALS:
    spi_sclk: out std_logic; -- communication clock
    spi_cs_n: out std_logic; -- chip select pin
    spi_dout: out std_logic; -- serial data out
	 spi_din:  in std_logic -- serial data in
);
end FPGA_Master;
 
architecture implementation of FPGA_Master is
 
    TYPE states is (start,first_edge,second_edge,Data_in,Data_out, finished);
 
    signal present_state : states := start; -- FSM state register
 
	 signal counter_data: integer:=0;
 
	 signal SCLK_Count: integer :=1; 
	 signal tmp: std_logic := '0'; --variable for data to sclk
	 signal D_inXY std_logic:= '0'; --Variable to toggle between X and Y measurement
	 signal data_X std_logic_vector(WORD_SIZE-1 downto 0); -- data for transmission to SPI slave
	 signal data_Y std_logic_vector(WORD_SIZE-1 downto 0); -- data for transmission to SPI slave


	 begin
 
 
    -- Generate postscaled_clk 
    POSTSCALER: process(clk_50)
        
    begin
        if rising_edge(clk_50) then
            SCLK_Count <= SCLK_Count+1;
				if SCLK_Count=(50) then
					tmp <= not tmp;
					SCLK_Count <=1;
				end if;
        end if;
		  spi_sclk <= tmp;
    end process POSTSCALER;
	 
	 -- PRESENT STATE REGISTER
    fsm_present_state_p : process (spi_sclk)
    begin
        if (falling_edge(spi_sclk)) then

                present_state <= next_state;

        end if;
    end process;

    -- NEXT STATE LOGIC
    fsm_next_state_p : process (spi_sclk,present_state)
    begin
	 
		 if (rising_edge(spi_sclk)) then --Occures every rising edge of spi_sclk
		 
		 
			  case present_state is
					when start =>
					
					next_state <= first_edge;
					
					when first_edge =>
					
						next_state <= second_edge;
						
						edge_count=1;

					when second_edge =>
						 
							edge_count <= 2;
							next_state <= Data_in;
							
					when Data_in =>

						if(edge_count = 7) then
						
							next_state <= Data_out;
						end if;
					
					when Data_out =>
						 
						edge_count = edge_count+1;
					 
						if (edge_count = 18) then
					 
							next_state <= finished;
					
					when finished => -- setting up for new cycle
						 
					 edge_count = 0; 
					 next_state <= start;
					

					when others =>
						 next_state <= start;
			  end case;
		 end if;
    end process;
	 
	 -- OUTPUTS LOGIC
    fsm_outputs_p : process (spi_sclk, present_state, counter_data, edge_count)
    begin
        
	if (rising_edge(spi_sclk)) then	  
		  
		  
		  case present_state is
            when start => -- Setting up ADC for reading
					
					CS <= '0';  -- ADC to begin
					D_out= <='1'; -- D_in to be set for Start Bit
					

            when first_edge =>  --First pulse since CS=0
					CS <= '0';
					D_out <='1'; --Start bit
					
            when second_edge =>
					
					CS <= '0';
					D_out <='1';   --"single" configuration
					
					
            when Data_out => 
				
					if (D_outXY = '0') then
						D_out <= '0'; -- ADC will read all 0's for Control Bits
						
					else
						D_out <= '1'; -- ADC will read all 1's for Control Bits

					end if;
					
					counter_data <= 0;
				
				when Data_in =>
					
				counter_data <= 17-edge_count;
				
				if (D_outXY = '0') then
							data_X(counter_data) <= D_in;
						else
							data_Y(counter_data) <= D_in;
				end if;
				
				when finish =>
				
				if (D_outXY = '0') then
							D_outXY <= '1';
						else
							D_outXY <= '0';
					end if;

		end case;
	 end if;
 end process;
	 
	 