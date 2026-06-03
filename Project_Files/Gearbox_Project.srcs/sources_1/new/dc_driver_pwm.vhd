library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dc_driver_pwm is
    generic (
        CLK_FREQ_HZ : positive := 100_000_000;
        PWM_FREQ_HZ : positive := 2000
    );
    port (
        clk : in std_logic;
        rst : in std_logic;

        enable : in std_logic;


        -- DIRECTION
        -- 0 = reverse
        -- 1 = forward

        fixed_dir : in std_logic;

        duty_cycle : in unsigned(7 downto 0);

        motor_a : out std_logic;
        motor_b : out std_logic
    );
end entity;

architecture rtl of dc_driver_pwm is

    component pwm_generator is
        generic (
            CLK_FREQ_HZ : positive;
            PWM_FREQ_HZ : positive
        );
        port (
            clk : in std_logic;
            rst : in std_logic;

            duty_cycle : in unsigned(7 downto 0);

            pwm_out : out std_logic
        );
    end component;

    signal pwm_sig : std_logic;

begin

    ----------------------------------------------------------------------------
    -- PWM
    ----------------------------------------------------------------------------
    U_PWM : pwm_generator
        generic map (
            CLK_FREQ_HZ => CLK_FREQ_HZ,
            PWM_FREQ_HZ => PWM_FREQ_HZ
        )
        port map (
            clk => clk,
            rst => rst,

            duty_cycle => duty_cycle,

            pwm_out => pwm_sig
        );

    ----------------------------------------------------------------------------
    -- OUTPUTS
    ----------------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then

            if rst = '1' then

                motor_a <= '0';
                motor_b <= '0';

            else

                if enable = '0' then

                    motor_a <= '0';
                    motor_b <= '0';

                else

                    if fixed_dir = '1' then

                        motor_a <= pwm_sig;
                        motor_b <= '0';

                    else

                        motor_a <= '0';
                        motor_b <= pwm_sig;

                    end if;

                end if;

            end if;

        end if;
    end process;

end architecture;