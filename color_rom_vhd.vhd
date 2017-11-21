LIBRARY  IEEE; 
USE  IEEE.STD_LOGIC_1164.ALL; 
USE  IEEE.STD_LOGIC_ARITH.ALL; 
USE  IEEE.STD_LOGIC_UNSIGNED.ALL;
 
ENTITY color_rom_vhd  IS 
	PORT( 
		CLOCK_50   	    : IN STD_LOGIC;
		jump 			: IN STD_LOGIC;
		reset 			: IN STD_LOGIC;
		start			: IN STD_LOGIC;
		random 			: IN STD_LOGIC;
	    i_pixel_column  : IN STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	    i_pixel_row     : IN STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	    o_red           : OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	    o_green         : OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	    o_blue          : OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	    hit				: OUT STD_LOGIC);
	    
END color_rom_vhd; 

ARCHITECTURE behavioral OF color_rom_vhd  IS 

SIGNAL M_SIG, B_SIG :  STD_LOGIC; -- SINYAL MERAH DAN BIRU UNTUK MEWARNAI KOTAK
VARIABLE clock_50hz : std_logic;  -- SINYAL 50 HZ UNTUK RENDER GRAFIK

COMPONENT clockdiv IS     -- MENGUBAH SINYAL CLOCK JADI 50 HZ
	PORT(
		CLK : IN STD_LOGIC;
		div : INTEGER;
		DIVOUT : BUFFER BIT);
END COMPONENT;

BEGIN 

CLK_50HZ : clockdiv
PORT MAP (
	CLK		=> CLOCK_50,
	div     => 500000,
	DIVOUT	=> clock_50hz);

PROCESS(i_pixel_row,i_pixel_column, M_SIG, B_SIG ,clock_50hz, jump, reset)

-- KONDISI AWAL :
	-- USER :
	CONSTANT USER_KANAN 	: INTEGER := 200;
	CONSTANT USER_KIRI  	: INTEGER := 100;
	CONSTANT USER_ATAS  	: INTEGER := 380;
	CONSTANT USER_BAWAH 	: INTEGER := 480;

	-- OBS :
	CONSTANT OBS_ATAS 		: INTEGER := 330;
	CONSTANT OBS_BAWAH		: INTEGER := 480;
	CONSTANT OBS_KIRI		: INTEGER := 700;
	CONSTANT OBS_KANAN		: INTEGER := 775;

-- BATAS KOTAK USER :
	CONSTANT  BATAS_LONCAT  : INTEGER := 100;
	CONSTANT  BATAS_BAWAH   : INTEGER := 0;

-- BATAS KOTAK OBSTACLE KETIKA BELUM ADA RINTANGAN :
	CONSTANT  O_KI  		: INTEGER := 0;
	
-- DIMENSI KOTAK OBSTACLE :
	VARIABLE O_KIRI			: INTEGER := 700;
	VARIABLE O_KANAN		: INTEGER := 775;
	
-- DIMENSI KOTAK USER :
	VARIABLE U_ATAS  		: INTEGER := 380;
	VARIABLE U_BAWAH 		: INTEGER := 480;

-- VARIABEL & KONSTANTA LAIN :
	VARIABLE sentuh			: STD_LOGIC := '0';
	VARIABLE gerak			: STD_LOGIC := '0';
BEGIN

	IF ( clock_50hz = '1' ) THEN
		IF (reset = '1') THEN 
			U_ATAS 	:= USER_ATAS;
			U_BAWAH := USER_BAWAH;
			O_KIRI 	:= OBS_KIRI;
			O_KANAN := OBS_KANAN;
		ELSIF ((airborne = '1') or (jump = '1' )) AND (U_ATAS >= BATAS_LONCAT) THEN
			airborne := '1';
			U_ATAS 	:= U_ATAS - 25;
			U_BAWAH := U_BAWAH - 25 ;
			IF ( U_ATAS = BATAS_LONCAT) THEN
				SENTUH := '1';
			END IF;
		ELSIF ((sentuh = '1') AND (U_BAWAH  <= BATAS_BAWAH)) THEN
			U_ATAS 	:= U_ATAS + 25;
			U_BAWAH := U_BAWAH + 25 ;
			IF ( U_BAWAH = BATAS_BAWAH) THEN
				SENTUH := '0';
				airborne := '0';
			END IF;
		ELSIF ((airborne = '0') AND (reset = '0')) THEN
			U_ATAS 	:= U_ATAS;
			U_BAWAH := U_BAWAH;
		END IF;
			
		IF (((random = '1') OR (gerak = '1')) AND (O_KIRI >= O_KI)) THEN
			gerak 	:= '1';
			O_KIRI 	:= O_KIRI - 5;
			O_KANAN := O_KANAN - 5;
			IF (O_KIRI = O_KI) THEN
				O_KIRI 	:= OBS_KIRI;
				O_KANAN := OBS_KANAN;
				gerak 	:= '0';
			END IF;
		END IF;

		IF ((USER_KANAN = O_KIRI AND U_BAWAH >= OBS_ATAS) OR U_BAWAH = OBS_ATAS) THEN
			hit := '1';
		END IF;
	END IF;
	
  IF ((i_pixel_row >= U_ATAS)  AND (i_pixel_row <= U_BAWAH )  ) AND ((i_pixel_column >= USER_KIRI )  AND (i_pixel_column <= USER_KANAN)  ) THEN B_SIG <=  '1';
  ELSE B_SIG <=  '0';
  END IF;

  IF ((i_pixel_row >= OBS_ATAS)  AND (i_pixel_row <= OBS_BAWAH )  ) AND ((i_pixel_column >= O_KIRI )  AND (i_pixel_column <= O_KANAN)  ) THEN M_SIG <=  '1';
  ELSE M_SIG <=  '0';
  END IF;

  IF (B_SIG = '1') THEN  o_red <= X"00"; o_green <= X"00"; o_blue <= X"FF"; 
  ELSIF (M_SIG = '1') THEN  o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00";
  ELSE o_red <= X"FF"; o_green <= X"FF"; o_blue <= X"FF";
  END IF;
 
END PROCESS;

END behavioral;