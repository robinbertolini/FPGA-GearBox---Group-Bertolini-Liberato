--------------------------------------------------------------------------------
-- Entity   : dual_stepper_top
-- Purpose  : Top-level wrapper for two independent stepper motor controllers.
--            Motor 1 → Pmod JA[1..4] (IN1..IN4)
--            Motor 2 → Pmod JB[1..4] (IN1..IN4)
--
-- *** EDIT CLK_FREQ_HZ HERE TO MATCH YOUR BOARD CLOCK ***
--     Basys3 default: 100 MHz
--
-- Controls (tied to slide switches on Basys3):
--   sw(0)  – Motor 1 enable
--   sw(1)  – Motor 1 direction
--   sw(2)  – Motor 2 enable
--   sw(3)  – Motor 2 direction
--   btnC   – Synchronous reset (centre button)
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity dual_stepper_top is
    generic (
        -- ┌─────────────────────────────────────────────────┐
        -- │  SINGLE POINT OF TRUTH – change only this value │
        -- └─────────────────────────────────────────────────┘
        CLK_FREQ_HZ  : positive := 100_000_000;   -- Basys3: 100 MHz
        STEP_FREQ_HZ : positive := 100             -- 100 steps/s per motor
    );
    port (
        clk   : in  std_logic;                     -- 100 MHz on-board oscillator
        btnC  : in  std_logic;                     -- centre push-button → reset
        sw    : in  std_logic_vector(3 downto 0);  -- slide switches

        -- Pmod JA – Motor 1 (upper row, pins 1-4)
        JA    : out std_logic_vector(3 downto 0);  -- JA(0)=IN1 … JA(3)=IN4

        -- Pmod JB – Motor 2 (upper row, pins 1-4)
        JB    : out std_logic_vector(3 downto 0)   -- JB(0)=IN1 … JB(3)=IN4
    );
end entity dual_stepper_top;

architecture structural of dual_stepper_top is

    ---------------------------------------------------------------------------
    -- Component declaration (matches stepper_motor_ctrl.vhd)
    ---------------------------------------------------------------------------
    component stepper_motor_ctrl is
        generic (
            CLK_FREQ_HZ  : positive;
            STEP_FREQ_HZ : positive
        );
        port (
            clk    : in  std_logic;
            rst    : in  std_logic;
            enable : in  std_logic;
            dir    : in  std_logic;
            coils  : out std_logic_vector(3 downto 0)
        );
    end component stepper_motor_ctrl;

begin

    ---------------------------------------------------------------------------
    -- Instance 1: Motor connected to Pmod JA
    --   sw(0) → enable,  sw(1) → direction
    ---------------------------------------------------------------------------
    U_MOTOR1 : stepper_motor_ctrl
        generic map (
            CLK_FREQ_HZ  => CLK_FREQ_HZ,
            STEP_FREQ_HZ => STEP_FREQ_HZ
        )
        port map (
            clk    => clk,
            rst    => btnC,
            enable => sw(0),
            dir    => sw(1),
            coils  => JA
        );

    ---------------------------------------------------------------------------
    -- Instance 2: Motor connected to Pmod JB
    --   sw(2) → enable,  sw(3) → direction
    ---------------------------------------------------------------------------
    U_MOTOR2 : stepper_motor_ctrl
        generic map (
            CLK_FREQ_HZ  => CLK_FREQ_HZ,
            STEP_FREQ_HZ => STEP_FREQ_HZ
        )
        port map (
            clk    => clk,
            rst    => btnC,
            enable => sw(2),
            dir    => sw(3),
            coils  => JB
        );

end architecture structural;
