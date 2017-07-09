`include "defines.v"

module	ex_mem(
	input		wire							clk,
	input		wire							rst,
	
	input		wire[5:0]					stall,
	
	//--------------------------------------
	//add on 2015-12-19
	input wire                    	flush,
	//--------------------------------------
	
	input	wire[`RegAddrBus]		ex_wd,
	input	wire								ex_wreg,
	input	wire[`RegBus]				ex_wdata,
	
	//----------------------------------------
	//add on 2015-11-18
	input	wire[`AluOpBus]			ex_mem_aluop_i,
	input	wire[`InstAddrBus]	ex_mem_addr_i,
	input	wire[`InstAddrBus]	ex_mem_data_i,
	
	output	reg[`AluOpBus]		ex_mem_aluop_o,
	output	reg[`InstAddrBus]	ex_mem_addr_o,
	output	reg[`InstAddrBus]	ex_mem_data_o,
	//----------------------------------------
	
	//----------------------------------------
	//add on 2015-11-24
	input wire[`RegBus64]			ex_mem_idt_i,
	input wire[`RegBus64]			ex_mem_gdt_i,
	input wire[`RegBus64]			ex_mem_ldt_i,
	input wire[`RegBus64]			ex_mem_tr_i,
	
	output reg[`RegBus64]		ex_mem_idt_o,
	output reg[`RegBus64]		ex_mem_gdt_o,
	output reg[`RegBus64]		ex_mem_ldt_o,
	output reg[`RegBus64]		ex_mem_tr_o,
	
	input wire                ex_mem_w_reg64_i, 
	output reg                ex_mem_w_reg64_o, 

	//----------------------------------------
	
	//----------------------------------------
	//add on 2015-11-27	
	input	wire[`InstAddrBus]	ex_mem_addr_j_i,
	input	wire[`InstAddrBus]	ex_mem_data_j_i,
	
	output	reg[`InstAddrBus]	ex_mem_addr_j_o,
	output	reg[`InstAddrBus]	ex_mem_data_j_o,
	//----------------------------------------
	
	//--------------------------------------
	//add on 2015-12-2
	input		wire[`ByteWidth]	ex_mem_exp_no_i,
	output	reg[`ByteWidth]		ex_mem_exp_no_o,
	
	input		wire[`InstAddrBus]	ex_mem_exp_retpc_i,
	output	reg[`InstAddrBus]		ex_mem_exp_retpc_o,
	//--------------------------------------
	
	output	reg[`RegAddrBus]	mem_wd,
	output	reg								mem_wreg,
	output	reg[`RegBus]			mem_wdata,
	
	input wire[1:0]           cnt_i,	
	output reg[1:0]           cnt_o
);

	always	@ (posedge	clk)	begin
		if(rst == `RstEnable) begin
			mem_wd				<= `NOPRegAddr;
			mem_wreg			<= `WriteDisable;
			mem_wdata			<= `ZeroWord;			
			cnt_o 				<= 2'b00;	
			
			//----------------------------------
			//add on 2015-11-18
			ex_mem_aluop_o				<=	`EXE_NOP_OP;
			ex_mem_addr_o	<=	`ZeroWord;
			ex_mem_data_o	<=	`ZeroWord;
			//----------------------------------
			//----------------------------------
			//add on 2015-11-27
			ex_mem_addr_j_o	<=	`ZeroWord;
			ex_mem_data_j_o	<=	`ZeroWord;
			//----------------------------------
			
			//----------------------------------
			//add on 2015-12-2
			ex_mem_exp_no_o	<=	8'hFF;
			ex_mem_exp_retpc_o	<=	`ZeroWord;			
			//----------------------------------
			
			//----------------------------------
			//add on 2015-11-24			
			ex_mem_idt_o	<= `ZeroDWord;
			ex_mem_gdt_o	<= `ZeroDWord;
			ex_mem_ldt_o	<= `ZeroDWord;
			ex_mem_tr_o		<= `ZeroDWord;
			ex_mem_w_reg64_o	<=	`WriteDisable;
			//----------------------------------	
		
		//----------------------------------	
		//add on 2015-12-19	
		end else if(flush == 1'b1 ) begin
			mem_wd				<= `NOPRegAddr;
			mem_wreg			<= `WriteDisable;
			mem_wdata			<= `ZeroWord;			
			cnt_o 				<= 2'b00;	
			ex_mem_aluop_o				<=	`EXE_NOP_OP;
			ex_mem_addr_o	<=	`ZeroWord;
			ex_mem_data_o	<=	`ZeroWord;
			ex_mem_addr_j_o	<=	`ZeroWord;
			ex_mem_data_j_o	<=	`ZeroWord;
			ex_mem_exp_no_o	<=	8'hFF;
			ex_mem_exp_retpc_o	<=	`ZeroWord;	
			ex_mem_idt_o	<= `ZeroDWord;
			ex_mem_gdt_o	<= `ZeroDWord;
			ex_mem_ldt_o	<= `ZeroDWord;
			ex_mem_tr_o		<= `ZeroDWord;
			ex_mem_w_reg64_o	<=	`WriteDisable;	    				
		//----------------------------------	
			
		end else if(stall[3] == `Stop && stall[4] == `NoStop) begin
			mem_wd				<= `NOPRegAddr;
			mem_wreg			<= `WriteDisable;
			mem_wdata			<= `ZeroWord;			
			cnt_o 				<= cnt_i;	
			
			//----------------------------------
			//add on 2015-11-18
			ex_mem_aluop_o				<=	`EXE_NOP_OP;
			ex_mem_addr_o	<=	`ZeroWord;
			ex_mem_data_o	<=	`ZeroWord;
			//----------------------------------
			//----------------------------------
			//add on 2015-11-27
			ex_mem_addr_j_o	<=	`ZeroWord;
			ex_mem_data_j_o	<=	`ZeroWord;
			//----------------------------------
			
			//----------------------------------
			//add on 2015-12-2
			ex_mem_exp_no_o	<=	8'hFF;	
			ex_mem_exp_retpc_o	<=	`ZeroWord;		
			//----------------------------------
			
			//----------------------------------
			//add on 2015-11-24	
			ex_mem_idt_o	<= `ZeroDWord;
			ex_mem_gdt_o	<= `ZeroDWord;
			ex_mem_ldt_o	<= `ZeroDWord;
			ex_mem_tr_o		<= `ZeroDWord;
			
			ex_mem_w_reg64_o	<=	`WriteDisable;
			//----------------------------------		
			
		end else if(stall[3] == `NoStop) begin
			mem_wd				<= ex_wd;
			mem_wreg			<= ex_wreg;
			mem_wdata			<= ex_wdata;
			cnt_o 				<= 2'b00;
			
			//----------------------------------
			//add on 2015-11-18
			ex_mem_aluop_o	<=	ex_mem_aluop_i;
			ex_mem_addr_o		<=	ex_mem_addr_i;
			ex_mem_data_o		<=	ex_mem_data_i;
			//----------------------------------
			//----------------------------------
			//add on 2015-11-27
			ex_mem_addr_j_o	<=	ex_mem_addr_j_i;
			ex_mem_data_j_o	<=	ex_mem_data_j_i;
			//----------------------------------
			
			//----------------------------------
			//add on 2015-12-2
			ex_mem_exp_no_o	<=	ex_mem_exp_no_i;
			ex_mem_exp_retpc_o	<=	ex_mem_exp_retpc_i;			
			//----------------------------------
			
			//----------------------------------
			//add on 2015-11-24
			ex_mem_idt_o	<= ex_mem_idt_i;
			ex_mem_gdt_o	<= ex_mem_gdt_i;
			ex_mem_ldt_o	<= ex_mem_ldt_i;
			ex_mem_tr_o		<= ex_mem_tr_i;
			
			ex_mem_w_reg64_o	=	ex_mem_w_reg64_i;
			//----------------------------------	
		
		//add on 2015-10-27
		end else if(stall[3] == `Stop) begin
			mem_wd				<= `NOPRegAddr;
			mem_wreg			<= `WriteDisable;
			mem_wdata			<= `ZeroWord;			
			cnt_o 				<= cnt_i;
			
			//----------------------------------
			//add on 2015-11-18
			ex_mem_aluop_o	<=	`EXE_NOP_OP;
			ex_mem_addr_o		<=	`ZeroWord;
			ex_mem_data_o		<=	`ZeroWord;
			//----------------------------------
			//----------------------------------
			//add on 2015-11-27
			ex_mem_addr_j_o	<=	`ZeroWord;
			ex_mem_data_j_o	<=	`ZeroWord;
			//----------------------------------
			
			//----------------------------------
			//add on 2015-12-2
			ex_mem_exp_no_o	<=	8'hFF;
			ex_mem_exp_retpc_o	<=	`ZeroWord;			
			//----------------------------------
			
			//----------------------------------
			//add on 2015-11-24		
			ex_mem_idt_o	<= `ZeroDWord;
			ex_mem_gdt_o	<= `ZeroDWord;
			ex_mem_ldt_o	<= `ZeroDWord;
			ex_mem_tr_o		<= `ZeroDWord;
			
			ex_mem_w_reg64_o	<=	`WriteDisable;
			//----------------------------------	
			
		//--------------------------------
		/*
		//modi on 2015-11-18	
		//add on 2015-10-3
		end else begin
			mem_wd		<= ex_wd;
			mem_wreg	<= ex_wreg;
			mem_wdata	<= ex_wdata;
			cnt_o 		<= cnt_i;	
		*/
		//--------------------------------
		
		end
	end

endmodule