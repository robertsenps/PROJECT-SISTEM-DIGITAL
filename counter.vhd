LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY counter IS
	PORT(	
		i_clk			: IN STD_LOGIC;
		start			: IN STD_LOGIC;
		current_count	: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		finish_counter	: OUT STD_LOGIC
		);
END counter;

ARCHITECTURE behavioral OF counter IS
	SIGNAL clock		: BIT;
	SIGNAL count		: STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL f_condition	: STD_LOGIC;
	SIGNAL stopper		: STD_LOGIC;
	
	COMPONENT clockdiv IS
		PORT(	CLK	: IN STD_LOGIC;
				div	: INTEGER;
				DIVOUT	: BUFFER BIT
			);
	END COMPONENT;
	
BEGIN
	
	CLOCKSET : clockdiv
		PORT MAP(	CLK 	=> i_clk,
					div		=> 50000000,
					DIVOUT	=> clock);
	
	PROCESS (clock,start)
		CONSTANT max_count	: STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001";
		CONSTANT min_count	: STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
	
	BEGIN
		IF start = '1' THEN
			f_condition <= '0';
			count <= min_count;
			stopper <= '0';
		ELSIF (clock'EVENT AND clock = '1') THEN
			IF f_condition = '1' THEN
				f_condition <= '0';
			ELSIF stopper = '0' THEN
				IF count < max_count THEN
					count <= count + 1;
				ELSE
					f_condition <= '1';
					stopper <= '1';
				END IF;
			END IF;
		END IF;
	END PROCESS;
	
	current_count <= count;
	finish_counter <= f_condition;
	
END behavioral;
				