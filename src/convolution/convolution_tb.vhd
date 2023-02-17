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
			de_in:		in		std_logic;
			hs_in:		in		std_logic;
			vs_in:		in		std_logic;
			
			new_pxl:	out		std_logic_vector(7 downto 0) := (others => '0');
			gray_out:	out		std_logic_vector(7 downto 0) := (others => '0');
			de_out:		out		std_logic;
			hs_out:		out		std_logic;
			vs_out:		out		std_logic
		);
	end component;

	signal clk:		std_logic := '0';
	signal pxl: 	std_logic_vector(7 downto 0);

	signal conv_pxlout:	std_logic_vector(7 downto 0);
	signal de_sig:		std_logic;
	signal hs_sig:		std_logic;
	signal vs_sig:		std_logic;

	signal de_sig_delayed:		std_logic;
	signal hs_sig_delayed:		std_logic;
	signal vs_sig_delayed:		std_logic;
	signal gray_delayed:		std_logic_vector(7 downto 0);
begin

	uut: convolution
		port map (
			clk 	=> clk,
			pxl 	=> pxl,
			de_in	=> de_sig,
			hs_in	=> hs_sig,
			vs_in	=> vs_sig,

			new_pxl => conv_pxlout,
			gray_out=> gray_delayed, 
			de_out	=> de_sig_delayed,
			hs_out	=> hs_sig_delayed,
			vs_out	=> vs_sig_delayed
		);

	de_sig <= (not vs_sig) and (not hs_sig);
	
	process begin
	
		vs_sig <= '1';
		hs_sig <= '1';

		
		for vc in 0 to 525 loop

			for hc in 0 to 800 loop

				-- simplified signal generation
				if hc < 640 then
					hs_sig <= '0';
				else
					hs_sig <= '1';
				end if;
				-- simplified signal generation
				if vc < 480 then
					vs_sig <= '0';
				else
					vs_sig <= '1';
				end if;
					
				if hc > 0 and hc < 11 and vc > 0 and vc < 11 then
					pxl <= x"AA";
				else
					pxl <= x"00";
				end if;

				clk <= '0'; wait for 1 us;
				clk <= '1'; wait for 1 us;
				
			end loop;

		end loop;
		

		report "test done";
		wait;

	end process;


end rtl;