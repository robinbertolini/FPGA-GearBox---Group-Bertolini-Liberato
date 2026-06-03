library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_generator is
    generic (
        CLK_FREQ_HZ : positive := 100_000_000;
        PWM_FREQ_HZ : positive := 1000
    );
    port (
        clk        : in  std_logic;
        rst        : in  std_logic;

        duty_cycle : in  unsigned(7 downto 0);

        pwm_out    : out std_logic
    );
end entity;

architecture rtl of pwm_generator is

    constant PERIOD_COUNT : integer := CLK_FREQ_HZ / PWM_FREQ_HZ;

    signal counter : integer range 0 to PERIOD_COUNT - 1 := 0;

begin

    process(clk)
        variable threshold : integer;
    begin
        if rising_edge(clk) then

            if rst = '1' then
                counter <= 0;
                pwm_out <= '0';

            else

                if counter = PERIOD_COUNT - 1 then
                    counter <= 0;
                else
                    counter <= counter + 1;
                end if;

                threshold := (to_integer(duty_cycle) * PERIOD_COUNT) / 255;

                if counter < threshold then
                    pwm_out <= '1';
                else
                    pwm_out <= '0';
                end if;

            end if;

        end if;
    end process;

end architecture;