LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY random IS
	PORT(	
		i_clk	: IN STD_LOGIC;
		start	: IN STD_LOGIC;
		random	: OUT STD_LOGIC
		);
END random;

ARCHITECTURE behavioral OF random IS
	SIGNAL r_condition	: STD_LOGIC;
	SIGNAL counter		: STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL clock50Hz		: BIT;
	
COMPONENT clockdiv IS
PORT(
	CLK				: IN std_logic;
	div				: integer;
	DIVOUT			: buffer BIT
	);
END COMPONENT;

BEGIN

clkdiv : clockdiv
PORT MAP(
	CLK		=> i_clk,
	div		=> 500000,
	DIVOUT 	=> clock50Hz
		);

	PROCESS (clock50Hz,start)
		CONSTANT max_count	: STD_LOGIC_VECTOR(3 DOWNTO 0) := "1010";
		CONSTANT min_count	: STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
	
	BEGIN
		IF start = '1' THEN
			r_condition <= '0';
			counter <= min_count;
		ELSIF (clock50Hz'EVENT AND clock50Hz = '1') THEN
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