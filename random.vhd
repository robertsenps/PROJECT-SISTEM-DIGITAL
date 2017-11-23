LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY random IS
	PORT(	i_clk	: IN BIT;
			start	: IN STD_LOGIC;
			random	: OUT STD_LOGIC
		);
END random;

ARCHITECTURE behavioral OF random IS
	SIGNAL r_condition	: STD_LOGIC;
	SIGNAL counter		: STD_LOGIC_VECTOR(6 DOWNTO 0);
	
BEGIN

	PROCESS (i_clk,start)
		CONSTANT max_count	: STD_LOGIC_VECTOR(6 DOWNTO 0) := "1100100";
		CONSTANT min_count	: STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000000";
	
	BEGIN
		IF start = '1' THEN
			r_condition <= '0';
			counter <= min_count;
		ELSIF (i_clk'EVENT AND i_clk = '1') THEN
			IF r_condition = '1' THEN
				r_condition <= '0';
				counter <= counter + 1;
			ELSIF r_condition = '0' THEN
				IF counter < max_count THEN
					counter <= counter + 1;
				ELSE
					r_condition <= '1';
					counter <= min_count;
				END IF;
			END IF;
		END IF;
	END PROCESS;
	
	random <= r_condition;
	
END behavioral;