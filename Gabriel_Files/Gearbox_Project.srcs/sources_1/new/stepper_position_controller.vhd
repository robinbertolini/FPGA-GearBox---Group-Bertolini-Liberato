--------------------------------------------------------------------------------
-- Entity : stepper_position_controller
--
-- Purpose:
--   Absolute-position controller for 28BYJ-48 stepper motors.
--
-- FIXED BUGS:
--   • Proper homing-step counting
--   • Proper target arrival detection
--   • No overshoot oscillation
--   • Stable MOVE state behavior
--   • Correct calibration timing
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stepper_position_controller is
    generic (
        CLK_FREQ_HZ : positive := 100_000_000
    );
    port (
        clk : in std_logic;
        rst : in std_logic;

        ------------------------------------------------------------------------
        -- CONTROL
        ------------------------------------------------------------------------
        start_calibration : in std_logic;

        target_position   : in integer;

        invert_direction  : in std_logic;

        ------------------------------------------------------------------------
        -- STATUS
        ------------------------------------------------------------------------
        calibrated : out std_logic;
        busy       : out std_logic;

        ------------------------------------------------------------------------
        -- MOTOR OUTPUTS
        ------------------------------------------------------------------------
        coils : out std_logic_vector(3 downto 0)
    );
end entity;

architecture rtl of stepper_position_controller is

    ----------------------------------------------------------------------------
    -- USER SETTINGS
    ----------------------------------------------------------------------------

    constant HOMING_STEP_HZ : integer := 150;
    constant RUN_STEP_HZ    : integer := 500;

    constant HOMING_TIME_MS : integer := 1200;
    constant WALL_WAIT_MS   : integer := 500;

    ----------------------------------------------------------------------------
    -- CLOCK COUNTS
    ----------------------------------------------------------------------------

    constant HOMING_STEP_COUNT :
        integer := CLK_FREQ_HZ / HOMING_STEP_HZ;

    constant RUN_STEP_COUNT :
        integer := CLK_FREQ_HZ / RUN_STEP_HZ;

    constant WALL_WAIT_COUNT :
        integer := (CLK_FREQ_HZ / 1000) * WALL_WAIT_MS;

    ----------------------------------------------------------------------------
    -- HOMING STEP COUNT
    ----------------------------------------------------------------------------

    constant REQUIRED_HOMING_STEPS :
        integer := (HOMING_STEP_HZ * HOMING_TIME_MS) / 1000;

    ----------------------------------------------------------------------------
    -- FSM
    ----------------------------------------------------------------------------

    type state_t is (
        IDLE,
        CALIB_MOVE,
        CALIB_WAIT,
        READY,
        MOVE
    );

    signal state : state_t := IDLE;

    ----------------------------------------------------------------------------
    -- HALF STEP FSM
    ----------------------------------------------------------------------------

    type step_state_t is (
        S0,S1,S2,S3,S4,S5,S6,S7
    );

    signal step_state : step_state_t := S0;

    ----------------------------------------------------------------------------
    -- POSITION
    ----------------------------------------------------------------------------

    signal current_position : integer := 0;

    ----------------------------------------------------------------------------
    -- COUNTERS
    ----------------------------------------------------------------------------

    signal tick_counter  : integer := 0;
    signal wait_counter  : integer := 0;
    signal homing_steps  : integer := 0;

    ----------------------------------------------------------------------------
    -- INTERNAL FLAGS
    ----------------------------------------------------------------------------

    signal calibrated_i : std_logic := '0';
    signal busy_i       : std_logic := '1';

