library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity computer is
    generic (
        hz : integer := 1
        hz : integer := 1
    );
    port (
        clk : in std_logic
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
    
    
end architecture rtl;