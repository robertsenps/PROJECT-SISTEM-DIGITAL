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
	    HEX1		: OUT STD_LOGIC_VECTOR(1 TO 7);
	    HEX2		: OUT STD_LOGIC_VECTOR(1 TO 7);
	    LEDR		: OUT STD_LOGIC_VECTOR(0 TO 9);
	    LEDG		: OUT STD_LOGIC_VECTOR(0 TO 7)
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
SIGNAL hit_i		: STD_LOGIC;
SIGNAL hit_o1		: STD_LOGIC;
SIGNAL hit_o2		: STD_LOGIC;
SIGNAL airborne_i	: STD_LOGIC;
SIGNAL airborne_o1	: STD_LOGIC;
SIGNAL airborne_o2	: STD_LOGIC;
SIGNAL count		: STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL clock25MHz 	: STD_LOGIC;

COMPONENT fsm IS
PORT(
	i_clk			: IN STD_LOGIC;
	start			: IN STD_LOGIC;
	reset			: IN STD_LOGIC;
	jump			: IN STD_LOGIC;
	finish_counter	: IN STD_LOGIC;
	airborne		: IN STD_LOGIC;
	die				: IN STD_LOGIC;
	finish			: OUT STD_LOGIC;
	game_over		: OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT display_vhd IS
PORT(
	i_clk           : IN STD_LOGIC;
	jump 			: IN STD_LOGIC;
	reset 			: IN STD_LOGIC;
	start			: IN STD_LOGIC;
	random 			: IN STD_LOGIC;
	hit_i			: IN STD_LOGIC;
	f_counter		: IN STD_LOGIC;
	finish			: IN STD_LOGIC;
	hit_o			: OUT STD_LOGIC;
	airborne		: OUT STD_LOGIC;
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
	die				: IN STD_LOGIC;
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


BEGIN

clock25Mhz <= CLOCK_50;

PROCESS (KEY,clock25MHz)
BEGIN
	IF (clock25MHz = '1' AND clock25MHz'EVENT AND KEY(2) = '0') THEN
		reset <= '1';
	ELSIF (clock25MHz = '1' AND clock25MHz'EVENT AND KEY(1) = '0') THEN
		start <= '1';
		reset <= '0';
	ELSIF (clock25MHz = '1' AND clock25MHz'EVENT AND KEY(0) = '0') THEN
		start <= '0';
		jump <= '1';
		airborne_o1 <= '1';
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
	
displayvga : display_vhd
PORT MAP(
	i_clk           => CLOCK_50,
    jump 			=> jump,
	reset 			=> reset,
	start			=> start,
	random 			=> randomz,
    hit_i			=> hit_i,
    f_counter		=> f_counter,
    finish			=> s_finish,
    hit_o			=> hit_o2,
    airborne		=> airborne_o2,
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
	airborne		=> airborne_i,
	die				=> hit_i,
	finish			=> s_finish,
	game_over		=> gameover
);

counting : counter
PORT MAP(
	i_clk			=> CLOCK_50,
	start			=> start,
	die				=> hit_i,
	current_count	=> count,
	finish_counter	=> f_counter
		);

sevensegment : bcd
PORT MAP(
	SW		=> count,
	HEX1	=> HEX1,
	HEX2	=> HEX2
		);

PROCESS (s_finish, gameover)
BEGIN
	IF s_finish = '1' THEN
		LEDG <= "11111111";
		LEDR <= "0000000000";
	ELSIF gameover = '1' THEN
		LEDG <= "00000000";
		LEDR <= "1111111111";
	ELSE
		LEDG <= "00000000";
		LEDR <= "0000000000";
	END IF;
END PROCESS;

hit_i <= hit_o2;
airborne_i <= airborne_o1 OR airborne_o2;

END behavioral;