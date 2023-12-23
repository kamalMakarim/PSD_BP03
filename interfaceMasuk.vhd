library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity interfaceMasuk is
    port (
        INSTRUCTION : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
        DATA_IN : OUT STD_LOGIC_VECTOR (63 DOWNTO 0);
        DONE : IN STD_LOGIC;
        WANT_TO_USE : OUT STD_LOGIC;
        CLK : IN STD_LOGIC;
        CPU_NOT_READY : IN STD_LOGIC;
        DATA_OUT : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
        CARD_ID : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
    );
end entity interfaceMasuk;

architecture rtl of interfaceMasuk is
    type state_type is (STAND_BY, GET_TIMESTAMP, CARDID_TIMESTAMP);
    signal current_state : state_type := IDLE;

begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            case current_state is
                when STAND_BY =>
                    if  CARD_ID /= (others => '0') then
                        if CPU_NOT_READY = '0' then
                            current_state <= GET_TIMESTAMP;
                        end if; 
                    else
                        current_state <= STAND_BY;
                    end if;
                when GET_TIMESTAMP =>
                    if DONE = '1' then
                        current_state <= CARDID_TIMESTAMP;
                    else
                        current_state <= GET_TIMESTAMP;
                    end if;
                when CARDID_TIMESTAMP =>
                    if DONE = '1' then
                        current_state <= STAND_BY;
                    else
                        current_state <= CARDID_TIMESTAMP;
                    end if;
                when others =>
                    current_state <= STAND_BY;
            end case;
        end if;
    end process;
end architecture rtl;
    
    
begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            if WANT_TO_USE = '1' then
                CPU_NOT_READY <= '1';
                DATA_OUT <= DATA_IN;
            else
                CPU_NOT_READY <= '0';
            end if;
        end if;
    end process;
end architecture rtl;