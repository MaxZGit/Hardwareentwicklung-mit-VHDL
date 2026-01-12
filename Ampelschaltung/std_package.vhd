library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package std_definitions is

    --###########################################
    --  USER SETTINGS (customizable)
    --###########################################
    -- traffic light phases (IN SECONDS)
    constant RED_YELLOW_PHASE_SEC: natural := 4;
    constant GREEN_PHASE_SEC: natural := 60;
    constant GREEN_BLINK_PHASE_SEC: natural := 4;
    constant YELLOW_PHASE_SEC: natural := 4;

    constant GREEN_BLINK_HALF_SECONDS: natural := 1; -- set to 1 and GREEN_BLINK_PHASE_SEC to 4 for 4 BLINKS a 0.5 sec!!
    constant NIGHT_MODE_BLINK_HALF_SECONDS: natural := 2;

    -- start night mode
    constant START_NP_H: natural := 22;
    constant START_NP_M: natural := 0;
    -- end night mode
    constant END_NP_H: natural := 5;
    constant END_NP_M: natural := 30; 

    -- clk period
    constant CLK_PERIOD: time := 10 ns; --100 Hz -> 10 ms periode
    constant CLK_FREQUENCY: natural := 4; -- 100 Hz
    constant CLKS_PER_HALF_SEC: natural := CLK_FREQUENCY / 2;
    constant CLOCK_COUNTER_BIT_WIDTH: natural := natural(ceil(log2(real(CLKS_PER_HALF_SEC))))+1; -- counter bit width to create a counter to be able to count to CLKS_PER_HALF_MINUTE max 

    -- States
    type traffic_light_state is (stOFF, stGREEN, stYELLOW, stRED, stRED_YELLOW);

    -- phases of a traffic light
    type traffic_light_phase is(phOFF, phGREEN, phGREEN_BLINK, phYELLOW, phRED, phRED_YELLOW, phNIGHT_MODE);
    
    -- traffic light red phase
    constant RED_PHASE_SEC: natural := RED_YELLOW_PHASE_SEC + GREEN_PHASE_SEC + GREEN_BLINK_PHASE_SEC + YELLOW_PHASE_SEC;

    -- counter bit width to count to the !BIGGEST! traffic light phase
    constant PHASE_COUNTER_BIT_WIDTH: natural := natural(ceil(log2(real(RED_PHASE_SEC))))+1; 

     -- USE THE BIGGEST ONE OF GREEN_BLINK_HALF_SECONDS and NIGHT_MODE_BLINK_HALF_SECONDS
    constant BLINK_COUNTER_BIT_WIDTH : natural := natural(ceil(log2(real(NIGHT_MODE_BLINK_HALF_SECONDS * CLKS_PER_HALF_SEC)))) + 1;
    

    -- start and endtime for all yellow phase
    constant START_NP : unsigned(10 downto 0) := to_unsigned(START_NP_H, 5) & to_unsigned(START_NP_M, 6);
    constant END_NP : unsigned(10 downto 0) := to_unsigned(END_NP_H, 5) & to_unsigned(END_NP_M, 6);



    
end package std_definitions;
