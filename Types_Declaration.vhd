library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package Types is
    type Screen_Row_Type is array (0 to 15) of STD_LOGIC;
    type Screen_Display_Type is array (0 to 15) of Screen_Row_Type;
end package Types;