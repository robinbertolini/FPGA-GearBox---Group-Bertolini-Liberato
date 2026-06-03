library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hc020k is
    generic (
        CLK_FREQ_HZ    : positive := 100_000_000;  -- 100 MHz
        MEASUREMENT_MS : positive := 100;          -- window of 100 ms
        SLOTS_PER_REV  : positive := 20            
    );
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        sensor_in : in  std_logic;                 -- digital signal for HC-020K
        rpm       : out std_logic_vector(15 downto 0);  -- routes/min
        valid     : out std_logic                       -- '1' per un ciclo quando rpm è aggiornato
    );
end entity;

architecture rtl of hc020k is
    constant WINDOW_CYCLES : integer := (CLK_FREQ_HZ * MEASUREMENT_MS) / 1000;

    signal sensor_prev : std_logic := '0';
    signal pulse_rise  : std_logic;
    signal pulse_cnt   : unsigned(15 downto 0) := (others => '0');
    signal latched_cnt : unsigned(15 downto 0) := (others => '0');
    signal cycle_cnt   : integer range 0 to WINDOW_CYCLES := 0;
begin

    -- Rilevamento fronte di salita
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

    -- Contatore impulsi e temporizzatore
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                pulse_cnt   <= (others => '0');
                cycle_cnt   <= 0;
                latched_cnt <= (others => '0');
                valid       <= '0';
            else
                valid <= '0';

                if pulse_rise = '1' then
                    pulse_cnt <= pulse_cnt + 1;
                end if;

                if cycle_cnt = WINDOW_CYCLES - 1 then
                    cycle_cnt   <= 0;
                    latched_cnt <= pulse_cnt;
                    pulse_cnt   <= (others => '0');
                    valid       <= '1';
                else
                    cycle_cnt <= cycle_cnt + 1;
                end if;
            end if;
        end if;
    end process;

    -- Calcolo RPM
    process(latched_cnt)
        variable temp : integer;
    begin
        temp := (to_integer(latched_cnt) * (1000 / MEASUREMENT_MS) * 60) / SLOTS_PER_REV;
        if temp > 65535 then
            rpm <= (others => '1');
        else
            rpm <= std_logic_vector(to_unsigned(temp, 16));
        end if;
    end process;

end architecture;