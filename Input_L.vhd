library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
entity Input_L is
Generic (
        WORD_SIZE   : natural := 10;    -- size of transfer word in bits, must be power of two
        SLAVE_COUNT : natural := 1     -- count of SPI slaves
    );
port(
    -- CLOCK:
    clk_5: in std_logic; -- 5 MHz FPGA clock
 
 
    -- SPI SIGNALS:
    spi_sclk: out std_logic; -- communication clock
    spi_cs_n: out std_logic; -- chip select pin
    spi_dout: out std_logic; -- serial data out
	 spi_din:  in std_logic; -- serial data in
	 
	 LED_1: out std_logic;  --LED assignation to test X and Y axis performance
	 LED_2: out std_logic;
	 LED_3: out std_logic;
	 LED_4: out std_logic
	 
);
end Input_L;
 
architecture implementation of Input_L is
 
    TYPE states is (start,first_edge,second_edge,Data_in,Data_out, finished);
 
    signal present_state : states := start; -- FSM states register
	 signal next_state : states := start; -- FSM states register
 
	 signal counter_data: integer:=0; --Counters to handle if transitions
	 signal edge_count: integer:=0;
 
	 signal SCLK_Count: integer :=1; 
	 signal tmp: std_logic := '0'; --variable for data to sclk
	 signal D_outXY: std_logic:= '0'; --Variable to toggle between X and Y measurement
	 signal data_X: std_logic_vector(WORD_SIZE-1 downto 0); -- data for transmission to SPI slave
	 signal data_Y: std_logic_vector(WORD_SIZE-1 downto 0); -- data for transmission to SPI slave
	 signal data_load_out : STD_LOGIC := '0';
	 
	 -- Inverted Signals
	 
	 signal not_sclk 	: STD_LOGIC := '0'; --inverted variables which handle the FPGA's nature of inverting
	 signal not_dout 	: STD_LOGIC := '0'; --inputs and outputs
	 signal not_din 	: STD_LOGIC := '0';

	 begin
 
	 -- Inversions
	 
 
	 spi_sclk    <= NOT not_sclk;
	 spi_dout    <= NOT not_dout;
	 not_din     <= NOT spi_din;
 
    -- Generate postscaled_clk 
    POSTSCALER: process(clk_5)
        
    begin
        if rising_edge(clk_5) then
            SCLK_Count <= SCLK_Count+1;
				if SCLK_Count=(50) then
					tmp <= not tmp;
					SCLK_Count <=1;
				end if;
        end if;
		  not_sclk <= tmp;
    end process POSTSCALER;
	 
	 -- PRESENT STATE REGISTER
    fsm_present_state_p : process (not_sclk, present_state,next_state)
    begin
        if (falling_edge(not_sclk)) then --Every time there is a falling edge on the postscaled clk, 
													  --allow for state transition

                present_state <= next_state;  --Present state is updated if a new state transition is defined

        end if;
    end process;

    -- NEXT STATE LOGIC
    fsm_next_state_p : process (not_sclk,present_state)
    begin
	 
		 if (rising_edge(not_sclk)) then --Occures every rising edge of spi_sclk
		 
		 
			  case present_state is
					
					when start => --State for defining preliminary set up for preparation of ADC communication
					
					spi_cs_n <= '0';  -- ADC to begin
					not_dout <='1'; -- D_in to be set for Start Bit
					
					next_state <= first_edge;
					
					when first_edge => --State that initialises ADC communication
					
						spi_cs_n <= '0';
						not_dout <='1'; --Start bit
					
					
						next_state <= second_edge;
						
						edge_count <=1; --monitors in which edge position the communication is currently at

					when second_edge => --State which defines which data for configuration will be sent to the ADC
						 
						spi_cs_n <= '0';
							
							
						edge_count <= 2;
						next_state <= Data_out;
						
						if (D_outXY = '1') then
							
							not_dout <= '0'; -- ADC will read all 0's for Control Bits, for CH1
							D_outXY <= '0';  -- Variable that registers if the current data transmitted is with
												  -- respect to the X or Y axes, being '0' for X and '1' for Y axis
						
						else
							
							not_dout <= '1'; -- ADC will read all 1's for Control Bits, for CH7
							D_outXY <= '1';
						
						end if;
							
					when Data_out => --State responsible for sending configuration data to the ADC
					
						edge_count <=edge_count +1;

						if(edge_count = 7) then
						
							counter_data <= 0;
					
							next_state <= Data_in;
						
						end if;
						
					
					when Data_in =>  --State responsible for reading the data sent from the ADC
					
						data_load_out <= '0';
						 
						edge_count <= edge_count+1;
						counter_data <= 17-edge_count; --counter that allows for assignation of information from
																 --the highest value bit to the lowest whilst reading D_in
						
						if (D_outXY = '0') and (counter_data >= 0) then
							
							data_X(counter_data) <= not_din; --Every rising edge the data currently at D_in is
																		--assigned to the respective 10 bit logic vector
						
						
						elsif (D_outXY = '1') and (counter_data >= 0) then
						
							data_Y(counter_data) <= not_din;
							
							
				
						end if;
					 
						if (edge_count = 18) then 
					 
							next_state <= finished;
							
							data_load_out <= '1';
							
							
						end if;
						
						
					
					when finished => --Transitionaty state from a finished reading cycle into a new one
						 
					 edge_count <= 0; 
					 next_state <= start;
				
					 spi_cs_n <= '1';
					 
					 when others => 
					 
					 null;
					 
			
					
			  end case;
		end if;
			  
    end process fsm_next_state_p;
	 
	 
	 LED: process(data_X,data_Y,data_load_out,D_outXY) --process which handles testing of the received input
																		--if appropiate communication was achieved, the same
																		--logic implemented here would be utilised for assigning
																		--variables for registering X and Y position
        
    begin
        if (data_load_out = '1') then
		  
				if (D_outXY = '0'  AND data_X < 400) then
				
				LED_1 <='1';
				LED_4 <='0';
				elsif (D_outXY ='0'  AND data_X > 700) then
				
				LED_1 <='0';
				LED_4 <='1';

				
				elsif (D_outXY = '0') then 
				
				LED_1 <='0';
				LED_4 <='0';
				
--				elsif (D_outXY ='1'  AND data_Y < 400) then    --Y logic has been commented out due to not appropiately
--																			  --working
--				LED_2 <='1';
--				LED_3 <='0';
--				
--				elsif (D_outXY ='1'  AND data_Y > 700) then
--				
--				LED_2 <='0';
--				LED_3 <='1';
--				
--				elsif (D_outXY ='1') then 
--				
--				LED_2 <='0';
--				LED_3 <='0';
--				
				end if;
		
		end if;
		  

    end process LED;
	 
end architecture;
	 