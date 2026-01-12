library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sync_debounce_tb is
end sync_debounce_tb;

architecture Behavioral of sync_debounce_tb is

     -- tb signals
    signal sys_clk_tb: std_logic := '0';
    signal sys_rst_tb: std_logic := '1';

    signal button_tb: std_logic := '0';
    signal output_tb: std_logic;

begin

    input_debounce_comp: entity work.sync_debounce(rtl)
    generic map(
        REGISTER_COUNT => 3,
        DEBOUNCE_CLK_CYCLES => 2000,
        COUNTER_BIT_WIDTH => 11
    )
    port map (
        input_i => button_tb,
        clk_i => sys_clk_tb,
        reset_i => sys_rst_tb,
        output_o => output_tb
    );

    sys_clk_tb <= not sys_clk_tb after (5) * 1 us;

    stimuli: process begin

        -- simluation time ~ 100 ms!

        -- reset
        sys_rst_tb <= '1';
        wait for 100 us;
        sys_rst_tb <= '0';
        wait for 1 ms;

        -- wait so the btn is not aligned with the clock (for testing synchronization)
        wait for 2 us;
        -- Bouncing Press (~15 ms, ~10 bounces)
        button_tb <= '1'; wait for 1.2 ms;
        button_tb <= '0'; wait for 0.9 ms;
        button_tb <= '1'; wait for 1.5 ms;
        button_tb <= '0'; wait for 1.3 ms;
        button_tb <= '1'; wait for 1.1 ms;
        button_tb <= '0'; wait for 1.4 ms;
        button_tb <= '1'; wait for 1.6 ms;
        button_tb <= '0'; wait for 1.0 ms;
        button_tb <= '1'; wait for 1.2 ms;
        button_tb <= '1';  -- finally stable pressed

        -- Stable Press (25 ms)
        wait for 25 ms;

        -- Bouncing Release (~15 ms, ~10 bounces)
        button_tb <= '0'; wait for 1.0 ms;
        button_tb <= '1'; wait for 1.3 ms;
        button_tb <= '0'; wait for 1.1 ms;
        button_tb <= '1'; wait for 1.6 ms;
        button_tb <= '0'; wait for 1.4 ms;
        button_tb <= '1'; wait for 1.2 ms;
        button_tb <= '0'; wait for 1.5 ms;
        button_tb <= '1'; wait for 1.0 ms;
        button_tb <= '0'; wait for 1.3 ms;
        button_tb <= '0';  -- finally stable released

        -- Stable Released (25 ms)
        wait for 25 ms;

        -- End of test
        wait;
    end process stimuli;
end architecture;