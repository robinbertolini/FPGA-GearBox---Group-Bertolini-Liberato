library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity main_motor_top_pwm is
    Port (
        clk   : in  STD_LOGIC;
        btnC  : in  STD_LOGIC;  -- Neutral (folle)
        btnU  : in  STD_LOGIC;  -- Gear 1 (arrow up)
        btnL  : in  STD_LOGIC;  -- Gear 2 (arrow left)
        btnR  : in  STD_LOGIC;  -- Gear 4 (arrow right)
        btnD  : in  STD_LOGIC;  -- Gear 3 (arrow down)
        sw    : in  STD_LOGIC_VECTOR(15 downto 0); -- sw(15) = RESET
        led   : out STD_LOGIC_VECTOR(3 downto 0);
        JA    : out STD_LOGIC_VECTOR(3 downto 2);
        JB    : out STD_LOGIC_VECTOR(3 downto 0);
        JC    : out STD_LOGIC_VECTOR(3 downto 0);
        seg   : out STD_LOGIC_VECTOR(6 downto 0);  -- 7-seg
        an    : out STD_LOGIC_VECTOR(3 downto 0);
        dp    : out STD_LOGIC
    );
end main_motor_top_pwm;

architecture rtl of main_motor_top_pwm is

    ----------------------------------------------------------------------------
    -- PARAMETRI DI TARATURA (modifica qui)
    ----------------------------------------------------------------------------
    -- POST_HOMING_OFFSET: passi di rientro DOPO aver toccato il muro.
    -- Definisce la posizione di folle (marcia 0).
    constant POST_HOMING_OFFSET : integer := 350;   -- angolo desiderato in passi

    -- STEPS_X deve coincidere con POST_HOMING_OFFSET (nessun movimento extra dopo calibrazione)
    constant STEPS_X : integer := POST_HOMING_OFFSET;

    -- Passi per il motore 1 (JB) - avanti e indietro
    constant S1_UP_STEPS   : integer := 450;   -- avanti (perfetto)
    constant S1_DOWN_STEPS : integer := 550;   -- indietro (speculare all'avanti, regola se serve più o meno)

    -- Passi per il motore 2 (JC) - avanti e indietro
    constant S2_UP_STEPS   : integer := 450;   -- avanti (perfetto)
    constant S2_DOWN_STEPS : integer := 550;   -- indietro (funziona bene così)

    constant GLOBAL_CALIB_DIR : std_logic := '1';

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

    signal s1_calibrated, s2_calibrated : std_logic;
    signal s1_busy, s2_busy : std_logic;
    signal s1_target, s2_target : integer := 0;
    signal start_calib : std_logic := '0';
    signal current_gear : integer range 0 to 4 := 0;
    signal master_reset : std_logic;

    signal digit_scan_counter : integer range 0 to 99999 := 0;
    signal digit_select       : integer range 0 to 3 := 0;

begin
    master_reset <= sw(15);

    led(0) <= s1_calibrated;
    led(1) <= s2_calibrated;
    led(2) <= s1_busy;
    led(3) <= s2_busy;

    JA(2) <= '1';
    JA(3) <= sw(0);

    -- Impulso di calibrazione automatica all'avvio
    process(clk)
        variable counter : integer := 0;
        variable fired   : boolean := false;
    begin
        if rising_edge(clk) then
            if master_reset = '1' then
                counter := 0; fired := false; start_calib <= '0';
            elsif not fired then
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

    ----------------------------------------------------------------------------
    -- Motori passo-passo con post-homing offset
    STEP1: stepper_position_controller
        generic map (
            CLK_FREQ_HZ        => 100_000_000,
            HOMING_DIR         => '0',               -- regola se necessario
            POST_HOMING_OFFSET => POST_HOMING_OFFSET
        )
        port map ( clk => clk, rst => master_reset, start_calibration => start_calib,
                   target_position => s1_target, invert_direction => GLOBAL_CALIB_DIR,
                   calibrated => s1_calibrated, busy => s1_busy, coils => JB );

    STEP2: stepper_position_controller
        generic map (
            CLK_FREQ_HZ        => 100_000_000,
            HOMING_DIR         => '0',
            POST_HOMING_OFFSET => POST_HOMING_OFFSET
        )
        port map ( clk => clk, rst => master_reset, start_calibration => start_calib,
                   target_position => s2_target, invert_direction => not GLOBAL_CALIB_DIR,
                   calibrated => s2_calibrated, busy => s2_busy, coils => JC );

    ----------------------------------------------------------------------------
    -- Pulsanti marce
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
    -- Target position (USA I NUOVI PARAMETRI PER SINGOLO MOTORE)
    process(clk)
    begin
        if rising_edge(clk) then
            if s1_calibrated = '1' and s2_calibrated = '1' then
                case current_gear is
                    when 1 =>   -- entrambi avanti
                        s1_target <= STEPS_X + S1_UP_STEPS;
                        s2_target <= STEPS_X + S2_UP_STEPS;
                    when 2 =>   -- S1 avanti, S2 indietro
                        s1_target <= STEPS_X + S1_UP_STEPS;
                        s2_target <= STEPS_X - S2_DOWN_STEPS;
                    when 3 =>   -- entrambi indietro
                        s1_target <= STEPS_X - S1_DOWN_STEPS;
                        s2_target <= STEPS_X - S2_DOWN_STEPS;
                    when 4 =>   -- S1 indietro, S2 avanti
                        s1_target <= STEPS_X - S1_DOWN_STEPS;
                        s2_target <= STEPS_X + S2_UP_STEPS;
                    when others =>  -- folle (target = STEPS_X)
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
    -- Display 7 segmenti
    process(clk)
    begin
        if rising_edge(clk) then
            if digit_scan_counter = 99999 then
                digit_scan_counter <= 0;
                if digit_select = 3 then digit_select <= 0;
                else digit_select <= digit_select + 1;
                end if;
            else digit_scan_counter <= digit_scan_counter + 1;
            end if;
        end if;
    end process;

    an <= "1110" when digit_select = 0 else
          "1101" when digit_select = 1 else
          "1011" when digit_select = 2 else
          "0111";

    process(digit_select, current_gear)
    begin
        if digit_select = 0 then
            case current_gear is
                when 0 => seg <= "1000000";
                when 1 => seg <= "1111001";
                when 2 => seg <= "0100100";
                when 3 => seg <= "0110000";
                when 4 => seg <= "0011001";
                when others => seg <= "1111111";
            end case;
        else seg <= "1111111";
        end if;
    end process;

    dp <= '1';
end rtl;