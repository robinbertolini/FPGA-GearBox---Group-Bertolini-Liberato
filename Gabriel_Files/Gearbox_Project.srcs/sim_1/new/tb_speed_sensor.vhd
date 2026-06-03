-- tb_speed_sensor.vhd RobNote: (or simple gate counter)
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_speed_sensor is
end tb_speed_sensor;

architecture test of tb_speed_sensor is
    constant CLK_PERIOD : time := 10 ns;
    constant CLK_FREQ   : positive := 100_000_000;
    constant GATE_S     : positive := 1;   -- 1 second

    signal clk, rst, sensor : std_logic := '0';
    signal speed : unsigned(13 downto 0);
begin
    uut: entity work.speed_sensor
        generic map (CLK_FREQ_HZ => CLK_FREQ, GATE_TIME_S => GATE_S)
        port map (clk => clk, rst => rst, sensor => sensor, speed => speed);

    clk <= not clk after CLK_PERIOD/2;

    process
    begin
        rst <= '1';
        wait until rising_edge(clk);
        rst <= '0';
        wait for 1 us;

        -- Generate 1000 pulses at 1 kHz (1 ms period)
        for i in 1 to 1000 loop
            sensor <= '1'; wait for 500 us;
            sensor <= '0'; wait for 500 us;
        end loop;
        -- Wait for gate to finish (1 sec total)
        wait for 1 sec - 1000*1ms;
        assert speed = 1000 report "Speed not 1000 pulses/sec" severity error;

        -- Reset and test zero
        rst <= '1'; wait until rising_edge(clk); rst <= '0';
        wait for 1 sec + 1 ms;
        assert speed = 0 report "After reset speed not zero" severity error;

        report "Speed sensor test completed" severity note;
        wait;
    end process;
end test;