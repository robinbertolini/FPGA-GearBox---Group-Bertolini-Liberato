-- tb_hc020k.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_hc020k is
end tb_hc020k;

architecture test of tb_hc020k is
    constant CLK_PERIOD : time := 10 ns;
    constant CLK_FREQ   : positive := 100_000_000;
    constant MEAS_MS    : positive := 10;   -- shorten for simulation
    constant SLOTS      : positive := 22;

    signal clk, rst, sensor_in : std_logic := '0';
    signal rpm : std_logic_vector(15 downto 0);
    signal valid : std_logic;
begin
    uut: entity work.hc020k
        generic map (CLK_FREQ_HZ => CLK_FREQ, MEASUREMENT_MS => MEAS_MS, SLOTS_PER_REV => SLOTS)
        port map (clk => clk, rst => rst, sensor_in => sensor_in, rpm => rpm, valid => valid);

    clk <= not clk after CLK_PERIOD/2;

    process
    begin
        -- Reset
        rst <= '1';
        wait until rising_edge(clk);
        rst <= '0';
        wait for 1 us;

        -- Test glitch rejection: short pulse < debounce (1000 cycles = 10 us)
        sensor_in <= '1';
        wait for 5 us;
        sensor_in <= '0';
        wait for 20 us;
        -- No rising edge should be counted -> rpm stays 0
        assert unsigned(rpm) = 0 report "Glitch counted as edge" severity error;

        -- Valid pulse longer than debounce
        sensor_in <= '1';
        wait for 15 us;   -- > 10 us
        sensor_in <= '0';
        wait for 15 us;
        -- We must wait for measurement window to finish (MEAS_MS = 10 ms)
        wait for 12 ms;
        -- After window, valid pulse and rpm calculation
        assert valid = '1' report "Valid not asserted after window" severity error;
        -- 1 pulse in 10 ms -> frequency = 100 Hz -> RPM = (100 * 60)/22 ≈ 272.7 -> integer rounding.
        -- Check roughly: (pulse_cnt=1)*SCALE(60000/10=6000)/22 = 6000/22 ≈ 272
        assert unsigned(rpm) = 272 report "Wrong RPM after one pulse" severity error;

        -- Test multiple pulses
        for i in 1 to 10 loop
            sensor_in <= '1'; wait for 15 us;
            sensor_in <= '0'; wait for 15 us;
        end loop;
        wait for 12 ms;
        assert valid = '1' and unsigned(rpm) = 2727 report "RPM miscalculation" severity error; -- 10 pulses * 6000/22

        report "HC020K test completed" severity note;
        wait;
    end process;
end test;