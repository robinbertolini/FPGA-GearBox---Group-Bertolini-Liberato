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
        seg   : out STD_LOGIC_VECTOR(6 downto 0);  -- 7-seg segments (active low)
        an    : out STD_LOGIC_VECTOR(3 downto 0);  -- anodes (active low)
        dp    : out STD_LOGIC                      -- decimal point (active low)
    );
end main_motor_top_pwm;

architecture rtl of main_motor_top_pwm is

    ----------------------------------------------------------------------------
    -- PARAMETRI DI TARATURA (modifica qui per adattare il movimento fisico)
    ----------------------------------------------------------------------------
    -- STEPS_X : passi dalla posizione di calibrazione (muro) alla posizione di neutro
    constant STEPS_X : integer := 1500;
    
    -- STEPS_Y : passi in salita (allontanamento ulteriore dal muro)
    constant STEPS_Y : integer := 450;
    
    -- STEPS_Y_DOWN : passi in discesa (avvicinamento al muro) - imposta tu il valore voluto
    constant STEPS_Y_DOWN : integer := 1;  -- metti il numero di passi che vuoi per il movimento "giù"
    
    ----------------------------------------------------------------------------
    -- Direzione globale di calibrazione (inverte entrambi i motori se necessario)
    constant GLOBAL_CALIB_DIR : std_logic := '1';

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

    -- 7-segment scanning
    signal digit_scan_counter : integer range 0 to 99999 := 0;
    signal digit_select       : integer range 0 to 3 := 0;

begin
    -- SW15 funge da reset manuale
    master_reset <= sw(15);

    -- LED diagnostici
    led(0) <= s1_calibrated;
    led(1) <= s2_calibrated;
    led(2) <= s1_busy;
    led(3) <= s2_busy;

    -- Motore DC (su JA)
    JA(2) <= '1';          -- direzione fissa (avanti)
    JA(3) <= sw(0);        -- abilitazione PWM da SW0

    ----------------------------------------------------------------------------
    -- Impulso di calibrazione automatica all'avvio (dopo 10 ms)
    process(clk)
        variable counter : integer := 0;
        variable fired   : boolean := false;
    begin
        if rising_edge(clk) then
            if master_reset = '1' then
                counter := 0;
                fired   := false;
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
    -- Motori passo-passo
    STEP1: stepper_position_controller
        port map ( clk => clk, rst => master_reset, start_calibration => start_calib,
                   target_position => s1_target, invert_direction => GLOBAL_CALIB_DIR,
                   calibrated => s1_calibrated, busy => s1_busy, coils => JB );

    STEP2: stepper_position_controller
        port map ( clk => clk, rst => master_reset, start_calibration => start_calib,
                   target_position => s2_target, invert_direction => not GLOBAL_CALIB_DIR,
                   calibrated => s2_calibrated, busy => s2_busy, coils => JC );

    ----------------------------------------------------------------------------
    -- Selezione della marcia con i pulsanti
    --   btnU -> gear 1
    --   btnL -> gear 2
    --   btnR -> gear 4
    --   btnD -> gear 3
    --   btnC -> gear 0 (folle)
    process(clk)
    begin
        if rising_edge(clk) then
            if s1_calibrated = '1' and s2_calibrated = '1' then
                if btnC = '1' then
                    current_gear <= 0;
                elsif btnU = '1' then
                    current_gear <= 1;
                elsif btnL = '1' then
                    current_gear <= 2;
                elsif btnD = '1' then
                    current_gear <= 3;
                elsif btnR = '1' then
                    current_gear <= 4;
                end if;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------------------
    -- Calcolo delle posizioni obiettivo in base alla marcia
    -- NB: UNICO processo, usa STEPS_Y_DOWN per gli spostamenti negativi
    process(clk)
    begin
        if rising_edge(clk) then
            if s1_calibrated = '1' and s2_calibrated = '1' then
                case current_gear is
                    when 1 =>   -- Gear 1: entrambi SU
                        s1_target <= STEPS_X + STEPS_Y;
                        s2_target <= STEPS_X + STEPS_Y;
                    when 2 =>   -- Gear 2: S1 SU, S2 GIU'
                        s1_target <= STEPS_X + STEPS_Y;
                        s2_target <= STEPS_X - STEPS_Y_DOWN;   -- usa STEPS_Y_DOWN
                    when 3 =>   -- Gear 3: entrambi GIU'
                        s1_target <= STEPS_X - STEPS_Y_DOWN;
                        s2_target <= STEPS_X - STEPS_Y_DOWN;
                    when 4 =>   -- Gear 4: S1 GIU', S2 SU
                        s1_target <= STEPS_X - STEPS_Y_DOWN;
                        s2_target <= STEPS_X + STEPS_Y;
                    when others =>  -- Folle (neutro)
                        s1_target <= STEPS_X;
                        s2_target <= STEPS_X;
                end case;
            else
                -- Durante la calibrazione rimaniamo a 0 (muro)
                s1_target <= 0;
                s2_target <= 0;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------------------
    -- 7-SEGMENT DISPLAY (gear on rightmost digit)
    ----------------------------------------------------------------------------
    -- Scansione a circa 1 kHz
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

    -- Controllo anodi (attivi bassi) - solo il digit 0 mostra il numero
    an <= "1110" when digit_select = 0 else
          "1101" when digit_select = 1 else
          "1011" when digit_select = 2 else
          "0111";

    -- Decodifica segmenti (attivi bassi)
    process(digit_select, current_gear)
    begin
        if digit_select = 0 then
            case current_gear is
                when 0 => seg <= "1000000";  -- 0
                when 1 => seg <= "1111001";  -- 1
                when 2 => seg <= "0100100";  -- 2
                when 3 => seg <= "0110000";  -- 3
                when 4 => seg <= "0011001";  -- 4
                when others => seg <= "1111111";
            end case;
        else
            seg <= "1111111";   -- altri digit spenti
        end if;
    end process;

    dp <= '1';   -- punto decimale spento

end rtl;