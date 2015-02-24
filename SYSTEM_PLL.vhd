----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:25:47 02/14/2015 
-- Design Name: 
-- Module Name:    SYSTEM_PLL - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity SYSTEM_PLL is
	Port (inclk0 : in STD_LOGIC;
		c0 : out STD_LOGIC );
end SYSTEM_PLL;

architecture Behavioral of SYSTEM_PLL is
signal clk_fast : STD_LOGIC;
--signal cnt_r :  STD_LOGIC_VECTOR(22 downto 0) := (others => '0');

begin 

DCM_SP_inst : DCM_SP
	generic map (
		CLKFX_DIVIDE => 1,
		CLKFX_MULTIPLY => 4
	)
	port map (
		CLKFX => clk_fast,
		CLKIN => inclk0,
		RST => '0'
		);

--process(clk_fast) is
--begin
--	if rising_edge(clk_fast) then
--		cnt_r <= cnt_r + 1;
--	end if;
--end process;

--c0 <= cnt_r(22);

c0 <= clk_fast;

end Behavioral;



