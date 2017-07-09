`include "defines.v"

module flash_top(   
    input   						clk_i,
    input   						rst_i,
    input   [31:0] 			adr_i,
    output reg [31:0] 	dat_o,
    input   [31:0] 			dat_i,     
    input	wire					stb_i,
		input	wire					we_i,			
		output	reg					ready_o,    
    
    output reg [31:0] 	flash_adr_o,
    input   [7:0] 			flash_dat_i,
    output  						flash_rst,
    output  						flash_oe,
    output  						flash_ce,
    output  						flash_we 
);   
   
    
    
    reg [3:0] 					waitstate;   
    
    wire acc = stb_i;    		//  access
    wire wr  = we_i;       	// write access
    wire rd  = !we_i;      	// read access   
    
    always @(posedge clk_i) begin
        if( rst_i == 1'b1 ) begin
            waitstate 	= 4'h0;
            ready_o 		= 1'b0;
        end else if(acc == 1'b0) begin
            waitstate 	= 4'h0;
            ready_o 		= 1'b0;
            dat_o 			= 32'h00000000;
        end else if(waitstate == 4'h0) begin
            ready_o = 1'b0;
            if(acc) begin
              waitstate = waitstate + 4'h1;
            end
						flash_adr_o = {10'b0000000000,adr_i[21:2],2'b00};						
               
        end else begin
            waitstate = waitstate + 4'h1;
				    if(waitstate == 4'h3) begin
					     dat_o[31:24] = flash_dat_i;
					     flash_adr_o 	= {10'b0000000000,adr_i[21:2],2'b01};
						end else if(waitstate == 4'h6) begin
						   dat_o[23:16] = flash_dat_i;
						   flash_adr_o 	= {10'b0000000000,adr_i[21:2],2'b10};
						end else if(waitstate == 4'h9) begin
						   dat_o[15:8] 	= flash_dat_i;
						   flash_adr_o	= {10'b0000000000,adr_i[21:2],2'b11};
						end else if(waitstate == 4'hc) begin
						   dat_o[7:0] 	= flash_dat_i;
               ready_o 			= 1'b1;
               
						end else if(waitstate == 4'hd) begin
               ready_o 			= 1'b0;
               waitstate 		= 4'h0;
            end
         end
      end

    assign flash_ce = !acc;
    assign flash_we = 1'b1;
    assign flash_oe = !rd;


    assign flash_rst = !rst_i;

endmodule
