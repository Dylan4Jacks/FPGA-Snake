-- Game State to Screen Display
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.Types.ALL;


entity GameState is
    port(
        clk_Game_Speed 		 : in STD_LOGIC;  
        i_X_Dir			 	 : in STD_LOGIC;
		  i_Y_Dir			 	 : in STD_LOGIC;
		  o_Screen_Display    : out Screen_Display_Type
    );
end entity GameState;
	 
architecture Behavioral of GameState is

type state_type is (s_home, s_play, s_over);

signal state : state_type := s_home;


signal internal_Screen_Display : Screen_Display_Type := (others => (others => '1'));

begin


process(clk_Game_Speed)
begin
    if rising_edge(clk_Game_Speed) then
        case state is
            when s_home =>
                o_Screen_Display <= (
						 "0000000000000000",
						 "0000000000000000",
						 "0000000000000000",
						 "0001000000001000",
						 "0000100000010000",
						 "0000010000100000",
						 "0000001001000000",
						 "0000000110000000",
						 "0000000110000000",
						 "0000001001000000",
						 "0000010000100000",
						 "0000100000010000",
						 "0001000000001000",
						 "0000000000000000",
						 "0000000000000000",
						 "0000000000000000"
					);


            when s_play =>
					
					 

            when s_over =>
					o_Screen_Display <= (
						"0000000000000000",
						"0000000000000000",
						"0000000000000000",
						"0111010001011100",
						"0100010001010110",
						"0100011001010010",
						"0100010101010010",
						"0111010011010010",
						"0100010001010010",
						"0100010001010010",
						"0100010001010010",
						"0111010001011100",
						"0000000000000000",
						"0000000000000000",
						"0000000000000000",
						"0000000000000000"
					);
					
					if i_x_Dir = '1' then
						state <= s_home;
					end if;
			  end case;
    end if;
end process;

end architecture Behavioral;