begin

    calibrated <= calibrated_i;
    busy       <= busy_i;

    ----------------------------------------------------------------------------
    -- MAIN FSM
    ----------------------------------------------------------------------------

    process(clk)

        variable desired_dir : std_logic;

    begin
        if rising_edge(clk) then

            if rst = '1' then

                state <= IDLE;

                step_state <= S0;

                current_position <= 0;

                calibrated_i <= '0';
                busy_i <= '1';

                tick_counter <= 0;
                wait_counter <= 0;
                homing_steps <= 0;

            else

                case state is

                    ----------------------------------------------------------------
                    -- IDLE
                    ----------------------------------------------------------------

                    when IDLE =>

                        busy_i <= '1';

                        if start_calibration = '1' then

                            state <= CALIB_MOVE;

                            tick_counter <= 0;
                            homing_steps <= 0;

                        end if;

                    ----------------------------------------------------------------
                    -- MOVE INTO WALL
                    ----------------------------------------------------------------

                    when CALIB_MOVE =>

                        busy_i <= '1';

                        if tick_counter >= HOMING_STEP_COUNT then

                            tick_counter <= 0;

                            ----------------------------------------------------------------
                            -- MOVE TOWARD WALL
                            ----------------------------------------------------------------

                            if invert_direction = '0' then

                                case step_state is
                                    when S0 => step_state <= S1;
                                    when S1 => step_state <= S2;
                                    when S2 => step_state <= S3;
                                    when S3 => step_state <= S4;
                                    when S4 => step_state <= S5;
                                    when S5 => step_state <= S6;
                                    when S6 => step_state <= S7;
                                    when others => step_state <= S0;
                                end case;

                            else

                                case step_state is
                                    when S0 => step_state <= S7;
                                    when S7 => step_state <= S6;
                                    when S6 => step_state <= S5;
                                    when S5 => step_state <= S4;
                                    when S4 => step_state <= S3;
                                    when S3 => step_state <= S2;
                                    when S2 => step_state <= S1;
                                    when others => step_state <= S0;
                                end case;

                            end if;

                            homing_steps <= homing_steps + 1;

                            ----------------------------------------------------------------
                            -- DONE HOMING
                            ----------------------------------------------------------------

                            if homing_steps >= REQUIRED_HOMING_STEPS then

                                state <= CALIB_WAIT;

                                wait_counter <= 0;

                            end if;

                        else

                            tick_counter <= tick_counter + 1;

                        end if;

                    ----------------------------------------------------------------
                    -- HOLD AGAINST WALL
                    ----------------------------------------------------------------

                    when CALIB_WAIT =>

                        if wait_counter >= WALL_WAIT_COUNT then

                            current_position <= 0;

                            calibrated_i <= '1';

                            state <= READY;

                        else

                            wait_counter <= wait_counter + 1;

                        end if;

                    ----------------------------------------------------------------
                    -- READY
                    ----------------------------------------------------------------

                    when READY =>

                        busy_i <= '0';

                        if target_position /= current_position then

                            busy_i <= '1';

                            state <= MOVE;

                            tick_counter <= 0;

                        end if;

                    ----------------------------------------------------------------
                    -- MOVE TO TARGET POSITION
                    ----------------------------------------------------------------

                    when MOVE =>

                        ----------------------------------------------------------------
                        -- ARRIVED
                        ----------------------------------------------------------------

                        if current_position = target_position then

                            state <= READY;

                        else

                            ----------------------------------------------------------------
                            -- DETERMINE DIRECTION
                            ----------------------------------------------------------------

                            if target_position > current_position then
                                desired_dir := '1';
                            else
                                desired_dir := '0';
                            end if;

                            if invert_direction = '1' then
                                desired_dir := not desired_dir;
                            end if;

                            ----------------------------------------------------------------
                            -- STEP TIMING
                            ----------------------------------------------------------------

                            if tick_counter >= RUN_STEP_COUNT then

                                tick_counter <= 0;

                                ----------------------------------------------------------------
                                -- FORWARD
                                ----------------------------------------------------------------

                                if desired_dir = '1' then

                                    case step_state is
                                        when S0 => step_state <= S1;
                                        when S1 => step_state <= S2;
                                        when S2 => step_state <= S3;
                                        when S3 => step_state <= S4;
                                        when S4 => step_state <= S5;
                                        when S5 => step_state <= S6;
                                        when S6 => step_state <= S7;
                                        when others => step_state <= S0;
                                    end case;

                                    current_position <= current_position + 1;

                                ----------------------------------------------------------------
                                -- REVERSE
                                ----------------------------------------------------------------

                                else

                                    case step_state is
                                        when S0 => step_state <= S7;
                                        when S7 => step_state <= S6;
                                        when S6 => step_state <= S5;
                                        when S5 => step_state <= S4;
                                        when S4 => step_state <= S3;
                                        when S3 => step_state <= S2;
                                        when S2 => step_state <= S1;
                                        when others => step_state <= S0;
                                    end case;

                                    current_position <= current_position - 1;

                                end if;

                            else

                                tick_counter <= tick_counter + 1;

                            end if;

                        end if;

                end case;

            end if;

        end if;
    end process;

    ----------------------------------------------------------------------------
    -- OUTPUT DECODE
    ----------------------------------------------------------------------------

    process(step_state)
    begin

        case step_state is

            when S0 => coils <= "1000";
            when S1 => coils <= "1100";
            when S2 => coils <= "0100";
            when S3 => coils <= "0110";
            when S4 => coils <= "0010";
            when S5 => coils <= "0011";
            when S6 => coils <= "0001";
            when others => coils <= "1001";

        end case;

    end process;

end architecture;