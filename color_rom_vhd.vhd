LIBRARY  IEEE; 
USE  IEEE.STD_LOGIC_1164.ALL; 
USE  IEEE.STD_LOGIC_ARITH.ALL; 
USE  IEEE.STD_LOGIC_UNSIGNED.ALL;
 
ENTITY color_rom_vhd  IS 
	PORT(
		CLOCK   	    : IN STD_LOGIC;
		jump 			: IN STD_LOGIC;
		reset 			: IN STD_LOGIC;
		start			: IN STD_LOGIC;
		random 			: IN STD_LOGIC;
	    i_pixel_column  : IN STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	    i_pixel_row     : IN STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	    o_red           : OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	    o_green         : OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	    o_blue          : OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	    hit_i			: IN STD_LOGIC;
	    f_counter		: IN STD_LOGIC;
	    finish			: IN STD_LOGIC;
	    hit_o			: OUT STD_LOGIC;
	    airborne		: OUT STD_LOGIC);
	    
END color_rom_vhd; 

ARCHITECTURE behavioral OF color_rom_vhd  IS 

SIGNAL M_SIG, B_SIG 	: STD_LOGIC; -- SINYAL MERAH DAN BIRU UNTUK MEWARNAI KOTAK
SIGNAL sentuh			: STD_LOGIC;
SIGNAL gerak			: STD_LOGIC;
SIGNAL clk100Hz			: BIT;
--SIGNAL impact			: STD_LOGIC;
SIGNAL air				: STD_LOGIC;
SIGNAL kena				: STD_LOGIC;

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
	CLK 	=> CLOCK,
	div		=> 250000,
	DIVOUT 	=> clk100hz
		);

PROCESS(i_pixel_row,i_pixel_column, M_SIG, B_SIG, jump, reset,clk100Hz,hit_i,kena,f_counter)

-- KONDISI AWAL :
	-- USER :
	CONSTANT USER_KANAN 	: INTEGER := 150;
	CONSTANT USER_KIRI  	: INTEGER := 100;
	CONSTANT USER_ATAS  	: INTEGER := 430;
	CONSTANT USER_BAWAH 	: INTEGER := 480;

	-- OBS :
	CONSTANT OBS_ATAS 		: INTEGER := 420;
	CONSTANT OBS_BAWAH		: INTEGER := 480;
	CONSTANT OBS_KIRI		: INTEGER := 700;
	CONSTANT OBS_KANAN		: INTEGER := 775;

-- BATAS KOTAK USER :
	CONSTANT  BATAS_LONCAT  : INTEGER := 100;
	CONSTANT  BATAS_BAWAH   : INTEGER := 480;

-- BATAS KOTAK OBSTACLE KETIKA BELUM ADA RINTANGAN :
	CONSTANT  O_KI  		: INTEGER := 40;
	
-- DIMENSI KOTAK OBSTACLE :
	VARIABLE O_KIRI			: INTEGER := 700;
	VARIABLE O_KANAN		: INTEGER := 775;
	
-- DIMENSI KOTAK USER :
	VARIABLE U_ATAS  		: INTEGER := 430;
	VARIABLE U_BAWAH 		: INTEGER := 480;

-- DIMENSI AKHIR
	CONSTANT ATAS 		: INTEGER := 0;
	CONSTANT BAWAH		: INTEGER := 480;
	CONSTANT KIRI		: INTEGER := 0;
	CONSTANT KANAN		: INTEGER := 640;
BEGIN
	IF (clk100Hz'EVENT AND clk100Hz = '1' ) THEN
		IF (reset = '1') THEN       -- INISIALISASI USER DAN OBSTACLES
			U_ATAS 	:= USER_ATAS;
			U_BAWAH := USER_BAWAH;
			O_KIRI 	:= OBS_KIRI;
			O_KANAN := OBS_KANAN;
			hit_o <= '0';
			kena <= '0';
		ELSIF (jump = '1' OR air ='1' ) THEN   -- SAAT LONCAT
			IF ((U_ATAS >= BATAS_LONCAT) AND (SENTUH = '0')) THEN
				U_ATAS 	:= U_ATAS - 10;
				U_BAWAH := U_BAWAH - 10 ;
				air <= '1';
				IF ( U_ATAS = BATAS_LONCAT) THEN
					SENTUH <= '1';
				END IF;
			ELSIF (sentuh = '1') THEN      -- SAAT JATUH
				IF (U_BAWAH  <= BATAS_BAWAH) THEN
					U_ATAS 	:= U_ATAS + 10;
					U_BAWAH := U_BAWAH + 10 ;
					IF ( U_BAWAH = BATAS_BAWAH) THEN
						SENTUH <= '0';
						airborne <= '0';
						air	<= '0';
					END IF;
				END IF;
			END IF;
		ELSIF ((air = '0') AND (reset = '0')) THEN     -- SAAT KONDISI IDLE
			U_ATAS 	:= U_ATAS;
			U_BAWAH := U_BAWAH;
		END IF;
			
		IF (((random = '1') OR (gerak = '1')) AND (O_KIRI >= O_KI) AND (finish = '0')) THEN   -- SAAT GERAK MENDEKATI USER
			gerak 	<= '1';
			O_KIRI 	:= O_KIRI - 5;
			O_KANAN := O_KANAN - 5;
			IF (O_KIRI = O_KI) THEN    --SAAT BOX KIRI UDAH SAMPAI UJUNG KIRI LANGSUNG NGILANG
				O_KIRI 	:= OBS_KIRI;
				O_KANAN := OBS_KANAN;
				gerak 	<= '0';
			END IF;
		END IF;
		IF (clk100Hz'EVENT AND clk100Hz = '1') THEN
			IF ((USER_KANAN = O_KIRI AND U_BAWAH >= OBS_ATAS) OR ((U_BAWAH = OBS_ATAS) AND ( O_KIRI > USER_KANAN) AND ( O_KANAN < USER_KIRI))) THEN   --NGASIH TAU KENA ATAU ENGGA
				hit_o <= '1';
				kena <= '1';
			END IF;
		END IF;
	END IF;
	
  IF ((i_pixel_row >= U_ATAS)  AND (i_pixel_row <= U_BAWAH )  ) AND ((i_pixel_column >= USER_KIRI )  AND (i_pixel_column <= USER_KANAN)  ) THEN B_SIG <=  '1';
  ELSE B_SIG <=  '0';
  END IF;

  IF ((i_pixel_row >= OBS_ATAS)  AND (i_pixel_row <= OBS_BAWAH )  ) AND ((i_pixel_column >= O_KIRI )  AND (i_pixel_column <= O_KANAN)  ) THEN M_SIG <=  '1';
  ELSE M_SIG <=  '0';
  END IF;

  IF (kena = '1') THEN
		o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00";
  ELSIF (f_counter = '1') THEN
		o_red <= X"00"; o_green <= X"FF"; o_blue <= X"00";
  ELSIF (B_SIG = '1') THEN  
		o_red <= X"00"; o_green <= X"00"; o_blue <= X"FF";     --OUTPUT WARNA BIRU UNTUK USER
  ELSIF (M_SIG = '1') THEN  
		o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00";  --OUTPUT WARNA MERAH UNTUK OBSTACLES
  ELSE 
		o_red <= X"FF"; o_green <= X"FF"; o_blue <= X"FF";						--OUTPUT WARNA PUTIH UNTUK BACKGROUND
  END IF;
 
END PROCESS;

--hit_o <= impact;

END behavioral;