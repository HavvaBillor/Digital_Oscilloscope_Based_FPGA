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


entity AD9226_Controller is
    port (
	CLK         : in std_logic;
	RST_N	    : in std_logic;
	START	    : in std_logic;
        PIADCDATA   : in STD_LOGIC_VECTOR(11 downto 0);
        POADCDATA   : out STD_LOGIC_VECTOR(11 downto 0)
    );
end AD9226_Controller;



architecture Behavioral of AD9226_Controller is 

signal clk_10k	:std_logic:='0';
signal clk_counter : integer range 0 to 3249 :=0;

type delay_array is array (0 to 6) of std_logic_vector(11 downto 0);
signal delay_line : delay_array:= (others => (others=> '0'));

begin 

process(CLK,clk_counter,clk_10k) 
begin 
	
	if rising_edge(clk) then 
			clk_10k <= '0';
			clk_counter<= 0;
		if clk_counter=3249 then 
			clk_10k <= not clk_10k;
			clk_counter <= 0;
		else 
			clk_counter <= clk_counter + 1;
		end if;
	end if;
end process;



process(clk_10k)
begin 

	if rising_edge(clk_10k) then 
		if RST_N ='0' then 
			delay_line <= (others => (others=> '0'));
		elsif START = '1' then 
			delay_line(6) <= delay_line(5);
			delay_line(5) <= delay_line(4);
			delay_line(4) <= delay_line(3);
			delay_line(3) <= delay_line(2);
			delay_line(2) <= delay_line(1);
			delay_line(1) <= delay_line(0);
			delay_line(0) <= PIADCDATA;
		end if;
	end if;
end process;


POADCDATA <= delay_line(6) ;

end Behavioral; 
