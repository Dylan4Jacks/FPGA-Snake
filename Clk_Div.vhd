-- clock divider
library IEEE;
USE IEEE.Std_logic_1164.all;

entity clk_div is 
	port(
		clk_out : out std_logic; -- Is the output clk
		clk_in : in std_logic;  -- Expected input clk of 50Mhz
		frequency_in : in integer -- Sets the clk_out frequency in Hz
	);
end clk_div;

architecture Behavioral of clk_div is
	signal count : integer := 1;
	signal tmp : std_logic := '0';
	signal divider_value: integer;

	begin
		process(clk_in)
		begin
			if(rising_edge(clk_in)) then
				if frequency_in = 0 then
					-- If frequency_in is 0, do nothing
				else
					divider_value <= 50000000 / frequency_in / 2;
					-- divider_Value uses the initial clock speed divided by frequency divided by 2. 
					-- Every time count reaches divider_value, tmp (which is your output clock) toggles. 
					-- This means that for a full cycle of your output clock (i.e., from '0' to '1' and back to '0'), count will reach divider_value twice.
					count <= count + 1;
					if count = divider_value then
						tmp <= NOT tmp;
						count <= 1;
					end if;
				end if;
			end if;
			clk_out <= tmp;
		end process;
	end Behavioral;