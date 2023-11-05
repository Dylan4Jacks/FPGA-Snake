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
	type state_type is (s_home, s_idle, s_move_player_head, s_check_game_over1, s_check_game_over2, s_move_player_body, s_update_internal_screen, s_update_screen, s_over);
	signal state : state_type := s_home;

	
	-- ====================================================================================================== Display
	signal internal_Screen_Display : Screen_Display_Type := (others => (others => '0'));

	-- ====================================================================================================== Snake
	type Position_Type is record
		x : integer range 0 to 16;  -- 16 to represent an unused slot
		y : integer range 0 to 16;  -- 16 to represent an unused slot
	end record;

	constant Empty_Position: Position_Type := (16, 16);  -- Define a constant for an empty position
	
	type Snake_Body_Type is array (0 to 19) of Position_Type;
	
	signal is_Game_Over : STD_LOGIC := '0';
	signal New_Snake_Head : Position_Type := (0, 0);
	
	signal Snake_Body: Snake_Body_Type := (
		 others => Empty_Position  -- Initialize all positions to 0,0
	);
	
		
		
begin
process(clk_Game_Speed)
begin
 if rising_edge(clk_Game_Speed) then
case state is
	when s_home =>
		 internal_Screen_Display <= (others => (others => '0'));
		 o_Screen_Display <= (
			"0000000000000000",
			"0000000000000000",
			"0000000000000000",
			"0001000000000000",
			"0000100000000000",
			"0000010000000000",
			"0000001000000000",
			"0000000100000000",
			"0000000010000000",
			"0000000001000000",
			"0000000000100000",
			"0000000000010000",
			"0000000000001000",
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
				o_Screen_Display(2)(0) <= '1';
				internal_Screen_Display <= (others => (others => '0'));
				count <= 1;
			end if;
		end if;
	 
	when s_move_player_head =>
		o_Screen_Display(3)(0) <= '1';
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
		state <= s_check_game_over1;
	
	when s_check_game_over1 =>
		o_Screen_Display(4)(0) <= '1';
		state <= s_check_game_over2;
		for i in 19 downto 0 loop
				if (Snake_Body(i).x = New_Snake_Head.x) and (Snake_Body(i).y = New_Snake_Head.y) then
					 is_Game_Over <= '1';
					 exit;
				end if;
		end loop;
		
	when s_check_game_over2 =>
		if is_Game_Over = '0' then
			o_Screen_Display(5)(0) <= '1';
        state <= s_move_player_body;
		else
		  state <= s_over;
		end if;
	
	when s_move_player_body =>
			o_Screen_Display(6)(0) <= '1';
		for i in 19 downto 1 loop
				Snake_Body(i) <= Snake_Body(i-1);
		end loop;
		Snake_Body(0) <= New_Snake_Head;
		state <= s_update_internal_screen;
	
	when s_update_internal_screen => 
--		o_Screen_Display(7)(0) <= '1';
--		for i in 0 to 19 loop
--        -- Check if the segment is within the bounds of the screen
--        if (Snake_Body(i).x >= 0) and (Snake_Body(i).x <= 15) and
--           (Snake_Body(i).y >= 0) and (Snake_Body(i).y <= 15) then
--            -- Update the screen at the segment's position
--            internal_Screen_Display(Snake_Body(i).y)(Snake_Body(i).x) <= '1';
--				o_Screen_Display(8)(0) <= '1';
--        end if;
--		  o_Screen_Display(9)(0) <= '1';
--    end loop;
--	 o_Screen_Display(10)(0) <= '1';
--	 state <= s_update_screen;
	
	when s_update_screen =>
--		o_Screen_Display(11)(0) <= '1';
--		o_Screen_Display <= internal_Screen_Display;
--		state <= s_idle;
	
	when s_over =>
		is_Game_Over <= '0';
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