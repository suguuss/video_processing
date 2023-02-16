// Taken from the HDMI config


module I2C_CAM_Config (	//	Host Side
		iCLK,
		iRST_N,
		//	I2C Side
		I2C_SCLK,
		I2C_SDAT,
	);
//	Host Side
input		iCLK;
input		iRST_N;
//	I2C Side
output		I2C_SCLK;
inout		I2C_SDAT;

//	Internal Registers/Wires
reg	[15:0]	mI2C_CLK_DIV;
reg	[23:0]	mI2C_DATA;
reg			mI2C_CTRL_CLK;
reg			mI2C_GO;
wire		mI2C_END;
wire		mI2C_ACK;
reg	[15:0]	LUT_DATA;
reg	[5:0]	LUT_INDEX;
reg	[3:0]	mSetup_ST;

//	Clock Setting
parameter	CLK_Freq	=	50000000;	//	50	MHz
parameter	I2C_Freq	=	50000;		//	50	KHz
//	LUT Data Number
parameter	LUT_SIZE	=	17;

/////////////////////	I2C Control Clock	////////////////////////
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		mI2C_CTRL_CLK	<=	0;
		mI2C_CLK_DIV	<=	0;
	end
	else
	begin
		if( mI2C_CLK_DIV	< (CLK_Freq/I2C_Freq) )
			mI2C_CLK_DIV	<=	mI2C_CLK_DIV+1;
		else
		begin
			mI2C_CLK_DIV	<=	0;
			mI2C_CTRL_CLK	<=	~mI2C_CTRL_CLK;
		end
	end
end
////////////////////////////////////////////////////////////////////
I2C_Controller 	u0	(	.CLOCK(mI2C_CTRL_CLK),			//	Controller Work Clock
						.I2C_SCLK(I2C_SCLK),			//	I2C CLOCK
 	 	 	 	 	 	.I2C_SDAT(I2C_SDAT),			//	I2C DATA
						.I2C_DATA(mI2C_DATA),			//	DATA:[SLAVE_ADDR,SUB_ADDR,DATA]
						.GO(mI2C_GO),					//	GO transfor
						.END(mI2C_END),					//	END transfor 
						.ACK(mI2C_ACK),					//	ACK
						.RESET(iRST_N)	);
////////////////////////////////////////////////////////////////////
//////////////////////	Config Control	////////////////////////////
always@(posedge mI2C_CTRL_CLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		LUT_INDEX	<=	0;
		mSetup_ST	<=	0;
		mI2C_GO		<=	0;
	end
	else
	begin
		if(LUT_INDEX<LUT_SIZE)
		begin
			case(mSetup_ST)
			0:	begin
					mI2C_DATA	<=	{8'h42,LUT_DATA};
					mI2C_GO		<=	1;
					mSetup_ST	<=	1;
				end
			1:	begin
					if(mI2C_END)
					begin
						if(!mI2C_ACK)
						mSetup_ST	<=	2;
						else
						mSetup_ST	<=	0;							
						mI2C_GO		<=	0;
					end
				end
			2:	begin
					LUT_INDEX	<=	LUT_INDEX+1;
					mSetup_ST	<=	0;
				end
			endcase
		end
		else
		begin
			LUT_INDEX <= LUT_INDEX;
		end
	end
end
////////////////////////////////////////////////////////////////////
/////////////////////	Config Data LUT	  //////////////////////////	
always
begin
	case(LUT_INDEX)
	
	//	Video Config Data
	0	:	LUT_DATA	<=	16'h1280; // Reset all registers to default values
	1	:	LUT_DATA	<=	16'h1280; // Reset all registers to default values
	2	:	LUT_DATA	<=	16'h1204; // Select RGB mode
	3	:	LUT_DATA	<=	16'h703A; // Select test pattern
	4	:	LUT_DATA	<=	16'h71B5; // Select test pattern
	5   :       LUT_DATA        <=      16'h1204;
	6       :       LUT_DATA        <=      16'h8c00;
	7       :       LUT_DATA        <=      16'h0400;
	8       :       LUT_DATA        <=      16'h40d0;
	9       :       LUT_DATA        <=      16'h146a;
	10      :       LUT_DATA        <=      16'h4fb3;
	11      :       LUT_DATA        <=      16'h50b3;
	12      :       LUT_DATA        <=      16'h5100;
	13      :       LUT_DATA        <=      16'h523d;
	14      :       LUT_DATA        <=      16'h53a7;
	15      :       LUT_DATA        <=      16'h54e4;
	16      :       LUT_DATA        <=      16'h3d40;
//	5	:	LUT_DATA	<=	16'h32B6; 
//	6	:	LUT_DATA	<=	16'h1713; 
//	7	:	LUT_DATA	<=	16'h1801; 
//	8	:	LUT_DATA	<=	16'h1902; 
//	9	:	LUT_DATA	<=	16'h1A7A; 
//	10	:	LUT_DATA	<=	16'h030A; 
	default:		LUT_DATA	<=	16'h1280;
	endcase
end
////////////////////////////////////////////////////////////////////
endmodule 