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

        YEAR : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        MONTH : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        DAY : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
        HOUR : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
        MINUTE : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
        SECOND : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
    );
END ENTITY interfaceMasuk;

ARCHITECTURE rtl OF interfaceMasuk IS
    TYPE state_type IS (STAND_BY, GET_TIMESTAMP, CARDID_TIMESTAMP, MOV_TO_REG, MOV_TO_MEM, INCREMENT, SAVE);
    SIGNAL next_state : state_type := STAND_BY;
    SIGNAL unix_timestamp : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL timestamp_seconds : INTEGER RANGE 0 TO 2 ** 32 - 1;
BEGIN
    timestamp_seconds <= to_integer(unsigned(unix_timestamp));

    -- Function to check leap YEAR
    FUNCTION is_leap_year(yr : INTEGER) RETURN BOOLEAN IS
    BEGIN
        RETURN ((yr MOD 4 = 0) AND THEN
        (yr MOD 100 /= 0)) OR (yr MOD 400 = 0);
    END FUNCTION;

    -- Year conversion function
    FUNCTION calculate_year(seconds : INTEGER) RETURN INTEGER IS
        VARIABLE YEAR : INTEGER := 1970;
        VARIABLE year_seconds : INTEGER;
    BEGIN
        WHILE seconds > 0 LOOP
            year_seconds := 365 * 24 * 60 * 60;
            IF is_leap_year(YEAR) THEN
                year_seconds := year_seconds + 24 * 60 * 60; -- Add a DAY for leap YEAR
            END IF;
            IF seconds < year_seconds THEN
                EXIT;
            ELSE
                seconds := seconds - year_seconds;
                YEAR := YEAR + 1;
            END IF;
        END LOOP;
        RETURN YEAR;
    END FUNCTION;

    -- Month conversion function
    FUNCTION calculate_month(seconds : INTEGER; yr : INTEGER) RETURN INTEGER IS
        CONSTANT months : ARRAY (1 TO 12) OF INTEGER := (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
        VARIABLE MONTH : INTEGER := 1;
        VARIABLE month_seconds : INTEGER;
    BEGIN
        IF is_leap_year(yr) THEN
            months(2) := 29; -- February has 29 days in a leap YEAR
        END IF;
        FOR i IN 1 TO 12 LOOP
            month_seconds := months(i) * 24 * 60 * 60;
            IF seconds < month_seconds THEN
                EXIT;
            ELSE
                seconds := seconds - month_seconds;
                MONTH := MONTH + 1;
            END IF;
        END LOOP;
        RETURN MONTH;
    END FUNCTION;

    -- Day conversion function
    FUNCTION calculate_day(seconds : INTEGER; yr : INTEGER; mnth : INTEGER) RETURN INTEGER IS
        CONSTANT months : ARRAY (1 TO 12) OF INTEGER := (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
        VARIABLE DAY : INTEGER := 1;
        VARIABLE day_seconds : INTEGER := 24 * 60 * 60; -- Seconds in a DAY
    BEGIN
        IF is_leap_year(yr) AND mnth = 2 THEN
            day_seconds := day_seconds * 29; -- February in a leap YEAR
        ELSE
            day_seconds := day_seconds * months(mnth);
        END IF;
        WHILE seconds >= day_seconds LOOP
            seconds := seconds - day_seconds;
            DAY := DAY + 1;
        END LOOP;
        RETURN DAY;
    END FUNCTION;

    -- Hour conversion function
    FUNCTION calculate_hour(seconds : INTEGER) RETURN INTEGER IS
    BEGIN
        RETURN (seconds / 3600); -- 3600 seconds in an HOUR
    END FUNCTION;

    -- Minute conversion function
    FUNCTION calculate_minute(seconds : INTEGER) RETURN INTEGER IS
    BEGIN
        RETURN ((seconds MOD 3600) / 60); -- 60 seconds in a MINUTE
    END FUNCTION;

    -- Second conversion function
    FUNCTION calculate_second(seconds : INTEGER) RETURN INTEGER IS
    BEGIN
        RETURN (seconds MOD 60);
    END FUNCTION;

    PROCESS (CLK)
        VARIABLE yr, mnth, dy, hr, min, sec : INTEGER;
    BEGIN
        IF rising_edge(CLK) THEN
            timestamp_seconds <= to_integer(unsigned(unix_timestamp));
            yr := calculate_year(timestamp_seconds);
            mnth := calculate_month(timestamp_seconds, yr);
            dy := calculate_day(timestamp_seconds, yr, mnth);
            hr := calculate_hour(timestamp_seconds);
            min := calculate_minute(timestamp_seconds);
            sec := calculate_second(timestamp_seconds);

            YEAR <= yr;
            MONTH <= mnth;
            DAY <= dy;
            HOUR <= hr;
            MINUTE <= min;
            SECOND <= sec;

            CASE next_state IS
                WHEN STAND_BY =>
                    WANT_TO_USE <= '0';
                    IF CARD_ID /= (OTHERS => '0') THEN
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
                    DATA_IN (31 DOWNTO 0) <= DATA_OUT;
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