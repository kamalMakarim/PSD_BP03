library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity computer is
    generic (
        hz : integer := 1;
    );
    port (
        clk : in std_logic;
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
            BALANCE : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
        );
    end component interfaceKeluar;

    component parking_memory is
        port (
            clk     : in  std_logic;
            rst     : in  std_logic;
            data_in : in  std_logic_vector(63 downto 0); -- 64 bits for combined data
            wr_en   : in  std_logic;
            addr    : in  std_logic_vector(7 downto 0);  -- 8-bit address
            data_out: out std_logic_vector(63 downto 0)
        );
    end component parking_memory;

    signal data_in : std_logic_vector(63 downto 0);
    signal data_out : std_logic_vector(63 downto 0);
    signal opcode : std_logic_vector(2 downto 0);
    signal mode : std_logic_vector(1 downto 0);
    signal operandA : std_logic_vector(2 downto 0);
    signal operandB : std_logic_vector(2 downto 0);

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
            balance => data_out
        );
    process(clk)
    begin
        if rising_edge(clk) then
            if want_to_use1 = '1' then
                opcode <= instruction2(10 downto 8);
                mode <= instruction2(7 downto 6);
                operandA <= instruction2(5 downto 3);
                operandB <= instruction2(2 downto 0);
                data_in <= data_in1;
                data_out <= data_out1;
            elsif want_to_use2 = '1' then
                opcode <= instruction2(10 downto 8);
                mode <= instruction2(7 downto 6);
                operandA <= instruction2(5 downto 3);
                operandB <= instruction2(2 downto 0);
                data_in <= data_in2;
                data_out <= data_out2;
            end if;

            case opcode is 
                when "000" => 
        end if;
    end process;
end architecture rtl;