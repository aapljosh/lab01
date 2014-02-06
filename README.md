#Introduction
The goal of this code repository is to implement a VGA driver for the Spartan 6 FPGA. This code assumes access to a VGA-to-HDMI conversion module. This module will take in clock and reset signals and output the proper signals to drive a VGA monitor.

#Implementation
The first modules I implemented were  h_sync and v_sync. These modules output the column and row of the current pixel to be displayed as well as some other control signals. A diagram of what these modules look like is shown in the following figure.

![h_v_sync](/h_v_sync.PNG)

The count and state are changed in processes that act as by D Flip Flops such as the one in the following code.
```vhdl
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
```
The next state logic is based upon the current count_reg value and the current state of the machine. Here is an example take from v_sync (h_sync is similar, but it does not depend on the h_completed signal):
```vhdl
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
```
If the current state equals the previous state, the machine is still incrementing the count, otherwise it resets. In the v_sync module h_completed must also be high to increment the count.

The overall output is achieved using a mealy machine implementation and the code is as follows:
```vhdl
  -- output of mealy
  row <= count_reg when state_reg = active_video else (others => '0');
  v_sync <= '0' when state_reg = sync_pulse else '1';
  blank <= '0' when state_reg = active_video else '1';
  completed <= '1' when (count_reg = v_back_porch_pulse-1) and (state_reg = back_porch) and (h_completed = '1') else 
```

The following diagram shows how the v_sync and h_sync modules were hooked up to form the overall vga_sync module. The vga_sync module produces all of the necessary signals (other than the proper rgb values) to drive the provided dvid module that convers the VGA signal to DVID. The module takes in clk and reset signals and outputs the row, column, h_sync, v_sync, v_completed and blank signals. 

- The h_sync and v_sync signals are low whenever their respective lower level modules are in the "sync" state, otherwise they are high. 
- The v_completed signal represents when both h_sync and v_sync have completed sending all of the necessary signals to display one frame on a screen. 
- The blank signal is low whenever the h_sync_gen and v_sync_gen modules are both in their “active_video” states. 
- The row and column simply represent the row and column number of the pixel currently being displayed. All of these signals together represent the control signals of the VGA protocol.

![vga_sync](/vga_sync.PNG)

The final module I needed to create was pixel_gen which takes in a row and column and the blank signal and outputs what rgb values for the color of that pixel. You can only display colors when blank is false, otherwise black (all zeros) should be sent For example to make the screen all red you would give it the following code:
```vhdl
  process(row,column,blank)
  begin
    if blank='0' then
      r <= (others => '1');
      g <= (others => '0');
      b <= (others => '0');
    else
      r <= (others => '0');
      g <= (others => '0');
      b <= (others => '0');
    end if;
  end process;
```


The following is a block diagram for atlys_lab_video that takes in a reset and clock and outputs the proper signals to drive a monitor from the created VGA signal to the HDMI output of the atlys board. It is included for completeness sake.

![block_diagram_1](/block_diagram_1.PNG)
![block_diagram_2](/block_diagram_2.PNG)

#Test/Debug
- The first problem I ran into was when my simulation for my h_sync and v_sync modules refused to output anything but Us for the row and column. After spending several hours trying to resolve this without any luck, known working code was inserted in place of some of my original code. This fixed the problem. I believe the issue was related to my moore implementation and not having a proper look-ahead. Once I replace my moore code with a mealy implementation, it started working just fine.
- The only other problem I ran into was the fact that the next state logic in my v_sync module needed to only change if h_completed was equal to '1'. Otherwise there was a glitch where the final row of the display (represented by v_back_porch_pulse-1) did not stay until the H-sync_gen module was finished writing all of its pixels horizontally. Once this was fixed, my code started working and the display lit up with my test pattern. 
- The final simulation of the vga_sync module with correct signals is shown below. What is seen is the transition from the active_video state of the v_sync_gen module to the front porch. After this state changes we see the h_sync signal pulse 10 times before the v_sync_gen module enters the synce state where v_sync is low for 2 pulses of h_sync. All this time the blank signal is high because the v_sync_gen module has entered the states other than active_video.

![simulation](/simulation.PNG)

#Conclusion
This lab was an excellent first look into interfacing FPGAs with hardware using VHDL. All of the skills currently being taught in class were tested from processes to type casting. Other than the fact that I have missed so much lab time I believe the lab was manageable but definitely time consuming. You would have to be extremely focused for the 6 hours lab time and not get stuck on anything trivial to finish in the allotted time.

The most difficult task for me was making the simulator work. I still don’t quite understand what was wrong to force me to get the ‘U’s, but eventually the code started working when I switched to a mealy implementation.

Overall, this lab was very satisfying. Getting to see you work (literally) was extremely encouraging. I would not recommend changing much for the future. As long as a person has paid attention in class and does not waste time, this is manageable. 
 
