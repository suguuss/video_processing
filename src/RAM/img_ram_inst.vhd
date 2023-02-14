
component img_ram
port
(
	data		: in std_logic_vector (7 downto 0);
	rdaddress	: in std_logic_vector (15 downto 0);
	rdclock		: in std_logic;
	wraddress	: in std_logic_vector (15 downto 0);
	wrclock		: in std_logic := '1';
	wren		: in std_logic := '0';
	q			: out std_logic_vector (7 downto 0)
);
end component;

img_ram_inst : img_ram 
	port map (
		data		=> data_sig,
		rdaddress	=> rdaddress_sig,
		rdclock		=> rdclock_sig,
		wraddress	=> wraddress_sig,
		wrclock		=> wrclock_sig,
		wren		=> wren_sig,
		q			=> q_sig
	);
