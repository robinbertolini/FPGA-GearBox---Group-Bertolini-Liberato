library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_main_motor_top_pwm is
end tb_main_motor_top_pwm;

architecture test of tb_main_motor_top_pwm is
    constant CLK_PERIOD : time := 10 ns;
    signal clk      : std_logic := '0';
    signal btnC, btnU, btnL, btnR, btnD : std_logic := '0';
    signal sw       : std_logic_vector(15 downto 0) := (others => '0');
    signal led      : std_logic_vector(15 downto 0);
    signal JA       : std_logic_vector(7 downto 0);
    signal JXADC    : std_logic_vector(1 downto 0);
    signal sensor_in1, sensor_in2 : std_logic := '0';
    signal seg      : std_logic_vector(6 downto 0);
    signal an       : std_logic_vector(3 downto 0);
    signal dp       : std_logic;

    procedure press_button(signal btn : out std_logic; duration : time := 100 ns) is
    begin
        btn <= '1';
        wait for duration;
        btn <= '0';
        wait for 1 us;
    end procedure;

    procedure generate_pulses(signal sig : out std_logic; num_pulses : integer; period : time) is
    begin
        for i in 1 to num_pulses loop
            sig <= '1';
            wait for period/2;
            sig <= '0';
            wait for period/2;
        end loop;
    end procedure;

begin
    -- DUT con SIMULATION = true
    uut: entity work.main_motor_top_pwm
        generic map (SIMULATION => true)
        port map (
            clk       => clk,
            btnC      => btnC,
            btnU      => btnU,
            btnL      => btnL,
            btnR      => btnR,
            btnD      => btnD,
            sw        => sw,
            led       => led,
            JA        => JA,
            JXADC     => JXADC,
            sensor_in1=> sensor_in1,
            sensor_in2=> sensor_in2,
            seg       => seg,
            an        => an,
            dp        => dp
        );

    clk <= not clk after CLK_PERIOD/2;

    process
        variable gear_leds : std_logic_vector(3 downto 0);
    begin
        report "=== INIZIO TEST (SIMULATION MODE) ===" severity note;

        -- Reset
        sw(15) <= '1';
        wait for 200 ns;
        sw(15) <= '0';
        wait for 10 us;   -- calibrazione veloce (SIM_CNT_MAX=100 -> ~10us)

        -- Verifica fine calibrazione dai LED
        assert led(0) = '1' and led(1) = '1'
            report "Calibrazione non completata" severity error;

        -- Test marce
        press_button(btnU);
        gear_leds := led(15 downto 12);
        assert gear_leds = "0001" report "Gear1 LED errato" severity error;

        press_button(btnL);
        assert led(15 downto 12) = "0010" report "Gear2 LED errato" severity error;

        press_button(btnD);
        assert led(15 downto 12) = "0100" report "Gear3 LED errato" severity error;

        press_button(btnR);
        assert led(15 downto 12) = "1000" report "Gear4 LED errato" severity error;

        press_button(btnC);
        assert led(15 downto 12) = "1111" report "Neutral LED errato" severity error;

        -- Test DC motor: 4 incrementi di duty
        for i in 1 to 4 loop
            sw(0) <= '1';
            wait for 100 ns;
            sw(0) <= '0';
            wait for 1 us;
        end loop;
        -- Verifichiamo che JXADC(1) (motor_b) sia attivo (in simulazione PWM non lo vedremo, ma almeno non è X)
        assert JXADC(1) /= 'X' report "JXADC(1) non valido" severity error;

        -- Test RPM con sensore1
        sw(13) <= '0';
        generate_pulses(sensor_in1, 110, period => 9.09 ms); -- ~110 Hz
        wait for 600 ms;   -- due finestre di misura (500ms ciascuna)
        -- Non possiamo leggere il valore interno, ma possiamo controllare che i segmenti non siano spenti
        assert an /= "1111" report "Display spento" severity error;
        assert seg /= "1111111" report "Segmenti spenti" severity error;

        report "=== TEST SUPERATO ===" severity note;
        wait;
    end process;
end test;