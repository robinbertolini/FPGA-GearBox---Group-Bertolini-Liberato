library ieee;
use ieee.std_logic_1164.all;

entity main_motor_top_pwm_tb is
end entity;

architecture sim of main_motor_top_pwm_tb is
    constant CLK_PERIOD : time := 10 ns;
    signal clk : std_logic := '0';
    signal btnC, btnU, btnL, btnD, btnR : std_logic := '0';
    signal sw : std_logic_vector(15 downto 0) := (others => '0');
    signal led : std_logic_vector(3 downto 0);
    signal JA : std_logic_vector(3 downto 2);
    signal JB, JC : std_logic_vector(3 downto 0);
    signal sensor_in1, sensor_in2 : std_logic := '0';
    signal seg : std_logic_vector(6 downto 0);
    signal an : std_logic_vector(3 downto 0);
    signal dp : std_logic;
begin
    clk <= not clk after CLK_PERIOD/2;
    
    DUT: entity work.main_motor_top_pwm
        port map (
            clk => clk, btnC => btnC, btnU => btnU, btnL => btnL,
            btnR => btnR, btnD => btnD, sw => sw, led => led,
            JA => JA, JB => JB, JC => JC,
            sensor_in1 => sensor_in1, sensor_in2 => sensor_in2,
            seg => seg, an => an, dp => dp
        );
    
    process
    begin
        -- reset
        sw(15) <= '1'; wait for 200 ns;
        sw(15) <= '0'; wait for 200 ns;
        
        -- attendi calibrazione
        wait until led(0) = '1' and led(1) = '1';
        wait for 10 us;
        
        -- abilita motore
        sw(0) <= '1';
        wait for 1 ms;
        
        -- marcia 1
        btnU <= '1'; wait for 1 us; btnU <= '0';
        wait for 50 ms;
        
        -- marcia 2
        btnL <= '1'; wait for 1 us; btnL <= '0';
        wait for 50 ms;
        
        -- fine
        report "Test completato" severity note;
        wait;
    end process;
end architecture;