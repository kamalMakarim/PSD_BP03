LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY interfaceMasuk IS
    PORT (
        INSTRUCTION : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
        DATA_IN : OUT STD_LOGIC_VECTOR (63 DOWNTO 0);
        DONE : IN STD_LOGIC;
        WANT_TO_USE : OUT STD_LOGIC;
        CLK : IN STD_LOGIC;
        CPU_NOT_READY : IN STD_LOGIC;
        DATA_OUT : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
        CARD_ID : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

        YEAR : OUT INTEGER;
        MONTH : OUT integer;
        DAY : OUT integer;
        HOUR : OUT integer;
        MINUTE : OUT integer;
        SECOND : OUT integer
    );
END ENTITY interfaceMasuk;

ARCHITECTURE rtl OF interfaceMasuk IS
    TYPE state_type IS (STAND_BY, GET_TIMESTAMP, CARDID_TIMESTAMP, MOV_TO_REG, MOV_TO_MEM, INCREMENT, SAVE);
    SIGNAL next_state : state_type := STAND_BY;
    SIGNAL unix_timestamp : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL timestamp_seconds : INTEGER;
    
    -- Function to check leap year
    FUNCTION is_leap_year(yr : INTEGER) RETURN BOOLEAN IS
    BEGIN
        if yr mod 4 = 0 then
            RETURN TRUE;
        else 
            return FALSE;
        end if;
    END FUNCTION;

    -- Year conversion function
    FUNCTION calculate_year(seconds : INTEGER) RETURN INTEGER IS
        VARIABLE year : INTEGER := 1970;
        VARIABLE year_seconds : INTEGER;
        VARIABLE Seconds_var : INTEGER := seconds;
    BEGIN
        WHILE Seconds_var > 0 LOOP
            year_seconds := 365 * 24 * 60 * 60;
            IF is_leap_year(year) THEN
                year_seconds := year_seconds + 24 * 60 * 60; -- Add a day for leap year
            END IF;
            IF Seconds_var < year_seconds THEN
                EXIT;
            ELSE
                Seconds_var := seconds - year_seconds;
                year := year + 1;
            END IF;
        END LOOP;
        RETURN year;
    END FUNCTION;

    -- Month conversion function
    FUNCTION calculate_month(seconds : INTEGER; yr : INTEGER) RETURN INTEGER IS
        type month_array is array (1 to 12) of integer;
        VARIABLE months : month_array := (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
        VARIABLE month : INTEGER := 1;
        VARIABLE month_seconds : INTEGER;
        variable Seconds_var : INTEGER := seconds;
    BEGIN
        IF is_leap_year(yr) THEN
            months(2) := 29; -- February has 29 days in a leap year
        END IF;
        FOR i IN 1 TO 12 LOOP
            month_seconds := months(i) * 24 * 60 * 60;
            IF Seconds_var < month_seconds THEN
                EXIT;
            ELSE
                Seconds_var := Seconds_var - month_seconds;
                month := month + 1;
            END IF;
        END LOOP;
        RETURN month;
    END FUNCTION;

    -- Day conversion function
    FUNCTION calculate_day(seconds : INTEGER; yr : INTEGER; mnth : INTEGER) RETURN INTEGER IS
        type month_array is array (1 to 12) of integer;
        VARIABLE months : month_array := (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
        VARIABLE day : INTEGER := 1;
        VARIABLE day_seconds : INTEGER;
        variable seconds_var : INTEGER := seconds;
    BEGIN
        IF is_leap_year(yr) AND mnth = 2 THEN
            day_seconds := 29 * 24 * 60 * 60; -- February in a leap year
        ELSE
            day_seconds := months(mnth) * 24 * 60 * 60;
        END IF;
        WHILE seconds_var >= day_seconds LOOP
            seconds_var := seconds_var - day_seconds;
            day := day + 1;
        END LOOP;
        RETURN day;
    END FUNCTION;

    -- Hour conversion function
    FUNCTION calculate_hour(seconds : INTEGER) RETURN INTEGER IS
    BEGIN
        RETURN (seconds / 3600); -- 3600 seconds in an hour
    END FUNCTION;

    -- Minute conversion function
    FUNCTION calculate_minute(seconds : INTEGER) RETURN INTEGER IS
    BEGIN
        RETURN ((seconds MOD 3600) / 60); -- 60 seconds in a minute
    END FUNCTION;

    -- Second conversion function
    FUNCTION calculate_second(seconds : INTEGER) RETURN INTEGER IS
    BEGIN
        RETURN (seconds MOD 60);
    END FUNCTION;

BEGIN
    PROCESS (CLK)
        VARIABLE yr, mnth, dy, hr, min, sec : INTEGER;
    BEGIN
        IF rising_edge(CLK) THEN

            CASE next_state IS
                WHEN STAND_BY =>
                    WANT_TO_USE <= '0';
                    IF CARD_ID /= "00000000000000000000000000000000" THEN
                        WANT_TO_USE <= '1';
                        IF CPU_NOT_READY = '0' THEN
                            next_state <= GET_TIMESTAMP;
                        END IF;
                    ELSE
                        next_state <= STAND_BY;
                    END IF;
                WHEN GET_TIMESTAMP =>
                    INSTRUCTION <= "01100000000";
                WHEN CARDID_TIMESTAMP =>
                    DATA_IN (63 DOWNTO 32) <= CARD_ID;
                    DATA_IN (31 DOWNTO 0) <= DATA_OUT(31 DOWNTO 0);
                    unix_timestamp <= DATA_OUT(31 DOWNTO 0);
                    timestamp_seconds <= to_integer(unsigned(unix_timestamp));
                    YEAR := calculate_year(timestamp_seconds);
                    MONTH := calculate_month(timestamp_seconds, YEAR);
                    DAY := calculate_day(timestamp_seconds, YEAR, MONTH);
                    HOUR := calculate_hour(timestamp_seconds);
                    MINUTE := calculate_minute(timestamp_seconds);
                    SECOND := calculate_second(timestamp_seconds);
                WHEN MOV_TO_REG =>
                    INSTRUCTION <= "01110010000";
                WHEN MOV_TO_MEM =>
                    INSTRUCTION <= "01111001010";
                WHEN INCREMENT =>
                    INSTRUCTION <= "11000100000";
                WHEN SAVE =>
                    INSTRUCTION <= "10000000000";
                WHEN OTHERS =>
                    next_state <= STAND_BY;
            END CASE;
        END IF;
    END PROCESS;
END ARCHITECTURE rtl;
