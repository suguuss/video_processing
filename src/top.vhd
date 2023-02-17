library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
  port (
	-- CLOCK 
	ADC_CLK_10:			in		std_logic;
	MAX10_CLK1_50:		in		std_logic;
	MAX10_CLK2_50:		in		std_logic;

	-- KEY 
	KEY:				in		std_logic_vector(1 downto 0);

	-- LED 
	LED:				out		std_logic_vector(7 downto 0) := x"ff";

	-- HDMI-TX
	HDMI_I2C_SCL:		inout	std_logic;
	HDMI_I2C_SDA:		inout	std_logic;
	HDMI_I2S:			inout	std_logic_vector(3 downto 0);
	HDMI_LRCLK:			inout	std_logic;
	HDMI_MCLK:			inout	std_logic;
	HDMI_SCLK:			inout	std_logic;
	HDMI_TX_CLK:		out		std_logic;
	HDMI_TX_D:			out		std_logic_vector(23 downto 0);
	HDMI_TX_DE:			out		std_logic;
	HDMI_TX_HS:			out		std_logic;
	HDMI_TX_INT:		in		std_logic;
	HDMI_TX_VS:			out		std_logic;

	-- SW 
	SW:					in		std_logic_vector(1 downto 0);

	-- BBB Conector 
	BBB_PWR_BUT: 		in		std_logic;
	BBB_SYS_RESET_n: 	in		std_logic;
	GPIO0_D: 			inout 	std_logic_vector(43 downto 0);
	GPIO1_D: 			inout 	std_logic_vector(22 downto 0)
  ) ;
end top;

architecture behavioral of top is

	component pll_pxlclk
		port (
			inclk0		: in	std_logic := '0';
			c0			: out	std_logic 
		);
	end component;
	
	component pll_cam
		port (
			inclk0		: in	std_logic := '0';
			c0			: out	std_logic 
		);
	end component;
	
	component HDMI_TX
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
			b:			out		std_logic_vector(7 downto 0);
			
			ram_data:	in		std_logic_vector(15 downto 0);
			ram_addr:	out		std_logic_vector(16 downto 0)
		);
	end component;
	
	component I2C_HDMI_Config
		port (
			iCLK:		in		std_logic;
			iRST_N:		in		std_logic;
			I2C_SCLK:	out		std_logic;
			I2C_SDAT:	inout	std_logic;
			HDMI_TX_INT:in		std_logic
		);
	end component;
	
	component full_ram
		port (
			data		:	in 		std_logic_vector (15 downto 0);
			rdaddress	:	in 		std_logic_vector (16 downto 0);
			rdclock		:	in 		std_logic;
			wraddress	:	in 		std_logic_vector (16 downto 0);
			wrclock		:	in 		std_logic := '1';
			wren		:	in 		std_logic := '0';
			q			:	out 	std_logic_vector (15 downto 0)
		);
	end component;
	
	component cam_read 
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
	end component;
	
	component I2C_CAM_Config
		port (
			iCLK:		in		std_logic;
			iRST_N:		in		std_logic;
			I2C_SCLK:	out		std_logic;
			I2C_SDAT:	inout	std_logic
		);
	end component;

	component rgbgray
		port (
			r:			in		std_logic_vector(7 downto 0);
			g:			in		std_logic_vector(7 downto 0);
			b:			in		std_logic_vector(7 downto 0);
			
			gray:		out		std_logic_vector(7 downto 0)
		);
	end component;
	
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

	signal pxl_clk:			std_logic;
	signal reset_n:			std_logic;
	
	signal ram_rd_data:		std_logic_vector(15 downto 0);
	signal ram_rd_addr:		std_logic_vector(16 downto 0);
	signal ram_wr_data:		std_logic_vector(15 downto 0);
	signal ram_wr_addr:		std_logic_vector(16 downto 0);
	signal ram_wren:		std_logic;
	
	signal gray:		std_logic_vector(7 downto 0);
	signal r_sig:		std_logic_vector(7 downto 0);
	signal g_sig:		std_logic_vector(7 downto 0);
	signal b_sig:		std_logic_vector(7 downto 0);
	
	signal conv_pxlout:	std_logic_vector(7 downto 0);
	signal de_sig:		std_logic;
	signal hs_sig:		std_logic;
	signal vs_sig:		std_logic;

	signal de_sig_delayed:		std_logic;
	signal hs_sig_delayed:		std_logic;
	signal vs_sig_delayed:		std_logic;
	signal gray_delayed:		std_logic_vector(7 downto 0);
