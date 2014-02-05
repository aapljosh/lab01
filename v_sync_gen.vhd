----------------------------------------------------------------------------------
-- Company:        USAFA
-- Engineer:       Josh Nielsen
-- 
-- Create Date:    10:42:09 01/29/2014 
-- Design Name:    Nielsen
-- Module Name:    v_sync_gen
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

-- Uncomment the following library declaration if using.
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use work.global_constants.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity v_sync_gen is
    port ( clk         : in  std_logic;
           reset       : in std_logic;
           h_completed : in std_logic;
           v_sync      : out std_logic;
           blank       : out std_logic;
           completed   : out std_logic;
           row         : out unsigned(10 downto 0)
     );
end v_sync_gen;

architecture nielsen of v_sync_gen is
    --TODO - required siganls
	 type v_sync_state_type is
      (active_video, front_porch, sync_pulse, back_porch);
    signal count_next, count_reg : unsigned(10 downto 0);
	 signal state_next, state_reg : v_sync_state_type;

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
	 process(count_reg, state_reg, h_completed)
	 begin
		state_next <= state_reg;
		if h_completed = '1' then
	     case state_reg is
            when active_video =>
				    if (count_reg = v_active_video_pulse-1) then
					     state_next <= front_porch;
					 end if;
            when front_porch =>
				    if (count_reg = v_front_porch_pulse-1) then
					     state_next <= sync_pulse;
					 end if;
            when sync_pulse =>
				    if (count_reg = v_sync_pulse_pulse-1) then
					     state_next <= back_porch;
					 end if;
			   when back_porch =>
				    if (count_reg = v_back_porch_pulse-1) then
					     state_next <= active_video;
					 end if;
        end case;
		 end if;
	 end process;
	 
	 --determine the next value of the counter  
--    process (h_completed, state_reg, state_next, clk) is
--	 begin     
--		  if (h_completed = '1') then
--    	      count_next <= count_reg + 1;
--        elsif (state_reg = state_next) then
--		      count_next <= count_next;	         
--		  else
--		      count_next <= (others => '0');
--		  end if;
--	 end process;

		count_next <= 	(others => '0') when state_reg /= state_next else
							count_reg + 1 when h_completed = '1' else
							count_reg;

    -- output of mealy
    row <= count_reg when state_reg = active_video else (others => '0');
    v_sync <= '0' when state_reg = sync_pulse else '1';
    blank <= '0' when state_reg = active_video else '1';
    completed <= '1' when (count_reg = v_back_porch_pulse-1) and (state_reg = back_porch) and (h_completed = '1') else '0';	

end nielsen;


