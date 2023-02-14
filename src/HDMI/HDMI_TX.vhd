library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity HDMI_TX is
	generic (
		h_total: 	integer := 2200;
		h_front: 	integer :=   88;
		h_sync: 	integer :=   44;
		h_back: 	integer :=  148;
		h_active: 	integer := 1920;

		v_total: 	integer := 1125;
		v_front: 	integer :=    4;
		v_sync: 	integer :=    5;
		v_back: 	integer :=   36;
		v_active: 	integer := 1080
	);

	port (
		clk:		in		std_logic;
		rst_n:		in		std_logic;
		color:		in		std_logic;
		de:			out		std_logic;
		vs:			out		std_logic;
		hs:			out		std_logic;
		r:			out		std_logic_vector(7 downto 0);
		g:			out		std_logic_vector(7 downto 0);
		b:			out		std_logic_vector(7 downto 0)
	);
end HDMI_TX;

architecture behavioral of HDMI_TX is

	component rgbgray
		port (
			r:			in		std_logic_vector(7 downto 0);
			g:			in		std_logic_vector(7 downto 0);
			b:			in		std_logic_vector(7 downto 0);
			
			gray:		out		std_logic_vector(7 downto 0)
		);
	end component;

	signal h_count: integer 	:= 0;
	signal v_count: integer 	:= 0;
	
	signal h_act:	std_logic 	:= '0';
	signal v_act:	std_logic 	:= '0';
	
	signal gray:	std_logic_vector(7 downto 0);
	signal r_sig:	std_logic_vector(7 downto 0);
	signal g_sig:	std_logic_vector(7 downto 0);
	signal b_sig:	std_logic_vector(7 downto 0);

begin

	-- VGA controls

	h_ctrl: process(clk)
	begin
		if rising_edge(clk) then
			if rst_n = '0' then
				h_count <= 0;
				hs <= '0';
				h_act <= '0';
			else
				
				-- Counter
				if h_count = (h_total - 1) then
					h_count <= 0;
				else
					h_count <= h_count + 1;
				end if;
				
				-- sync and active signals handler
				if h_count < h_active then
					h_act <= '1';
					hs <= '0';
				elsif h_count < (h_active + h_front) then
					h_act <= '0';
					hs <= '0';
				elsif h_count < (h_active + h_front + h_sync) then
					h_act <= '0';
					hs <= '1';
				else
					h_act <= '0';
					hs <= '0';
				end if;
					
			end if;
		end if;
	end process; -- end h_ctrl
	
	
	v_ctrl: process(clk)
	begin
		if rising_edge(clk) then
			if rst_n = '0' then
				v_count <= 0;
				vs <= '0';
				v_act <= '0';
			else
				
				-- Counter
				if h_count = (h_total - 1) then
					if v_count = (v_total - 1) then
						v_count <= 0;
					else
						v_count <= v_count + 1;
					end if;
				end if;
				
				-- sync and active signals handler
				if v_count < v_active then
					v_act <= '1';
					vs <= '0';
				elsif v_count < (v_active + v_front) then
					v_act <= '0';
					vs <= '0';
				elsif v_count < (v_active + v_front + v_sync) then
					v_act <= '0';
					vs <= '1';
				else
					v_act <= '0';
					vs <= '0';
				end if;
			
			end if;
		end if;
	end process; -- end v_ctrl
	
	
	gray1: rgbgray
		port map (
			r => r_sig,
			g => g_sig,
			b => b_sig,
			gray => gray
		);
	
	frame_gen: process(clk)
	begin
		if rising_edge(clk) then
			if h_act = '1' and v_act = '1' then
				de <= '1';
				
--				if h_count < 960 then
--					r_sig <= x"00";
--					g_sig <= x"FF";
--					b_sig <= x"00";
--				else 
--					r_sig <= x"00";
--					g_sig <= x"00";
--					b_sig <= x"FF";
--				end if;
				r_sig <= std_logic_vector(to_unsigned(h_count, 12))(8 downto 1);
				g_sig <= std_logic_vector(to_unsigned(v_count, 12))(8 downto 1);
				b_sig <= std_logic_vector(to_unsigned(h_count, 12))(8 downto 1);
				
				if color = '0' then
					r <= r_sig;
					g <= g_sig;
					b <= b_sig;
				else
					r <= gray;
					g <= gray;
					b <= gray;
				end if;
				
				
			else
				de <= '0';
				r <= (others => '0');
				g <= (others => '0');
				b <= (others => '0');
			end if;
		end if;
	end process; -- end frame_gen

end behavioral ; -- behavioral































