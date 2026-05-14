--------------------------------------------------------------------------------
-- Entity   : stepper_motor_ctrl
-- Purpose  : Variable-speed stepper motor controller using FSM sequencing.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stepper_motor_ctrl is
    generic (
        CLK_FREQ_HZ : positive := 100_000_000
    );
    port (
        clk    : in  std_logic;
        rst    : in  std_logic;

        enable : in  std_logic;
        dir    : in  std_logic;

        -- 0 = slowest
        -- 255 = fastest
        speed  : in  unsigned(7 downto 0);

        coils  : out std_logic_vector(3 downto 0)
    );
end entity stepper_motor_ctrl;

architecture rtl of stepper_motor_ctrl is

    ----------------------------------------------------------------------------
    -- VARIABLE STEP TIMING
    ----------------------------------------------------------------------------
    signal cycles_per_step : integer := 100000000;

    ----------------------------------------------------------------------------
    -- FSM STATES
    ----------------------------------------------------------------------------
    type fsm_state_t is (
        IDLE,
        STEP0, STEP1, STEP2, STEP3,
        STEP4, STEP5, STEP6, STEP7
    );

    ----------------------------------------------------------------------------
    -- INTERNAL SIGNALS
    ----------------------------------------------------------------------------
    signal state      : fsm_state_t := IDLE;
    signal tick_cnt   : integer := 0;
    signal tick_pulse : std_logic := '0';

begin

    ----------------------------------------------------------------------------
    -- SPEED CONTROL
    --
    -- speed 0   -> 1 step/sec
    -- speed 255 -> 200 step/sec
    ----------------------------------------------------------------------------
    p_speed : process(speed)
        variable freq : integer;
    begin

        freq := 1 + (to_integer(speed) * 199) / 255;

        cycles_per_step <= CLK_FREQ_HZ / freq;

    end process;

    ----------------------------------------------------------------------------
    -- TICK GENERATOR
    ----------------------------------------------------------------------------
    p_tick : process(clk)
    begin
        if rising_edge(clk) then

            if rst = '1' or enable = '0' then

                tick_cnt   <= 0;
                tick_pulse <= '0';

            else

                if tick_cnt >= cycles_per_step - 1 then

                    tick_cnt   <= 0;
                    tick_pulse <= '1';

                else

                    tick_cnt   <= tick_cnt + 1;
                    tick_pulse <= '0';

                end if;

            end if;

        end if;
    end process p_tick;

    ----------------------------------------------------------------------------
    -- FSM
    ----------------------------------------------------------------------------
    p_fsm : process(clk)
    begin
        if rising_edge(clk) then

            if rst = '1' then

                state <= IDLE;

            else

                case state is

                    ----------------------------------------------------------------
                    when IDLE =>

                        if enable = '1' then
                            state <= STEP0;
                        end if;

                    ----------------------------------------------------------------
                    when STEP0 =>

                        if enable = '0' then
                            state <= IDLE;

                        elsif tick_pulse = '1' then

                            if dir = '1' then
                                state <= STEP1;
                            else
                                state <= STEP7;
                            end if;

                        end if;

                    ----------------------------------------------------------------
                    when STEP1 =>

                        if enable = '0' then
                            state <= IDLE;

                        elsif tick_pulse = '1' then

                            if dir = '1' then
                                state <= STEP2;
                            else
                                state <= STEP0;
                            end if;

                        end if;

                    ----------------------------------------------------------------
                    when STEP2 =>

                        if enable = '0' then
                            state <= IDLE;

                        elsif tick_pulse = '1' then

                            if dir = '1' then
                                state <= STEP3;
                            else
                                state <= STEP1;
                            end if;

                        end if;

                    ----------------------------------------------------------------
                    when STEP3 =>

                        if enable = '0' then
                            state <= IDLE;

                        elsif tick_pulse = '1' then

                            if dir = '1' then
                                state <= STEP4;
                            else
                                state <= STEP2;
                            end if;

                        end if;

                    ----------------------------------------------------------------
                    when STEP4 =>

                        if enable = '0' then
                            state <= IDLE;

                        elsif tick_pulse = '1' then

                            if dir = '1' then
                                state <= STEP5;
                            else
                                state <= STEP3;
                            end if;

                        end if;

                    ----------------------------------------------------------------
                    when STEP5 =>

                        if enable = '0' then
                            state <= IDLE;

                        elsif tick_pulse = '1' then

                            if dir = '1' then
                                state <= STEP6;
                            else
                                state <= STEP4;
                            end if;

                        end if;

                    ----------------------------------------------------------------
                    when STEP6 =>

                        if enable = '0' then
                            state <= IDLE;

                        elsif tick_pulse = '1' then

                            if dir = '1' then
                                state <= STEP7;
                            else
                                state <= STEP5;
                            end if;

                        end if;

                    ----------------------------------------------------------------
                    when STEP7 =>

                        if enable = '0' then
                            state <= IDLE;

                        elsif tick_pulse = '1' then

                            if dir = '1' then
                                state <= STEP0;
                            else
                                state <= STEP6;
                            end if;

                        end if;

                    ----------------------------------------------------------------
                    when others =>

                        state <= IDLE;

                end case;

            end if;

        end if;
    end process p_fsm;

    ----------------------------------------------------------------------------
    -- OUTPUT DECODE
    ----------------------------------------------------------------------------
    p_output : process(state)
    begin

        case state is

            when STEP0  => coils <= "1000";
            when STEP1  => coils <= "1100";
            when STEP2  => coils <= "0100";
            when STEP3  => coils <= "0110";
            when STEP4  => coils <= "0010";
            when STEP5  => coils <= "0011";
            when STEP6  => coils <= "0001";
            when STEP7  => coils <= "1001";

            when others => coils <= "0000";

        end case;

    end process p_output;

end architecture rtl;