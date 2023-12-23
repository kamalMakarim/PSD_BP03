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
        port (
            INSTRUCTION : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
            DATA_IN : OUT STD_LOGIC_VECTOR (63 DOWNTO 0);
            DONE : IN STD_LOGIC;
            WANT_TO_USE : OUT STD_LOGIC;
            CLK : IN STD_LOGIC;
            CPU_NOT_READY : IN STD_LOGIC;
            DATA_OUT : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
            CARD_ID : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        );
    end component interfaceMasuk;
    component interfaceKeluar is
        port (
            INSTRUCTION : IN STD_LOGIC_VECTOR (10 DOWNTO 0);
            DATA_IN : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
            DONE : OUT STD_LOGIC;
            WANT_TO_USE : IN STD_LOGIC;
            CLK : IN STD_LOGIC;
            CPU_NOT_READY : OUT STD_LOGIC;
            DATA_OUT : OUT STD_LOGIC_VECTOR (63 DOWNTO 0);
            CARD_ID : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        );
    end component interfaceKeluar;
    component
begin
    
    
end architecture rtl;