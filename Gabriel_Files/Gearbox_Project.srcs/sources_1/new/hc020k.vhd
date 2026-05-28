-- ===========================================================
-- hc020k  v3 - adds debounce filter after synchronizer
-- Fixes: display oscillating 0000 ↔ 9999 due to sensor noise
-- ===========================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity hc020k is
    generic (
        CLK_FREQ_HZ    : positive := 100_000_000;
        MEASUREMENT_MS : positive := 500;
        SLOTS_PER_REV  : positive := 22
    );
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        sensor_in : in  std_logic;
        rpm       : out std_logic_vector(15 downto 0);
        valid     : out std_logic
    );
end entity;

architecture rtl of hc020k is

    -- Total cycles in one measurement window (50 000 000 for 500 ms @ 100 MHz)
    constant WINDOW_CYCLES   : positive := (CLK_FREQ_HZ / 1000) * MEASUREMENT_MS;

    -- Debounce: reject transitions lasting fewer than this many cycles.
    -- 1 000 cycles = 10 µs @ 100 MHz.
    -- Legitimate holes at 9 999 RPM stay high ~136 µs >> 10 µs.
    -- Noise glitches are typically < 1 µs, so they never survive this filter.
    constant DEBOUNCE_CYCLES : positive := 1000;

    -- RPM scale factor: 60 000 / MEASUREMENT_MS  (= 120 for 500 ms)
    constant SCALE           : positive := 60000 / MEASUREMENT_MS;

    -- ── 2-stage synchronizer (metastability) ─────────────────────────────────
    signal sync1, sync2 : std_logic := '0';
    attribute ASYNC_REG : string;
    attribute ASYNC_REG of sync1 : signal is "TRUE";
    attribute ASYNC_REG of sync2 : signal is "TRUE";

    -- ── Debounce filter ───────────────────────────────────────────────────────
    signal db_cnt  : integer range 0 to DEBOUNCE_CYCLES := 0;
    signal db_sig  : std_logic := '0';   -- clean, debounced output
    signal db_prev : std_logic := '0';   -- one-cycle delay for edge detection

    -- ── Measurement ───────────────────────────────────────────────────────────
    signal window_cnt : integer range 0 to WINDOW_CYCLES := 0;
    signal pulse_cnt  : integer range 0 to 65535         := 0;

    -- ── Output registers ─────────────────────────────────────────────────────
    signal rpm_reg   : std_logic_vector(15 downto 0) := (others => '0');
    signal valid_reg : std_logic := '0';

begin

    -- ─────────────────────────────────────────────────────────────────────────
    -- Stage 1: 2-stage synchronizer  (never access sensor_in directly below)
    -- ─────────────────────────────────────────────────────────────────────────
    process(clk)
    begin
        if rising_edge(clk) then
            sync1 <= sensor_in;
            sync2 <= sync1;
        end if;
    end process;

    -- ─────────────────────────────────────────────────────────────────────────
    -- Stage 2: Debounce filter
    -- The signal must remain stable for DEBOUNCE_CYCLES before db_sig updates.
    -- This kills any glitch shorter than 10 µs while passing real slot edges.
    -- ─────────────────────────────────────────────────────────────────────────
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                db_cnt <= 0;
                db_sig <= '0';
            else
                if sync2 = db_sig then
                    -- Signal is in its stable state; reset the counter
                    db_cnt <= 0;
                else
                    -- Signal differs from stable state; count how long it holds
                    if db_cnt = DEBOUNCE_CYCLES - 1 then
                        -- Held long enough → accept the new level
                        db_sig <= sync2;
                        db_cnt <= 0;
                    else
                        db_cnt <= db_cnt + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- ─────────────────────────────────────────────────────────────────────────
    -- Stage 3: Count rising edges of clean signal; compute RPM each window
    -- ─────────────────────────────────────────────────────────────────────────
    process(clk)
        variable rpm_calc : integer;
    begin
        if rising_edge(clk) then
            valid_reg <= '0';

            if rst = '1' then
                db_prev    <= '0';
                window_cnt <= 0;
                pulse_cnt  <= 0;
                rpm_reg    <= (others => '0');

            else
                db_prev <= db_sig;   -- pipeline delay for edge detection

                if window_cnt = WINDOW_CYCLES - 1 then
                    -- ── End of window: compute and latch RPM ─────────────────
                    -- RPM = (pulses / SLOTS_PER_REV) × (60 000 / MEASUREMENT_MS)
                    --     = pulse_cnt × SCALE / SLOTS_PER_REV
                    rpm_calc := (pulse_cnt * SCALE * 5) / (SLOTS_PER_REV * 4);

                    if rpm_calc > 9999 then
                        rpm_calc := 9999;
                    end if;

                    rpm_reg    <= std_logic_vector(to_unsigned(rpm_calc, 16));
                    valid_reg  <= '1';

                    -- Reset for next window
                    window_cnt <= 0;
                    pulse_cnt  <= 0;

                else
                    window_cnt <= window_cnt + 1;

                    -- Count rising edge of debounced signal only
                    if db_sig = '1' and db_prev = '0' then
                        if pulse_cnt < 65535 then
                            pulse_cnt <= pulse_cnt + 1;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    rpm   <= rpm_reg;
    valid <= valid_reg;

end architecture;