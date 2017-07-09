 `include "defines.v"

module	bus_dec(
	input		wire[`WordAddrBus]		s_addr,
	
	output	reg										s0_cs,
	output	reg										s1_cs,
	output	reg										s2_cs,
	output	reg										s3_cs,
	output	reg										s4_cs,
	output	reg										s5_cs,
	output	reg										s6_cs,
	output	reg										s7_cs
);
	
	//取bus的最高3位作为索引
	//wire[2:0]	s_index	= s_addr[29:27];
	wire[2:0]	s_index	= s_addr[31:29];
	
	always	@ (*)	begin
		
		s0_cs		= `NO;
		s1_cs		= `NO;
		s2_cs		= `NO;
		s3_cs		= `NO;
		s4_cs		= `NO;
		s5_cs		= `NO;
		s6_cs		= `NO;
		s7_cs		= `NO;
		
		case(s_index)
				`SLAVE_0	:	begin
								s0_cs  = `YES;
				end
				
				`SLAVE_1	:	begin
								s1_cs  = `YES;
				end
				
				`SLAVE_2	:	begin
								s2_cs  = `YES;
				end
				
				`SLAVE_3	:	begin
								s3_cs  = `YES;
				end
				
				`SLAVE_4	:	begin
								s4_cs  = `YES;
				end
				
				`SLAVE_5	:	begin
								s5_cs  = `YES;
				end
				
				`SLAVE_6	:	begin
								s6_cs  = `YES;
				end
				
				`SLAVE_7	:	begin
								s7_cs  = `YES;
				end
				
		endcase
		
	end

endmodule