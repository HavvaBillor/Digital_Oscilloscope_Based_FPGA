-----------------------------------------------------------------------------
-- Copyright (c) 2022 Burak Künkçü
-- VGA SYNC 1024x768 --
-----------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;





entity VGA_Sync is
    port ( 
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

end VGA_Sync;



architecture Behavioral of VGA_Sync is


-------------------------- Constants ---------------------------

constant FRAME_WIDTH : natural := 1024;
constant FRAME_HEIGHT : natural := 768;

-- Horizontal Constants

constant H_FP : natural := 24; --H front porch width (pixels)
constant H_PW : natural := 136;
constant H_MAX : natural := 1344;
constant H_POL : std_logic := '0';

-- Vertical Constants

constant V_FP : natural := 3;
constant V_PW : natural := 6;
constant V_MAX : natural := 806;
constant V_POL : std_logic := '0';

----------------------------------------------------------------

--------------------------- Signals ----------------------------


signal active  : std_logic; -- Active Region Indicator
-- Horizontal and Vertical Counters
signal H_Pos, V_Pos : std_logic_vector(11 downto 0) := (others =>'0');
-- Horizontal and Vertical Sync
signal H_Sync : std_logic := not(H_POL);
signal V_Sync : std_logic := not(V_POL);
-- Drawing Signals
----------------------------------------------------------------

begin


H_PosOut <= H_Pos;
V_PosOut <= V_Pos;
active <= '1' when H_Pos < FRAME_WIDTH and V_Pos < FRAME_HEIGHT else '0';
	 

-- Horizontal Counter
process (CLK)
begin
    if (rising_edge(CLK)) then
        if (H_Pos = (H_MAX - 1)) then
            H_Pos <= (others =>'0');
        else
            H_Pos <= H_Pos + 1;
        end if;
    end if;
end process;

-- Vertical Counter

process (CLK)
begin
    if (rising_edge(CLK)) then
        if ((H_Pos = (H_MAX - 1)) and (V_Pos = (V_MAX - 1))) then
            V_Pos <= (others =>'0');
        elsif (H_Pos = (H_MAX - 1)) then
            V_Pos <= V_Pos + 1;
        end if;
    end if;
end process;

-- Horizontal Sync

process (CLK)
begin
    if (rising_edge(CLK)) then
        if (H_Pos >= (H_FP + FRAME_WIDTH - 1)) and (H_Pos < (H_FP + FRAME_WIDTH + H_PW - 1)) then
            H_Sync <= H_POL;
        else
            H_Sync <= not(H_POL);
        end if;
    end if;
end process;

-- Vertical Sync

process (CLK)
begin
    if (rising_edge(CLK)) then
        if (V_Pos >= (V_FP + FRAME_HEIGHT - 1)) and (V_Pos < (V_FP + FRAME_HEIGHT + V_PW - 1)) then
            V_Sync <= V_POL;
        else
            V_Sync <= not(V_POL);
        end if;
    end if;
end process;

    

VGA_HS <= H_Sync;
VGA_VS <= V_Sync;

VGA_R <= bg_red   when active = '1' else (others => '0');
VGA_G <= bg_green when active = '1' else (others => '0');
VGA_B <= bg_blue  when active = '1' else (others => '0');



end Behavioral;