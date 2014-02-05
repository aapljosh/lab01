----------------------------------------------------------------------------------
-- Company:        USAFA
-- Engineer:       Josh Nielsen
-- 
-- Create Date:    10:42:09 01/29/2014 
-- Design Name:    Nielsen
-- Module Name:    vga_sync
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

entity vga_sync is
    port ( clk         : in  std_logic;
           reset       : in  std_logic;
           h_sync      : out std_logic;
           v_sync      : out std_logic;
           v_completed : out std_logic;
           blank       : out std_logic;
           row         : out unsigned(10 downto 0);
           column      : out unsigned(10 downto 0)
     );
end vga_sync;

architecture nielsen of vga_sync is
   component h_sync_gen
      port ( clk       : in  std_logic;
             reset     : in  std_logic;
             h_sync    : out std_logic;
             blank     : out std_logic;
             completed : out std_logic;
             column    : out unsigned(10 downto 0)
           );
    end component;
	 component v_sync_gen
      port ( clk         : in std_logic;
             reset       : in std_logic;
             h_completed : in std_logic;
             v_sync      : out std_logic;
             blank       : out std_logic;
             completed   : out std_logic;
             row         : out unsigned(10 downto 0)
           );
    end component;
	 signal h_completed : std_logic;
	 signal h_blank, v_blank : std_logic;
	 --signal h_and_v_blank : std_logic;
	 
begin
   vga_h_sync_gen:   h_sync_gen port map(
	                                 clk => clk, 
												reset => reset, 
												h_sync => h_sync, 
												blank => h_blank,
												completed => h_completed,
												column => column
												);
	vga_v_sync_gen:   v_sync_gen port map(
	                                 clk => clk,
												reset => reset,
												h_completed => h_completed,
												v_sync => v_sync,
												blank => v_blank,
												completed => v_completed,
												row => row												
	                                 );
   blank <= '0' when h_blank = '0' and v_blank = '0' else '1';
end nielsen;

