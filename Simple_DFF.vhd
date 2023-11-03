-- Simple D Flip FLop
Library IEEE;
USE IEEE.Std_logic_1164.all;

entity Simple_DFF is
	port(
		Q : out std_logic;
		Clk : in std_logic;
		D : in std_logic
	);
end Simple_DFF;

	architecture Behavioral of Simple_DFF is
		begin
			process(clk)
			begin
				if (rising_edge(clk)) then
					Q <= D;
				end if;
			end process;
		end Behavioral;