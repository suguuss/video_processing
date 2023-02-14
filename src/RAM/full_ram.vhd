library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity full_ram is 
	port
	(
		data		:	in 		std_logic_vector (7 downto 0);
		rdaddress	:	in 		std_logic_vector (18 downto 0);
		rdclock		:	in 		std_logic ;
		wraddress	:	in 		std_logic_vector (18 downto 0);
		wrclock		:	in 		std_logic  := '1';
		wren		:	in 		std_logic  := '0';
		q			:	out 	std_logic_vector (7 downto 0)
	);
end full_ram;

architecture rtl of full_ram is

	component img_ram
	port
	(
		data		: 	in		std_logic_vector (7 downto 0);
		rdaddress	: 	in		std_logic_vector (15 downto 0);
		rdclock		: 	in		std_logic;
		wraddress	: 	in		std_logic_vector (15 downto 0);
		wrclock		: 	in		std_logic := '1';
		wren		: 	in		std_logic := '0';
		q			: 	out		std_logic_vector (7 downto 0)
	);
	end component;

	signal q0:		std_logic_vector(7 downto 0);
	signal q1:		std_logic_vector(7 downto 0);
	signal q2:		std_logic_vector(7 downto 0);
	signal q3:		std_logic_vector(7 downto 0);
	signal q4:		std_logic_vector(7 downto 0);
	signal q5:		std_logic_vector(7 downto 0);
	signal q6:		std_logic_vector(7 downto 0);
	signal q7:		std_logic_vector(7 downto 0);
	
	signal data0:	std_logic_vector(7 downto 0);
	signal data1:	std_logic_vector(7 downto 0);
	signal data2:	std_logic_vector(7 downto 0);
	signal data3:	std_logic_vector(7 downto 0);
	signal data4:	std_logic_vector(7 downto 0);
	signal data5:	std_logic_vector(7 downto 0);
	signal data6:	std_logic_vector(7 downto 0);
	signal data7:	std_logic_vector(7 downto 0);

begin
	
	process(wrclock)
	begin
		case wraddress(18 downto 16) is
			when "000" => q <= q0;
			when "001" => q <= q1;
			when "010" => q <= q2;
			when "011" => q <= q3;
			when "100" => q <= q4;
			when "101" => q <= q5;
			when "110" => q <= q6;
			when "111" => q <= q7;
		end case;
	end process;

	process(rdclock)
	begin
		case rdaddress(18 downto 16) is
			when "000" => data0 <= data;
			when "001" => data1 <= data;
			when "010" => data2 <= data;
			when "011" => data3 <= data;
			when "100" => data4 <= data;
			when "101" => data5 <= data;
			when "110" => data6 <= data;
			when "111" => data7 <= data;
		end case;
	end process;


	ram0: img_ram 
		port map (
			data		=> data0,
			rdaddress	=> rdaddress(15 downto 0),
			rdclock		=> rdclock,
			wraddress	=> wraddress(15 downto 0),
			wrclock		=> wrclock,
			wren		=> wren,
			q			=> q0
		);
	ram1: img_ram 
		port map (
			data		=> data1,
			rdaddress	=> rdaddress(15 downto 0),
			rdclock		=> rdclock,
			wraddress	=> wraddress(15 downto 0),
			wrclock		=> wrclock,
			wren		=> wren,
			q			=> q1
		);
	ram2: img_ram 
		port map (
			data		=> data2,
			rdaddress	=> rdaddress(15 downto 0),
			rdclock		=> rdclock,
			wraddress	=> wraddress(15 downto 0),
			wrclock		=> wrclock,
			wren		=> wren,
			q			=> q2
		);
	ram3: img_ram 
		port map (
			data		=> data3,
			rdaddress	=> rdaddress(15 downto 0),
			rdclock		=> rdclock,
			wraddress	=> wraddress(15 downto 0),
			wrclock		=> wrclock,
			wren		=> wren,
			q			=> q3
		);
	ram4: img_ram 
		port map (
			data		=> data4,
			rdaddress	=> rdaddress(15 downto 0),
			rdclock		=> rdclock,
			wraddress	=> wraddress(15 downto 0),
			wrclock		=> wrclock,
			wren		=> wren,
			q			=> q4
		);
	ram5: img_ram 
		port map (
			data		=> data5,
			rdaddress	=> rdaddress(15 downto 0),
			rdclock		=> rdclock,
			wraddress	=> wraddress(15 downto 0),
			wrclock		=> wrclock,
			wren		=> wren,
			q			=> q5
		);
	ram6: img_ram 
		port map (
			data		=> data6,
			rdaddress	=> rdaddress(15 downto 0),
			rdclock		=> rdclock,
			wraddress	=> wraddress(15 downto 0),
			wrclock		=> wrclock,
			wren		=> wren,
			q			=> q6
		);
	ram7: img_ram 
		port map (
			data		=> data7,
			rdaddress	=> rdaddress(15 downto 0),
			rdclock		=> rdclock,
			wraddress	=> wraddress(15 downto 0),
			wrclock		=> wrclock,
			wren		=> wren,
			q			=> q7
		);


end rtl;