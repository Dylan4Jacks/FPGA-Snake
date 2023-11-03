-- Simple D Flip FLop with reset
Library IEEE;
USE IEEE.Std_logic_1164.all;

entity Simple_DFF_R2 is
	port(
		Q : out std_logic;
		Clk : in std_logic;
		D : in std_logic;
		reset : in std_logic
	);
end Simple_DFF_R2;

	architecture Behavioral of Simple_DFF_R2 is
		begin
			process(clk, reset)
			begin
				if (reset='1') then
					Q<='0';
				elsif (rising_edge(clk)) then
					Q <= D;
				end if;
			end process;
		end Behavioral;