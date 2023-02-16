library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- DATASHEET USED : http://web.mit.edu/6.111/www/f2016/tools/OV7670_2006.pdf

entity cam_read is 
	port (
		pclk:			in		std_logic;
		rst_n:			in		std_logic;
		vsync:			in		std_logic;
		href:			in		std_logic;
		data:			in		std_logic_vector(7 downto 0);

		ram_wr_data:	out		std_logic_vector(15 downto 0)  := (others => '0');
		ram_wr_addr:	out		std_logic_vector(16 downto 0) := (others => '0');
		ram_wr_en:		out		std_logic := '0'
	);
end cam_read;

architecture rtl of cam_read is

	signal h_count:	integer := 0;
	signal v_count:	integer := 0;
	signal incr:	integer := 0;
	signal r:		std_logic_vector(4 downto 0) := (others => '0');
	signal g:		std_logic_vector(5 downto 0) := (others => '0');
	signal b:		std_logic_vector(4 downto 0) := (others => '0');

begin
	
	horizontal : process( pclk, rst_n )
	begin
		if rst_n = '0' then
			h_count <= 0;
			incr <= 0;
		else

			if rising_edge(pclk) then
				if href = '0' then
					h_count <= 0;
				else
					if incr = 0 then
						incr <= 1;
						
						g(2 downto 0) <= data(7 downto 5);
						b <= data(4 downto 0);
					else
						incr <= 0;
						h_count <= h_count + 1;
						
						r <= data(7 downto 3);
						g(5 downto 3) <= data(2 downto 0);
					end if;
				end if;
			end if;

		end if;
	end process ; -- horizontal


	vertical : process( href, rst_n )
	begin
		if rst_n = '0' then
			v_count <= 0;
		else

			if vsync = '1' then
				v_count <= 0;
			else
				if falling_edge(href) then
					v_count <= v_count + 1;
				end if;
			end if;

		end if;
	end process ; -- vertical


	ram_wr_addr <= std_logic_vector(to_unsigned((v_count/2) * 320 + (h_count/2), 17));
	
	-- ram_wr_data <= r & "000";
	ram_wr_data <= r(4 downto 0) & g(5 downto 0) & b(4 downto 0);
	-- ram_wr_data <= x"ffff";
	
	
	data_proc : process( pclk )
	begin
		if falling_edge(pclk) then
			if href = '1' and vsync = '0' and incr = 1 then
				ram_wr_en <= '1';
			else 
				ram_wr_en <= '0';
			end if;
		end if;
	end process ; -- data
end rtl;