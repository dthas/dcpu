`include "defines.v"

module	mem(
	input		wire							rst,
	
	input	wire[`RegAddrBus]		wd_i,
	input	wire								wreg_i,
	input	wire[`RegBus]				wdata_i,
	
	//----------------------------------------
	//add on 2015-11-18
	input	wire[`AluOpBus]			m_mem_aluop_i,
	input	wire[`InstAddrBus]	m_mem_addr_i,
	input	wire[`InstAddrBus]	m_mem_data_i,
	
	input wire[`DataBus]			dm_data_i,
	output reg								dm_we,
	output reg[`DataAddrBus]	dm_addr,
	output reg[3:0]						dm_sel,	
	output reg[`DataBus]			dm_data_o,
	output reg								dm_ce,
	//----------------------------------------
	
	//--------------------------------------
	//add on 2015-11-21
	output	reg[`InstAddrBus]	ret_addr,
	output	reg								ret_fl,
	//--------------------------------------
	
	//----------------------------------------
	//add on 2015-11-24
	output reg								dm_we64,
	output reg[7:0]						dm_sel64,	
	input wire[`DataBus64]		dm_data_i64,
	output reg[`DataBus64]		dm_data_o64,	
	
	input wire[`RegBus64]			m_mem_idt_i,
	input wire[`RegBus64]			m_mem_gdt_i,
	input wire[`RegBus64]			m_mem_ldt_i,
	input wire[`RegBus64]			m_mem_tr_i,
	
	output reg[`RegBus64]			m_mem_idt_o,
	output reg[`RegBus64]			m_mem_gdt_o,
	output reg[`RegBus64]			m_mem_ldt_o,
	output reg[`RegBus64]			m_mem_tr_o,
	 
	input wire                m_mem_w_reg64_i, 
	output reg                m_mem_w_reg64_o,
	//----------------------------------------
	
	//----------------------------------------
	//add on 2015-11-27
	output reg								dm_flg64,
	input	wire[`InstAddrBus]	m_mem_addr_j_i,
	input	wire[`InstAddrBus]	m_mem_data_j_i,
	//----------------------------------------
	
	//--------------------------------------
	//add on 2015-12-2
	input		wire[`ByteWidth]			mem_exp_no_i,	
	input		wire[`InstAddrBus]		mem_exp_pc_i,
	input		wire[`InstAddrBus]		mem_exp_pc_to_i,
	output	reg[`InstAddrBus]			mem_exp_retaddr_o,
	output	reg										mem_exp_fl,
	output	reg[`InstAddrBus]			mem_exp_pc_to_o,
	//--------------------------------------
	
	output	reg[`RegAddrBus]	wd_o,
	output	reg								wreg_o,
	output	reg[`RegBus]			wdata_o
);

	reg[`RegBus]			temp_data;
	
	always	@ (*)	begin
		if(rst == `RstEnable) begin
			wd_o		= `NOPRegAddr;
			wreg_o	= `WriteDisable;
			wdata_o	= `ZeroWord;
			
			ret_addr		= `ZeroWord;
			ret_fl			=	`False_v;	
			m_mem_w_reg64_o	=	`WriteDisable;
			temp_data		= `ZeroWord;
			
			//add on 2015-12-2
			mem_exp_fl	= `False_v;
			mem_exp_pc_to_o		=	`ZeroWord;
		end else begin
			if(mem_exp_no_i == 8'hFF)	begin
					wd_o		= wd_i;
					wreg_o	= wreg_i;
					wdata_o	= wdata_i;
					m_mem_w_reg64_o	=	m_mem_w_reg64_i;
					
					case(m_mem_aluop_i)
						`EXE_PUSH_REG16_OP	: begin
								dm_we			= `WriteEnable;
								dm_sel		= 4'b1111;
								dm_data_o	=	m_mem_data_i; 
								dm_ce			= `ChipEnable;
								
								//modi on 2015-11-19
								//dm_addr		=	m_mem_addr_i;
								dm_addr		=	{m_mem_addr_i[31:2], 2'b00}; 
								
								//add on 2015-11-27
								dm_flg64	= `False_v;
						end
						
						`EXE_PUSH_REG32_OP	: begin
								dm_we			= `WriteEnable;
								dm_sel		= 4'b1111;						
								dm_data_o	=	m_mem_data_i; 
								dm_ce			= `ChipEnable;
								
								//modi on 2015-11-19
								//dm_addr		=	m_mem_addr_i;
								dm_addr		=	{m_mem_addr_i[31:2], 2'b00};
								
								//add on 2015-11-27         
								dm_flg64	= `False_v;
						end
						
						`EXE_POP_REG16_OP	: begin
								dm_we			= `WriteDisable;
								dm_sel		= 4'b1111;
								dm_ce			= `ChipEnable;
								
								//modi on 2015-11-19
								//dm_addr		=	m_mem_addr_i;
								dm_addr		=	{m_mem_addr_i[31:2], 2'b00};	
								
								//add on 2015-11-21
								wdata_o		= dm_data_i;	
								
								//add on 2015-11-27         
								dm_flg64	= `False_v;				
						end
						
						`EXE_POP_REG32_OP	: begin
								dm_we			= `WriteDisable;
								dm_sel		= 4'b1111;
								dm_ce			= `ChipEnable;
								
								//modi on 2015-11-19
								//dm_addr		=	m_mem_addr_i;
								dm_addr		=	{m_mem_addr_i[31:2], 2'b00};	
								
								//add on 2015-11-21
								wdata_o		= dm_data_i;
								
								//add on 2015-11-27         
								dm_flg64	= `False_v;					
						end
						
						`EXE_CALL_OP_32	: begin
								dm_we			= `WriteEnable;
								dm_sel		= 4'b1111;						
								dm_data_o	=	m_mem_data_j_i; 
								dm_ce			= `ChipEnable;
								
								//modi on 2015-11-19
								//dm_addr		=	m_mem_addr_j_i;
								dm_addr		=	{m_mem_addr_j_i[31:2], 2'b00};
								
								//add on 2015-11-27         
								dm_flg64	= `False_v;
						end
						
						`EXE_CALLREG_OP_16	: begin
								dm_we			= `WriteEnable;
								dm_sel		= 4'b1111;						
								dm_data_o	=	m_mem_data_j_i; 
								dm_ce			= `ChipEnable;
								
								//modi on 2015-11-19
								//dm_addr		=	m_mem_addr_j_i;
								dm_addr		=	{m_mem_addr_j_i[31:2], 2'b00};
								
								//add on 2015-11-27         
								dm_flg64	= `False_v;
						end
						
						`EXE_CALLREG_OP_32	: begin
								dm_we			= `WriteEnable;
								dm_sel		= 4'b1111;						
								dm_data_o	=	m_mem_data_j_i; 
								dm_ce			= `ChipEnable;
								
								//modi on 2015-11-19
								//dm_addr		=	m_mem_addr_j_i;
								dm_addr		=	{m_mem_addr_j_i[31:2], 2'b00};
								
								//add on 2015-11-27         
								dm_flg64	= `False_v;
						end
						
						`EXE_RET_OP_16	: begin
								dm_we			= `WriteDisable;
								dm_sel		= 4'b1111;
								dm_ce			= `ChipEnable;
								
								//modi on 2015-11-19
								//dm_addr		=	m_mem_addr_j_i;
								dm_addr		=	{m_mem_addr_j_i[31:2], 2'b00};	
								
								//add on 2015-11-21
								ret_addr		= dm_data_i;
								ret_fl			=	`True_v;		
								
								//add on 2015-11-27         
								dm_flg64	= `False_v;			
						end
						
						`EXE_RET_OP_32	: begin
								dm_we			= `WriteDisable;
								dm_sel		= 4'b1111;
								dm_ce			= `ChipEnable;
								
								//modi on 2015-11-19
								//dm_addr		=	m_mem_addr_j_i;
								dm_addr		=	{m_mem_addr_j_i[31:2], 2'b00};	
								
								//add on 2015-11-21
								ret_addr		= dm_data_i;
								ret_fl			=	`True_v;		
								
								//add on 2015-11-27         
								dm_flg64	= `False_v;			
						end
						
						`EXE_LEAVE_OP	: begin
								dm_we			= `WriteDisable;
								dm_sel		= 4'b1111;
								dm_ce			= `ChipEnable;						
								
								dm_addr		=	{m_mem_addr_i[31:2], 2'b00};						
							
								wdata_o		= dm_data_i;		
								
								//add on 2015-11-27         
								dm_flg64	= `False_v;			
						end
						
						`EXE_SIDT_OP	: begin
								dm_we64			= `WriteEnable;
								dm_sel64		= 8'b11111111;
								dm_ce			= `ChipEnable;
								
								//add on 2015-11-27         
								dm_flg64			= `True_v;	
								//加16是测试用的
								//temp_data			= m_mem_addr_i + 16;
								temp_data			= m_mem_addr_i;
								dm_addr				=	{temp_data[31:2], 2'b00};		
								dm_data_o64		= m_mem_idt_o;						
						end
						
						`EXE_LIDT_OP	: begin
								dm_we64			= `WriteDisable;
								dm_sel64		= 8'b11111111;
								dm_ce			= `ChipEnable;
								
								//add on 2015-11-27         
								dm_flg64			= `True_v;	
								temp_data		= m_mem_addr_i;
								dm_addr		=	{temp_data[31:2], 2'b00};	
								m_mem_idt_o		= dm_data_i64;
						end
						
						`EXE_SGDT_OP	: begin
								dm_we64			= `WriteEnable;
								dm_sel64		= 8'b11111111;
								dm_ce			= `ChipEnable;
								
								//add on 2015-11-27         
								dm_flg64			= `True_v;	
								//加16是测试用的
								//temp_data			= m_mem_addr_i + 16;
								temp_data			= m_mem_addr_i;
								dm_addr				=	{temp_data[31:2], 2'b00};		
								dm_data_o64		= m_mem_gdt_o;						
						end
						
						`EXE_LGDT_OP	: begin
								dm_we64			= `WriteDisable;
								dm_sel64		= 8'b11111111;
								dm_ce			= `ChipEnable;
								
								//add on 2015-11-27         
								dm_flg64			= `True_v;	
								temp_data		= m_mem_addr_i;
								dm_addr		=	{temp_data[31:2], 2'b00};	
								m_mem_gdt_o		= dm_data_i64;
						end
						
						
						`EXE_STR_OP	: begin
								dm_we64			= `WriteEnable;
								dm_sel64		= 8'b11111111;
								dm_ce			= `ChipEnable;
								
								//add on 2015-11-27         
								dm_flg64			= `True_v;	
								//加16是测试用的
								//temp_data			= m_mem_addr_i + 16;
								temp_data			= m_mem_addr_i;
								dm_addr				=	{temp_data[31:2], 2'b00};		
								dm_data_o64		= m_mem_tr_o;						
						end
						
						`EXE_LTR_OP	: begin
								dm_we64			= `WriteDisable;
								dm_sel64		= 8'b11111111;
								dm_ce			= `ChipEnable;
								
								//add on 2015-11-27         
								dm_flg64			= `True_v;							
								dm_addr		=	{m_mem_addr_i[31:2], 2'b00};	
								m_mem_tr_o		= dm_data_i64;
						end
						
						`EXE_SLDT_OP	: begin
								dm_we64			= `WriteEnable;
								dm_sel64		= 8'b11111111;
								dm_ce			= `ChipEnable;
								
								//add on 2015-11-27         
								dm_flg64			= `True_v;	
								//加16是测试用的
								//temp_data			= m_mem_addr_i + 16;
								temp_data			= m_mem_addr_i;
								dm_addr				=	{temp_data[31:2], 2'b00};		
								dm_data_o64		= m_mem_ldt_o;						
						end
						
						`EXE_LLDT_OP	: begin
								dm_we64			= `WriteDisable;
								dm_sel64		= 8'b11111111;
								dm_ce			= `ChipEnable;
								
								//add on 2015-11-27         
								dm_flg64			= `True_v;							
								dm_addr		=	{m_mem_addr_i[31:2], 2'b00};	
								m_mem_ldt_o		= dm_data_i64;
						end
		
						
						default:	begin
								ret_addr		= `ZeroWord;
								ret_fl			=	`False_v;	
						end
						
					endcase
			
			end else begin
					//中断、异常、系统调用的处理
					case (mem_exp_no_i)
						//1）异常的处理
						`EXP_0, `EXP_1,`EXP_2,`EXP_3,`EXP_4,`EXP_5, `EXP_6,`EXP_7,`EXP_8,`EXP_9,
						`EXP_10, `EXP_11,`EXP_12,`EXP_13,`EXP_14,`EXP_15, `EXP_16,`EXP_17,`EXP_18,`EXP_19	:	begin
								mem_exp_fl				= `True_v;
								mem_exp_retaddr_o	= mem_exp_pc_i;
								mem_exp_pc_to_o		= mem_exp_pc_to_i;
						end
						
						//2）中断的处理
						`EXP_32, `EXP_33,`EXP_34,`EXP_35,`EXP_36,`EXP_37, `EXP_38,`EXP_39, 
						`EXP_40, `EXP_41,`EXP_42,`EXP_43,`EXP_44,`EXP_45, `EXP_46,`EXP_47	:	begin
								mem_exp_fl				= `True_v;
								mem_exp_retaddr_o	= mem_exp_pc_i;
								mem_exp_pc_to_o		= mem_exp_pc_to_i;
						end
						
						//2）syscall的处理
						`EXP_80	:	begin
								mem_exp_fl				= `True_v;
								mem_exp_retaddr_o	= mem_exp_pc_i;
								mem_exp_pc_to_o		= mem_exp_pc_to_i;
						end
					
						default:	begin
								mem_exp_fl				= `False_v;
								mem_exp_pc_to_o		=	`ZeroWord;
						end
					
					endcase
			end
					
		end
	end

endmodule