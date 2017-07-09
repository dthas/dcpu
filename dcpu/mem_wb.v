`include "defines.v"

module	mem_wb(
	input		wire							clk,
	input		wire							rst,
	
	input		wire[5:0]					stall,
	
	//--------------------------------------
	//add on 2015-12-19
	input wire                    	flush,
	//--------------------------------------
	
	input	wire[`RegAddrBus]		mem_wd,
	input	wire								mem_wreg,
	input	wire[`RegBus]				mem_wdata,
	
	//----------------------------------------
	//add on 2015-11-24
	input wire[`RegBus64]			mem_wb_idt_i,
	input wire[`RegBus64]			mem_wb_gdt_i,
	input wire[`RegBus64]			mem_wb_ldt_i,
	input wire[`RegBus64]			mem_wb_tr_i,
	
	output reg[`RegBus64]			mem_wb_idt_o,
	output reg[`RegBus64]			mem_wb_gdt_o,
	output reg[`RegBus64]			mem_wb_ldt_o,
	output reg[`RegBus64]			mem_wb_tr_o,
	
	input wire                mem_wb_reg64_i, 
	output reg                mem_wb_reg64_o, 
	//----------------------------------------
	
	output	reg[`RegAddrBus]	wb_wd,
	output	reg								wb_wreg,
	output	reg[`RegBus]			wb_wdata
);

	always	@ (posedge	clk)	begin
		if(rst == `RstEnable) begin
			wb_wd			<= `NOPRegAddr;
			wb_wreg		<= `WriteDisable;
			wb_wdata	<= `ZeroWord;
			
			//----------------------------------
			//add on 2015-11-24			
			mem_wb_idt_o	<= `ZeroDWord;
			mem_wb_gdt_o	<= `ZeroDWord;
			mem_wb_ldt_o	<= `ZeroDWord;
			mem_wb_tr_o		<= `ZeroDWord;
			
			mem_wb_reg64_o	<= `WriteDisable;
			//----------------------------------	
		
		//----------------------------------
		//add on 2015-12-19
		end else if(flush == 1'b1 ) begin
			wb_wd			<= `NOPRegAddr;
			wb_wreg		<= `WriteDisable;
			wb_wdata	<= `ZeroWord;
			mem_wb_idt_o	<= `ZeroDWord;
			mem_wb_gdt_o	<= `ZeroDWord;
			mem_wb_ldt_o	<= `ZeroDWord;
			mem_wb_tr_o		<= `ZeroDWord;			
			mem_wb_reg64_o	<= `WriteDisable;
		//----------------------------------
			
		end else if(stall[3] == `Stop && stall[4] == `NoStop) begin
			wb_wd			<= `NOPRegAddr;
			wb_wreg		<= `WriteDisable;
			wb_wdata	<= `ZeroWord;
			
			//----------------------------------
			//add on 2015-11-24		
			mem_wb_idt_o	<= `ZeroDWord;
			mem_wb_gdt_o	<= `ZeroDWord;
			mem_wb_ldt_o	<= `ZeroDWord;
			mem_wb_tr_o		<= `ZeroDWord;
			
			mem_wb_reg64_o	<= `WriteDisable;
			//----------------------------------	
		// add on 2015-10-27
		end else if(stall[4] == `Stop) begin
			wb_wd			<= `NOPRegAddr;
			wb_wreg		<= `WriteDisable;
			wb_wdata	<= `ZeroWord;
			
			//----------------------------------
			//add on 2015-11-24		
			mem_wb_idt_o	<= `ZeroDWord;
			mem_wb_gdt_o	<= `ZeroDWord;
			mem_wb_ldt_o	<= `ZeroDWord;
			mem_wb_tr_o		<= `ZeroDWord;
			
			mem_wb_reg64_o	<= `WriteDisable;
			//----------------------------------	
			
		end else begin
			wb_wd			<= mem_wd;
			wb_wreg		<= mem_wreg;
			wb_wdata	<= mem_wdata;
			
			//----------------------------------
			//add on 2015-11-24
			mem_wb_idt_o	<= mem_wb_idt_i;
			mem_wb_gdt_o	<= mem_wb_gdt_i;
			mem_wb_ldt_o	<= mem_wb_ldt_i;
			mem_wb_tr_o		<= mem_wb_tr_i;
			
			mem_wb_reg64_o	<= mem_wb_reg64_i;
			//----------------------------------	
		end
	end

endmodule