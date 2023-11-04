-- Simple Snake Game
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.Types.ALL;

entity SnakeTLE is
	port(
		-- Input Clock
		i_CLK_50MHz_NOT : in STD_LOGIC;
	
		-- Input Buttons
		i_S1_LEFT_NOT 	: in STD_LOGIC;
		i_S2_RIGHT_NOT : in STD_LOGIC;
		i_S3_UP_NOT  	: in STD_LOGIC;
		i_S4_DOWN_NOT  : in STD_LOGIC;
		
		-- Output Screen
		o_LATCH_NOT : out STD_LOGIC;
		o_CLK_NOT   : out STD_LOGIC;
		o_DATA_NOT  : out STD_LOGIC;
		o_EN_NOT    : out STD_LOGIC;
		o_ROW_NOT   : out STD_LOGIC_VECTOR(3 downto 0);
		
		-- Output LED Debug
		o_LED_D1_NOT : out STD_LOGIC;
		o_LED_D2_NOT : out STD_LOGIC;
		o_LED_D3_NOT : out STD_LOGIC;
		o_LED_D4_NOT : out STD_LOGIC
	);
end SnakeTLE;

architecture Structure of SnakeTLE is
	
	-- =================================================== Input Output Signals
	-- Signal Clock
	signal i_CLK_50MHz : STD_LOGIC;
	
	-- Signal Button
	signal i_S1_LEFT  : STD_LOGIC := '0';
	signal i_S2_RIGHT : STD_LOGIC := '0';
	signal i_S3_UP    : STD_LOGIC := '0';
	signal i_S4_DOWN  : STD_LOGIC := '0';

	-- Signal Display
	signal o_LATCH : STD_LOGIC := '0';
	signal o_CLK   : STD_LOGIC := '0';
	signal o_DATA  : STD_LOGIC := '0';
	signal o_EN    : STD_LOGIC := '0';
	signal o_ROW   : STD_LOGIC_VECTOR(3 downto 0) := "0000"; 

	-- Signal LED Debug
	signal o_LED_D1 : STD_LOGIC := '0';
	signal o_LED_D2 : STD_LOGIC := '0';
	signal o_LED_D3 : STD_LOGIC := '0';
	signal o_LED_D4 : STD_LOGIC := '0';
	
	-- =================================================== Internal Signals

	--Clocks
	signal o_Clk_Display : STD_LOGIC := '0';
	signal o_Clk_Game : STD_LOGIC := '0';
	
	signal Screen_Display : Screen_Display_Type := (
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


	
	
	-- =================================================== Component Declarations
	component clk_div
		port(
			clk_out : out std_logic;
			clk_in : in std_logic;
			frequency_in : in integer
			);
	end component;
	
	component OutputController
		port(
        clk_Display_Speed : in STD_LOGIC;
        i_Screen_Display  : in Screen_Display_Type;
        o_LATCH           : out STD_LOGIC;
        o_CLK             : out STD_LOGIC;
        o_DATA            : out STD_LOGIC;
		  o_EN				  : out STD_LOGIC;
        o_ROW             : out STD_LOGIC_VECTOR(3 downto 0)
        -- Add other ports as needed
		);
	end component;
	
	
begin
	-- =================================================== Invertions
	-- INVERTED CLOCK
	i_CLK_50MHz		<= NOT i_CLK_50MHz_NOT;
	-- INVERTED BUTTONS
	i_S1_LEFT		<= NOT i_S1_LEFT_NOT;
	i_S2_RIGHT		<= NOT i_S2_RIGHT_NOT;
	i_S3_UP 	 		<= NOT i_S3_UP_NOT;
	i_S4_DOWN		<= NOT i_S4_DOWN_NOT;
	-- INVERTED DISPLAY
	o_LATCH_NOT		<= NOT o_LATCH;
	o_CLK_NOT		<= NOT o_CLK;
	o_DATA_NOT		<= NOT o_DATA;
	o_EN_NOT 		<= NOT o_EN;
	o_ROW_NOT		<= NOT o_ROW;
	-- INVERTED LED DEBUG
	o_LED_D1_NOT	<= NOT o_LED_D1;
	o_LED_D2_NOT	<= NOT o_LED_D2;
	o_LED_D3_NOT	<= NOT o_LED_D3;
	o_LED_D4_NOT	<= NOT o_LED_D4;
	
	
	-- ====================================================================
	-- !!!  Values with '_NOT' are Forbidden beyond this point (Below)  !!!
	--             Use Internal Signal Definitions instead
	-- ====================================================================
	
	
	-- =================================================== Simple Wire Connections
	o_LED_D1 		<= o_Clk_Display;
	o_LED_D2 		<= o_Clk_Game;
	o_LED_D4			<= o_LATCH;
	-- =================================================== Logic
	Clk_Display_Speed: clk_div port map (
    clk_out => o_Clk_Display,
    clk_in  => i_CLK_50MHz,
	 frequency_in => 24000 -- Exact Clk for 24Hz output_Display is 18947Hz Clk
	);
	
	Clk_Game_Speed: clk_div port map (
    clk_out => o_Clk_Game,
    clk_in  => i_CLK_50MHz,
	 frequency_in => 1 
	);
	
	OutputController_inst: OutputController
        port map(
				clk_Display_Speed => o_Clk_Display,
            i_Screen_Display  => Screen_Display,
				o_LATCH           => o_LATCH,
				o_CLK             => o_CLK,
				o_DATA            => o_DATA,
				o_EN					=> o_EN,
				o_ROW             => o_ROW
        );

end Structure;

