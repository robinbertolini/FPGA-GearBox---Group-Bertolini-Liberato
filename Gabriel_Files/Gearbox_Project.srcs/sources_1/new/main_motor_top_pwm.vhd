--------------------------------------------------------------------------------
-- Entity : main_motor_top_pwm
--
-- Purpose:
--   Autonomous gearbox controller using:
--     • 1 DC motor (PWM controlled)
--     • 2x 28BYJ-48 stepper motors
--
-- Features:
--   • Automatic startup calibration
--   • Software-defined motor directions
--   • Gear selection through switches
--   • Neutral priority
--   • Gear changes only enabled AFTER calibration
--
-- Board:
--   Digilent Basys3
--
-- Connections:
--   JA3 -> DC IN2
--   JA4 -> DC IN1
--
--   JB1..JB4 -> Stepper 1 ULN2003 IN1..IN4
--   JC1..JC4 -> Stepper 2 ULN2003 IN1..IN4
--
-- Switch Mapping:
--
--   SW0  : DC motor enable
--
--   SW1  : 25% speed
--   SW2  : 50% speed
--   SW3  : 75% speed
--   SW4  : 100% speed
--
--   SW7  : Neutral
--   SW8  : Gear 1
--   SW9  : Gear 2
--   SW10 : Gear 3
--   SW11 : Gear 4
--
--   btnC : synchronous reset
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity main_motor_top_pwm is
    Port (
        clk   : in  STD_LOGIC;
        btnC  : in  STD_LOGIC;
        sw    : in  STD_LOGIC_VECTOR(15 downto 0);

        JA    : out STD_LOGIC_VECTOR(3 downto 2);
        JB    : out STD_LOGIC_VECTOR(3 downto 0);
        JC    : out STD_LOGIC_VECTOR(3 downto 0)
    );
end main_motor_top_pwm;

architecture Behavioral of main_motor_top_pwm is

    ----------------------------------------------------------------------------
    -- CLOCK
    ----------------------------------------------------------------------------

    constant CLK_FREQ : integer := 100000000;

    ----------------------------------------------------------------------------
    -- DC MOTOR SETTINGS
    ----------------------------------------------------------------------------

    constant DC_DIRECTION : STD_LOGIC := '1';

    signal pwm_counter : unsigned(7 downto 0) := (others => '0');
    signal pwm_duty    : unsigned(7 downto 0) := (others => '0');
    signal pwm_signal  : STD_LOGIC;

    ----------------------------------------------------------------------------
    -- STEPPER SETTINGS
    ----------------------------------------------------------------------------

    -- IMPORTANT:
    -- Change these if gearbox orientation changes.

    constant STEPPER1_WALL_DIR : STD_LOGIC := '1';
    constant STEPPER2_WALL_DIR : STD_LOGIC := '0';

    -- After calibration:
    -- Move away from wall by X degrees.

    constant NEUTRAL_DEGREES : integer := 20;

    -- Gear movement from neutral.

    constant GEAR_DEGREES : integer := 10;

    -- 28BYJ-48:
    -- 2048 half-steps per revolution.

    constant STEPS_PER_REV : integer := 2048;

    function DEG_TO_STEPS(deg : integer) return integer is
    begin
        return (deg * STEPS_PER_REV) / 360;
    end function;

    constant NEUTRAL_STEPS : integer := DEG_TO_STEPS(NEUTRAL_DEGREES);
    constant GEAR_STEPS    : integer := DEG_TO_STEPS(GEAR_DEGREES);

    ----------------------------------------------------------------------------
    -- CALIBRATION TIMING
    ----------------------------------------------------------------------------

    constant CALIBRATION_STEP_DELAY : integer := 300000;
    constant NORMAL_STEP_DELAY      : integer := 120000;

    constant WALL_HOLD_TIME : integer := 50000000;

    ----------------------------------------------------------------------------
    -- STATE MACHINE
    ----------------------------------------------------------------------------

    type state_type is (
        CALIB_MOVE_TO_WALL,
        CALIB_HOLD,
        MOVE_TO_NEUTRAL,
        READY
    );

    signal state : state_type := CALIB_MOVE_TO_WALL;

    ----------------------------------------------------------------------------
    -- STEPPER INTERNALS
    ----------------------------------------------------------------------------

    type step_array is array (0 to 7) of STD_LOGIC_VECTOR(3 downto 0);

    constant HALFSTEP : step_array := (
        "1000",
        "1100",
        "0100",
        "0110",
        "0010",
        "0011",
        "0001",
        "1001"
    );

    signal seq1 : integer range 0 to 7 := 0;
    signal seq2 : integer range 0 to 7 := 0;

    signal step_counter : integer := 0;

    signal calib_hold_counter : integer := 0;

    signal current_gear : integer range 0 to 4 := 0;

    ----------------------------------------------------------------------------
    -- HELPERS
    ----------------------------------------------------------------------------

    procedure step_motor(
        signal seq : inout integer;
        dir : STD_LOGIC
    ) is
    begin
        if dir = '1' then
            if seq = 7 then
                seq <= 0;
            else
                seq <= seq + 1;
            end if;
        else
            if seq = 0 then
                seq <= 7;
            else
                seq <= seq - 1;
            end if;
        end if;
    end procedure;

