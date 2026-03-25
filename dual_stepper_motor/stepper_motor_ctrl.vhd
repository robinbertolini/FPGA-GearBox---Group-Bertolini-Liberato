--------------------------------------------------------------------------------
-- Entity   : stepper_motor_ctrl
-- Author   : (inspired by Prof. Philippe Velha's style)
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
    -- Timing: number of clock cycles between two consecutive steps
    ---------------------------------------------------------------------------
    constant CYCLES_PER_STEP : positive :=
        CLK_FREQ_HZ / STEP_FREQ_HZ;               -- integer division, exact enough

    ---------------------------------------------------------------------------
    -- FSM state encoding
    -- IDLE   : motor disabled, coils de-energised
    -- STEPx  : half-step states 0..7 (8 states for smooth torque)
    -- TICK   : one-cycle "pulse" that advances the step pointer
    ---------------------------------------------------------------------------
    type fsm_state_t is (
        IDLE,
        STEP0, STEP1, STEP2, STEP3,
        STEP4, STEP5, STEP6, STEP7
    );

    -- Half-step excitation table: (IN1, IN2, IN3, IN4)
    -- Follows the standard 28BYJ-48 / generic 4-wire unipolar sequence
    type coil_table_t is array (0 to 7) of std_logic_vector(3 downto 0);
    constant HALF_STEP_TABLE : coil_table_t := (
        "1000",   -- step 0
        "1100",   -- step 1
        "0100",   -- step 2
        "0110",   -- step 3
        "0010",   -- step 4
        "0011",   -- step 5
        "0001",   -- step 6
        "1001"    -- step 7
    );

    ---------------------------------------------------------------------------
    -- Internal signals
    ---------------------------------------------------------------------------
    signal state      : fsm_state_t := IDLE;
    signal step_idx   : integer range 0 to 7 := 0;
    signal tick_cnt   : integer range 0 to CYCLES_PER_STEP - 1 := 0;
    signal tick_pulse : std_logic := '0';          -- one-cycle strobe

begin

    ---------------------------------------------------------------------------
    -- Process 1 – Tick generator
    -- Produces a one-cycle pulse every CYCLES_PER_STEP clocks.
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
    -- Process 2 – FSM
    -- Controls the step sequencer state machine.
    ---------------------------------------------------------------------------
    p_fsm : process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state    <= IDLE;
                step_idx <= 0;

            else
                case state is

                    -- --------------------------------------------------------
                    when IDLE =>
                        step_idx <= 0;
                        if enable = '1' then
                            state <= STEP0;
                        end if;

                    -- --------------------------------------------------------
                    -- Each STEPx state: hold coil pattern until tick fires,
                    -- then advance to next step (direction-aware).
                    -- --------------------------------------------------------
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
    -- Process 3 – Step index decoder
    -- Maps FSM state → integer index into the half-step table.
    -- Purely combinational (no registered delay on coil outputs).
    ---------------------------------------------------------------------------
    p_step_decode : process (state)
    begin
        case state is
            when STEP0  => step_idx <= 0;
            when STEP1  => step_idx <= 1;
            when STEP2  => step_idx <= 2;
            when STEP3  => step_idx <= 3;
            when STEP4  => step_idx <= 4;
            when STEP5  => step_idx <= 5;
            when STEP6  => step_idx <= 6;
            when STEP7  => step_idx <= 7;
            when others => step_idx <= 0;
        end case;
    end process p_step_decode;

    ---------------------------------------------------------------------------
    -- Output logic
    -- When IDLE, all coils are de-energised (prevents heating at standstill).
    ---------------------------------------------------------------------------
    coils <= HALF_STEP_TABLE(step_idx) when state /= IDLE
             else "0000";

end architecture rtl;
