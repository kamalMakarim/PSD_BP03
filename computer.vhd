library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity computer is
    generic (
        hz : integer := 1
    );
    port (
        clk : in std_logic
    );
end entity computer;

architecture rtl of computer is
    component interfaceMasuk is
        PORT (
            INSTRUCTION : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
            DATA_IN : OUT STD_LOGIC_VECTOR (63 DOWNTO 0);
            DONE : IN STD_LOGIC;
            WANT_TO_USE : OUT STD_LOGIC;
            CLK : IN STD_LOGIC;
            CPU_NOT_READY : IN STD_LOGIC;
            DATA_OUT : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
            CARD_ID : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            YEAR : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            MONTH : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            DAY : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
            HOUR : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
            MINUTE : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
            SECOND : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
        );
    end component interfaceMasuk;

    component interfaceKeluar is
        port (
            INSTRUCTION : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
            DATA_IN : OUT STD_LOGIC_VECTOR (63 DOWNTO 0);
            DONE : IN STD_LOGIC;
            WANT_TO_USE : OUT STD_LOGIC;
            CLK : IN STD_LOGIC;
            CPU_NOT_READY : IN STD_LOGIC;
            DATA_OUT : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
            CARD_ID : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            YEAR : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            MONTH : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            DAY : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
            HOUR : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
            MINUTE : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
            SECOND : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
            BALANCE : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
        );
    end component interfaceKeluar;

    component parking_memory is
        port (
            clk     : in  std_logic;
            rst     : in  std_logic;
            data_in : in  std_logic_vector(63 downto 0); -- 64 bits for combined data
            wr_en   : in  std_logic;
            addr    : in  std_logic_vector(7 downto 0);  -- 8-bit address
            data_out: out std_logic_vector(63 downto 0);
            shift   : in  std_logic
        );
    end component parking_memory;

    signal data_in : std_logic_vector(63 downto 0);
    signal data_out : std_logic_vector(63 downto 0);
    signal opcode : std_logic_vector(2 downto 0);
    signal mode : std_logic_vector(1 downto 0);
    signal operandA : std_logic_vector(2 downto 0);
    signal operandB : std_logic_vector(2 downto 0);
    type reg_array is array (0 to 7) of std_logic_vector(63 downto 0);
    signal reg : reg_array := (others => (others => '0'));
    signal addr : std_logic_vector(7 downto 0);
    signal data_in_memory : std_logic_vector(63 downto 0);
    signal data_out_memory : std_logic_vector(63 downto 0);
    signal balance : std_logic_vector(63 downto 0);
    signal done : std_logic;
    signal wr_en: std_logic;
    type state_type is (s0, s1, s2, s3, s4);
    signal state : state_type := s0;
    signal shift : std_logic;

    signal instruction1 : std_logic_vector(10 downto 0);
    signal instruction2 : std_logic_vector(10 downto 0);
    signal data_in1 : std_logic_vector(63 downto 0);
    signal data_in2 : std_logic_vector(63 downto 0);
    signal data_out1 : std_logic_vector(63 downto 0);
    signal data_out2 : std_logic_vector(63 downto 0);
    signal done1 : std_logic;
    signal done2 : std_logic;
    signal want_to_use1 : std_logic;
    signal want_to_use2 : std_logic;
    signal cpu_not_ready1 : std_logic;
    signal cpu_not_ready2 : std_logic;
    signal year1 : std_logic_vector(15 downto 0);
    signal year2 : std_logic_vector(15 downto 0);
    signal month1 : std_logic_vector(3 downto 0);
    signal month2 : std_logic_vector(3 downto 0);
    signal day1 : std_logic_vector(4 downto 0);
    signal day2 : std_logic_vector(4 downto 0);
    signal hour1 : std_logic_vector(4 downto 0);
    signal hour2 : std_logic_vector(4 downto 0);
    signal minute1 : std_logic_vector(5 downto 0);
    signal minute2 : std_logic_vector(5 downto 0);
    signal second1 : std_logic_vector(5 downto 0);
    signal second2 : std_logic_vector(5 downto 0);
    signal card_id1 : std_logic_vector(31 downto 0);
    signal card_id2 : std_logic_vector(31 downto 0);
