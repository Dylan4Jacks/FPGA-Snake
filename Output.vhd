-- Output Controller to Screen Display
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.Types.ALL;


entity OutputController is
    port(
        clk_60Hz          : in STD_LOGIC;              -- 60Hz clock input
        i_Screen_Display  : in Screen_Display_Type;    -- Screen display input
        o_LATCH           : out STD_LOGIC;              -- Latch input
        o_CLK             : out STD_LOGIC;              -- Clock input
        o_DATA            : out STD_LOGIC;              -- Data input
        o_ROW             : out STD_LOGIC_VECTOR(3 downto 0)  -- Row input
        
    );
end entity OutputController;
	 
architecture Behavioral of OutputController is

type state_type is (s_idle, s_process_bit, s_clk_on, s_latch_on, s_process_row);

signal state : state_type := s_idle;
signal bit_count : integer range 0 to 15 := 0; -- 16 bits 
signal row_count : integer range 0 to 15 := 0; -- 16 rows

begin


process(clk_60Hz)
begin
    if rising_edge(clk_60Hz) then
        case state is
            when s_idle =>
                bit_count <= 0;
                row_count <= 0;
					 o_LATCH		<= '0';  
					 o_CLK 		<= '0';  
                o_ROW <= "0000"; -- Reset to the first row
                state <= s_process_bit;

            when s_process_bit =>
                o_Data <= i_Screen_Display(row_count)(bit_count); -- Send data bit
                state <= s_clk_on; -- Move to the next state to toggle the clock
					 o_CLK <= '0';  -- Reset
					 

            when s_clk_on =>
					o_CLK <= '1'; -- Send a pulse
					if bit_count = 15 then
					  bit_count <= 0;
					  state <= s_latch_on;
					else
						bit_count <= bit_count + 1;     -- TODO: may be issue with Bit_Count for testing purposes only
					   state <= s_process_bit;
					end if;

				when s_latch_on =>
					 o_LATCH <= '1'; -- Send a pulse
					 if row_count = 15 then
						  state <= s_idle; -- Reset everything
					 else
						  row_count <= row_count + 1;
						  state <= s_process_row;
					 end if;
					 
				 when s_process_row =>
					 o_LATCH <= '0'; -- Reset
					 o_ROW <= STD_LOGIC_VECTOR(to_unsigned(row_count, 4));
					 state <= s_process_bit;
					 
			  end case;
    end if;
end process;

end architecture Behavioral;