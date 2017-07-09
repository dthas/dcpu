`include "defines.v"

module	id(
	input		wire									rst,
	input		wire[`InstAddrBus]		pc_i,
	input		wire[`InstBus]				inst_i,
	
	input		wire									ex_wreg_i,
	input		wire[`RegBus]					ex_wdata_i,
	input		wire[`RegAddrBus]			ex_wd_i,
	
	input		wire									mem_wreg_i,
	input		wire[`RegBus]					mem_wdata_i,
	input		wire[`RegAddrBus]			mem_wd_i,
	
	input		wire[`RegBus]					reg1_data_i,
	input		wire[`RegBus]					reg2_data_i,
	
	output	reg										reg1_read_o,
	output	reg										reg2_read_o,
	output	reg[`RegAddrBus]			reg1_addr_o,
	output	reg[`RegAddrBus]			reg2_addr_o,
	
	output	reg[`AluOpBus]				aluop_o,
	output	reg[`AluSelBus]				alusel_o,
	output	reg[`RegBus]					reg1_o,
	output	reg[`RegBus]					reg2_o,
	output	reg[`RegAddrBus]			wd_o,
	output	reg										wreg_o,
	
	output 	reg                   stallreq,
	
	//modi on 2015-12-22
	//output	reg										stallreq_to_id,
	
	/*
	//add on 2015-10-18
	input		wire									ex_fl_eflag,
	input		wire[`RegBus]					ex_eflag_val,
	input		wire[`AluOpBus]				ex_eflag_op,
	input		wire[`RegAddrBus]			ex_dest_addr_o
	*/
	
	//add on 2015-11-5
	input		wire									ex_reg_fl,
	input		wire[`RegBus]					ex_reg_val,
	input		wire[`AluOpBus]				ex_reg_aluop,
	input		wire[`AluSelBus]			ex_reg_alusel,
	input		wire[`RegAddrBus]			ex_reg_dest_addr,
	
	//add on 2015-11-21
	output		wire[`InstAddrBus]		pc_o		
);

	//--------------------------------------------------
	//add on 2015-11-21
	assign	pc_o	= pc_i;
	//--------------------------------------------------
	
	//=================================================================================
	//add on 2015-9-25
	reg[`InstWidth]				cur_inst;						//48字节的指令存放空间，后面的分析根据
	
	//--------------------------------------------------
	//modi on 2015-12-22
	//reg[`InstBus]					cur_pos;						//cur_inst[cur_pos: 0]
	//reg[`InstBus]					tot_len_i;					//累计输入指令长度
	//reg[`InstBus]					tot_len;						//分析当前指令，所发现的相应指令长度
	//reg[`InstBus]					temp;
	//reg[15:0]							i;
	//reg[15:0]							j;
	//reg[15:0]							opcode_len;
	//reg[15:0]							cmdcode_len;
	//reg[15:0]							data_len;
	
	reg[`InstBus8]					cur_pos;						//cur_inst[cur_pos: 0]
	reg[`InstBus8]					tot_len_i;					//累计输入指令长度
	reg[`InstBus8]					tot_len;						//分析当前指令，所发现的相应指令长度
	reg[`InstBus8]					temp;
	reg[`InstBus8]					i;
	reg[`InstBus8]					j;
	reg[`InstBus8]					opcode_len;
	reg[`InstBus8]					cmdcode_len;
	reg[`InstBus8]					data_len;
	//--------------------------------------------------
	
	reg										pre_66;							//前缀 8'h66 标志位
	reg										pre_67;							//前缀 8'h67 标志位
	
	reg[7:0]								pre1;
	reg[7:0]								pre2;
	reg[7:0]								pre3;
	reg[7:0]								pre4;
	
	reg[7:0]								op1	;	
	
	
	//--------------------------------------------------
	
	reg[`RegBus] imm;
	
	reg[1:0]		mod;
	reg[2:0]		regop;
	reg[2:0]		rm;
	
	reg[7:0]		disp8;
	reg[15:0]		disp16;
	reg[31:0]		disp32;
	
	
	
	reg 					instvalid;
	
	reg					flg_cmd;
	
	
	//赋初值，一次
	initial	begin
		//--------------------------------------------------
		//modi on 2015-12-22
		//cur_inst			=	384'h000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
		cur_inst			=	96'h000000000000000000000000;
		//--------------------------------------------------
		
		cur_pos				=	`InstLen - 1;					
		tot_len_i			=	`ZeroWord;
		tot_len				=	`ZeroWord;	
		
		pre_66				=	`False_v;
		pre_67				=	`False_v;
			
	end
	//--------------------------------------------------
	
	
	always	@ (*)	begin
		if(rst == `RstEnable) begin
			aluop_o				=	`EXE_NOP_OP;
			alusel_o			=	`EXE_RES_NOP;
			wd_o					=	`NOPRegAddr;
			wreg_o				=	`WriteDisable;
			instvalid			=	`InstValid;
			reg1_read_o		=	1'b0;
			reg2_read_o		= 	1'b0;
			reg1_addr_o		= 	`NOPRegAddr;
			reg2_addr_o		=	`NOPRegAddr;
			imm						=	32'h0;
			
			stallreq 			= `NoStop;
			
			//modi on 2015-10-27
			//stallreq_to_id=	`NoStop;
			
			
			//--------------------------------------------------
			//modi on 2015-12-22
			//cur_inst			=	384'h000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
			cur_inst			=	96'h000000000000000000000000;
			//--------------------------------------------------
			
			cur_pos				=	`InstLen - 1;					//383
			tot_len_i			=	`ZeroWord;
			tot_len				=	`ZeroWord;
			opcode_len		= `ZeroWord;
			cmdcode_len		=	`ZeroWord;
			data_len			=	`ZeroWord;
			//----------------------------------------
			
			//----------------------------------------
			//add on 2015-10-24
			flg_cmd				= `False_v;
			//----------------------------------------
			
		end else begin
			aluop_o				=	`EXE_NOP_OP;
			alusel_o			=	`EXE_RES_NOP;
			wd_o					=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];						//cur_inst[21:19];
			wreg_o				=	`WriteDisable;
			instvalid			=	`InstInValid;
			reg1_read_o		=	1'b0;
			reg2_read_o		= 	1'b0;
			//reg1_addr_o		= 	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];						//cur_inst[21:19];
			//reg2_addr_o		=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];
			reg1_addr_o		= 	`NOPRegAddr;						//cur_inst[21:19];
			reg2_addr_o		=	`NOPRegAddr;						//cur_inst[18:16];
			imm						=	`ZeroWord;
			opcode_len		= `ZeroWord;
			cmdcode_len		=	`ZeroWord;
			data_len			=	`ZeroWord;
			
			
			//=================================================================================
			
			//--------------------------------------------------
			//add on 2015-10-18
			if(ex_reg_fl == `True_v)	begin	
					wreg_o				=	`WriteEnable;         
					aluop_o				=	ex_reg_aluop;          
					alusel_o			=	ex_reg_alusel;                                                           											
					reg1_read_o		=	1'b0; 				        										                                          											
					reg2_read_o		=	1'b0;                 										                                                                 											
					reg1_addr_o		=	ex_reg_dest_addr;             										                                                        											
					imm						= ex_reg_val;       									                                                        											
					wd_o					=	reg1_addr_o ;	        										                                                        											
					instvalid			=	`InstValid;  
					
					
			//--------------------------------------------------
			
			end else begin
			
				//--------------------------------------------------
				// add on 2015-10-30
				//将本次获得的指令赋给 cur_inst
				//cur_inst[cur_pos  : ((cur_pos + 1) - `Num32)]	= inst_i[`InstBus];
				//cur_inst[cur_pos - : (`Num32 - 1)]	= inst_i[`InstBus];
				j = (cur_pos + 1) - `Num32;
					for(i=0; i<`Num32; i=i+1)	begin
							cur_inst[j + i]	= inst_i[i];
					end
				//--------------------------------------------------

				if(cur_pos	== `InstLen - 1)	begin	
								
					//--------------------------------------------------
					//获取前缀（如果存在）
					pre1						= cur_inst[(`InstLen - 1) 	:	(`InstLen - 8)];						//cur_inst[31:24];
					pre2						= cur_inst[(`InstLen - 9)  :	(`InstLen - 16)];						//cur_inst[23:16];
					pre3						= cur_inst[(`InstLen - 17)  :	(`InstLen - 24)];						//cur_inst[15:8];
					pre4						= cur_inst[(`InstLen - 25)  :	(`InstLen - 32)];						//cur_inst[7:0];
					
					if(((pre1 == 8'h66) && (pre2 == 8'h67)) || ((pre1 == 8'h67) && (pre2 == 8'h66))) begin			// 0x6667xxxx 或者 0x6766xxxx
						//--------------------------------------------------
						//modi on 2015-12-22
						//cur_inst			=	384'h000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
						cur_inst			=	96'h000000000000000000000000;
						//--------------------------------------------------
						
						//cur_inst[cur_pos  : ((cur_pos + 1) - (`Num32 - 16))]	= inst_i[15:0];	//省略 8'h66 和 8'h67,取后面16位
						//cur_inst[cur_pos - : (`Num32 - 17)]	= inst_i[15:0];	//省略 8'h66 和 8'h67,取后面16位
						j = (cur_pos + 1) - (`Num32 - 16);
						for(i=0; i<`Num16; i=i+1)	begin
								cur_inst[j + i]	= inst_i[i];
						end						
						
						tot_len_i			=	tot_len_i	+ `Num16;
						cur_pos				=	cur_pos		- `Num16;
						
						pre_66				=	`True_v	;
						pre_67				=	`True_v;
					end else if((pre1 == 8'h66) || (pre1 == 8'h67)) begin	// 0x66xxxxxx 或者 0x67xxxxxx
						//--------------------------------------------------
						//modi on 2015-12-22
						//cur_inst			=	384'h000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
						cur_inst			=	96'h000000000000000000000000;
						//--------------------------------------------------
						//cur_inst[cur_pos  : ((cur_pos + 1) - (`Num32 - 8))]	= inst_i[23:0];		//省略 8'h66 或 8'h67,取后面24位
						//cur_inst[cur_pos - : (`Num32 - 9)]	= inst_i[23:0];		//省略 8'h66 或 8'h67,取后面24位
						j = (cur_pos + 1) - (`Num32 - 8);
						for(i=0; i<`Num24; i=i+1)	begin
								cur_inst[j + i]	= inst_i[i];
						end
						
						tot_len_i			=	tot_len_i	+ `Num24;
						cur_pos				=	cur_pos		- `Num24;
						
						if(pre1 == 8'h66)	begin
							pre_66			=	`True_v	;
							pre_67			=	`False_v;
						end else if (pre1 == 8'h67) begin
							pre_67			=	`True_v	;
							pre_66			=	`False_v;
						end					
					
					//-----------------------------------------------------------------------------------------------
					// add on 2015-10-13  0x006667xx 或者 0x006766xx
					end else if((pre1 == 0) && (((pre2 == 8'h66) && (pre3 == 8'h67)) || ((pre2 == 8'h67) && (pre3 == 8'h66)))) begin			
						//--------------------------------------------------
						//modi on 2015-12-22
						//cur_inst			=	384'h000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
						cur_inst			=	96'h000000000000000000000000;
						//--------------------------------------------------
						
						j = (cur_pos + 1) - (`Num32 - 24);
						for(i=0; i<`Num8; i=i+1)	begin
								cur_inst[j + i]	= inst_i[i];
						end						
						
						tot_len_i			=	tot_len_i	+ `Num8;
						cur_pos				=	cur_pos		- `Num8;
						
						pre_66				=	`True_v	;
						pre_67				=	`True_v;
						
					end else if((pre1 == 0) && ((pre2 == 8'h66) || (pre2 == 8'h67)))	begin			// 0x0066xxxx 或者 0x0067xxxx
						j = (cur_pos + 1) - (`Num32 - 16);
						for(i=0; i<`Num16; i=i+1)	begin
								cur_inst[j + i]	= inst_i[i];
						end
						
						tot_len_i			=	tot_len_i	+ `Num16;
						cur_pos				=	cur_pos		- `Num16;
						
						if(pre2 == 8'h66)	begin
							pre_66			=	`True_v	;
							pre_67			=	`False_v;
						end else if (pre2 == 8'h67) begin
							pre_67			=	`True_v	;
							pre_66			=	`False_v;
						end	
					
					//-----------------------------------------------------------------------------------------------
					
					//-----------------------------------------------------------------------------------------------
					// add on 2015-10-4
					end else if((pre1 == 0) && (pre2 != 0))	begin
						j = (cur_pos + 1) - (`Num32 - 8);
						for(i=0; i<`Num24; i=i+1)	begin
								cur_inst[j + i]	= inst_i[i];
						end
						
						tot_len_i			=	tot_len_i	+ `Num24;
						cur_pos				=	cur_pos		- `Num24;
						
						pre_66				=	`False_v	;
						pre_67				=	`False_v;
					//-----------------------------------------------------------------------------------------------
					
					//-----------------------------------------------------------------------------------------------
					// add on 2015-10-13	 0x00006667 或者 0x00006766
					end else if((pre1 == 0) && (pre2 == 0) && (((pre3 == 8'h66) && (pre4 == 8'h67)) || ((pre3 == 8'h67) && (pre4 == 8'h66)))) begin			
						//--------------------------------------------------
						//modi on 2015-12-22
						//cur_inst			=	384'h000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
						cur_inst			=	96'h000000000000000000000000;
						//--------------------------------------------------
												
						pre_66				=	`True_v	;
						pre_67				=	`True_v;
						
					end else if((pre1 == 0) && (pre2 == 0) && ((pre3 == 8'h66) || (pre3 == 8'h67)))	begin
						j = (cur_pos + 1) - (`Num32 - 24);
						for(i=0; i<`Num8; i=i+1)	begin
								cur_inst[j + i]	= inst_i[i];
						end
						
						tot_len_i			=	tot_len_i	+ `Num8;
						cur_pos				=	cur_pos		- `Num8;
						
						if(pre3 == 8'h66)	begin
							pre_66			=	`True_v	;
							pre_67			=	`False_v;
						end else if (pre3 == 8'h67) begin
							pre_67			=	`True_v	;
							pre_66			=	`False_v;
						end	
					
					//-----------------------------------------------------------------------------------------------
					
					
					//-----------------------------------------------------------------------------------------------
					// add on 2015-10-4	
					end else if((pre1 == 0) && (pre2 == 0) && (pre3 != 0))	begin
						j = (cur_pos + 1) - (`Num32 - 16);
						for(i=0; i<`Num16; i=i+1)	begin
								cur_inst[j + i]	= inst_i[i];
						end						
						
						tot_len_i			=	tot_len_i	+ `Num16;
						cur_pos				=	cur_pos		- `Num16;
						
						pre_66				=	`False_v	;
						pre_67				=	`False_v;
					//-----------------------------------------------------------------------------------------------	
					
					//-----------------------------------------------------------------------------------------------
					// add on 2015-10-13	 0x00000066 或者 0x00000067
					end else if((pre1 == 0) && (pre2 == 0) && (pre3 == 0) && ((pre4 == 8'h66) || (pre4 == 8'h67)))	begin		
											
						if(pre4 == 8'h66)	begin
							pre_66			=	`True_v	;
							pre_67			=	`False_v;
						end else if (pre4 == 8'h67) begin
							pre_67			=	`True_v	;
							pre_66			=	`False_v;
						end	
					
					//-----------------------------------------------------------------------------------------------				
					
					
					//-----------------------------------------------------------------------------------------------
					// modi on 2015-10-24
					// add on 2015-10-4	
					end else if((pre1 == 0) && (pre2 == 0) && (pre3 == 0) && (pre4 != 0))	begin
						flg_cmd				= `False_v;
						
						//只有操作码的指令1
						case(pre4)	
							8'h06, 8'h0E, 8'h16, 8'h1E, 			// push 
							8'h50, 8'h51, 8'h52, 8'h53,
							8'h54, 8'h55, 8'h56, 8'h57,
							8'h58, 8'h59, 8'h5A, 8'h5B, 			//	pop
							8'h5C, 8'h5D, 8'h5E, 8'h5F, 
							8'h60,														// pushad
							8'h9d,														// pushfd
							8'h07, 8'h17, 8'h1F,							// pop
							8'h61,														// popad
							8'h9D,														// popf
							8'hC9,														// leave
							8'h9B,														// wait
							8'h90,														// nop
							8'hF9,														// stc
							8'hFB,														// sti
							8'hF8,														// clc
							8'hFA,														// cli
							8'hF4,														// hlt
							8'hC3, 8'hCB,											// ret
							8'hCF,														// iret	
							8'h40,8'h41,8'h42,8'h43,					// inc
							8'h44,8'h45,8'h46,8'h47,					
							8'h48,8'h49,8'h4A,8'h4B,					// dec
							8'h4C,8'h4D,8'h4E,8'h4F						
										: begin
												flg_cmd	= `True_v;	
												end
								
							default:	begin
												flg_cmd	= `False_v;
												end
						endcase
						
												
						if(flg_cmd == `True_v)	begin
								//只有操作码的指令长度为8字节
								j = (cur_pos + 1) - (`Num32 - 24);
								for(i=0; i<`Num8; i=i+1)	begin
										cur_inst[j + i]	= inst_i[i];
								end						
								
								tot_len_i			=	tot_len_i	+ `Num8;
								cur_pos				=	cur_pos		- `Num8;
								
								pre_66				=	`False_v	;
								pre_67				=	`False_v;
						
						end else	begin
								//有些指令的操作码是00（指令的实际长度为16位），例如，指令码为 00 的add 指令
								j = (cur_pos + 1) - (`Num32 - 16);
								for(i=0; i<`Num16; i=i+1)	begin
										cur_inst[j + i]	= inst_i[i];
								end						
								
								tot_len_i			=	tot_len_i	+ `Num16;
								cur_pos				=	cur_pos		- `Num16;
								
								pre_66				=	`False_v	;
								pre_67				=	`False_v;
						end
					
					//-----------------------------------------------------------------------------------------------
					
										
					end else if(inst_i != 32'h0) begin
					
						tot_len_i	=	tot_len_i	+ `Num32;
						cur_pos		=	cur_pos		- `Num32;
						
						pre_66		=	`False_v;
						pre_67		=	`False_v;
					end
					
					
					//-------------------------------------------------- 
			
			//--------------------------------------------------	
			//modi on 2015-12-19	
			end else if (tot_len == 0) begin	
					//获取前缀（如果存在）
					pre1						= cur_inst[(`InstLen - 1) 	:	(`InstLen - 8)];						//cur_inst[31:24];
					pre2						= cur_inst[(`InstLen - 9)  :	(`InstLen - 16)];						//cur_inst[23:16];
					pre3						= cur_inst[(`InstLen - 17)  :	(`InstLen - 24)];						//cur_inst[15:8];
					pre4						= cur_inst[(`InstLen - 25)  :	(`InstLen - 32)];						//cur_inst[7:0];
					
					if(((pre1 == 8'h66) && (pre2 == 8'h67)) || ((pre1 == 8'h67) && (pre2 == 8'h66))) begin			// 0x6667xxxx 或者 0x6766xxxx
						cur_inst = cur_inst << `Num16;
						
						tot_len_i	=	tot_len_i	+ `Num32 - `Num16;
						cur_pos		=	cur_pos		- `Num32 + `Num16;
						
						pre_66				=	`True_v	;
						pre_67				=	`True_v;
					end else if((pre1 == 8'h66) || (pre1 == 8'h67)) begin	// 0x66xxxxxx 或者 0x67xxxxxx
						cur_inst = cur_inst << `Num8;	
						
						tot_len_i	=	tot_len_i	+ `Num32 - `Num8;
						cur_pos		=	cur_pos		- `Num32 + `Num8;				
						
						if(pre1 == 8'h66)	begin
							pre_66			=	`True_v	;
							pre_67			=	`False_v;
						end else if (pre1 == 8'h67) begin
							pre_67			=	`True_v	;
							pre_66			=	`False_v;
						end
					
					end
			//--------------------------------------------------	
					
			end else begin				
			
					temp				=	tot_len - tot_len_i;
										
					cur_pos		=	cur_pos - temp;
										
					tot_len_i	=	tot_len_i	+ `Num32;
			end
			
			
		
			//获取指令的各个标志位
			op1		= cur_inst[(`InstLen - 1) 	:	(`InstLen - 8)];						//cur_inst[31:24];
			
			//=================================================================================
			
			
			
			
			case(op1)
				`OPCODE_80	:	begin
								regop						=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];						//cur_inst[21:19];
						
								case(regop)							
									`AND_REG	:	begin				//80 /4 ib 	AND r/m8, imm8
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_AND_OP;
																alusel_o			=	`EXE_RES_LOGIC;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																opcode_len		= 8;
																cmdcode_len		=	8;
																
																reg1_addr_o[4:2]	=	rm;
																reg1_addr_o[1:0]	=	2'b00;
																
																disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																imm				= disp8;
																data_len	=	8;
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end	
									
									
									`OR_REG	:	begin
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_OR_OP;
																alusel_o			=	`EXE_RES_LOGIC;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																opcode_len		= 8;
																cmdcode_len		=	8;
																
																reg1_addr_o[4:2]	=	rm;
																reg1_addr_o[1:0]	=	2'b00;
																
																disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																imm				= disp8;
																data_len	=	8;
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end						
								
									`ADD_REG	:	begin				//80 /0 ib ADD r/m8, imm8
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_ADD_OP;
																alusel_o			=	`EXE_RES_ARITH;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																opcode_len		= 8;
																cmdcode_len		=	8;
																
																reg1_addr_o[4:2]	=	rm;
																reg1_addr_o[1:0]	=	2'b00;
																
																disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																imm				= disp8;
																data_len	=	8;
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end	
														
									`SUB_REG	:	begin				//	80 /5 ib	SUB r/m8, imm8
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_SUB_OP;
																alusel_o			=	`EXE_RES_ARITH;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																opcode_len		= 8;
																cmdcode_len		=	8;
																
																reg1_addr_o[4:2]	=	rm;
																reg1_addr_o[1:0]	=	2'b00;
																
																disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																imm				= disp8;
																data_len	=	8;
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
														
														
									`ADC_REG	:	begin				//	80 /2 ib ADC r/m8, imm8
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_ADC_OP;
																alusel_o			=	`EXE_RES_ARITH;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																opcode_len		= 8;
																cmdcode_len		=	8;
																
																reg1_addr_o[4:2]	=	rm;
																reg1_addr_o[1:0]	=	2'b00;
																
																disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																imm				= disp8;
																data_len	=	8;
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end	
										
										
										`SBB_REG	:	begin				//	80 /3 ib SBB r/m8, imm8
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_SBB_OP;
																alusel_o			=	`EXE_RES_ARITH;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																opcode_len		= 8;
																cmdcode_len		=	8;
																
																reg1_addr_o[4:2]	=	rm;
																reg1_addr_o[1:0]	=	2'b00;
																
																disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																imm				= disp8;
																data_len	=	8;
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end				
										
										`CMP_REG	:	begin				// 80 /7 ib CMP r/m8, imm8
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_CMP_OP;
																alusel_o			=	`EXE_RES_ARITH;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																opcode_len		= 8;
																cmdcode_len		=	8;
																
																reg1_addr_o[4:2]	=	rm;
																reg1_addr_o[1:0]	=	2'b00;
																
																disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																imm				= disp8;
																data_len	=	8;
																
																wd_o			=	`EFLAGS;															
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end				
														
															
										default:	begin
														end											
																	
								endcase
								
						end	
						
				`OPCODE_81	:	begin
								regop						=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];						//cur_inst[21:19];
						
								case(regop)						
									`AND_REG	:	begin
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_AND_OP;
																alusel_o			=	`EXE_RES_LOGIC;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];
																opcode_len		=	8;	
																cmdcode_len		=	8;
																
																reg1_addr_o[4:2]	=	rm;
																
																if(pre_66 == `True_v)	begin		//81 /4 id AND r/m32, imm32 																
																	reg1_addr_o[1:0]	=	2'b11;
																	
																	disp32						=	{32'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 48)]};	//{16'h0, cur_inst[32:0]};																					
																	imm								= disp32;
																	data_len					=	32;
																	
																	//modi on 2015-10-24
																	if(`LITTLE_END == `True_v)	begin
																		imm = ((imm & 32'h000000FF)<<24) | ((imm & 32'h0000FF00)<<8) | ((imm & 32'h00FF0000) >>8) | ((imm & 32'hFF000000) >>24)  ;
																	end 
																
																end else begin		//81 /4 iw  AND r/m16, imm16 	
																	reg1_addr_o[1:0]	=	2'b01;
																	
																	disp16						=	{16'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 32)]};	//{16'h0, cur_inst[32:0]};																					
																	imm								= disp16;
																	data_len					=	16;
																	
																	//modi on 2015-10-24
																	if(`LITTLE_END == `True_v)	begin
																		imm = ((imm & 16'h00FF)<<8)  | ((imm & 16'hFF00) >>8)  ;
																	end 
																end										
																
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len + cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
														
														
									`OR_REG	:	begin
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_OR_OP;
																alusel_o			=	`EXE_RES_LOGIC;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																opcode_len		= 8;
																cmdcode_len		=	8;
																
																reg1_addr_o[4:2]	=	rm;
																
																if(pre_66 == `True_v)	begin		//81 /1 id OR r/m32, imm32 																
																	reg1_addr_o[1:0]	=	2'b11;
																	
																	disp32						=	{32'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 48)]};	//{16'h0, cur_inst[32:0]};																					
																	imm								= disp32;
																	data_len					=	32;
																	
																	//modi on 2015-10-24
																	if(`LITTLE_END == `True_v)	begin
																		imm = ((imm & 32'h000000FF)<<24) | ((imm & 32'h0000FF00)<<8) | ((imm & 32'h00FF0000) >>8) | ((imm & 32'hFF000000) >>24)  ;
																	end 
																
																end else begin		//81 /1 iw OR r/m16, imm16 	
																	reg1_addr_o[1:0]	=	2'b01;
																	
																	disp16						=	{16'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 32)]};	//{16'h0, cur_inst[32:0]};																					
																	imm								= disp16;
																	data_len					=	16;
																	
																	//modi on 2015-10-24
																	if(`LITTLE_END == `True_v)	begin
																		imm = ((imm & 16'h00FF)<<8)  | ((imm & 16'hFF00) >>8)  ;
																	end
																end
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
														
									`ADD_REG	:	begin
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_ADD_OP;
																alusel_o			=	`EXE_RES_ARITH;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];
																opcode_len		=	8;	
																cmdcode_len		=	8;
																
																reg1_addr_o[4:2]	=	rm;
																
																if(pre_66 == `True_v)	begin		//81 /0 id ADD r/m32, imm32 																
																	reg1_addr_o[1:0]	=	2'b11;
																	
																	disp32						=	{32'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 48)]};	//{16'h0, cur_inst[32:0]};																					
																	imm								= disp32;
																	data_len					=	32;
																	
																	//modi on 2015-10-24
																	if(`LITTLE_END == `True_v)	begin
																		imm = ((imm & 32'h000000FF)<<24) | ((imm & 32'h0000FF00)<<8) | ((imm & 32'h00FF0000) >>8) | ((imm & 32'hFF000000) >>24)  ;
																	end 
																
																end else begin								//81 /0 iw ADD r/m16, imm16 	
																	reg1_addr_o[1:0]	=	2'b01;
																	
																	disp16						=	{16'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 32)]};	//{16'h0, cur_inst[32:0]};																					
																	imm								= disp16;
																	data_len					=	16;
																	
																	//modi on 2015-10-24
																	if(`LITTLE_END == `True_v)	begin
																		imm = ((imm & 16'h00FF)<<8)  | ((imm & 16'hFF00) >>8)  ;
																	end
																end
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len + cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
														
														
									`SUB_REG	:	begin
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_SUB_OP;
																alusel_o			=	`EXE_RES_ARITH;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];
																opcode_len		=	8;	
																cmdcode_len		=	8;
																
																reg1_addr_o[4:2]	=	rm;
																
																if(pre_66 == `True_v)	begin		//	81 /5 id SUB r/m32, imm32 																
																	reg1_addr_o[1:0]	=	2'b11;
																	
																	disp32						=	{32'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 48)]};	//{16'h0, cur_inst[32:0]};																					
																	imm								= disp32;
																	data_len					=	32;
																	
																	//modi on 2015-10-24
																	if(`LITTLE_END == `True_v)	begin
																		imm = ((imm & 32'h000000FF)<<24) | ((imm & 32'h0000FF00)<<8) | ((imm & 32'h00FF0000) >>8) | ((imm & 32'hFF000000) >>24)  ;
																	end 
																
																end else begin								//	81 /5 iw SUB r/m16, imm16 	
																	reg1_addr_o[1:0]	=	2'b01;
																	
																	disp16						=	{16'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 32)]};	//{16'h0, cur_inst[32:0]};																					
																	imm								= disp16;
																	data_len					=	16;
																	
																	//modi on 2015-10-24
																	if(`LITTLE_END == `True_v)	begin
																		imm = ((imm & 16'h00FF)<<8)  | ((imm & 16'hFF00) >>8)  ;
																	end
																end
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len + cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
									
									`ADC_REG	:	begin
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_ADC_OP;
																alusel_o			=	`EXE_RES_ARITH;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];
																opcode_len		=	8;	
																cmdcode_len		=	8;
																
																reg1_addr_o[4:2]	=	rm;
																
																if(pre_66 == `True_v)	begin		//	81 /2 id ADC r/m32, imm32 																
																	reg1_addr_o[1:0]	=	2'b11;
																	
																	disp32						=	{32'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 48)]};	//{16'h0, cur_inst[32:0]};																					
																	imm								= disp32;
																	data_len					=	32;
																	
																	//modi on 2015-10-24
																	if(`LITTLE_END == `True_v)	begin
																		imm = ((imm & 32'h000000FF)<<24) | ((imm & 32'h0000FF00)<<8) | ((imm & 32'h00FF0000) >>8) | ((imm & 32'hFF000000) >>24)  ;
																	end 
																
																end else begin								//	81 /2 iw ADC r/m16, imm16	
																	reg1_addr_o[1:0]	=	2'b01;
																	
																	disp16						=	{16'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 32)]};	//{16'h0, cur_inst[32:0]};																					
																	imm								= disp16;
																	data_len					=	16;
																	
																	//modi on 2015-10-24
																	if(`LITTLE_END == `True_v)	begin
																		imm = ((imm & 16'h00FF)<<8)  | ((imm & 16'hFF00) >>8)  ;
																	end
																end
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len + cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
									
									
									`SBB_REG	:	begin
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_SBB_OP;
																alusel_o			=	`EXE_RES_ARITH;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];
																opcode_len		=	8;	
																cmdcode_len		=	8;
																
																reg1_addr_o[4:2]	=	rm;
																
																if(pre_66 == `True_v)	begin		//	81 /3 id SBB r/m32, imm32 																
																	reg1_addr_o[1:0]	=	2'b11;
																	
																	disp32						=	{32'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 48)]};	//{16'h0, cur_inst[32:0]};																					
																	imm								= disp32;
																	data_len					=	32;
																	
																	//modi on 2015-10-24
																	if(`LITTLE_END == `True_v)	begin
																		imm = ((imm & 32'h000000FF)<<24) | ((imm & 32'h0000FF00)<<8) | ((imm & 32'h00FF0000) >>8) | ((imm & 32'hFF000000) >>24)  ;
																	end 
																
																end else begin								//	81 /3 iw SBB r/m16, imm16 	
																	reg1_addr_o[1:0]	=	2'b01;
																	
																	disp16						=	{16'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 32)]};	//{16'h0, cur_inst[32:0]};																					
																	imm								= disp16;
																	data_len					=	16;
																	
																	//modi on 2015-10-24
																	if(`LITTLE_END == `True_v)	begin
																		imm = ((imm & 16'h00FF)<<8)  | ((imm & 16'hFF00) >>8)  ;
																	end
																end
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len + cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end	
									
									`CMP_REG	:	begin
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_CMP_OP;
																alusel_o			=	`EXE_RES_ARITH;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];
																opcode_len		=	8;	
																cmdcode_len		=	8;
																
																reg1_addr_o[4:2]	=	rm;
																
																if(pre_66 == `True_v)	begin		//81 /7 id CMP r/m32, imm32 																
																	reg1_addr_o[1:0]	=	2'b11;
																	
																	disp32						=	{32'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 48)]};	//{16'h0, cur_inst[32:0]};																					
																	imm								= disp32;
																	data_len					=	32;
																	
																	//modi on 2015-10-24
																	if(`LITTLE_END == `True_v)	begin
																		imm = ((imm & 32'h000000FF)<<24) | ((imm & 32'h0000FF00)<<8) | ((imm & 32'h00FF0000) >>8) | ((imm & 32'hFF000000) >>24)  ;
																	end 
																
																end else begin								//81 /7 iw CMP r/m16, imm16	
																	reg1_addr_o[1:0]	=	2'b01;
																	
																	disp16						=	{16'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 32)]};	//{16'h0, cur_inst[32:0]};																					
																	imm								= disp16;
																	data_len					=	16;
																	
																	//modi on 2015-10-24
																	if(`LITTLE_END == `True_v)	begin
																		imm = ((imm & 16'h00FF)<<8)  | ((imm & 16'hFF00) >>8)  ;
																	end
																end
																
																wd_o			=	`EFLAGS ;															
																
																tot_len		=	opcode_len + cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end	
									
									
															
										default:	begin
														end											
																	
								endcase
								
						end	
						
				`OPCODE_83	:	begin
								regop						=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];						//cur_inst[21:19];
						
								case(regop)			//83 /4 ib  AND r/m16, imm8 				
									`AND_REG	:	begin
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_AND_OP;
																alusel_o			=	`EXE_RES_LOGIC;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];
																opcode_len		=	8;	
																cmdcode_len		=	8;
																
																reg1_addr_o[4:2]	=	rm;
																
																//modi on 2015-10-24
																if(pre_66 == `True_v)	begin																
																	reg1_addr_o[1:0]	=	2'b11;
																	disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																	imm				= disp8;
																	data_len	=	8;
																	
																	//if(`LITTLE_END == `True_v)	begin
																	//		imm = ((imm & 32'h000000FF)<<24) | ((imm & 32'h0000FF00)<<8) | ((imm & 32'h00FF0000) >>8) | ((imm & 32'hFF000000) >>24)  ;
																	//end
																end else begin
																	reg1_addr_o[1:0]	=	2'b01;
																	disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																	imm				= disp8;
																	data_len	=	8;																	
																	
																	//if(`LITTLE_END == `True_v)	begin
																	//	imm = ((imm & 16'h00FF)<<8)  | ((imm & 16'hFF00) >>8)  ;
																	//end
																end		
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len + cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end	
														
									`OR_REG	:	begin
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_OR_OP;
																alusel_o			=	`EXE_RES_LOGIC;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																opcode_len		= 8;
																cmdcode_len		=	8;
																
																reg1_addr_o[4:2]	=	rm;
																
																//modi on 2015-10-24
																if(pre_66 == `True_v)	begin																
																	reg1_addr_o[1:0]	=	2'b11;
																	disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																	imm				= disp8;
																	data_len	=	8;
																	
																	//if(`LITTLE_END == `True_v)	begin
																	//		imm = ((imm & 32'h000000FF)<<24) | ((imm & 32'h0000FF00)<<8) | ((imm & 32'h00FF0000) >>8) | ((imm & 32'hFF000000) >>24)  ;
																	//end
																end else begin
																	reg1_addr_o[1:0]	=	2'b01;
																	disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																	imm				= disp8;
																	data_len	=	8;																	
																	
																	//if(`LITTLE_END == `True_v)	begin
																	//	imm = ((imm & 16'h00FF)<<8)  | ((imm & 16'hFF00) >>8)  ;
																	//end
																end		
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end	
														
									`ADD_REG	:	begin					
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_ADD_OP;
																alusel_o			=	`EXE_RES_ARITH;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];
																opcode_len		=	8;	
																cmdcode_len		=	8;
																
																reg1_addr_o[4:2]	=	rm;
																
																//modi on 2015-10-24
																if(pre_66 == `True_v)	begin																
																	reg1_addr_o[1:0]	=	2'b11;
																	disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																	imm				= disp8;
																	data_len	=	8;
																	
																	//if(`LITTLE_END == `True_v)	begin
																	//		imm = ((imm & 32'h000000FF)<<24) | ((imm & 32'h0000FF00)<<8) | ((imm & 32'h00FF0000) >>8) | ((imm & 32'hFF000000) >>24)  ;
																	//end
																end else begin
																	reg1_addr_o[1:0]	=	2'b01;
																	disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																	imm				= disp8;
																	data_len	=	8;																	
																	
																	//if(`LITTLE_END == `True_v)	begin
																	//	imm = ((imm & 16'h00FF)<<8)  | ((imm & 16'hFF00) >>8)  ;
																	//end
																end		
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len + cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
									
									`SUB_REG	:	begin					
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_SUB_OP;
																alusel_o			=	`EXE_RES_ARITH;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];
																opcode_len		=	8;	
																cmdcode_len		=	8;
																
																reg1_addr_o[4:2]	=	rm;
																
																//modi on 2015-10-24
																if(pre_66 == `True_v)	begin																
																	reg1_addr_o[1:0]	=	2'b11;
																	disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																	imm				= disp8;
																	data_len	=	8;
																	
																	//if(`LITTLE_END == `True_v)	begin
																	//		imm = ((imm & 32'h000000FF)<<24) | ((imm & 32'h0000FF00)<<8) | ((imm & 32'h00FF0000) >>8) | ((imm & 32'hFF000000) >>24)  ;
																	//end
																end else begin
																	reg1_addr_o[1:0]	=	2'b01;
																	disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																	imm				= disp8;
																	data_len	=	8;																	
																	
																	//if(`LITTLE_END == `True_v)	begin
																	//	imm = ((imm & 16'h00FF)<<8)  | ((imm & 16'hFF00) >>8)  ;
																	//end
																end		
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len + cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
									
									`ADC_REG	:	begin					
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_ADC_OP;
																alusel_o			=	`EXE_RES_ARITH;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];
																opcode_len		=	8;	
																cmdcode_len		=	8;
																
																reg1_addr_o[4:2]	=	rm;
																
																//modi on 2015-10-24
																if(pre_66 == `True_v)	begin																
																	reg1_addr_o[1:0]	=	2'b11;
																	disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																	imm				= disp8;
																	data_len	=	8;
																	
																	//if(`LITTLE_END == `True_v)	begin
																	//		imm = ((imm & 32'h000000FF)<<24) | ((imm & 32'h0000FF00)<<8) | ((imm & 32'h00FF0000) >>8) | ((imm & 32'hFF000000) >>24)  ;
																	//end
																end else begin
																	reg1_addr_o[1:0]	=	2'b01;
																	disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																	imm				= disp8;
																	data_len	=	8;																	
																	
																	//if(`LITTLE_END == `True_v)	begin
																	//	imm = ((imm & 16'h00FF)<<8)  | ((imm & 16'hFF00) >>8)  ;
																	//end
																end		
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len + cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
									
									`SBB_REG	:	begin					
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_SBB_OP;
																alusel_o			=	`EXE_RES_ARITH;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];
																opcode_len		=	8;	
																cmdcode_len		=	8;
																
																reg1_addr_o[4:2]	=	rm;
																
																//modi on 2015-10-24
																if(pre_66 == `True_v)	begin																
																	reg1_addr_o[1:0]	=	2'b11;
																	disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																	imm				= disp8;
																	data_len	=	8;
																	
																	//if(`LITTLE_END == `True_v)	begin
																	//		imm = ((imm & 32'h000000FF)<<24) | ((imm & 32'h0000FF00)<<8) | ((imm & 32'h00FF0000) >>8) | ((imm & 32'hFF000000) >>24)  ;
																	//end
																end else begin
																	reg1_addr_o[1:0]	=	2'b01;
																	disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																	imm				= disp8;
																	data_len	=	8;																	
																	
																	//if(`LITTLE_END == `True_v)	begin
																	//	imm = ((imm & 16'h00FF)<<8)  | ((imm & 16'hFF00) >>8)  ;
																	//end
																end			
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len + cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
									
									`CMP_REG	:	begin					
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_CMP_OP;
																alusel_o			=	`EXE_RES_ARITH;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];
																opcode_len		=	8;	
																cmdcode_len		=	8;
																
																reg1_addr_o[4:2]	=	rm;
																
																//modi on 2015-10-24
																if(pre_66 == `True_v)	begin																
																	reg1_addr_o[1:0]	=	2'b11;
																	disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																	imm				= disp8;
																	data_len	=	8;
																end else begin
																	reg1_addr_o[1:0]	=	2'b01;
																	disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																	imm				= disp8;
																	data_len	=	8;	
																end		
																
																wd_o			=	`EFLAGS ;															
																
																tot_len		=	opcode_len + cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
														
															
										default:	begin
														end											
																	
								endcase
								
						end
						
					
				`OPCODE_00	:	begin		//	00 /r ADD r/m8, r8
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_ADD_OP;
								alusel_o			=	`EXE_RES_ARITH;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;
																
								mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
								regop					=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];	
								rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];								
									
								if(mod == 2'b11)	begin
									reg1_addr_o[4:2]	=	rm;
									reg1_addr_o[1:0]	=	2'b00;
									
									reg2_addr_o[4:2]	=	regop;
									reg2_addr_o[1:0]	=	2'b00;
								end else begin
								
								end	
														
								opcode_len		= 8;
								cmdcode_len		=	8;	
								data_len			= 0;						
																
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end
				
				`OPCODE_01	:	begin		
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_ADD_OP;
								alusel_o			=	`EXE_RES_ARITH;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;
																
								mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
								regop					=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];	
								rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];								
									
								if(mod == 2'b11)	begin		
									if(pre_66 == `True_v)	begin			//	01 /r ADD r/m32, r32
										reg1_addr_o[4:2]	=	rm;
										reg1_addr_o[1:0]	=	2'b11;
										
										reg2_addr_o[4:2]	=	regop;
										reg2_addr_o[1:0]	=	2'b11;
									end else begin									//	01 /r ADD r/m16, r16
										reg1_addr_o[4:2]	=	rm;
										reg1_addr_o[1:0]	=	2'b01;
										
										reg2_addr_o[4:2]	=	regop;
										reg2_addr_o[1:0]	=	2'b01;
									end
									
								end else begin
								
								end	
														
								opcode_len		= 8;
								cmdcode_len		=	8;	
								data_len			= 0;						
																
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;		
								
													
						end
				
				`OPCODE_02	:	begin		// 02 /r ADD r8, r/m8
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_ADD_OP;
								alusel_o			=	`EXE_RES_ARITH;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;
																
								mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
								regop					=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];	
								rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];								
									
								if(mod == 2'b11)	begin
									reg1_addr_o[4:2]	=	rm;
									reg1_addr_o[1:0]	=	2'b00;
									
									reg2_addr_o[4:2]	=	regop;
									reg2_addr_o[1:0]	=	2'b00;
								end else begin
								
								end	
														
								opcode_len		= 8;
								cmdcode_len		=	8;	
								data_len			= 0;						
																
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end
						
				`OPCODE_03	:	begin		
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_ADD_OP;
								alusel_o			=	`EXE_RES_ARITH;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;
																
								mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
								regop					=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];	
								rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];								
									
								if(mod == 2'b11)	begin		
									if(pre_66 == `True_v)	begin			//	03 /r ADD r32, r/m32
										reg1_addr_o[4:2]	=	rm;
										reg1_addr_o[1:0]	=	2'b11;
										
										reg2_addr_o[4:2]	=	regop;
										reg2_addr_o[1:0]	=	2'b11;
									end else begin									//	03 /r ADD r16, r/m16
										reg1_addr_o[4:2]	=	rm;
										reg1_addr_o[1:0]	=	2'b01;
										
										reg2_addr_o[4:2]	=	regop;
										reg2_addr_o[1:0]	=	2'b01;
									end
									
								end else begin
								
								end	
														
								opcode_len		= 8;
								cmdcode_len		=	8;	
								data_len			= 0;						
																
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end		
					
				
				`OPCODE_04	:	begin		//04 ib ADD AL, imm8
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_ADD_OP;
								alusel_o			=	`EXE_RES_ARITH;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b0;
																
																
								opcode_len		= 8;
								cmdcode_len		=	0;
																
								reg1_addr_o[4:2]	=	3'b000;
								reg1_addr_o[1:0]	=	2'b00;
																
								disp8			=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 16)]};	//{16'h0, cur_inst[32:0]};																					
								imm				= disp8;
								data_len	=	8;
																
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end
						
				`OPCODE_05	:	begin		
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_ADD_OP;
								alusel_o			=	`EXE_RES_ARITH;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b0;
																
																
								opcode_len		= 8;
								cmdcode_len		=	0;
												
								if(pre_66 == `True_v)	begin			//05 id ADD EAX, imm32
											reg1_addr_o[4:2]	=	3'b000;
											reg1_addr_o[1:0]	=	2'b11;
											
											disp32						=	{32'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 40)]};	//{16'h0, cur_inst[32:0]};																					
											imm								= disp32;
											data_len					=	32;
											
											//modi on 2015-10-24
											if(`LITTLE_END == `True_v)	begin
												imm = ((imm & 32'h000000FF)<<24) | ((imm & 32'h0000FF00)<<8) | ((imm & 32'h00FF0000) >>8) | ((imm & 32'hFF000000) >>24)  ;
											end
									
								end else begin									//05 iw ADD AX, imm16										
											reg1_addr_o[4:2]	=	3'b000;
											reg1_addr_o[1:0]	=	2'b01;
											
											disp16						=	{16'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
											imm								= disp16;
											data_len					=	16;
											
											//modi on 2015-10-24
											if(`LITTLE_END == `True_v)	begin
												imm = ((imm & 16'h00FF)<<8)  | ((imm & 16'hFF00) >>8)  ;
											end
								end
								
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end					
				
				`OPCODE_06	:	begin							//06 PUSH ES
								wreg_o				=	`WriteEnable;	
								aluop_o				=	`EXE_PUSH_REG16_OP;															
								alusel_o			=	`EXE_RES_MOV;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;	
								
								reg1_addr_o		=	`ES;
								reg2_addr_o		=	`ESP;
								
								wd_o					=	reg2_addr_o ;								//更新esp	
								
								opcode_len		= 8;
								cmdcode_len		=	0;
								data_len			=	0;
								
								tot_len				=	opcode_len	+ cmdcode_len	+ data_len;
																							
								instvalid			=	`InstValid;
						end
				
				`OPCODE_07	:	begin							//07 POP ES
								wreg_o				=	`WriteEnable;	
								aluop_o				=	`EXE_POP_REG16_OP;															
								alusel_o			=	`EXE_RES_MOV;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;	
								
								reg1_addr_o		=	`ES;
								reg2_addr_o		=	`ESP;
								
								wd_o					=	reg1_addr_o ;								//
								
								opcode_len		= 8;
								cmdcode_len		=	0;
								data_len			=	0;
								
								tot_len				=	opcode_len	+ cmdcode_len	+ data_len;
																							
								instvalid			=	`InstValid;
						end		
				
				`OPCODE_08	:	begin		//08 /r OR r/m8, r8
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_OR_OP;
								alusel_o			=	`EXE_RES_LOGIC;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;
																
								mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
								regop					=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];	
								rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];								
									
								if(mod == 2'b11)	begin
									reg1_addr_o[4:2]	=	rm;
									reg1_addr_o[1:0]	=	2'b00;
									
									reg2_addr_o[4:2]	=	regop;
									reg2_addr_o[1:0]	=	2'b00;
								end else begin
								
								end	
														
								opcode_len		= 8;
								cmdcode_len		=	8;	
								data_len			= 0;						
																
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end
						
						
				`OPCODE_09	:	begin		
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_OR_OP;
								alusel_o			=	`EXE_RES_LOGIC;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;
																
								mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
								regop					=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];	
								rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];								
									
								if(mod == 2'b11)	begin		
									if(pre_66 == `True_v)	begin			//	09 /r OR r/m32, r32
										reg1_addr_o[4:2]	=	rm;
										reg1_addr_o[1:0]	=	2'b11;
										
										reg2_addr_o[4:2]	=	regop;
										reg2_addr_o[1:0]	=	2'b11;
									end else begin									//	09 /r OR r/m16, r16
										reg1_addr_o[4:2]	=	rm;
										reg1_addr_o[1:0]	=	2'b01;
										
										reg2_addr_o[4:2]	=	regop;
										reg2_addr_o[1:0]	=	2'b01;
									end
									
								end else begin
								
								end	
														
								opcode_len		= 8;
								cmdcode_len		=	8;	
								data_len			= 0;						
																
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end	
						
				`OPCODE_0A	:	begin		//0A /r OR r8, r/m8
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_OR_OP;
								alusel_o			=	`EXE_RES_LOGIC;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;
																
								mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
								regop					=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];	
								rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];								
									
								if(mod == 2'b11)	begin
									reg1_addr_o[4:2]	=	rm;
									reg1_addr_o[1:0]	=	2'b00;
									
									reg2_addr_o[4:2]	=	regop;
									reg2_addr_o[1:0]	=	2'b00;
								end else begin
								
								end	
														
								opcode_len		= 8;
								cmdcode_len		=	8;	
								data_len			= 0;						
																
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end
						
						
				`OPCODE_0B	:	begin		
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_OR_OP;
								alusel_o			=	`EXE_RES_LOGIC;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;
																
								mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
								regop					=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];	
								rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];								
									
								if(mod == 2'b11)	begin		
									if(pre_66 == `True_v)	begin			//	0B /r OR r32, r/m32
										reg1_addr_o[4:2]	=	rm;
										reg1_addr_o[1:0]	=	2'b11;
										
										reg2_addr_o[4:2]	=	regop;
										reg2_addr_o[1:0]	=	2'b11;
									end else begin									//	0B /r OR r16, r/m16
										reg1_addr_o[4:2]	=	rm;
										reg1_addr_o[1:0]	=	2'b01;
										
										reg2_addr_o[4:2]	=	regop;
										reg2_addr_o[1:0]	=	2'b01;
									end
									
								end else begin
								
								end	
														
								opcode_len		= 8;
								cmdcode_len		=	8;	
								data_len			= 0;						
																
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end
				
				
				`OPCODE_0C	:	begin		//0C ib	OR AL, imm8
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_OR_OP;
								alusel_o			=	`EXE_RES_LOGIC;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b0;
																
																
								opcode_len		= 8;
								cmdcode_len		=	0;
																
								reg1_addr_o[4:2]	=	3'b000;
								reg1_addr_o[1:0]	=	2'b00;
																
								disp8			=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 16)]};	//{16'h0, cur_inst[32:0]};																					
								imm				= disp8;
								data_len	=	8;
																
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end
						
						
			`OPCODE_0D	:	begin		//0D iw AND AX, imm16
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_OR_OP;
								alusel_o			=	`EXE_RES_LOGIC;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b0;
																
																
								opcode_len		= 8;
								cmdcode_len		=	0;
												
								if(pre_66 == `True_v)	begin
									reg1_addr_o[4:2]	=	3'b000;
									reg1_addr_o[1:0]	=	2'b11;
									
									disp32						=	{32'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 40)]};	//{16'h0, cur_inst[32:0]};																					
									imm								= disp32;
									data_len					=	32;
									
									//modi on 2015-10-24
									if(`LITTLE_END == `True_v)	begin
										imm = ((imm & 32'h000000FF)<<24) | ((imm & 32'h0000FF00)<<8) | ((imm & 32'h00FF0000) >>8) | ((imm & 32'hFF000000) >>24)  ;
									end
								end else begin																		
									reg1_addr_o[4:2]	=	3'b000;
									reg1_addr_o[1:0]	=	2'b01;
									
									disp16						=	{16'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
									imm								= disp16;
									data_len					=	16;
									
									//modi on 2015-10-24
									if(`LITTLE_END == `True_v)	begin
										imm = ((imm & 16'h00FF)<<8)  | ((imm & 16'hFF00) >>8)  ;
									end
								end												
								
																
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end
						
				`OPCODE_0E	:	begin							//0E PUSH CS
								wreg_o				=	`WriteEnable;	
								aluop_o				=	`EXE_PUSH_REG16_OP;															
								alusel_o			=	`EXE_RES_MOV;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;	
								
								reg1_addr_o		=	`CS;
								reg2_addr_o		=	`ESP;
								
								wd_o					=	reg2_addr_o ;								//更新esp	
								
								opcode_len		= 8;
								cmdcode_len		=	0;
								data_len			=	0;
								
								tot_len				=	opcode_len	+ cmdcode_len	+ data_len;
																							
								instvalid			=	`InstValid;
						end
						
				
				`OPCODE_10	:	begin		//	10 /r ADC r/m8, r8
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_ADC_OP;
								alusel_o			=	`EXE_RES_ARITH;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;
																
								mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
								regop					=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];	
								rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];								
									
								if(mod == 2'b11)	begin
									reg1_addr_o[4:2]	=	rm;
									reg1_addr_o[1:0]	=	2'b00;
									
									reg2_addr_o[4:2]	=	regop;
									reg2_addr_o[1:0]	=	2'b00;
								end else begin
								
								end	
														
								opcode_len		= 8;
								cmdcode_len		=	8;	
								data_len			= 0;						
																
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end
				
				`OPCODE_11	:	begin		
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_ADC_OP;
								alusel_o			=	`EXE_RES_ARITH;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;
																
								mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
								regop					=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];	
								rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];								
									
								if(mod == 2'b11)	begin		
									if(pre_66 == `True_v)	begin			//	11 /r ADC r/m32, r32
										reg1_addr_o[4:2]	=	rm;
										reg1_addr_o[1:0]	=	2'b11;
										
										reg2_addr_o[4:2]	=	regop;
										reg2_addr_o[1:0]	=	2'b11;
									end else begin									//	11 /r ADC r/m16, r16
										reg1_addr_o[4:2]	=	rm;
										reg1_addr_o[1:0]	=	2'b01;
										
										reg2_addr_o[4:2]	=	regop;
										reg2_addr_o[1:0]	=	2'b01;
									end
									
								end else begin
								
								end	
														
								opcode_len		= 8;
								cmdcode_len		=	8;	
								data_len			= 0;						
																
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end
				
				`OPCODE_12	:	begin		// 12 /r ADC r8, r/m8
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_ADC_OP;
								alusel_o			=	`EXE_RES_ARITH;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;
																
								mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
								regop					=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];	
								rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];								
									
								if(mod == 2'b11)	begin
									reg1_addr_o[4:2]	=	rm;
									reg1_addr_o[1:0]	=	2'b00;
									
									reg2_addr_o[4:2]	=	regop;
									reg2_addr_o[1:0]	=	2'b00;
								end else begin
								
								end	
														
								opcode_len		= 8;
								cmdcode_len		=	8;	
								data_len			= 0;						
																
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end
						
				`OPCODE_13	:	begin		
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_ADC_OP;
								alusel_o			=	`EXE_RES_ARITH;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;
																
								mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
								regop					=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];	
								rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];								
									
								if(mod == 2'b11)	begin		
									if(pre_66 == `True_v)	begin			//	13 /r ADC r32, r/m32
										reg1_addr_o[4:2]	=	rm;
										reg1_addr_o[1:0]	=	2'b11;
										
										reg2_addr_o[4:2]	=	regop;
										reg2_addr_o[1:0]	=	2'b11;
									end else begin									//	13 /r ADC r16, r/m16
										reg1_addr_o[4:2]	=	rm;
										reg1_addr_o[1:0]	=	2'b01;
										
										reg2_addr_o[4:2]	=	regop;
										reg2_addr_o[1:0]	=	2'b01;
									end
									
								end else begin
								
								end	
														
								opcode_len		= 8;
								cmdcode_len		=	8;	
								data_len			= 0;						
																
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end	
				
					
				`OPCODE_14	:	begin		//	14 ib ADC AL, imm8
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_ADC_OP;
								alusel_o			=	`EXE_RES_ARITH;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b0;
																
																
								opcode_len		= 8;
								cmdcode_len		=	0;
																
								reg1_addr_o[4:2]	=	3'b000;
								reg1_addr_o[1:0]	=	2'b00;
																
								disp8			=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 16)]};	//{16'h0, cur_inst[32:0]};																					
								imm				= disp8;
								data_len	=	8;
																
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end
						
				`OPCODE_15	:	begin		
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_ADC_OP;
								alusel_o			=	`EXE_RES_ARITH;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b0;
																
																
								opcode_len		= 8;
								cmdcode_len		=	0;
												
								if(pre_66 == `True_v)	begin			//	15 id ADC EAX, imm32
									reg1_addr_o[4:2]	=	3'b000;
									reg1_addr_o[1:0]	=	2'b11;
									
									disp32						=	{32'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 40)]};	//{16'h0, cur_inst[32:0]};																					
									imm								= disp32;
									data_len					=	32;
									
									//modi on 2015-10-24
									if(`LITTLE_END == `True_v)	begin
										imm = ((imm & 32'h000000FF)<<24) | ((imm & 32'h0000FF00)<<8) | ((imm & 32'h00FF0000) >>8) | ((imm & 32'hFF000000) >>24)  ;
									end
									
								end else begin									//	15 iw ADC AX, imm16									
									reg1_addr_o[4:2]	=	3'b000;
									reg1_addr_o[1:0]	=	2'b01;
									
									disp16						=	{16'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
									imm								= disp16;
									data_len					=	16;
									
									//modi on 2015-10-24
									if(`LITTLE_END == `True_v)	begin
										imm = ((imm & 16'h00FF)<<8)  | ((imm & 16'hFF00) >>8)  ;
									end
								end
								
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end
				
				`OPCODE_16	:	begin							//16 PUSH SS
								wreg_o				=	`WriteEnable;	
								aluop_o				=	`EXE_PUSH_REG16_OP;															
								alusel_o			=	`EXE_RES_MOV;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;	
								
								reg1_addr_o		=	`SS;
								reg2_addr_o		=	`ESP;
								
								wd_o					=	reg2_addr_o ;								//更新esp	
								
								opcode_len		= 8;
								cmdcode_len		=	0;
								data_len			=	0;
								
								tot_len				=	opcode_len	+ cmdcode_len	+ data_len;
																							
								instvalid			=	`InstValid;
						end
				
				`OPCODE_17	:	begin							//	17 POP SS
								wreg_o				=	`WriteEnable;	
								aluop_o				=	`EXE_POP_REG16_OP;															
								alusel_o			=	`EXE_RES_MOV;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;	
								
								reg1_addr_o		=	`SS;
								reg2_addr_o		=	`ESP;
								
								wd_o					=	reg1_addr_o ;								//
								
								opcode_len		= 8;
								cmdcode_len		=	0;
								data_len			=	0;
								
								tot_len				=	opcode_len	+ cmdcode_len	+ data_len;
																							
								instvalid			=	`InstValid;
						end
						
						
				`OPCODE_18	:	begin		//	18 /r SBB r/m8, r8
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_SBB_OP;
								alusel_o			=	`EXE_RES_ARITH;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;
																
								mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
								regop					=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];	
								rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];								
									
								if(mod == 2'b11)	begin
									reg1_addr_o[4:2]	=	rm;
									reg1_addr_o[1:0]	=	2'b00;
									
									reg2_addr_o[4:2]	=	regop;
									reg2_addr_o[1:0]	=	2'b00;
								end else begin
								
								end	
														
								opcode_len		= 8;
								cmdcode_len		=	8;	
								data_len			= 0;						
																
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end
				
				`OPCODE_19	:	begin		
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_SBB_OP;
								alusel_o			=	`EXE_RES_ARITH;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;
																
								mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
								regop					=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];	
								rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];								
									
								if(mod == 2'b11)	begin		
									if(pre_66 == `True_v)	begin			//	19 /r SBB r/m32, r32
										reg1_addr_o[4:2]	=	rm;
										reg1_addr_o[1:0]	=	2'b11;
										
										reg2_addr_o[4:2]	=	regop;
										reg2_addr_o[1:0]	=	2'b11;
									end else begin									//	19 /r SBB r/m16, r16
										reg1_addr_o[4:2]	=	rm;
										reg1_addr_o[1:0]	=	2'b01;
										
										reg2_addr_o[4:2]	=	regop;
										reg2_addr_o[1:0]	=	2'b01;
									end
									
								end else begin
								
								end	
														
								opcode_len		= 8;
								cmdcode_len		=	8;	
								data_len			= 0;						
																
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end
				
				`OPCODE_1A	:	begin		// 1A /r SBB r8, r/m8
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_SBB_OP;
								alusel_o			=	`EXE_RES_ARITH;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;
																
								mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
								regop					=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];	
								rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];								
									
								if(mod == 2'b11)	begin
									reg1_addr_o[4:2]	=	rm;
									reg1_addr_o[1:0]	=	2'b00;
									
									reg2_addr_o[4:2]	=	regop;
									reg2_addr_o[1:0]	=	2'b00;
								end else begin
								
								end	
														
								opcode_len		= 8;
								cmdcode_len		=	8;	
								data_len			= 0;						
																
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end
						
				`OPCODE_1B	:	begin		
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_SBB_OP;
								alusel_o			=	`EXE_RES_ARITH;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;
																
								mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
								regop					=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];	
								rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];								
									
								if(mod == 2'b11)	begin		
									if(pre_66 == `True_v)	begin			//	1B /r SBB r32, r/m32
										reg1_addr_o[4:2]	=	rm;
										reg1_addr_o[1:0]	=	2'b11;
										
										reg2_addr_o[4:2]	=	regop;
										reg2_addr_o[1:0]	=	2'b11;
									end else begin									//	1B /r SBB r16, r/m16
										reg1_addr_o[4:2]	=	rm;
										reg1_addr_o[1:0]	=	2'b01;
										
										reg2_addr_o[4:2]	=	regop;
										reg2_addr_o[1:0]	=	2'b01;
									end
									
								end else begin
								
								end	
														
								opcode_len		= 8;
								cmdcode_len		=	8;	
								data_len			= 0;						
																
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end		
						
				
				`OPCODE_1C	:	begin		//	1C ib SBB AL, imm8
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_SBB_OP;
								alusel_o			=	`EXE_RES_ARITH;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b0;
																
																
								opcode_len		= 8;
								cmdcode_len		=	0;
																
								reg1_addr_o[4:2]	=	3'b000;
								reg1_addr_o[1:0]	=	2'b00;
																
								disp8			=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 16)]};	//{16'h0, cur_inst[32:0]};																					
								imm				= disp8;
								data_len	=	8;
																
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end

						
				`OPCODE_1D	:	begin		
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_SBB_OP;
								alusel_o			=	`EXE_RES_ARITH;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b0;
																
																
								opcode_len		= 8;
								cmdcode_len		=	0;
												
								if(pre_66 == `True_v)	begin			//	1D id SBB EAX, imm32
									reg1_addr_o[4:2]	=	3'b000;
									reg1_addr_o[1:0]	=	2'b11;
									
									disp32						=	{32'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 40)]};	//{16'h0, cur_inst[32:0]};																					
									imm								= disp32;
									data_len					=	32;
									
									//modi on 2015-10-24
									if(`LITTLE_END == `True_v)	begin
										imm = ((imm & 32'h000000FF)<<24) | ((imm & 32'h0000FF00)<<8) | ((imm & 32'h00FF0000) >>8) | ((imm & 32'hFF000000) >>24)  ;
									end
									
								end else begin									// 	1D iw SBB AX, imm16										
									reg1_addr_o[4:2]	=	3'b000;
									reg1_addr_o[1:0]	=	2'b01;
									
									disp16						=	{16'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
									imm								= disp16;
									data_len					=	16;
									
									//modi on 2015-10-24
									if(`LITTLE_END == `True_v)	begin
										imm = ((imm & 16'h00FF)<<8)  | ((imm & 16'hFF00) >>8)  ;
									end
								end
								
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end
				
				
				`OPCODE_1E	:	begin							//1E PUSH DS
								wreg_o				=	`WriteEnable;	
								aluop_o				=	`EXE_PUSH_REG16_OP;															
								alusel_o			=	`EXE_RES_MOV;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;	
								
								reg1_addr_o		=	`DS;
								reg2_addr_o		=	`ESP;
								
								wd_o					=	reg2_addr_o ;								//更新esp	
								
								opcode_len		= 8;
								cmdcode_len		=	0;
								data_len			=	0;
								
								tot_len				=	opcode_len	+ cmdcode_len	+ data_len;
																							
								instvalid			=	`InstValid;
						end
				
				`OPCODE_1F	:	begin							//1F POP DS
								wreg_o				=	`WriteEnable;	
								aluop_o				=	`EXE_POP_REG16_OP;															
								alusel_o			=	`EXE_RES_MOV;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;	
								
								reg1_addr_o		=	`DS;
								reg2_addr_o		=	`ESP;
								
								wd_o					=	reg1_addr_o ;								//
								
								opcode_len		= 8;
								cmdcode_len		=	0;
								data_len			=	0;
								
								tot_len				=	opcode_len	+ cmdcode_len	+ data_len;
																							
								instvalid			=	`InstValid;
						end		
				
				`OPCODE_20	:	begin		//20 /r AND r/m8, r8
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_AND_OP;
								alusel_o			=	`EXE_RES_LOGIC;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;
																
								mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
								regop					=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];	
								rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];								
									
								if(mod == 2'b11)	begin
									reg1_addr_o[4:2]	=	rm;
									reg1_addr_o[1:0]	=	2'b00;
									
									reg2_addr_o[4:2]	=	regop;
									reg2_addr_o[1:0]	=	2'b00;
								end else begin
								
								end	
														
								opcode_len		= 8;
								cmdcode_len		=	8;	
								data_len			= 0;						
																
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end
						
						
				`OPCODE_21	:	begin		
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_AND_OP;
								alusel_o			=	`EXE_RES_LOGIC;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;
																
								mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
								regop					=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];	
								rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];								
									
								if(mod == 2'b11)	begin		
									if(pre_66 == `True_v)	begin	//	21 /r AND r/m32, r32
										reg1_addr_o[4:2]	=	rm;
										reg1_addr_o[1:0]	=	2'b11;
										
										reg2_addr_o[4:2]	=	regop;
										reg2_addr_o[1:0]	=	2'b11;
									end else begin							//	21 /r AND r/m16, r16
										reg1_addr_o[4:2]	=	rm;
										reg1_addr_o[1:0]	=	2'b01;
										
										reg2_addr_o[4:2]	=	regop;
										reg2_addr_o[1:0]	=	2'b01;
									end
									
								end else begin
								
								end	
														
								opcode_len		= 8;
								cmdcode_len		=	8;	
								data_len			= 0;						
																
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end
				
						
				`OPCODE_24	:	begin		//24 ib AND AL, imm8
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_AND_OP;
								alusel_o			=	`EXE_RES_LOGIC;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b0;
																
																
								opcode_len		= 8;
								cmdcode_len		=	0;
																
								reg1_addr_o[4:2]	=	3'b000;
								reg1_addr_o[1:0]	=	2'b00;
																
								disp8			=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 16)]};	//{16'h0, cur_inst[32:0]};																					
								imm				= disp8;
								data_len	=	8;
																
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end
						
				`OPCODE_25	:	begin		//25 iw AND AX, imm16
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_AND_OP;
								alusel_o			=	`EXE_RES_LOGIC;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b0;
																
																
								opcode_len		= 8;
								cmdcode_len		=	0;
												
								if(pre_66 == `True_v)	begin
									reg1_addr_o[4:2]	=	3'b000;
									reg1_addr_o[1:0]	=	2'b11;
									
									disp32						=	{32'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 40)]};	//{16'h0, cur_inst[32:0]};																					
									imm								= disp32;
									data_len					=	32;
									
									//modi on 2015-10-24
									if(`LITTLE_END == `True_v)	begin
										imm = ((imm & 32'h000000FF)<<24) | ((imm & 32'h0000FF00)<<8) | ((imm & 32'h00FF0000) >>8) | ((imm & 32'hFF000000) >>24)  ;
									end
									
								end else begin																		
									reg1_addr_o[4:2]	=	3'b000;
									reg1_addr_o[1:0]	=	2'b01;
									
									disp16						=	{16'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
									imm								= disp16;
									data_len					=	16;
									
									//modi on 2015-10-24
									if(`LITTLE_END == `True_v)	begin
										imm = ((imm & 16'h00FF)<<8)  | ((imm & 16'hFF00) >>8)  ;
									end
								end
																
								
																
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end
						
				
				
				
				
				
					
				
				
				`OPCODE_28	:	begin		//	28 /r SUB r/m8, r8
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_SUB_OP;
								alusel_o			=	`EXE_RES_ARITH;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;
																
								mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
								regop					=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];	
								rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];								
									
								if(mod == 2'b11)	begin
									reg1_addr_o[4:2]	=	rm;
									reg1_addr_o[1:0]	=	2'b00;
									
									reg2_addr_o[4:2]	=	regop;
									reg2_addr_o[1:0]	=	2'b00;
								end else begin
								
								end	
														
								opcode_len		= 8;
								cmdcode_len		=	8;	
								data_len			= 0;						
																
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end
				
				`OPCODE_29	:	begin		
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_SUB_OP;
								alusel_o			=	`EXE_RES_ARITH;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;
																
								mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
								regop					=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];	
								rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];								
									
								if(mod == 2'b11)	begin		
									if(pre_66 == `True_v)	begin			//	29 /r SUB r/m32, r32
										reg1_addr_o[4:2]	=	rm;
										reg1_addr_o[1:0]	=	2'b11;
										
										reg2_addr_o[4:2]	=	regop;
										reg2_addr_o[1:0]	=	2'b11;
									end else begin									//	29 /r SUB r/m16, r16
										reg1_addr_o[4:2]	=	rm;
										reg1_addr_o[1:0]	=	2'b01;
										
										reg2_addr_o[4:2]	=	regop;
										reg2_addr_o[1:0]	=	2'b01;
									end
									
								end else begin
								
								end	
														
								opcode_len		= 8;
								cmdcode_len		=	8;	
								data_len			= 0;						
																
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end
				
				`OPCODE_2A	:	begin		// 2A /r SUB r8, r/m8
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_SUB_OP;
								alusel_o			=	`EXE_RES_ARITH;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;
																
								mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
								regop					=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];	
								rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];								
									
								if(mod == 2'b11)	begin
									reg1_addr_o[4:2]	=	rm;
									reg1_addr_o[1:0]	=	2'b00;
									
									reg2_addr_o[4:2]	=	regop;
									reg2_addr_o[1:0]	=	2'b00;
								end else begin
								
								end	
														
								opcode_len		= 8;
								cmdcode_len		=	8;	
								data_len			= 0;						
																
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end
						
				`OPCODE_2B	:	begin		
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_SUB_OP;
								alusel_o			=	`EXE_RES_ARITH;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;
																
								mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
								regop					=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];	
								rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];								
									
								if(mod == 2'b11)	begin		
									if(pre_66 == `True_v)	begin			//	2B /r SUB r32, r/m32
										reg1_addr_o[4:2]	=	rm;
										reg1_addr_o[1:0]	=	2'b11;
										
										reg2_addr_o[4:2]	=	regop;
										reg2_addr_o[1:0]	=	2'b11;
									end else begin									//	2B /r SUB r16, r/m16
										reg1_addr_o[4:2]	=	rm;
										reg1_addr_o[1:0]	=	2'b01;
										
										reg2_addr_o[4:2]	=	regop;
										reg2_addr_o[1:0]	=	2'b01;
									end
									
								end else begin
								
								end	
														
								opcode_len		= 8;
								cmdcode_len		=	8;	
								data_len			= 0;						
																
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end	
				
				
				`OPCODE_2C	:	begin		//	2C ib SUB AL, imm8
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_SUB_OP;
								alusel_o			=	`EXE_RES_ARITH;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b0;
																
																
								opcode_len		= 8;
								cmdcode_len		=	0;
																
								reg1_addr_o[4:2]	=	3'b000;
								reg1_addr_o[1:0]	=	2'b00;
																
								disp8			=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 16)]};	//{16'h0, cur_inst[32:0]};																					
								imm				= disp8;
								data_len	=	8;
																
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end

						
				`OPCODE_2D	:	begin		
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_SUB_OP;
								alusel_o			=	`EXE_RES_ARITH;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b0;
																
																
								opcode_len		= 8;
								cmdcode_len		=	0;
												
								if(pre_66 == `True_v)	begin			//	2D id SUB EAX, imm32
									reg1_addr_o[4:2]	=	3'b000;
									reg1_addr_o[1:0]	=	2'b11;
									
									disp32						=	{32'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 40)]};	//{16'h0, cur_inst[32:0]};																					
									imm								= disp32;
									data_len					=	32;
									
									//modi on 2015-10-24
									if(`LITTLE_END == `True_v)	begin
										imm = ((imm & 32'h000000FF)<<24) | ((imm & 32'h0000FF00)<<8) | ((imm & 32'h00FF0000) >>8) | ((imm & 32'hFF000000) >>24)  ;
									end
									
								end else begin									// 	2D iw SUB AX, imm16										
									reg1_addr_o[4:2]	=	3'b000;
									reg1_addr_o[1:0]	=	2'b01;
									
									disp16						=	{16'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
									imm								= disp16;
									data_len					=	16;
									
									//modi on 2015-10-24
									if(`LITTLE_END == `True_v)	begin
										imm = ((imm & 16'h00FF)<<8)  | ((imm & 16'hFF00) >>8)  ;
									end
								end
								
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end	


//----------------- cmp -----------------------------------------------------

				`OPCODE_38	:	begin		//	38 /r CMP r/m8, r8
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_CMP_OP;
								alusel_o			=	`EXE_RES_ARITH;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;
																
								mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
								regop					=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];	
								rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];								
									
								if(mod == 2'b11)	begin
									reg1_addr_o[4:2]	=	rm;
									reg1_addr_o[1:0]	=	2'b00;
									
									reg2_addr_o[4:2]	=	regop;
									reg2_addr_o[1:0]	=	2'b00;
								end else begin
								
								end	
														
								opcode_len		= 8;
								cmdcode_len		=	8;	
								data_len			= 0;						
																
								wd_o			=	`EFLAGS ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end
						
				`OPCODE_39	:	begin		
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_CMP_OP;
								alusel_o			=	`EXE_RES_ARITH;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;
																
								mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
								regop					=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];	
								rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];								
									
								if(mod == 2'b11)	begin		
									if(pre_66 == `True_v)	begin			//	39 /r CMP r/m32, r32
										reg1_addr_o[4:2]	=	rm;
										reg1_addr_o[1:0]	=	2'b11;
										
										reg2_addr_o[4:2]	=	regop;
										reg2_addr_o[1:0]	=	2'b11;
									end else begin									//	39 /r CMP r/m16, r16
										reg1_addr_o[4:2]	=	rm;
										reg1_addr_o[1:0]	=	2'b01;
										
										reg2_addr_o[4:2]	=	regop;
										reg2_addr_o[1:0]	=	2'b01;
									end
									
								end else begin
								
								end	
														
								opcode_len		= 8;
								cmdcode_len		=	8;	
								data_len			= 0;						
																
								wd_o			=	`EFLAGS ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;		
								
													
						end
						
				`OPCODE_3A	:	begin		// 3A /r CMP r8, r/m8
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_CMP_OP;
								alusel_o			=	`EXE_RES_ARITH;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;
																
								mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
								regop					=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];	
								rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];								
									
								if(mod == 2'b11)	begin
									reg1_addr_o[4:2]	=	rm;
									reg1_addr_o[1:0]	=	2'b00;
									
									reg2_addr_o[4:2]	=	regop;
									reg2_addr_o[1:0]	=	2'b00;
								end else begin
								
								end	
														
								opcode_len		= 8;
								cmdcode_len		=	8;	
								data_len			= 0;						
																
								wd_o			=	`EFLAGS ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end
						
				`OPCODE_3B	:	begin		
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_CMP_OP;
								alusel_o			=	`EXE_RES_ARITH;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;
																
								mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
								regop					=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];	
								rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];								
									
								if(mod == 2'b11)	begin		
									if(pre_66 == `True_v)	begin			//	3B /r CMP r32, r/m32
										reg1_addr_o[4:2]	=	rm;
										reg1_addr_o[1:0]	=	2'b11;
										
										reg2_addr_o[4:2]	=	regop;
										reg2_addr_o[1:0]	=	2'b11;
									end else begin									//	3B /r CMP r16, r/m16
										reg1_addr_o[4:2]	=	rm;
										reg1_addr_o[1:0]	=	2'b01;
										
										reg2_addr_o[4:2]	=	regop;
										reg2_addr_o[1:0]	=	2'b01;
									end
									
								end else begin
								
								end	
														
								opcode_len		= 8;
								cmdcode_len		=	8;	
								data_len			= 0;						
																
								wd_o			=	`EFLAGS ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end					
						
				`OPCODE_3C	:	begin		//3C ib CMP AL, imm8
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_CMP_OP;
								alusel_o			=	`EXE_RES_ARITH;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b0;
																
																
								opcode_len		= 8;
								cmdcode_len		=	0;
																
								reg1_addr_o[4:2]	=	3'b000;
								reg1_addr_o[1:0]	=	2'b00;
																
								disp8			=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 16)]};	//{16'h0, cur_inst[32:0]};																					
								imm				= disp8;
								data_len	=	8;
																
								wd_o			=	`EFLAGS ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end
				
				
				`OPCODE_3D	:	begin		
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_CMP_OP;
								alusel_o			=	`EXE_RES_ARITH;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b0;
																
																
								opcode_len		= 8;
								cmdcode_len		=	0;
												
								if(pre_66 == `True_v)	begin			//3D id CMP EAX, imm32
											reg1_addr_o[4:2]	=	3'b000;
											reg1_addr_o[1:0]	=	2'b11;
											
											disp32						=	{32'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 40)]};	//{16'h0, cur_inst[32:0]};																					
											imm								= disp32;
											data_len					=	32;
											
											//modi on 2015-10-24
											if(`LITTLE_END == `True_v)	begin
												imm = ((imm & 32'h000000FF)<<24) | ((imm & 32'h0000FF00)<<8) | ((imm & 32'h00FF0000) >>8) | ((imm & 32'hFF000000) >>24)  ;
											end
									
								end else begin									//3D iw CMP AX, imm16										
											reg1_addr_o[4:2]	=	3'b000;
											reg1_addr_o[1:0]	=	2'b01;
											
											disp16						=	{16'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
											imm								= disp16;
											data_len					=	16;
											
											//modi on 2015-10-24
											if(`LITTLE_END == `True_v)	begin
												imm = ((imm & 16'h00FF)<<8)  | ((imm & 16'hFF00) >>8)  ;
											end
								end
								
								wd_o			=	`EFLAGS ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end			
						
//----------------- inc/dec -------------------------------------------------
				
				`OPCODE_40, `OPCODE_41, `OPCODE_42, `OPCODE_43, `OPCODE_44, `OPCODE_45, `OPCODE_46, `OPCODE_47	:	
						begin	
								regop						=	cur_inst[(`InstLen - 6) 	:	(`InstLen - 8)];						//cur_inst[21:19];
								
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_INC_OP;
								alusel_o			=	`EXE_RES_ARITH;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b0;
																
								opcode_len		= 8;
								cmdcode_len		=	0;
																
								reg1_addr_o[4:2]	=	regop;
								reg1_addr_o[1:0]	=	2'b01;
																
								if(pre_66 == `True_v) begin	// 40+ rd INC r32
									reg1_addr_o[4:2]	=	regop;
									reg1_addr_o[1:0]	=	2'b11;
								end else begin							// 40+ rw** INC r16
									reg1_addr_o[4:2]	=	regop;
									reg1_addr_o[1:0]	=	2'b01;
								end			
								
								imm				= 1;
								data_len	=	0;
																
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;												
								
				end		
				
				`OPCODE_48, `OPCODE_49, `OPCODE_4A, `OPCODE_4B, `OPCODE_4C, `OPCODE_4D, `OPCODE_4E, `OPCODE_4F		:	
						begin	
								regop						=	cur_inst[(`InstLen - 6) 	:	(`InstLen - 8)];						//cur_inst[21:19];
								
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_DEC_OP;
								alusel_o			=	`EXE_RES_ARITH;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b0;
																
								opcode_len		= 0;
								cmdcode_len		=	8;
																
								reg1_addr_o[4:2]	=	regop;
								reg1_addr_o[1:0]	=	2'b01;
																
								if(pre_66 == `True_v) begin	// 48+rd DEC r32
									reg1_addr_o[4:2]	=	regop;
									reg1_addr_o[1:0]	=	2'b11;
								end else begin							// 48+rw DEC r16
									reg1_addr_o[4:2]	=	regop;
									reg1_addr_o[1:0]	=	2'b01;
								end		
																					
								imm				= 1;
								data_len	=	0;	
																
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;												
								
				end		
				
