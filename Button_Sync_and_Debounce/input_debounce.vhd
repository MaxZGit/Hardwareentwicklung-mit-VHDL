library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity input_debounce is
    generic (
        DEBOUNCE_CLK_CYCLES : natural;
        COUNTER_BIT_WIDTH   : natural
    );
    port (
        input_i  : in  std_ulogic;
        clk_i    : in  std_ulogic;
        reset_i  : in  std_logic;
        output_o : out std_ulogic
    );
end entity;

architecture rtl of input_debounce is
    type debounce_fsm_state is (stIDLE, stRISING_EDGE, stFALLING_EDGE);

    signal counter         : unsigned(COUNTER_BIT_WIDTH-1 downto 0) := (others => '0');
    signal next_counter    : unsigned(COUNTER_BIT_WIDTH-1 downto 0);
    signal fsm_state       : debounce_fsm_state := stIDLE;
    signal next_fsm_state  : debounce_fsm_state;

    signal prev_input      : std_ulogic := '0';  -- previous input (1 cycle delayed)

    signal rising_edge_detected   : std_logic := '0';
    signal falling_edge_detected  : std_logic := '0';
begin

    -- Edge detection: detect change between current and previous input
    rising_edge_detected <= '1' when input_i = '1' and prev_input = '0' else '0';
    falling_edge_detected <= '1' when input_i = '0' and prev_input = '1' else '0';

    -- output_logic
    output_logic: process(prev_input, fsm_state)
    begin
        output_o <= prev_input;
        if fsm_state = stRISING_EDGE then
            output_o <= '1';
        elsif fsm_state = stFALLING_EDGE then
            output_o <= '0';
        end if;
    end process;

    -- FSM and counter logic
    fsm_proc: process(fsm_state, rising_edge_detected, falling_edge_detected, counter)
    begin
        next_fsm_state <= fsm_state;
        next_counter <= counter + 1;

        case fsm_state is
            when stIDLE =>
                next_counter   <= (others => '0');  -- reset debounce timer
                if rising_edge_detected = '1' then
                    next_fsm_state <= stRISING_EDGE;
                end if;
                if falling_edge_detected = '1' then
                    next_fsm_state <= stFALLING_EDGE;
                end if;

            when stRISING_EDGE =>
                if counter >= to_unsigned(DEBOUNCE_CLK_CYCLES-1, COUNTER_BIT_WIDTH) then
                    next_fsm_state <= stIDLE;
                end if;
            
            when stFALLING_EDGE => 
                if counter >= to_unsigned(DEBOUNCE_CLK_CYCLES-1, COUNTER_BIT_WIDTH) then
                    next_fsm_state <= stIDLE;
                end if;
        end case;
    end process;


    -- register process
    reg_proc: process(clk_i, reset_i)
    begin
        if reset_i = '1' then
            prev_input   <= '0';
            counter      <= (others => '0');
            fsm_state    <= stIDLE;
        elsif rising_edge(clk_i) then
            prev_input   <= input_i;
            counter      <= next_counter;
            fsm_state    <= next_fsm_state;
        end if;
    end process;
end architecture;
