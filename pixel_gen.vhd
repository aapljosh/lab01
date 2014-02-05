----------------------------------------------------------------------------------
-- Company:        USAFA
-- Engineer:       Josh Nielsen
-- 
-- Create Date:    10:42:09 01/29/2014 
-- Design Name:    Nielsen
-- Module Name:    pixel_gen
-- Project Name:   Lab 01
-- Target Devices: Spartan 6
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
-- TODO: Include requied libraries and packages
--       Don't forget about `unisim` and its `vcomponents` package.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pixel_gen is
    port ( row      : in unsigned(10 downto 0);
           column   : in unsigned(10 downto 0);
           blank    : in std_logic;
           r        : out std_logic_vector(7 downto 0);
           g        : out std_logic_vector(7 downto 0);
           b        : out std_logic_vector(7 downto 0));
end pixel_gen;

architecture nielsen of pixel_gen is
    signal temp, temp2 : natural;   
begin

    process(row,column,blank)
    begin
        if blank='0' then
		      --test pattern
			   if (column <= 640/3 and row <= 2*640/3) then
				    r <= (others => '1');
	             g <= (others => '0');
	             b <= (others => '0');
				elsif (column <= 2*640/3 and column > 640/3 and row <= 2*480/3) then
				    r <= (others => '0');
	             g <= (others => '1');
	             b <= (others => '0');
				elsif (column <= 640 and column > 2*640/3 and row <= 2*480/3) then
				    r <= (others => '0');
	             g <= (others => '0');
	             b <= (others => '1');
				else
				    r <= (others => '1');
	             g <= (others => '1');
	             b <= (others => '0');
				end if;
		  else
		      r <= (others => '0');
	         g <= (others => '0');
	         b <= (others => '0');
        end if;
    end process;

end nielsen;

