library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity synchronizer is
    generic (
        REGISTER_COUNT: natural
    );
    port(
        input_i: in std_ulogic;
        clk_i: in std_ulogic;
        reset_i: in std_logic;
        output_o: out std_ulogic
    );
end entity synchronizer;

architecture rtl of synchronizer is
    signal sync_values : std_ulogic_vector(REGISTER_COUNT-1 downto 0):=(others => '0');
    signal next_sync_values : std_ulogic_vector(REGISTER_COUNT-1 downto 0):=(others => '0');
begin
    
    output_o <= sync_values(REGISTER_COUNT-1); -- last one is the output
    
    sync_logic: process(sync_values, input_i) begin
        next_sync_values <= sync_values;
        next_sync_values(0) <= input_i;
        for i in 1 to REGISTER_COUNT-1 loop
            next_sync_values(i) <= sync_values(i-1); -- shift to next FF
        end loop;
        
    end process sync_logic;
    
    reg_proc: process(clk_i, reset_i) begin
        if reset_i = '1' then
            sync_values <= (others => '0');
        elsif rising_edge(clk_i) then
            sync_values <= next_sync_values;
        end if;
    end process;
    
end rtl;