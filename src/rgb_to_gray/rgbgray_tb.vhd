library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rgbgray_tb is
end rgbgray_tb;

architecture testbench of rgbgray_tb is

	component rgbgray
		port (
			r:			in		std_logic_vector(7 downto 0);
			g:			in		std_logic_vector(7 downto 0);
			b:			in		std_logic_vector(7 downto 0);
			
			gray:		out		std_logic_vector(7 downto 0)
		);
	end component;

	signal r: 		std_logic_vector(7 downto 0) := "11010110";
	signal g: 		std_logic_vector(7 downto 0) := "11111110";
	signal b: 		std_logic_vector(7 downto 0) := "01011100";
	signal gray: 	std_logic_vector(7 downto 0);

begin
	
	uut: rgbgray
		port map (
			r => r,
			g => g,
			b => b,
			gray => gray
		);

	process begin

	for i in 0 to 1 loop
		wait for 2 us;
		r <= "00110010";
		g <= "01011010";
		b <= "00000010";
	end loop;
	
	
	report "test done";
	wait;
	end process;

end testbench;