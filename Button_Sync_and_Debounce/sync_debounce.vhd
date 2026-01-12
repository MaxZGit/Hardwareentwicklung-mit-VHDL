library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sync_debounce is
    generic (
        -- register count for synchronization (most of the time 2 is enough, to be safe choose 3)
        REGISTER_COUNT: natural;
        -- number of clk cycles that the debouncer waits after detecting a button press/release (should be around 20ms)
        DEBOUNCE_CLK_CYCLES : natural;
        -- bit width of the counter that is used for waiting the DEBOUNCE_CLK_CYCLES, make sure the BIT_WIDTH is large enough!
        COUNTER_BIT_WIDTH   : natural
    );
    port (
        input_i  : in  std_ulogic;
        clk_i    : in  std_ulogic;
        reset_i  : in  std_logic;
        output_o : out std_ulogic
    );
end entity;

architecture rtl of sync_debounce is
    signal signal_sync : std_ulogic;
begin

    --------------------
    -- Components
    --------------------

    -- synchronizer
    synchronizer: entity work.synchronizer(rtl)
        generic map(
            REGISTER_COUNT => REGISTER_COUNT
        )
        port map(
            input_i => input_i,
            clk_i => clk_i,
            reset_i => reset_i,
            output_o => signal_sync
        );

    -- debouncer
    debouncer: entity work.input_debounce(rtl)
        generic map(
            DEBOUNCE_CLK_CYCLES => DEBOUNCE_CLK_CYCLES,
            COUNTER_BIT_WIDTH => COUNTER_BIT_WIDTH
        )
        port map(
            input_i => signal_sync,
            clk_i => clk_i,
            reset_i => reset_i,
            output_o => output_o
        );
end architecture rtl;