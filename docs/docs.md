# Introduction

# HDMI Driver

To display the ouput of the camera on the screen, I'm going to use the HDMI TX Connector present on the development board. The HDMI is controlled by a transmitter chip that translates VGA style data to HDMI data. The chip is the **ADV7513** ([datasheet](https://www.analog.com/media/en/technical-documentation/data-sheets/adv7513.pdf) and [User Manual](https://www.analog.com/media/en/technical-documentation/user-guides/adv7513_hardware_user_guide.pdf)).


## Getting the informations

Controlling a display using VGA data is not that hard. There are only 3 control signals (Data Enable, Horizontal Sync, Vertical Sync) and the RGB data. The figure below shows how the vertical and horizontal sync signals are used. In this figure, the polarity of the signals is active low, but it can be active high sometimes.

![vga_timings](/docs/assets/vga_timings.jpg)


To get the correct timings, I used this [Video Timings Calculator](https://tomverbeure.github.io/video_timings_calculator). You can select any resolution and refresh rate, and it will give you all the informations needed. In the example below, I choose a 1080p resolution with a 60Hz refresh rate. The information that we need are in the column **CEA-861**. 

![calculator](/docs/assets/calculator.jpg)

## VHDL implementation

The HDMI transmitter has to be configured using I2C. The code is not covered here, because I did not write it. It came with some example projets with the dev board. However, you can find the code in the `src/HDMI` folder.


![hdmi_entity](/docs/assets/hdmi_entity.jpg)

The entity of the HDMI driver is represented by the following VHDL code. The default values in the generic are for a 1080p resolution. 

```vhdl
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
		de:			out		std_logic;
		vs:			out		std_logic;
		hs:			out		std_logic;
		r:			out		std_logic_vector(7 downto 0);
		g:			out		std_logic_vector(7 downto 0);
		b:			out		std_logic_vector(7 downto 0)
	);
end HDMI_TX;
```

The architecture of the controller is made of 3 processes. One for the vertical sync, one for the horizontal sync and one for the data. When testing the driver, the data was either a full color or some random patterns.

```vhdl
architecture behavioral of HDMI_TX is

	signal h_count: integer 	:= 0;
	signal v_count: integer 	:= 0;
	
	signal h_act:	std_logic 	:= '0';
	signal v_act:	std_logic 	:= '0';

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
	
	
	frame_gen: process(clk)
	begin
		if rising_edge(clk) then
			if h_act = '1' and v_act = '1' then
				de <= '1';
				r <= std_logic_vector(to_unsigned(h_count, 12))(9 downto 2);
				g <= std_logic_vector(to_unsigned(v_count, 12))(9 downto 2);
				b <= std_logic_vector(to_unsigned(h_count, 12))(9 downto 2);
			else
				de <= '0';
				r <= (others => '0');
				g <= (others => '0');
				b <= (others => '0');
			end if;
		end if;
	end process; -- end frame_gen

end behavioral ; -- behavioral
```


# RGB to grayscale converter

I decided to convert the RGB video stream coming from the camera to a grayscale stream. There are two reasons to this. 

1. I don't need the colors when doing edge detections (with the Sobel or Laplacian kernel).
2. There a less data to handle when using grayscale.

To do the conversion, I searched for an efficient way to convert RGB to Gray on FPGA. I found [this paper](https://www.sciencedirect.com/science/article/pii/S187705092031200X?ref=cra_js_challenge&fr=RR-1), and decided to implement it. They explain in the paper that the gray value of a pixel is composed of 28.1% of red, 56.2% of green and 9.3% of blue, this is used in the "rgb2gray" function in MATLAB.

This is the block diagram of the proposed technique.

![rgb2gray](/docs/assets/rgb2gray.jpg)


## VHDL Implementation

![grayentity](/docs/assets/gray_entity.jpg)

```vhdl
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
```

## Simulating the design

To verify that I implemented correctly the design, I simulated it with [ghdl](https://github.com/ghdl/ghdl), and checked the waveform using [GTKWave](https://github.com/gtkwave/gtkwave). I wrote a very basic testbench and tested the conversion. In the paper they give an example conversion with the following values : 

- R : `b11010110`
- G : `b11111110`
- B : `b01011100`

They also give the intermediate R1 and R2 values (values after shifting the bits). The result of this conversion is : `b11010000`.

![graysim](/docs/assets/gray_simulation.jpg)

We can see in the simulation that I have the same result as the one in the example given in the paper. I also tested another value and verified it by doing the calculations by hand using python.

