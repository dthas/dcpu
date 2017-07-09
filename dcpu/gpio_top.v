`include "defines.v"

module	gpio_top(
		input	wire				clk,
		input	wire				rst,

		input	wire				cs,
		input	wire				as,
		input	wire				rw,
		input	wire	[`GpioAddrBus]		addr,		
		input	wire	[`WordDataBus]		wr_data,
		output	reg	[`WordDataBus]		rd_data,
		output	reg										rdy,
		input	wire	[`Num16-1:0]	gpio_in,
		output	reg	[`Num32-1:0]	gpio_out
		);

	
	//===========================================================================
	// timer control
	//===========================================================================
	always @(posedge clk) begin
		if(rst == `RstEnable) begin
			rd_data		= `WORD_DATA_W'h0;
			rdy				= `NO;
			gpio_out	= `ZeroWord;
			
		end else begin
			//-----------------------------------------------------------------------------
			// build ready signal
			//-----------------------------------------------------------------------------
			if((cs == `YES) && (as == `YES)) begin
				rdy		= `YES;
			end else begin
				rdy		= `NO;
			end

			//-----------------------------------------------------------------------------
			// read access
			//-----------------------------------------------------------------------------
			if((cs == `YES) && (as == `YES) && (rw == `READ)) begin
				rd_data		= gpio_in;					
			end else begin
				rd_data		= `WORD_DATA_W'h0;
			end

			//-----------------------------------------------------------------------------
			// write access
			//-----------------------------------------------------------------------------			
			if((cs == `YES) && (as == `YES) && (rw == `WRITE) ) begin				
				gpio_out	= wr_data[`Num32-1:0];					
			end			
			
		end
	end
	

endmodule
