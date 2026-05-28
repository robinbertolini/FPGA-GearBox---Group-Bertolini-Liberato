-- ===========================================================
-- main_motor_top_pwm  (UPDATED TOP-LEVEL ENTITY)
-- Replace ONLY this block (original lines 1-313).
-- All other entities in the file stay unchanged.
-- ===========================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity main_motor_top_pwm is
    Port (
        clk         : in  STD_LOGIC;
        btnC        : in  STD_LOGIC;   -- Neutral
        btnU        : in  STD_LOGIC;   -- Gear 1
        btnL        : in  STD_LOGIC;   -- Gear 2
        btnR        : in  STD_LOGIC;   -- Gear 4
        btnD        : in  STD_LOGIC;   -- Gear 3
        sw          : in  STD_LOGIC_VECTOR(15 downto 0);  -- sw(15)=RESET  sw(13)=sensor-select  sw(0)=DC-motor
        -- LEDs: [3:0] calibration/busy status | [11:4] unused | [15:12] gear indicator
        led         : out STD_LOGIC_VECTOR(15 downto 0);
        -- JA [3:0] = STEPPER1 coils (JA1-JA4)
        -- JA [7:4] = STEPPER2 coils (JA7-JA10)
        JA          : out STD_LOGIC_VECTOR(7 downto 0);
        -- JXADC [0] = DC IN1 (JXADC1)   [1] = DC IN2 (JXADC2)
        JXADC       : out STD_LOGIC_VECTOR(1 downto 0);
        sensor_in1  : in  STD_LOGIC;   -- HC-020K #1 → JC1 (K17)
        sensor_in2  : in  STD_LOGIC;   -- HC-020K #2 → JC2 (M18)
        seg         : out STD_LOGIC_VECTOR(6 downto 0);
        an          : out STD_LOGIC_VECTOR(3 downto 0);
        dp          : out STD_LOGIC
    );
    
end main_motor_top_pwm;

