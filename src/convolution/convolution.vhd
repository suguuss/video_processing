library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity convolution is 
	port (
		clk:		in		std_logic;
		pxl:		in		std_logic_vector(7 downto 0);
		de_in:		in		std_logic;
		hs_in:		in		std_logic;
		vs_in:		in		std_logic;
		
		new_pxl:	out		std_logic_vector(7 downto 0) := (others => '0');
		gray_out:	out		std_logic_vector(7 downto 0) := (others => '0');
		de_out:		out		std_logic := '0';
		hs_out:		out		std_logic := '0';
		vs_out:		out		std_logic := '0'
	);
end convolution;

architecture rtl of convolution is

	constant FRAME_WIDTH:	integer := 640;
	constant KERNEL_SIZE:	integer := 3;
	
	type t_kernel is array (0 to (KERNEL_SIZE*KERNEL_SIZE)-1) of integer;
	type t_fifo is array (0 to FRAME_WIDTH - KERNEL_SIZE - 1) of integer range 0 to 255;

	constant sobel_x: t_kernel := (	-1,  0,  1,
									-2,  0,  2,
									-1,  0,  1);
	
	constant sobel_y: t_kernel := (	 1,  2,  1,
									 0,  0,  0,
									-1, -2, -1);

	signal new_pxl_x:	integer := 0;
	signal new_pxl_y:	integer := 0;
	signal new_pxl_sum:	integer := 0;

	signal fifo_1:		t_fifo;
	signal fifo_2:		t_fifo;

	signal image: 		t_kernel := (0, 0, 0, 0, 0, 0, 0, 0, 0);	
	
	-- Shift registers to delay the control signals
	constant SR_SIZE:	integer := 5;
	type t_fifo_delay is array (0 to SR_SIZE) of integer range 0 to 255;
	signal fifo_gray:	t_fifo_delay;
	signal de_sr:		std_logic_vector(SR_SIZE downto 0) := (others => '0');
	signal hs_sr:		std_logic_vector(SR_SIZE downto 0) := (others => '0');
	signal vs_sr:		std_logic_vector(SR_SIZE downto 0) := (others => '0');

begin
	
	de_out <= de_sr(de_sr'high);
	hs_out <= hs_sr(hs_sr'high);
	vs_out <= vs_sr(vs_sr'high);
	gray_out <= std_logic_vector(to_unsigned(fifo_gray(fifo_gray'high), 8));
	
	shifter: process( clk )
	begin
		if rising_edge(clk) then
			if de_in = '1' then
				image(0) 	<= image(1);
				image(1) 	<= image(2);
				image(2) 	<= fifo_2(fifo_2'high);
				fifo_2 		<= image(3) & fifo_2(0 to fifo_2'high-1);
				image(3) 	<= image(4);
				image(4) 	<= image(5);
				image(5) 	<= fifo_1(fifo_1'high);
				fifo_1 		<= image(6) & fifo_1(0 to fifo_1'high-1);
				image(6) 	<= image(7);
				image(7) 	<= image(8);
				image(8) 	<= to_integer(unsigned(pxl));
				fifo_gray	<= to_integer(unsigned(pxl)) & fifo_gray(0 to fifo_gray'high-1);
			end if;
			
			de_sr 		<= de_sr(de_sr'high-1 downto 0) & de_in;
			hs_sr 		<= hs_sr(hs_sr'high-1 downto 0) & hs_in;
			vs_sr 		<= vs_sr(vs_sr'high-1 downto 0) & vs_in;

		end if;
	end process; -- shifter

	mutliplier : process( clk )
	begin
		if rising_edge(clk) then

			new_pxl_x <= 	(image(0) * sobel_x(0)) +
							(image(1) * sobel_x(1)) +
							(image(2) * sobel_x(2)) +
							(image(3) * sobel_x(3)) +
							(image(4) * sobel_x(4)) +
							(image(5) * sobel_x(5)) +
							(image(6) * sobel_x(6)) +
							(image(7) * sobel_x(7)) +
							(image(8) * sobel_x(8));
							
			new_pxl_y <= 	(image(0) * sobel_y(0)) +
							(image(1) * sobel_y(1)) +
							(image(2) * sobel_y(2)) +
							(image(3) * sobel_y(3)) +
							(image(4) * sobel_y(4)) +
							(image(5) * sobel_y(5)) +
							(image(6) * sobel_y(6)) +
							(image(7) * sobel_y(7)) +
							(image(8) * sobel_y(8));

			new_pxl_sum <= abs(new_pxl_x + new_pxl_y);

			if new_pxl_sum > 64 then
				new_pxl <= (others => '1');
			else
				new_pxl <= (others => '0');
			end if;

		end if;
	end process ; -- mutliplier

end rtl;