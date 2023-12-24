library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity interfaceKeluar is
    port (
        INSTRUCTION : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
        DATA_IN : OUT STD_LOGIC_VECTOR (63 DOWNTO 0);
        DONE : IN STD_LOGIC;
        WANT_TO_USE : OUT STD_LOGIC;
        CLK : IN STD_LOGIC;
        CPU_NOT_READY : IN STD_LOGIC;
        DATA_OUT : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
        CARD_ID : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        BALANCE : INOUT STD_LOGIC_VECTOR (63 DOWNTO 0)
    );
end entity interfaceKeluar;

architecture rtl of interfaceKeluar is
    type state_type is (
        stand_by, 
        set_0_r2, 
        card_id_to_data_in, 
        mov_R3_data_in_1, 
        mov_R4_MR2,
        mov_data_out_R4_1,
        remove_timestamp, 
        mov_R4_data_in_1, 
        sub_R4_R3_1, 
        mov_data_out_R4_2, 
        check_data_out, 
        mov_R3_MR2, 
        mov_data_out_R3, 
        remove_cardid, 
        mov_R3_data_in_2, 
        get_timestamp, 
        mov_R4_data_in_2, 
        sub_R4_R3_2, 
        div_R4_data_in, 
        mul_R4_data_in, 
        mov_balance_to_reg, 
        sub_R5_R4, 
        mov_data_out_R5, 
        check_balance,
        save);
    signal next_state : state_type := stand_by;
    
begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            case next_state is
                when stand_by =>
                    WANT_TO_USE <= '1';
                    if CPU_NOT_READY = '0' then
                        next_state <= set_0_r2;
                    else
                        next_state <= stand_by;
                    end if;
                when set_0_r2 => -- Mencari Card ID yang sesuai (1)
                    DATA_IN <= (OTHERS => '0');
                    INSTRUCTION <= "01110010000";
                    if DONE = '1' then
                        next_state <= card_id_to_data_in;
                    else
                        next_state <= set_0_r2;
                    end if;
                when card_id_to_data_in => -- Mencari Card ID yang sesuai (2)
                    DATA_IN(31 DOWNTO 0) <= CARD_ID;
                    if DONE = '1' then
                        next_state <= mov_R3_data_in_1;
                    else
                        next_state <= card_id_to_data_in;
                    end if;
                when mov_R3_data_in_1 => -- Mencari Card ID yang sesuai (3)
                    INSTRUCTION <= "01110011000";
                    if DONE = '1' then
                        next_state <= mov_R4_MR2;
                    else
                        next_state <= mov_R3_data_in_1;
                    end if;
                when mov_R4_MR2 => -- Mencari Card ID yang sesuai (4)
                    INSTRUCTION <= "01101100010";
                    if DONE = '1' then
                        next_state <= mov_data_out_R4_1;
                    else
                        next_state <= mov_R4_MR2;
                    end if;
                when mov_data_out_R4_1 => -- Mencari Card ID yang sesuai (5)
                    INSTRUCTION <= "01100000100";
                    if DONE = '1' then
                        next_state <= remove_timestamp;
                    else
                        next_state <= mov_data_out_R4_1;
                    end if;
                when remove_timestamp => -- Mencari Card ID yang sesuai (6)
                    DATA_IN(31 DOWNTO 0) <= DATA_OUT(63 DOWNTO 32);
                    DATA_IN(63 DOWNTO 32) <= (OTHERS => '0');
                    if DONE = '1' then
                        next_state <= mov_R4_data_in_1;
                    else
                        next_state <= remove_timestamp;
                    end if;
                when mov_R4_data_in_1 => -- Mencari Card ID yang sesuai (7)
                    INSTRUCTION <= "01110100000";
                    if DONE = '1' then
                        next_state <= sub_R4_R3_1;
                    else
                        next_state <= mov_R4_data_in_1;
                    end if;
                when sub_R4_R3_1 => -- Mencari Card ID yang sesuai (8)
                    INSTRUCTION <= "00111100011";
                    if DONE = '1' then
                        next_state <= mov_data_out_R4_2;
                    else
                        next_state <= sub_R4_R3_1;
                    end if;
                when mov_data_out_R4_2 => -- Mencari Card ID yang sesuai (9)
                    INSTRUCTION <= "01100000100";
                    if DONE = '1' then
                        next_state <= check_data_out;
                    else
                        next_state <= mov_data_out_R4_2;
                    end if;
                when check_data_out => -- Mencari Card ID yang sesuai (10)
                    if DATA_OUT = "0000000000000000000000000000000000000000000000000000000000000000" then
                        next_state <= mov_R3_MR2;
                    else
                        INSTRUCTION <= "11001000000";
                        next_state <= mov_R4_MR2;
                    end if;
                when mov_R3_MR2 => -- Mencari Card ID yang sesuai (11)
                    INSTRUCTION <= "01101011010";
                     if DONE = '1' then
                        next_state <= mov_data_out_R3;
                    else
                        next_state <= mov_R3_MR2;
                    end if;
                when mov_data_out_R3 => -- Mencari Card ID yang sesuai (12)
                    INSTRUCTION <= "01100000011";
                    if DONE = '1' then
                        next_state <= remove_cardid;
                    else
                        next_state <= mov_data_out_R3;
                    end if;
                when remove_cardid => -- Menghapus Card ID, menyisakan timestamp
                    DATA_IN(63 downto 32) <= (OTHERS => '0');
                    DATA_IN(31 downto 0) <= DATA_OUT(31 downto 0);
                    if DONE = '1' then
                        next_state <= mov_R3_data_in_2;
                    else
                        next_state <= remove_cardid;
                    end if;
                when mov_R3_data_in_2 => -- Letakkan timestamp saat kendaraan masuk ke R3
                    INSTRUCTION <= "01110011000";
                    if DONE = '1' then
                        next_state <= get_timestamp;
                    else
                        next_state <= mov_R3_data_in_2;
                    end if;
                when get_timestamp => -- Get timestamp saat kendaraan keluar
                    INSTRUCTION <= "01100000000";
                    if DONE = '1' then
                        next_state <= mov_R4_data_in_2;
                    else
                        next_state <= get_timestamp;
                    end if;
                when mov_R4_data_in_2 => -- Letakkan timestamp saat kendaraan keluar ke R4
                    DATA_IN <= DATA_OUT;
                    INSTRUCTION <= "01110100000";
                    if DONE = '1' then
                        next_state <= sub_R4_R3_2;
                    else
                        next_state <= mov_R4_data_in_2;
                    end if;
                when sub_R4_R3_2 => -- Substract untuk menghitung lama parkir
                    INSTRUCTION <= "00111100011";
                    if DONE = '1' then
                        next_state <= div_R4_data_in;
                    else
                        next_state <= sub_R4_R3_2;
                    end if;
                when div_R4_data_in => -- Divide untuk mengonversi detik menjadi jam
                    DATA_IN <= "0000000000000000000000000000000000000000000000000000111000010000";
                    INSTRUCTION <= "10110100000";
                    if DONE = '1' then
                        next_state <= mul_R4_data_in;
                    else
                        next_state <= div_R4_data_in;
                    end if;
                when mul_R4_data_in => -- Multiply untuk menghitung total harga parkir
                    DATA_IN <= "0000000000000000000000000000000000000000000000000000101110111000";
                    INSTRUCTION <= "01010100000";
                    if DONE = '1' then
                        next_state <= mov_balance_to_reg;
                    else
                        next_state <= mul_R4_data_in;
                    end if;
                when mov_balance_to_reg => -- Letakkan balance user ke R5
                    DATA_IN <= BALANCE;
                    INSTRUCTION <= "01110101000";
                    if DONE = '1' then
                        next_state <= sub_R5_R4;
                    else
                        next_state <= mov_balance_to_reg;
                    end if;
                when sub_R5_R4 => -- Substract untuk mengurangi balance user
                    INSTRUCTION <= "00111101100";
                    if DONE = '1' then
                        next_state <= mov_data_out_R5;
                    else
                        next_state <= sub_R5_R4;
                    end if;
                when mov_data_out_R5 =>
                    INSTRUCTION <= "01100000101";
                    if DONE = '1' then
                        next_state <= check_balance;
                    else
                        next_state <= mov_data_out_R5;
                    end if;
                when check_balance => 
                    if DATA_OUT = "0000000000000000000000000000000000000000000000000000000000000000" then
                        BALANCE <= DATA_OUT; -- Mengupdate balance user
                        next_state <= save;
                    else
                        REPORT "Balance anda tidak cukup" SEVERITY FAILURE; -- Jika balance tidak cukup, berikan REPORT kepada user
                        next_state <= check_balance;
                    end if;
                when save =>
                    INSTRUCTION <= "10000000000";
                    if DONE = '1' then
                        next_state <= stand_by;
                    else
                        next_state <= save;
                    end if;
                when others =>
                    next_state <= stand_by;
            end case;
        end if;
    end process;
end architecture rtl;