//----------------- push/pop --------------------------------------------------	
				
				`OPCODE_50, `OPCODE_51, `OPCODE_52, `OPCODE_53, `OPCODE_54, `OPCODE_55, `OPCODE_56, `OPCODE_57	:	
						begin	
								regop						=	cur_inst[(`InstLen - 6) 	:	(`InstLen - 8)];						//cur_inst[21:19];
								
								wreg_o				=	`WriteEnable;								
								alusel_o			=	`EXE_RES_MOV;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;
																
								opcode_len		= 8;
								cmdcode_len		=	0;
								data_len			=	0;		
																
								if(pre_66 == `True_v) begin	// PUSH r32
									reg1_addr_o[4:2]	=	regop;
									reg1_addr_o[1:0]	=	2'b11;								
									aluop_o				=	`EXE_PUSH_REG32_OP;
								end else begin							// PUSH r16
									reg1_addr_o[4:2]	=	regop;
									reg1_addr_o[1:0]	=	2'b01;								
									aluop_o				=	`EXE_PUSH_REG16_OP;
								end			
																
								reg2_addr_o		=	`ESP;																
								wd_o			=	reg2_addr_o ;								//更新esp															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;												
								
				end
				
				
				`OPCODE_58, `OPCODE_59, `OPCODE_5A, `OPCODE_5B, `OPCODE_5C, `OPCODE_5D, `OPCODE_5E, `OPCODE_5F	:	
						begin	
								regop						=	cur_inst[(`InstLen - 6) 	:	(`InstLen - 8)];						//cur_inst[21:19];
								
								wreg_o				=	`WriteEnable;								
								alusel_o			=	`EXE_RES_MOV;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;
																
								opcode_len		= 8;
								cmdcode_len		=	0;
								data_len			=	0;		
																
								if(pre_66 == `True_v) begin	// POP r32
									reg1_addr_o[4:2]	=	regop;
									reg1_addr_o[1:0]	=	2'b11;								
									aluop_o				=	`EXE_POP_REG32_OP;
								end else begin							// POP r16
									reg1_addr_o[4:2]	=	regop;
									reg1_addr_o[1:0]	=	2'b01;								
									aluop_o				=	`EXE_POP_REG16_OP;
								end			
																
								reg2_addr_o		=	`ESP;																
								wd_o					=	reg1_addr_o ;																						
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;												
								
				end
				
				`OPCODE_68	:	
						begin	
								regop						=	cur_inst[(`InstLen - 6) 	:	(`InstLen - 8)];						//cur_inst[21:19];
						
								wreg_o				=	`WriteEnable;								
								alusel_o			=	`EXE_RES_MOV;
								reg1_read_o		=	1'b0;
								reg2_read_o		=	1'b1;
																
								opcode_len		= 8;
								cmdcode_len		=	0;
																
								reg2_addr_o		=	`ESP;
																								
								if(pre_66 == `True_v) begin			// 68 id PUSH imm32								
									
									aluop_o		=	`EXE_PUSH_IMM32_OP;
								
									disp32		=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 40)]};	//{16'h0, cur_inst[32:0]};																					
									imm				= disp32;
									data_len	=	32;
									
									//modi on 2015-10-24
									if(`LITTLE_END == `True_v)	begin
										imm = ((imm & 32'h000000FF)<<24) | ((imm & 32'h0000FF00)<<8) | ((imm & 32'h00FF0000) >>8) | ((imm & 32'hFF000000) >>24)  ;
									end
								end else begin										// 68 iw PUSH imm16								
									
									aluop_o		=	`EXE_PUSH_IMM16_OP;
								
									disp16		=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
									imm				= disp16;
									data_len	=	16;
									
									//modi on 2015-10-24
									if(`LITTLE_END == `True_v)	begin
										imm = ((imm & 16'h00FF)<<8)  | ((imm & 16'hFF00) >>8)  ;
									end
								end			
																
								wd_o			=	reg2_addr_o ;						//更新 esp												
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;												
								
				end	
				
				`OPCODE_6A	:	
						begin	
								regop						=	cur_inst[(`InstLen - 6) 	:	(`InstLen - 8)];						//cur_inst[21:19];
						
								wreg_o				=	`WriteEnable;	
								aluop_o				=	`EXE_PUSH_IMM8_OP;							
								alusel_o			=	`EXE_RES_MOV;
								reg1_read_o		=	1'b0;
								reg2_read_o		=	1'b1;
																
								opcode_len		= 8;
								cmdcode_len		=	0;
																
								reg2_addr_o		=	`ESP;	
								
								disp8			=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 16)]};																						
								imm				= disp8;		
																
								wd_o			=	reg2_addr_o ;						//更新 esp												
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;												
								
				end	
				
