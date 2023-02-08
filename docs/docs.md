# Introduction

# HDMI Driver

To display the ouput of the camera on the screen, I'm going to use the HDMI TX Connector present on the development board. The HDMI is controlled by a transmitter chip that translates VGA style data to HDMI data. The chip is the **ADV7513** ([datasheet](https://www.analog.com/media/en/technical-documentation/data-sheets/adv7513.pdf) and [User Manual](https://www.analog.com/media/en/technical-documentation/user-guides/adv7513_hardware_user_guide.pdf)).


## Getting the informations

Controlling a display using VGA data is not that hard. There are only 3 control signals (Data Enable, Horizontal Sync, Vertical Sync) and the RGB data. The figure below shows how the vertical and horizontal sync signals are used. In this figure, the polarity of the signals is active low, but it can be active high sometimes.

![vga_timings](/docs/assets/vga_timings.jpg)


To get the correct timings, I used this [Video Timings Calculator](https://tomverbeure.github.io/video_timings_calculator). You can select any resolution and refresh rate, and it will give you all the informations needed. In the example below, I choose a 1080p resolution with a 60Hz refresh rate. The information that we need are in the column **CEA-861**. 

![calculator](/docs/assets/calculator.jpg)

## VHDL

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
