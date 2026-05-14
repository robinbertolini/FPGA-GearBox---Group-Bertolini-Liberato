--------------------------------------------------------------------------------
-- Entity   : stepper_motor_ctrl
-- Purpose  : Single-channel stepper motor controller driven entirely by an FSM.
--            Generates the 8-step half-step excitation sequence for a
--            4-wire unipolar stepper motor (IN1..IN4).
--
-- Generics :
--   CLK_FREQ_HZ  – board clock frequency in Hz  (edit at top-level only)
--   STEP_FREQ_HZ – desired stepping rate in Hz   (default 100 steps/s)
--
-- Ports :
--   clk      – system clock (rising-edge)
--   rst      – synchronous active-high reset
--   enable   – '1' = motor runs, '0' = all coils off (free-wheel)
--   dir      – '1' = forward (CW), '0' = backward (CCW)
--   coils    – 4-bit coil drive vector (IN1 downto IN4)
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stepper_motor_ctrl is
    generic (
        CLK_FREQ_HZ  : positive := 100_000_000;   -- overridden by top-level
        STEP_FREQ_HZ : positive := 100             -- steps per second
    );
    port (
        clk    : in  std_logic;
        rst    : in  std_logic;
        enable : in  std_logic;
        dir    : in  std_logic;
        coils  : out std_logic_vector(3 downto 0)  -- (IN1, IN2, IN3, IN4)
    );
end entity stepper_motor_ctrl;

architecture rtl of stepper_motor_ctrl is

    ---------------------------------------------------------------------------
    -- Timing constant (elaboration-time division, zero hardware cost)
    ---------------------------------------------------------------------------
    constant CYCLES_PER_STEP : positive := CLK_FREQ_HZ / STEP_FREQ_HZ;

    ---------------------------------------------------------------------------
    -- FSM state type  (IDLE + 8 half-step states)
    ---------------------------------------------------------------------------
    type fsm_state_t is (
        IDLE,
        STEP0, STEP1, STEP2, STEP3,
        STEP4, STEP5, STEP6, STEP7
    );

    ---------------------------------------------------------------------------
    -- Internal signals — each driven by exactly ONE process
    ---------------------------------------------------------------------------
    signal state      : fsm_state_t := IDLE;          -- driven by p_fsm only
    signal tick_cnt   : integer range 0 to CYCLES_PER_STEP - 1 := 0;
    signal tick_pulse : std_logic := '0';              -- driven by p_tick only

begin

    ---------------------------------------------------------------------------
    -- Process 1 – Tick generator (registered)
    -- Produces a single-cycle '1' pulse every CYCLES_PER_STEP clock edges.
    ---------------------------------------------------------------------------
    p_tick : process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' or enable = '0' then
                tick_cnt   <= 0;
                tick_pulse <= '0';
            else
                if tick_cnt = CYCLES_PER_STEP - 1 then
                    tick_cnt   <= 0;
                    tick_pulse <= '1';
                else
                    tick_cnt   <= tick_cnt + 1;
                    tick_pulse <= '0';
                end if;
            end if;
        end if;
    end process p_tick;

    ---------------------------------------------------------------------------
    -- Process 2 – FSM next-state logic (registered)
    -- `state` is the ONLY signal written here.
    ---------------------------------------------------------------------------
    p_fsm : process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= IDLE;
            else
                case state is

                    when IDLE =>
                        if enable = '1' then
                            state <= STEP0;
                        end if;

                    when STEP0 =>
                        if enable = '0' then
                            state <= IDLE;
                        elsif tick_pulse = '1' then
                            if dir = '1' then state <= STEP1;
                            else              state <= STEP7; end if;
                        end if;

                    when STEP1 =>
                        if enable = '0' then
                            state <= IDLE;
                        elsif tick_pulse = '1' then
                            if dir = '1' then state <= STEP2;
                            else              state <= STEP0; end if;
                        end if;

                    when STEP2 =>
                        if enable = '0' then
                            state <= IDLE;
                        elsif tick_pulse = '1' then
                            if dir = '1' then state <= STEP3;
                            else              state <= STEP1; end if;
                        end if;

                    when STEP3 =>
                        if enable = '0' then
                            state <= IDLE;
                        elsif tick_pulse = '1' then
                            if dir = '1' then state <= STEP4;
                            else              state <= STEP2; end if;
                        end if;

                    when STEP4 =>
                        if enable = '0' then
                            state <= IDLE;
                        elsif tick_pulse = '1' then
                            if dir = '1' then state <= STEP5;
                            else              state <= STEP3; end if;
                        end if;

                    when STEP5 =>
                        if enable = '0' then
                            state <= IDLE;
                        elsif tick_pulse = '1' then
                            if dir = '1' then state <= STEP6;
                            else              state <= STEP4; end if;
                        end if;

                    when STEP6 =>
                        if enable = '0' then
                            state <= IDLE;
                        elsif tick_pulse = '1' then
                            if dir = '1' then state <= STEP7;
                            else              state <= STEP5; end if;
                        end if;

                    when STEP7 =>
                        if enable = '0' then
                            state <= IDLE;
                        elsif tick_pulse = '1' then
                            if dir = '1' then state <= STEP0;
                            else              state <= STEP6; end if;
                        end if;

                    when others =>
                        state <= IDLE;

                end case;
            end if;
        end if;
    end process p_fsm;

    ---------------------------------------------------------------------------
    -- Process 3 – Moore output decoder (purely combinational)
    -- Maps state -> coil pattern directly. No shared signals with other processes.
    -- Half-step table: (IN1, IN2, IN3, IN4)
    ---------------------------------------------------------------------------
    p_output : process (state)
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
            when others => coils <= "0000";  -- IDLE: de-energise all coils
        end case;
    end process p_output;

end architecture rtl;