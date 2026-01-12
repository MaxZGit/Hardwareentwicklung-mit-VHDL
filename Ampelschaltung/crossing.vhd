library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.std_definitions.all;

entity crossing is
    generic(
        -- CLOCK
        CLKS_PER_HALF_SEC: natural;
        CLOCK_COUNTER_BIT_WIDTH: natural;

        -- TRAFFIC LIGHT
        RED_YELLOW_PHASE_SEC: natural;
        GREEN_PHASE_SEC: natural;
        GREEN_BLINK_PHASE_SEC: natural;
        YELLOW_PHASE_SEC: natural;
        RED_PHASE_SEC : natural;
        PHASE_COUNTER_BIT_WIDTH: natural;

        GREEN_BLINK_HALF_SECONDS: natural;
        NIGHT_MODE_BLINK_HALF_SECONDS: natural;

        BLINK_COUNTER_BIT_WIDTH: natural;

        -- NIGHT MODE
        START_NP: unsigned(10 downto 0);
        END_NP: unsigned(10 downto 0)
    );
    port(
        -- inputs
        sys_clk_i : in std_ulogic;
        sys_reset_i : in std_ulogic;

        -- outputs
        car_light_vertical_o : out traffic_light_state;
        pedestrian_light_vertical_o : out traffic_light_state;
        car_light_horizontal_o : out traffic_light_state;        
        pedestrian_light_horizontal_o : out traffic_light_state
    );
end crossing;


architecture rtl of crossing is
    signal clock_time : unsigned(16 downto 0);
    signal night_mode : std_ulogic;
    signal time_overflow : std_ulogic;
begin

    -- set night mode
    time_overflow <= '1' when START_NP > END_NP else '0';

    nicht_mode_proc: process(clock_time, time_overflow) begin
        if time_overflow = '0' then
            if START_NP < clock_time(16 downto 6) and clock_time(16 downto 6) < END_NP then
                night_mode <= '1';
            else
                night_mode <= '0';
            end if;
        else
            if START_NP > clock_time(16 downto 6) and clock_time(16 downto 6) > END_NP then
                night_mode <= '0';
            else
                night_mode <= '1';
            end if;
        end if;
    end process;

    -- ############################################################################
    -- ###################### COMPONENTS ##########################################
    -- ############################################################################

    -- CLOCK
    clock: entity work.clock(rtl)
    generic map(
        CLKS_PER_HALF_SEC => CLKS_PER_HALF_SEC,
        COUNTER_BIT_WIDTH => CLOCK_COUNTER_BIT_WIDTH
    )
    port map(
        sys_clk_i => sys_clk_i,
        sys_reset_i => sys_reset_i,
        time_o => clock_time
    );

    -- Traffic Light Horizontal
    tl_h : entity work.traffic_light(rtl)
    generic map(
        START_TYPE => '0',

        RED_YELLOW_PHASE_SEC => RED_YELLOW_PHASE_SEC,
        GREEN_PHASE_SEC =>GREEN_PHASE_SEC,
        GREEN_BLINK_PHASE_SEC => GREEN_BLINK_PHASE_SEC,
        YELLOW_PHASE_SEC => YELLOW_PHASE_SEC,
        RED_PHASE_SEC => RED_PHASE_SEC,
        PHASE_COUNTER_BIT_WIDTH => PHASE_COUNTER_BIT_WIDTH,

        GREEN_BLINK_HALF_SECONDS => GREEN_BLINK_HALF_SECONDS,
        NIGHT_MODE_BLINK_HALF_SECONDS => NIGHT_MODE_BLINK_HALF_SECONDS,

        BLINK_COUNTER_BIT_WIDTH => BLINK_COUNTER_BIT_WIDTH
    )
    port map(
        -- inputs
        sys_clk_i => sys_clk_i,
        sys_reset_i => sys_reset_i,
        time_i => clock_time,

        night_mode_i => night_mode,
        
        -- outputs
        car_ligth_o => car_light_horizontal_o,
        pedestrian_light_o => pedestrian_light_horizontal_o
    );

    -- Traffic Light Vertical
    tl_v : entity work.traffic_light(rtl)
    generic map(
        START_TYPE => '1',

        RED_YELLOW_PHASE_SEC => RED_YELLOW_PHASE_SEC,
        GREEN_PHASE_SEC =>GREEN_PHASE_SEC,
        GREEN_BLINK_PHASE_SEC => GREEN_BLINK_PHASE_SEC,
        YELLOW_PHASE_SEC => YELLOW_PHASE_SEC,
        RED_PHASE_SEC => RED_PHASE_SEC,
        PHASE_COUNTER_BIT_WIDTH => PHASE_COUNTER_BIT_WIDTH,

        GREEN_BLINK_HALF_SECONDS => GREEN_BLINK_HALF_SECONDS,
        NIGHT_MODE_BLINK_HALF_SECONDS => NIGHT_MODE_BLINK_HALF_SECONDS,

        BLINK_COUNTER_BIT_WIDTH => BLINK_COUNTER_BIT_WIDTH
    )
    port map(
        -- inputs
        sys_clk_i => sys_clk_i,
        sys_reset_i => sys_reset_i,
        time_i => clock_time,

        night_mode_i => night_mode,
        
        -- outputs
        car_ligth_o => car_light_vertical_o,
        pedestrian_light_o => pedestrian_light_vertical_o
    );

end architecture;