begin
	
	reset_n <= KEY(1);
	
	
	-- 148.5   MHz for 1080p 60Hz
	-- 74.25   MHz for 1080p 30Hz
	-- 12.5875 MHz for 640x480 30 Hz
	-- 25.1750 MHz for 640x480 60 Hz
	Inst_pixel_pll: pll_pxlclk
		port map(
			inclk0 	=> MAX10_CLK1_50,
			c0 		=> pxl_clk
		);
			
	Inst_hdmi_conf: I2C_HDMI_Config 
		port map (
			iCLK 		=> MAX10_CLK2_50,
			iRST_N 		=> reset_n,		
			I2C_SCLK 	=> HDMI_I2C_SCL,
			I2C_SDAT 	=> HDMI_I2C_SDA,
			HDMI_TX_INT => HDMI_TX_INT
		);
	
	Inst_hdmi: HDMI_TX 
		generic map (
			h_total		=>  800,
			h_active	=>  640,
			h_front		=>   16,
			h_sync		=>   96,
			h_back		=>   48,

			v_total		=>  525,
			v_active	=>  480,
			v_front		=>   10,
			v_sync		=>    3,
			v_back		=>   33
		)
		port map (
			clk 		=> pxl_clk,
			rst_n 		=> reset_n,
			de 			=> de_sig,
			hs 			=> hs_sig,
			vs 			=> vs_sig,
			r 			=> r_sig,
			g 			=> g_sig,
			b 			=> b_sig,
			
			ram_data 	=> ram_rd_data,
			ram_addr	=> ram_rd_addr
		);

	HDMI_TX_CLK <= not pxl_clk;

		
	Inst_ram: full_ram 
		port map (
			wraddress	=> ram_wr_addr,
			wrclock		=> GPIO1_D(8),
			wren		=> ram_wren,
			data		=> ram_wr_data,

			rdaddress	=> ram_rd_addr,
			rdclock		=> pxl_clk,
			q			=> ram_rd_data
		);
		

	-- 24 MHz	
	Inst_cam_pll: pll_cam
		port map(
			inclk0 	=> MAX10_CLK1_50,
			c0 		=> GPIO1_D(20)
		);
		
	GPIO1_D(9) <= reset_n;
		
	Inst_cam: cam_read
		port map (
			pclk			=> GPIO1_D(8),
			rst_n			=> reset_n,
			vsync			=> GPIO1_D(10),
			href			=> GPIO1_D(11),
			data			=> GPIO1_D(19 downto 12),

			ram_wr_data		=> ram_wr_data,
			ram_wr_addr		=> ram_wr_addr,
			ram_wr_en		=> ram_wren
		);
	
	Inst_Cam_conf: I2C_CAM_Config 
		port map (
			iCLK 		=> MAX10_CLK2_50,
			iRST_N 		=> reset_n,		
			I2C_SCLK 	=> GPIO1_D(7),
			I2C_SDAT 	=> GPIO1_D(6)
		);
		
		
	Inst_gray_conversion: rgbgray
		port map (
			r => r_sig,
			g => g_sig,
			b => b_sig,
			gray => gray
		);
		
	Inst_convolution: convolution
		port map (
			clk 	=> pxl_clk,
			pxl 	=> gray,
			de_in	=> de_sig,
			hs_in	=> hs_sig,
			vs_in	=> vs_sig,

			new_pxl => conv_pxlout,
			gray_out=> gray_delayed, 
			de_out	=> de_sig_delayed,
			hs_out	=> hs_sig_delayed,
			vs_out	=> vs_sig_delayed
		);
		
		
	rgb_mux : process( r_sig, g_sig, b_sig, SW )
	begin
		case( SW ) is
		
			when "00" => -- Grayscale image
				HDMI_TX_D(23 downto 16)	<= gray;
				HDMI_TX_D(15 downto 8)	<= gray;
				HDMI_TX_D(7 downto 0)	<= gray;
				HDMI_TX_DE <= de_sig;
				HDMI_TX_HS <= hs_sig;
				HDMI_TX_VS <= vs_sig;
			when "10" => -- convolution output
				HDMI_TX_D(23 downto 16)	<= conv_pxlout;
				HDMI_TX_D(15 downto 8)	<= conv_pxlout;
				HDMI_TX_D(7 downto 0)	<= conv_pxlout;
				HDMI_TX_DE <= de_sig_delayed;
				HDMI_TX_HS <= hs_sig_delayed;
				HDMI_TX_VS <= vs_sig_delayed;
			when "11" => -- convolution output + gray
				HDMI_TX_D(23 downto 16)	<= conv_pxlout or gray_delayed;
				HDMI_TX_D(15 downto 8)	<= conv_pxlout or gray_delayed;
				HDMI_TX_D(7 downto 0)	<= conv_pxlout or gray_delayed;
				HDMI_TX_DE <= de_sig_delayed;
				HDMI_TX_HS <= hs_sig_delayed;
				HDMI_TX_VS <= vs_sig_delayed;
			when others => -- RGB image
				HDMI_TX_D(23 downto 16)	<= r_sig;
				HDMI_TX_D(15 downto 8)	<= g_sig;
				HDMI_TX_D(7 downto 0)	<= b_sig;
				HDMI_TX_DE <= de_sig;
				HDMI_TX_HS <= hs_sig;
				HDMI_TX_VS <= vs_sig;
		
		end case ;
	end process ; -- rgb_mux
		
end behavioral ; -- behavioral



























