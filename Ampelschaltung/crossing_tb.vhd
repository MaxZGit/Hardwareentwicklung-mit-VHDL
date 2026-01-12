library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.std_definitions.all;


entity crossing_tb is
end;

architecture rtl of crossing_tb is
    signal clk_tb : std_ulogic := '0';
    signal reset_tb : std_ulogic := '1';

    signal car_light_vertical_tb : traffic_light_state;
    signal pedestrian_light_vertical_tb : traffic_light_state;
    signal car_light_horizontal_tb : traffic_light_state;        
    signal pedestrian_light_horizontal_tb : traffic_light_state;
begin
    bhv: entity work.crossing(rtl)
    generic map(
        -- CLOCK
        CLKS_PER_HALF_SEC =>  CLKS_PER_HALF_SEC,
        CLOCK_COUNTER_BIT_WIDTH => CLOCK_COUNTER_BIT_WIDTH,

        -- TRAFFIC LIGHT
        RED_YELLOW_PHASE_SEC => RED_YELLOW_PHASE_SEC,
        GREEN_PHASE_SEC => GREEN_PHASE_SEC,
        GREEN_BLINK_PHASE_SEC => GREEN_BLINK_PHASE_SEC,
        YELLOW_PHASE_SEC => YELLOW_PHASE_SEC,
        RED_PHASE_SEC => RED_PHASE_SEC,
        PHASE_COUNTER_BIT_WIDTH => PHASE_COUNTER_BIT_WIDTH,

        GREEN_BLINK_HALF_SECONDS => GREEN_BLINK_HALF_SECONDS,
        NIGHT_MODE_BLINK_HALF_SECONDS => NIGHT_MODE_BLINK_HALF_SECONDS,

        BLINK_COUNTER_BIT_WIDTH => BLINK_COUNTER_BIT_WIDTH,

        -- NIGHT MODE
        START_NP => START_NP,
        END_NP => END_NP
    )
    port map(
        sys_clk_i => clk_tb,
        sys_reset_i => reset_tb,

        car_light_vertical_o => car_light_vertical_tb,
        pedestrian_light_vertical_o => pedestrian_light_vertical_tb,
        car_light_horizontal_o => car_light_horizontal_tb,       
        pedestrian_light_horizontal_o => pedestrian_light_horizontal_tb
    );
    
    clk_tb <= not clk_tb after (CLK_PERIOD/2);
    
    stimuli: process begin
        wait for 100 ns;
        reset_tb <= '0';
        wait;
    end process stimuli;
end architecture rtl;