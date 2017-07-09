 `include "defines.v"

module	bus_ctrl(
	input		wire									clk,
	input		wire									rst,
	
	input		wire									m0_req,
	input		wire									m1_req,
	input		wire									m2_req,
	input		wire									m3_req,	
	
	output	reg										m0_get,
	output	reg										m1_get,
	output	reg										m2_get,
	output	reg										m3_get
	
);

	reg owner;
	
	always	@ (*)	begin
		m0_get	= `NO;
		m1_get	= `NO;
		m2_get	= `NO;
		m3_get	= `NO;
		
		case(owner)
			`MASTER_0	:	begin
						m0_get	= `YES;
			end
			
			`MASTER_1	:	begin
						m1_get	= `YES;
			end
			
			`MASTER_2	:	begin
						m2_get	= `YES;
			end
			
			`MASTER_3	:	begin
						m3_get	= `YES;
			end
		endcase
		
	end
	
	
	
	
	always	@ (posedge	clk)	begin
		if(rst == `RstEnable) begin
				owner		= `MASTER_0;
		end else begin
				case(owner)
					`MASTER_0	:	begin
							if(m0_req == `YES) begin
								owner	= `MASTER_0;
							end else if(m1_req	== `YES) begin
								owner	= `MASTER_1;
							end else if(m2_req	== `YES) begin
								owner	= `MASTER_2;
							end else if(m3_req	== `YES) begin
								owner	= `MASTER_3;
							end
					end
					
					`MASTER_1	:	begin
							if(m1_req	== `YES) begin
								owner	= `MASTER_1;
							end else if(m2_req	== `YES) begin
								owner	= `MASTER_2;
							end else if(m3_req	== `YES) begin
								owner	= `MASTER_3;
							end else if(m0_req == `YES) begin
								owner	= `MASTER_0;							
							end
					end
					
					`MASTER_2	:	begin
							if(m2_req	== `YES) begin
								owner	= `MASTER_2;
							end else if(m3_req	== `YES) begin
								owner	= `MASTER_3;
							end else if(m0_req == `YES) begin
								owner	= `MASTER_0;
							end else if(m1_req	== `YES) begin
								owner	= `MASTER_1;													
							end
					end
					
					`MASTER_3	:	begin
							if(m3_req	== `YES) begin
								owner	= `MASTER_3;
							end else if(m0_req == `YES) begin
								owner	= `MASTER_0;
							end else if(m1_req	== `YES) begin
								owner	= `MASTER_1;
							end else if(m2_req	== `YES) begin
								owner	= `MASTER_2;																			
							end
					end
					
				endcase
			
		end
	end

endmodule