begin

    ----------------------------------------------------------------------------
    -- PWM
    ----------------------------------------------------------------------------

    process(clk)
    begin
        if rising_edge(clk) then
            pwm_counter <= pwm_counter + 1;
        end if;
    end process;

    pwm_signal <= '1' when pwm_counter < pwm_duty else '0';

    ----------------------------------------------------------------------------
    -- DC MOTOR CONTROL
    ----------------------------------------------------------------------------

    process(sw)
    begin

        if sw(1) = '1' then
            pwm_duty <= to_unsigned(64, 8);

        elsif sw(2) = '1' then
            pwm_duty <= to_unsigned(128, 8);

        elsif sw(3) = '1' then
            pwm_duty <= to_unsigned(192, 8);

        elsif sw(4) = '1' then
            pwm_duty <= to_unsigned(255, 8);

        else
            pwm_duty <= to_unsigned(0, 8);
        end if;

    end process;

    JA(3) <= pwm_signal when sw(0) = '1' else '0';
    JA(2) <= DC_DIRECTION;

    ----------------------------------------------------------------------------
    -- MAIN CONTROLLER
    ----------------------------------------------------------------------------

    process(clk)
    begin
        if rising_edge(clk) then

            if btnC = '1' then

                state <= CALIB_MOVE_TO_WALL;

                seq1 <= 0;
                seq2 <= 0;

                step_counter <= 0;
                calib_hold_counter <= 0;

                current_gear <= 0;

            else

                case state is

                    ----------------------------------------------------------------
                    -- MOVE TO WALL
                    ----------------------------------------------------------------

                    when CALIB_MOVE_TO_WALL =>

                        if step_counter >= CALIBRATION_STEP_DELAY then

                            step_counter <= 0;

                            step_motor(seq1, STEPPER1_WALL_DIR);
                            step_motor(seq2, STEPPER2_WALL_DIR);

                            if calib_hold_counter >= 300 then
                                calib_hold_counter <= 0;
                                state <= CALIB_HOLD;
                            else
                                calib_hold_counter <= calib_hold_counter + 1;
                            end if;

                        else
                            step_counter <= step_counter + 1;
                        end if;

                    ----------------------------------------------------------------
                    -- HOLD AGAINST WALL
                    ----------------------------------------------------------------

                    when CALIB_HOLD =>

                        if calib_hold_counter >= WALL_HOLD_TIME then

                            calib_hold_counter <= 0;
                            step_counter <= 0;

                            state <= MOVE_TO_NEUTRAL;

                        else
                            calib_hold_counter <= calib_hold_counter + 1;
                        end if;

                    ----------------------------------------------------------------
                    -- MOVE TO NEUTRAL
                    ----------------------------------------------------------------

                    when MOVE_TO_NEUTRAL =>

                        if step_counter >= NORMAL_STEP_DELAY then

                            step_counter <= 0;

                            step_motor(seq1, not STEPPER1_WALL_DIR);
                            step_motor(seq2, not STEPPER2_WALL_DIR);

                            if calib_hold_counter >= NEUTRAL_STEPS then

                                calib_hold_counter <= 0;
                                current_gear <= 0;

                                state <= READY;

                            else
                                calib_hold_counter <= calib_hold_counter + 1;
                            end if;

                        else
                            step_counter <= step_counter + 1;
                        end if;

                    ----------------------------------------------------------------
                    -- READY
                    ----------------------------------------------------------------

                    when READY =>

                        if step_counter >= NORMAL_STEP_DELAY then

                            step_counter <= 0;

                            ----------------------------------------------------------------
                            -- NEUTRAL PRIORITY
                            ----------------------------------------------------------------

                            if sw(7) = '1' then
                                current_gear <= 0;

                            elsif sw(8) = '1' then
                                current_gear <= 1;

                            elsif sw(9) = '1' then
                                current_gear <= 2;

                            elsif sw(10) = '1' then
                                current_gear <= 3;

                            elsif sw(11) = '1' then
                                current_gear <= 4;
                            end if;

                            ----------------------------------------------------------------
                            -- GEAR MOVEMENTS
                            ----------------------------------------------------------------

                            case current_gear is

                                --------------------------------------------------------
                                -- Neutral
                                --------------------------------------------------------

                                when 0 =>
                                    null;

                                --------------------------------------------------------
                                -- Gear 1
                                --------------------------------------------------------

                                when 1 =>

                                    step_motor(seq1, '1');
                                    step_motor(seq2, '1');

                                --------------------------------------------------------
                                -- Gear 2
                                --------------------------------------------------------

                                when 2 =>

                                    step_motor(seq1, '1');
                                    step_motor(seq2, '0');

                                --------------------------------------------------------
                                -- Gear 3
                                --------------------------------------------------------

                                when 3 =>

                                    step_motor(seq1, '0');
                                    step_motor(seq2, '0');

                                --------------------------------------------------------
                                -- Gear 4
                                --------------------------------------------------------

                                when 4 =>

                                    step_motor(seq1, '0');
                                    step_motor(seq2, '1');

                                when others =>
                                    null;

                            end case;

                        else
                            step_counter <= step_counter + 1;
                        end if;

                end case;

            end if;
        end if;
    end process;

    ----------------------------------------------------------------------------
    -- OUTPUTS
    ----------------------------------------------------------------------------

    JB <= HALFSTEP(seq1);
    JC <= HALFSTEP(seq2);

end Behavioral;