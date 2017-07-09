`include "defines.v"

module	id_ex(
	input		wire							clk,
	input		wire							rst,
	
	input		wire[5:0]					stall,
	
	//--------------------------------------
	//add on 2015-12-19
	input wire                    	flush,
	//--------------------------------------
	
	input		wire[`AluOpBus]		id_aluop,
	input		wire[`AluSelBus]	id_alusel,
	input		wire[`RegBus]			id_reg1,
	input		wire[`RegBus]			id_reg2,
	input		wire[`RegAddrBus]	id_wd,
	input		wire							id_wreg,
	
	output	reg[`AluOpBus]		ex_aluop,
	output	reg[`AluSelBus]		ex_alusel,
	output	reg[`RegBus]			ex_reg1,
	output	reg[`RegBus]			ex_reg2,
	output	reg[`RegAddrBus]	ex_wd,
	output	reg								ex_wreg,
	
	//------------------------------------
	//add on 2105-11-21
	input		wire[`InstAddrBus]		id_pc_i,
	output	reg[`InstAddrBus]			ex_pc_o
	//------------------------------------
);

	always	@ (posedge	clk)	begin
		if(rst == `RstEnable) begin
			ex_aluop	<=	`EXE_NOP_OP;
			ex_alusel	<=	`EXE_RES_NOP;
			ex_reg1		<= 	`ZeroWord;
			ex_reg2		<=	`ZeroWord;
			ex_wd			<=	`NOPRegAddr;
			ex_wreg		<=	`WriteDisable;
			
			//add on 2015-11-21
			ex_pc_o		<=	`ZeroWord;
		
		//------------------------------------------------
		//add on 2015-12-19
		end else if(flush == 1'b1 ) begin
			ex_aluop	<=	`EXE_NOP_OP;
			ex_alusel	<=	`EXE_RES_NOP;
			ex_reg1		<= 	`ZeroWord;
			ex_reg2		<=	`ZeroWord;
			ex_wd			<=	`NOPRegAddr;
			ex_wreg		<=	`WriteDisable;			
			ex_pc_o		<=	`ZeroWord;
		//------------------------------------------------
		
		end else if(stall[2] == `Stop && stall[3] == `NoStop) begin
			ex_aluop	<=	`EXE_NOP_OP;
			ex_alusel	<=	`EXE_RES_NOP;
			ex_reg1		<= 	`ZeroWord;
			ex_reg2		<=	`ZeroWord;
			ex_wd			<=	`NOPRegAddr;
			ex_wreg		<=	`WriteDisable;
			
			//add on 2015-11-21
			ex_pc_o		<=	`ZeroWord;
		end else if(stall[2] == `NoStop) begin
			ex_aluop	<=	id_aluop;
			ex_alusel	<=	id_alusel;
			ex_reg1		<= 	id_reg1;
			ex_reg2		<=	id_reg2;
			ex_wd			<=	id_wd;
			ex_wreg		<=	id_wreg;
			
			//add on 2015-11-21
			ex_pc_o		<=	id_pc_i;
			
		/*
		//modi on 2015-11-14
		//add on 2015-10-3
		end else begin
			ex_aluop	<=	id_aluop;
			ex_alusel	<=	id_alusel;
			ex_reg1		<= 	id_reg1;
			ex_reg2		<=	id_reg2;
			ex_wd			<=	id_wd;
			ex_wreg		<=	id_wreg;
		*/
		
		end
		
	end

endmodule