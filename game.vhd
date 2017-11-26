LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY game IS 
	PORT (
		CLOCK_50	: IN STD_LOGIC;
	    KEY			: IN STD_LOGIC_VECTOR( 2 DOWNTO 0 );
	    VGA_R		: OUT STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	    VGA_G		: OUT STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	    VGA_B		: OUT STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	    VGA_HS		: OUT STD_LOGIC;
	    VGA_VS		: OUT STD_LOGIC;
	    VGA_CLK		: OUT STD_LOGIC;
	    VGA_BLANK	: OUT STD_LOGIC;
	    LEDR		: OUT STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	    LEDG		: OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	    HEX1		: OUT STD_LOGIC_VECTOR(1 TO 7);
	    HEX2		: OUT STD_LOGIC_VECTOR(1 TO 7)
	    );
END game;

ARCHITECTURE behavioral of game IS

SIGNAL jump 		: STD_LOGIC;
SIGNAL reset		: STD_LOGIC;
SIGNAL start		: STD_LOGIC;
SIGNAL f_counter	: STD_LOGIC;
SIGNAL s_finish		: STD_LOGIC;
SIGNAL gameover		: STD_LOGIC;
SIGNAL randomz		: STD_LOGIC;
SIGNAL hit			: STD_LOGIC;
SIGNAL airborne		: STD_LOGIC;
SIGNAL count		: STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL clock25MHz 	: BIT;
SIGNAL clock5hz		: BIT;

COMPONENT fsm IS
PORT(
	i_clk			: IN STD_LOGIC;
	start			: IN STD_LOGIC;
	reset			: IN STD_LOGIC;
	jump			: IN STD_LOGIC;
	finish_counter	: IN STD_LOGIC;
	airborne		: BUFFER STD_LOGIC;
	die				: BUFFER STD_LOGIC;
	finish			: OUT STD_LOGIC;
	game_over		: OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT display_vga IS
PORT(
	i_clk           : IN STD_LOGIC;
	jump 			: IN STD_LOGIC;
	reset 			: IN STD_LOGIC;
	start			: IN STD_LOGIC;
	random 			: IN STD_LOGIC;
	hit				: BUFFER STD_LOGIC;
	airborne		: BUFFER STD_LOGIC;
	VGA_R           : OUT STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	VGA_G           : OUT STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	VGA_B           : OUT STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	VGA_HS          : OUT STD_LOGIC;
	VGA_VS          : OUT STD_LOGIC;
	VGA_CLK         : OUT STD_LOGIC;
	VGA_BLANK       : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT random IS
PORT( 
	i_clk			: IN STD_LOGIC;
	start			: IN STD_LOGIC;
	random			: OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT counter IS
PORT(	
	i_clk			: IN STD_LOGIC;
	start			: IN STD_LOGIC;
	current_count	: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
	finish_counter	: OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT bcd IS
PORT(	
	SW		: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	HEX1	: OUT STD_LOGIC_VECTOR(1 TO 7);
	HEX2	: OUT STD_LOGIC_VECTOR(1 TO 7)
	);
END COMPONENT;

COMPONENT clockdiv IS
PORT(
	CLK				: IN std_logic;
	div				: integer;
	DIVOUT			: buffer BIT
	);
END COMPONENT;

BEGIN

clockset : clockdiv
PORT MAP(
	CLK		=> CLOCK_50,
	div		=> 1,
	DIVOUT	=> clock25MHz
		);

clockset1 : clockdiv
PORT MAP(
	CLK		=> CLOCK_50,
	div		=> 5000000,
	DIVOUT	=> clock5Hz
		);
	
PROCESS (KEY,clock25MHz)
BEGIN
	IF (clock25MHz = '1' AND clock25MHz'EVENT AND KEY(2) = '0') THEN
		reset <= '1';
		hit   <= '0';
	ELSIF (clock25MHz = '1' AND clock25MHz'EVENT AND KEY(1) = '0') THEN
		start <= '1';
		reset <= '0';
	ELSIF (clock25MHz = '1' AND clock25MHz'EVENT AND KEY(0) = '0') THEN
		start <= '0';
		jump <= '1';
		airborne <= '1';
	ELSIF (clock25MHz = '1' AND clock25MHz'EVENT AND KEY(2) = '1' AND KEY(1) = '1' AND KEY(0) = '1') THEN
		jump  <= '0';
	END IF;
END PROCESS;

randm : random
PORT MAP(
	i_clk			=> CLOCK_50,
	start			=> start,
	random			=> randomz
		);
	
displayvga : display_vga
PORT MAP(
	i_clk           => CLOCK_50,
    jump 			=> jump,
	reset 			=> reset,
	start			=> start,
	random 			=> randomz,
    hit				=> hit,
    airborne		=> airborne,
    VGA_R           => VGA_R,
    VGA_G           => VGA_G,
    VGA_B           => VGA_B,
    VGA_HS          => VGA_HS,
    VGA_VS          => VGA_VS,
    VGA_CLK         => VGA_CLK,
    VGA_BLANK       => VGA_BLANK
);

mainstage : fsm
PORT MAP(
	i_clk			=> CLOCK_50,
	start			=> start,
	reset			=> reset,
	jump			=> jump,
	finish_counter	=> f_counter,
	airborne		=> airborne,
	die				=> hit,
	finish			=> s_finish,
	game_over		=> gameover
);

counting : counter
PORT MAP(
	i_clk			=> CLOCK_50,
	start			=> start,
	current_count	=> count,
	finish_counter	=> f_counter
		);

sevensegment : bcd
PORT MAP(
	SW		=> count,
	HEX1	=> HEX1,
	HEX2	=> HEX2
		);

PROCESS (f_counter,gameover,clock25Mhz,reset)
BEGIN
	IF(f_counter = '1') THEN
				LEDG(0) <= '1';
				LEDG(1) <= '1';
				LEDG(2) <= '1';
				LEDG(3) <= '1';
				LEDG(4) <= '1';
				LEDG(5) <= '1';
				LEDG(6) <= '1';
				LEDG(7) <= '1';
	ELSIF(gameover = '1') THEN
				LEDR(0) <= '1';
				LEDR(1) <= '1';
				LEDR(2) <= '1';
				LEDR(3) <= '1';
				LEDR(4) <= '1';
				LEDR(5) <= '1';
				LEDR(6) <= '1';
				LEDR(7) <= '1';
				LEDR(8) <= '1';
				LEDR(9) <= '1';
	END IF;
	
	IF (reset = '1') THEN
				LEDR(0) <= '0';
				LEDR(1) <= '0';
				LEDR(2) <= '0';
				LEDR(3) <= '0';
				LEDR(4) <= '0';
				LEDR(5) <= '0';
				LEDR(6) <= '0';
				LEDR(7) <= '0';
				LEDR(8) <= '0';
				LEDR(9) <= '0';
				LEDG(0) <= '0';
				LEDG(1) <= '0';
				LEDG(2) <= '0';
				LEDG(3) <= '0';
				LEDG(4) <= '0';
				LEDG(5) <= '0';
				LEDG(6) <= '0';
				LEDG(7) <= '0';
	END IF;
END PROCESS;
END behavioral;