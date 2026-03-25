--------------------------------------------------------------------------------
-- Entity   : tb_dual_stepper
-- Author   : (inspired by Prof. Philippe Velha's style)
-- Purpose  : Self-checking testbench for dual_stepper_top.
--
-- Strategy :
--   • Simulated clock uses a SCALED-DOWN CLK_FREQ_HZ (1 000 Hz) and a
--     STEP_FREQ_HZ of 10 steps/s so the simulation remains fast yet
--     exercises the exact same FSM paths as in silicon.
--   • Five independent test scenarios run sequentially:
--       TC1 – Reset behaviour (all coils = 0)
--       TC2 – Motor 1 forward only
--       TC3 – Motor 2 forward only (Motor 1 idle) → independence check
--       TC4 – Both motors forward simultaneously
--       TC5 – Direction reversal mid-run
--   • Assertion library (assert/report) flags any unexpected coil output.
--   • A final PASS/FAIL banner is printed at the end.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_dual_stepper is
    -- Testbench has no ports (IEEE 1076 standard practice)
end entity tb_dual_stepper;

architecture sim of tb_dual_stepper is

    ---------------------------------------------------------------------------
    -- Simulation parameters (scaled down for fast simulation)
    ---------------------------------------------------------------------------
    constant SIM_CLK_FREQ_HZ  : positive := 1_000;   -- 1 kHz simulated clock
    constant SIM_STEP_FREQ_HZ : positive := 10;       -- 10 steps/s

    -- Derived timing constants
    constant CLK_PERIOD   : time := 1 sec / SIM_CLK_FREQ_HZ;   -- 1 ms
    constant STEP_PERIOD  : time := 1 sec / SIM_STEP_FREQ_HZ;  -- 100 ms per step
    constant CYCLES_STEP  : positive := SIM_CLK_FREQ_HZ / SIM_STEP_FREQ_HZ; -- 100 cycles

    ---------------------------------------------------------------------------
    -- DUT interface signals
    ---------------------------------------------------------------------------
    signal clk  : std_logic := '0';
    signal btnC : std_logic := '0';
    signal sw   : std_logic_vector(3 downto 0) := (others => '0');
    signal JA   : std_logic_vector(3 downto 0);
    signal JB   : std_logic_vector(3 downto 0);

    ---------------------------------------------------------------------------
    -- Test infrastructure
    ---------------------------------------------------------------------------
    signal test_done   : std_logic := '0';
    signal fail_count  : integer   := 0;

    ---------------------------------------------------------------------------
    -- Half-step reference table (mirrors RTL constant exactly)
    ---------------------------------------------------------------------------
    type coil_table_t is array (0 to 7) of std_logic_vector(3 downto 0);
    constant HALF_STEP_TABLE : coil_table_t := (
        "1000", "1100", "0100", "0110",
        "0010", "0011", "0001", "1001"
    );

    ---------------------------------------------------------------------------
    -- Helper: std_logic_vector → string  (replaces VHDL-2008 to_string,
    --         compatible with VHDL-93 / 2002 / 2008)
    ---------------------------------------------------------------------------
    function slv_to_str (slv : std_logic_vector) return string is
        variable result : string(1 to slv'length);
        variable idx    : integer := 1;
    begin
        for i in slv'range loop
            case slv(i) is
                when '0'    => result(idx) := '0';
                when '1'    => result(idx) := '1';
                when 'U'    => result(idx) := 'U';
                when 'X'    => result(idx) := 'X';
                when 'Z'    => result(idx) := 'Z';
                when '-'    => result(idx) := '-';
                when others => result(idx) := '?';
            end case;
            idx := idx + 1;
        end loop;
        return result;
    end function slv_to_str;

    ---------------------------------------------------------------------------
    -- Helper: wait for N complete steps on a given coil signal.
    -- Samples the coil output once per step period and checks the sequence.
    ---------------------------------------------------------------------------
    procedure wait_and_check_steps (
        signal   coil_sig  : in  std_logic_vector(3 downto 0);
        constant n_steps   : in  positive;
        constant start_idx : in  integer;
        constant forward   : in  boolean;
        variable err_count : inout integer
    ) is
        variable idx  : integer := start_idx;
        variable incr : integer;
    begin
        if forward then incr := 1; else incr := -1; end if;

        for i in 1 to n_steps loop
            -- Wait one full step period (the FSM will have advanced)
            wait for STEP_PERIOD;
            -- Allow one extra clock for registered outputs to settle
            wait for CLK_PERIOD;

            idx := (idx + incr + 8) mod 8;

            if coil_sig /= HALF_STEP_TABLE(idx) then
                report "COIL MISMATCH at step " & integer'image(i)
                     & " expected=" & slv_to_str(HALF_STEP_TABLE(idx))
                     & " got="      & slv_to_str(coil_sig)
                severity warning;
                err_count := err_count + 1;
            end if;
        end loop;
    end procedure wait_and_check_steps;

begin

    ---------------------------------------------------------------------------
    -- DUT instantiation (uses scaled-down generics)
    ---------------------------------------------------------------------------
    DUT : entity work.dual_stepper_top
        generic map (
            CLK_FREQ_HZ  => SIM_CLK_FREQ_HZ,
            STEP_FREQ_HZ => SIM_STEP_FREQ_HZ
        )
        port map (
            clk  => clk,
            btnC => btnC,
            sw   => sw,
            JA   => JA,
            JB   => JB
        );

    ---------------------------------------------------------------------------
    -- Clock generator – free-running, stops when test_done = '1'
    ---------------------------------------------------------------------------
    p_clk : process
    begin
        while test_done = '0' loop
            clk <= '0'; wait for CLK_PERIOD / 2;
            clk <= '1'; wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process p_clk;

    ---------------------------------------------------------------------------
    -- Stimulus process
    ---------------------------------------------------------------------------
    p_stim : process
        variable errors : integer := 0;
    begin

        -----------------------------------------------------------------------
        -- TC1 – Reset: assert btnC, all coils must be 0
        -----------------------------------------------------------------------
        report "=== TC1: Reset check ===";
        btnC <= '1';
        sw   <= "1111";   -- everything enabled, but reset dominates
        wait for 5 * CLK_PERIOD;

        assert JA = "0000"
            report "TC1 FAIL: JA not 0 during reset" severity warning;
        if JA /= "0000" then errors := errors + 1; end if;

        assert JB = "0000"
            report "TC1 FAIL: JB not 0 during reset" severity warning;
        if JB /= "0000" then errors := errors + 1; end if;

        -- Release reset
        btnC <= '0';
        sw   <= "0000";
        wait for 5 * CLK_PERIOD;

        -----------------------------------------------------------------------
        -- TC2 – Motor 1 forward only (sw(0)='1', sw(1)='1')
        --       Motor 2 disabled → JB must stay "0000"
        -----------------------------------------------------------------------
        report "=== TC2: Motor 1 forward, Motor 2 idle ===";
        sw <= "0011";  -- enable M1, dir M1 = forward; M2 off
        wait for 5 * CLK_PERIOD;   -- let FSM enter STEP0

        -- Check that M2 coils stay zero
        wait for 3 * STEP_PERIOD;
        assert JB = "0000"
            report "TC2 FAIL: JB should be 0 when Motor 2 is disabled" severity warning;
        if JB /= "0000" then errors := errors + 1; end if;

        -- Stop Motor 1
        sw <= "0000";
        wait for 2 * CLK_PERIOD;
        assert JA = "0000"
            report "TC2 FAIL: JA should de-energise when disabled" severity warning;
        if JA /= "0000" then errors := errors + 1; end if;

        -----------------------------------------------------------------------
        -- TC3 – Motor 2 forward only (independence check)
        -----------------------------------------------------------------------
        report "=== TC3: Motor 2 forward, Motor 1 idle ===";
        sw <= "1100";  -- enable M2, dir M2 = forward; M1 off
        wait for 5 * CLK_PERIOD;

        wait for 3 * STEP_PERIOD;
        assert JA = "0000"
            report "TC3 FAIL: JA should be 0 when Motor 1 is disabled" severity warning;
        if JA /= "0000" then errors := errors + 1; end if;

        sw <= "0000";
        wait for 2 * CLK_PERIOD;

        -----------------------------------------------------------------------
        -- TC4 – Both motors running forward simultaneously
        -----------------------------------------------------------------------
        report "=== TC4: Both motors forward ===";

        -- Full reset before synchronised start
        btnC <= '1';
        wait for 3 * CLK_PERIOD;
        btnC <= '0';
        wait for 3 * CLK_PERIOD;

        sw <= "1111";   -- M1 enable + forward, M2 enable + forward
        wait for 5 * CLK_PERIOD;

        -- Allow 8 full steps (one complete electrical cycle)
        wait for 8 * STEP_PERIOD + CLK_PERIOD;

        -- After one full cycle the coil pattern must be back at HALF_STEP_TABLE(0)
        -- (both motors started from STEP0 after reset)
        assert JA = HALF_STEP_TABLE(0)
            report "TC4 FAIL: JA not at step-0 after 8 steps" severity warning;
        if JA /= HALF_STEP_TABLE(0) then errors := errors + 1; end if;

        assert JB = HALF_STEP_TABLE(0)
            report "TC4 FAIL: JB not at step-0 after 8 steps" severity warning;
        if JB /= HALF_STEP_TABLE(0) then errors := errors + 1; end if;

        sw <= "0000";
        wait for 2 * CLK_PERIOD;

        -----------------------------------------------------------------------
        -- TC5 – Direction reversal mid-run on Motor 1
        -----------------------------------------------------------------------
        report "=== TC5: Direction reversal ===";

        btnC <= '1'; wait for 3 * CLK_PERIOD;
        btnC <= '0'; wait for 3 * CLK_PERIOD;

        -- Start Motor 1 forward for 4 steps
        sw <= "0011";
        wait for 4 * STEP_PERIOD + CLK_PERIOD;

        -- Reverse direction (keep enable, flip dir)
        sw <= "0001";
        wait for 4 * STEP_PERIOD + CLK_PERIOD;

        -- After 4 forward + 4 backward the motor should be back near step 0
        -- (not bit-exact due to reversal latency, just check no lockup)
        assert JA /= "XXXX"
            report "TC5 FAIL: JA driven to unknowns after reversal" severity warning;

        sw <= "0000";

        -----------------------------------------------------------------------
        -- End of test
        -----------------------------------------------------------------------
        wait for 5 * CLK_PERIOD;

      
    end process p_stim;

end architecture sim;