begin
    interfaceMasuk_inst : interfaceMasuk
        port map (
            instruction => instruction1,
            data_in => data_in1,
            done => done1,
            want_to_use => want_to_use1,
            clk => clk,
            cpu_not_ready => cpu_not_ready1,
            data_out => data_out1,
            card_id => card_id1,
            year => year1,
            month => month1,
            day => day1,
            hour => hour1,
            minute => minute1,
            second => second1
        );
    interfaceKeluar_inst : interfaceKeluar
        port map (
            instruction => instruction2,
            data_in => data_in2,
            done => done2,
            want_to_use => want_to_use2,
            clk => clk,
            cpu_not_ready => cpu_not_ready2,
            data_out => data_out2,
            card_id => card_id2,
            year => year2,
            month => month2,
            day => day2,
            hour => hour2,
            minute => minute2,
            second => second2,
            balance => balance
        );
    parking_memory_inst : parking_memory
        port map (
            clk => clk,
            rst => '0',
            data_in => data_in_memory,
            wr_en => wr_en,
            addr => addr,
            data_out => data_out_memory,
            shift => shift
        );
    reg(0)(31 downto 0) <= "11000000111011010110111000000000";
    reg(1) <= (others => '0');
    process(clk)
        variable clock_counter : integer range 0 to hz-1 := 0;
        variable temp_integer, temp_integer1, temp_integer2 : integer;
        variable temp_vector : std_logic_vector(63 downto 0);
    begin
        if rising_edge(clk) then
            clock_counter := clock_counter + 1;
            if clock_counter = hz-1 then
                clock_counter := 0;
                temp_integer := to_integer(unsigned(reg(0)(31 downto 0)));
                temp_integer := temp_integer + 1;
                reg(0)(31 downto 0) <= std_logic_vector(to_unsigned(temp_integer, 32));
            end if;
            if want_to_use1 = '1' then
                opcode <= instruction2(10 downto 8);
                mode <= instruction2(7 downto 6);
                operandA <= instruction2(5 downto 3);
                operandB <= instruction2(2 downto 0);
                data_in <= data_in1;
            elsif want_to_use2 = '1' then
                opcode <= instruction2(10 downto 8);
                mode <= instruction2(7 downto 6);
                operandA <= instruction2(5 downto 3);
                operandB <= instruction2(2 downto 0);
                data_in <= data_in2;
            end if;
            done <= '0';
            shift <= '0';
            wr_en <= '0';

            case opcode is 
                when "000" =>
                    --remove
                    if state = s0 then
                        wr_en <= '0';
                        addr <= "11111111";
                        temp_vector(63 downto 32) := (others => '0');
                        state <= s1;
                    elsif state = s1 then
                        wr_en <= '0';
                        temp_integer := to_integer(signed(addr));
                        temp_integer := temp_integer + 1;
                        addr <= std_logic_vector(to_unsigned(temp_integer, 8));
                        state <= s2;
                    elsif state = s2 then
                        temp_vector(31 downto 0) := data_out_memory(63 downto 32);
                        temp_vector(63 downto 32) := (others => '0');
                        if data_in = temp_vector then
                            state <= s3;
                        else
                            state <= s1;
                        end if;
                    elsif state = s3 then
                        shift <= '1';
                        state <= s4;
                    elsif state = s4 then
                        done <= '1';
                    end if;
                when "001" =>
                    if state = s0 then
                        if mode = "00" then
                            temp_integer1 := to_integer(signed(data_out));
                            temp_integer2 := to_integer(unsigned(operandB));
                            temp_integer2 := to_integer(signed(reg(temp_integer2)));
                            temp_integer1 := temp_integer1 - temp_integer2;
                            data_out <= std_logic_vector(to_signed(temp_integer1, 64));
                            state <= s3;
                        elsif mode = "01" then
                            wr_en <= '0';
                            temp_integer1 := to_integer(unsigned(operandA));
                            temp_integer1 := to_integer(signed(reg(temp_integer1)));
                            temp_integer2 := to_integer(signed(operandB));
                            addr <= reg(temp_integer2)(7 downto 0);
                            state <= s1;
                        elsif mode = "10" then
                            temp_integer1 := to_integer(unsigned(operandA));
                            temp_integer1 := to_integer(signed(reg(temp_integer1)));
                            temp_integer2 := to_integer(signed(data_in));
                            temp_integer1 := temp_integer1 - temp_integer2;
                            temp_integer := to_integer(signed(operandA));
                            reg(temp_integer) <= std_logic_vector(to_signed(temp_integer1, 64));
                            state <= s3;
                        elsif mode = "11" then
                            temp_integer1 := to_integer(unsigned(operandA));
                            temp_integer1 := to_integer(signed(reg(temp_integer1)));
                            temp_integer2 := to_integer(unsigned(operandB));
                            temp_integer2 := to_integer(signed(reg(temp_integer2)));
                            temp_integer1 := temp_integer1 - temp_integer2;
                            temp_integer := to_integer(signed(operandA));
                            reg(temp_integer) <= std_logic_vector(to_signed(temp_integer1, 64));
                            state <= s3;
                        end if;
                    elsif state = s1 then
                        temp_integer2 := to_integer(signed(data_out_memory));
                        temp_integer1 := temp_integer1 - temp_integer2;
                        temp_integer := to_integer(signed(operandA));
                        reg(temp_integer) <= std_logic_vector(to_signed(temp_integer1, 64));
                        state <= s3;
                    elsif state = s3 then
                        done <= '1';
                        state <= s0;
                    end if;
                when "010" =>
                    --mul
                    if state = s0 then
                        if mode = "00" then
                            temp_integer1 := to_integer(signed(data_out));
                            temp_integer2 := to_integer(unsigned(operandB));
                            temp_integer2 := to_integer(signed(reg(temp_integer2)));
                            temp_integer1 := temp_integer1 * temp_integer2;
                            data_out <= std_logic_vector(to_signed(temp_integer1, 64));
                            state <= s3;
                        elsif mode = "01" then
                            wr_en <= '0';
                            temp_integer1 := to_integer(unsigned(operandA));
                            temp_integer1 := to_integer(signed(reg(temp_integer1)));
                            temp_integer2 := to_integer(signed(operandB));
                            addr <= reg(temp_integer2)(7 downto 0);
                            state <= s1;
                        elsif mode = "10" then
                            temp_integer1 := to_integer(unsigned(operandA));
                            temp_integer1 := to_integer(signed(reg(temp_integer1)));
                            temp_integer2 := to_integer(signed(data_in));
                            temp_integer1 := temp_integer1 * temp_integer2;
                            temp_integer := to_integer(signed(operandA));
                            reg(temp_integer) <= std_logic_vector(to_signed(temp_integer1, 64));
                            state <= s3;
                        elsif mode = "11" then
                            temp_integer1 := to_integer(unsigned(operandA));
                            temp_integer1 := to_integer(signed(reg(temp_integer1)));
                            temp_integer2 := to_integer(unsigned(operandB));
                            temp_integer2 := to_integer(signed(reg(temp_integer2)));
                            temp_integer1 := temp_integer1 * temp_integer2;
                            temp_integer := to_integer(signed(operandA));
                            reg(temp_integer) <= std_logic_vector(to_signed(temp_integer1, 64));
                            state <= s3;
                        end if;
                        done <= '1';
                    elsif state = s1 then
                        temp_integer2 := to_integer(signed(data_out_memory));
                        temp_integer1 := temp_integer1 * temp_integer2;
                        temp_integer := to_integer(signed(operandA));
                        reg(temp_integer) <= std_logic_vector(to_signed(temp_integer1, 64));
                        state <= s3;
                    elsif state = s3 then
                        done <= '1';
                        state <= s0;
                    end if;
                when "011" =>
                    --mov
                    if state = s0 then
                        if mode = "00" then
                            temp_integer2 := to_integer(unsigned(operandB));
                            temp_vector := reg(temp_integer2);
                            data_out <= std_logic_vector(to_signed(temp_integer1, 64));
                            state <= s3;
                        elsif mode = "01" then
                            wr_en <= '0';
                            temp_integer2 := to_integer(unsigned(operandB));
                            addr <= reg(temp_integer2)(7 downto 0);
                            state <= s1;
                        elsif mode = "10" then
                            temp_integer := to_integer(unsigned(operandA));
                            temp_vector := data_in;
                            reg(temp_integer) <= temp_vector;
                        elsif mode = "11" then
                            temp_integer1 := to_integer(unsigned(operandA));
                            temp_integer2 := to_integer(unsigned(operandB));
                            addr <= reg(temp_integer1)(7 downto 0);
                            wr_en <= '1';
                            data_in_memory <= reg(temp_integer2);
                            state <= s1;
                        end if;
                        done <= '1';
                    elsif state = s1 then
                        reg(temp_integer) <= data_out_memory;
                        state <= s3;
                    elsif state = s3 then
                        done <= '1';
                    end if;
                when "100" =>
                    report "save";
                when "101" =>
                    --div
                    if state = s0 then
                        if mode = "00" then
                            temp_integer1 := to_integer(signed(data_out));
                            temp_integer2 := to_integer(unsigned(operandB));
                            temp_integer2 := to_integer(signed(reg(temp_integer2)));
                            temp_integer1 := temp_integer1 / temp_integer2;
                            data_out <= std_logic_vector(to_signed(temp_integer1, 64));
                            state <= s3;
                        elsif mode = "01" then
                            wr_en <= '0';
                            temp_integer1 := to_integer(unsigned(operandA));
                            temp_integer1 := to_integer(signed(reg(temp_integer1)));
                            temp_integer2 := to_integer(signed(operandB));
                            addr <= reg(temp_integer2)(7 downto 0);
                            state <= s1;
                        elsif mode = "10" then
                            temp_integer1 := to_integer(unsigned(operandA));
                            temp_integer1 := to_integer(signed(reg(temp_integer1)));
                            temp_integer2 := to_integer(signed(data_in));
                            temp_integer1 := temp_integer1 / temp_integer2;
                            temp_integer := to_integer(signed(operandA));
                            reg(temp_integer) <= std_logic_vector(to_signed(temp_integer1, 64));
                            state <= s3;
                        elsif mode = "11" then
                            temp_integer1 := to_integer(unsigned(operandA));
                            temp_integer1 := to_integer(signed(reg(temp_integer1)));
                            temp_integer2 := to_integer(unsigned(operandB));
                            temp_integer2 := to_integer(signed(reg(temp_integer2)));
                            temp_integer1 := temp_integer1 / temp_integer2;
                            temp_integer := to_integer(signed(operandA));
                            reg(temp_integer) <= std_logic_vector(to_signed(temp_integer1, 64));
                            state <= s3;
                        end if;
                    elsif state = s1 then
                        temp_integer2 := to_integer(signed(data_out_memory));
                        temp_integer1 := temp_integer1 / temp_integer2;
                        temp_integer := to_integer(signed(operandA));
                        reg(temp_integer) <= std_logic_vector(to_signed(temp_integer1, 64));
                        state <= s3;
                    elsif state = s3 then
                        done <= '1';
                        state <= s0;
                    end if;
                when "110" =>
                    --inc
                    temp_integer1 := to_integer(unsigned(operandA));
                    temp_integer1 := to_integer(signed(reg(temp_integer1)));
                    temp_integer1 := temp_integer1 + 1;
                    temp_integer := to_integer(unsigned(operandA));
                    reg(temp_integer) <= std_logic_vector(to_signed(temp_integer1, 64));
                    done <= '1';
                when "111" =>
                    --dec
                    temp_integer1 := to_integer(unsigned(operandA));
                    temp_integer1 := to_integer(signed(reg(temp_integer1)));
                    temp_integer1 := temp_integer1 - 1;
                    temp_integer := to_integer(unsigned(operandA));
                    reg(temp_integer) <= std_logic_vector(to_signed(temp_integer1, 64));
                    done <= '1';
                when others => 
                    report "Error: opcode not recognized" severity error;
            end case;

            if want_to_use1 = '1' then
                data_out1 <= data_out;
                done1 <= done;
            elsif want_to_use2 = '1' then
                data_out2 <= data_out;
                done2 <= done;
            end if;
        end if;
    end process;
end architecture rtl;