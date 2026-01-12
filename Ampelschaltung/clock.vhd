library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.std_definitions.all;

entity clock is
    generic(
        CLKS_PER_HALF_SEC: natural;
        COUNTER_BIT_WIDTH : natural
    );
    port(
        -- inputs
        sys_clk_i : in std_ulogic;
        sys_reset_i : in std_ulogic;

        -- outpus
        time_o: out unsigned(16 downto 0)
    );
end clock;


architecture rtl of clock is
    signal counter_val: unsigned(COUNTER_BIT_WIDTH - 1 downto 0);
    signal next_counter_val: unsigned(COUNTER_BIT_WIDTH - 1 downto 0);
    signal seconds: unsigned(5 downto 0);
    signal next_seconds: unsigned (5 downto 0);
    signal minutes: unsigned(5 downto 0);
    signal next_minutes: unsigned(5 downto 0);
    signal hours: unsigned(4 downto 0);
    signal next_hours: unsigned(4 downto 0);
begin

    time_o <= hours & minutes & seconds;

    counter_comb_proc: process (counter_val) begin
        next_counter_val <= counter_val + 1;
        
        -- reset after 1 sec
        if counter_val = to_unsigned(2*CLKS_PER_HALF_SEC - 1, COUNTER_BIT_WIDTH) then
            next_counter_val <= (others => '0');
        end if;
    end process;

    seconds_comb_proc: process(counter_val, seconds) begin
        next_seconds <= seconds;

        if counter_val = to_unsigned(2*CLKS_PER_HALF_SEC - 1, COUNTER_BIT_WIDTH) then
            if seconds = to_unsigned(59,6) then
                next_seconds <= (others => '0');
            else
                next_seconds <= seconds + 1;
            end if;
        end if;
    end process;

    minutes_comb_proc: process(seconds, next_seconds, minutes) begin
        next_minutes <= minutes;

        if(seconds = to_unsigned(59,6) and next_seconds = to_unsigned(0,6)) then
            if minutes = to_unsigned(59,6) then
                next_minutes <= (others => '0');
            else
                next_minutes <= minutes + 1;
            end if;
        end if;
    end process;

    hours_comb_proc: process(minutes, next_minutes, hours) begin
        next_hours <= hours;

        if(minutes = to_unsigned(59,6) and next_minutes = to_unsigned(0,6)) then
            if hours = to_unsigned(23,5) then
                next_hours <= (others => '0');
            else
                next_hours <= hours + 1;
            end if;
        end if;
    end process;

    clock_reg_proc: process(sys_clk_i, sys_reset_i) begin
        if sys_reset_i = '1' then
            counter_val <= (others => '0');
            seconds <= (others => '0');
            minutes <= (others => '0');
            hours <= (others => '0');
        elsif rising_edge(sys_clk_i) then
            counter_val <= next_counter_val;
            seconds <= next_seconds;
            minutes <= next_minutes;
            hours <= next_hours;
        end if;
    end process;

end architecture;
