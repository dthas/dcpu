`include "defines.v"

module	ctrl(
	input		wire						rst,
	input		wire						stallreq_from_id,
	input		wire						stallreq_from_ex,
	
	//-----------------------------------------------------
	//add on 2015-12-11
	input wire              stallreq_from_if,
	input wire              stallreq_from_mem,
	//-----------------------------------------------------
	
	//-----------------------------------------------------
	//modi on 2015-12-22
	//input		wire						stallreq_to_id,
	//-----------------------------------------------------
	
	// stallreq_from_fetchinst	= 6'b000011
	input		wire						stallreq_from_fi,
	
	output	reg[5:0]				stall
);

	always	@ (*)	begin
		if(rst == `RstEnable) begin
			stall	= 6'b000000;
		end else if(stallreq_from_ex == `Stop) begin
			stall	= 6'b001111;			
		end else if(stallreq_from_id == `Stop) begin
			stall	= 6'b000111;			
		end else if(stallreq_from_fi == `Stop) begin
			stall	= 6'b000011;	
			//stall	= 6'b000111;		
		//---------------------------------------------------
		// add on 2015-12-11
		end else if(stallreq_from_mem == `Stop) begin
			stall = 6'b011111;			
		end else if(stallreq_from_if == `Stop) begin
			//---------------------------------------------------
			// modi on 2015-12-26
			// just for test
			stall = 6'b000111;
			//stall = 6'b000000;			
			//---------------------------------------------------
		//---------------------------------------------------
		// modi on 2015-12-22
		/*
		end else if(stallreq_to_id == `Stop) begin
			stall	= 6'b111000;	
		*/
		//---------------------------------------------------				
		end else begin
			stall	= 6'b000000;		
		end	
	end

endmodule