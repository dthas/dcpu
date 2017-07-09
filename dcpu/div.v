`include "defines.v"

module	div(
	input		wire						clk,
	input		wire						rst,
	input		wire[`RegBus]		div_s,
	input		wire[`RegBus]		div_b,
	input		wire						flg_start_div,
	
	output	reg[2:0]				state,
	output	reg[`RegBus]		res					//除法运算结果
);

	
	reg[`RegBus]	res_temp;
	reg[`RegBus64]	res_temp64;
	reg[`RegBus]	k;	
	reg[`RegBus]	div_n;		
	
	/*
	//modi on 2015-12-12
	always	@ (*)	begin
		if((flg_start_div == `True_v) && (state == `DIV_STATE_99)) begin
				state	= `DIV_STATE_0;
		end
		
		if((flg_start_div == `False_v) && (state == `DIV_STATE_2)) begin
				state	= `DIV_STATE_99;
		end
	end
	*/
	
	
	always	@ (posedge	clk)	begin
		if(rst == `RstEnable) begin
			res				= `ZeroWord;
			res_temp	= `ZeroWord;
			res_temp64= `ZeroDWord;
			div_n			= `ZeroWord;			
			k					= 31;	
			state			= `DIV_STATE_99;		
		end else begin
		
			//---------------------------------------------------------------
			//add on 2015-12-12
			if((flg_start_div == `True_v) && (state == `DIV_STATE_99)) begin
				state	= `DIV_STATE_0;
			end
			
			if((flg_start_div == `False_v) && (state == `DIV_STATE_2)) begin
					state	= `DIV_STATE_99;
			end
			//---------------------------------------------------------------
		
			case(state)	
					`DIV_STATE_0	:	begin
										div_n[0]	= div_s[k];				//div_s[31], k = 31
			
										res_temp64= div_n - div_b;
										res_temp	=	res_temp64;
										
										if((res_temp64>>32) == 0)	begin
											res[k]			= 1;
																						
											div_n			= `ZeroWord;																				
											div_n			= res_temp;
											div_n 		= (div_n << 1) | div_s[k-1];
										end else begin
											res[k]	= 0;											
											div_n 				= (div_n << 1) | div_s[k-1];
										end
										
										k 				= k-1;										
										state			= `DIV_STATE_1;
					end
					
					`DIV_STATE_1	:	begin
													
										res_temp64= div_n - div_b;
										res_temp	=	res_temp64;	
										
										if((res_temp64>>32) == 0)	begin
											res[k]			= 1;											
											
											div_n			= `ZeroWord;																					
											div_n			= res_temp;
											div_n 		= (div_n << 1) | div_s[k-1];
										end else begin
											res[k]	= 0;
											
											div_n 				= (div_n << 1) | div_s[k-1];																
										end
										
										k 				= k-1;										
										
										if(k[31] == 1) begin		//k < 0
												state			= `DIV_STATE_2;
										end
					end
					
					`DIV_STATE_2	:	begin
										res_temp64	= res_temp64;			//just for test			
										
					end
					
					
					
					default	: begin
					
					end
					
				endcase		
		end
	end

endmodule