library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stepper_position_controller is
    generic (
        CLK_FREQ_HZ        : positive := 100_000_000;
        HOMING_DIR         : std_logic := '1';  -- '1' = calibra verso il muro
        POST_HOMING_OFFSET : integer   := 0     -- passi da fare indietro dopo il muro
    );
    port (
        clk               : in  std_logic;
        rst               : in  std_logic;
        start_calibration : in  std_logic;
        target_position   : in  integer;
        invert_direction  : in  std_logic;
        calibrated        : out std_logic;
        busy              : out std_logic;
        coils             : out std_logic_vector(3 downto 0)
    );
end entity;

architecture rtl of stepper_position_controller is
    constant HOMING_STEP_HZ   : integer := 400;   -- velocità homing
    constant RUN_STEP_HZ      : integer := 500;   -- velocità normale
    constant REQ_HOMING_STEPS : integer := 2000;  -- passi per raggiungere il muro

    type state_t is (IDLE, CALIB_MOVE, CALIB_WAIT, POST_HOMING_MOVE, POST_HOMING_WAIT, READY, MOVE);
    signal state : state_t := IDLE;
    type step_state_t is (S0,S1,S2,S3,S4,S5,S6,S7);
    signal step_state : step_state_t := S0;

    signal current_pos  : integer := 0;
    signal tick_cnt     : integer := 0;
    signal wait_cnt     : integer := 0;
    signal homing_steps : integer := 0;
    signal backoff_steps: integer := 0;

    signal calibrated_i : std_logic := '0';
begin
    calibrated <= calibrated_i;

    process(state) begin
        if state = READY then busy <= '0'; else busy <= '1'; end if;
    end process;

    process(clk)
        variable act_dir : std_logic;
        variable log_dir : std_logic;
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= IDLE;
                calibrated_i <= '0';
            else
                case state is
                    when IDLE =>
                        if start_calibration = '1' then
                            state <= CALIB_MOVE;
                            tick_cnt <= 0;
                            homing_steps <= 0;
                        end if;

                    when CALIB_MOVE =>
                        if tick_cnt >= (CLK_FREQ_HZ / HOMING_STEP_HZ) then
                            tick_cnt <= 0;
                            act_dir := HOMING_DIR xor invert_direction;
                            if act_dir = '1' then
                                case step_state is
                                    when S0=>step_state<=S1; when S1=>step_state<=S2; when S2=>step_state<=S3; when S3=>step_state<=S4;
                                    when S4=>step_state<=S5; when S5=>step_state<=S6; when S6=>step_state<=S7; when others=>step_state<=S0;
                                end case;
                            else
                                case step_state is
                                    when S0=>step_state<=S7; when S7=>step_state<=S6; when S6=>step_state<=S5; when S5=>step_state<=S4;
                                    when S4=>step_state<=S3; when S3=>step_state<=S2; when S2=>step_state<=S1; when others=>step_state<=S0;
                                end case;
                            end if;
                            homing_steps <= homing_steps + 1;
                            if homing_steps >= REQ_HOMING_STEPS then
                                state <= CALIB_WAIT;
                                wait_cnt <= 0;
                            end if;
                        else
                            tick_cnt <= tick_cnt + 1;
                        end if;

                    when CALIB_WAIT =>
                        if wait_cnt >= (CLK_FREQ_HZ/10) then
                            if POST_HOMING_OFFSET > 0 then
                                state <= POST_HOMING_MOVE;
                                tick_cnt <= 0;
                                backoff_steps <= 0;
                                current_pos <= 0;
                            else
                                current_pos <= 0;
                                calibrated_i <= '1';
                                state <= READY;
                            end if;
                        else
                            wait_cnt <= wait_cnt + 1;
                        end if;

                    when POST_HOMING_MOVE =>
                        if tick_cnt >= (CLK_FREQ_HZ / HOMING_STEP_HZ) then
                            tick_cnt <= 0;
                            act_dir := not (HOMING_DIR xor invert_direction);
                            if act_dir = '1' then
                                case step_state is
                                    when S0=>step_state<=S1; when S1=>step_state<=S2; when S2=>step_state<=S3; when S3=>step_state<=S4;
                                    when S4=>step_state<=S5; when S5=>step_state<=S6; when S6=>step_state<=S7; when others=>step_state<=S0;
                                end case;
                            else
                                case step_state is
                                    when S0=>step_state<=S7; when S7=>step_state<=S6; when S6=>step_state<=S5; when S5=>step_state<=S4;
                                    when S4=>step_state<=S3; when S3=>step_state<=S2; when S2=>step_state<=S1; when others=>step_state<=S0;
                                end case;
                            end if;
                            backoff_steps <= backoff_steps + 1;
                            current_pos <= current_pos + 1;
                            if backoff_steps >= POST_HOMING_OFFSET - 1 then
                                state <= POST_HOMING_WAIT;
                                wait_cnt <= 0;
                            end if;
                        else
                            tick_cnt <= tick_cnt + 1;
                        end if;

                    when POST_HOMING_WAIT =>
                        if wait_cnt >= (CLK_FREQ_HZ/10) then
                            calibrated_i <= '1';
                            state <= READY;
                        else
                            wait_cnt <= wait_cnt + 1;
                        end if;

                    when READY =>
                        if target_position /= current_pos then
                            state <= MOVE;
                            tick_cnt <= 0;
                        end if;

                    when MOVE =>
                        if current_pos = target_position then
                            state <= READY;
                        elsif tick_cnt >= (CLK_FREQ_HZ / RUN_STEP_HZ) then
                            tick_cnt <= 0;
                            if target_position > current_pos then
                                log_dir := '1';
                            else
                                log_dir := '0';
                            end if;
                            act_dir := (not log_dir) xor invert_direction;
                            if act_dir = '1' then
                                case step_state is
                                    when S0=>step_state<=S1; when S1=>step_state<=S2; when S2=>step_state<=S3; when S3=>step_state<=S4;
                                    when S4=>step_state<=S5; when S5=>step_state<=S6; when S6=>step_state<=S7; when others=>step_state<=S0;
                                end case;
                            else
                                case step_state is
                                    when S0=>step_state<=S7; when S7=>step_state<=S6; when S6=>step_state<=S5; when S5=>step_state<=S4;
                                    when S4=>step_state<=S3; when S3=>step_state<=S2; when S2=>step_state<=S1; when others=>step_state<=S0;
                                end case;
                            end if;
                            if log_dir = '1' then
                                current_pos <= current_pos + 1;
                            else
                                current_pos <= current_pos - 1;
                            end if;
                        else
                            tick_cnt <= tick_cnt + 1;
                        end if;
                end case;
            end if;
        end if;
    end process;

    process(step_state) begin
        case step_state is
            when S0=>coils<="1000"; when S1=>coils<="1100"; when S2=>coils<="0100"; when S3=>coils<="0110";
            when S4=>coils<="0010"; when S5=>coils<="0011"; when S6=>coils<="0001"; when others=>coils<="1001";
        end case;
    end process;
end architecture;