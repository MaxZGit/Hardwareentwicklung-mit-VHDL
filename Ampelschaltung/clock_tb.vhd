library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.std_definitions.all;


entity clock_tb is
end;

architecture rtl of clock_tb is
    signal clk_tb : std_ulogic := '0';
    signal reset_tb : std_ulogic := '1';
    signal time_tb : unsigned(16 downto 0);

    signal seconds_tb: unsigned(5 downto 0);
    signal minutes_tb: unsigned(5 downto 0);
    signal hours_tb: unsigned(4 downto 0);

begin
    bhv: entity work.clock(rtl)
    generic map(
        CLKS_PER_HALF_SEC => CLKS_PER_HALF_SEC,
        COUNTER_BIT_WIDTH => CLOCK_COUNTER_BIT_WIDTH
    )
    port map(
        sys_clk_i => clk_tb,
        sys_reset_i => reset_tb,
        time_o => time_tb
    );
    
    clk_tb <= not clk_tb after (CLK_PERIOD/2);

    seconds_tb <= time_tb(5 downto 0);
    minutes_tb <= time_tb(11 downto 6);
    hours_tb <= time_tb(16 downto 12);
    
    stimuli: process begin
        wait for 1 us;
        reset_tb <= '0';
        wait for 5 ms;
        
        wait;
    end process stimuli;
end architecture rtl;