 `include "defines.v"

module	C8259A(
	input		wire									clk,
	input		wire									rst,
	
	input		wire[`ByteWidth]			data_i,
	input		wire[`ByteWidth]			port_i,
	
	output reg[`WordWidth]        int_status
	
);


	always	@ (*)	begin
		if(rst == `RstEnable) begin
			int_status	= `ZeroWord;
		end else begin
			
			//--------------------------------------------------
			//��������
			int_status = 8'h01;		//��ʾ����ʱ���ж�
			//--------------------------------------------------
		end
	end

endmodule