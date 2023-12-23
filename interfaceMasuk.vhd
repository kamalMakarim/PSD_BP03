library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity interfaceMasuk is
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
end entity interfaceMasuk;

architecture rtl of interfaceMasuk is
    type state_type is (STAND_BY, GET_TIMESTAMP, CARDID_TIMESTAMP, MOV_TO_REG, MOV_TO_MEM, SAVE);
    signal next_state : state_type := IDLE;
    
begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            case next_state is
                when STAND_BY =>
                    WANT_TO_USE <= '0';
                    if  CARD_ID /= (others => '0') then
                        WANT_TO_USE <= '1';
                        if CPU_NOT_READY = '0' then
                            next_state <= GET_TIMESTAMP;
                        end if; 
                    else
                        next_state <= STAND_BY;
                    end if;
                when GET_TIMESTAMP =>
                    INSTRUCTION <= "01100000000";
                    if DONE = '1' then
                        next_state <= CARDID_TIMESTAMP;
                    else
                        next_state <= GET_TIMESTAMP;
                    end if;
                when CARDID_TIMESTAMP =>
                    if DONE = '1' then
                        next_state <= STAND_BY;
                    else
                        next_state <= CARDID_TIMESTAMP;
                    end if;
                when MOV_TO_REG =>
                    if DONE = '1' then
                        next_state <= STAND_BY;
                    else
                        next_state <= MOV_TO_REG;
                    end if;
                when MOV_TO_MEM =>
                    if DONE = '1' then
                        next_state <= STAND_BY;
                    else
                        next_state <= MOV_TO_MEM;
                    end if;
                when SAVE =>
                    if DONE = '1' then
                        next_state <= STAND_BY;
                    else
                        next_state <= SAVE;
                    end if;
                when others =>
                    next_state <= STAND_BY;
            end case;
        end if;
    end process;
end architecture rtl;