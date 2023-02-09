library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rgbgray is 
	port (
		r:			in		std_logic_vector(7 downto 0);
		g:			in		std_logic_vector(7 downto 0);
		b:			in		std_logic_vector(7 downto 0);
		
		gray:		out		std_logic_vector(7 downto 0)
	);
end rgbgray;

architecture rtl of rgbgray is

	signal r1: std_logic_vector(7 downto 0);
	signal r2: std_logic_vector(7 downto 0);
	signal g1: std_logic_vector(7 downto 0);
	signal g2: std_logic_vector(7 downto 0);
	signal b1: std_logic_vector(7 downto 0);
	signal b2: std_logic_vector(7 downto 0);

begin
	
	r1 <= "00" 		& r(7 downto 2); -- shift right by 2
	r2 <= "00000" 	& r(7 downto 5); -- shift right by 5
	g1 <= "0" 		& g(7 downto 1); -- shift right by 1
	g2 <= "0000" 	& g(7 downto 4); -- shift right by 4
	b1 <= "0000" 	& b(7 downto 4); -- shift right by 4
	b2 <= "00000" 	& b(7 downto 5); -- shift right by 5

	-- Add all the values together
	gray <= std_logic_vector(unsigned(r1) + unsigned(r2) + unsigned(g1) + unsigned(g2) + unsigned(b1) + unsigned(b2));
	
end rtl;