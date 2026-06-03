library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hc020k_speed_sensor is
    generic (
        CLK_FREQ_HZ       : positive := 100_000_000;   -- system clock frequency
        MEASUREMENT_MS    : positive := 100;           -- measurement window in ms
        SLOTS_PER_REV     : positive := 20             -- number of slots on encoder disc (e.g., 20 for typical HC-020K)
    );
    port (
        clk         : in  std_logic;                   -- 100 MHz clock
        rst         : in  std_logic;                   -- synchronous reset
        sensor_in   : in  std_logic;                   -- HC-020K OUT pin (digital)
        
        -- Speed outputs
        pulse_hz    : out std_logic_vector(15 downto 0);  -- pulses per second (0–65535)
        rpm         : out std_logic_vector(15 downto 0);  -- revolutions per minute
        valid       : out std_logic                       -- high for one clock when outputs updated
    );
end entity;

architecture rtl of hc020k_speed_sensor is
    -- Measurement window in clock cycles
    constant WINDOW_CYCLES : integer := (CLK_FREQ_HZ * MEASUREMENT_MS) / 1000;
    
    -- Edge detection signals
    signal sensor_prev : std_logic := '0';
    signal pulse_rise  : std_logic := '0';
    
    -- Pulse counter
    signal pulse_cnt    : unsigned(15 downto 0) := (others => '0');
    signal latched_cnt  : unsigned(15 downto 0) := (others => '0');
    
    -- Timer
    signal cycle_cnt    : integer range 0 to WINDOW_CYCLES := 0;
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                sensor_prev <= '0';
                pulse_rise  <= '0';
            else
                sensor_prev <= sensor_in;
                if sensor_in = '1' and sensor_prev = '0' then
                    pulse_rise <= '1';
                else
                    pulse_rise <= '0';
                end if;
            end if;
        end if;
    end process;
    
    ----------------------------------------------------------------------------
    -- Pulse counter and measurement timer
    ----------------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                pulse_cnt   <= (others => '0');
                cycle_cnt   <= 0;
                latched_cnt <= (others => '0');
                valid       <= '0';
            else
                valid <= '0';   -- default, only one clock pulse per window
                
                -- Pulse counting
                if pulse_rise = '1' then
                    pulse_cnt <= pulse_cnt + 1;
                end if;
                
                -- Measurement timer
                if cycle_cnt = WINDOW_CYCLES - 1 then
                    cycle_cnt   <= 0;
                    -- Latch the current count and calculate derived values
                    latched_cnt <= pulse_cnt;
                    pulse_cnt   <= (others => '0');
                    valid       <= '1';
                else
                    cycle_cnt <= cycle_cnt + 1;
                end if;
            end if;
        end if;
    end process;
    
    ----------------------------------------------------------------------------
    -- Output calculations (combinatorial)
    ----------------------------------------------------------------------------
    -- pulses per second = latched_cnt * (1000 / MEASUREMENT_MS)
    -- Since we only have integer arithmetic, compute as:
    -- pulse_hz = (latched_cnt * 1000) / MEASUREMENT_MS
    process(latched_cnt)
        variable temp : integer;
    begin
        temp := to_integer(latched_cnt) * (1000 / MEASUREMENT_MS);
        if temp > 65535 then
            pulse_hz <= (others => '1');
        else
            pulse_hz <= std_logic_vector(to_unsigned(temp, 16));
        end if;
        
        -- RPM = (pulse_hz * 60) / SLOTS_PER_REV
        temp := (to_integer(latched_cnt) * (1000 / MEASUREMENT_MS) * 60) / SLOTS_PER_REV;
        if temp > 65535 then
            rpm <= (others => '1');
        else
            rpm <= std_logic_vector(to_unsigned(temp, 16));
        end if;
    end process;
end architecture;