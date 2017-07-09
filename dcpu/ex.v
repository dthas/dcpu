`include "defines.v"

module	ex(
	input		wire							rst,
	
	input		wire[`AluOpBus]		aluop_i,
	input		wire[`AluSelBus]	alusel_i,
	input		wire[`RegBus]			reg1_i,
	input		wire[`RegBus]			reg2_i,
	input		wire[`RegAddrBus]	wd_i,
	input		wire							wreg_i,
	
	output	reg[`RegAddrBus]	wd_o,
	output	reg								wreg_o,
	output	reg[`RegBus]			wdata_o,
	
	input wire[1:0]           cnt_i,
	output reg[1:0]           cnt_o,
	
	output reg								stallreq,
	
	//--------------------------------------
	//add on 2015-11-7
	input		wire[2:0]					div_state_i,
	input		wire[`RegBus]			div_res_i,
	output	reg								start_div_o,
	output	reg[`RegBus]			div_s_o,					//被除数
	output	reg[`RegBus]			div_b_o,					//除数
	//--------------------------------------
	
	//--------------------------------------
	//add on 2015-11-5
	output	reg[`RegBus]			reg_val,
	output	reg[`AluOpBus]		reg_aluop,
	output	reg[`AluSelBus]		reg_alusel,
	output	reg								reg_fl,
	output	reg[`RegAddrBus]	reg_dest_addr_o,
	//--------------------------------------
	
	//--------------------------------------
	//add on 2015-11-14
	output	reg[`InstAddrBus]	jmp_addr,
	output	reg								jmp_fl,
	//--------------------------------------
	
	//--------------------------------------
	//add on 2015-11-18
	//input	wire[`InstAddrBus]	mem_data_i,
	output	reg[`InstAddrBus]	mem_addr_o,
	output	reg[`InstAddrBus]	mem_data_o,
	output	wire[`AluOpBus]		mem_aluop_o,
	//--------------------------------------
	
	//--------------------------------------
	//add on 2015-11-21
		input		wire[`InstAddrBus]		mem_pc_i,
	//--------------------------------------
	
	//--------------------------------------
	//add on 2015-11-27
	output	reg[`InstAddrBus]	mem_addr_j_o,
	output	reg[`InstAddrBus]	mem_data_j_o,
	//--------------------------------------
	
	//----------------------------------------
	//add on 2015-11-24
	input wire[`RegBus64]			ex_idt_i,
	input wire[`RegBus64]			ex_gdt_i,
	input wire[`RegBus64]			ex_ldt_i,
	input wire[`RegBus64]			ex_tr_i,
	
	output reg[`RegBus64]		ex_idt_o,
	output reg[`RegBus64]		ex_gdt_o,
	output reg[`RegBus64]		ex_ldt_o,
	output reg[`RegBus64]		ex_tr_o,
	
	 
	output reg                ex_w_reg64_o,
	
	input wire[`RegBus64]			mem_idt_i,
	input wire[`RegBus64]			mem_gdt_i,
	input wire[`RegBus64]			mem_ldt_i,
	input wire[`RegBus64]			mem_tr_i, 
	input wire                mem_w_reg64_i,
	
	input wire[`RegBus64]			wb_idt_i,
	input wire[`RegBus64]			wb_gdt_i,
	input wire[`RegBus64]			wb_ldt_i,
	input wire[`RegBus64]			wb_tr_i,
	input wire                wb_w_reg64_i,
	//----------------------------------------
	
	//--------------------------------------
	//add on 2015-12-2
	output	reg[`ByteWidth]		exp_no,
	output	reg[`InstAddrBus]	exp_retpc,
	//--------------------------------------
	
	//--------------------------------------
	//add on 2015-12-4
	input wire               	timer_int_o,
	input	wire[`WordWidth]		int_status_i
	//--------------------------------------
	
		
	
	
);

	reg[`RegBus] logicout;
	reg[`RegBus] moveres;
	reg[`RegBus] shiftres;
	reg[`RegBus] expres;
	reg[`RegBus] arithres;
	reg[`RegBus64] arithres64;
	reg[`RegBus] reg_eflag;
	reg[`RegBus] jmpres;
	reg[`RegBus] sysres;
	reg[`RegBus] ss;
	reg[`RegBus] ds;	
	
	reg					zf;
	reg					of;
	reg					sf;
	reg					cf;
	reg					pf;
	reg					iff;
	reg[`RegBus] ebp;
	reg[`RegBus] esp;
	
	reg[`RegBus64] idt;
	reg[`RegBus64] gdt;
	reg[`RegBus64] ldt;
	reg[`RegBus64] tr;
	
	reg[`AluOpBus]		div_aluop_t;

	
	//--------------------------------------------------
	//modi on 2015-12-22
	//reg										cf_h;
	//reg										cf_l;
	//reg[`RegBus] 					k;
	//reg[`RegBus] 					i;
	//reg[`RegBus] 					j;	
	//reg[`RegBus] 					temp;
	
	reg[`InstBus8] 					i;
	reg[`InstBus8] 					j;
	reg[`InstBus8] 					temp;
	//--------------------------------------------------
	
	assign	mem_aluop_o	= aluop_i;
	
	always	@ ( * )	begin
		if(rst == `RstEnable) begin
			//jmp init
			jmpres			= `ZeroWord;			
			jmp_addr		= `ZeroWord;
			jmp_fl			=	`False_v;	
			mem_addr_j_o=	`ZeroWord;
			mem_data_j_o=	`ZeroWord;						
			zf				=	0;
			of				= 0;
			sf				= 0;
			cf				= 0;	
			pf				= 0;	
			
			//arith init
			arithres							= `ZeroWord;							
			reg_val								= `ZeroWord;
			reg_fl								= `False_v;	
			reg_aluop							=	`EXE_NOP_OP;
			reg_alusel						=	`EXE_RES_NOP;
			reg_dest_addr_o				=	`NOPRegAddr;			
			start_div_o						= `False_v;
			arithres64						= `ZeroDWord;
			temp									=	`ZeroWord;			
			div_aluop_t						=	`EXE_NOP_OP;			
			cnt_o									= 0;
			
			//logi init
			logicout	= `ZeroWord;	
			
			//mov init
			moveres		= `ZeroWord;
			mem_data_o=	`ZeroWord;
			mem_addr_o=	`ZeroWord;
			ss				= `ZeroWord;		
			
			//shift init
			shiftres							= `ZeroWord;
			i											= `ZeroWord;
			j											= `ZeroWord;
			//k											= `ZeroWord;
			temp									= `ZeroWord;						
			reg_val							= `ZeroWord;
			reg_aluop					= `EXE_NOP_OP;			
			reg_fl							= `False_v;	
			
			//sys init
			sysres	= `ZeroWord;
			ebp			= `ZeroWord;
			esp			= `ZeroWord;
			ds			= 16'h0000;	
			
			//exception init
			exp_no	= 8'hFF;
			
			//eflag init
			expres		= `ZeroWord;
			reg_eflag		= `ZeroWord;	
			
			//64bit reg init			
			ex_w_reg64_o	= `WriteDisable;
			idt						= `ZeroDWord;
			gdt						= `ZeroDWord;
			ldt						= `ZeroDWord;
			tr						= `ZeroDWord;
						
		end else begin
			case (aluop_i)					
					//====================================================================================
					//============										 转移指令处理 										==================
					//====================================================================================
					`EXE_JMP_OP_8: begin
						//-------------------------------------------------------------------------------------
						//modi on 2015-11-18
						//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
						//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
						//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
						//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
						//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
		 				//jmp_addr				= reg1_i + 2;
		 				jmp_addr				= reg1_i + 4;			//4为该指令的长度（虽然实际为2字节，但inst_rom.data读入就是4字节
		 				//-------------------------------------------------------------------------------------
						jmp_fl					= `True_v;	
						jmpres		= `ZeroWord;				
					end
					
		 			`EXE_JMP_OP_16: begin
		 				//-------------------------------------------------------------------------------------
						//modi on 2015-11-18
						//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
						//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
						//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
						//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
						//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
		 				//jmp_addr				= reg1_i + 3;
		 				jmp_addr				= reg1_i + 4;			//4为该指令的长度（虽然实际为3字节，但inst_rom.data读入就是4字节
		 				//-------------------------------------------------------------------------------------
						jmp_fl					= `True_v;
						jmpres		= `ZeroWord;						
					end	
					
					`EXE_JMP_OP_32: begin
		 				//-------------------------------------------------------------------------------------
						//modi on 2015-11-18
						//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
						//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
						//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
						//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
						//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
		 				//jmp_addr				= reg1_i + 5;
		 				jmp_addr				= reg1_i + 8;			//4为该指令的长度（虽然实际为5字节，但inst_rom.data读入就是8字节
		 				//-------------------------------------------------------------------------------------
						jmp_fl					= `True_v;
						jmpres		= `ZeroWord;					
					end
					
					//E0
					`EXE_LOOPNE_OP: begin	
						jmpres		= reg1_i - 1;
						
						if((jmpres != 0) && (reg_eflag[`ZF] == 0)) 	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 2;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为2字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end								
					end
					
					//E1
					`EXE_LOOPE_OP: begin	
						jmpres		= reg1_i - 1;
						if((jmpres != 0) && (reg_eflag[`ZF] == 1)) 	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 2;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为2字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end										
					end
					
					//E2
					`EXE_LOOP_OP: begin	
						jmpres		= reg1_i - 1;
						if(jmpres != 0)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 2;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为2字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end										
					end
					
					//E3
					`EXE_JCXZ_OP_8: begin	
						if(reg1_i == 0)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 2;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为2字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;											
					end
					
					`EXE_CALL_OP_32: begin		 				
		 				//jmp_addr				= reg1_i + 5;
		 				jmp_addr				= reg1_i + 8;			//4为该指令的长度（虽然实际为5字节，但inst_rom.data读入就是8字节		 				
						jmp_fl		= `True_v;
						
						//执行push操作，将call指令的下一条指令压栈
						mem_addr_j_o	= ss + reg2_i ;		// target_addr 	= mem_addr_o = SS:offset	, reg2_i = esp
						//mem_data_j_o	= mem_pc_i + 5;	// 将call的下一条指令的地址压栈;
						mem_data_j_o	= mem_pc_i -4 + 8;		// 将call的下一条指令的地址压栈;
						jmpres			= reg2_i + 4;			// 更新 esp 值				
					end
					
					`EXE_CALLREG_OP_16: begin		 				
		 				//jmp_addr				= reg1_i + 2;
		 				jmp_addr				= reg1_i + 4;			//4为该指令的长度（虽然实际为2字节，但inst_rom.data读入就是8字节		 				
						jmp_fl		= `True_v;
						
						//执行push操作，将call指令的下一条指令压栈
						mem_addr_j_o	= ss + reg2_i ;		// target_addr 	= mem_addr_o = SS:offset	, reg2_i = esp
						//mem_data_j_o	= mem_pc_i + 2;	// 将call的下一条指令的地址压栈;
						mem_data_j_o	= mem_pc_i -4 + 4;		// 将call的下一条指令的地址压栈;
						jmpres			= reg2_i + 4;			// 更新 esp 值				
					end		
					
					`EXE_CALLREG_OP_32: begin		 				
		 				//jmp_addr				= reg1_i + 3;
		 				jmp_addr				= reg1_i + 4;			//4为该指令的长度（虽然实际为3字节，但inst_rom.data读入就是8字节		 				
						jmp_fl		= `True_v;
						
						//执行push操作，将call指令的下一条指令压栈
						mem_addr_j_o	= ss + reg2_i ;		// target_addr 	= mem_addr_o = SS:offset	, reg2_i = esp
						//mem_data_j_o	= mem_pc_i + 3;	// 将call的下一条指令的地址压栈;
						mem_data_j_o	= mem_pc_i -4 + 4;		// 将call的下一条指令的地址压栈;
						jmpres			= reg2_i + 4;			// 更新 esp 值				
					end		
					
					`EXE_RET_OP_16:	begin
						mem_addr_j_o			= ss + reg2_i -4 ;		// target_addr 	= mem_addr_o = SS:offset	, reg2_i = esp
												
						// 更新 esp 值
						//jmpres					= reg2_i - 2;			//目前esp全部按4字节算							
						jmpres						= reg2_i - 4;									
					end
					
					`EXE_RET_OP_32:	begin
						mem_addr_j_o			= ss + reg2_i -4 ;		// target_addr 	= mem_addr_o = SS:offset	, reg2_i = esp
												
						// 更新 esp 值
						//jmpres				= reg2_i - 4;			//目前esp全部按4字节算							
						jmpres					= reg2_i - 4;						
					end				
					
					//70
					`EXE_JO_OP_8: begin
						of							= reg1_i >> `OF;
												
						if(of == 1)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 2;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为2字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;											
					end
					
					//71
					`EXE_JNO_OP_8: begin
						of							= reg1_i >> `OF;
												
						if(of == 0)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 2;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为2字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end
						jmpres		= `ZeroWord;												
					end
					
					
					//72
					`EXE_JB_OP_8,	`EXE_JC_OP_8,	`EXE_JNAE_OP_8: begin
						cf							= reg1_i >> `CF;
												
						if(cf == 1)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 2;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为2字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;											
					end
					
					//73
					`EXE_JAE_OP_8,	`EXE_JNB_OP_8,	`EXE_JNC_OP_8: begin
						cf							= reg1_i >> `CF;
												
						if(cf == 0)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 2;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为2字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end		
						jmpres		= `ZeroWord;										
					end	
					
					//74
					`EXE_JE_OP_8,	`EXE_JZ_OP_8: begin
						zf							= reg1_i >> `ZF;
												
						if(cf == 0)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 2;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为2字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end			
						jmpres		= `ZeroWord;									
					end	
					
					//75
					`EXE_JNE_OP_8,	`EXE_JNZ_OP_8: begin
						zf							= reg1_i >> `ZF;
												
						if(zf == 0)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 2;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为2字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end
						jmpres		= `ZeroWord;												
					end					
					
					//76
					`EXE_JBE_OP_8,	`EXE_JNA_OP_8: begin
						cf							= reg1_i >> `CF;
						zf							= reg1_i >> `ZF;
						
						if((cf == 1) && (zf == 1))	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 2;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为2字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end
						jmpres		= `ZeroWord;												
					end
					
					//77
					`EXE_JA_OP_8, `EXE_JNBE_OP_8: begin
						cf							= reg1_i >> `CF;
						zf							= reg1_i >> `ZF;
						
						if((cf == 0) && (zf == 0))	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 2;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为2字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;											
					end
					
					//78
					`EXE_JS_OP_8: begin
						sf							= reg1_i >> `PF;
												
						if(sf == 1)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 2;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为2字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end		
						jmpres		= `ZeroWord;										
					end	
					
					//79
					`EXE_JNS_OP_8: begin
						sf							= reg1_i >> `PF;
												
						if(sf == 0)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 2;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为2字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;											
					end	
					
					//7A
					`EXE_JP_OP_8,	`EXE_JPE_OP_8: begin
						pf							= reg1_i >> `PF;
												
						if(pf == 1)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 2;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为2字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end		
						jmpres		= `ZeroWord;										
					end	
					
					//7B
					`EXE_JNP_OP_8,	`EXE_JPO_OP_8: begin
						pf							= reg1_i >> `PF;
												
						if(pf == 0)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 2;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为2字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;											
					end	
					
					//7C
					`EXE_JL_OP_8, `EXE_JNGE_OP_8: begin
						of							= reg1_i >> `OF;						
						sf							= reg1_i >> `SF;
						
						if(sf != of)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 2;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为2字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;											
					end
					
					//7D
					`EXE_JGE_OP_8, `EXE_JNL_OP_8: begin
						of							= reg1_i >> `OF;						
						sf							= reg1_i >> `SF;
						
						if(sf == of)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 2;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为2字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;											
					end
					
					//7E
					`EXE_JLE_OP_8,	`EXE_JNG_OP_8: begin
						of							= reg1_i >> `OF;
						zf							= reg1_i >> `ZF;
						sf							= reg1_i >> `SF;
						
						if((sf != of) && (zf == 1))	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 2;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为2字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;											
					end
					
					//7F
					`EXE_JG_OP_8,	`EXE_JNLE_OP_8: begin
						of							= reg1_i >> `OF;
						zf							= reg1_i >> `ZF;
						sf							= reg1_i >> `SF;
						
						if((sf == of) && (zf == 0))	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 2;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为2字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;											
					end
					
					//80
					`EXE_JO_OP_16: begin
						of							= reg1_i >> `OF;
												
						if(of == 1)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 3;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为3字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;											
					end
					
					//81
					`EXE_JNO_OP_16: begin
						of							= reg1_i >> `OF;
												
						if(of == 0)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 3;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为3字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;											
					end
					
					
					//82
					`EXE_JB_OP_16,	`EXE_JC_OP_16,	`EXE_JNAE_OP_16: begin
						cf							= reg1_i >> `CF;
												
						if(cf == 1)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 3;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为3字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;											
					end
					
					//83
					`EXE_JAE_OP_16,	`EXE_JNB_OP_16,	`EXE_JNC_OP_16: begin
						cf							= reg1_i >> `CF;
												
						if(cf == 0)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 3;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为3字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;											
					end	
					
					//84
					`EXE_JE_OP_16,	`EXE_JZ_OP_16: begin
						zf							= reg1_i >> `ZF;
												
						if(cf == 0)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 3;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为3字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;											
					end	
					
					//85
					`EXE_JNE_OP_16,	`EXE_JNZ_OP_16: begin
						zf							= reg1_i >> `ZF;
												
						if(zf == 0)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 3;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为3字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;											
					end					
					
					//86
					`EXE_JBE_OP_16,	`EXE_JNA_OP_16: begin
						cf							= reg1_i >> `CF;
						zf							= reg1_i >> `ZF;
						
						if((cf == 1) && (zf == 1))	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 3;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为3字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;											
					end
					
					//87
					`EXE_JA_OP_16,	`EXE_JNBE_OP_16: begin
						cf							= reg1_i >> `CF;
						zf							= reg1_i >> `ZF;
						
						if((cf == 0) && (zf == 0))	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 3;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为3字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;											
					end
					
					//88
					`EXE_JS_OP_16: begin
						sf							= reg1_i >> `PF;
												
						if(sf == 1)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 3;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为3字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;											
					end	
					
					//89
					`EXE_JNS_OP_16: begin
						sf							= reg1_i >> `PF;
												
						if(sf == 0)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 3;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为3字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end		
						jmpres		= `ZeroWord;										
					end	
					
					//8A
					`EXE_JP_OP_16,	`EXE_JPE_OP_16: begin
						pf							= reg1_i >> `PF;
												
						if(pf == 1)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 3;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为3字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;											
					end	
					
					//8B
					`EXE_JNP_OP_16,	`EXE_JPO_OP_16: begin
						pf							= reg1_i >> `PF;
												
						if(pf == 0)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 3;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为3字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;											
					end	
					
					//8C
					`EXE_JL_OP_16,	`EXE_JNGE_OP_16: begin
						of							= reg1_i >> `OF;						
						sf							= reg1_i >> `SF;
						
						if(sf != of)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 3;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为3字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end			
						jmpres		= `ZeroWord;									
					end
					
					//8D
					`EXE_JGE_OP_16,	`EXE_JNL_OP_16: begin
						of							= reg1_i >> `OF;						
						sf							= reg1_i >> `SF;
						
						if(sf == of)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 3;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为3字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end		
						jmpres		= `ZeroWord;										
					end
					
					//8E
					`EXE_JLE_OP_16,	`EXE_JNG_OP_16: begin
						of							= reg1_i >> `OF;
						zf							= reg1_i >> `ZF;
						sf							= reg1_i >> `SF;
						
						if((sf != of) && (zf == 1))	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 3;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为3字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;											
					end
					
					//8F
					`EXE_JG_OP_16,	`EXE_JNLE_OP_16: begin
						of							= reg1_i >> `OF;
						zf							= reg1_i >> `ZF;
						sf							= reg1_i >> `SF;
						
						if((sf == of) && (zf == 0))	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 3;
			 				jmp_addr				= reg2_i + 4;			//4为该指令的长度（虽然实际为3字节，但inst_rom.data读入就是4字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;											
					end
					
					//80
					 `EXE_JO_OP_32: begin
						of							= reg1_i >> `OF;
												
						if(of == 1)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 5;
			 				jmp_addr				= reg2_i + 8;			//4为该指令的长度（虽然实际为5字节，但inst_rom.data读入就是8字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;											
					end
					
					//81
					`EXE_JNO_OP_32: begin
						of							= reg1_i >> `OF;
												
						if(of == 0)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 5;
			 				jmp_addr				= reg2_i + 8;			//4为该指令的长度（虽然实际为5字节，但inst_rom.data读入就是8字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;											
					end
					
					
					//82
					`EXE_JB_OP_32,	`EXE_JC_OP_32,	`EXE_JNAE_OP_32: begin
						cf							= reg1_i >> `CF;
												
						if(cf == 1)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 5;
			 				jmp_addr				= reg2_i + 8;			//4为该指令的长度（虽然实际为5字节，但inst_rom.data读入就是8字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;											
					end
					
					//83
					`EXE_JAE_OP_32,	`EXE_JNB_OP_32,	`EXE_JNC_OP_32: begin
						cf							= reg1_i >> `CF;
												
						if(cf == 0)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 5;
			 				jmp_addr				= reg2_i + 8;			//4为该指令的长度（虽然实际为5字节，但inst_rom.data读入就是8字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;											
					end	
					
					//84
					`EXE_JE_OP_32,	`EXE_JZ_OP_32: begin
						zf							= reg1_i >> `ZF;
												
						if(cf == 0)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 5;
			 				jmp_addr				= reg2_i + 8;			//4为该指令的长度（虽然实际为5字节，但inst_rom.data读入就是8字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;											
					end	
					
					//85
					`EXE_JNE_OP_32,	`EXE_JNZ_OP_32: begin
						zf							= reg1_i >> `ZF;
												
						if(zf == 0)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 5;
			 				jmp_addr				= reg2_i + 8;			//4为该指令的长度（虽然实际为5字节，但inst_rom.data读入就是8字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;											
					end					
					
					//86
					`EXE_JBE_OP_32,	`EXE_JNA_OP_32: begin
						cf							= reg1_i >> `CF;
						zf							= reg1_i >> `ZF;
						
						if((cf == 1) && (zf == 1))	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 5;
			 				jmp_addr				= reg2_i + 8;			//4为该指令的长度（虽然实际为5字节，但inst_rom.data读入就是8字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;											
					end
					
					//87
					`EXE_JA_OP_32,	`EXE_JNBE_OP_32: begin
						cf							= reg1_i >> `CF;
						zf							= reg1_i >> `ZF;
						
						if((cf == 0) && (zf == 0))	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 5;
			 				jmp_addr				= reg2_i + 8;			//4为该指令的长度（虽然实际为5字节，但inst_rom.data读入就是8字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;											
					end
					
					//88
					`EXE_JS_OP_32: begin
						sf							= reg1_i >> `PF;
												
						if(sf == 1)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 5;
			 				jmp_addr				= reg2_i + 8;			//4为该指令的长度（虽然实际为5字节，但inst_rom.data读入就是8字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;											
					end	
					
					//89
					`EXE_JNS_OP_32: begin
						sf							= reg1_i >> `PF;
												
						if(sf == 0)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 5;
			 				jmp_addr				= reg2_i + 8;			//4为该指令的长度（虽然实际为5字节，但inst_rom.data读入就是8字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end		
						jmpres		= `ZeroWord;										
					end	
					
					//8A
					`EXE_JP_OP_32,	`EXE_JPE_OP_32: begin
						pf							= reg1_i >> `PF;
												
						if(pf == 1)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 5;
			 				jmp_addr				= reg2_i + 8;			//4为该指令的长度（虽然实际为5字节，但inst_rom.data读入就是8字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;											
					end	
					
					//8B
					`EXE_JNP_OP_32,	`EXE_JPO_OP_32: begin
						pf							= reg1_i >> `PF;
												
						if(pf == 0)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 5;
			 				jmp_addr				= reg2_i + 8;			//4为该指令的长度（虽然实际为5字节，但inst_rom.data读入就是8字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;											
					end	
					
					//8C
					`EXE_JL_OP_32,	`EXE_JNGE_OP_32: begin
						of							= reg1_i >> `OF;						
						sf							= reg1_i >> `SF;
						
						if(sf != of)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 5;
			 				jmp_addr				= reg2_i + 8;			//4为该指令的长度（虽然实际为5字节，但inst_rom.data读入就是8字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end			
						jmpres		= `ZeroWord;									
					end
					
					//8D
					`EXE_JGE_OP_32,	`EXE_JNL_OP_32: begin
						of							= reg1_i >> `OF;						
						sf							= reg1_i >> `SF;
						
						if(sf == of)	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 5;
			 				jmp_addr				= reg2_i + 8;			//4为该指令的长度（虽然实际为5字节，但inst_rom.data读入就是8字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end		
						jmpres		= `ZeroWord;										
					end
					
					//8E
					`EXE_JLE_OP_32,	`EXE_JNG_OP_32: begin
						of							= reg1_i >> `OF;
						zf							= reg1_i >> `ZF;
						sf							= reg1_i >> `SF;
						
						if((sf != of) && (zf == 1))	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 5;
			 				jmp_addr				= reg2_i + 8;			//4为该指令的长度（虽然实际为5字节，但inst_rom.data读入就是8字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;											
					end
					
					//8F
					`EXE_JG_OP_32,	`EXE_JNLE_OP_32: begin
						of							= reg1_i >> `OF;
						zf							= reg1_i >> `ZF;
						sf							= reg1_i >> `SF;
						
						if((sf == of) && (zf == 0))	begin
							//-------------------------------------------------------------------------------------
							//modi on 2015-11-18
							//因为 jmp 是相对转移，即 JMP START 指令的实际意义是 目标地址 = pc + len(JMP START) + START
							//也就是要跳转的地址为 (pc + JMP指令的长度 + JMP指令所带的位移）
							//即 EB0003（EB为JMP的代码，0x0003为相对位移，JMP指令的长度为3字节），则目标地址 = pc + 3 + 0x0003
							//因为所有指令在inst_rom.data中读入，每条指令的长度都是4字节的倍数，
							//所以JMP指令的长度也变为4的倍数，这个以后需要改（因为实际不是这样的，intel指令的长度是可变的）
			 				//jmp_addr				= reg2_i + 5;
			 				jmp_addr				= reg2_i + 8;			//4为该指令的长度（虽然实际为5字节，但inst_rom.data读入就是8字节
			 				//-------------------------------------------------------------------------------------
							jmp_fl					= `True_v;
						end	
						jmpres		= `ZeroWord;
					end	
						
					//====================================================================================
					//============										 算术运算处理 										==================
					//====================================================================================
					`EXE_ADD_OP: begin
		 				arithres64= reg1_i + reg2_i;
						arithres		= arithres64;
						
						if(arithres64[32] == 1'b1)	begin
								reg_eflag[`CF]	=	1'b1;								
								reg_val					= reg_eflag;
								reg_fl					= `True_v;									
								reg_aluop				= `EXE_CF_SET;
								reg_alusel			= `EXE_RES_EXP;
								reg_dest_addr_o	= `EFLAGS;
						end	
						
					end
					
					`EXE_SUB_OP: begin
						arithres64	= reg1_i - reg2_i;
						arithres	= arithres64;
						
						if(arithres64[32] == 1'b1)	begin
									reg_eflag[`CF]	=	1'b1;									
									reg_val					= reg_eflag;
									reg_fl					= `True_v;									
									reg_aluop				= `EXE_CF_SET;
									reg_alusel			= `EXE_RES_EXP;
									reg_dest_addr_o	= `EFLAGS;
							end
					end
					
						
					`EXE_ADC_OP: begin
						// dest = dest + src + CF
							arithres64= reg1_i + reg2_i + reg_eflag[`CF];
							arithres	= arithres64;	
							
							if(arithres64[32] == 1'b1)	begin
									reg_eflag[`CF]	=	1'b1;									
									reg_val					= reg_eflag;
									reg_fl					= `True_v;									
									reg_aluop				= `EXE_CF_SET;
									reg_alusel			= `EXE_RES_EXP;
									reg_dest_addr_o	= `EFLAGS;
							end
							
							//--------------------------------------------
							//add on 2015-12-4
							//只是用于测试
							//of				= 1;
							//--------------------------------------------
							
					end				
					
					`EXE_SBB_OP: begin
						arithres64	= reg1_i - (reg2_i + reg_eflag[`CF]) ;
						arithres	= arithres64;	
							
							if(arithres64[32] == 1'b1)	begin
									reg_eflag[`CF]	=	1'b1;									
									reg_val					= reg_eflag;
									reg_fl					= `True_v;									
									reg_aluop				= `EXE_CF_SET;
									reg_alusel			= `EXE_RES_EXP;
									reg_dest_addr_o	= `EFLAGS;
							end
							
					end
					
					`EXE_INC_OP: begin
						arithres64= reg1_i + reg2_i;
						arithres	= arithres64;
						
						if(arithres64[32] == 1'b1)	begin
								reg_eflag[`CF]	=	1'b1;								
								reg_val					= reg_eflag;
								reg_fl					= `True_v;									
								reg_aluop				= `EXE_CF_SET;
								reg_alusel			= `EXE_RES_EXP;
								reg_dest_addr_o	= `EFLAGS;
						end
					end
					
					`EXE_DEC_OP: begin
						arithres64	= reg1_i - reg2_i;
						
						arithres	= arithres64;
						
						if(arithres64[32] == 1'b1)	begin
								reg_eflag[`CF]	=	1'b1;								
								reg_val					= reg_eflag;
								reg_fl					= `True_v;									
								reg_aluop				= `EXE_CF_SET;
								reg_alusel			= `EXE_RES_EXP;
								reg_dest_addr_o	= `EFLAGS;
						end
					end
					
					`EXE_MUL_OP_8: begin
		 				arithres		= reg1_i * reg2_i;
					end
					
					`EXE_MUL_OP_16: begin
		 				arithres		= reg1_i * reg2_i;
						
						reg_val					= (arithres>>16);
						reg_fl					= `True_v;									
						reg_aluop				= `EXE_MUL_SET;
						reg_alusel			= `EXE_RES_EXP;
						reg_dest_addr_o	= `DX;						
									
						arithres						= arithres & (16'hFFFF);			//取低16位 => AX
					end
					
					`EXE_MUL_OP_32: begin
		 				arithres64= reg1_i * reg2_i;
						arithres		= arithres64;
						
						reg_val					= (arithres64>>32);
						reg_fl					= `True_v;									
						reg_aluop				= `EXE_MUL_SET;
						reg_alusel			= `EXE_RES_EXP;
						reg_dest_addr_o	= `EDX;
						
						
					end
					
					`EXE_DIV_OP_8: begin
		 										
						div_s_o					= reg1_i;
						div_b_o					= reg2_i;		
						start_div_o			= `True_v;	
						stallreq				= `Stop;
						
						div_aluop_t			= `EXE_DIV_OP_8;						
									
					end
					
					`EXE_DIV_OP_16: begin
		 										
						div_s_o					= reg1_i;
						div_b_o					= reg2_i;		
						start_div_o			= `True_v;	
						stallreq				= `Stop;
						
						div_aluop_t			= `EXE_DIV_OP_16;						
											
					end
					
					`EXE_DIV_OP_32: begin
		 										
						div_s_o					= reg1_i;
						div_b_o					= reg2_i;		
						start_div_o			= `True_v;	
						stallreq				= `Stop;
						
						div_aluop_t			= `EXE_DIV_OP_32;						
											
					end
				  
				  
				  `EXE_CMP_OP: begin
						arithres64	= reg1_i - reg2_i;						
						
						if((arithres64>>32) > 0)	begin							// src < dest
									reg_eflag[`CF]	=	1'b1;
									reg_eflag[`ZF]	=	1'b0;
						end	else if(arithres64[32] == 0) begin			// src == dest
									reg_eflag[`ZF]	=	1'b1;
						end else begin															// src > dest
									reg_eflag[`ZF]	=	1'b0;
									reg_eflag[`CF]	=	1'b0;	
						end 
						
						arithres	= reg_eflag;
									
					end	
					
					//====================================================================================
					//============										 逻辑运算处理 										==================
					//====================================================================================												
					`EXE_AND_OP: begin
						logicout	= reg1_i & reg2_i;
					end
					
					`EXE_OR_OP: begin
						logicout	= reg1_i | reg2_i;
					end
					
					`EXE_NOT_OP: begin
						logicout	= ~reg1_i;
					end
					
					//====================================================================================
					//============										 mov运算处理	 										==================
					//====================================================================================
					`EXE_MOV_IMM_OP: begin
						moveres	= reg2_i;
					end
					
					`EXE_MOV_REG_OP:	begin
						moveres	= reg2_i;
					end
					
					`EXE_PUSH_REG16_OP:	begin
						mem_addr_o	= ss + reg2_i ;		// target_addr 	= mem_addr_o = SS:offset	, reg2_i = esp
						mem_data_o	= reg1_i;					// target_data	= reg1_i;
						
						//moid on 2015-11-19
						//目前esp全部按4字节算
						//moveres			= reg2_i + 2;			// 更新 esp 值
						moveres			= reg2_i + 4;			// 更新 esp 值
					end
					
					`EXE_PUSH_REG32_OP:	begin
						mem_addr_o	= ss + reg2_i ;		// target_addr 	= mem_addr_o = SS:offset	, reg2_i = esp
						mem_data_o	= reg1_i;					// target_data	= reg1_i;
						moveres			= reg2_i + 4;			// 更新 esp 值
					end
					
					`EXE_POP_REG16_OP:	begin
						mem_addr_o			= ss + reg2_i -4 ;		// target_addr 	= mem_addr_o = SS:offset	, reg2_i = esp
						//moveres					= mem_data_i;
						
						// 更新 esp 值
						//moveres				= reg2_i - 2;			//目前esp全部按4字节算							
						reg_val					= reg2_i - 4;			
						reg_fl					= `True_v;									
						reg_aluop				= `EXE_ESP_SET;
						reg_alusel			= `EXE_RES_EXP;
						reg_dest_addr_o	= `ESP;
					end
					
					`EXE_POP_REG32_OP:	begin
						mem_addr_o			= ss + reg2_i -4 ;		// target_addr 	= mem_addr_o = SS:offset	, reg2_i = esp
						//moveres					= mem_data_i;
						
						// 更新 esp 值
						//moveres				= reg2_i - 4;			//目前esp全部按4字节算							
						reg_val					= reg2_i - 4;			
						reg_fl					= `True_v;									
						reg_aluop				= `EXE_ESP_SET;
						reg_alusel			= `EXE_RES_EXP;
						reg_dest_addr_o	= `ESP;
					end
					
					//====================================================================================
					//============										 移位运算处理	 										==================
					//====================================================================================
					`EXE_SAL_OP: begin
						shiftres	= reg1_i << reg2_i;
					end
					
					`EXE_SAR_OP: begin						
						shiftres	= (reg1_i[31:31] << 31) | (reg1_i >> reg2_i);					//算术移位只针对32位寄存器
					end
					
					`EXE_SHL_OP: begin
						shiftres	= reg1_i << reg2_i;
					end
					
					`EXE_SHR_OP: begin
						shiftres	= reg1_i >> reg2_i;
					end
					
					`EXE_RCL_OP: begin					
						
						shiftres	= reg1_i;	//CF
						
						/*
						//modi on 2015-12-11
						for(j=0; j<reg2_i; j=j+1)	begin
							temp[0]	= shiftres[31];
							
							// add on 2015-11-4
							reg_eflag[`CF]	= temp[0];
							
							for(i=31; i>0; i=i-1)	begin
									shiftres[i]	= shiftres[i-1];
							end
							shiftres[0]	= temp[0];
						end
						*/
						
						case(reg2_i)
							8'h01:	begin
											for(j=0; j<1; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
							
							8'h02:	begin
											for(j=0; j<2; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h03:	begin
											for(j=0; j<3; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h04:	begin
											for(j=0; j<4; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h05:	begin
											for(j=0; j<5; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h06:	begin
											for(j=0; j<6; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h07:	begin
											for(j=0; j<7; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h08:	begin
											for(j=0; j<8; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h09:	begin
											for(j=0; j<9; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h0a:	begin
											for(j=0; j<10; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h0b:	begin
											for(j=0; j<11; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h0c:	begin
											for(j=0; j<12; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h0d:	begin
											for(j=0; j<13; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h0e:	begin
											for(j=0; j<14; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h0f:	begin
											for(j=0; j<15; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h10:	begin
											for(j=0; j<16; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h11:	begin
											for(j=0; j<17; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h12:	begin
											for(j=0; j<18; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h13:	begin
											for(j=0; j<19; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h14:	begin
											for(j=0; j<20; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h15:	begin
											for(j=0; j<21; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h16:	begin
											for(j=0; j<22; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h17:	begin
											for(j=0; j<23; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h18:	begin
											for(j=0; j<24; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h19:	begin
											for(j=0; j<25; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h1a:	begin
											for(j=0; j<26; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h1b:	begin
											for(j=0; j<27; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h1c:	begin
											for(j=0; j<28; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h1d:	begin
											for(j=0; j<29; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
													
							8'h1e:	begin
											for(j=0; j<30; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
							
							8'h1f:	begin
											for(j=0; j<31; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
													
							8'h20:	begin
											for(j=0; j<32; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
							
							default:	begin
										end
										
						endcase
						
						//--------------------------------------
						// add on 2015-11-4
						//CF set	
						reg_val					= reg_eflag;
						reg_fl					= `True_v;									
						reg_aluop				= `EXE_CF_SET;
						reg_alusel			= `EXE_RES_EXP;
						reg_dest_addr_o	= `EFLAGS;
						//--------------------------------------
						
					end					
					
					`EXE_RCR_OP: begin
						
						shiftres	= reg1_i;				//CF
						
						/*
						//modi on 2015-12-11
						for(j=0; j<reg2_i; j=j+1)	begin
							temp[0]	= shiftres[0];
							
							// add on 2015-11-4
							reg_eflag[`CF]	= temp[0];
							
							for(i=0; i<31; i=i+1)	begin
									shiftres[i]	= shiftres[i+1];
							end
							shiftres[31]	= temp[0];
						end
						*/
						
						case(reg2_i)
							8'h01:	begin
											for(j=0; j<1; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
							
							8'h02:	begin
											for(j=0; j<2; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h03:	begin
											for(j=0; j<3; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h04:	begin
											for(j=0; j<4; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h05:	begin
											for(j=0; j<5; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h06:	begin
											for(j=0; j<6; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h07:	begin
											for(j=0; j<7; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h08:	begin
											for(j=0; j<8; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h09:	begin
											for(j=0; j<9; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h0a:	begin
											for(j=0; j<10; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h0b:	begin
											for(j=0; j<11; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h0c:	begin
											for(j=0; j<12; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h0d:	begin
											for(j=0; j<13; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h0e:	begin
											for(j=0; j<14; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h0f:	begin
											for(j=0; j<15; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h10:	begin
											for(j=0; j<16; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h11:	begin
											for(j=0; j<17; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h12:	begin
											for(j=0; j<18; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h13:	begin
											for(j=0; j<19; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h14:	begin
											for(j=0; j<20; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h15:	begin
											for(j=0; j<21; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h16:	begin
											for(j=0; j<22; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h17:	begin
											for(j=0; j<23; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h18:	begin
											for(j=0; j<24; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h19:	begin
											for(j=0; j<25; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h1a:	begin
											for(j=0; j<26; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h1b:	begin
											for(j=0; j<27; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h1c:	begin
											for(j=0; j<28; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h1d:	begin
											for(j=0; j<29; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
													
							8'h1e:	begin
											for(j=0; j<30; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
							
							8'h1f:	begin
											for(j=0; j<31; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
													
							8'h20:	begin
											for(j=0; j<32; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
							
							default:	begin
										end
										
						endcase
												
						//--------------------------------------
						// add on 2015-11-4
						//CF set	
						reg_val					= reg_eflag;
						reg_fl					= `True_v;									
						reg_aluop				= `EXE_CF_SET;
						reg_alusel			= `EXE_RES_EXP;
						reg_dest_addr_o	= `EFLAGS;
						//--------------------------------------
						
						
					end						
					
					`EXE_ROL_OP: begin
										
						shiftres	= reg1_i;								
						
						/*
						//modi on 2015-12-11
						for(j=0; j<reg2_i; j=j+1)	begin
							temp[0]	= shiftres[31];
							
							// add on 2015-11-4
							reg_eflag[`CF]	= temp[0];
							
							for(i=31; i>0; i=i-1)	begin
									shiftres[i]	= shiftres[i-1];
							end
							shiftres[0]	= temp[0];
						end		
						*/
						
						case(reg2_i)
							8'h01:	begin
											for(j=0; j<1; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
							
							8'h02:	begin
											for(j=0; j<2; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h03:	begin
											for(j=0; j<3; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h04:	begin
											for(j=0; j<4; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h05:	begin
											for(j=0; j<5; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h06:	begin
											for(j=0; j<6; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h07:	begin
											for(j=0; j<7; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h08:	begin
											for(j=0; j<8; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h09:	begin
											for(j=0; j<9; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h0a:	begin
											for(j=0; j<10; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h0b:	begin
											for(j=0; j<11; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h0c:	begin
											for(j=0; j<12; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h0d:	begin
											for(j=0; j<13; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h0e:	begin
											for(j=0; j<14; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h0f:	begin
											for(j=0; j<15; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h10:	begin
											for(j=0; j<16; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h11:	begin
											for(j=0; j<17; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h12:	begin
											for(j=0; j<18; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h13:	begin
											for(j=0; j<19; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h14:	begin
											for(j=0; j<20; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h15:	begin
											for(j=0; j<21; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h16:	begin
											for(j=0; j<22; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h17:	begin
											for(j=0; j<23; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h18:	begin
											for(j=0; j<24; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h19:	begin
											for(j=0; j<25; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h1a:	begin
											for(j=0; j<26; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h1b:	begin
											for(j=0; j<27; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h1c:	begin
											for(j=0; j<28; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
										
							8'h1d:	begin
											for(j=0; j<29; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
													
							8'h1e:	begin
											for(j=0; j<30; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
							
							8'h1f:	begin
											for(j=0; j<31; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
													
							8'h20:	begin
											for(j=0; j<32; j=j+1)	begin
												temp[0]	= shiftres[31];
												reg_eflag[`CF]	= temp[0];
												
												for(i=31; i>0; i=i-1)	begin
														shiftres[i]	= shiftres[i-1];
												end
												shiftres[0]	= temp[0];
											end
										end
							
							default:	begin
										end
										
						endcase
						
						
						//--------------------------------------
						// add on 2015-11-4
						//CF set	
						reg_val					= reg_eflag;
						reg_fl					= `True_v;									
						reg_aluop				= `EXE_CF_SET;
						reg_alusel			= `EXE_RES_EXP;
						reg_dest_addr_o	= `EFLAGS;
						//--------------------------------------
						
					end
					
					
					`EXE_ROR_OP: begin	
						
						shiftres	= reg1_i;				
						
						/*
						//modi on 2015-12-11
						for(j=0; j<reg2_i; j=j+1)	begin
							temp[0]	= shiftres[0];
							
							// add on 2015-11-4
							reg_eflag[`CF]	= temp[0];
							
							for(i=0; i<31; i=i+1)	begin
									shiftres[i]	= shiftres[i+1];
							end
							shiftres[31]	= temp[0];
						end		
						*/
						
						case(reg2_i)
							8'h01:	begin
											for(j=0; j<1; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
							
							8'h02:	begin
											for(j=0; j<2; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h03:	begin
											for(j=0; j<3; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h04:	begin
											for(j=0; j<4; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h05:	begin
											for(j=0; j<5; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h06:	begin
											for(j=0; j<6; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h07:	begin
											for(j=0; j<7; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h08:	begin
											for(j=0; j<8; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h09:	begin
											for(j=0; j<9; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h0a:	begin
											for(j=0; j<10; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h0b:	begin
											for(j=0; j<11; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h0c:	begin
											for(j=0; j<12; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h0d:	begin
											for(j=0; j<13; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h0e:	begin
											for(j=0; j<14; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h0f:	begin
											for(j=0; j<15; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h10:	begin
											for(j=0; j<16; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h11:	begin
											for(j=0; j<17; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h12:	begin
											for(j=0; j<18; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h13:	begin
											for(j=0; j<19; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h14:	begin
											for(j=0; j<20; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h15:	begin
											for(j=0; j<21; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h16:	begin
											for(j=0; j<22; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h17:	begin
											for(j=0; j<23; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h18:	begin
											for(j=0; j<24; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h19:	begin
											for(j=0; j<25; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h1a:	begin
											for(j=0; j<26; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h1b:	begin
											for(j=0; j<27; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h1c:	begin
											for(j=0; j<28; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
										
							8'h1d:	begin
											for(j=0; j<29; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
													
							8'h1e:	begin
											for(j=0; j<30; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
							
							8'h1f:	begin
											for(j=0; j<31; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
													
							8'h20:	begin
											for(j=0; j<32; j=j+1)	begin
												temp[0]	= shiftres[0];
												reg_eflag[`CF]	= temp[0];
												
												for(i=0; i<31; i=i+1)	begin
														shiftres[i]	= shiftres[i+1];
												end
												shiftres[31]	= temp[0];
											end
										end
							
							default:	begin
										end
										
						endcase
						
						
						//--------------------------------------
						// add on 2015-11-4
						//CF set	
						reg_val					= reg_eflag;
						reg_fl					= `True_v;									
						reg_aluop				= `EXE_CF_SET;
						reg_alusel			= `EXE_RES_EXP;
						reg_dest_addr_o	= `EFLAGS;
						//--------------------------------------	
						
						
					end		
					
					//====================================================================================
					//============										 系统指令处理	 										==================
					//====================================================================================
					`EXE_NOP_OP: begin
						sysres	= `ZeroWord;
					end	
					
					`EXE_STI_OP: begin
						sysres			= reg1_i;
						sysres[`IF]	= reg2_i;					// reg2_i = 1						
					end	
					
					`EXE_CLI_OP: begin
						sysres			= reg1_i;
						sysres[`IF]	= reg2_i;					// reg2_i = 0	
					end	
					
					`EXE_STC_OP: begin
						sysres			= reg1_i;
						sysres[`OF]	= reg2_i;					// reg2_i = 1	
					end	
					
					`EXE_CLC_OP: begin
						sysres			= reg1_i;
						sysres[`OF]	= reg2_i;					// reg2_i = 0
					end	
					
					`EXE_LEA_OP: begin
						sysres	= reg2_i;
					end
					
					`EXE_LEAVE_OP: begin
						esp			= reg1_i;
						ebp			= reg2_i;
						
						//pop ebx	
						mem_addr_o			= ss + esp -4 ;		// target_addr 	= mem_addr_o = SS:offset	, reg1_i = esp
												
						//esp = ebp
						reg_val					= ebp;			
						reg_fl					= `True_v;									
						reg_aluop				= `EXE_ESP_SET;
						reg_alusel			= `EXE_RES_EXP;
						reg_dest_addr_o	= `ESP;
					end	
					
					`EXE_SIDT_OP: begin
						mem_addr_o			= ds + reg2_i ;		// target_addr 	= mem_addr_o = SS:offset	, reg2_i = offset	
						
						ex_w_reg64_o		= `WriteEnable;
					end
					
					`EXE_LIDT_OP: begin
						mem_addr_o			= ds + reg2_i ;		// target_addr 	= mem_addr_o = SS:offset	, reg2_i = offset	
						
						ex_w_reg64_o		= `WriteEnable;
					end
					
					`EXE_SGDT_OP: begin
						mem_addr_o			= ds + reg2_i ;		// target_addr 	= mem_addr_o = SS:offset	, reg2_i = offset	
						
						ex_w_reg64_o		= `WriteEnable;
					end
					
					`EXE_LGDT_OP: begin
						mem_addr_o			= ds + reg2_i ;		// target_addr 	= mem_addr_o = SS:offset	, reg2_i = offset	
						
						ex_w_reg64_o		= `WriteEnable;
					end
					
					`EXE_STR_OP: begin
						mem_addr_o			= ds + reg2_i ;		// target_addr 	= mem_addr_o = SS:offset	, reg2_i = offset	
						
						ex_w_reg64_o		= `WriteEnable;
					end
					
					`EXE_LTR_OP: begin
						mem_addr_o			= ds + reg2_i ;		// target_addr 	= mem_addr_o = SS:offset	, reg2_i = offset	
						
						ex_w_reg64_o		= `WriteEnable;
					end
					
					`EXE_SLDT_OP: begin
						mem_addr_o			= ds + reg2_i ;		// target_addr 	= mem_addr_o = SS:offset	, reg2_i = offset	
						
						ex_w_reg64_o		= `WriteEnable;
					end
					
					`EXE_LLDT_OP: begin
						mem_addr_o			= ds + reg2_i ;		// target_addr 	= mem_addr_o = SS:offset	, reg2_i = offset	
						
						ex_w_reg64_o		= `WriteEnable;
					end	
					
					//====================================================================================
					//============										 异常的处理		 										==================
					//====================================================================================	
					`EXE_ADD_OP, `EXE_ADC_OP, `EXE_INC_OP:	begin
						exp_retpc	= mem_pc_i + 4 - 4;        //暂定ADD的指令长度为4字节，以后再改
					end
					
					`EXE_MUL_OP_8,  `EXE_MUL_OP_16,  `EXE_MUL_OP_32:	begin
							exp_retpc	= mem_pc_i + 4 - 4;        //暂定乘法的指令长度为4字节，以后再改
					end
					
					`EXE_SYSCALL_OP: begin
							exp_no	= 8'h80;
							exp_retpc	= mem_pc_i + 4 - 4;        //暂定syscall的指令长度为4字节，以后再改
					end
					
					//====================================================================================
					//============										 EFLAGS 处理	 										==================
					//====================================================================================
					`EXE_CF_SET	: begin				//设置EFLAGS 的 CF 位
							expres				= reg2_i;	
							reg_fl				= `False_v;						
					end	
					
					`EXE_MUL_SET	: begin				//设置DX,EDX
							expres				= reg2_i;	
							reg_fl				= `False_v;					
					end	
					
					`EXE_DIV_SET	: begin				//设置 AL, AX, EAX
							expres				= reg2_i;	
							reg_fl				= `False_v;					
					end	
					
					`EXE_ESP_SET	: begin				//设置 ESP
							expres				= reg2_i;	
							reg_fl				= `False_v;					
					end
					
					
									
				default: begin
					//jmp default
					jmp_addr	= `ZeroWord;
					jmp_fl		=	`False_v;						
					mem_addr_j_o	=	`ZeroWord;
					mem_data_j_o	=	`ZeroWord;
					
					//arith default	
					arithres							= `ZeroWord;
					arithres64						= `ZeroDWord;
					temp									=	`ZeroWord;		
					start_div_o						= `False_v;	
									
					//logic default
					logicout	= `ZeroWord;
					
					//mov default
					moveres		= `ZeroWord;
					mem_data_o=	`ZeroWord;
					mem_addr_o=	`ZeroWord;
					
					//shift default
					shiftres							= `ZeroWord;
					i											= `ZeroWord;
					j											= `ZeroWord;
					
					//--------------------------------------
					//modi on 2015-12-22
					//k											= `ZeroWord;
					//temp									= `ZeroWord;
					//--------------------------------------
					
					//sys default
					sysres	= `ZeroWord;
					
					//exception default
					exp_no	= 8'hFF;
					
					//eflag default
					expres						= `ZeroWord;	
					
									
				end
			endcase	
			
			//====================================================================================
			//============										 64位寄存器处理										==================
			//====================================================================================
			if (mem_w_reg64_i == `WriteEnable)	begin
						idt						=  mem_idt_i;
						gdt           =  mem_gdt_i;
						ldt           =  mem_ldt_i;
						tr	          =  mem_tr_i;
			end else if (wb_w_reg64_i == `WriteEnable)	begin
						idt						=  wb_idt_i;
						gdt           =  wb_gdt_i;
						ldt           =  wb_ldt_i;
						 tr           =  wb_tr_i;	
			end else begin	
						idt						=  ex_idt_i;
						gdt           =  ex_gdt_i;
						ldt           =  ex_ldt_i;
						 tr           =  ex_tr_i;		 
			end
					
			//====================================================================================
			//============										 DIV补充处理											==================
			//====================================================================================
			if(div_state_i == `DIV_STATE_2)	begin
				arithres			= div_res_i;
				stallreq			= `NoStop;
				start_div_o		= `False_v;
				
				reg_val					= arithres;
				reg_fl					= `True_v;
				reg_alusel			= `EXE_RES_EXP;
				
				case(div_aluop_t)
						`EXE_DIV_OP_8:	begin
									reg_dest_addr_o	= `AL;
									reg_aluop				= `EXE_DIV_SET;
						end
						
						`EXE_DIV_OP_16:	begin
									reg_dest_addr_o	= `AX;
									reg_aluop				= `EXE_DIV_SET;
						end
				
						`EXE_DIV_OP_32:	begin
									reg_dest_addr_o	= `EAX;
									reg_aluop				= `EXE_DIV_SET;
						end
						
						default:	begin
						end
				endcase
				
			end
			
			//====================================================================================
			//============										 异常补充处理	 										==================
			//====================================================================================
			if(of == 1) begin
					exp_no	=  8'h04;
			end
				
			if((timer_int_o == 1) && (int_status_i == 1))	begin
					exp_no	=	 `EXP_32;
			end
			
			//====================================================================================
			//============									所有处理的最终结果									==================
			//====================================================================================
			wd_o		= wd_i;
			wreg_o	= wreg_i;
			case (alusel_i)
				`EXE_RES_LOGIC: begin
					wdata_o	= logicout;
				end
				
				`EXE_RES_MOV:		begin
		 			wdata_o = moveres;
		 			
		 			//--------------------------------
		 			//add on 2015-12-17
		 			case(wd_i)
		 				`ESP:	begin
		 								esp	= moveres;
		 							end
		 			endcase
		 			//--------------------------------
		 		end	
		 		
		 		`EXE_RES_SHIFT:		begin
		 			wdata_o = shiftres;
		 		end	
		 		
		 		`EXE_RES_ARITH:		begin
		 			wdata_o = arithres;
		 		end	
		 		
		 			 		
		 		`EXE_RES_EXP:		begin
		 			wdata_o = expres;
		 		end
		 		
		 		`EXE_RES_JMP:		begin
		 			wdata_o = jmpres;
		 		end	
		 		
		 		`EXE_RES_SYS:		begin
		 			wdata_o = sysres;
		 		end		
		 		
		 	
				default: begin
					wdata_o	= `ZeroWord;
				end
			endcase
			
			
		end
	end



endmodule