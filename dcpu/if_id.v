`include "defines.v"

module	if_id(
	input		wire									clk,
	input		wire									rst,
	
	input		wire[5:0]							stall,
	
	//--------------------------------------
	//add on 2015-12-19
	input wire                    	flush,
	//--------------------------------------
	
	input		wire[`InstAddrBus]		if_pc,
	input		wire[`InstBus]				if_inst,
	
	output	reg[`InstAddrBus]			id_pc,
	output	reg[`InstBus]					id_inst
);

	always	@ (posedge	clk)	begin
		if(rst == `RstEnable) begin
			id_pc <= `ZeroWord;
			id_inst <= `ZeroWord;
		//----------------------------------------------
		//add on 2015-12-19
		end else if(flush == 1'b1 ) begin
			id_pc <= `ZeroWord;
			id_inst <= `ZeroWord;	
		//----------------------------------------------
		end else if(stall[1] == `Stop && stall[2] == `NoStop) begin
			id_pc		<=	`ZeroWord;
			id_inst	<=	`ZeroWord;
		end else if(stall[1] == `NoStop) begin
			id_pc <= if_pc;
			id_inst <= if_inst;
		
		/*
		//modi on 2015-11-14	
		//add on 2015-10-3
		end else begin
			id_pc <= if_pc;
			id_inst <= if_inst;
		*/
		
		end
	end

endmodule