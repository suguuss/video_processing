library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity full_ram is 
	port
	(
		data		:	in 		std_logic_vector (7 downto 0);
		rdaddress	:	in 		std_logic_vector (16 downto 0);
		rdclock		:	in 		std_logic ;
		wraddress	:	in 		std_logic_vector (16 downto 0);
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
	
	signal data0:	std_logic_vector(7 downto 0);
	signal data1:	std_logic_vector(7 downto 0);

	signal wr_en:	std_logic_vector(1 downto 0);

begin
	
	process(rdclock)
	begin
		if rising_edge(rdclock) then
			if rdaddress(16) = '0' then
				q <= q0;
			else
				q <= q1;
			end if ;
		end if;
	end process;

	process(wrclock)
	begin
		if rising_edge(wrclock) then
			if wraddress(16) = '0' then
				data0 <= data;
				wr_en <= "01";
			else
				data1 <= data;
				wr_en <= "10";
			end if;
		end if;
	end process;


	ram0: img_ram 
		port map (
			data		=> data0,
			rdaddress	=> rdaddress(15 downto 0),
			rdclock		=> rdclock,
			wraddress	=> wraddress(15 downto 0),
			wrclock		=> wrclock,
			wren		=> wr_en(0),
			q			=> q0
		);
	ram1: img_ram 
		port map (
			data		=> data1,
			rdaddress	=> rdaddress(15 downto 0),
			rdclock		=> rdclock,
			wraddress	=> wraddress(15 downto 0),
			wrclock		=> wrclock,
			wren		=> wr_en(1),
			q			=> q1
		);

end rtl;