library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity main_motor_top_pwm is
    Port (
        clk         : in  STD_LOGIC;
        btnC        : in  STD_LOGIC;  -- Neutral (folle)
        btnU        : in  STD_LOGIC;  -- Gear 1 (arrow up)
        btnL        : in  STD_LOGIC;  -- Gear 2 (arrow left)
        btnR        : in  STD_LOGIC;  -- Gear 4 (arrow right)
        btnD        : in  STD_LOGIC;  -- Gear 3 (arrow down)
        sw          : in  STD_LOGIC_VECTOR(15 downto 0); -- sw(15) = RESET
        led         : out STD_LOGIC_VECTOR(3 downto 0);
        JA          : out STD_LOGIC_VECTOR(3 downto 2);
        JB          : out STD_LOGIC_VECTOR(3 downto 0);
        JC          : out STD_LOGIC_VECTOR(3 downto 0);
        sensor_in1  : in  STD_LOGIC;   -- HC-020K #1 su JXADC pin 1 (J2)
        sensor_in2  : in  STD_LOGIC;   -- HC-020K #2 su JXADC pin 3 (K2)
        seg         : out STD_LOGIC_VECTOR(6 downto 0);
        an          : out STD_LOGIC_VECTOR(3 downto 0);
        dp          : out STD_LOGIC
    );
end main_motor_top_pwm;

