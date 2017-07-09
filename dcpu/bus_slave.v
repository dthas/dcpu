 `include "defines.v"

module	bus_slave(
	input		wire									s0_cs,
	input		wire									s0_ready,
	input		wire[`WordDataBus]		s0_data_i,
	
	input		wire									s1_cs,
	input		wire									s1_ready,
	input		wire[`WordDataBus]		s1_data_i,
	
	input		wire									s2_cs,
	input		wire									s2_ready,
	input		wire[`WordDataBus]		s2_data_i,
	
	input		wire									s3_cs,
	input		wire									s3_ready,
	input		wire[`WordDataBus]		s3_data_i,
	
	input		wire									s4_cs,
	input		wire									s4_ready,
	input		wire[`WordDataBus]		s4_data_i,
	
	input		wire									s5_cs,
	input		wire									s5_ready,
	input		wire[`WordDataBus]		s5_data_i,
	
	input		wire									s6_cs,
	input		wire									s6_ready,
	input		wire[`WordDataBus]		s6_data_i,
	
	input		wire									s7_cs,
	input		wire									s7_ready,
	input		wire[`WordDataBus]		s7_data_i,
	
	output	reg										s_ready,
	output	reg[`WordDataBus]			s_data_o	
);


	always	@ (*)	begin
		if(s0_cs == `YES) begin
			s_ready		= s0_ready;
			s_data_o	= s0_data_i;
		end else if(s1_cs == `YES) begin
			s_ready		= s1_ready;
			s_data_o	= s1_data_i;
		end else if(s2_cs == `YES) begin
			s_ready		= s2_ready;
			s_data_o	= s2_data_i;
		end else if(s3_cs == `YES) begin
			s_ready		= s3_ready;
			s_data_o	= s3_data_i;
		end else if(s4_cs == `YES) begin
			s_ready		= s4_ready;
			s_data_o	= s4_data_i;	
		end else if(s5_cs == `YES) begin
			s_ready		= s5_ready;
			s_data_o	= s5_data_i;		
		end else if(s6_cs == `YES) begin
			s_ready		= s6_ready;
			s_data_o	= s6_data_i;
		end else if(s7_cs == `YES) begin
			s_ready		= s7_ready;
			s_data_o	= s7_data_i;				
		end else begin
			s_ready		= `NO;
			//s_data_o	= `WordDataWith'h0;				
		end
	end

endmodule