-- tb_stepper_position_controller.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_stepper_position_controller is
end tb_stepper_position_controller;

architecture test of tb_stepper_position_controller is
    constant CLK_PERIOD : time := 10 ns;
    constant CLK_FREQ   : positive := 100_000_000;
    constant OFFSET     : integer := 100;  -- reduced for simulation

    signal clk, rst, start_cal, calibrated, busy : std_logic := '0';
    signal target_pos : integer := 0;
    signal invert_dir : std_logic := '0';
    signal coils : std_logic_vector(3 downto 0);
begin
    uut: entity work.stepper_position_controller
        generic map (CLK_FREQ_HZ => CLK_FREQ, HOMING_DIR => '1', POST_HOMING_OFFSET => OFFSET)
        port map (clk => clk, rst => rst, start_calibration => start_cal,
                  target_position => target_pos, invert_direction => invert_dir,
                  calibrated => calibrated, busy => busy, coils => coils);

    clk <= not clk after CLK_PERIOD/2;

    procedure wait_cycles(n : positive) is
    begin
        for i in 1 to n loop wait until rising_edge(clk); end loop;
    end procedure;

    process
    begin
        rst <= '1';
        wait_cycles(5);
        rst <= '0';
        wait_cycles(2);

        -- Start calibration
        start_cal <= '1';
        wait_cycles(1);
        start_cal <= '0';
        assert busy = '1' report "Busy not set during calibration" severity error;

        -- Let calibration run (homing + offset). Wait enough time.
        wait for 30 ms;  -- > steps * step period
        assert calibrated = '1' and busy = '0' report "Calibration failed to complete" severity error;

        -- Move to positive target
        target_pos <= OFFSET + 200;
        wait_cycles(1);
        wait for 15 ms;
        assert busy = '0' and calibrated = '1' report "Move did not finish" severity error;

        -- Move to negative target (test direction)
        target_pos <= OFFSET - 100;
        wait_cycles(1);
        wait for 15 ms;
        assert busy = '0' report "Negative move failed" severity error;

        -- Test invert_direction
        invert_dir <= '1';
        target_pos <= OFFSET + 50;
        wait_cycles(1);
        wait for 10 ms;
        -- No error, just verify coils sequence runs
        assert busy = '0' report "Inverted direction move failed" severity error;

        report "Stepper position controller test completed" severity note;
        wait;
    end process;
end test;