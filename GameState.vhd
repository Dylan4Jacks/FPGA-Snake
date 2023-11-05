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
		  i_game_frequency	 : in integer;
        i_X_Dir			 	 : in STD_LOGIC;
		  i_Y_Dir			 	 : in STD_LOGIC;
		  o_Screen_Display    : out Screen_Display_Type
    );
end entity GameState;
	 
architecture Behavioral of GameState is

	-- ====================================================================================================== Timings
	signal count : integer := 1;

	-- ====================================================================================================== States
	type state_type is (s_home, s_idle, s_move_player_head, s_check_game_over, s_move_player_body, s_over);
	signal state : state_type := s_home;

	
	-- ====================================================================================================== Display
	signal internal_Screen_Display : Screen_Display_Type := (others => (others => '1'));

	-- ====================================================================================================== Snake
	type Position_Type is record
		x : integer range 0 to 15;  -- 0 to represent an unused slot
		y : integer range 0 to 15;  -- 0 to represent an unused slot
	end record;

	type Snake_Body_Type is array (0 to 255) of Position_Type;
	
	signal is_Game_Over : STD_LOGIC := '0';
	signal New_Snake_Head : Position_Type := (0, 0);
	
	signal Snake_Body: Snake_Body_Type := (
		 others => (0, 0)  -- Initialize all positions to 0,0
	);
	
		
		
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
		if i_X_Dir = '1' OR i_Y_Dir = '1' then
			state <= s_idle;
			
			-- Initializing the snake body with a length of 3 at the specified positions
			Snake_Body(0) <= (8, 7);  -- Head of the snake
			Snake_Body(1) <= (8, 8);
			Snake_Body(2) <= (8, 9);  -- Tail of the snake
		end if;

	when s_idle =>
		if i_game_frequency = 0 then
		-- If frequency_in is 0, do nothing
		else
			count <= count + 1;
			if count = i_game_frequency then
				state <= s_move_player_head;
				-- Move player
				count <= 1;
			end if;
		end if;
	 
	when s_move_player_head =>
		 -- Assuming '1' represents positive direction (right or up) and '0' represents negative (left or down)
		if i_X_Dir = '1' then
		  -- Check if the head is at the edge of the grid
		  if New_Snake_Head.x < 15 then
				New_Snake_Head.x <= New_Snake_Head.x + 1; -- Move right
		  end if;
		elsif i_X_Dir = '0' then
		  -- Check if the head is at the edge of the grid
		  if New_Snake_Head.x > 0 then
				New_Snake_Head.x <= New_Snake_Head.x - 1; -- Move left
		  end if;
		end if;

		if i_Y_Dir = '1' then
		  -- Check if the head is at the edge of the grid
		  if New_Snake_Head.y < 15 then
				New_Snake_Head.y <= New_Snake_Head.y + 1; -- Move up
		  end if;
		elsif i_Y_Dir = '0' then
		  -- Check if the head is at the edge of the grid
		  if New_Snake_Head.y > 0 then
				New_Snake_Head.y <= New_Snake_Head.y - 1; -- Move down
		  end if;
		end if;
		state <= s_check_game_over;
	
	when s_check_game_over =>
		
		state <= s_over;
	
	when s_move_player_body =>
			
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
		
		if i_X_Dir = '1' OR i_Y_Dir = '1' then
			state <= s_home;
		end if;
end case;
end if;
end process;

end architecture Behavioral;