architecture rtl of main_motor_top_pwm is

    ----------------------------------------------------------------------------
    -- PARAMETERS SET SPERIMENTALLY
    ----------------------------------------------------------------------------
    constant POST_HOMING_OFFSET : integer := 550;   -- rientro dopo il muro (neutro)
    constant STEPS_X            : integer := POST_HOMING_OFFSET;
    constant GEAR_STEP          : integer := 750;   -- passo simmetrico per le marce

    constant GLOBAL_CALIB_DIR : std_logic := '1';

    ----------------------------------------------------------------------------
    -- COMPONENTS
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
    -- SEGNALI INTERNI
    ----------------------------------------------------------------------------
    signal s1_calibrated, s2_calibrated : std_logic;
    signal s1_busy, s2_busy : std_logic;
    signal s1_target, s2_target : integer := 0;
    signal start_calib : std_logic := '0';
    signal current_gear : integer range 0 to 4 := 0;
    signal master_reset : std_logic;

    -- Sensori HC-020K
    signal rpm1, rpm2 : std_logic_vector(15 downto 0);
    signal valid1, valid2 : std_logic;
    signal rpm1_latched, rpm2_latched : std_logic_vector(15 downto 0) := (others => '0');
    signal selected_rpm : std_logic_vector(15 downto 0);
    signal any_valid : std_logic;  -- '1' se almeno un sensore ha dato un valore valido

    -- Display
    signal digit_scan_counter : integer range 0 to 99999 := 0;
    signal digit_select       : integer range 0 to 3 := 0;

    -- Funzione per convertire cifra 0-9 in segmenti
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
    -- LED DI STATO (identici a prima)
    ----------------------------------------------------------------------------
    led(0) <= s1_calibrated;
    led(1) <= s2_calibrated;
    led(2) <= s1_busy;
    led(3) <= s2_busy;

    ----------------------------------------------------------------------------
    -- DC MOTOR (identico a prima)
    ----------------------------------------------------------------------------
    JA(2) <= '1';
    JA(3) <= sw(0);

    ----------------------------------------------------------------------------
    -- CALIBRAZIONE AUTOMATICA ALL'AVVIO / RESET (identica a prima)
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
    -- ISTANZE MOTORI PASSO-PASSO (identiche a prima)
    ----------------------------------------------------------------------------
    STEP1: stepper_position_controller
        generic map (CLK_FREQ_HZ => 100_000_000, HOMING_DIR => '0', POST_HOMING_OFFSET => POST_HOMING_OFFSET)
        port map ( clk => clk, rst => master_reset, start_calibration => start_calib,
                   target_position => s1_target, invert_direction => GLOBAL_CALIB_DIR,
                   calibrated => s1_calibrated, busy => s1_busy, coils => JB );

    STEP2: stepper_position_controller
        generic map (CLK_FREQ_HZ => 100_000_000, HOMING_DIR => '0', POST_HOMING_OFFSET => POST_HOMING_OFFSET)
        port map ( clk => clk, rst => master_reset, start_calibration => start_calib,
                   target_position => s2_target, invert_direction => not GLOBAL_CALIB_DIR,
                   calibrated => s2_calibrated, busy => s2_busy, coils => JC );

    ----------------------------------------------------------------------------
    -- SENSORI HC-020K (NUOVI, non toccano il resto)
    ----------------------------------------------------------------------------
    SENSOR1: hc020k
        generic map (CLK_FREQ_HZ => 100_000_000, MEASUREMENT_MS => 100, SLOTS_PER_REV => 20)
        port map (clk => clk, rst => master_reset, sensor_in => sensor_in1, rpm => rpm1, valid => valid1);

    SENSOR2: hc020k
        generic map (CLK_FREQ_HZ => 100_000_000, MEASUREMENT_MS => 100, SLOTS_PER_REV => 20)
        port map (clk => clk, rst => master_reset, sensor_in => sensor_in2, rpm => rpm2, valid => valid2);

    -- Latch dei valori RPM quando sono validi
    process(clk)
    begin
        if rising_edge(clk) then
            if master_reset = '1' then
                rpm1_latched <= (others => '0');
                rpm2_latched <= (others => '0');
            else
                if valid1 = '1' then
                    rpm1_latched <= rpm1;
                end if;
                if valid2 = '1' then
                    rpm2_latched <= rpm2;
                end if;
            end if;
        end if;
    end process;

    -- Selezione RPM in base a sw[13]
    selected_rpm <= rpm1_latched when sw(13) = '0' else rpm2_latched;
    
    -- Flag: almeno un sensore ha prodotto un dato valido?
    any_valid <= valid1 or valid2;

    ----------------------------------------------------------------------------
    -- SELEZIONE MARCIA (IDENTICA a prima)
    ----------------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if s1_calibrated = '1' and s2_calibrated = '1' then
                if btnC = '1' then current_gear <= 0;
                elsif btnU = '1' then current_gear <= 1;
                elsif btnL = '1' then current_gear <= 2;
                elsif btnD = '1' then current_gear <= 3;
                elsif btnR = '1' then current_gear <= 4;
                end if;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------------------
    -- CALCOLO TARGET (IDENTICO a prima)
    ----------------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if s1_calibrated = '1' and s2_calibrated = '1' then
                case current_gear is
                    when 1 =>   -- entrambi avanti
                        s1_target <= STEPS_X + GEAR_STEP;
                        s2_target <= STEPS_X + GEAR_STEP;
                    when 2 =>   -- S1 avanti, S2 indietro
                        s1_target <= STEPS_X + GEAR_STEP;
                        s2_target <= STEPS_X - GEAR_STEP;
                    when 3 =>   -- entrambi indietro
                        s1_target <= STEPS_X - GEAR_STEP;
                        s2_target <= STEPS_X - GEAR_STEP;
                    when 4 =>   -- S1 indietro, S2 avanti
                        s1_target <= STEPS_X - GEAR_STEP;
                        s2_target <= STEPS_X + GEAR_STEP;
                    when others =>  -- folle
                        s1_target <= STEPS_X;
                        s2_target <= STEPS_X;
                end case;
            else
                s1_target <= 0;
                s2_target <= 0;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------------------
    -- DISPLAY 7 SEGMENTI
    -- an[0] -> sempre marcia
    -- an[3],an[2],an[1] -> RPM selezionato (0-999) oppure spenti se sensori non attivi
    ----------------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if digit_scan_counter = 99999 then
                digit_scan_counter <= 0;
                if digit_select = 3 then
                    digit_select <= 0;
                else
                    digit_select <= digit_select + 1;
                end if;
            else
                digit_scan_counter <= digit_scan_counter + 1;
            end if;
        end if;
    end process;

    -- Anodi
    an <= "1110" when digit_select = 0 else
          "1101" when digit_select = 1 else
          "1011" when digit_select = 2 else
          "0111";

    -- Segmenti
    process(digit_select, current_gear, selected_rpm, any_valid)
        variable rpm_int : integer;
        variable digit    : integer range 0 to 9;
    begin
        if digit_select = 0 then
            -- Cifra più a destra: MARCA (sempre visibile)
            case current_gear is
                when 0 => seg <= "1000000";   -- 0
                when 1 => seg <= "1111001";   -- 1
                when 2 => seg <= "0100100";   -- 2
                when 3 => seg <= "0110000";   -- 3
                when 4 => seg <= "0011001";   -- 4
                when others => seg <= "1111111";
            end case;
        else
            -- Cifre 1,2,3: RPM se disponibile, altrimenti spente
            if any_valid = '1' then
                rpm_int := to_integer(unsigned(selected_rpm)) mod 1000;
                case digit_select is
                    when 1 => digit := rpm_int mod 10;          -- UNIT
                    when 2 => digit := (rpm_int / 10) mod 10;   -- DECS
                    when 3 => digit := (rpm_int / 100) mod 10;  -- HUNDREDS
                    when others => digit := 0;
                end case;
                seg <= bcd_to_seg(digit);
            else
                seg <= "1111111";   -- spente
            end if;
        end if;
    end process;

    dp <= '1';   -- punto decimale sempre spento

end rtl;