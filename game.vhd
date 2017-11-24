LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY game IS 
	PORT (
		CLOCK_50   : IN STD_LOGIC;
	    KEY		   : IN STD_LOGIC_VECTOR( 2 DOWNTO 0 );
	    VGA_R      : OUT STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	    VGA_G      : OUT STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	    VGA_B      : OUT STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	    VGA_HS     : OUT STD_LOGIC;
	    VGA_VS     : OUT STD_LOGIC;
	    VGA_CLK    : OUT STD_LOGIC;
	    VGA_BLANK  : OUT STD_LOGIC;
	    LEDR       : OUT STD_LOGIC_VECTOR( 49 DOWNTO 0 )
	    );
END game;

ARCHITECTURE behavioral of game IS

SIGNAL jump 		: STD_LOGIC;
SIGNAL reset		: STD_LOGIC;
SIGNAL start		: STD_LOGIC;
SIGNAL clock50hz	: BIT;
SIGNAL f_counter	: STD_LOGIC;
SIGNAL s_finish		: STD_LOGIC;
SIGNAL gameover		: STD_LOGIC;
SIGNAL randomz		: STD_LOGIC;
SIGNAL hit			: STD_LOGIC;
SIGNAL airborne		: STD_LOGIC;

COMPONENT clockdiv IS
PORT(
	CLK		: IN std_logic;
	div		: integer;
	DIVOUT	: buffer BIT);
END COMPONENT;

COMPONENT fsm IS
PORT(
	i_clk			: IN BIT;
	start			: IN STD_LOGIC;
	reset			: IN STD_LOGIC;
	airborne		: BUFFER STD_LOGIC;
	jump			: IN STD_LOGIC;
	die				: BUFFER STD_LOGIC;
	finish_counter	: IN STD_LOGIC;
	finish			: OUT STD_LOGIC;
	game_over		: OUT STD_LOGIC);
END COMPONENT;

COMPONENT display_vga IS
PORT(
	    i_clk           : IN BIT;
	    jump 			: IN STD_LOGIC;
		reset 			: IN STD_LOGIC;
		start			: IN STD_LOGIC;
		random 			: IN STD_LOGIC;
	    VGA_R           : OUT STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	    VGA_G           : OUT STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	    VGA_B           : OUT STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	    VGA_HS          : OUT STD_LOGIC;
	    VGA_VS          : OUT STD_LOGIC;
	    VGA_CLK         : OUT STD_LOGIC;
	    VGA_BLANK       : OUT STD_LOGIC;
	    hit				: BUFFER STD_LOGIC;
	    airborne		: BUFFER STD_LOGIC);
	    
END COMPONENT;

COMPONENT random IS
PORT( 
	i_clk	: IN BIT;
	start	: IN STD_LOGIC;
	random	: OUT STD_LOGIC
);
END COMPONENT;

BEGIN

clk50Hz : clockdiv
PORT MAP(
	CLK		=> CLOCK_50,
	div 	=> 500000,
	DIVOUT	=> clock50hz
);
PROCESS (clock50hz,KEY)
BEGIN
	IF (clock50hz = '1' AND KEY(2) = '0') THEN
		reset <= '1';
		hit   <= '0';
	ELSIF (clock50hz = '1' AND KEY(1) = '0') THEN
		start <= '1';
	ELSIF (clock50hz = '1' AND KEY(0) = '0') THEN
		jump <= '1';
		airborne <= '1';
	ELSIF (clock50hz = '1' AND KEY(2) = '1' AND KEY(1) = '1' AND KEY(0) = '1') THEN
		reset <= '0';
		start <= '0';
		jump  <= '0';
	END IF;
END PROCESS;

randm : random
PORT MAP(
	i_clk			=> clock50hz,
	start			=> start,
	random			=> randomz);
	
displayvga : display_vga
PORT MAP(
	i_clk           => clock50hz,
    jump 			=> jump,
	reset 			=> reset,
	start			=> start,
	random 			=> randomz,
    VGA_R           => VGA_R,
    VGA_G           => VGA_G,
    VGA_B           => VGA_B,
    VGA_HS          => VGA_HS,
    VGA_VS          => VGA_VS,
    VGA_CLK         => VGA_CLK,
    VGA_BLANK       => VGA_BLANK,
    hit				=> hit,
    airborne		=> airborne
);

mainstage : fsm
PORT MAP(
	i_clk			=> clock50hz,
	start			=> start,
	reset			=> reset,
	airborne		=> airborne,
	jump			=> jump,
	die				=> hit,
	finish_counter	=> f_counter,
	finish			=> s_finish,
	game_over		=> gameover
);

END behavioral;