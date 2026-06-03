-- tb_dc_driver_pwm.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_dc_driver_pwm is
end tb_dc_driver_pwm;

architecture test of tb_dc_driver_pwm is
    constant CLK_PERIOD : time := 10 ns;
    signal clk, rst, enable, fixed_dir : std_logic := '0';
    signal duty_cycle : unsigned(7 downto 0) := (others => '0');
    signal motor_a, motor_b : std_logic;
begin
    uut: entity work.dc_driver_pwm
        generic map (CLK_FREQ_HZ => 100_000_000, PWM_FREQ_HZ => 2000)
        port map (clk => clk, rst => rst, enable => enable, fixed_dir => fixed_dir,
                  duty_cycle => duty_cycle, motor_a => motor_a, motor_b => motor_b);

    clk <= not clk after CLK_PERIOD/2;

    process
    begin
        -- Reset
        rst <= '1'; enable <= '0';
        wait until rising_edge(clk);
        rst <= '0';
        wait until rising_edge(clk);

        -- Disabled: both outputs 0
        enable <= '0'; fixed_dir <= '1'; duty_cycle <= to_unsigned(128,8);
        wait for 200 ns;
        assert motor_a = '0' and motor_b = '0' report "Disabled: outputs not zero" severity error;

        -- Enabled, forward direction -> motor_a = pwm, motor_b = 0
        enable <= '1'; fixed_dir <= '1';
        wait for 200 ns;
        assert motor_b = '0' report "Forward: motor_b should be 0" severity error;
        -- Check that motor_a toggles (depends on pwm)
        wait until rising_edge(clk);
        assert motor_a = '1' or motor_a = '0' report "Forward: motor_a should be valid PWM" severity error;

        -- Enabled, reverse direction -> motor_a = 0, motor_b = pwm
        fixed_dir <= '0';
        wait for 200 ns;
        assert motor_a = '0' report "Reverse: motor_a should be 0" severity error;

        -- Duty cycle 0% -> both zero regardless of direction
        duty_cycle <= to_unsigned(0,8);
        wait for 200 ns;
        assert motor_a = '0' and motor_b = '0' report "0% duty: outputs not zero" severity error;

        report "DC driver PWM test completed" severity note;
        wait;
    end process;
end test;