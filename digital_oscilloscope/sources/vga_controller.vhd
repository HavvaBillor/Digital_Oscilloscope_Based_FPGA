-----------------------------------------------------------------------------
-- HAVVA BİLLOR
-- ALEYNA ÇETİN
--
-- DIGITAL OSILLOSCOPE BASED FPGA 
-----------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.TermProjectLibrary.ALL;



entity VGA_Driver is
	port(
		CLK: in std_logic;
		DATA : in STD_LOGIC_VECTOR(11 downto 0);
		VGA_HS, VGA_VS : out std_logic;
		VGA_B : out std_logic_vector (4 downto 0);
		VGA_G: out std_logic_vector (5 downto 0);
		VGA_R: out std_logic_vector (4 downto 0)
		);
end VGA_Driver;

architecture Behavioral of VGA_Driver is


---------------------------------------------------
-------------------Components----------------------
component VGA_Sync is

    Port ( 

        CLK : in std_logic;
		bg_blue : in std_logic_vector (4 downto 0);
		bg_green: in std_logic_vector (5 downto 0);
		bg_red: in std_logic_vector (4 downto 0);
        H_PosOut, V_PosOut : out std_logic_vector(11 downto 0);
        VGA_HS, VGA_VS : out std_logic;
        VGA_B : out std_logic_vector (4 downto 0);
		VGA_G: out std_logic_vector (5 downto 0);
		VGA_R: out std_logic_vector (4 downto 0)
		);
end component;


---------------------------------------------------
-------------------signals-------------------------


signal H_Pos, V_Pos : std_logic_vector(11 downto 0);
signal bg_red  :  std_logic_vector(4 downto 0);
signal bg_green :  std_logic_vector(5 downto 0);
signal bg_blue :  std_logic_vector(4 downto 0);

---------------------------------------------------
-------------------constant------------------------
constant FRAME_WIDTH : natural := 1024;
constant FRAME_HEIGHT : natural := 768;
-- Frame Constants
constant xFrameLeft : natural := 50; 
constant xFrameRight : natural := 50;
constant yFrameTop : natural := 92;
constant yFrameBottom : natural := 46;


constant xFrameWidth : natural := (FRAME_WIDTH - xFrameLeft - xFrameRight) - (FRAME_WIDTH - xFrameLeft - xFrameRight) rem 70;
constant xFrameCenter : natural := xFrameLeft + (xFrameWidth / 2);
constant xFrameGrid : natural := xFrameWidth / 14;
constant yFrameHeight : natural := (FRAME_HEIGHT - yFrameTop - yFrameBottom) - (FRAME_HEIGHT - yFrameTop - yFrameBottom) rem 40;
constant yFrameCenter : natural := yFrameTop + (yFrameHeight / 2);
constant yFrameGrid : natural := yFrameHeight / 8;

----------------------------------------------------------------

----------------------------- RAM ------------------------------

type ram_type is array(0 to 1023) of std_logic_vector(8 downto 0);  -- 0-511 range için
signal sample_ram : ram_type;
signal write_ptr  : integer range 0 to 1023 := 0;

signal adc_int  : integer;
signal y_value  : integer range 0 to 511;  -- VGA için uyarlanmış değer

signal prev_adc_int : integer := 0;
signal read_base : integer := 0;


signal clk_10k	:std_logic:='0';
signal clk_counter : integer range 0 to 3249 :=0;

---------------------------------------------------------------

begin


				  
--VGA INST

VGA_Sync_Module: VGA_Sync
        port map(
            CLK       => CLK,
			bg_blue   => bg_blue,
            bg_red    => bg_red,
            bg_green  => bg_green,
            H_PosOut  => H_Pos,
            V_PosOut  => V_Pos,
            VGA_HS    => VGA_HS,
            VGA_VS    => VGA_VS,
            VGA_R     => VGA_R,
            VGA_G     => VGA_G,
            VGA_B     => VGA_B
        ); 

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
    adc_int <= to_integer(unsigned(DATA));
    y_value <= 599- ((adc_int*599)/4095);

    sample_ram(write_ptr) <= std_logic_vector(to_unsigned(y_value, 9));
    write_ptr <= (write_ptr + 1) mod 1024;
  end if;
