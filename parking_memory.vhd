library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity parking_memory is
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        data_in : in  std_logic_vector(63 downto 0); -- 64 bits for combined data
        wr_en   : in  std_logic;
        addr    : in  std_logic_vector(7 downto 0);  -- 8-bit address
        data_out: out std_logic_vector(63 downto 0);
        shift   : in  std_logic
    );
end entity parking_memory;

architecture behavioral of parking_memory is

    type memory_type is array (0 to 255) of std_logic_vector(63 downto 0); -- 256 entries
    signal memory_array : memory_type := (others => (others => '0')); -- Initialize to zero
    signal addr_temp : integer;

    begin
    process(clk, rst)
        variable addr_int : integer;
        begin
            if rst = '1' then
                memory_array <= (others => (others => '0'));  -- Initialize to zero
            elsif rising_edge(clk) then
                if wr_en = '1' then
                    addr_temp <= to_integer(unsigned(addr));
                    memory_array(addr_temp) <= data_in;
                end if;
            end if;
            if shift = '1' then
                addr_int := to_integer(unsigned(addr));
                for i in addr_int to 254 loop
                    memory_array(i) <= memory_array(i+1);
                end loop;
                memory_array(255) <= (others => '0');
            end if;
    end process;

    data_out <= memory_array(addr_temp);

end architecture behavioral;
