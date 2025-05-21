----------------------------------------------------------------------------------
-- HAVVA BİLLOR
-- ALEYNA ÇETİN
--
-- DIGITAL OSILLOSCOPE BASED FPGA 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;



entity TOP_MODULE is 
port(
		CLK: in std_logic;
		RST_N: in std_logic;
		ADC_CLK:out std_logic;
		DATA : in STD_LOGIC_VECTOR(11 downto 0);
		VGA_HS, VGA_VS : out std_logic;
		VGA_B : out std_logic_vector (4 downto 0);
		VGA_G: out std_logic_vector (5 downto 0);
		VGA_R: out std_logic_vector (4 downto 0)
		);
end TOP_MODULE;

architecture Behavioral of TOP_MODULE is


------------------------------------------------------
------------------COMPONENTS--------------------------

component AD9226_Controller is

    Port (
		  CLK       : in std_logic;
		  RST_N		: in std_logic;
		  START		: in std_logic;
		  PIADCDATA : in STD_LOGIC_VECTOR(11 downto 0);
          POADCDATA : out STD_LOGIC_VECTOR(11 downto 0)

    );

end component;

component VGA_Driver is
	port(
		CLK: in std_logic;
		DATA : in STD_LOGIC_VECTOR(11 downto 0);
		VGA_HS, VGA_VS : out std_logic;
		VGA_B : out std_logic_vector (4 downto 0);
		VGA_G: out std_logic_vector (5 downto 0);
		VGA_R: out std_logic_vector (4 downto 0)
		);
end component;

component PLL1
port
 (-- Clock in ports
  CLK_IN1           : in     std_logic;
  -- Clock out ports
  CLK_OUT1          : out    std_logic;
  CLK_OUT2          : out    std_logic
 );
end component;

---------------------------------------------------------
---------------------SIGNALS-----------------------------

signal SDATA:std_logic_vector(11 downto 0);
signal pixel_clk : std_logic;--- vga 65mhz
signal data_clk: std_logic;  --- adc data clk

---------------------------------------------------------

begin

	 
PLL: PLL1
  port map
   (-- Clock in ports
    CLK_IN1 => CLK,
    -- Clock out ports
    CLK_OUT1 => pixel_clk,
    CLK_OUT2 => data_clk);	 
	 
	 
	  

ADC : AD9226_Controller 

    Port map (
		  CLK       => data_clk, 
		  RST_N 	=> RST_N,
		  START     =>'1',
          PIADCDATA => DATA, 
          POADCDATA => SDATA  

    );


VGA: VGA_Driver 
	port map(
		CLK	   => pixel_clk,
		DATA   => SDATA, 	
		VGA_HS => VGA_HS,
		VGA_VS => VGA_VS,
		VGA_R  => VGA_R,
		VGA_G  => VGA_G,
		VGA_B  => VGA_B
		);

ODDR2_inst : ODDR2
generic map (
   DDR_ALIGNMENT => "NONE", -- "NONE", "C0", "C1"
   INIT => '0', 
   SRTYPE => "SYNC" -- "ASYNC" or "SYNC"
)
port map (
   Q  => ADC_CLK,       -- Output
   C0 => data_clk,      -- Clock
   C1 => not data_clk,  -- Inverted Clock
   CE => '1',
   D0 => '1',
   D1 => '0',
   R  => '0',
   S  => '0'
);


end Behavioral;

