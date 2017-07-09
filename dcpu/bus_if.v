`include "defines.v"

module bus_if(

	input	wire										clk,
	input wire										rst,
	
	//控制
	input wire[5:0]               stall_i,
	input                         flush_i,
	
	//CPU接口
	input wire                    cpu_ce_i,
	input wire[`RegBus]           cpu_data_i,
	input wire[`RegBus]           cpu_addr_i,
	input wire                    cpu_we_i,
	input wire[3:0]               cpu_sel_i,
	output reg[`RegBus]           cpu_data_o,
	
	//总线接口
	input	wire	[`WordDataBus]		bus_rd_data,
	input	wire										bus_ready,
	input	wire										bus_get,
	output	reg										bus_req,
	output	reg	[`WordAddrBus]		bus_addr,
	output	reg										bus_as,
	output	reg										bus_rw,
	output	reg	[`WordDataBus]		bus_wr_data,

	output reg                    stallreq	       
	
);

  reg[2:0] bus_state;
  reg[`RegBus] rd_buf;

	always @ (posedge clk) begin
		if(rst == `RstEnable) begin
			bus_state	 			= `BUS_IDLE;
			bus_req 				= `NO;			
			bus_addr				= `WordAddrWith'h0;
			bus_as				 	= `NO;
			bus_rw				 	= `READ;
			bus_wr_data			=	`WordDataWith'h0;			
			rd_buf 					= `ZeroWord;
		end else begin
			case (bus_state)
				`BUS_IDLE:		begin
					if((cpu_ce_i == 1'b1) && (flush_i == `False_v)) begin
						bus_req 				= `YES;			
						bus_addr				= cpu_addr_i;
						bus_rw				 	= cpu_we_i;
						bus_wr_data			=	cpu_data_i;		
			
						bus_state 			= `BUS_BUSY;
						rd_buf 					= `ZeroWord;
					end							
				end
				
							
				`BUS_BUSY:		begin
						bus_as			= `YES;
										
					if(bus_ready == `YES) begin
						bus_req			= `NO;
						bus_addr		= `WordAddrWith'h0;
						bus_rw			= `READ;
						bus_wr_data	= `WordDataWith'h0;
						bus_state	 			= `BUS_IDLE; 
						
						if(cpu_we_i == `READ) begin
							rd_buf		= bus_rd_data;
						end
						
						if(stall_i != 6'b000000) begin
							bus_state = `BUS_WAIT_FOR_STALL;
						end	
						
					end else	if(flush_i == `True_v) begin
					  bus_state	 			= `BUS_IDLE;
						bus_req 				= `NO;			
						bus_addr				= `WordAddrWith'h0;
						bus_as				 	= `NO;
						bus_rw				 	= `READ;
						bus_wr_data			=	`WordDataWith'h0;			
						rd_buf 					= `ZeroWord;						
					end					
				end
				
				`BUS_WAIT_FOR_STALL:		begin
					if(stall_i == 6'b000000) begin
						bus_state = `BUS_IDLE;
					end
				end
				default: begin
				end 
			endcase
		end    
	end      
			

	always @ (*) begin
		if(rst == `RstEnable) begin
			stallreq 		= `NoStop;
			cpu_data_o 	= `ZeroWord;
		end else begin
			stallreq = `NoStop;
			case (bus_state)
				`BUS_IDLE:		begin
					if((cpu_ce_i == 1'b1) && (flush_i == `False_v)) begin
						stallreq 		= `Stop;
						//cpu_data_o 	= `ZeroWord;				
					end
				end
				
				`BUS_BUSY:		begin
					if(bus_ready == `YES) begin
						stallreq = `NoStop;
						if(cpu_we_i == `READ) begin
							cpu_data_o	= bus_rd_data;
						end else begin
							cpu_data_o = `ZeroWord;
						end
					end else begin
						stallreq 		= `Stop;
						//cpu_data_o 	= `ZeroWord;	
					end					
				end
				
				`BUS_WAIT_FOR_STALL:		begin
					stallreq 			= `NoStop;
					cpu_data_o 		= rd_buf;
				end
				
				default: begin
				end 
			endcase
		end    
	end      

endmodule