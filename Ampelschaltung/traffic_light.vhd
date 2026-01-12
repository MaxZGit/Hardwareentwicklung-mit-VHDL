library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.std_definitions.all;

entity traffic_light is
    generic(
        START_TYPE: std_ulogic;

        RED_YELLOW_PHASE_SEC: natural;
        GREEN_PHASE_SEC: natural;
        GREEN_BLINK_PHASE_SEC: natural;
        YELLOW_PHASE_SEC: natural;
        RED_PHASE_SEC : natural;
        PHASE_COUNTER_BIT_WIDTH: natural;

        GREEN_BLINK_HALF_SECONDS: natural;
        NIGHT_MODE_BLINK_HALF_SECONDS: natural;

        BLINK_COUNTER_BIT_WIDTH: natural
    );
    port(
        -- inputs
        sys_clk_i : in std_ulogic;
        sys_reset_i : in std_ulogic;
        time_i : in unsigned(16 downto 0);

        night_mode_i : in std_ulogic;
        
        -- outputs
        car_ligth_o : out traffic_light_state;
        pedestrian_light_o : out traffic_light_state
    );
end traffic_light;

architecture rtl of traffic_light is

    signal seconds : unsigned(5 downto 0);
    signal prev_seconds : unsigned(5 downto 0);

    signal phase_fsm_state : traffic_light_phase;
    signal next_phase_fsm_state: traffic_light_phase;

    signal phase_counter_val : unsigned(PHASE_COUNTER_BIT_WIDTH - 1 downto 0);
    signal next_phase_counter_val: unsigned(PHASE_COUNTER_BIT_WIDTH -1 downto 0);
    signal new_phase_strb : std_ulogic;

    signal blink_counter_val : unsigned(BLINK_COUNTER_BIT_WIDTH -1 downto 0);
    signal next_blink_counter_val: unsigned(BLINK_COUNTER_BIT_WIDTH -1 downto 0);

    signal blink: std_ulogic;
    signal next_blink: std_ulogic;
