`include "defines.v"

module sys64b_reg(

	input	wire										clk,
	input wire										rst,
	
	//Ð´¶Ë¿Ú
	input wire										we,
	input wire[`RegBus64]				  idt_i,
	input wire[`RegBus64]				  gdt_i,
	input wire[`RegBus64]				  ldt_i,
	input wire[`RegBus64]				  tr_i,
	
	//¶Á¶Ë¿Ú1
	output reg[`RegBus64]				  idt_o,
	output reg[`RegBus64]				  gdt_o,
	output reg[`RegBus64]				  ldt_o,
	output reg[`RegBus64]				  tr_o
	
);

	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
					idt_o <= `ZeroDWord;
					gdt_o <= `ZeroDWord;
					ldt_o <= `ZeroDWord;
					tr_o 	<= `ZeroDWord;
		end else if((we == `WriteEnable)) begin
					idt_o <= idt_i;
					gdt_o <= gdt_i;
					ldt_o <= ldt_i;
					tr_o 	<= tr_i;
		end
	end

endmodule