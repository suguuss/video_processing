library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cam_read_tb is 
end cam_read_tb;

architecture rtl of cam_read_tb is
	component cam_read 
		port (
			pclk:			in		std_logic;
			rst_n:			in		std_logic;
			vsync:			in		std_logic;
			href:			in		std_logic;
			data:			in		std_logic_vector(7 downto 0);

			ram_wr_data:	out		std_logic_vector(7 downto 0);
			ram_wr_addr:	out		std_logic_vector(16 downto 0);
			ram_wr_en:		out		std_logic
		);
	end component;
			
			
	signal pclk:			std_logic := '0';
	signal rst_n:			std_logic := '1';
	signal vsync:			std_logic := '0';
	signal href:			std_logic := '0';
	signal data:			std_logic_vector(7 downto 0) := (others => '0');
	signal ram_wr_data:		std_logic_vector(7 downto 0) := (others => '0');
	signal ram_wr_addr:		std_logic_vector(16 downto 0) := (others => '0');
	signal ram_wr_en:		std_logic := '0';
	
begin
	
	uut: cam_read
		port map (
			pclk			=> pclk,
			rst_n			=> rst_n,
			vsync			=> vsync,
			href			=> href,
			data			=> data,
			ram_wr_data		=> ram_wr_data,
			ram_wr_addr		=> ram_wr_addr,
			ram_wr_en		=> ram_wr_en
		);


	process begin

		
		for l in 0 to 480-1 loop
			href <= '1';
			for i in 0 to 640-1 loop
				pclk <= '0';
				data <= x"ff";
				wait for 20 ns;
				
				pclk <= '1';
				wait for 20 ns;

				data <= x"00";
				pclk <= '0';
				wait for 20 ns;

				pclk <= '1';
				wait for 20 ns;
			end loop;

			href <= '0';
			for i in 0 to 144-1 loop
				pclk <= '0';
				wait for 20 ns;
				
				pclk <= '1';
				wait for 20 ns;

				pclk <= '0';
				wait for 20 ns;

				pclk <= '1';
				wait for 20 ns;
			end loop;
		
		end loop;
		
		
		report "test done";
		wait;
	end process;

end rtl;