//----------------- jcc -----------------------------------------------------
				
				`OPCODE_E3	:	begin			
							wreg_o				=	`WriteDisable;
							aluop_o				=	`EXE_JCXZ_OP_8;
							alusel_o			=	`EXE_RES_JMP;
							reg1_read_o		=	1'b1;
							reg2_read_o		=	1'b0;
							
							if(pre_66 == `True_v) begin				// E3 cb JECXZ rel8
									reg1_addr_o				=	`ECX;
								end else begin									// E3 cb JCXZ rel8
									reg1_addr_o				=	`CX;
							end	
							
							disp8			=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 16)]};																						
							imm				= disp8;
							
							opcode_len		= 8;
							cmdcode_len		=	0;
							data_len	=	8;			
							
							tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																						
							instvalid	=	`InstValid;							
								
						end
				
				
				`OPCODE_70	:	begin
							//70 cb JO rel8			
							wreg_o				=	`WriteDisable;
							aluop_o				=	`EXE_JO_OP_8;
							alusel_o			=	`EXE_RES_JMP;
							reg1_read_o		=	1'b1;
							reg2_read_o		=	1'b0;
							
							reg1_addr_o		=	`EFLAGS;
							
							disp8			=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 16)]};																						
							imm				= disp8;
							
							opcode_len		= 8;
							cmdcode_len		=	0;
							data_len	=	8;			
							
							tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																						
							instvalid	=	`InstValid;							
								
						end
				
				`OPCODE_71	:	begin
							//71 cb JNO rel8			
							wreg_o				=	`WriteDisable;
							aluop_o				=	`EXE_JNO_OP_8;
							alusel_o			=	`EXE_RES_JMP;
							reg1_read_o		=	1'b1;
							reg2_read_o		=	1'b0;
							
							reg1_addr_o		=	`EFLAGS;
							
							disp8			=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 16)]};																						
							imm				= disp8;
							
							opcode_len		= 8;
							cmdcode_len		=	0;
							data_len	=	8;			
							
							tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																						
							instvalid	=	`InstValid;							
								
						end

				`OPCODE_72	:	begin
							//72 cb JB rel8		, 72 cb JC rel8		,72 cb JNAE rel8			
							wreg_o				=	`WriteDisable;
							aluop_o				=	`EXE_JB_OP_8;
							alusel_o			=	`EXE_RES_JMP;
							reg1_read_o		=	1'b1;
							reg2_read_o		=	1'b0;
							
							reg1_addr_o		=	`EFLAGS;
							
							disp8			=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 16)]};																						
							imm				= disp8;
							
							opcode_len		= 8;
							cmdcode_len		=	0;
							data_len	=	8;			
							
							tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																						
							instvalid	=	`InstValid;							
								
						end

				`OPCODE_73	:	begin
							//73 cb JAE rel8		,73 cb JNB rel8		,73 cb JNC rel8				
							wreg_o				=	`WriteDisable;
							aluop_o				=	`EXE_JAE_OP_8;
							alusel_o			=	`EXE_RES_JMP;
							reg1_read_o		=	1'b1;
							reg2_read_o		=	1'b0;
							
							reg1_addr_o		=	`EFLAGS;
							
							disp8			=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 16)]};																						
							imm				= disp8;
							
							opcode_len		= 8;
							cmdcode_len		=	0;
							data_len	=	8;			
							
							tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																						
							instvalid	=	`InstValid;							
								
						end
						
				`OPCODE_74	:	begin
							//74 cb JE rel8			,74 cb JZ rel8				
							wreg_o				=	`WriteDisable;
							aluop_o				=	`EXE_JE_OP_8;
							alusel_o			=	`EXE_RES_JMP;
							reg1_read_o		=	1'b1;
							reg2_read_o		=	1'b0;
							
							reg1_addr_o		=	`EFLAGS;
							
							disp8			=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 16)]};																						
							imm				= disp8;
							
							opcode_len		= 8;
							cmdcode_len		=	0;
							data_len	=	8;			
							
							tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																						
							instvalid	=	`InstValid;							
								
						end
						
				`OPCODE_75	:	begin
							//75 cb JNE rel8		,75 cb JNZ rel8					
							wreg_o				=	`WriteDisable;
							aluop_o				=	`EXE_JNE_OP_8;
							alusel_o			=	`EXE_RES_JMP;
							reg1_read_o		=	1'b1;
							reg2_read_o		=	1'b0;
							
							reg1_addr_o		=	`EFLAGS;
							
							disp8			=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 16)]};																						
							imm				= disp8;
							
							opcode_len		= 8;
							cmdcode_len		=	0;
							data_len	=	8;			
							
							tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																						
							instvalid	=	`InstValid;							
								
						end
				
				`OPCODE_76	:	begin
							//76 cb JNA rel8								
							wreg_o				=	`WriteDisable;
							aluop_o				=	`EXE_JNA_OP_8;
							alusel_o			=	`EXE_RES_JMP;
							reg1_read_o		=	1'b1;
							reg2_read_o		=	1'b0;
							
							reg1_addr_o		=	`EFLAGS;
							
							disp8			=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 16)]};																						
							imm				= disp8;
							
							opcode_len		= 8;
							cmdcode_len		=	0;
							data_len	=	8;			
							
							tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																						
							instvalid	=	`InstValid;							
								
						end
						
				`OPCODE_77	:	begin
							//77 cb JA rel8		,77 cb JNBE rel8						
							wreg_o				=	`WriteDisable;
							aluop_o				=	`EXE_JA_OP_8;
							alusel_o			=	`EXE_RES_JMP;
							reg1_read_o		=	1'b1;
							reg2_read_o		=	1'b0;
							
							reg1_addr_o		=	`EFLAGS;
							
							disp8			=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 16)]};																						
							imm				= disp8;
							
							opcode_len		= 8;
							cmdcode_len		=	0;
							data_len	=	8;			
							
							tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																						
							instvalid	=	`InstValid;							
								
						end	
						
				`OPCODE_78	:	begin
							//78 cb JS rel8						
							wreg_o				=	`WriteDisable;
							aluop_o				=	`EXE_JS_OP_8;
							alusel_o			=	`EXE_RES_JMP;
							reg1_read_o		=	1'b1;
							reg2_read_o		=	1'b0;
							
							reg1_addr_o		=	`EFLAGS;
							
							disp8			=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 16)]};																						
							imm				= disp8;
							
							opcode_len		= 8;
							cmdcode_len		=	0;
							data_len	=	8;			
							
							tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																						
							instvalid	=	`InstValid;							
								
						end	
				
				`OPCODE_79	:	begin
							//79 cb JNS rel8						
							wreg_o				=	`WriteDisable;
							aluop_o				=	`EXE_JNS_OP_8;
							alusel_o			=	`EXE_RES_JMP;
							reg1_read_o		=	1'b1;
							reg2_read_o		=	1'b0;
							
							reg1_addr_o		=	`EFLAGS;
							
							disp8			=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 16)]};																						
							imm				= disp8;
							
							opcode_len		= 8;
							cmdcode_len		=	0;
							data_len	=	8;			
							
							tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																						
							instvalid	=	`InstValid;							
								
						end	
						
				`OPCODE_7A	:	begin
							//7A cb JP rel8		,7A cb JPE rel8				
							wreg_o				=	`WriteDisable;
							aluop_o				=	`EXE_JP_OP_8;
							alusel_o			=	`EXE_RES_JMP;
							reg1_read_o		=	1'b1;
							reg2_read_o		=	1'b0;
							
							reg1_addr_o		=	`EFLAGS;
							
							disp8			=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 16)]};																						
							imm				= disp8;
							
							opcode_len		= 8;
							cmdcode_len		=	0;
							data_len	=	8;			
							
							tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																						
							instvalid	=	`InstValid;							
								
						end	
				
				`OPCODE_7B	:	begin
							//7B cb JNP rel8	,7B cb JPO rel8				
							wreg_o				=	`WriteDisable;
							aluop_o				=	`EXE_JNP_OP_8;
							alusel_o			=	`EXE_RES_JMP;
							reg1_read_o		=	1'b1;
							reg2_read_o		=	1'b0;
							
							reg1_addr_o		=	`EFLAGS;
							
							disp8			=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 16)]};																						
							imm				= disp8;
							
							opcode_len		= 8;
							cmdcode_len		=	0;
							data_len	=	8;			
							
							tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																						
							instvalid	=	`InstValid;							
								
						end
						
				`OPCODE_7C	:	begin
							//7C cb JL rel8		,7C cb JNGE rel8					
							wreg_o				=	`WriteDisable;
							aluop_o				=	`EXE_JL_OP_8;
							alusel_o			=	`EXE_RES_JMP;
							reg1_read_o		=	1'b1;
							reg2_read_o		=	1'b0;
							
							reg1_addr_o		=	`EFLAGS;
							
							disp8			=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 16)]};																						
							imm				= disp8;
							
							opcode_len		= 8;
							cmdcode_len		=	0;
							data_len	=	8;			
							
							tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																						
							instvalid	=	`InstValid;							
								
						end
				
				`OPCODE_7D	:	begin
							//7D cb JGE rel8		,7D cb JNL rel8					
							wreg_o				=	`WriteDisable;
							aluop_o				=	`EXE_JGE_OP_8;
							alusel_o			=	`EXE_RES_JMP;
							reg1_read_o		=	1'b1;
							reg2_read_o		=	1'b0;
							
							reg1_addr_o		=	`EFLAGS;
							
							disp8			=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 16)]};																						
							imm				= disp8;
							
							opcode_len		= 8;
							cmdcode_len		=	0;
							data_len	=	8;			
							
							tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																						
							instvalid	=	`InstValid;							
								
						end	
					
				`OPCODE_7E	:	begin
							//7E cb JLE rel8		,7E cb JNG rel8				
							wreg_o				=	`WriteDisable;
							aluop_o				=	`EXE_JLE_OP_8;
							alusel_o			=	`EXE_RES_JMP;
							reg1_read_o		=	1'b1;
							reg2_read_o		=	1'b0;
							
							reg1_addr_o		=	`EFLAGS;
							
							disp8			=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 16)]};																						
							imm				= disp8;
							
							opcode_len		= 8;
							cmdcode_len		=	0;
							data_len	=	8;			
							
							tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																						
							instvalid	=	`InstValid;							
								
						end
						
				`OPCODE_7F	:	begin
							//7F cb JG rel8		,7F cb JNLE rel8						
							wreg_o				=	`WriteDisable;
							aluop_o				=	`EXE_JG_OP_8;
							alusel_o			=	`EXE_RES_JMP;
							reg1_read_o		=	1'b1;
							reg2_read_o		=	1'b0;
							
							reg1_addr_o		=	`EFLAGS;
							
							disp8			=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 16)]};																						
							imm				= disp8;
							
							opcode_len		= 8;
							cmdcode_len		=	0;
							data_len	=	8;			
							
							tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																						
							instvalid	=	`InstValid;							
								
						end		
						
				`OPCODE_0F	:	begin
								regop						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 16)];						
						
								case(regop)	
									`OPCODE_00	:	begin
											regop						=	cur_inst[(`InstLen - 19) 	:	(`InstLen - 21)];						//cur_inst[21:19];
									
											case(regop)							
												`STR_REG	:	begin					//0F 00 /1 STR r/m16
																			wreg_o				=	`WriteDisable;
																			aluop_o				=	`EXE_STR_OP;
																			alusel_o			=	`EXE_RES_SYS;
																			reg1_read_o		=	1'b0;
																			reg2_read_o		=	1'b1;
																											
																			mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																			regop					=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];	
																			rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];								
																				
																			if(mod == 2'b11)	begin																		
																					reg2_addr_o[4:2]	=	rm;
																					reg2_addr_o[1:0]	=	2'b01;
																					
																					opcode_len		= 16;
																					cmdcode_len		=	8;	
																					data_len			= 0;																	
																			end else begin
																					opcode_len		= 16;
																					cmdcode_len		=	8;
																					data_len			=	16;
																														
																					disp16		=	{8'h0, cur_inst[(`InstLen - 25)	:	(`InstLen - 40)]};	//{16'h0, cur_inst[32:0]};																					
																					imm				= disp16;
																			end															
																											
																			tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																										
																			instvalid	=	`InstValid;							
																	end
																																	
												`LTR_REG	:	begin					//0F 00 /3 LTR r/m16
																			wreg_o				=	`WriteDisable;
																			aluop_o				=	`EXE_LTR_OP;
																			alusel_o			=	`EXE_RES_SYS;
																			reg1_read_o		=	1'b0;
																			reg2_read_o		=	1'b1;
																											
																			mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																			regop					=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];	
																			rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];								
																				
																			if(mod == 2'b11)	begin																		
																					reg2_addr_o[4:2]	=	rm;
																					reg2_addr_o[1:0]	=	2'b01;
																					
																					opcode_len		= 16;
																					cmdcode_len		=	8;	
																					data_len			= 0;																	
																			end else begin
																					opcode_len		= 16;
																					cmdcode_len		=	8;
																					data_len			=	16;
																														
																					disp16		=	{8'h0, cur_inst[(`InstLen - 25)	:	(`InstLen - 40)]};	//{16'h0, cur_inst[32:0]};																					
																					imm				= disp16;
																			end															
																											
																			tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																										
																			instvalid	=	`InstValid;							
																	end
												
												`SLDT_REG	:	begin					//0F 00 /0 SLDT r/m16
																			wreg_o				=	`WriteDisable;
																			aluop_o				=	`EXE_SLDT_OP;
																			alusel_o			=	`EXE_RES_SYS;
																			reg1_read_o		=	1'b0;
																			reg2_read_o		=	1'b1;
																											
																			mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																			regop					=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];	
																			rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];								
																				
																			if(mod == 2'b11)	begin																		
																					reg2_addr_o[4:2]	=	rm;
																					reg2_addr_o[1:0]	=	2'b01;
																					
																					opcode_len		= 16;
																					cmdcode_len		=	8;	
																					data_len			= 0;																	
																			end else begin
																					opcode_len		= 16;
																					cmdcode_len		=	8;
																					data_len			=	16;
																														
																					disp16		=	{8'h0, cur_inst[(`InstLen - 25)	:	(`InstLen - 40)]};	//{16'h0, cur_inst[32:0]};																					
																					imm				= disp16;
																			end															
																											
																			tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																										
																			instvalid	=	`InstValid;							
																	end
																																	
												`LLDT_REG	:	begin					//0F 00 /2 LLDT r/m16
																			wreg_o				=	`WriteDisable;
																			aluop_o				=	`EXE_LLDT_OP;
																			alusel_o			=	`EXE_RES_SYS;
																			reg1_read_o		=	1'b0;
																			reg2_read_o		=	1'b1;
																											
																			mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																			regop					=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];	
																			rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];								
																				
																			if(mod == 2'b11)	begin																		
																					reg2_addr_o[4:2]	=	rm;
																					reg2_addr_o[1:0]	=	2'b01;
																					
																					opcode_len		= 16;
																					cmdcode_len		=	8;	
																					data_len			= 0;																	
																			end else begin
																					opcode_len		= 16;
																					cmdcode_len		=	8;
																					data_len			=	16;
																														
																					disp16		=	{8'h0, cur_inst[(`InstLen - 25)	:	(`InstLen - 40)]};	//{16'h0, cur_inst[32:0]};																					
																					imm				= disp16;
																			end															
																											
																			tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																										
																			instvalid	=	`InstValid;							
																	end					
																															
																		
													default:	begin
																	end											
																				
											endcase
											
											end
														
									`OPCODE_01	:	begin
											regop						=	cur_inst[(`InstLen - 19) 	:	(`InstLen - 21)];						//cur_inst[21:19];
									
											case(regop)							
												`SIDT_REG	:	begin				//	0F 01 /1 SIDT m
																			wreg_o				=	`WriteEnable;	
																			aluop_o				=	`EXE_SIDT_OP;															
																			alusel_o			=	`EXE_RES_SYS;
																			reg1_read_o		=	1'b0;
																			reg2_read_o		=	1'b0;	
																			
																			opcode_len		= 16;
																			cmdcode_len		=	8;
																			data_len			=	16;
																			
																			disp16		=	{8'h0, cur_inst[(`InstLen - 25)	:	(`InstLen - 40)]};	//{16'h0, cur_inst[32:0]};																					
																			imm				= disp16;
																			
																			tot_len				=	opcode_len	+ cmdcode_len	+ data_len;
																																		
																			instvalid			=	`InstValid;
																	end	
																	
												`LIDT_REG	:	begin				//	0F 01 /3 LIDT m16&32
																			wreg_o				=	`WriteEnable;	
																			aluop_o				=	`EXE_LIDT_OP;															
																			alusel_o			=	`EXE_RES_SYS;
																			reg1_read_o		=	1'b0;
																			reg2_read_o		=	1'b0;	
																			
																			opcode_len		= 16;
																			cmdcode_len		=	8;
																			data_len			=	16;
																			
																			disp16		=	{8'h0, cur_inst[(`InstLen - 25)	:	(`InstLen - 40)]};	//{16'h0, cur_inst[32:0]};																					
																			imm				= disp16;
																			
																			tot_len				=	opcode_len	+ cmdcode_len	+ data_len;
																																		
																			instvalid			=	`InstValid;
																	end	
												
												`SGDT_REG	:	begin				//	0F 01 /0 SGDT m
																			wreg_o				=	`WriteEnable;	
																			aluop_o				=	`EXE_SGDT_OP;															
																			alusel_o			=	`EXE_RES_SYS;
																			reg1_read_o		=	1'b0;
																			reg2_read_o		=	1'b0;	
																			
																			opcode_len		= 16;
																			cmdcode_len		=	8;
																			data_len			=	16;
																			
																			disp16		=	{8'h0, cur_inst[(`InstLen - 25)	:	(`InstLen - 40)]};	//{16'h0, cur_inst[32:0]};																					
																			imm				= disp16;
																			
																			tot_len				=	opcode_len	+ cmdcode_len	+ data_len;
																																		
																			instvalid			=	`InstValid;
																	end	
																	
												`LGDT_REG	:	begin				//	0F 01 /2 LGDT m16&32
																			wreg_o				=	`WriteEnable;	
																			aluop_o				=	`EXE_LGDT_OP;															
																			alusel_o			=	`EXE_RES_SYS;
																			reg1_read_o		=	1'b0;
																			reg2_read_o		=	1'b0;	
																			
																			opcode_len		= 16;
																			cmdcode_len		=	8;
																			data_len			=	16;
																			
																			disp16		=	{8'h0, cur_inst[(`InstLen - 25)	:	(`InstLen - 40)]};	//{16'h0, cur_inst[32:0]};																					
																			imm				= disp16;
																			
																			tot_len				=	opcode_len	+ cmdcode_len	+ data_len;
																																		
																			instvalid			=	`InstValid;
																	end												
																		
													default:	begin
																	end											
																				
											endcase
											
									end	
									
									`OPCODE_05	:	begin			//0F 05 SYSCALL
																wreg_o				=	`WriteDisable;
																aluop_o				=	`EXE_SYSCALL_OP;																
																alusel_o			=	`EXE_RES_SYS;
																reg1_read_o		=	1'b0;
																reg2_read_o		=	1'b0;
																
																opcode_len		= 16;
																cmdcode_len		=	0;																
																
																															
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
									
									
									`OPCODE_80	:	begin
																wreg_o				=	`WriteDisable;																
																alusel_o			=	`EXE_RES_JMP;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																opcode_len		= 8;
																cmdcode_len		=	8;																
																
																if(mod == 2'b11)	begin
																	if(pre_66 == `True_v) begin							// 0F 80 cd JO rel32
																		reg1_addr_o				=	`EFLAGS;															
																		aluop_o						=	`EXE_JO_OP_32;
																		
																		disp32						=	{32'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 48)]};																						
																		imm								= disp32;
																		data_len					=	32;
																	end else begin													// 0F 80 cw JO rel16
																		reg1_addr_o				=	`EFLAGS;															
																		aluop_o						=	`EXE_JO_OP_16;
																		
																		disp16						=	{16'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 32)]};																						
																		imm								= disp16;
																		data_len					=	16;
																	end																
																	
																end else begin
																
																end											
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
									
									`OPCODE_81	:	begin
																wreg_o				=	`WriteDisable;																
																alusel_o			=	`EXE_RES_JMP;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																opcode_len		= 8;
																cmdcode_len		=	8;																
																
																if(mod == 2'b11)	begin
																	if(pre_66 == `True_v) begin							// 0F 81 cd JNO rel32
																		reg1_addr_o				=	`EFLAGS;															
																		aluop_o						=	`EXE_JNO_OP_32;
																		
																		disp32						=	{32'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 48)]};																						
																		imm								= disp32;
																		data_len					=	32;
																	end else begin													// 0F 81 cw JNO rel16
																		reg1_addr_o				=	`EFLAGS;															
																		aluop_o						=	`EXE_JNO_OP_16;
																		
																		disp16						=	{16'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 32)]};																						
																		imm								= disp16;
																		data_len					=	16;
																	end																
																	
																end else begin
																
																end											
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
														
									
									`OPCODE_82	:	begin
																wreg_o				=	`WriteDisable;																
																alusel_o			=	`EXE_RES_JMP;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																opcode_len		= 8;
																cmdcode_len		=	8;																
																
																if(mod == 2'b11)	begin
																	if(pre_66 == `True_v) begin							// 0F 82 cd JB rel32	,0F 82 cd JC rel32,	0F 82 cd JNAE rel32
																		reg1_addr_o				=	`EFLAGS;															
																		aluop_o						=	`EXE_JB_OP_32;
																		
																		disp32						=	{32'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 48)]};																						
																		imm								= disp32;
																		data_len					=	32;
																	end else begin													// 0F 82 cw JB rel16	,0F 82 cw JC rel16,	0F 82 cw JNAE rel16
																		reg1_addr_o				=	`EFLAGS;															
																		aluop_o						=	`EXE_JB_OP_16;
																		
																		disp16						=	{16'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 32)]};																						
																		imm								= disp16;
																		data_len					=	16;
																	end																
																	
																end else begin
																
																end											
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
									
									`OPCODE_83	:	begin
																wreg_o				=	`WriteDisable;																
																alusel_o			=	`EXE_RES_JMP;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																opcode_len		= 8;
																cmdcode_len		=	8;																
																
																if(mod == 2'b11)	begin
																	if(pre_66 == `True_v) begin							// 0F 83 cd JAE rel32,	0F 83 cd JNB rel32,	0F 83 cd JNC rel32
																		reg1_addr_o				=	`EFLAGS;															
																		aluop_o						=	`EXE_JAE_OP_32;
																		
																		disp32						=	{32'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 48)]};																						
																		imm								= disp32;
																		data_len					=	32;
																	end else begin													// 0F 83 cw JAE rel16,	0F 83 cw JNB rel16,	0F 83 cw JNC rel16
																		reg1_addr_o				=	`EFLAGS;															
																		aluop_o						=	`EXE_JAE_OP_16;
																		
																		disp16						=	{16'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 32)]};																						
																		imm								= disp16;
																		data_len					=	16;
																	end																
																	
																end else begin
																
																end											
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
														
									`OPCODE_84	:	begin
																wreg_o				=	`WriteDisable;																
																alusel_o			=	`EXE_RES_JMP;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																opcode_len		= 8;
																cmdcode_len		=	8;																
																
																if(mod == 2'b11)	begin
																	if(pre_66 == `True_v) begin							// 0F 84 cd JE rel32,	0F 84 cd JZ rel32,	0F 84 cd JZ rel32
																		reg1_addr_o				=	`EFLAGS;															
																		aluop_o						=	`EXE_JE_OP_32;
																		
																		disp32						=	{32'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 48)]};																						
																		imm								= disp32;
																		data_len					=	32;
																	end else begin													// 0F 84 cw JE rel16,	0F 84 cw JZ rel16,	0F 84 cw JZ rel16
																		reg1_addr_o				=	`EFLAGS;															
																		aluop_o						=	`EXE_JE_OP_16;
																		
																		disp16						=	{16'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 32)]};																						
																		imm								= disp16;
																		data_len					=	16;
																	end																
																	
																end else begin
																
																end											
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
														
									
									`OPCODE_85	:	begin
																wreg_o				=	`WriteDisable;																
																alusel_o			=	`EXE_RES_JMP;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																opcode_len		= 8;
																cmdcode_len		=	8;																
																
																if(mod == 2'b11)	begin
																	if(pre_66 == `True_v) begin							// 0F 85 cd JNE rel32,	0F 85 cd JNZ rel32
																		reg1_addr_o				=	`EFLAGS;															
																		aluop_o						=	`EXE_JNE_OP_32;
																		
																		disp32						=	{32'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 48)]};																						
																		imm								= disp32;
																		data_len					=	32;
																	end else begin													// 0F 85 cw JNE rel16,	0F 85 cw JNZ rel16
																		reg1_addr_o				=	`EFLAGS;															
																		aluop_o						=	`EXE_JNE_OP_16;
																		
																		disp16						=	{16'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 32)]};																						
																		imm								= disp16;
																		data_len					=	16;
																	end																
																	
																end else begin
																
																end											
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end					
															
									
									`OPCODE_86	:	begin
																wreg_o				=	`WriteDisable;																
																alusel_o			=	`EXE_RES_JMP;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																opcode_len		= 8;
																cmdcode_len		=	8;																
																
																if(mod == 2'b11)	begin
																	if(pre_66 == `True_v) begin							// 0F 86 cd JBE rel32,	0F 86 cd JNA rel32
																		reg1_addr_o				=	`EFLAGS;															
																		aluop_o						=	`EXE_JB_OP_32;
																		
																		disp32						=	{32'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 48)]};																						
																		imm								= disp32;
																		data_len					=	32;
																	end else begin													// 0F 86 cw JBE rel16,	0F 86 cw JNA rel16
																		reg1_addr_o				=	`EFLAGS;															
																		aluop_o						=	`EXE_JB_OP_16;
																		
																		disp16						=	{16'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 32)]};																						
																		imm								= disp16;
																		data_len					=	16;
																	end																
																	
																end else begin
																
																end											
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
															
																		
									`OPCODE_87	:	begin
																wreg_o				=	`WriteDisable;																
																alusel_o			=	`EXE_RES_JMP;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																opcode_len		= 8;
																cmdcode_len		=	8;																
																
																if(mod == 2'b11)	begin
																	if(pre_66 == `True_v) begin							// 0F 87 cd JA rel32,	0F 87 cd JNBE rel32
																		reg1_addr_o				=	`EFLAGS;															
																		aluop_o						=	`EXE_JA_OP_32;
																		
																		disp32						=	{32'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 48)]};																						
																		imm								= disp32;
																		data_len					=	32;
																	end else begin													// 0F 87 cw JA rel16,	0F 87 cw JNBE rel16
																		reg1_addr_o				=	`EFLAGS;															
																		aluop_o						=	`EXE_JA_OP_16;
																		
																		disp16						=	{16'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 32)]};																						
																		imm								= disp16;
																		data_len					=	16;
																	end																
																	
																end else begin
																
																end											
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end						
									
									
									`OPCODE_88	:	begin
																wreg_o				=	`WriteDisable;																
																alusel_o			=	`EXE_RES_JMP;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																opcode_len		= 8;
																cmdcode_len		=	8;																
																
																if(mod == 2'b11)	begin
																	if(pre_66 == `True_v) begin							// 0F 88 cd JS rel32
																		reg1_addr_o				=	`EFLAGS;															
																		aluop_o						=	`EXE_JS_OP_32;
																		
																		disp32						=	{32'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 48)]};																						
																		imm								= disp32;
																		data_len					=	32;
																	end else begin													// 0F 88 cw JS rel16
																		reg1_addr_o				=	`EFLAGS;															
																		aluop_o						=	`EXE_JS_OP_16;
																		
																		disp16						=	{16'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 32)]};																						
																		imm								= disp16;
																		data_len					=	16;
																	end																
																	
																end else begin
																
																end											
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
									
									
									`OPCODE_89	:	begin
																wreg_o				=	`WriteDisable;																
																alusel_o			=	`EXE_RES_JMP;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																opcode_len		= 8;
																cmdcode_len		=	8;																
																
																if(mod == 2'b11)	begin
																	if(pre_66 == `True_v) begin							// 0F 89 cd JNS rel32
																		reg1_addr_o				=	`EFLAGS;															
																		aluop_o						=	`EXE_JNS_OP_32;
																		
																		disp32						=	{32'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 48)]};																						
																		imm								= disp32;
																		data_len					=	32;
																	end else begin													// 0F 89 cw JNS rel16
																		reg1_addr_o				=	`EFLAGS;															
																		aluop_o						=	`EXE_JNS_OP_16;
																		
																		disp16						=	{16'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 32)]};																						
																		imm								= disp16;
																		data_len					=	16;
																	end																
																	
																end else begin
																
																end											
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
									
									
									`OPCODE_8A	:	begin
																wreg_o				=	`WriteDisable;																
																alusel_o			=	`EXE_RES_JMP;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																opcode_len		= 8;
																cmdcode_len		=	8;																
																
																if(mod == 2'b11)	begin
																	if(pre_66 == `True_v) begin							// 0F 8A cd JP rel32,	0F 8A cd JPE rel32
																		reg1_addr_o				=	`EFLAGS;															
																		aluop_o						=	`EXE_JP_OP_32;
																		
																		disp32						=	{32'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 48)]};																						
																		imm								= disp32;
																		data_len					=	32;
																	end else begin													// 0F 8A cw JP rel16,	0F 8A cw JPE rel16
																		reg1_addr_o				=	`EFLAGS;															
																		aluop_o						=	`EXE_JP_OP_16;
																		
																		disp16						=	{16'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 32)]};																						
																		imm								= disp16;
																		data_len					=	16;
																	end																
																	
																end else begin
																
																end											
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
									
									
									`OPCODE_8B	:	begin
																wreg_o				=	`WriteDisable;																
																alusel_o			=	`EXE_RES_JMP;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																opcode_len		= 8;
																cmdcode_len		=	8;																
																
																if(mod == 2'b11)	begin
																	if(pre_66 == `True_v) begin							// 0F 8B cd JNP rel32,	0F 8B cd JPO rel32
																		reg1_addr_o				=	`EFLAGS;															
																		aluop_o						=	`EXE_JNP_OP_32;
																		
																		disp32						=	{32'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 48)]};																						
																		imm								= disp32;
																		data_len					=	32;
																	end else begin													// 0F 8B cw JNP rel16,	0F 8B cw JPO rel16
																		reg1_addr_o				=	`EFLAGS;															
																		aluop_o						=	`EXE_JNP_OP_16;
																		
																		disp16						=	{16'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 32)]};																						
																		imm								= disp16;
																		data_len					=	16;
																	end																
																	
																end else begin
																
																end											
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
									
									
									
									`OPCODE_8C	:	begin
																wreg_o				=	`WriteDisable;																
																alusel_o			=	`EXE_RES_JMP;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																opcode_len		= 8;
																cmdcode_len		=	8;																
																
																if(mod == 2'b11)	begin
																	if(pre_66 == `True_v) begin							// 0F 8C cd JL rel32,	0F 8C cd JNGE rel32
																		reg1_addr_o				=	`EFLAGS;															
																		aluop_o						=	`EXE_JL_OP_32;
																		
																		disp32						=	{32'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 48)]};																						
																		imm								= disp32;
																		data_len					=	32;
																	end else begin													// 0F 8C cw JL rel16,	0F 8C cw JNGE rel16
																		reg1_addr_o				=	`EFLAGS;															
																		aluop_o						=	`EXE_JL_OP_16;
																		
																		disp16						=	{16'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 32)]};																						
																		imm								= disp16;
																		data_len					=	16;
																	end																
																	
																end else begin
																
																end											
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
									
									
									`OPCODE_8D	:	begin
																wreg_o				=	`WriteDisable;																
																alusel_o			=	`EXE_RES_JMP;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																opcode_len		= 8;
																cmdcode_len		=	8;																
																
																if(mod == 2'b11)	begin
																	if(pre_66 == `True_v) begin							// 0F 8D cd JGE rel32,	0F 8D cd JNL rel32
																		reg1_addr_o				=	`EFLAGS;															
																		aluop_o						=	`EXE_JGE_OP_32;
																		
																		disp32						=	{32'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 48)]};																						
																		imm								= disp32;
																		data_len					=	32;
																	end else begin													// 0F 8D cw JGE rel16,	0F 8D cw JNL rel16
																		reg1_addr_o				=	`EFLAGS;															
																		aluop_o						=	`EXE_JGE_OP_16;
																		
																		disp16						=	{16'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 32)]};																						
																		imm								= disp16;
																		data_len					=	16;
																	end																
																	
																end else begin
																
																end											
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
									
									`OPCODE_8E	:	begin
																wreg_o				=	`WriteDisable;																
																alusel_o			=	`EXE_RES_JMP;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																opcode_len		= 8;
																cmdcode_len		=	8;																
																
																if(mod == 2'b11)	begin
																	if(pre_66 == `True_v) begin							// 0F 8E cd JLE rel32,	0F 8E cd JNG rel32
																		reg1_addr_o				=	`EFLAGS;															
																		aluop_o						=	`EXE_JLE_OP_32;
																		
																		disp32						=	{32'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 48)]};																						
																		imm								= disp32;
																		data_len					=	32;
																	end else begin													// 0F 8E cw JLE rel16,	0F 8E cw JNG rel16
																		reg1_addr_o				=	`EFLAGS;															
																		aluop_o						=	`EXE_JLE_OP_16;
																		
																		disp16						=	{16'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 32)]};																						
																		imm								= disp16;
																		data_len					=	16;
																	end																
																	
																end else begin
																
																end											
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
									
									`OPCODE_8F	:	begin
																wreg_o				=	`WriteDisable;																
																alusel_o			=	`EXE_RES_JMP;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																opcode_len		= 8;
																cmdcode_len		=	8;																
																
																if(mod == 2'b11)	begin
																	if(pre_66 == `True_v) begin							// 0F 8F cd JG rel32,	0F 8F cd JNLE rel32
																		reg1_addr_o				=	`EFLAGS;															
																		aluop_o						=	`EXE_JG_OP_32;
																		
																		disp32						=	{32'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 48)]};																						
																		imm								= disp32;
																		data_len					=	32;
																	end else begin													// 0F 8F cw JG rel16,	0F 8F cw JNLE rel16
																		reg1_addr_o				=	`EFLAGS;															
																		aluop_o						=	`EXE_JG_OP_16;
																		
																		disp16						=	{16'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 32)]};																						
																		imm								= disp16;
																		data_len					=	16;
																	end																
																	
																end else begin
																
																end											
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
														
									`OPCODE_A0	:	begin							//0F A0 PUSH FS
																wreg_o				=	`WriteEnable;	
																aluop_o				=	`EXE_PUSH_REG16_OP;															
																alusel_o			=	`EXE_RES_MOV;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b1;	
																
																reg1_addr_o		=	`FS;
																reg2_addr_o		=	`ESP;
																
																wd_o					=	reg2_addr_o ;								//更新esp	
																
																opcode_len		= 8;
																cmdcode_len		=	0;
																data_len			=	0;
																
																tot_len				=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid			=	`InstValid;
														end
									
									`OPCODE_A1	:	begin							//	0F A1 POP FS
																wreg_o				=	`WriteEnable;	
																aluop_o				=	`EXE_POP_REG16_OP;															
																alusel_o			=	`EXE_RES_MOV;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b1;	
																
																reg1_addr_o		=	`FS;
																reg2_addr_o		=	`ESP;
																
																wd_o					=	reg1_addr_o ;								
																
																opcode_len		= 8;
																cmdcode_len		=	0;
																data_len			=	0;
																
																tot_len				=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid			=	`InstValid;
														end
									
									
									`OPCODE_A8	:	begin							//0F A8 PUSH GS
																wreg_o				=	`WriteEnable;	
																aluop_o				=	`EXE_PUSH_REG16_OP;															
																alusel_o			=	`EXE_RES_MOV;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b1;	
																
																reg1_addr_o		=	`GS;
																reg2_addr_o		=	`ESP;
																
																wd_o					=	reg2_addr_o ;								//更新esp	
																
																opcode_len		= 8;
																cmdcode_len		=	0;
																data_len			=	0;
																
																tot_len				=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid			=	`InstValid;
														end
									
									`OPCODE_A9	:	begin							//	0F A9 POP GS
																wreg_o				=	`WriteEnable;	
																aluop_o				=	`EXE_POP_REG16_OP;															
																alusel_o			=	`EXE_RES_MOV;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b1;	
																
																reg1_addr_o		=	`GS;
																reg2_addr_o		=	`ESP;
																
																wd_o					=	reg1_addr_o ;								
																
																opcode_len		= 8;
																cmdcode_len		=	0;
																data_len			=	0;
																
																tot_len				=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid			=	`InstValid;
														end
														
															
										default:	begin
														end											
																	
								endcase
								
						end	
				
//----------------- mov -----------------------------------------------------
				`OPCODE_88	:	begin	//	88 /r MOV r/m8,r8	
							
								wreg_o				=	`WriteEnable;                                                                   		
								aluop_o				=	`EXE_MOV_REG_OP;                                                                    								
								alusel_o			=	`EXE_RES_MOV;                                                                   								
								reg1_read_o		=	1'b0;                                                                           								
								reg2_read_o		=	1'b1;                                                                           								
								                                                                                                								
								// mod|regop|rm :                                                                               								
								// 1th register : rm                                                                            								
								// 2th register : regop                                                                         								
								regop					=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];						//cur_inst[21:19];      								
								mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];      								
								rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	    								
								opcode_len		= 8;                                                                              								
								cmdcode_len		=	8;                                                                              								
								                                                                                                								
								reg1_addr_o[4:2]	=	rm;                                                                         								
								reg1_addr_o[1:0]	=	2'b00;                                                                      								
								                                                                                                								
								reg2_addr_o[4:2]	=	regop;                                                                      								
								reg2_addr_o[1:0]	=	2'b00;                                                                      								
								                                                                                                								
								data_len	=	0;                                                                                  								
								                                                                                                								
								wd_o			=	reg1_addr_o ;															                                          								
								                                                                                                								
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;                                               								
																							                                                                  								
								instvalid	=	`InstValid;                                                      								
							
				end	
				
				`OPCODE_89	:	begin	
							
								wreg_o				=	`WriteEnable;                                                                   		
								aluop_o				=	`EXE_MOV_REG_OP;                                                                    								
								alusel_o			=	`EXE_RES_MOV;                                                                   								
								reg1_read_o		=	1'b0;                                                                           								
								reg2_read_o		=	1'b1;                                                                           								
								                                                                                                								
								// mod|regop|rm :                                                                               								
								// 1th register : rm                                                                            								
								// 2th register : regop                                                                         								
								regop					=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];						//cur_inst[21:19];      								
								mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];      								
								rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	    								
								opcode_len		= 8;                                                                              								
								cmdcode_len		=	8; 
								
								if(pre_66 == `True_v) begin	// 89 /r MOV r/m32,r32
									reg1_addr_o[4:2]	=	rm;                                                                         								
									reg1_addr_o[1:0]	=	2'b11;                                                                      								
									                                                                                                								
									reg2_addr_o[4:2]	=	regop;                                                                      								
									reg2_addr_o[1:0]	=	2'b11;
								
									
								end else begin	// 89 /r MOV r/m16,r16
									reg1_addr_o[4:2]	=	rm;                                                                         								
									reg1_addr_o[1:0]	=	2'b01;                                                                      								
									                                                                                                								
									reg2_addr_o[4:2]	=	regop;                                                                      								
									reg2_addr_o[1:0]	=	2'b01;
								end	                                                  								
								                                                                                               								
								data_len	=	0;                                                                                  								
								                                                                                                								
								wd_o			=	reg1_addr_o ;															                                          								
								                                                                                                								
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;                                               								
																							                                                                  								
								instvalid	=	`InstValid;                                                      								
							
				end	

//-------------------------- lea	-------------------------------------

				`OPCODE_8D	:	begin		
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_LEA_OP;
								alusel_o			=	`EXE_RES_SYS;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b0;
																
								mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
								regop					=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];	
								rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];		
								
								if(pre_66 == `True_v)	begin			//	8D /r LEA r32,m
										reg1_addr_o[4:2]	=	regop;
										reg1_addr_o[1:0]	=	2'b11;									
										
										disp32		=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 40)]};	//{16'h0, cur_inst[32:0]};																					
										imm				= disp32;
										data_len	=	32;
										
										if(`LITTLE_END == `True_v)	begin
											imm = ((imm & 32'h000000FF)<<24) | ((imm & 32'h0000FF00)<<8) | ((imm & 32'h00FF0000) >>8) | ((imm & 32'hFF000000) >>24)  ;
										end
									
								end else begin									//	8D /r LEA r16,m
										reg1_addr_o[4:2]	=	regop;
										reg1_addr_o[1:0]	=	2'b01;										
										
										disp16		=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
										imm				= disp16;
										data_len	=	16;
										
										if(`LITTLE_END == `True_v)	begin
											imm = ((imm & 16'h00FF)<<8)  | ((imm & 16'hFF00) >>8)  ;
										end
								end
								
								opcode_len		= 8;
								cmdcode_len		=	8;	
																
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end	
						
//-------------------------- pop	-------------------------------------
				`OPCODE_8F	:	begin
								regop						=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];						//cur_inst[21:19];
						
								case(regop)							
									`POP_REG	:	begin					
																wreg_o				=	`WriteEnable;																
																alusel_o			=	`EXE_RES_MOV;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b1;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																opcode_len		= 8;
																cmdcode_len		=	8;
																
																if(mod == 2'b11)	begin
																	if(pre_66 == `True_v) begin			// 8F /0 POP r/m32
																		reg1_addr_o[4:2]	=	regop;
																		reg1_addr_o[1:0]	=	2'b11;																
																		aluop_o						=	`EXE_POP_REG32_OP;
																	end else begin									// 8F /0 POP r/m16
																		reg1_addr_o[4:2]	=	regop;
																		reg1_addr_o[1:0]	=	2'b01;																
																		aluop_o						=	`EXE_POP_REG16_OP;
																	end	
																	
																end else begin
																
																end	
																
																reg2_addr_o		=	`ESP;
																
																wd_o			=	reg2_addr_o ;								//更新esp												
																																
																data_len	=	0;							
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
															
															
										default:	begin
														end											
																	
								endcase
								
						end	
				
				
//-------------------------- nop	-------------------------------------
				
				`OPCODE_90	:	begin		//	90 NOP
								wreg_o				=	`WriteDisable;
								aluop_o				=	`EXE_NOP_OP;
								alusel_o			=	`EXE_RES_SYS;
								reg1_read_o		=	1'b0;
								reg2_read_o		=	1'b0;
																						
								opcode_len		= 8;
								cmdcode_len		=	0;	
								data_len			= 0;																
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end
												
//---------------------------------------------------------------------

				`OPCODE_B0, `OPCODE_B1, `OPCODE_B2, `OPCODE_B3, `OPCODE_B4, `OPCODE_B5, `OPCODE_B6, `OPCODE_B7	:	
						begin	// mov al/cl/dl/bl/ah/ch/dh/bh, imm
								regop						=	cur_inst[(`InstLen - 6) 	:	(`InstLen - 8)];						//cur_inst[21:19];
						
								//MOV r8, imm8				
								
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_MOV_IMM_OP;
								alusel_o			=	`EXE_RES_MOV;
								reg1_read_o		=	1'b0;
								reg2_read_o		=	1'b0;
																
								opcode_len		= 8;
								cmdcode_len		=	0;
																
								reg1_addr_o[4:2]	=	regop;
								reg1_addr_o[1:0]	=	2'b00;
																
								disp8			=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 16)]};	//{16'h0, cur_inst[32:0]};																					
								imm				= disp8;
								data_len	=	8;
																
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;												
								
						end
						
							
				
				
				`OPCODE_B8, `OPCODE_B9, `OPCODE_BA, `OPCODE_BB, `OPCODE_BC, `OPCODE_BD, `OPCODE_BE, `OPCODE_BF	:	
						begin	
								regop						=	cur_inst[(`InstLen - 6) 	:	(`InstLen - 8)];						//cur_inst[21:19];
						
								//B8+ rw iw MOV r16, imm16				
								
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_MOV_IMM_OP;
								alusel_o			=	`EXE_RES_MOV;
								reg1_read_o		=	1'b0;
								reg2_read_o		=	1'b0;
																
								opcode_len		= 8;
								cmdcode_len		=	0;
																
								reg1_addr_o[4:2]	=	regop;
								reg1_addr_o[1:0]	=	2'b01;
																
								if(pre_66 == `True_v) begin	// mov eax/ecx/edx/ebx, imm32
									reg1_addr_o[4:2]	=	regop;
									reg1_addr_o[1:0]	=	2'b11;
								
									disp32		=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 40)]};	//{16'h0, cur_inst[32:0]};																					
									imm				= disp32;
									data_len	=	32;
									
									//modi on 2015-10-24
									if(`LITTLE_END == `True_v)	begin
										imm = ((imm & 32'h000000FF)<<24) | ((imm & 32'h0000FF00)<<8) | ((imm & 32'h00FF0000) >>8) | ((imm & 32'hFF000000) >>24)  ;
									end
								end else begin	// mov ax/cx/dx/bx, imm16
									reg1_addr_o[4:2]	=	regop;
									reg1_addr_o[1:0]	=	2'b01;
								
									disp16		=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
									imm				= disp16;
									data_len	=	16;
									
									//modi on 2015-10-24
									if(`LITTLE_END == `True_v)	begin
										imm = ((imm & 16'h00FF)<<8)  | ((imm & 16'hFF00) >>8)  ;
									end
								end			
																
								wd_o			=	reg1_addr_o ;															
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;												
								
				end	
				
				
				
				
//-----------------------------  ret -----------------------------------------		
				`OPCODE_C3	:	begin							//	CB RET
								wreg_o				=	`WriteDisable;	
								aluop_o				=	`EXE_RET_OP_16;															
								alusel_o			=	`EXE_RES_MOV;
								reg1_read_o		=	1'b0;
								reg2_read_o		=	1'b1;	
								
								reg2_addr_o		=	`ESP;
								
								wd_o					=	reg2_addr_o ;								//更新esp	
								
								opcode_len		= 8;
								cmdcode_len		=	0;
								data_len			=	0;
								
								tot_len				=	opcode_len	+ cmdcode_len	+ data_len;
																							
								instvalid			=	`InstValid;
						end


				`OPCODE_CB	:	begin							//	CB RET
								wreg_o				=	`WriteDisable;	
								aluop_o				=	`EXE_RET_OP_32;															
								alusel_o			=	`EXE_RES_MOV;
								reg1_read_o		=	1'b0;
								reg2_read_o		=	1'b1;	
								
								reg2_addr_o		=	`ESP;
								
								wd_o					=	reg2_addr_o ;								//更新esp	
								
								opcode_len		= 8;
								cmdcode_len		=	0;
								data_len			=	0;
								
								tot_len				=	opcode_len	+ cmdcode_len	+ data_len;
																							
								instvalid			=	`InstValid;
						end




//----------------- SAL/SAR/SHL/SHR -----------------------------------------

				`OPCODE_C0	:	begin
								regop						=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];						//cur_inst[21:19];
						
								case(regop)			//C0 /4 ib SAL r/m8, imm8			
									`SAL_REG	:	begin
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_SAL_OP;
																alusel_o			=	`EXE_RES_SHIFT;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																opcode_len		= 8;
																cmdcode_len		=	8;
																
																if(mod == 2'b11)	begin
																	reg1_addr_o[4:2]	=	rm;
																	reg1_addr_o[1:0]	=	2'b00;
																end else begin
																
																end																
																
																disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																imm				= disp8;
																data_len	=	8;
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end	
									
									`SAR_REG	:	begin
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_SAR_OP;
																alusel_o			=	`EXE_RES_SHIFT;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																opcode_len		= 8;
																cmdcode_len		=	8;
																
																if(mod == 2'b11)	begin
																	reg1_addr_o[4:2]	=	rm;
																	reg1_addr_o[1:0]	=	2'b00;
																end else begin
																
																end																
																
																disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																imm				= disp8;
																data_len	=	8;
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
									
									`SHL_REG	:	begin
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_SHL_OP;
																alusel_o			=	`EXE_RES_SHIFT;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																opcode_len		= 8;
																cmdcode_len		=	8;
																
																if(mod == 2'b11)	begin
																	reg1_addr_o[4:2]	=	rm;
																	reg1_addr_o[1:0]	=	2'b00;
																end else begin
																
																end																
																
																disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																imm				= disp8;
																data_len	=	8;
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
								
								`SHR_REG	:	begin
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_SHR_OP;
																alusel_o			=	`EXE_RES_SHIFT;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																opcode_len		= 8;
																cmdcode_len		=	8;
																
																if(mod == 2'b11)	begin
																	reg1_addr_o[4:2]	=	rm;
																	reg1_addr_o[1:0]	=	2'b00;
																end else begin
																
																end																
																
																disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																imm				= disp8;
																data_len	=	8;
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end	
									
								`RCL_REG	:	begin			//C0 /2 ib RCL r/m8, imm8
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_RCL_OP;
																alusel_o			=	`EXE_RES_SHIFT;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																opcode_len		= 8;
																cmdcode_len		=	8;
																
																if(mod == 2'b11)	begin
																	reg1_addr_o[4:2]	=	rm;
																	reg1_addr_o[1:0]	=	2'b00;
																end else begin
																
																end																
																
																disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																imm				= disp8;
																data_len	=	8;
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end	
														
								`RCR_REG	:	begin			//C0 /3 ib RCR r/m8, imm8
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_RCR_OP;
																alusel_o			=	`EXE_RES_SHIFT;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																opcode_len		= 8;
																cmdcode_len		=	8;
																
																if(mod == 2'b11)	begin
																	reg1_addr_o[4:2]	=	rm;
																	reg1_addr_o[1:0]	=	2'b00;
																end else begin
																
																end																
																
																disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																imm				= disp8;
																data_len	=	8;
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end	
														
								`ROL_REG	:	begin			//C0 /0 ib ROL r/m8, imm8
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_ROL_OP;
																alusel_o			=	`EXE_RES_SHIFT;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																opcode_len		= 8;
																cmdcode_len		=	8;
																
																if(mod == 2'b11)	begin
																	reg1_addr_o[4:2]	=	rm;
																	reg1_addr_o[1:0]	=	2'b00;
																end else begin
																
																end																
																
																disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																imm				= disp8;
																data_len	=	8;
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end	
														
																										
								`ROR_REG	:	begin			//C0 /1 ib ROR r/m8, imm8
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_ROR_OP;
																alusel_o			=	`EXE_RES_SHIFT;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																opcode_len		= 8;
																cmdcode_len		=	8;
																
																if(mod == 2'b11)	begin
																	reg1_addr_o[4:2]	=	rm;
																	reg1_addr_o[1:0]	=	2'b00;
																end else begin
																
																end																
																
																disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																imm				= disp8;
																data_len	=	8;
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end													
									
															
										default:	begin
														end											
																	
								endcase
								
						end
						
									
						
					`OPCODE_C1	:	begin
								regop						=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];						//cur_inst[21:19];
						
								case(regop)					
									`SAL_REG	:	begin
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_SAL_OP;
																alusel_o			=	`EXE_RES_SHIFT;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																opcode_len		= 8;
																cmdcode_len		=	8;
																
																if(mod == 2'b11)	begin					//C1 /4 ib SAL r/m32, imm8
																	if(pre_66 == `True_v)	begin
																		reg1_addr_o[4:2]	=	rm;
																		reg1_addr_o[1:0]	=	2'b11;
																		
																		disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																		imm				= disp8;
																		data_len	=	8;
																		
																		//modi on 2015-10-24
																		//if(`LITTLE_END == `True_v)	begin
																		//	imm = ((imm & 32'h000000FF)<<24) | ((imm & 32'h0000FF00)<<8) | ((imm & 32'h00FF0000) >>8) | ((imm & 32'hFF000000) >>24)  ;
																		//end
																		
																	end else begin								//C1 /4 ib SAL r/m16, imm8
																		reg1_addr_o[4:2]	=	rm;
																		reg1_addr_o[1:0]	=	2'b01;
																		
																		disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																		imm				= disp8;
																		data_len	=	8;
																		
																		//modi on 2015-10-24
																		//if(`LITTLE_END == `True_v)	begin
																		//	imm = ((imm & 16'h00FF)<<8)  | ((imm & 16'hFF00) >>8)  ;
																		//end
																	end
																	
																end else begin
																
																end		
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end	
									
									`SAR_REG	:	begin
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_SAR_OP;
																alusel_o			=	`EXE_RES_SHIFT;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																opcode_len		= 8;
																cmdcode_len		=	8;
																
																if(mod == 2'b11)	begin					//C1 /4 ib SAL r/m32, imm8
																	if(pre_66 == `True_v)	begin
																		reg1_addr_o[4:2]	=	rm;
																		reg1_addr_o[1:0]	=	2'b11;
																		
																		disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																		imm				= disp8;
																		data_len	=	8;
																		
																		//modi on 2015-10-24
																		//if(`LITTLE_END == `True_v)	begin
																		//	imm = ((imm & 32'h000000FF)<<24) | ((imm & 32'h0000FF00)<<8) | ((imm & 32'h00FF0000) >>8) | ((imm & 32'hFF000000) >>24)  ;
																		//end
																		
																	end else begin								//C1 /4 ib SAL r/m16, imm8
																		reg1_addr_o[4:2]	=	rm;
																		reg1_addr_o[1:0]	=	2'b01;
																		
																		reg1_addr_o[4:2]	=	rm;
																		reg1_addr_o[1:0]	=	2'b01;
																		
																		disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																		imm				= disp8;
																		data_len	=	8;
																		
																		//modi on 2015-10-24
																		//if(`LITTLE_END == `True_v)	begin
																		//	imm = ((imm & 16'h00FF)<<8)  | ((imm & 16'hFF00) >>8)  ;
																		//end
																	end
																	
																end else begin
																
																end			
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
									
									`SHL_REG	:	begin
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_SHL_OP;
																alusel_o			=	`EXE_RES_SHIFT;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																opcode_len		= 8;
																cmdcode_len		=	8;
																
																if(mod == 2'b11)	begin					//C1 /4 ib SAL r/m32, imm8
																	if(pre_66 == `True_v)	begin
																		reg1_addr_o[4:2]	=	rm;
																		reg1_addr_o[1:0]	=	2'b11;
																		
																		disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																		imm				= disp8;
																		data_len	=	8;
																		
																		//modi on 2015-10-24
																		//if(`LITTLE_END == `True_v)	begin
																		//	imm = ((imm & 32'h000000FF)<<24) | ((imm & 32'h0000FF00)<<8) | ((imm & 32'h00FF0000) >>8) | ((imm & 32'hFF000000) >>24)  ;
																		//end
																	end else begin								//C1 /4 ib SAL r/m16, imm8
																		reg1_addr_o[4:2]	=	rm;
																		reg1_addr_o[1:0]	=	2'b01;
																		
																		disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																		imm				= disp8;
																		data_len	=	8;
																		
																		//modi on 2015-10-24
																		//if(`LITTLE_END == `True_v)	begin
																		//	imm = ((imm & 16'h00FF)<<8)  | ((imm & 16'hFF00) >>8)  ;
																		//end
																	end
																	
																end else begin
																
																end																		
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
								
								`SHR_REG	:	begin
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_SHR_OP;
																alusel_o			=	`EXE_RES_SHIFT;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																opcode_len		= 8;
																cmdcode_len		=	8;
																
																if(mod == 2'b11)	begin					//C1 /4 ib SAL r/m32, imm8
																	if(pre_66 == `True_v)	begin
																		reg1_addr_o[4:2]	=	rm;
																		reg1_addr_o[1:0]	=	2'b11;
																		
																		disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																		imm				= disp8;
																		data_len	=	8;
																		
																		//modi on 2015-10-24
																		//if(`LITTLE_END == `True_v)	begin
																		//	imm = ((imm & 32'h000000FF)<<24) | ((imm & 32'h0000FF00)<<8) | ((imm & 32'h00FF0000) >>8) | ((imm & 32'hFF000000) >>24)  ;
																		//end
																		
																	end else begin								//C1 /4 ib SAL r/m16, imm8
																		reg1_addr_o[4:2]	=	rm;
																		reg1_addr_o[1:0]	=	2'b01;
																		
																		disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																		imm				= disp8;
																		data_len	=	8;
																		
																		//modi on 2015-10-24
																		//if(`LITTLE_END == `True_v)	begin
																		//	imm = ((imm & 16'h00FF)<<8)  | ((imm & 16'hFF00) >>8)  ;
																		//end
																	end
																	
																end else begin
																
																end	
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end	
								
								`RCL_REG	:	begin
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_RCL_OP;
																alusel_o			=	`EXE_RES_SHIFT;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin					//C1 /0 ib ROL r/m32, imm8
																			if(pre_66 == `True_v)	begin
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b11;
																				
																				disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																				imm				= disp8;
																				data_len	=	8;
																				
																				//modi on 2015-10-24
																				//if(`LITTLE_END == `True_v)	begin
																				//	imm = ((imm & 32'h000000FF)<<24) | ((imm & 32'h0000FF00)<<8) | ((imm & 32'h00FF0000) >>8) | ((imm & 32'hFF000000) >>24)  ;
																				//end
																				
																			end else begin								//C1 /0 ib ROL r/m16, imm8
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b01;
																				
																				disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																				imm				= disp8;
																				data_len	=	8;
																				
																				//modi on 2015-10-24
																				//if(`LITTLE_END == `True_v)	begin
																				//	imm = ((imm & 16'h00FF)<<8)  | ((imm & 16'hFF00) >>8)  ;
																				//end
																				
																			end
																			
																		end else begin
																		
																		end																
																		
																		
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end
																
									 `RCR_REG	:	begin
																		wreg_o				=	`WriteEnable;
																		aluop_o				=	`EXE_RCR_OP;
																		alusel_o			=	`EXE_RES_SHIFT;
																		reg1_read_o		=	1'b1;
																		reg2_read_o		=	1'b0;
																		
																		mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin					//C1 /3 ib RCR r/m32, imm8
																			if(pre_66 == `True_v)	begin
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b11;
																				
																				disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																				imm				= disp8;
																				data_len	=	8;
																				
																				//modi on 2015-10-24
																				//if(`LITTLE_END == `True_v)	begin
																				//	imm = ((imm & 32'h000000FF)<<24) | ((imm & 32'h0000FF00)<<8) | ((imm & 32'h00FF0000) >>8) | ((imm & 32'hFF000000) >>24)  ;
																				//end
																				
																			end else begin								//C1 /3 ib RCR r/m16, imm8
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b01;
																				
																				disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																				imm				= disp8;
																				data_len	=	8;
																				
																				//modi on 2015-10-24
																				//if(`LITTLE_END == `True_v)	begin
																				//	imm = ((imm & 16'h00FF)<<8)  | ((imm & 16'hFF00) >>8)  ;
																				//end
																			end
																			
																		end else begin
																		
																		end		
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end
																
									 `ROL_REG	:	begin
																		wreg_o				=	`WriteEnable;
																		aluop_o				=	`EXE_ROL_OP;
																		alusel_o			=	`EXE_RES_SHIFT;
																		reg1_read_o		=	1'b1;
																		reg2_read_o		=	1'b0;
																		
																		mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin					//C1 /0 ib ROL r/m32, imm8
																			if(pre_66 == `True_v)	begin
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b11;
																				
																				disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																				imm				= disp8;
																				data_len	=	8;
																				
																				//modi on 2015-10-24
																				//if(`LITTLE_END == `True_v)	begin
																				//	imm = ((imm & 32'h000000FF)<<24) | ((imm & 32'h0000FF00)<<8) | ((imm & 32'h00FF0000) >>8) | ((imm & 32'hFF000000) >>24)  ;
																				//end
																				
																			end else begin								//C1 /0 ib ROL r/m16, imm8
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b01;
																				
																				disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																				imm				= disp8;
																				data_len	=	8;
																				
																				//modi on 2015-10-24
																				//if(`LITTLE_END == `True_v)	begin
																				//	imm = ((imm & 16'h00FF)<<8)  | ((imm & 16'hFF00) >>8)  ;
																				//end
																				
																			end
																			
																		end else begin
																		
																		end		
																		
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end
																
									 `ROR_REG	:	begin
																		wreg_o				=	`WriteEnable;
																		aluop_o				=	`EXE_ROR_OP;
																		alusel_o			=	`EXE_RES_SHIFT;
																		reg1_read_o		=	1'b1;
																		reg2_read_o		=	1'b0;
																		
																		mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin					//C1 /1 ib ROR r/m32, imm8
																			if(pre_66 == `True_v)	begin
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b11;
																				
																				disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																				imm				= disp8;
																				data_len	=	8;
																				
																				//modi on 2015-10-24
																				//if(`LITTLE_END == `True_v)	begin
																				//	imm = ((imm & 32'h000000FF)<<24) | ((imm & 32'h0000FF00)<<8) | ((imm & 32'h00FF0000) >>8) | ((imm & 32'hFF000000) >>24)  ;
																				//end
																				
																			end else begin								//C1 /1 ib ROR r/m16, imm8
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b01;
																				
																				disp8			=	{8'h0, cur_inst[(`InstLen - 17)	:	(`InstLen - 24)]};	//{16'h0, cur_inst[32:0]};																					
																				imm				= disp8;
																				data_len	=	8;
																				
																				//modi on 2015-10-24
																				//if(`LITTLE_END == `True_v)	begin
																				//	imm = ((imm & 16'h00FF)<<8)  | ((imm & 16'hFF00) >>8)  ;
																				//end
																			end
																			
																		end else begin
																		
																		end		
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end	
																
											
																	
												default:	begin
																end											
																			
										endcase
										
								end			
								
//-------------------------- leave	-------------------------------------
				
				`OPCODE_C9	:	begin		//	C9 LEAVE
								wreg_o				=	`WriteEnable;
								aluop_o				=	`EXE_LEAVE_OP;
								alusel_o			=	`EXE_RES_SYS;
								reg1_read_o		=	1'b1;
								reg2_read_o		=	1'b1;
																						
								opcode_len		= 8;
								cmdcode_len		=	0;	
								data_len			= 0;		
								
								reg1_addr_o		=	`ESP;	
								reg2_addr_o		=	`EBP;	
								
								wd_o					=	reg2_addr_o ;													
																
								tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
								instvalid	=	`InstValid;							
						end


//-------------------------- sal	-------------------------------------								
						`OPCODE_D0	:	begin
										regop						=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];						//cur_inst[21:19];
								
										case(regop)			//D0 /4 SAL r/m8, 1		
											`SAL_REG	:	begin
																		wreg_o				=	`WriteEnable;
																		aluop_o				=	`EXE_SAL_OP;
																		alusel_o			=	`EXE_RES_SHIFT;
																		reg1_read_o		=	1'b1;
																		reg2_read_o		=	1'b0;
																		
																		mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin
																			reg1_addr_o[4:2]	=	rm;
																			reg1_addr_o[1:0]	=	2'b00;
																		end else begin
																		
																		end																
																																						
																		imm				= 1;
																		data_len	=	0;
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end	
											
											`SAR_REG	:	begin
																		wreg_o				=	`WriteEnable;
																		aluop_o				=	`EXE_SAR_OP;
																		alusel_o			=	`EXE_RES_SHIFT;
																		reg1_read_o		=	1'b1;
																		reg2_read_o		=	1'b0;
																		
																		mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin
																			reg1_addr_o[4:2]	=	rm;
																			reg1_addr_o[1:0]	=	2'b00;
																		end else begin
																		
																		end																
																		
																		imm				= 1;
																		data_len	=	0;
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end
											
											`SHL_REG	:	begin
																		wreg_o				=	`WriteEnable;
																		aluop_o				=	`EXE_SHL_OP;
																		alusel_o			=	`EXE_RES_SHIFT;
																		reg1_read_o		=	1'b1;
																		reg2_read_o		=	1'b0;
																		
																		mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin
																			reg1_addr_o[4:2]	=	rm;
																			reg1_addr_o[1:0]	=	2'b00;
																		end else begin
																		
																		end																
																		
																		imm				= 1;
																		data_len	=	0;
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end
										
										`SHR_REG	:	begin
																		wreg_o				=	`WriteEnable;
																		aluop_o				=	`EXE_SHR_OP;
																		alusel_o			=	`EXE_RES_SHIFT;
																		reg1_read_o		=	1'b1;
																		reg2_read_o		=	1'b0;
																		
																		mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin
																			reg1_addr_o[4:2]	=	rm;
																			reg1_addr_o[1:0]	=	2'b00;
																		end else begin
																		
																		end																
																		
																		imm				= 1;
																		data_len	=	0;
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end	
											
										`RCL_REG	:	begin			//D0 /2 RCL r/m8, 1
																		wreg_o				=	`WriteEnable;
																		aluop_o				=	`EXE_RCL_OP;
																		alusel_o			=	`EXE_RES_SHIFT;
																		reg1_read_o		=	1'b1;
																		reg2_read_o		=	1'b0;
																		
																		mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin
																			reg1_addr_o[4:2]	=	rm;
																			reg1_addr_o[1:0]	=	2'b00;
																		end else begin
																		
																		end																
																																						
																		imm				= 1;
																		data_len	=	0;
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end	
																
										`RCR_REG	:	begin			//D0 /3 RCR r/m8, 1
																		wreg_o				=	`WriteEnable;
																		aluop_o				=	`EXE_RCR_OP;
																		alusel_o			=	`EXE_RES_SHIFT;
																		reg1_read_o		=	1'b1;
																		reg2_read_o		=	1'b0;
																		
																		mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin
																			reg1_addr_o[4:2]	=	rm;
																			reg1_addr_o[1:0]	=	2'b00;
																		end else begin
																		
																		end																
																																						
																		imm				= 1;
																		data_len	=	0;
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end	
																
										`ROL_REG	:	begin			//D0 /0 ROL r/m8, 1
																		wreg_o				=	`WriteEnable;
																		aluop_o				=	`EXE_ROL_OP;
																		alusel_o			=	`EXE_RES_SHIFT;
																		reg1_read_o		=	1'b1;
																		reg2_read_o		=	1'b0;
																		
																		mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin
																			reg1_addr_o[4:2]	=	rm;
																			reg1_addr_o[1:0]	=	2'b00;
																		end else begin
																		
																		end																
																																						
																		imm				= 1;
																		data_len	=	0;
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end	
																
										`ROR_REG	:	begin			//D0 /1 ROR r/m8, 1
																		wreg_o				=	`WriteEnable;
																		aluop_o				=	`EXE_ROR_OP;
																		alusel_o			=	`EXE_RES_SHIFT;
																		reg1_read_o		=	1'b1;
																		reg2_read_o		=	1'b0;
																		
																		mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin
																			reg1_addr_o[4:2]	=	rm;
																			reg1_addr_o[1:0]	=	2'b00;
																		end else begin
																		
																		end																
																																						
																		imm				= 1;
																		data_len	=	0;
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end	
										
										
																
											
																	
												default:	begin
																end											
																			
										endcase
										
								end
								
						`OPCODE_D1	:	begin
										regop						=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];						//cur_inst[21:19];
								
										case(regop)					
											`SAL_REG	:	begin
																		wreg_o				=	`WriteEnable;
																		aluop_o				=	`EXE_SAL_OP;
																		alusel_o			=	`EXE_RES_SHIFT;
																		reg1_read_o		=	1'b1;
																		reg2_read_o		=	1'b0;
																		
																		mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin					//D1 /4 SAL r/m32, 1
																			if(pre_66 == `True_v)	begin
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b11;
																				
																			end else begin								//D1 /4 SAL r/m16, 1
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b01;
																			end
																			
																		end else begin
																		
																		end																
																		
																		imm				= 1;
																		data_len	=	0;
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end	
											
											`SAR_REG	:	begin
																		wreg_o				=	`WriteEnable;
																		aluop_o				=	`EXE_SAR_OP;
																		alusel_o			=	`EXE_RES_SHIFT;
																		reg1_read_o		=	1'b1;
																		reg2_read_o		=	1'b0;
																		
																		mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin					//C1 /4 ib SAL r/m32, imm8
																			if(pre_66 == `True_v)	begin
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b11;
																				
																			end else begin								//C1 /4 ib SAL r/m16, imm8
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b01;
																			end
																			
																		end else begin
																		
																		end																	
																		
																		imm				= 1;
																		data_len	=	0;
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end
											
											`SHL_REG	:	begin
																		wreg_o				=	`WriteEnable;
																		aluop_o				=	`EXE_SHL_OP;
																		alusel_o			=	`EXE_RES_SHIFT;
																		reg1_read_o		=	1'b1;
																		reg2_read_o		=	1'b0;
																		
																		mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin					//C1 /4 ib SAL r/m32, imm8
																			if(pre_66 == `True_v)	begin
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b11;
																				
																			end else begin								//C1 /4 ib SAL r/m16, imm8
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b01;
																			end
																			
																		end else begin
																		
																		end																	
																		
																		imm				= 1;
																		data_len	=	0;
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end
										
										`SHR_REG	:	begin
																		wreg_o				=	`WriteEnable;
																		aluop_o				=	`EXE_SHR_OP;
																		alusel_o			=	`EXE_RES_SHIFT;
																		reg1_read_o		=	1'b1;
																		reg2_read_o		=	1'b0;
																		
																		mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin					//C1 /4 ib SAL r/m32, imm8
																			if(pre_66 == `True_v)	begin
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b11;
																				
																			end else begin								//C1 /4 ib SAL r/m16, imm8
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b01;
																			end
																			
																		end else begin
																		
																		end																	
																		
																		imm				= 1;
																		data_len	=	0;
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end	
										
										`RCL_REG	:	begin
																		wreg_o				=	`WriteEnable;
																		aluop_o				=	`EXE_RCL_OP;
																		alusel_o			=	`EXE_RES_SHIFT;
																		reg1_read_o		=	1'b1;
																		reg2_read_o		=	1'b0;
																		
																		mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin					//D1 /2 RCL r/m32, 1
																			if(pre_66 == `True_v)	begin
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b11;
																				
																			end else begin								//D1 /2 RCL r/m16, 1
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b01;
																			end
																			
																		end else begin
																		
																		end																
																		
																		imm				= 1;
																		data_len	=	0;
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end
																
										`RCR_REG	:	begin
																		wreg_o				=	`WriteEnable;
																		aluop_o				=	`EXE_RCR_OP;
																		alusel_o			=	`EXE_RES_SHIFT;
																		reg1_read_o		=	1'b1;
																		reg2_read_o		=	1'b0;
																		
																		mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin					//D1 /3 RCR r/m32, 1
																			if(pre_66 == `True_v)	begin
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b11;
																				
																			end else begin								//D1 /3 RCR r/m16, 1
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b01;
																			end
																			
																		end else begin
																		
																		end																
																		
																		imm				= 1;
																		data_len	=	0;
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end
																
										`ROL_REG	:	begin
																		wreg_o				=	`WriteEnable;
																		aluop_o				=	`EXE_ROL_OP;
																		alusel_o			=	`EXE_RES_SHIFT;
																		reg1_read_o		=	1'b1;
																		reg2_read_o		=	1'b0;
																		
																		mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin					//D1 /0 ROL r/m32, 1
																			if(pre_66 == `True_v)	begin
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b11;
																				
																			end else begin								//D1 /0 ROL r/m16, 1
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b01;
																			end
																			
																		end else begin
																		
																		end																
																		
																		imm				= 1;
																		data_len	=	0;
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end
																
										`ROR_REG	:	begin
																		wreg_o				=	`WriteEnable;
																		aluop_o				=	`EXE_ROR_OP;
																		alusel_o			=	`EXE_RES_SHIFT;
																		reg1_read_o		=	1'b1;
																		reg2_read_o		=	1'b0;
																		
																		mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin					//D1 /1 ROR r/m32, 1
																			if(pre_66 == `True_v)	begin
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b11;
																				
																			end else begin								//D1 /1 ROR r/m16, 1
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b01;
																			end
																			
																		end else begin
																		
																		end																
																		
																		imm				= 1;
																		data_len	=	0;
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end							
												
											
																	
												default:	begin
																end											
																			
										endcase
										
								end			
								
						`OPCODE_D2	:	begin
										regop						=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];						//cur_inst[21:19];
								
										case(regop)			//D2 /4 SAL r/m8, CL
											`SAL_REG	:	begin
																		wreg_o				=	`WriteEnable;
																		aluop_o				=	`EXE_SAL_OP;
																		alusel_o			=	`EXE_RES_SHIFT;
																		reg1_read_o		=	1'b1;
																		reg2_read_o		=	1'b1;
																		
																		mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin
																			reg1_addr_o[4:2]	=	rm;
																			reg1_addr_o[1:0]	=	2'b00;
																			
																			reg2_addr_o				=	`CL;																					
																		end else begin
																		
																		end																
																		
																		data_len	=	0;
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end	
											
											`SAR_REG	:	begin
																		wreg_o				=	`WriteEnable;
																		aluop_o				=	`EXE_SAR_OP;
																		alusel_o			=	`EXE_RES_SHIFT;
																		reg1_read_o		=	1'b1;
																		reg2_read_o		=	1'b1;
																		
																		mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin
																			reg1_addr_o[4:2]	=	rm;
																			reg1_addr_o[1:0]	=	2'b00;
																			
																			reg2_addr_o				=	`CL;
																		end else begin
																		
																		end																
																		
																		data_len	=	0;
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end	
											
											`SHL_REG	:	begin
																		wreg_o				=	`WriteEnable;
																		aluop_o				=	`EXE_SHL_OP;
																		alusel_o			=	`EXE_RES_SHIFT;
																		reg1_read_o		=	1'b1;
																		reg2_read_o		=	1'b1;
																		
																		mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin
																			reg1_addr_o[4:2]	=	rm;
																			reg1_addr_o[1:0]	=	2'b00;
																			
																			reg2_addr_o				=	`CL;
																		end else begin
																		
																		end																
																		
																		data_len	=	0;
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end	
										
										`SHR_REG	:	begin
																		wreg_o				=	`WriteEnable;
																		aluop_o				=	`EXE_SHR_OP;
																		alusel_o			=	`EXE_RES_SHIFT;
																		reg1_read_o		=	1'b1;
																		reg2_read_o		=	1'b1;
																		
																		mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin
																			reg1_addr_o[4:2]	=	rm;
																			reg1_addr_o[1:0]	=	2'b00;
																			
																			reg2_addr_o				=	`CL;
																		end else begin
																		
																		end																
																		
																		data_len	=	0;
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end		
											
										`RCL_REG	:	begin				//D2 /2 RCL r/m8, CL
																		wreg_o				=	`WriteEnable;
																		aluop_o				=	`EXE_RCL_OP;
																		alusel_o			=	`EXE_RES_SHIFT;
																		reg1_read_o		=	1'b1;
																		reg2_read_o		=	1'b1;
																		
																		mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin
																			reg1_addr_o[4:2]	=	rm;
																			reg1_addr_o[1:0]	=	2'b00;
																			
																			reg2_addr_o				=	`CL;																					
																		end else begin
																		
																		end																
																		
																		data_len	=	0;
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end	
																
										`RCR_REG	:	begin				//D2 /3 RCR r/m8, CL
																		wreg_o				=	`WriteEnable;
																		aluop_o				=	`EXE_RCR_OP;
																		alusel_o			=	`EXE_RES_SHIFT;
																		reg1_read_o		=	1'b1;
																		reg2_read_o		=	1'b1;
																		
																		mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin
																			reg1_addr_o[4:2]	=	rm;
																			reg1_addr_o[1:0]	=	2'b00;
																			
																			reg2_addr_o				=	`CL;																					
																		end else begin
																		
																		end																
																		
																		data_len	=	0;
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end	
																
										`ROL_REG	:	begin				//D2 /0 ROL r/m8, CL
																		wreg_o				=	`WriteEnable;
																		aluop_o				=	`EXE_ROL_OP;
																		alusel_o			=	`EXE_RES_SHIFT;
																		reg1_read_o		=	1'b1;
																		reg2_read_o		=	1'b1;
																		
																		mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin
																			reg1_addr_o[4:2]	=	rm;
																			reg1_addr_o[1:0]	=	2'b00;
																			
																			reg2_addr_o				=	`CL;																					
																		end else begin
																		
																		end																
																		
																		data_len	=	0;
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end	
																
										`ROR_REG	:	begin				//D2 /1 ROR r/m8, CL
																		wreg_o				=	`WriteEnable;
																		aluop_o				=	`EXE_ROR_OP;
																		alusel_o			=	`EXE_RES_SHIFT;
																		reg1_read_o		=	1'b1;
																		reg2_read_o		=	1'b1;
																		
																		mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin
																			reg1_addr_o[4:2]	=	rm;
																			reg1_addr_o[1:0]	=	2'b00;
																			
																			reg2_addr_o				=	`CL;																					
																		end else begin
																		
																		end																
																		
																		data_len	=	0;
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end	
										
										
														
											
																	
												default:	begin
																end											
																			
										endcase
										
								end		
								
						`OPCODE_D3	:	begin
										regop						=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];						//cur_inst[21:19];
								
										case(regop)					
											`SAL_REG	:	begin
																		wreg_o				=	`WriteEnable;
																		aluop_o				=	`EXE_SAL_OP;
																		alusel_o			=	`EXE_RES_SHIFT;
																		reg1_read_o		=	1'b1;
																		reg2_read_o		=	1'b1;
																		
																		mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin					//D3 /4 SAL r/m32, CL
																			if(pre_66 == `True_v)	begin
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b11;
																				
																			end else begin								//D3 /4 SAL r/m16, CL
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b01;
																			end
																			
																		end else begin
																		
																		end																
																		
																		reg2_addr_o				=	`CL;
																		data_len	=	0;
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end	
											
											`SAR_REG	:	begin
																		wreg_o				=	`WriteEnable;
																		aluop_o				=	`EXE_SAR_OP;
																		alusel_o			=	`EXE_RES_SHIFT;
																		reg1_read_o		=	1'b1;
																		reg2_read_o		=	1'b1;
																		
																		mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin					//D3 /4 SAL r/m32, CL
																			if(pre_66 == `True_v)	begin
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b11;
																				
																			end else begin								//D3 /4 SAL r/m16, 1
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b01;
																			end
																			
																		end else begin
																		
																		end																
																		
																		reg2_addr_o				=	`CL;
																		data_len	=	0;
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end	
											
											`SHL_REG	:	begin
																		wreg_o				=	`WriteEnable;
																		aluop_o				=	`EXE_SHL_OP;
																		alusel_o			=	`EXE_RES_SHIFT;
																		reg1_read_o		=	1'b1;
																		reg2_read_o		=	1'b1;
																		
																		mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin					//D3 /4 SAL r/m32, 1
																			if(pre_66 == `True_v)	begin
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b11;
																				
																			end else begin								//D3 /4 SAL r/m16, 1
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b01;
																			end
																			
																		end else begin
																		
																		end																
																		
																		reg2_addr_o				=	`CL;
																		data_len	=	0;
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end	
										
										`SHR_REG	:	begin
																		wreg_o				=	`WriteEnable;
																		aluop_o				=	`EXE_SHR_OP;
																		alusel_o			=	`EXE_RES_SHIFT;
																		reg1_read_o		=	1'b1;
																		reg2_read_o		=	1'b1;
																		
																		mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin					//D3 /4 SAL r/m32, 1
																			if(pre_66 == `True_v)	begin
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b11;
																				
																			end else begin								//D3 /4 SAL r/m16, 1
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b01;
																			end
																			
																		end else begin
																		
																		end																
																		
																		reg2_addr_o				=	`CL;
																		data_len	=	0;
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end		
										
										`RCL_REG	:	begin
																		wreg_o				=	`WriteEnable;
																		aluop_o				=	`EXE_RCL_OP;
																		alusel_o			=	`EXE_RES_SHIFT;
																		reg1_read_o		=	1'b1;
																		reg2_read_o		=	1'b1;
																		
																		mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin					//D3 /2 RCL r/m32, CL
																			if(pre_66 == `True_v)	begin
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b11;
																				
																			end else begin								//D3 /2 RCL r/m16, CL
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b01;
																			end
																			
																		end else begin
																		
																		end																
																		
																		reg2_addr_o				=	`CL;
																		data_len	=	0;
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end	
																
										`RCR_REG	:	begin
																		wreg_o				=	`WriteEnable;
																		aluop_o				=	`EXE_RCR_OP;
																		alusel_o			=	`EXE_RES_SHIFT;
																		reg1_read_o		=	1'b1;
																		reg2_read_o		=	1'b1;
																		
																		mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin					//D3 /3 RCR r/m32, CL
																			if(pre_66 == `True_v)	begin
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b11;
																				
																			end else begin								//D3 /3 RCR r/m16, CL
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b01;
																			end
																			
																		end else begin
																		
																		end																
																		
																		reg2_addr_o				=	`CL;
																		data_len	=	0;
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end	
																
										`ROL_REG	:	begin
																		wreg_o				=	`WriteEnable;
																		aluop_o				=	`EXE_ROL_OP;
																		alusel_o			=	`EXE_RES_SHIFT;
																		reg1_read_o		=	1'b1;
																		reg2_read_o		=	1'b1;
																		
																		mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin					//D3 /0 ROL r/m32, CL
																			if(pre_66 == `True_v)	begin
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b11;
																				
																			end else begin								//D3 /0 ROL r/m16, CL
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b01;
																			end
																			
																		end else begin
																		
																		end																
																		
																		reg2_addr_o				=	`CL;
																		data_len	=	0;
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end	
																
										`ROR_REG	:	begin
																		wreg_o				=	`WriteEnable;
																		aluop_o				=	`EXE_ROR_OP;
																		alusel_o			=	`EXE_RES_SHIFT;
																		reg1_read_o		=	1'b1;
																		reg2_read_o		=	1'b1;
																		
																		mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																		rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																		opcode_len		= 8;
																		cmdcode_len		=	8;
																		
																		if(mod == 2'b11)	begin					//D3 /1 ROR r/m32, CL
																			if(pre_66 == `True_v)	begin
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b11;
																				
																			end else begin								//D3 /1 ROR r/m16, CL
																				reg1_addr_o[4:2]	=	rm;
																				reg1_addr_o[1:0]	=	2'b01;
																			end
																			
																		end else begin
																		
																		end																
																		
																		reg2_addr_o				=	`CL;
																		data_len	=	0;
																		
																		wd_o			=	reg1_addr_o ;															
																		
																		tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																																	
																		instvalid	=	`InstValid;
																end	
																
														
										endcase
										
								end		
	
	//-------------------- loop ------------------------------------------------------
				`OPCODE_E0	:	begin
							//E0 cb LOOPNE rel8	
							wreg_o				=	`WriteEnable;
							aluop_o				=	`EXE_LOOPNE_OP;
							alusel_o			=	`EXE_RES_JMP;
							reg1_read_o		=	1'b1;
							reg2_read_o		=	1'b0;
							
							reg1_addr_o		=	`CX;							//暂定 CX 为计数器
							
							disp8			=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 16)]};																						
							imm				= disp8;
							
							opcode_len		= 8;
							cmdcode_len		=	0;
							data_len	=	8;		
							
							wd_o			=	reg1_addr_o ;		
							
							tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																						
							instvalid	=	`InstValid;							
								
						end
	
				`OPCODE_E1	:	begin
							//E1 cb LOOPE rel8	
							wreg_o				=	`WriteEnable;
							aluop_o				=	`EXE_LOOPE_OP;
							alusel_o			=	`EXE_RES_JMP;
							reg1_read_o		=	1'b1;
							reg2_read_o		=	1'b0;
							
							reg1_addr_o		=	`CX;							//暂定 CX 为计数器
							
							disp8			=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 16)]};																						
							imm				= disp8;
							
							opcode_len		= 8;
							cmdcode_len		=	0;
							data_len	=	8;
							
							wd_o			=	reg1_addr_o ;				
							
							tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																						
							instvalid	=	`InstValid;							
								
						end
	
				`OPCODE_E2	:	begin
							//E2 cb LOOP rel8		
							wreg_o				=	`WriteEnable;
							aluop_o				=	`EXE_LOOP_OP;
							alusel_o			=	`EXE_RES_JMP;
							reg1_read_o		=	1'b1;
							reg2_read_o		=	1'b0;
							
							reg1_addr_o		=	`CX;							//暂定 CX 为计数器
							
							disp8			=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 16)]};																						
							imm				= disp8;
							
							opcode_len		= 8;
							cmdcode_len		=	0;
							data_len	=	8;		
							
							wd_o			=	reg1_addr_o ;		
							
							tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																						
							instvalid	=	`InstValid;							
								
						end
	
	//-------------------- call ------------------------------------------------------
				`OPCODE_E8	:	begin
							//E8 cw CALL rel16,	E8 cd CALL rel32								
							wreg_o				=	`WriteEnable;
							aluop_o				=	`EXE_CALL_OP_32;
							alusel_o			=	`EXE_RES_JMP;
							reg1_read_o		=	1'b0;
							reg2_read_o		=	1'b1;
							
							disp32						=	{32'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 40)]};																						
							imm								= disp32;							
							
							if(`LITTLE_END == `True_v)	begin
									imm = ((imm & 32'h000000FF)<<24) | ((imm & 32'h0000FF00)<<8) | ((imm & 32'h00FF0000) >>8) | ((imm & 32'hFF000000) >>24)  ;
							end 
																	
							opcode_len		= 8;
							cmdcode_len		=	0;
							data_len			=	32;							//暂时都按32位算
							
							reg2_addr_o		=	`ESP;
																
							wd_o					=	reg2_addr_o ;															
							
							tot_len				=	opcode_len	+ cmdcode_len	+ data_len;
																						
							instvalid			=	`InstValid;							
								
						end
	
	
	//-------------------- jmp ------------------------------------------------------
				`OPCODE_E9	:	begin
							//E9 cw JMP rel16,	E9 cd JMP rel32								
							wreg_o				=	`WriteDisable;
							aluop_o				=	`EXE_JMP_OP_32;
							alusel_o			=	`EXE_RES_JMP;
							reg1_read_o		=	1'b0;
							reg2_read_o		=	1'b0;
							
							disp32						=	{32'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 40)]};																						
							imm								= disp32;
																	
							opcode_len		= 8;
							cmdcode_len		=	0;
							data_len	=	32;							//暂时都按32位算
																
							//wd_o			=	`AL ;															
							
							tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																						
							instvalid	=	`InstValid;							
								
						end
	
				`OPCODE_EB	:	begin
							//EB cb JMP rel8								
							wreg_o				=	`WriteDisable;
							aluop_o				=	`EXE_JMP_OP_8;
							alusel_o			=	`EXE_RES_JMP;
							reg1_read_o		=	1'b0;
							reg2_read_o		=	1'b0;
							
							disp8			=	{8'h0, cur_inst[(`InstLen - 9)	:	(`InstLen - 16)]};																						
							imm				= disp8;
							
							opcode_len		= 8;
							cmdcode_len		=	0;
							data_len	=	8;
																
							//wd_o			=	`AL ;															
							
							tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																						
							instvalid	=	`InstValid;							
								
						end
	
	//----------------- not/mul -----------------------------------------------------
				
				`OPCODE_F6	:	begin
								regop						=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];						//cur_inst[21:19];
						
								case(regop)			//F6 /2 NOT r/m8				
									`NOT_REG	:	begin
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_NOT_OP;
																alusel_o			=	`EXE_RES_LOGIC;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																opcode_len		= 8;
																cmdcode_len		=	8;
																data_len	=	0;
																
																if(mod == 2'b11)	begin
																	reg1_addr_o[4:2]	=	rm;
																	reg1_addr_o[1:0]	=	2'b00;														
																	
																end else begin
																
																end	
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end							
									
									`MUL_REG	:	begin				//	F6 /4 MUL r/m8
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_MUL_OP_8;
																alusel_o			=	`EXE_RES_ARITH;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b1;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																opcode_len		= 8;
																cmdcode_len		=	8;
																
																if(mod == 2'b11)	begin
																	reg2_addr_o[4:2]	=	rm;
																	reg2_addr_o[1:0]	=	2'b00;
																end else begin
																
																end
																
																data_len	=	0;
																
																//modi on 2015-11-7
																//reg1_addr_o[4:2]	=	`AL;
																//reg1_addr_o[1:0]	=	2'b00;
																reg1_addr_o					=	`AL;
																
																//modi on 2015-11-5
																//wd_o			=	reg1_addr_o ;	
																wd_o			=	`AX ;														
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
									
									`DIV_REG	:	begin				//	F6 /6 DIV r/m8
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_DIV_OP_8;
																alusel_o			=	`EXE_RES_ARITH;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b1;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																opcode_len		= 8;
																cmdcode_len		=	8;
																
																if(mod == 2'b11)	begin
																	reg2_addr_o[4:2]	=	rm;
																	reg2_addr_o[1:0]	=	2'b00;
																end else begin
																
																end
																
																data_len	=	0;
																
																reg1_addr_o				=	`AX;
																																
																//modi on 2015-11-5
																//wd_o			=	reg1_addr_o ;	
																wd_o			=	`AL;														
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
									
									
									
															
										default:	begin
														end											
																	
								endcase
								
						end
				
				
				`OPCODE_F7	:	begin
								regop						=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];						//cur_inst[21:19];
						
								case(regop)							
									`NOT_REG	:	begin
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_NOT_OP;
																alusel_o			=	`EXE_RES_LOGIC;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																opcode_len		= 8;
																cmdcode_len		=	8;
																data_len	=	0;
																
																if(mod == 2'b11)	begin
																	if(pre_66 == `True_v) begin	// F7 /2 NOT r/m32
																		reg1_addr_o[4:2]	=	rm;
																		reg1_addr_o[1:0]	=	2'b11;															
																		
																	end else begin	// F7 /2 NOT r/m16
																		reg1_addr_o[4:2]	=	rm;
																		reg1_addr_o[1:0]	=	2'b01;															
																		
																	end																
																	
																end else begin
																
																end	
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end							
									
									`MUL_REG	:	begin				
																wreg_o				=	`WriteEnable;																
																alusel_o			=	`EXE_RES_ARITH;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b1;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																opcode_len		= 8;
																cmdcode_len		=	8;
																
																if(mod == 2'b11)	begin							//	F7 /4 MUL r/m32
																			if(pre_66 == `True_v)	begin
																				reg2_addr_o[4:2]	=	rm;
																				reg2_addr_o[1:0]	=	2'b11;
																				
																				reg1_addr_o				=	`EAX;
																				
																				
																				aluop_o						=	`EXE_MUL_OP_32;
																			end else begin								//	F7 /4 MUL r/m16
																				reg2_addr_o[4:2]	=	rm;
																				reg2_addr_o[1:0]	=	2'b01;
																				
																				reg1_addr_o				=	`AX;
																																								
																				aluop_o						=	`EXE_MUL_OP_16;
																			end
																			
																end else begin
																		
																end
																
																data_len	=	0;
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
									
									`DIV_REG	:	begin				
																wreg_o				=	`WriteEnable;																
																alusel_o			=	`EXE_RES_ARITH;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b1;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																opcode_len		= 8;
																cmdcode_len		=	8;
																
																if(mod == 2'b11)	begin							//	F7 /6 DIV r/m32
																			if(pre_66 == `True_v)	begin
																				reg2_addr_o[4:2]	=	rm;
																				reg2_addr_o[1:0]	=	2'b11;
																				
																				reg1_addr_o				=	`EAX;
																				
																				
																				aluop_o						=	`EXE_DIV_OP_32;
																			end else begin								//	F7 /6 DIV r/m16
																				reg2_addr_o[4:2]	=	rm;
																				reg2_addr_o[1:0]	=	2'b01;
																				
																				reg1_addr_o				=	`AX;
																																								
																				aluop_o						=	`EXE_DIV_OP_16;
																			end
																			
																end else begin
																		
																end
																
																data_len	=	0;
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
									
									
									
															
										default:	begin
														end											
																	
								endcase
								
						end	
//---------------------------------------------------------------------------	
	
					`OPCODE_F8	:	begin			//	F8 CLC							
								wreg_o				=	`WriteEnable;                                                                   		
								aluop_o				=	`EXE_CLC_OP;                                                                    								
								alusel_o			=	`EXE_RES_SYS;                                                                   								
								reg1_read_o		=	1'b0;                                                                           								
								reg2_read_o		=	1'b0;                                                                         								
										
								opcode_len		= 8;                                                                              								
								cmdcode_len		=	0;  
								data_len			=	0;                                                                                  								
								   
								disp8					=	0;																					
								imm						= disp8;
								reg1_addr_o		=	`EFLAGS;                                                                                             								
								wd_o					=	reg1_addr_o ;															                                          								
								                                                                                                								
								tot_len				=	opcode_len	+ cmdcode_len	+ data_len;                                               								
																							                                                                  								
								instvalid			=	`InstValid;                                                      								
							
					end
	
					`OPCODE_F9	:	begin			//	F9 STC							
								wreg_o				=	`WriteEnable;                                                                   		
								aluop_o				=	`EXE_STC_OP;                                                                    								
								alusel_o			=	`EXE_RES_SYS;                                                                   								
								reg1_read_o		=	1'b0;                                                                           								
								reg2_read_o		=	1'b0;                                                                         								
										
								opcode_len		= 8;                                                                              								
								cmdcode_len		=	0;  
								data_len			=	0;                                                                                  								
								   
								disp8					=	1;																					
								imm						= disp8;
								reg1_addr_o		=	`EFLAGS;                                                                                             								
								wd_o					=	reg1_addr_o ;															                                          								
								                                                                                                								
								tot_len				=	opcode_len	+ cmdcode_len	+ data_len;                                               								
																							                                                                  								
								instvalid			=	`InstValid;                                                      								
							
					end	
	
					`OPCODE_FA	:	begin			//	FA CLI							
								wreg_o				=	`WriteEnable;                                                                   		
								aluop_o				=	`EXE_CLI_OP;                                                                    								
								alusel_o			=	`EXE_RES_SYS;                                                                   								
								reg1_read_o		=	1'b0;                                                                           								
								reg2_read_o		=	1'b0;                                                                         								
										
								opcode_len		= 8;                                                                              								
								cmdcode_len		=	0;  
								data_len			=	0;                                                                                  								
								   
								disp8					=	0;																					
								imm						= disp8;
								reg1_addr_o		=	`EFLAGS;                                                                                             								
								wd_o					=	reg1_addr_o ;															                                          								
								                                                                                                								
								tot_len				=	opcode_len	+ cmdcode_len	+ data_len;                                               								
																							                                                                  								
								instvalid			=	`InstValid;                                                      								
							
					end
	
					`OPCODE_FB	:	begin			//FB STI							
								wreg_o				=	`WriteEnable;                                                                   		
								aluop_o				=	`EXE_STI_OP;                                                                    								
								alusel_o			=	`EXE_RES_SYS;                                                                   								
								reg1_read_o		=	1'b0;                                                                           								
								reg2_read_o		=	1'b0;                                                                         								
										
								opcode_len		= 8;                                                                              								
								cmdcode_len		=	0;  
								data_len			=	0;                                                                                  								
								   
								disp8					=	1;																					
								imm						= disp8;
								reg1_addr_o		=	`EFLAGS;                                                                                             								
								wd_o					=	reg1_addr_o ;															                                          								
								                                                                                                								
								tot_len				=	opcode_len	+ cmdcode_len	+ data_len;                                               								
																							                                                                  								
								instvalid			=	`InstValid;                                                      								
							
					end
														
					`OPCODE_FE	:	begin
								regop						=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];						//cur_inst[21:19];
						
								case(regop)							
									`INC_REG	:	begin				//	FE /0 INC r/m8
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_INC_OP;
																alusel_o			=	`EXE_RES_ARITH;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																opcode_len		= 8;
																cmdcode_len		=	8;
																
																if(mod == 2'b11)	begin
																	reg1_addr_o[4:2]	=	rm;
																	reg1_addr_o[1:0]	=	2'b00;
																	
																end else begin
																
																end																	
																																
																disp8			=	1;																					
																imm				= disp8;
																data_len	=	0;
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end	
														
									`DEC_REG	:	begin				//	FE /1 DEC r/m8
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_DEC_OP;
																alusel_o			=	`EXE_RES_ARITH;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																opcode_len		= 8;
																cmdcode_len		=	8;
																
																if(mod == 2'b11)	begin
																	reg1_addr_o[4:2]	=	rm;
																	reg1_addr_o[1:0]	=	2'b00;
																	
																end else begin
																
																end																	
																																
																disp8			=	1;																					
																imm				= disp8;
																data_len	=	0;
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
															
										default:	begin
														end											
																	
								endcase
								
						end	
														
														
					`OPCODE_FF	:	begin
								regop						=	cur_inst[(`InstLen - 11) 	:	(`InstLen - 13)];						//cur_inst[21:19];
						
								case(regop)							
									`INC_REG	:	begin					
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_INC_OP;
																alusel_o			=	`EXE_RES_ARITH;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																opcode_len		= 8;
																cmdcode_len		=	8;
																
																if(mod == 2'b11)	begin
																	if(pre_66 == `True_v) begin			// FF /0 INC r/m32
																		reg1_addr_o[4:2]	=	regop;
																		reg1_addr_o[1:0]	=	2'b11;																
																		
																	end else begin									// FF /0 INC r/m16
																		reg1_addr_o[4:2]	=	regop;
																		reg1_addr_o[1:0]	=	2'b01;																
																		
																	end	
																	
																end else begin
																
																end																
																																
																disp8			=	1;																					
																imm				= disp8;
																data_len	=	0;
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end	
														
									`DEC_REG	:	begin					
																wreg_o				=	`WriteEnable;
																aluop_o				=	`EXE_DEC_OP;
																alusel_o			=	`EXE_RES_ARITH;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																opcode_len		= 8;
																cmdcode_len		=	8;
																
																if(mod == 2'b11)	begin
																	if(pre_66 == `True_v) begin			// FF /1 DEC r/m32
																		reg1_addr_o[4:2]	=	regop;
																		reg1_addr_o[1:0]	=	2'b11;																
																		
																	end else begin									// FF /1 DEC r/m16
																		reg1_addr_o[4:2]	=	regop;
																		reg1_addr_o[1:0]	=	2'b01;																
																		
																	end	
																	
																end else begin
																
																end																
																																
																disp8			=	1;																					
																imm				= disp8;
																data_len	=	0;
																
																wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
									
									
									`JMP_REG	:	begin
																wreg_o				=	`WriteDisable;																
																alusel_o			=	`EXE_RES_JMP;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b0;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																opcode_len		= 8;
																cmdcode_len		=	8;
																data_len	=	0;
																
																if(mod == 2'b11)	begin
																	if(pre_66 == `True_v) begin	// FF /4 JMP r/m32
																		reg1_addr_o[4:2]	=	rm;
																		reg1_addr_o[1:0]	=	2'b11;															
																		aluop_o						=	`EXE_JMP_OP_32;
																	end else begin							// FF /4 JMP r/m16
																		reg1_addr_o[4:2]	=	rm;
																		reg1_addr_o[1:0]	=	2'b01;															
																		aluop_o						=	`EXE_JMP_OP_16;
																	end																
																	
																end else begin
																
																end	
																
																//wd_o			=	reg1_addr_o ;															
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end						
									
									`PUSH_REG	:	begin					
																wreg_o				=	`WriteEnable;																
																alusel_o			=	`EXE_RES_MOV;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b1;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																opcode_len		= 8;
																cmdcode_len		=	8;
																
																if(mod == 2'b11)	begin
																	if(pre_66 == `True_v) begin			// FF /6 PUSH r/m32
																		reg1_addr_o[4:2]	=	regop;
																		reg1_addr_o[1:0]	=	2'b11;																
																		aluop_o						=	`EXE_PUSH_REG32_OP;
																	end else begin									// FF /6 PUSH r/m16
																		reg1_addr_o[4:2]	=	regop;
																		reg1_addr_o[1:0]	=	2'b01;																
																		aluop_o						=	`EXE_PUSH_REG16_OP;
																	end	
																	
																end else begin
																
																end	
																
																reg2_addr_o		=	`ESP;
																
																wd_o			=	reg2_addr_o ;								//更新esp												
																																
																data_len	=	0;							
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
									
									`CALL_REG	:	begin					
																wreg_o				=	`WriteEnable;																
																alusel_o			=	`EXE_RES_JMP;
																reg1_read_o		=	1'b1;
																reg2_read_o		=	1'b1;
																
																mod						=	cur_inst[(`InstLen - 9) 	:	(`InstLen - 10)];						//cur_inst[23:22];
																rm						=	cur_inst[(`InstLen - 14) 	:	(`InstLen - 16)];						//cur_inst[18:16];	
																opcode_len		= 8;
																cmdcode_len		=	8;
																
																if(mod == 2'b11)	begin
																	if(pre_66 == `True_v) begin			// FF /2 CALL r/m32
																		reg1_addr_o[4:2]	=	rm;
																		reg1_addr_o[1:0]	=	2'b11;																
																		aluop_o						=	`EXE_CALLREG_OP_32;
																	end else begin									// FF /2 CALL r/m16
																		reg1_addr_o[4:2]	=	rm;
																		reg1_addr_o[1:0]	=	2'b01;																
																		aluop_o						=	`EXE_CALLREG_OP_16;
																	end	
																	
																end else begin
																
																end	
																
																reg2_addr_o		=	`ESP;
																
																wd_o			=	reg2_addr_o ;								//更新esp												
																																
																data_len	=	0;							
																
																tot_len		=	opcode_len	+ cmdcode_len	+ data_len;
																															
																instvalid	=	`InstValid;
														end
									
															
															
										default:	begin
														end											
																	
								endcase
								
						end		
										
		//---------------------------------------------------------------------------
		
								
								
						default:	begin
												end
					endcase
					
					
					//----------------------------------------
					//add on 2015-9-24
					if(tot_len < tot_len_i) begin
						cur_pos		= 	`InstLen - 1;					//383
						//--------------------------------------------------
						//modi on 2015-12-22
						//cur_inst			=	384'h000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
						cur_inst			=	96'h000000000000000000000000;
						//--------------------------------------------------
						
						temp				=	tot_len_i - tot_len;
							
						//cur_inst[cur_pos : ((cur_pos + 1) - temp)]	=	inst_i[(temp - 1) : 0];		//下一条指令开头
						//cur_inst[(`InstLen - 1) - : (temp - 1)]	=	inst_i[(temp - 1) : 0];		//下一条指令开头
						//cur_inst[(`InstLen - 1) - : (temp - 1)]	=	inst_i[(temp - 1) : 0];		//下一条指令开头
						
						
						//------------------------------------------
						//modi on 2015-12-11
						/*
						j	=	cur_pos + 1 - temp;
						for(i=0; i<temp; i=i+1)	begin
							cur_inst[j+i]	=	inst_i[i];
						end
						*/
						
						j	=	cur_pos + 1 - temp;
						case(temp)
							8'h01	:	begin
										cur_inst[j+0]	=	inst_i[0];
										end
							8'h02	:	begin
										cur_inst[j+0]	=	inst_i[0];	
										cur_inst[j+1]	=	inst_i[1];
										end
							8'h03	:	begin
										cur_inst[j+0]	=	inst_i[0];	
										cur_inst[j+1]	=	inst_i[1];
										cur_inst[j+2]	=	inst_i[2];
										end
							8'h04	:	begin
										cur_inst[j+0]	=	inst_i[0];	
										cur_inst[j+1]	=	inst_i[1];
										cur_inst[j+2]	=	inst_i[2];
										cur_inst[j+3]	=	inst_i[3];
										end
							8'h05	:	begin
										cur_inst[j+0]	=	inst_i[0];	
										cur_inst[j+1]	=	inst_i[1];
										cur_inst[j+2]	=	inst_i[2];
										cur_inst[j+3]	=	inst_i[3];
										cur_inst[j+4]	=	inst_i[4];
										end
							8'h06	:	begin
										cur_inst[j+0]	=	inst_i[0];	
										cur_inst[j+1]	=	inst_i[1];
										cur_inst[j+2]	=	inst_i[2];
										cur_inst[j+3]	=	inst_i[3];
										cur_inst[j+4]	=	inst_i[4];
										cur_inst[j+5]	=	inst_i[5];
										end
							8'h07	:	begin
										cur_inst[j+0]	=	inst_i[0];	
										cur_inst[j+1]	=	inst_i[1];
										cur_inst[j+2]	=	inst_i[2];
										cur_inst[j+3]	=	inst_i[3];
										cur_inst[j+4]	=	inst_i[4];
										cur_inst[j+5]	=	inst_i[5];	
										cur_inst[j+6]	=	inst_i[6];
										end
							8'h08	:	begin
										cur_inst[j+0]	=	inst_i[0];	
										cur_inst[j+1]	=	inst_i[1];
										cur_inst[j+2]	=	inst_i[2];
										cur_inst[j+3]	=	inst_i[3];
										cur_inst[j+4]	=	inst_i[4];
										cur_inst[j+5]	=	inst_i[5];	
										cur_inst[j+6]	=	inst_i[6];
										cur_inst[j+7]	=	inst_i[7];
										end
							8'h09	:	begin
										cur_inst[j+0]	=	inst_i[0];	
										cur_inst[j+1]	=	inst_i[1];
										cur_inst[j+2]	=	inst_i[2];
										cur_inst[j+3]	=	inst_i[3];
										cur_inst[j+4]	=	inst_i[4];
										cur_inst[j+5]	=	inst_i[5];	
										cur_inst[j+6]	=	inst_i[6];
										cur_inst[j+7]	=	inst_i[7];
										cur_inst[j+8]	=	inst_i[8];
										end
							8'h0a	:	begin
										cur_inst[j+0]	=	inst_i[0];	
										cur_inst[j+1]	=	inst_i[1];
										cur_inst[j+2]	=	inst_i[2];
										cur_inst[j+3]	=	inst_i[3];
										cur_inst[j+4]	=	inst_i[4];
										cur_inst[j+5]	=	inst_i[5];	
										cur_inst[j+6]	=	inst_i[6];
										cur_inst[j+7]	=	inst_i[7];
										cur_inst[j+8]	=	inst_i[8];
										cur_inst[j+9]	=	inst_i[9];
										end
							8'h0b	:	begin
										cur_inst[j+0]	=	inst_i[0];	
										cur_inst[j+1]	=	inst_i[1];
										cur_inst[j+2]	=	inst_i[2];
										cur_inst[j+3]	=	inst_i[3];
										cur_inst[j+4]	=	inst_i[4];
										cur_inst[j+5]	=	inst_i[5];	
										cur_inst[j+6]	=	inst_i[6];
										cur_inst[j+7]	=	inst_i[7];
										cur_inst[j+8]	=	inst_i[8];
										cur_inst[j+9]	=	inst_i[9];
										cur_inst[j+10]	=	inst_i[10];	
										end
							8'h0c	:	begin
										cur_inst[j+0]	=	inst_i[0];	
										cur_inst[j+1]	=	inst_i[1];
										cur_inst[j+2]	=	inst_i[2];
										cur_inst[j+3]	=	inst_i[3];
										cur_inst[j+4]	=	inst_i[4];
										cur_inst[j+5]	=	inst_i[5];	
										cur_inst[j+6]	=	inst_i[6];
										cur_inst[j+7]	=	inst_i[7];
										cur_inst[j+8]	=	inst_i[8];
										cur_inst[j+9]	=	inst_i[9];
										cur_inst[j+10]	=	inst_i[10];	
										cur_inst[j+11]	=	inst_i[11];
										end
							8'h0d	:	begin
										cur_inst[j+0]	=	inst_i[0];	
										cur_inst[j+1]	=	inst_i[1];
										cur_inst[j+2]	=	inst_i[2];
										cur_inst[j+3]	=	inst_i[3];
										cur_inst[j+4]	=	inst_i[4];
										cur_inst[j+5]	=	inst_i[5];	
										cur_inst[j+6]	=	inst_i[6];
										cur_inst[j+7]	=	inst_i[7];
										cur_inst[j+8]	=	inst_i[8];
										cur_inst[j+9]	=	inst_i[9];
										cur_inst[j+10]	=	inst_i[10];	
										cur_inst[j+11]	=	inst_i[11];
										cur_inst[j+12]	=	inst_i[12];
										end
							8'h0e	:	begin
										cur_inst[j+0]	=	inst_i[0];	
										cur_inst[j+1]	=	inst_i[1];
										cur_inst[j+2]	=	inst_i[2];
										cur_inst[j+3]	=	inst_i[3];
										cur_inst[j+4]	=	inst_i[4];
										cur_inst[j+5]	=	inst_i[5];	
										cur_inst[j+6]	=	inst_i[6];
										cur_inst[j+7]	=	inst_i[7];
										cur_inst[j+8]	=	inst_i[8];
										cur_inst[j+9]	=	inst_i[9];
										cur_inst[j+10]	=	inst_i[10];	
										cur_inst[j+11]	=	inst_i[11];
										cur_inst[j+12]	=	inst_i[12];
										cur_inst[j+13]	=	inst_i[13];
										end
							8'h0f	:	begin
										cur_inst[j+0]	=	inst_i[0];	
										cur_inst[j+1]	=	inst_i[1];
										cur_inst[j+2]	=	inst_i[2];
										cur_inst[j+3]	=	inst_i[3];
										cur_inst[j+4]	=	inst_i[4];
										cur_inst[j+5]	=	inst_i[5];	
										cur_inst[j+6]	=	inst_i[6];
										cur_inst[j+7]	=	inst_i[7];
										cur_inst[j+8]	=	inst_i[8];
										cur_inst[j+9]	=	inst_i[9];
										cur_inst[j+10]	=	inst_i[10];	
										cur_inst[j+11]	=	inst_i[11];
										cur_inst[j+12]	=	inst_i[12];
										cur_inst[j+13]	=	inst_i[13];
										cur_inst[j+14]	=	inst_i[14];
										end
							8'h10	:	begin
										cur_inst[j+0]	=	inst_i[0];	
										cur_inst[j+1]	=	inst_i[1];
										cur_inst[j+2]	=	inst_i[2];
										cur_inst[j+3]	=	inst_i[3];
										cur_inst[j+4]	=	inst_i[4];
										cur_inst[j+5]	=	inst_i[5];	
										cur_inst[j+6]	=	inst_i[6];
										cur_inst[j+7]	=	inst_i[7];
										cur_inst[j+8]	=	inst_i[8];
										cur_inst[j+9]	=	inst_i[9];
										cur_inst[j+10]	=	inst_i[10];	
										cur_inst[j+11]	=	inst_i[11];
										cur_inst[j+12]	=	inst_i[12];
										cur_inst[j+13]	=	inst_i[13];
										cur_inst[j+14]	=	inst_i[14];
										cur_inst[j+15]	=	inst_i[15];
										end	
							8'h11	:	begin
										cur_inst[j+0]	=	inst_i[0];	
										cur_inst[j+1]	=	inst_i[1];
										cur_inst[j+2]	=	inst_i[2];
										cur_inst[j+3]	=	inst_i[3];
										cur_inst[j+4]	=	inst_i[4];
										cur_inst[j+5]	=	inst_i[5];	
										cur_inst[j+6]	=	inst_i[6];
										cur_inst[j+7]	=	inst_i[7];
										cur_inst[j+8]	=	inst_i[8];
										cur_inst[j+9]	=	inst_i[9];
										cur_inst[j+10]	=	inst_i[10];	
										cur_inst[j+11]	=	inst_i[11];
										cur_inst[j+12]	=	inst_i[12];
										cur_inst[j+13]	=	inst_i[13];
										cur_inst[j+14]	=	inst_i[14];
										cur_inst[j+15]	=	inst_i[15];	
										cur_inst[j+16]	=	inst_i[16];
										end
							8'h12	:	begin
										cur_inst[j+0]	=	inst_i[0];	
										cur_inst[j+1]	=	inst_i[1];
										cur_inst[j+2]	=	inst_i[2];
										cur_inst[j+3]	=	inst_i[3];
										cur_inst[j+4]	=	inst_i[4];
										cur_inst[j+5]	=	inst_i[5];	
										cur_inst[j+6]	=	inst_i[6];
										cur_inst[j+7]	=	inst_i[7];
										cur_inst[j+8]	=	inst_i[8];
										cur_inst[j+9]	=	inst_i[9];
										cur_inst[j+10]	=	inst_i[10];	
										cur_inst[j+11]	=	inst_i[11];
										cur_inst[j+12]	=	inst_i[12];
										cur_inst[j+13]	=	inst_i[13];
										cur_inst[j+14]	=	inst_i[14];
										cur_inst[j+15]	=	inst_i[15];	
										cur_inst[j+16]	=	inst_i[16];
										cur_inst[j+17]	=	inst_i[17];
										end
							8'h13	:	begin
										cur_inst[j+0]	=	inst_i[0];	
										cur_inst[j+1]	=	inst_i[1];
										cur_inst[j+2]	=	inst_i[2];
										cur_inst[j+3]	=	inst_i[3];
										cur_inst[j+4]	=	inst_i[4];
										cur_inst[j+5]	=	inst_i[5];	
										cur_inst[j+6]	=	inst_i[6];
										cur_inst[j+7]	=	inst_i[7];
										cur_inst[j+8]	=	inst_i[8];
										cur_inst[j+9]	=	inst_i[9];
										cur_inst[j+10]	=	inst_i[10];	
										cur_inst[j+11]	=	inst_i[11];
										cur_inst[j+12]	=	inst_i[12];
										cur_inst[j+13]	=	inst_i[13];
										cur_inst[j+14]	=	inst_i[14];
										cur_inst[j+15]	=	inst_i[15];	
										cur_inst[j+16]	=	inst_i[16];
										cur_inst[j+17]	=	inst_i[17];
										cur_inst[j+18]	=	inst_i[18];
										end
							8'h14	:	begin
										cur_inst[j+0]	=	inst_i[0];	
										cur_inst[j+1]	=	inst_i[1];
										cur_inst[j+2]	=	inst_i[2];
										cur_inst[j+3]	=	inst_i[3];
										cur_inst[j+4]	=	inst_i[4];
										cur_inst[j+5]	=	inst_i[5];	
										cur_inst[j+6]	=	inst_i[6];
										cur_inst[j+7]	=	inst_i[7];
										cur_inst[j+8]	=	inst_i[8];
										cur_inst[j+9]	=	inst_i[9];
										cur_inst[j+10]	=	inst_i[10];	
										cur_inst[j+11]	=	inst_i[11];
										cur_inst[j+12]	=	inst_i[12];
										cur_inst[j+13]	=	inst_i[13];
										cur_inst[j+14]	=	inst_i[14];
										cur_inst[j+15]	=	inst_i[15];	
										cur_inst[j+16]	=	inst_i[16];
										cur_inst[j+17]	=	inst_i[17];
										cur_inst[j+18]	=	inst_i[18];
										cur_inst[j+19]	=	inst_i[19];
										end
							8'h15	:	begin
										cur_inst[j+0]	=	inst_i[0];	
										cur_inst[j+1]	=	inst_i[1];
										cur_inst[j+2]	=	inst_i[2];
										cur_inst[j+3]	=	inst_i[3];
										cur_inst[j+4]	=	inst_i[4];
										cur_inst[j+5]	=	inst_i[5];	
										cur_inst[j+6]	=	inst_i[6];
										cur_inst[j+7]	=	inst_i[7];
										cur_inst[j+8]	=	inst_i[8];
										cur_inst[j+9]	=	inst_i[9];
										cur_inst[j+10]	=	inst_i[10];	
										cur_inst[j+11]	=	inst_i[11];
										cur_inst[j+12]	=	inst_i[12];
										cur_inst[j+13]	=	inst_i[13];
										cur_inst[j+14]	=	inst_i[14];
										cur_inst[j+15]	=	inst_i[15];	
										cur_inst[j+16]	=	inst_i[16];
										cur_inst[j+17]	=	inst_i[17];
										cur_inst[j+18]	=	inst_i[18];
										cur_inst[j+19]	=	inst_i[19];
										cur_inst[j+20]	=	inst_i[20];
										end
							8'h16	:	begin
										cur_inst[j+0]	=	inst_i[0];	
										cur_inst[j+1]	=	inst_i[1];
										cur_inst[j+2]	=	inst_i[2];
										cur_inst[j+3]	=	inst_i[3];
										cur_inst[j+4]	=	inst_i[4];
										cur_inst[j+5]	=	inst_i[5];	
										cur_inst[j+6]	=	inst_i[6];
										cur_inst[j+7]	=	inst_i[7];
										cur_inst[j+8]	=	inst_i[8];
										cur_inst[j+9]	=	inst_i[9];
										cur_inst[j+10]	=	inst_i[10];	
										cur_inst[j+11]	=	inst_i[11];
										cur_inst[j+12]	=	inst_i[12];
										cur_inst[j+13]	=	inst_i[13];
										cur_inst[j+14]	=	inst_i[14];
										cur_inst[j+15]	=	inst_i[15];	
										cur_inst[j+16]	=	inst_i[16];
										cur_inst[j+17]	=	inst_i[17];
										cur_inst[j+18]	=	inst_i[18];
										cur_inst[j+19]	=	inst_i[19];
										cur_inst[j+20]	=	inst_i[20];	
										cur_inst[j+21]	=	inst_i[21];
										end
							8'h17	:	begin
										cur_inst[j+0]	=	inst_i[0];	
										cur_inst[j+1]	=	inst_i[1];
										cur_inst[j+2]	=	inst_i[2];
										cur_inst[j+3]	=	inst_i[3];
										cur_inst[j+4]	=	inst_i[4];
										cur_inst[j+5]	=	inst_i[5];	
										cur_inst[j+6]	=	inst_i[6];
										cur_inst[j+7]	=	inst_i[7];
										cur_inst[j+8]	=	inst_i[8];
										cur_inst[j+9]	=	inst_i[9];
										cur_inst[j+10]	=	inst_i[10];	
										cur_inst[j+11]	=	inst_i[11];
										cur_inst[j+12]	=	inst_i[12];
										cur_inst[j+13]	=	inst_i[13];
										cur_inst[j+14]	=	inst_i[14];
										cur_inst[j+15]	=	inst_i[15];	
										cur_inst[j+16]	=	inst_i[16];
										cur_inst[j+17]	=	inst_i[17];
										cur_inst[j+18]	=	inst_i[18];
										cur_inst[j+19]	=	inst_i[19];
										cur_inst[j+20]	=	inst_i[20];	
										cur_inst[j+21]	=	inst_i[21];
										cur_inst[j+22]	=	inst_i[22];
										end
							8'h18	:	begin
										cur_inst[j+0]	=	inst_i[0];	
										cur_inst[j+1]	=	inst_i[1];
										cur_inst[j+2]	=	inst_i[2];
										cur_inst[j+3]	=	inst_i[3];
										cur_inst[j+4]	=	inst_i[4];
										cur_inst[j+5]	=	inst_i[5];	
										cur_inst[j+6]	=	inst_i[6];
										cur_inst[j+7]	=	inst_i[7];
										cur_inst[j+8]	=	inst_i[8];
										cur_inst[j+9]	=	inst_i[9];
										cur_inst[j+10]	=	inst_i[10];	
										cur_inst[j+11]	=	inst_i[11];
										cur_inst[j+12]	=	inst_i[12];
										cur_inst[j+13]	=	inst_i[13];
										cur_inst[j+14]	=	inst_i[14];
										cur_inst[j+15]	=	inst_i[15];	
										cur_inst[j+16]	=	inst_i[16];
										cur_inst[j+17]	=	inst_i[17];
										cur_inst[j+18]	=	inst_i[18];
										cur_inst[j+19]	=	inst_i[19];
										cur_inst[j+20]	=	inst_i[20];	
										cur_inst[j+21]	=	inst_i[21];
										cur_inst[j+22]	=	inst_i[22];
										cur_inst[j+23]	=	inst_i[23];
										end
							8'h19	:	begin
										cur_inst[j+0]	=	inst_i[0];	
										cur_inst[j+1]	=	inst_i[1];
										cur_inst[j+2]	=	inst_i[2];
										cur_inst[j+3]	=	inst_i[3];
										cur_inst[j+4]	=	inst_i[4];
										cur_inst[j+5]	=	inst_i[5];	
										cur_inst[j+6]	=	inst_i[6];
										cur_inst[j+7]	=	inst_i[7];
										cur_inst[j+8]	=	inst_i[8];
										cur_inst[j+9]	=	inst_i[9];
										cur_inst[j+10]	=	inst_i[10];	
										cur_inst[j+11]	=	inst_i[11];
										cur_inst[j+12]	=	inst_i[12];
										cur_inst[j+13]	=	inst_i[13];
										cur_inst[j+14]	=	inst_i[14];
										cur_inst[j+15]	=	inst_i[15];	
										cur_inst[j+16]	=	inst_i[16];
										cur_inst[j+17]	=	inst_i[17];
										cur_inst[j+18]	=	inst_i[18];
										cur_inst[j+19]	=	inst_i[19];
										cur_inst[j+20]	=	inst_i[20];	
										cur_inst[j+21]	=	inst_i[21];
										cur_inst[j+22]	=	inst_i[22];
										cur_inst[j+23]	=	inst_i[23];
										cur_inst[j+24]	=	inst_i[24];
										end
							8'h1a	:	begin
										cur_inst[j+0]	=	inst_i[0];	
										cur_inst[j+1]	=	inst_i[1];
										cur_inst[j+2]	=	inst_i[2];
										cur_inst[j+3]	=	inst_i[3];
										cur_inst[j+4]	=	inst_i[4];
										cur_inst[j+5]	=	inst_i[5];	
										cur_inst[j+6]	=	inst_i[6];
										cur_inst[j+7]	=	inst_i[7];
										cur_inst[j+8]	=	inst_i[8];
										cur_inst[j+9]	=	inst_i[9];
										cur_inst[j+10]	=	inst_i[10];	
										cur_inst[j+11]	=	inst_i[11];
										cur_inst[j+12]	=	inst_i[12];
										cur_inst[j+13]	=	inst_i[13];
										cur_inst[j+14]	=	inst_i[14];
										cur_inst[j+15]	=	inst_i[15];	
										cur_inst[j+16]	=	inst_i[16];
										cur_inst[j+17]	=	inst_i[17];
										cur_inst[j+18]	=	inst_i[18];
										cur_inst[j+19]	=	inst_i[19];
										cur_inst[j+20]	=	inst_i[20];	
										cur_inst[j+21]	=	inst_i[21];
										cur_inst[j+22]	=	inst_i[22];
										cur_inst[j+23]	=	inst_i[23];
										cur_inst[j+24]	=	inst_i[24];
										cur_inst[j+25]	=	inst_i[25];
										end
							8'h1b	:	begin
										cur_inst[j+0]	=	inst_i[0];	
										cur_inst[j+1]	=	inst_i[1];
										cur_inst[j+2]	=	inst_i[2];
										cur_inst[j+3]	=	inst_i[3];
										cur_inst[j+4]	=	inst_i[4];
										cur_inst[j+5]	=	inst_i[5];	
										cur_inst[j+6]	=	inst_i[6];
										cur_inst[j+7]	=	inst_i[7];
										cur_inst[j+8]	=	inst_i[8];
										cur_inst[j+9]	=	inst_i[9];
										cur_inst[j+10]	=	inst_i[10];	
										cur_inst[j+11]	=	inst_i[11];
										cur_inst[j+12]	=	inst_i[12];
										cur_inst[j+13]	=	inst_i[13];
										cur_inst[j+14]	=	inst_i[14];
										cur_inst[j+15]	=	inst_i[15];	
										cur_inst[j+16]	=	inst_i[16];
										cur_inst[j+17]	=	inst_i[17];
										cur_inst[j+18]	=	inst_i[18];
										cur_inst[j+19]	=	inst_i[19];
										cur_inst[j+20]	=	inst_i[20];	
										cur_inst[j+21]	=	inst_i[21];
										cur_inst[j+22]	=	inst_i[22];
										cur_inst[j+23]	=	inst_i[23];
										cur_inst[j+24]	=	inst_i[24];
										cur_inst[j+25]	=	inst_i[25];	
										cur_inst[j+26]	=	inst_i[26];
										end
							8'h1c	:	begin
										cur_inst[j+0]	=	inst_i[0];	
										cur_inst[j+1]	=	inst_i[1];
										cur_inst[j+2]	=	inst_i[2];
										cur_inst[j+3]	=	inst_i[3];
										cur_inst[j+4]	=	inst_i[4];
										cur_inst[j+5]	=	inst_i[5];	
										cur_inst[j+6]	=	inst_i[6];
										cur_inst[j+7]	=	inst_i[7];
										cur_inst[j+8]	=	inst_i[8];
										cur_inst[j+9]	=	inst_i[9];
										cur_inst[j+10]	=	inst_i[10];	
										cur_inst[j+11]	=	inst_i[11];
										cur_inst[j+12]	=	inst_i[12];
										cur_inst[j+13]	=	inst_i[13];
										cur_inst[j+14]	=	inst_i[14];
										cur_inst[j+15]	=	inst_i[15];	
										cur_inst[j+16]	=	inst_i[16];
										cur_inst[j+17]	=	inst_i[17];
										cur_inst[j+18]	=	inst_i[18];
										cur_inst[j+19]	=	inst_i[19];
										cur_inst[j+20]	=	inst_i[20];	
										cur_inst[j+21]	=	inst_i[21];
										cur_inst[j+22]	=	inst_i[22];
										cur_inst[j+23]	=	inst_i[23];
										cur_inst[j+24]	=	inst_i[24];
										cur_inst[j+25]	=	inst_i[25];	
										cur_inst[j+26]	=	inst_i[26];
										cur_inst[j+27]	=	inst_i[27];	
										end								
							8'h1d	:	begin
										cur_inst[j+0]	=	inst_i[0];	
										cur_inst[j+1]	=	inst_i[1];
										cur_inst[j+2]	=	inst_i[2];
										cur_inst[j+3]	=	inst_i[3];
										cur_inst[j+4]	=	inst_i[4];
										cur_inst[j+5]	=	inst_i[5];	
										cur_inst[j+6]	=	inst_i[6];
										cur_inst[j+7]	=	inst_i[7];
										cur_inst[j+8]	=	inst_i[8];
										cur_inst[j+9]	=	inst_i[9];
										cur_inst[j+10]	=	inst_i[10];	
										cur_inst[j+11]	=	inst_i[11];
										cur_inst[j+12]	=	inst_i[12];
										cur_inst[j+13]	=	inst_i[13];
										cur_inst[j+14]	=	inst_i[14];
										cur_inst[j+15]	=	inst_i[15];	
										cur_inst[j+16]	=	inst_i[16];
										cur_inst[j+17]	=	inst_i[17];
										cur_inst[j+18]	=	inst_i[18];
										cur_inst[j+19]	=	inst_i[19];
										cur_inst[j+20]	=	inst_i[20];	
										cur_inst[j+21]	=	inst_i[21];
										cur_inst[j+22]	=	inst_i[22];
										cur_inst[j+23]	=	inst_i[23];
										cur_inst[j+24]	=	inst_i[24];
										cur_inst[j+25]	=	inst_i[25];	
										cur_inst[j+26]	=	inst_i[26];
										cur_inst[j+27]	=	inst_i[27];
										cur_inst[j+28]	=	inst_i[28];	
										end										
							8'h1e	:	begin
										cur_inst[j+0]	=	inst_i[0];	
										cur_inst[j+1]	=	inst_i[1];
										cur_inst[j+2]	=	inst_i[2];
										cur_inst[j+3]	=	inst_i[3];
										cur_inst[j+4]	=	inst_i[4];
										cur_inst[j+5]	=	inst_i[5];	
										cur_inst[j+6]	=	inst_i[6];
										cur_inst[j+7]	=	inst_i[7];
										cur_inst[j+8]	=	inst_i[8];
										cur_inst[j+9]	=	inst_i[9];
										cur_inst[j+10]	=	inst_i[10];	
										cur_inst[j+11]	=	inst_i[11];
										cur_inst[j+12]	=	inst_i[12];
										cur_inst[j+13]	=	inst_i[13];
										cur_inst[j+14]	=	inst_i[14];
										cur_inst[j+15]	=	inst_i[15];	
										cur_inst[j+16]	=	inst_i[16];
										cur_inst[j+17]	=	inst_i[17];
										cur_inst[j+18]	=	inst_i[18];
										cur_inst[j+19]	=	inst_i[19];
										cur_inst[j+20]	=	inst_i[20];	
										cur_inst[j+21]	=	inst_i[21];
										cur_inst[j+22]	=	inst_i[22];
										cur_inst[j+23]	=	inst_i[23];
										cur_inst[j+24]	=	inst_i[24];
										cur_inst[j+25]	=	inst_i[25];	
										cur_inst[j+26]	=	inst_i[26];
										cur_inst[j+27]	=	inst_i[27];
										cur_inst[j+28]	=	inst_i[28];
										cur_inst[j+29]	=	inst_i[29];
										end											
							8'h1f	:	begin
										cur_inst[j+0]	=	inst_i[0];	
										cur_inst[j+1]	=	inst_i[1];
										cur_inst[j+2]	=	inst_i[2];
										cur_inst[j+3]	=	inst_i[3];
										cur_inst[j+4]	=	inst_i[4];
										cur_inst[j+5]	=	inst_i[5];	
										cur_inst[j+6]	=	inst_i[6];
										cur_inst[j+7]	=	inst_i[7];
										cur_inst[j+8]	=	inst_i[8];
										cur_inst[j+9]	=	inst_i[9];
										cur_inst[j+10]	=	inst_i[10];	
										cur_inst[j+11]	=	inst_i[11];
										cur_inst[j+12]	=	inst_i[12];
										cur_inst[j+13]	=	inst_i[13];
										cur_inst[j+14]	=	inst_i[14];
										cur_inst[j+15]	=	inst_i[15];	
										cur_inst[j+16]	=	inst_i[16];
										cur_inst[j+17]	=	inst_i[17];
										cur_inst[j+18]	=	inst_i[18];
										cur_inst[j+19]	=	inst_i[19];
										cur_inst[j+20]	=	inst_i[20];	
										cur_inst[j+21]	=	inst_i[21];
										cur_inst[j+22]	=	inst_i[22];
										cur_inst[j+23]	=	inst_i[23];
										cur_inst[j+24]	=	inst_i[24];
										cur_inst[j+25]	=	inst_i[25];	
										cur_inst[j+26]	=	inst_i[26];
										cur_inst[j+27]	=	inst_i[27];
										cur_inst[j+28]	=	inst_i[28];
										cur_inst[j+29]	=	inst_i[29];
										cur_inst[j+30]	=	inst_i[30];									
								end
								
							8'h20	:	begin
										cur_inst[j+0]	=	inst_i[0];	
										cur_inst[j+1]	=	inst_i[1];
										cur_inst[j+2]	=	inst_i[2];
										cur_inst[j+3]	=	inst_i[3];
										cur_inst[j+4]	=	inst_i[4];
										cur_inst[j+5]	=	inst_i[5];	
										cur_inst[j+6]	=	inst_i[6];
										cur_inst[j+7]	=	inst_i[7];
										cur_inst[j+8]	=	inst_i[8];
										cur_inst[j+9]	=	inst_i[9];
										cur_inst[j+10]	=	inst_i[10];	
										cur_inst[j+11]	=	inst_i[11];
										cur_inst[j+12]	=	inst_i[12];
										cur_inst[j+13]	=	inst_i[13];
										cur_inst[j+14]	=	inst_i[14];
										cur_inst[j+15]	=	inst_i[15];	
										cur_inst[j+16]	=	inst_i[16];
										cur_inst[j+17]	=	inst_i[17];
										cur_inst[j+18]	=	inst_i[18];
										cur_inst[j+19]	=	inst_i[19];
										cur_inst[j+20]	=	inst_i[20];	
										cur_inst[j+21]	=	inst_i[21];
										cur_inst[j+22]	=	inst_i[22];
										cur_inst[j+23]	=	inst_i[23];
										cur_inst[j+24]	=	inst_i[24];
										cur_inst[j+25]	=	inst_i[25];	
										cur_inst[j+26]	=	inst_i[26];
										cur_inst[j+27]	=	inst_i[27];
										cur_inst[j+28]	=	inst_i[28];
										cur_inst[j+29]	=	inst_i[29];
										cur_inst[j+30]	=	inst_i[30];	
										cur_inst[j+31]	=	inst_i[31];									
								end
						
								default:	begin
												end
						endcase
						
						//------------------------------------------
							
						//-----------------------------------------------
						//如果以后读指令出现问题，可考虑解注释 cur_pos
						//modi on 2015-10-11		
						//add on 2015-10-1
						cur_pos	=	cur_pos - temp;
						//-----------------------------------------------
						 
						//modi on 2015-12-19
						//tot_len_i 		=	`ZeroWord;
						tot_len_i 		=	temp;
						
						tot_len				=	`ZeroWord;
						
												
					
									
					end else if (tot_len == tot_len_i) begin
						cur_pos				= 	`InstLen - 1;					//383
						//--------------------------------------------------
						//modi on 2015-12-22
						//cur_inst			=	384'h000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
						cur_inst			=	96'h000000000000000000000000;
						//--------------------------------------------------
						tot_len_i 		=	`ZeroWord;
						tot_len				=	`ZeroWord;
						
						
						
						
					
					//add on 2015-10-11	
					end else begin
						//-----------------------------------------------
						//add on 2015-10-28
						wreg_o				=	`WriteDisable;
						aluop_o				=	`EXE_NOP_OP;
						alusel_o			=	`EXE_RES_NOP;
						reg1_read_o		=	1'b0;
						reg2_read_o		=	1'b0;																
						reg1_addr_o		= `NOPRegAddr;
						reg2_addr_o		=	`NOPRegAddr;
						imm						=	32'h0;											
						instvalid			=	`InstValid;					
						//-----------------------------------------------
						
						
						//modi on 2015-11-2
						//modi on 2015-10-28
						//stallreq 				= `Stop;					//如果指令实际长度大于当前得到的指令长度（表明指令未取完），暂停流水线					
						//stallreq_to_id	=	`Stop;
						
						
					end
					//----------------------------------------
					
					
				end
				
			end
	
	end
			
	
	
	
	always @(*) begin
		if(rst == `RstEnable) begin
			reg1_o	= `ZeroWord;
		end else if((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg1_addr_o)) begin
			reg1_o = ex_wdata_i;
		end else if((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg1_addr_o)) begin
			reg1_o = mem_wdata_i;
		end else if(reg1_read_o == 1'b1) begin
			reg1_o	= reg1_data_i;	  	
		end else if(reg1_read_o == 1'b0) begin
			reg1_o	= imm;
		end else begin
			reg1_o	= `ZeroWord;
		end
		
		//modi on 2015-10-24
		//if(`LITTLE_END == `True_v)	begin
		//	reg1_o = ((reg1_o & 32'h000000FF)<<24) | ((reg1_o & 32'h0000FF00)<<8) | ((reg1_o & 32'h00FF0000) >>8) | ((reg1_o & 32'hFF000000) >>24)  ;
		//end 
	end
	
	
	always @(*) begin
		if(rst == `RstEnable) begin
			reg2_o	= `ZeroWord;
		end else if((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1) && (ex_wd_i == reg2_addr_o)) begin
			reg2_o = ex_wdata_i;
		end else if((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1) && (mem_wd_i == reg2_addr_o)) begin
			reg2_o = mem_wdata_i;
		end else if(reg2_read_o == 1'b1) begin
			reg2_o	= reg2_data_i;
		end else if(reg2_read_o == 1'b0) begin
			reg2_o	= imm;
		end else begin
			reg2_o	= `ZeroWord;
		end
		
		//modi on 2015-10-24
		//if(`LITTLE_END == `True_v)	begin
		//	reg2_o = ((reg2_o & 32'h000000FF)<<24) | ((reg2_o & 32'h0000FF00)<<8) | ((reg2_o & 32'h00FF0000) >>8) | ((reg2_o & 32'hFF000000) >>24)  ;
		//end 
	end

endmodule