begin

    seconds <= time_i(5 downto 0);

    new_phase_strb <= '1' when not(phase_fsm_state = next_phase_fsm_state) else '0';

    -- fsm next state logic
    phase_fsm_next_state_logic: process(phase_fsm_state, phase_counter_val, night_mode_i) begin
        
        -- standard assignment
        next_phase_fsm_state <= phase_fsm_state;


        if night_mode_i = '1' then
            next_phase_fsm_state <= phNIGHT_MODE;
        else

            case phase_fsm_state is
                when phOFF=>
                    if START_TYPE = '0' then
                        next_phase_fsm_state <= phRED;
                    else
                        next_phase_fsm_state <= phRED_YELLOW;
                    end if;

                when phGREEN=>
                    if phase_counter_val = to_unsigned(GREEN_PHASE_SEC, PHASE_COUNTER_BIT_WIDTH) then
                        next_phase_fsm_state <= phGREEN_BLINK;
                    end if;
                when phGREEN_BLINK =>
                    if phase_counter_val = to_unsigned(GREEN_BLINK_PHASE_SEC, PHASE_COUNTER_BIT_WIDTH) then
                        next_phase_fsm_state <= phYELLOW;
                    end if;

                when phYELLOW =>
                    if phase_counter_val = to_unsigned(YELLOW_PHASE_SEC, PHASE_COUNTER_BIT_WIDTH) then
                        next_phase_fsm_state <= phRED;
                    end if;            
                when phRED =>
                    if phase_counter_val = to_unsigned(RED_PHASE_SEC, PHASE_COUNTER_BIT_WIDTH) then
                        next_phase_fsm_state <= phRED_YELLOW;
                    end if; 
                when phRED_YELLOW =>
                    if phase_counter_val = to_unsigned(RED_YELLOW_PHASE_SEC, PHASE_COUNTER_BIT_WIDTH) then
                        next_phase_fsm_state <= phGREEN;
                    end if; 

                when phNIGHT_MODE =>
                    if night_mode_i = '0' then
                        if START_TYPE = '0' then
                            next_phase_fsm_state <= phRED;
                        else
                            next_phase_fsm_state <= phRED_YELLOW;
                        end if;
                    end if;
            end case;
        end if;
    end process;


    -- traffic light assignment
    traffic_light_assignment: process(phase_fsm_state, blink) begin
        --standard assignment
        car_ligth_o <= stOFF;
        pedestrian_light_o <= stOFF;

        case phase_fsm_state is
            when phOFF=>
                car_ligth_o <= stOFF;
                pedestrian_light_o <= stOFF;
            when phGREEN=>
                car_ligth_o <= stGREEN;
                pedestrian_light_o <= stRED;
            when phGREEN_BLINK =>
                if blink = '1' then
                    car_ligth_o <= stGREEN;
                else 
                    car_ligth_o <= stOFF;
                end if;
                pedestrian_light_o <= stRED;
            when phYELLOW =>
                car_ligth_o <= stYELLOW;
                pedestrian_light_o <= stRED;
            when phRED =>
                car_ligth_o <= stRED;
                pedestrian_light_o <= stGREEN;
            when phRED_YELLOW =>
                car_ligth_o <= stRED_YELLOW;
                if blink = '1' then
                    pedestrian_light_o <= stGREEN;
                else 
                    pedestrian_light_o <= stOFF;
                end if;
            when phNIGHT_MODE =>
                pedestrian_light_o <= stOFF;
                if blink = '1' then
                    car_ligth_o <= stYELLOW;
                else 
                    car_ligth_o <= stOFF;
                end if;
        end case;
    end process;


    -- counter for counting seconds for traffic light phases
    phase_counter_comb_proc: process(new_phase_strb, seconds, prev_seconds, phase_counter_val) begin
        next_phase_counter_val <= phase_counter_val;

        if new_phase_strb = '1' then
            next_phase_counter_val <= (others => '0');
        elsif not (prev_seconds = seconds) then -- only count up when seconds flip
            next_phase_counter_val <= phase_counter_val + 1;
        end if;
    end process;

    -- counter for counting time for blinking phases and set blink register
    blink_counter_comb_proc: process(phase_fsm_state, new_phase_strb, blink_counter_val, blink) begin
        -- standard assignment
        next_blink_counter_val <= blink_counter_val;
        next_blink <= blink;

        -- reset counter before every next phase
        if new_phase_strb = '1' then
            next_blink_counter_val <= (others => '0');
            next_blink <= '0';
        else

            -- GREEN BLINK PHASE
            if phase_fsm_state = phGREEN_BLINK or phase_fsm_state = phRED_YELLOW then
                if blink_counter_val = to_unsigned((CLKS_PER_HALF_SEC * GREEN_BLINK_HALF_SECONDS) - 1, BLINK_COUNTER_BIT_WIDTH) then
                    next_blink <= not blink;
                    next_blink_counter_val <= (others => '0');
                else
                    next_blink_counter_val <= blink_counter_val + 1;
                end if;
            end if;

            -- NIGHT MODE BLINK PHASE
            if phase_fsm_state = phNIGHT_MODE then
                if blink_counter_val = to_unsigned((CLKS_PER_HALF_SEC *NIGHT_MODE_BLINK_HALF_SECONDS) - 1, BLINK_COUNTER_BIT_WIDTH) then
                    next_blink <= not blink;
                    next_blink_counter_val <= (others => '0');
                else
                    next_blink_counter_val <= blink_counter_val + 1;
                end if;
            end if;
        end if;
    end process;

    -- register process
    reg_proc: process(sys_clk_i, sys_reset_i) begin
        if sys_reset_i = '1' then
            phase_counter_val <= (others => '0');
            blink_counter_val <= (others => '0');
            phase_fsm_state <= phOFF;
            blink <= '0';
            prev_seconds <= (others => '0');
        elsif rising_edge(sys_clk_i) then
            phase_counter_val <= next_phase_counter_val;
            blink_counter_val <= next_blink_counter_val;
            phase_fsm_state <= next_phase_fsm_state;
            blink <= next_blink;
            prev_seconds <= seconds;
        end if;
    end process;

end architecture;