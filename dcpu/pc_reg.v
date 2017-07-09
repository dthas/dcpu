`include "defines.v"

module	pc_reg(
	input		wire										clk,
	input		wire										rst,
	
	input		wire[5:0]								stall,
	
	//--------------------------------------
	//add on 2015-11-14
	input		wire[`InstAddrBus]			jmp_addr_pc,
	input		wire										jmp_fl_pc,
	//--------------------------------------
	
	//--------------------------------------
	//add on 2015-11-21
	input		wire[`InstAddrBus]			ret_addr_pc,
	input		wire										ret_fl_pc,
	//--------------------------------------
	
	//--------------------------------------
	//add on 2015-12-2
	input		wire[`InstAddrBus]			exp_addr_pc,
	input		wire										exp_fl_pc,
	//--------------------------------------
	
	//--------------------------------------
	//add on 2015-12-19
	input wire                    	flush,
	//--------------------------------------
	
	output	reg[`InstAddrBus]				pc,
	output	reg											ce
);

	
	
	always @ (posedge clk) begin
		if(ce == `ChipDisable) begin
			//pc <= 32'h30000000;
			pc <= 32'ha0000000;
		end else if(stall[0] == `NoStop) begin	
						
			//modi on 2015-12-2
			if(exp_fl_pc == `True_v)	begin
					pc	<=	exp_addr_pc;
			//--------------------------------------
			//add on 2015-12-19
			end else if(flush == 1'b1) begin
					pc <= 	exp_addr_pc;
			//--------------------------------------
			end else	begin			
					//--------------------------------------
					//modi on 2015-11-21
					if ((jmp_fl_pc == `False_v) && (ret_fl_pc == `False_v)) begin
							pc 				<= pc + 4'h4;
					end else if(jmp_fl_pc == `True_v)	begin					
							pc				<= jmp_addr_pc;					
					end else if(ret_fl_pc == `True_v) begin
							pc				<= ret_addr_pc;	
					end
					//--------------------------------------
			end
		end
	end
	
	always	@ (posedge	clk)	begin
		if(rst == `RstEnable) begin
			ce <= `ChipDisable;
		end else begin
			ce <= `ChipEnable;
		end
	end

endmodule