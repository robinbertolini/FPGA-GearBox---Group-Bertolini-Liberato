library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity main_motor_top_pwm is
    Port (
        clk   : in  STD_LOGIC;
        btnC  : in  STD_LOGIC; -- Neutral
        btnU  : in  STD_LOGIC; -- Gear 1
        btnL  : in  STD_LOGIC; -- Gear 4
        btnR  : in  STD_LOGIC; -- Gear 2
        btnD  : in  STD_LOGIC; -- Gear 3
        sw    : in  STD_LOGIC_VECTOR(15 downto 0); -- sw(15) is now RESET
        led   : out STD_LOGIC_VECTOR(3 downto 0);
        JA    : out STD_LOGIC_VECTOR(3 downto 2);
        JB    : out STD_LOGIC_VECTOR(3 downto 0);
        JC    : out STD_LOGIC_VECTOR(3 downto 0)
    );
end main_motor_top_pwm;

architecture rtl of main_motor_top_pwm is

    ----------------------------------------------------------------------------
    -- TUNING PARAMETERS (CHANGE THESE TO FINE-TUNE ANGLES)
    ----------------------------------------------------------------------------
    -- STEPS_X: The distance to move AWAY from the wall after calibration to 
    -- reach the Neutral (center) position. 
    constant STEPS_X : integer := 1500; 

    -- STEPS_Y: The distance for a 30-degree gear shift from Neutral.
    -- (30/360) * 4096 total steps = ~341 steps.
    constant STEPS_Y : integer := 341; 
    ----------------------------------------------------------------------------

    constant GLOBAL_CALIB_DIR : std_logic := '0'; 

    component stepper_position_controller is
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
    end component;

    signal s1_calibrated, s2_calibrated : std_logic;
    signal s1_busy, s2_busy : std_logic;
    signal s1_target, s2_target : integer := 0;
    signal start_calib : std_logic := '0';
    signal current_gear : integer range 0 to 4 := 0;
    signal master_reset : std_logic;

begin
    -- Use SW15 as a manual reset trigger
    master_reset <= sw(15);

    led(0) <= s1_calibrated;
    led(1) <= s2_calibrated;
    led(2) <= s1_busy;
    led(3) <= s2_busy;

    -- DC Motor (SW0)
    JA(2) <= '1'; 
    JA(3) <= sw(0); 

    -- Start Pulse for Calibration
    process(clk)
        variable counter : integer := 0;
        variable fired : boolean := false;
    begin
        if rising_edge(clk) then
            if master_reset = '1' then
                counter := 0; fired := false; start_calib <= '0';
            elsif fired = false then
                if counter < 1000000 then 
                    counter := counter + 1;
                else
                    start_calib <= '1'; fired := true;
                end if;
            else
                start_calib <= '0';
            end if;
        end if;
    end process;

    STEP1: stepper_position_controller
        port map ( clk => clk, rst => master_reset, start_calibration => start_calib,
                   target_position => s1_target, invert_direction => GLOBAL_CALIB_DIR,
                   calibrated => s1_calibrated, busy => s1_busy, coils => JB );

    STEP2: stepper_position_controller
        port map ( clk => clk, rst => master_reset, start_calibration => start_calib,
                   target_position => s2_target, invert_direction => not GLOBAL_CALIB_DIR,
                   calibrated => s2_calibrated, busy => s2_busy, coils => JC );

    -- Button-based Gear Selection
    process(clk)
    begin
        if rising_edge(clk) then
            if s1_calibrated = '1' and s2_calibrated = '1' then
                if btnC = '1' then current_gear <= 0; -- Neutral
                elsif btnU = '1' then current_gear <= 1;
                elsif btnR = '1' then current_gear <= 2;
                elsif btnD = '1' then current_gear <= 3;
                elsif btnL = '1' then current_gear <= 4;
                end if;
            end if;
        end if;
    end process;

    -- Target Position Mapping (Using X to return from wall, Y to shift)
    process(clk)
    begin
        if rising_edge(clk) then
            if s1_calibrated = '1' and s2_calibrated = '1' then
                case current_gear is
                    when 1 => -- Gear 1: Both "Up" 30 deg from center
                        s1_target <= STEPS_X + STEPS_Y; s2_target <= STEPS_X + STEPS_Y;
                    when 2 => -- Gear 2: S1 Up, S2 Down
                        s1_target <= STEPS_X + STEPS_Y; s2_target <= STEPS_X - STEPS_Y;
                    when 3 => -- Gear 3: Both Down
                        s1_target <= STEPS_X - STEPS_Y; s2_target <= STEPS_X - STEPS_Y;
                    when 4 => -- Gear 4: S1 Down, S2 Up
                        s1_target <= STEPS_X - STEPS_Y; s2_target <= STEPS_X + STEPS_Y;
                    when others => -- Neutral (Exactly at return angle X)
                        s1_target <= STEPS_X; s2_target <= STEPS_X;
                end case;
            else
                -- During calibration, we stay at 0 (the wall)
                s1_target <= 0; s2_target <= 0;
            end if;
        end if;
    end process;
end rtl;