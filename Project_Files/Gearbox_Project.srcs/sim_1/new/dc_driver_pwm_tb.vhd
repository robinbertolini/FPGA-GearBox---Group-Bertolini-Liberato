library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dc_driver_pwm_tb is
end entity;

architecture sim of dc_driver_pwm_tb is
    constant CLK_PERIOD : time := 10 ns;
    
    signal clk        : std_logic := '0';
    signal rst        : std_logic := '1';
    signal enable     : std_logic := '0';
    signal fixed_dir  : std_logic := '1';
    signal duty_cycle : unsigned(7 downto 0) := (others => '0');
    signal motor_a    : std_logic;
    signal motor_b    : std_logic;
begin
    -- Clock
    clk <= not clk after CLK_PERIOD/2;
    
    -- DUT
    DUT: entity work.dc_driver_pwm
        generic map (
            CLK_FREQ_HZ => 100_000_000,
            PWM_FREQ_HZ => 2000
        )
        port map (
            clk        => clk,
            rst        => rst,
            enable     => enable,
            fixed_dir  => fixed_dir,
            duty_cycle => duty_cycle,
            motor_a    => motor_a,
            motor_b    => motor_b
        );
    
    -- Stimulus
    process
    begin
        -- Reset
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;
        
        -- Enable motor with 50% duty cycle forward
        enable <= '1';
        fixed_dir <= '1';
        duty_cycle <= to_unsigned(127, 8);
        wait for 1 ms;
        
        -- Switch to reverse
        fixed_dir <= '0';
        wait for 1 ms;
        
        -- Change duty cycle to 25%
        duty_cycle <= to_unsigned(63, 8);
        wait for 1 ms;
        
        -- Disable motor
        enable <= '0';
        wait for 500 ns;
        
        report "Test completato" severity note;
        wait;
    end process;
end architecture;