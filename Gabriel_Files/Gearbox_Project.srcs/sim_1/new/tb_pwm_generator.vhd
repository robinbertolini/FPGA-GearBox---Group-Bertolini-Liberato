-- tb_pwm_generator.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_pwm_generator is
end tb_pwm_generator;

architecture test of tb_pwm_generator is
    constant CLK_PERIOD : time := 10 ns;   -- 100 MHz
    constant CLK_FREQ   : positive := 100_000_000;
    constant PWM_FREQ   : positive := 2000;
    constant PERIOD_CYCLES : integer := CLK_FREQ / PWM_FREQ;  -- = 50000

    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal duty_cycle : unsigned(7 downto 0) := (others => '0');
    signal pwm_out  : std_logic;

    procedure wait_cycles(signal clk : std_logic; n : positive) is
    begin
        for i in 1 to n loop
            wait until rising_edge(clk);
        end loop;
    end procedure;

begin
    -- DUT
    uut: entity work.pwm_generator
        generic map (CLK_FREQ_HZ => CLK_FREQ, PWM_FREQ_HZ => PWM_FREQ)
        port map (clk => clk, rst => rst, duty_cycle => duty_cycle, pwm_out => pwm_out);

    -- Clock generator
    clk <= not clk after CLK_PERIOD/2;

    -- Stimulus
    process
        variable high_cycles : integer;
        variable period_cycles : integer;
    begin
        -- Reset
        rst <= '1';
        wait_cycles(clk, 5);
        rst <= '0';
        wait_cycles(clk, 2);

        -- Test 0% duty
        duty_cycle <= to_unsigned(0, 8);
        wait_cycles(clk, PERIOD_CYCLES);
        assert pwm_out = '0' report "0% duty: output should be 0" severity error;

        -- Test 25% duty (64/255)
        duty_cycle <= to_unsigned(64, 8);
        wait_cycles(clk, PERIOD_CYCLES);
        -- Count high cycles (approximate, but works for simulation)
        high_cycles := 0;
        for i in 1 to PERIOD_CYCLES loop
            if pwm_out = '1' then high_cycles := high_cycles + 1; end if;
            wait until rising_edge(clk);
        end loop;
        assert high_cycles >= (PERIOD_CYCLES * 64 / 255) - 1 and
               high_cycles <= (PERIOD_CYCLES * 64 / 255) + 1
            report "25% duty: wrong number of high cycles" severity error;

        -- Test 50% duty (128/255)
        duty_cycle <= to_unsigned(128, 8);
        wait_cycles(clk, PERIOD_CYCLES);
        high_cycles := 0;
        for i in 1 to PERIOD_CYCLES loop
            if pwm_out = '1' then high_cycles := high_cycles + 1; end if;
            wait until rising_edge(clk);
        end loop;
        assert high_cycles >= (PERIOD_CYCLES / 2) - 1 and
               high_cycles <= (PERIOD_CYCLES / 2) + 1
            report "50% duty: wrong number of high cycles" severity error;

        -- Test 100% duty (255/255)
        duty_cycle <= to_unsigned(255, 8);
        wait_cycles(clk, PERIOD_CYCLES);
        assert pwm_out = '1' report "100% duty: output should be 1" severity error;

        report "PWM generator test completed" severity note;
        wait;
    end process;
end test;