-- Simple Snake Game
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Snake is
	port(
		i_CLK_50 : in STD_LOGIC;
	
		-- Screen Input
		i_LATCH_NOT : in STD_LOGIC;
		i_CLK_NOT   : in STD_LOGIC;
		i_DATA_NOT  : in STD_LOGIC;
		i_EN_NOT    : in STD_LOGIC;
		
		-- Screen Outputs
		o_LATCH_NOT : out STD_LOGIC;
		o_CLK_NOT   : out STD_LOGIC;
		o_DATA_NOT  : out STD_LOGIC;
		o_EN_NOT    : out STD_LOGIC;
		o_ROW_NOT   : out STD_LOGIC_VECTOR(3 downto 0);
		
		-- Board Lights Debug Output
		o_LED_LATCH_NOT : out STD_LOGIC;
		o_LED_CLK_NOT   : out STD_LOGIC;
		o_LED_DATA_NOT  : out STD_LOGIC;
		o_LED_EN_NOT    : out STD_LOGIC
	);
end Snake;

architecture Behavioral of Snake is
	-- Signals for manual clock toggle
  signal i_LATCH : STD_LOGIC;
	signal i_CLK   : STD_LOGIC;
	signal i_DATA  : STD_LOGIC;
	signal i_EN    : STD_LOGIC;

	-- Internal Screen Outputs  (NOT inverted)
	signal o_LATCH : STD_LOGIC;
	signal o_CLK   : STD_LOGIC;
	signal o_DATA  : STD_LOGIC;
	signal o_EN    : STD_LOGIC;
	signal o_ROW   : STD_LOGIC_VECTOR(3 downto 0); 

	-- Board Lights Debug Output
	signal o_LED_LATCH : STD_LOGIC;
	signal o_LED_CLK   : STD_LOGIC;
	signal o_LED_DATA  : STD_LOGIC;
	signal o_LED_EN    : STD_LOGIC;
	
	-- Internal variables
	signal current_row : STD_LOGIC_VECTOR(3 downto 0);
	signal bitmask     : STD_LOGIC_VECTOR(15 downto 0);
	
	-- State Machine Signals
	signal shift_counter : integer range 0 to 16 := 16;
	signal prev_clk : std_logic := '0';
	
	-- Clock Signals
	signal SCLK_Count : std_logic := '0';
	signal tmp : std_logic;
	signal spi_slck : std_logic;
begin
	-- INPUT AND OUTPUT 

	-- Setting Input 
	i_LATCH <= NOT i_LATCH_NOT;
	i_CLK   <= NOT i_CLK_NOT;
	i_DATA  <= NOT i_DATA_NOT;
	i_EN    <= NOT i_EN_NOT;

	-- Setting 16x16 output
	o_LATCH_NOT <= NOT o_LATCH;
	o_CLK_NOT   <= NOT o_CLK;
	o_DATA_NOT  <= NOT o_DATA;
	o_EN_NOT    <= NOT o_EN;
	o_ROW_NOT   <= NOT o_ROW;

	-- Setting LED Output
	o_LED_LATCH_NOT <= NOT o_LED_LATCH;
	o_LED_CLK_NOT   <= NOT o_LED_CLK;
	o_LED_DATA_NOT  <= NOT o_LED_DATA;
	o_LED_EN_NOT    <= NOT o_LED_EN;
	
	
	-- WIRE DECLARATIONS
	o_LATCH			<= i_LATCH; 
	o_LED_LATCH	<= i_LATCH; 
	o_CLK				<= i_CLK; 
	o_LED_CLK		<= i_CLK; 
	o_DATA			<= i_DATA; 
	o_LED_DATA	<= i_DATA; 
	o_EN				<= i_EN; 
	o_LED_EN		<= i_EN; 
	
	-- TEST CONSTANTS
	o_ROW <= "0100";
	
--	-- Using Internal Clock
--	POSTSCALER: process(i_CLK_50)
--    begin
--        if rising_edge(i_CLK_50) then
--            SCLK_Count <= SCLK_Count+1;
--                if SCLK_Count=(50) then
--                    tmp <= not tmp;
--                    SCLK_Count <=1;
--                end if;
--        end if;
--          spi_slck <= tmp;
--    end process POSTSCALER;
	 
	-- Clock-driven process to handle shifting
	process(i_CLK)
	begin
		 if rising_edge(i_CLK) then
			  -- if prev_clk = '0' then
				-- 	-- Set initial values
				-- 	o_Test <= '1';
				-- 	o_LATCH <= '0';
				-- 	o_CLK <= '0';
				-- 	o_DATA <= '0';
				-- 	o_EN <= '0';
				-- 	o_ROW <= (others => '0');

				-- 	-- Equivalent of lightPixel(0, 0);
				-- 	current_row <= "0001"; -- Represents row 0
				-- 	bitmask <= "1111111111111110"; -- Represents pixel at (0,0)

				-- 	-- Lighting up the pixel
				-- 	o_EN <= '1';
				-- 	o_ROW <= current_row;
					
				-- 	prev_clk <= '1';

			  -- elsif shift_counter < 16 then
				-- 	prev_clk <= '0';
				-- 	o_Test <= '0';
				-- 	o_DATA <= not bitmask(shift_counter);
				-- 	o_CLK <= not o_CLK; -- Toggle the CLK
				-- 	shift_counter <= shift_counter + 1;
			  -- elsif shift_counter = 16 then
				-- 	prev_clk <= '0';
				-- 	o_Test <= '1';
				-- 	o_LATCH <= '1';
				-- 	o_EN <= '0';
				-- 	shift_counter <= 0;  -- Reset the counter
			 -- end if;
		 end if;
	end process;

end Behavioral;

