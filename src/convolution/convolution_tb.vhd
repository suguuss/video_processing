library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity convolution_tb is 
end convolution_tb;

architecture rtl of convolution_tb is
	
	component convolution
		port (
			clk:		in		std_logic;
			pxl:		in		std_logic_vector(7 downto 0);
			new_pxl:	out		std_logic_vector(7 downto 0) := (others => '0')
		);
	end component;

	signal clk:		std_logic := '0';
	signal pxl: 	std_logic_vector(7 downto 0);
	signal new_pxl: std_logic_vector(7 downto 0);

begin

	uut: convolution 
		port map (
			clk => clk,
			pxl => pxl,
			new_pxl => new_pxl
		);

	process begin


		for i in 0 to 200 loop
			pxl <= std_logic_vector(to_unsigned(i, 8)) xor x"5a";

			clk <= '0'; wait for 1 us;
			clk <= '1'; wait for 1 us;
			
		end loop;



		report "test done";
		wait;

	end process;


end rtl;