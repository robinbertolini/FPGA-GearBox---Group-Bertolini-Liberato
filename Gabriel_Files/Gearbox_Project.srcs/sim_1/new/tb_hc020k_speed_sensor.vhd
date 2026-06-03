-- tb_hc020k_speed_sensor.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_hc020k_speed_sensor is
end tb_hc020k_speed_sensor;

architecture test of tb_hc020k_speed_sensor is
    constant CLK_PERIOD : time := 10 ns;
    constant CLK_FREQ   : positive := 100_000_000;
    constant MEAS_MS    : positive := 10;   -- 10 ms for simulation
    constant SLOTS      : positive := 20;

    signal clk, rst, sensor_in : std_logic := '0';
    signal pulse_hz, rpm : std_logic_vector(15 downto 0);
    signal valid : std_logic;
begin
    uut: entity work.hc020k_speed_sensor
        generic map (CLK_FREQ_HZ => CLK_FREQ, MEASUREMENT_MS => MEAS_MS, SLOTS_PER_REV => SLOTS)
        port map (clk => clk, rst => rst, sensor_in => sensor_in,
                  pulse_hz => pulse_hz, rpm => rpm, valid => valid);

    clk <= not clk after CLK_PERIOD/2;

    process
    begin
        rst <= '1';
        wait until rising_edge(clk);
        rst <= '0';
        wait for 1 us;

        -- Provide 5 pulses in the window (10 ms)
        for i in 1 to 5 loop
            sensor_in <= '1'; wait for 1 us;
            sensor_in <= '0'; wait for 1 us;
        end loop;
        wait for 10 ms;   -- end of window
        assert valid = '1' report "Valid not high" severity error;
        -- 5 pulses in 10 ms = 500 Hz
        assert unsigned(pulse_hz) = 500 report "pulse_hz miscalculated" severity error;
        -- RPM = (500 * 60)/20 = 1500
        assert unsigned(rpm) = 1500 report "RPM miscalculated" severity error;

        -- Overflow test: large pulse count
        for i in 1 to 1000 loop
            sensor_in <= '1'; wait for 1 us;
            sensor_in <= '0'; wait for 1 us;
        end loop;
        wait for 10 ms;
        assert unsigned(pulse_hz) = 65535 report "Overflow not saturated" severity error;

        report "HC020K speed sensor test completed" severity note;
        wait;
    end process;
end test;