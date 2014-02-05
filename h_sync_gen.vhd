----------------------------------------------------------------------------------
-- Company:        USAFA
-- Engineer:       Josh Nielsen
-- 
-- Create Date:    10:42:09 01/29/2014 
-- Design Name:    Nielsen
-- Module Name:    h_sync_gen
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
use work.global_constants.all;

--constant h_active_video_pulse : integer := 640;
--constant front_porch_length : integer := 16;
--constant sync_pulse_length : integer := 96;
--constant back_porch_length : integer := 48;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity h_sync_gen is
    port ( clk       : in  std_logic;
           reset     : in  std_logic;
           h_sync    : out std_logic;
           blank     : out std_logic;
           completed : out std_logic;
           column    : out unsigned(10 downto 0)
     );
end h_sync_gen;

architecture nielsen of h_sync_gen is
    --TODO - required siganls
	 type h_sync_state_type is
      (active_video, front_porch, sync_pulse, back_porch);
    signal count_next, count_reg : unsigned(10 downto 0);--:= (others => '1');
	 signal state_next, state_reg : h_sync_state_type;

begin
	 
	 --process for changing the count
    process(clk,reset)
    begin
        if reset='1' then
			   count_reg <= (others => '0');
        elsif (clk'event and clk='1') then
            count_reg <= count_next;
		  else
		      count_reg <= count_reg;--memory
        end if;
    end process;
	 
    --process for handling changing states
    process(clk,reset)
    begin
        if reset='1' then
			   state_reg <= active_video;
        elsif (clk'event and clk='1') then
            state_reg <= state_next;
		  else
		      state_reg <= state_reg;--memory
        end if; 
    end process;
	 
	 	 --process for determining the next state
	 process(count_reg, state_reg)
	 begin
		state_next <= state_reg;
	 
	     case state_reg is
            when active_video =>
				    if (count_reg = h_active_video_pulse-1) then
					     state_next <= front_porch;
					 end if;
            when front_porch =>
				    if (count_reg = h_front_porch_pulse-1) then
					     state_next <= sync_pulse;
					 end if;
            when sync_pulse =>
				    if (count_reg = h_sync_pulse_pulse-1) then
					     state_next <= back_porch;
					 end if;
			   when back_porch =>
				    if (count_reg = h_back_porch_pulse-1) then
					     state_next <= active_video;
					 end if;
        end case;
	 end process;
	 
	 --determine the next value of the counter 

	 count_next <= (others => '0') when state_reg /= state_next else
						 count_reg + 1;	
						 
    -- output of mealy
    column <= count_reg when state_reg = active_video else (others => '0');
    h_sync <= '0' when state_reg = sync_pulse else '1';
    blank <= '0' when state_reg = active_video else '1';
    completed <= '1' when (count_reg = h_back_porch_pulse-1) and (state_reg = back_porch) else '0';	

end nielsen;