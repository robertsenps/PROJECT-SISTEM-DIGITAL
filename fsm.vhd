LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY fsm IS
	PORT(	i_clk			: IN STD_LOGIC;
			start			: IN STD_LOGIC;
			reset			: IN STD_LOGIC;
			airborne		: IN STD_LOGIC;
			jump			: IN STD_LOGIC;
			die				: IN STD_LOGIC;
			finish_counter	: IN STD_LOGIC;
			finish			: OUT STD_LOGIC;
			game_over		: OUT STD_LOGIC	
		);
END fsm;

ARCHITECTURE behavioral OF fsm IS
	TYPE state_type IS (Init, A, B, C, D);
	SIGNAL s 		: state_type;
	SIGNAL clock	: BIT;

	COMPONENT clockdiv IS
		PORT(	CLK		: IN STD_LOGIC;
				div		: INTEGER;
				DIVOUT	: BUFFER BIT
			);
	END COMPONENT;

BEGIN
	
	CLOCKSET : clockdiv
	PORT MAP(	CLK => i_clk,
				div => 500000,
				DIVOUT	=> clock);

	PROCESS (reset, clock)
	BEGIN
		IF reset = '1' THEN
			s <= Init;
		ELSIF (clock'EVENT AND clock = '1') THEN
			IF finish_counter = '1' THEN
				s <= D;
			ELSIF die = '1' THEN
				s <= B;
			ELSE
				CASE s IS
					WHEN Init =>
						IF start = '1' THEN
							s <= A;
						ELSE
							s <= Init;
						END IF;
					WHEN A =>
						IF jump = '1' THEN
							s <= C;
						ELSE 
							s <= A;
						END IF;
					WHEN B =>
						s <= B;
					WHEN C =>
						IF airborne = '1' THEN
							s <= C;
						ELSE
							s <= A;
						END IF;
					WHEN D =>
						s <= D;
				END CASE;
			END IF;
		END IF;
	END PROCESS;
	
	finish <= '1' WHEN s = D ELSE '0';
	game_over <= '1' WHEN s = B ELSE '0';
	
END behavioral;