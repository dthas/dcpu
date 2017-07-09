 `include "defines.v"

module	expt(
	input		wire									clk,
	input		wire									rst,
	
	input		wire[`ByteWidth]			exp_no_i,
	output	reg[`InstAddrBus]			exp_pc,
	
	//--------------------------------------
	//add on 2015-12-19
	output reg                    flush,
	//--------------------------------------
	
	//-------------------------------------------
	//add on 2015-12-4
	input wire[5:0]               int_i,
	output reg                   	timer_int_o,
	output reg[`RegBus]           count_o
	//-------------------------------------------
);

reg[`RegBus]           compare_o;

	always	@ (*)	begin
		if(rst == `RstEnable) begin
			exp_pc	= `ZeroWord;
			
			//add on 2015-12-19
			flush 	= 1'b0;
		end else begin			
			case(exp_no_i)
				//1）异常的处理
				`EXP_0, `EXP_1,`EXP_2,`EXP_3,`EXP_4,`EXP_5, `EXP_6,`EXP_7,`EXP_8,`EXP_9,
				`EXP_10, `EXP_11,`EXP_12,`EXP_13,`EXP_14,`EXP_15, `EXP_16,`EXP_17,`EXP_18,`EXP_19	:	begin
						exp_pc	= 8'h20;
						
						//add on 2015-12-19
						flush 	= 1'b1;
				end
				
				//2）中断的处理
				`EXP_32, `EXP_33,`EXP_34,`EXP_35,`EXP_36,`EXP_37, `EXP_38,`EXP_39, 
				`EXP_40, `EXP_41,`EXP_42,`EXP_43,`EXP_44,`EXP_45, `EXP_46,`EXP_47:	begin
						exp_pc	= 8'h40;
						
						//add on 2015-12-19
						flush 	= 1'b1;
				end
				
				//2）syscall的处理
				`EXP_80:	begin
						exp_pc	= 8'h40;
						
						//add on 2015-12-19
						flush 	= 1'b1;
				end
				
				default:	begin
						exp_pc	= `ZeroWord;
						
						//add on 2015-12-19
						flush 	= 1'b0;
				end
			endcase
		end	
	end
	
	always	@ (posedge clk)	begin
		if(rst == `RstEnable) begin
			count_o			= `ZeroWord;
			timer_int_o = `InterruptNotAssert;
			
			//----------------------------------------------
			//测试时钟中断时可将compare_o设置成较小，如：3
			//compare_o		= 3;
			compare_o		= 32'hFFFFFFFF;
			//----------------------------------------------
			
		end else begin
		
			//----------------------------------------------
			/*关时钟中断（调试用）
			//modi on 2015-12-19
			count_o 		= count_o + 1 ;
			
			if(count_o == compare_o) begin
				timer_int_o = `InterruptAssert;
				count_o	= `ZeroWord;
			end
			*/
			//----------------------------------------------
			
		end	
	end

endmodule