----------------------------------------------------------------------------------
-- Company:        USAFA
-- Engineer:       Josh Nielsen
-- 
-- Create Date:    10:42:09 01/29/2014 
-- Design Name:    Nielsen
-- Module Name:    atlys_lab_video
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
use IEEE.NUMERIC_STD.ALL;

entity atlys_lab_video is
    port ( 
             clk   : in  std_logic; -- 100 MHz
             reset : in  std_logic;
             tmds  : out std_logic_vector(3 downto 0);
             tmdsb : out std_logic_vector(3 downto 0)
         );
end atlys_lab_video;

architecture nielsen of atlys_lab_video is
    -- TODO: Signals, as needed ADDED:v_completed

	 signal pixel_clk, serialize_clk, serialize_clk_n, blank, h_sync, v_sync, 
	        red_s, green_s, blue_s, clock_s, v_completed : std_logic;
	 signal red, green, blue : std_logic_vector(7 downto 0);
	 signal row, column : unsigned(10 downto 0);
	 
	 component vga_sync
        port ( clk         : in  std_logic;
               reset       : in  std_logic;
               h_sync      : out std_logic;
               v_sync      : out std_logic;
               v_completed : out std_logic;
               blank       : out std_logic;
               row         : out unsigned(10 downto 0);
               column      : out unsigned(10 downto 0)
             );
    end component;
	 
	 component pixel_gen
		  port ( row      : in unsigned(10 downto 0);
			 	   column   : in unsigned(10 downto 0);
			 	   blank    : in std_logic;
			 	   r        : out std_logic_vector(7 downto 0);
				   g        : out std_logic_vector(7 downto 0);
				   b        : out std_logic_vector(7 downto 0)
				 );
    end component;
	 
begin

    -- Clock divider - creates pixel clock from 100MHz clock
    inst_DCM_pixel: DCM
    generic map(
                   CLKFX_MULTIPLY => 2,
                   CLKFX_DIVIDE   => 8,
                   CLK_FEEDBACK   => "1X"
               )
    port map(
                clkin => clk,
                rst   => reset,
                clkfx => pixel_clk --25MHz
            );

    -- Clock divider - creates HDMI serial output clock
    inst_DCM_serialize: DCM
    generic map(
                   CLKFX_MULTIPLY => 10, -- 5x speed of pixel clock
                   CLKFX_DIVIDE   => 8,
                   CLK_FEEDBACK   => "1X"
               )
    port map(
                clkin => clk,
                rst   => reset,
                clkfx => serialize_clk, --125MHz
                clkfx180 => serialize_clk_n
            );
				
	 --vga_sync port map		
    vga_sync_top: vga_sync 
	 port map(
	            clk => pixel_clk,
               reset => reset,
               h_sync => h_sync,
               v_sync => v_sync,
               v_completed => v_completed,
               blank => blank,
               row => row,
               column => column 
	         );
    -- Pixel generator port map
	 pixel_gen_top: pixel_gen
	 port map(
	            row => row,
			 	   column => column,
			 	   blank => blank,
			 	   r => red,
				   g => green,
				   b => blue
	         );
	 
    -- Convert VGA signals to HDMI (actually, DVID ... but close enough)
    inst_dvid: entity work.dvid
    port map(
                clk       => serialize_clk,
                clk_n     => serialize_clk_n, 
                clk_pixel => pixel_clk,
                red_p     => red,
                green_p   => green,
                blue_p    => blue,
                blank     => blank,
                hsync     => h_sync,
                vsync     => v_sync,
                -- outputs to TMDS drivers
                red_s     => red_s,
                green_s   => green_s,
                blue_s    => blue_s,
                clock_s   => clock_s
            );

    -- Output the HDMI data on differential signalling pins
    OBUFDS_blue  : OBUFDS port map
        ( O  => TMDS(0), OB => TMDSB(0), I  => blue_s  );
    OBUFDS_red   : OBUFDS port map
        ( O  => TMDS(1), OB => TMDSB(1), I  => green_s );
    OBUFDS_green : OBUFDS port map
        ( O  => TMDS(2), OB => TMDSB(2), I  => red_s   );
    OBUFDS_clock : OBUFDS port map
        ( O  => TMDS(3), OB => TMDSB(3), I  => clock_s );

end nielsen;