end process;




process(CLK)
variable ram_index :integer;
begin 

	if rising_edge(CLK) then 
		bg_red <= "00000";
		bg_green <= "000000";
		bg_blue <= "10101";
		
	
		if (V_Pos < yFrameTop - 20) then -- Top

						  if (draw_string(conv_integer(H_Pos), conv_integer(V_Pos), xFrameCenter - xFrameLeft - 260 , 32, " Digital Oscilloscope Based FPGA", false, 2)) then

								bg_red <= (others => '1');
								bg_green <= (others => '1');
								bg_blue <= (others => '1');

							end if;
		elsif (V_Pos >= yFrameTop and V_Pos <= yFrameTop + yFrameHeight) then -- Middle

                 if (H_Pos >= xFrameLeft and H_Pos <= xFrameLeft + xFrameWidth) then -- Middle in/on Frame

                     if (V_Pos = yFrameTop or V_Pos = yFrameTop + yFrameHeight or H_Pos = xFrameLeft or H_Pos = xFrameLeft + xFrameWidth) then -- Middle on Frame

                         -- Draw white borders
                         bg_red <= (others => '0');
                         bg_green <= (others => '1');
                         bg_blue <= (others => '0');

                     else -- Middle in Frame

								 
								 ram_index :=conv_integer(H_Pos)-xFrameLeft;
								 
									if (conv_integer(V_Pos) = yFrameTop + yFrameHeight - conv_integer(sample_ram(ram_index))) then
									-- Draw CH1 signal

									  bg_red <= (others => '1');
									  bg_green <= (others => '1');
									  bg_blue <= (others => '0');
									

                         elsif ((((conv_integer(H_Pos) - xFrameLeft) rem (xFrameGrid / 5) = 0) and ((conv_integer(V_Pos) - yFrameTop) rem yFrameGrid = 0)) or (((conv_integer(H_Pos) - xFrameLeft) rem xFrameGrid = 0) and ((conv_integer(V_Pos) - yFrameTop) rem (yFrameGrid / 5) = 0))) then

                             -- Draw reference points

                             bg_red <= (others => '0');
                             bg_green <= (others => '1');
                             bg_blue <= (others => '0');                                                                 

                         elsif ((((conv_integer(H_Pos) - xFrameLeft) rem (xFrameGrid / 5) = 0) and (V_Pos < yFrameTop + 8 or V_Pos > yFrameTop + yFrameHeight - 8)) or (((conv_integer(V_Pos) - yFrameTop) rem (yFrameGrid / 5) = 0) and (H_Pos < xFrameLeft + 6 or H_Pos > xFrameLeft + xFrameWidth - 6))) then

                             -- Draw reference lines

                             bg_red <= (others => '0');
                             bg_green <= (others => '1');
                             bg_blue <= (others => '0');                         

                         elsif ((((conv_integer(H_Pos) - xFrameLeft) rem (xFrameGrid / 5) = 0) and (V_Pos < (yFrameCenter + 4) and V_Pos > (yFrameCenter - 4))) or (((conv_integer(V_Pos) - yFrameTop) rem (yFrameGrid / 5) = 0) and (H_Pos < (xFrameCenter + 3) and H_Pos > (xFrameCenter - 3)))) then

                             -- Draw reference lines - Center

                             bg_red <= (others => '0');
                             bg_green <= (others => '1');
                             bg_blue <= (others => '0');

                         else

                             -- Draw black bakground

                             bg_red <= (others => '0');
                             bg_green <= (others => '0');
                             bg_blue <= (others => '0');
								end if;

                   end if;       

                end if;
									  
			elsif (V_Pos > FRAME_HEIGHT - yFrameBottom and V_Pos <= FRAME_HEIGHT ) then -- Bottom

						   if (draw_string(conv_integer(H_Pos), conv_integer(V_Pos), xFrameCenter - 30, 730, "Havva Billor   Aleyna Cetin", false, 2)) then

								bg_red <= (others => '1');
								bg_green <= (others => '1');
								bg_blue <= (others => '1');
							end if;

         end if;  
	end if;

end process;




end Behavioral;