architecture rtl of main_motor_top_pwm is

    ----------------------------------------------------------------------------
    -- PARAMETERS (unchanged from previous designer)
    ----------------------------------------------------------------------------
    constant POST_HOMING_OFFSET : integer := 550;
    constant STEPS_X            : integer := POST_HOMING_OFFSET;
    constant GEAR_STEP          : integer := 770;
    constant GLOBAL_CALIB_DIR   : std_logic := '1';

    ----------------------------------------------------------------------------
    -- COMPONENTS (unchanged)
    ----------------------------------------------------------------------------
    component stepper_position_controller is
        generic (
            CLK_FREQ_HZ        : positive := 100_000_000;
            HOMING_DIR         : std_logic := '1';
            POST_HOMING_OFFSET : integer   := 0
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
    end component;

    component hc020k is
        generic (
            CLK_FREQ_HZ    : positive := 100_000_000;
            MEASUREMENT_MS : positive := 100;
            SLOTS_PER_REV  : positive := 20
        );
        port (
            clk       : in  std_logic;
            rst       : in  std_logic;
            sensor_in : in  std_logic;
            rpm       : out std_logic_vector(15 downto 0);
            valid     : out std_logic
        );
    end component;

    ----------------------------------------------------------------------------
    -- INTERNAL SIGNALS
    ----------------------------------------------------------------------------
    signal s1_calibrated, s2_calibrated : std_logic;
    signal s1_busy,       s2_busy       : std_logic;
    signal s1_target,     s2_target     : integer := 0;
    signal start_calib  : std_logic := '0';
    signal current_gear : integer range 0 to 4 := 0;
    signal master_reset : std_logic;

    -- Stepper coil buses (routed to JA slices)
    signal step1_coils : std_logic_vector(3 downto 0);
    signal step2_coils : std_logic_vector(3 downto 0);

    -- Speed sensors
    signal rpm1, rpm2                   : std_logic_vector(15 downto 0);
    signal valid1, valid2               : std_logic;
    signal rpm1_latched, rpm2_latched   : std_logic_vector(15 downto 0) := (others => '0');
    signal selected_rpm                 : std_logic_vector(15 downto 0);
    signal any_valid                    : std_logic;

    -- 7-segment scan
    signal digit_scan_counter : integer range 0 to 99999 := 0;
    signal digit_select       : integer range 0 to 3     := 0;

    -- BCD → segments (active-low, common-anode)
    function bcd_to_seg(bcd : integer range 0 to 9) return std_logic_vector is
    begin
        case bcd is
            when 0 => return "1000000";
            when 1 => return "1111001";
            when 2 => return "0100100";
            when 3 => return "0110000";
            when 4 => return "0011001";
            when 5 => return "0010010";
            when 6 => return "0000010";
            when 7 => return "1111000";
            when 8 => return "0000000";
            when 9 => return "0010000";
            when others => return "1111111";
        end case;
    end function;

begin
    master_reset <= sw(15);

    ----------------------------------------------------------------------------
    -- DC MOTOR  (IN1=JXADC1 always high, IN2=JXADC2 follows sw(0))
    ----------------------------------------------------------------------------
    JXADC(0) <= '1';
    JXADC(1) <= sw(0);

    ----------------------------------------------------------------------------
    -- STEPPER COILS → JA header
    --   JA[3:0]  = STEPPER1  (JA1-JA4)
    --   JA[7:4]  = STEPPER2  (JA7-JA10)
    ----------------------------------------------------------------------------
    JA(3 downto 0) <= step1_coils;
    JA(7 downto 4) <= step2_coils;

    ----------------------------------------------------------------------------
    -- STATUS LEDs [3:0]  (calibrated / busy, unchanged)
    ----------------------------------------------------------------------------
    led(0) <= s1_calibrated;
    led(1) <= s2_calibrated;
    led(2) <= s1_busy;
    led(3) <= s2_busy;

    -- LEDs [11:4] not used
    led(11 downto 4) <= (others => '0');

    ----------------------------------------------------------------------------
    -- GEAR INDICATOR  LEDs [15:12]
    --   Neutral (0) → all four ON  "1111"
    --   Gear  1     → LD12 only    "0001"
    --   Gear  2     → LD13 only    "0010"
    --   Gear  3     → LD14 only    "0100"
    --   Gear  4     → LD15 only    "1000"
    ----------------------------------------------------------------------------
    process(current_gear)
    begin
        case current_gear is
            when 0      => led(15 downto 12) <= "1111";
            when 1      => led(15 downto 12) <= "0001";
            when 2      => led(15 downto 12) <= "0010";
            when 3      => led(15 downto 12) <= "0100";
            when 4      => led(15 downto 12) <= "1000";
            when others => led(15 downto 12) <= "0000";
        end case;
    end process;

    ----------------------------------------------------------------------------
    -- AUTO-CALIBRATION ON START / RESET (unchanged)
    ----------------------------------------------------------------------------
    process(clk)
        variable counter : integer := 0;
        variable fired   : boolean := false;
    begin
        if rising_edge(clk) then
            if master_reset = '1' then
                counter := 0;
                fired := false;
                start_calib <= '0';
            elsif not fired then
                if counter < 1000000 then
                    counter := counter + 1;
                else
                    start_calib <= '1';
                    fired := true;
                end if;
            else
                start_calib <= '0';
            end if;
        end if;
    end process;

    ----------------------------------------------------------------------------
    -- STEPPER INSTANCES (logic unchanged; coils now go to internal signals)
    ----------------------------------------------------------------------------
    STEP1: stepper_position_controller
        generic map (CLK_FREQ_HZ => 100_000_000, HOMING_DIR => '1', POST_HOMING_OFFSET => POST_HOMING_OFFSET)--changed
        port map (
            clk               => clk,
            rst               => master_reset,
            start_calibration => start_calib,
            target_position   => s1_target,
            invert_direction  => GLOBAL_CALIB_DIR,
            calibrated        => s1_calibrated,
            busy              => s1_busy,
            coils             => step1_coils       -- routed to JA[3:0]
        );

    STEP2: stepper_position_controller
        generic map (CLK_FREQ_HZ => 100_000_000, HOMING_DIR => '1', POST_HOMING_OFFSET => POST_HOMING_OFFSET)--changed
        port map (
            clk               => clk,
            rst               => master_reset,
            start_calibration => start_calib,
            target_position   => s2_target,
            invert_direction  => not GLOBAL_CALIB_DIR,
            calibrated        => s2_calibrated,
            busy              => s2_busy,
            coils             => step2_coils       -- routed to JA[7:4]
        );

    ----------------------------------------------------------------------------
    -- SPEED SENSORS (unchanged logic)
    ----------------------------------------------------------------------------
    SENSOR1: hc020k
        generic map (CLK_FREQ_HZ => 100_000_000, MEASUREMENT_MS => 500, SLOTS_PER_REV => 22)
        port map (clk => clk, rst => master_reset, sensor_in => sensor_in1, rpm => rpm1, valid => valid1);

    SENSOR2: hc020k
        generic map (CLK_FREQ_HZ => 100_000_000, MEASUREMENT_MS => 500, SLOTS_PER_REV => 22)
        port map (clk => clk, rst => master_reset, sensor_in => sensor_in2, rpm => rpm2, valid => valid2);

    -- Latch RPM values on valid pulses
    process(clk)
    begin
        if rising_edge(clk) then
            if master_reset = '1' then
                rpm1_latched <= (others => '0');
                rpm2_latched <= (others => '0');
            else
                if valid1 = '1' then rpm1_latched <= rpm1; end if;
                if valid2 = '1' then rpm2_latched <= rpm2; end if;
            end if;
        end if;
    end process;

    -- sw(13) = '0' → Sensor 1 (input shaft),  '1' → Sensor 2 (output shaft)
    selected_rpm <= rpm1_latched when sw(13) = '0' else rpm2_latched;
    any_valid    <= valid1 or valid2;

    ----------------------------------------------------------------------------
    -- GEAR SELECTION (unchanged)
    ----------------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if s1_calibrated = '1' and s2_calibrated = '1' then
                if    btnC = '1' then current_gear <= 0;
                elsif btnU = '1' then current_gear <= 1;
                elsif btnL = '1' then current_gear <= 2;
                elsif btnD = '1' then current_gear <= 3;
                elsif btnR = '1' then current_gear <= 4;
                end if;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------------------
    -- TARGET POSITION CALCULATION (unchanged)
    ----------------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if s1_calibrated = '1' and s2_calibrated = '1' then
                case current_gear is
                    when 1 => s1_target <= STEPS_X + GEAR_STEP; s2_target <= STEPS_X + GEAR_STEP;
                    when 2 => s1_target <= STEPS_X + GEAR_STEP; s2_target <= STEPS_X - GEAR_STEP;
                    when 3 => s1_target <= STEPS_X - GEAR_STEP; s2_target <= STEPS_X - GEAR_STEP;
                    when 4 => s1_target <= STEPS_X - GEAR_STEP; s2_target <= STEPS_X + GEAR_STEP;
                    when others => s1_target <= STEPS_X; s2_target <= STEPS_X;
                end case;
            else
                s1_target <= 0;
                s2_target <= 0;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------------------
    -- 7-SEGMENT DISPLAY  - 4 digits, full decimal RPM  (0 - 9999)
    --   an[0] rightmost = units
    --   an[1]           = tens
    --   an[2]           = hundreds
    --   an[3] leftmost  = thousands
    -- sw(13) selects which sensor is shown.
    -- Displays "0000" when no valid measurement yet.
    ----------------------------------------------------------------------------
    -- Digit scanner (~1 kHz refresh per digit at 100 MHz)
    process(clk)
    begin
        if rising_edge(clk) then
            if digit_scan_counter = 99999 then
                digit_scan_counter <= 0;
                if digit_select = 3 then digit_select <= 0;
                else digit_select <= digit_select + 1;
                end if;
            else
                digit_scan_counter <= digit_scan_counter + 1;
            end if;
        end if;
    end process;

    -- Anode enables (active-low)
    an <= "1110" when digit_select = 0 else
          "1101" when digit_select = 1 else
          "1011" when digit_select = 2 else
          "0111";

    -- Segment data
    process(digit_select, selected_rpm, any_valid)
        variable rpm_int : integer;
        variable digit   : integer range 0 to 9;
    begin
        rpm_int := to_integer(unsigned(selected_rpm));
        if rpm_int > 9999 then rpm_int := 9999; end if;

        case digit_select is
            when 0 => digit := rpm_int mod 10;
            when 1 => digit := (rpm_int / 10)   mod 10;
            when 2 => digit := (rpm_int / 100)  mod 10;
            when 3 => digit := (rpm_int / 1000) mod 10;
            when others => digit := 0;
        end case;

        seg <= bcd_to_seg(digit);
    end process;

    dp <= '1';   -- decimal point always off

end rtl;