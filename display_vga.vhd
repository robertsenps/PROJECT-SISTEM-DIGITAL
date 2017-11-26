LIBRARY  IEEE; 
USE  IEEE.STD_LOGIC_1164.ALL; 
USE  IEEE.STD_LOGIC_ARITH.ALL; 
USE  IEEE.STD_LOGIC_UNSIGNED.ALL;
 
ENTITY display_vga  IS 
	PORT( 
	    i_clk           : IN STD_LOGIC;
	    jump 			: IN STD_LOGIC;
		reset 			: IN STD_LOGIC;
		start			: IN STD_LOGIC;
		random 			: IN STD_LOGIC;
	    hit_i			: IN STD_LOGIC;
	    hit_o			: OUT STD_LOGIC;
		airborne		: OUT STD_LOGIC;
	    VGA_R           : OUT STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	    VGA_G           : OUT STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	    VGA_B           : OUT STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	    VGA_HS          : OUT STD_LOGIC;
	    VGA_VS          : OUT STD_LOGIC);
--	    VGA_CLK         : OUT STD_LOGIC;
--	    VGA_BLANK       : OUT STD_LOGIC);
		
END display_vga; 

ARCHITECTURE behavioral OF display_vga  IS 

SIGNAL  red                 :        STD_LOGIC_VECTOR (5 DOWNTO 0);	  
SIGNAL  green               :        STD_LOGIC_VECTOR (5 DOWNTO 0);	  
SIGNAL  blue                :        STD_LOGIC_VECTOR (5 DOWNTO 0);	  
SIGNAL  red_color           :        STD_LOGIC_VECTOR (7 DOWNTO 0);   
SIGNAL  green_color         :        STD_LOGIC_VECTOR (7 DOWNTO 0);   
SIGNAL  blue_color          :        STD_LOGIC_VECTOR (7 DOWNTO 0);   
SIGNAL  pixel_row           :        STD_LOGIC_VECTOR (9 DOWNTO 0);   
SIGNAL  pixel_column        :        STD_LOGIC_VECTOR (9 DOWNTO 0);               
SIGNAL  red_on              :        STD_LOGIC;              
SIGNAL  green_on            :        STD_LOGIC;              
SIGNAL  blue_on             :        STD_LOGIC;              

COMPONENT vga  IS 
	PORT( 
		i_clk              :  IN   STD_LOGIC; 
		i_red              :  IN   STD_LOGIC; 
		i_green            :  IN   STD_LOGIC; 
		i_blue             :  IN   STD_LOGIC; 
		o_red              :  OUT  STD_LOGIC; 
		o_green            :  OUT  STD_LOGIC; 
		o_blue             :  OUT  STD_LOGIC;  
		o_horiz_sync       :  OUT  STD_LOGIC; 
		o_vert_sync        :  OUT  STD_LOGIC; 
		o_pixel_row        :  OUT  STD_LOGIC_VECTOR( 9 DOWNTO 0 ); 
		o_pixel_column     :  OUT  STD_LOGIC_VECTOR( 9 DOWNTO 0 )); 
END COMPONENT;  

COMPONENT color_rom_vhd  IS 
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
	    hit_o			: OUT STD_LOGIC;
		airborne		: OUT STD_LOGIC);
	    
END COMPONENT;

BEGIN 

vga_driver0 : vga 
   PORT MAP (
   i_clk            => i_clk,
   i_red            => '1',
   i_green          => '1',
   i_blue           => '1',
   o_red            => red_on,
   o_green          => green_on,
   o_blue           => blue_on,
   o_horiz_sync     => VGA_HS,
   o_vert_sync      => VGA_VS,
   o_pixel_row      => pixel_row,
   o_pixel_column   => pixel_column);

color_rom0 : color_rom_vhd 
   PORT MAP (
   CLOCK	   	    => i_clk,
   jump				=> jump,
   reset			=> reset,
   start			=> start,
   random			=> random,
   i_pixel_column   => pixel_column,
   i_pixel_row      => pixel_row,
   o_red            => red_color,
   o_green          => green_color,
   o_blue           => blue_color,
   hit_i			=> hit_i,
   hit_o			=> hit_o,
   airborne			=> airborne
   );
   
red   <= red_color  (7 DOWNTO 2) ;
green <= green_color(7 DOWNTO 2) ;
blue  <= blue_color (7 DOWNTO 2) ;


PROCESS(red_on,green_on,blue_on,red,green,blue)
BEGIN

  IF (red_on = '1'  ) THEN VGA_R <=  red;
  ELSE  VGA_R <=  "000000";
  END IF;
  
  IF (green_on = '1'  ) THEN VGA_G <=  green;
  ELSE VGA_G <=  "000000";
  END IF;
  
  IF (blue_on = '1'  ) THEN VGA_B <=  blue;
  ELSE VGA_B <=  "000000";
  END IF;
  
  
END PROCESS;



END behavioral; 