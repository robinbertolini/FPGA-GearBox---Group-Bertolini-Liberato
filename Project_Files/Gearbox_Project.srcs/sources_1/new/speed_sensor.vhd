library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity speed_sensor is
    generic (
        CLK_FREQ_HZ : positive := 100_000_000;   -- 100 MHz
        GATE_TIME_S : positive := 1              -- 1 second
    );
    port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        sensor   : in  std_logic;                -- ingresso  HC-020K
        speed    : out unsigned(13 downto 0)     -- impulse/second (max 16383)
    );
end entity;

architecture rtl of speed_sensor is
    constant MAX_COUNT : integer := CLK_FREQ_HZ * GATE_TIME_S - 1;
    signal gate_cnt    : integer range 0 to MAX_COUNT := 0;
    signal pulse_cnt   : integer range 0 to 20000 := 0;
    signal speed_reg   : unsigned(13 downto 0) := (others => '0');
    signal sensor_prev  : std_logic := '0';
begin
    speed <= speed_reg;

    process(clk, rst)
    begin
        if rst = '1' then
            gate_cnt   <= 0;
            pulse_cnt  <= 0;
            speed_reg  <= (others => '0');
            sensor_prev <= '0';
        elsif rising_edge(clk) then
            -- Rilevazione fronte di salita del sensore
            if sensor = '1' and sensor_prev = '0' then
                pulse_cnt <= pulse_cnt + 1;
            end if;
            sensor_prev <= sensor;

            -- Contatore del gate (1 secondo)
            if gate_cnt = MAX_COUNT then
                speed_reg  <= to_unsigned(pulse_cnt, 14);
                pulse_cnt  <= 0;
                gate_cnt   <= 0;
            else
                gate_cnt <= gate_cnt + 1;
            end if;
        end if;
    end process;
end architecture;