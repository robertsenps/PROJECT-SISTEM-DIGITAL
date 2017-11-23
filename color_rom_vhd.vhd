LIBRARY  IEEE; 
USE  IEEE.STD_LOGIC_1164.ALL; 
USE  IEEE.STD_LOGIC_ARITH.ALL; 
USE  IEEE.STD_LOGIC_UNSIGNED.ALL;
 
ENTITY color_rom_vhd  IS 
	PORT( 
		CLOCK   	    : IN BIT;
		jump 			: IN STD_LOGIC;
		reset 			: IN STD_LOGIC;
		start			: IN STD_LOGIC;
		random 			: IN STD_LOGIC;
	    i_pixel_column  : IN STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	    i_pixel_row     : IN STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	    o_red           : OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	    o_green         : OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	    o_blue          : OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	    hit				: OUT STD_LOGIC;
	    airborne		: OUT STD_LOGIC);
	    
END color_rom_vhd; 

ARCHITECTURE behavioral OF color_rom_vhd  IS 

SIGNAL M_SIG, B_SIG :  STD_LOGIC; -- SINYAL MERAH DAN BIRU UNTUK MEWARNAI KOTAK
SIGNAL loncat		: STD_LOGIC;  -- menyimpan temp saat loncat
SIGNAL sentuh		: STD_LOGIC;
SIGNAL gerak		: STD_LOGIC;

BEGIN 

PROCESS(i_pixel_row,i_pixel_column, M_SIG, B_SIG, jump, reset,CLOCK)

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

BEGIN
		IF (CLOCK'EVENT AND CLOCK = '1' ) THEN
		IF (reset = '1') THEN       -- INISIALISASI USER DAN OBSTACLES
			U_ATAS 	:= USER_ATAS;
			U_BAWAH := USER_BAWAH;
			O_KIRI 	:= OBS_KIRI;
			O_KANAN := OBS_KANAN;
		ELSIF ((jump = '1' ) OR (loncat = '1')) AND (U_ATAS >= BATAS_LONCAT) THEN   -- SAAT LONCAT
			loncat	<= '1';
			U_ATAS 	:= U_ATAS - 25;
			U_BAWAH := U_BAWAH - 25 ;
			IF ( U_ATAS = BATAS_LONCAT) THEN
				SENTUH <= '1';
				loncat <= '0';
			END IF;
		ELSIF ((sentuh = '1') AND (U_BAWAH  <= BATAS_BAWAH)) THEN      -- SAAT JATUH
			U_ATAS 	:= U_ATAS + 25;
			U_BAWAH := U_BAWAH + 25 ;
			IF ( U_BAWAH = BATAS_BAWAH) THEN
				SENTUH <= '0';
				airborne <= '0';
			END IF;
		ELSIF ((loncat = '0') AND (reset = '0')) THEN     -- SAAT KONDISI IDLE
			U_ATAS 	:= U_ATAS;
			U_BAWAH := U_BAWAH;
		END IF;
			
		IF (((random = '1') OR (gerak = '1')) AND (O_KIRI >= O_KI)) THEN   -- SAAT GERAK MENDEKATI USER
			gerak 	<= '1';
			O_KIRI 	:= O_KIRI - 5;
			O_KANAN := O_KANAN - 5;
			IF (O_KIRI = O_KI) THEN    --SAAT BOX KIRI UDAH SAMPAI UJUNG KIRI LANGSUNG NGILANG
				O_KIRI 	:= OBS_KIRI;
				O_KANAN := OBS_KANAN;
				gerak 	<= '0';
			END IF;
		END IF;

		IF ((USER_KANAN = O_KIRI AND U_BAWAH >= OBS_ATAS) OR U_BAWAH = OBS_ATAS) THEN   --NGASIH TAU KENA ATAU ENGGA
			hit <= '1';
		END IF;
	END IF;

  IF ((i_pixel_row >= U_ATAS)  AND (i_pixel_row <= U_BAWAH )  ) AND ((i_pixel_column >= USER_KIRI )  AND (i_pixel_column <= USER_KANAN)  ) THEN B_SIG <=  '1';
  ELSE B_SIG <=  '0';
  END IF;

  IF ((i_pixel_row >= OBS_ATAS)  AND (i_pixel_row <= OBS_BAWAH )  ) AND ((i_pixel_column >= O_KIRI )  AND (i_pixel_column <= O_KANAN)  ) THEN M_SIG <=  '1';
  ELSE M_SIG <=  '0';
  END IF;

  IF (B_SIG = '1') THEN  o_red <= X"00"; o_green <= X"00"; o_blue <= X"FF";     --OUTPUT WARNA BIRU UNTUK USER
  ELSIF (M_SIG = '1') THEN  o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00";  --OUTPUT WARNA MERAH UNTUK OBSTACLES
  ELSE o_red <= X"FF"; o_green <= X"FF"; o_blue <= X"FF";						--OUTPUT WARNA PUTIH UNTUK BACKGROUND
  END IF;
 
END PROCESS;

END behavioral;