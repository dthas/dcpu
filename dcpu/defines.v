`define	BIG_END								1'b0
`define	LITTLE_END						1'b1

`define	RstEnable							1'b1
`define	RstDisable						1'b0
`define	ZeroByte							8'h00
`define	ZeroDByte							16'h0000
`define	ZeroWord							32'h00000000
`define	ZeroDWord							64'h0000000000000000
`define	WriteEnable						1'b1
`define	WriteDisable					1'b0
`define	ReadEnable						1'b1
`define	ReadDisable						1'b0
`define	AluOpBus							7:0
`define	AluSelBus							2:0
`define	InstValid							1'b0
`define	InstInValid						1'b1

`define Stop 1'b1
`define NoStop 1'b0
`define InDelaySlot 1'b1
`define NotInDelaySlot 1'b0
`define Branch 1'b1
`define NotBranch 1'b0
`define InterruptAssert 1'b1
`define InterruptNotAssert 1'b0
`define TrapAssert 1'b1
`define TrapNotAssert 1'b0

//数据存储器data_ram
`define DataAddrBus 31:0
`define DataBus 31:0
`define ByteWidth 7:0
`define WordWidth 15:0

//modi on 2015-11-19
//`define DataMemNum 131071
//`define DataMemNumLog2 17
`define DataMemNum 127
`define DataMemNumLog2 7


`define	True_v								1'b1
`define	False_v								1'b0
`define	ChipEnable						1'b1
`define	ChipDisable						1'b0

//`define	EXE_AND								6'b001000
//`define	EXE_AND_1							6'b100000

//------------	add		 ------------------------------
`define	OPCODE_00							8'h00
`define	OPCODE_01							8'h01
`define	OPCODE_02							8'h02
`define	OPCODE_03							8'h03
`define	OPCODE_04							8'h04				
`define	OPCODE_05							8'h05
//---------------------------------------------------

//------------	adc		 ------------------------------
`define	OPCODE_10							8'h10
`define	OPCODE_11							8'h11
`define	OPCODE_12							8'h12
`define	OPCODE_13							8'h13
`define	OPCODE_14							8'h14				
`define	OPCODE_15							8'h15
//---------------------------------------------------

//------------	sbb		 ------------------------------
`define	OPCODE_18							8'h18
`define	OPCODE_19							8'h19
`define	OPCODE_1A							8'h1A				
`define	OPCODE_1B							8'h1B
`define	OPCODE_1C							8'h1C
`define	OPCODE_1D							8'h1D
//---------------------------------------------------

//------------	sub		 ------------------------------
`define	OPCODE_28							8'h28
`define	OPCODE_29							8'h29
`define	OPCODE_2A							8'h2A				
`define	OPCODE_2B							8'h2B
`define	OPCODE_2C							8'h2C
`define	OPCODE_2D							8'h2D
//---------------------------------------------------

//------------	inc/dec		 --------------------------
`define	OPCODE_40							8'h40
`define	OPCODE_41							8'h41
`define	OPCODE_42							8'h42
`define	OPCODE_43							8'h43
`define	OPCODE_44							8'h44
`define	OPCODE_45							8'h45
`define	OPCODE_46							8'h46
`define	OPCODE_47							8'h47
`define	OPCODE_48							8'h48
`define	OPCODE_49							8'h49
`define	OPCODE_4A							8'h4A
`define	OPCODE_4B							8'h4B
`define	OPCODE_4C							8'h4C
`define	OPCODE_4D							8'h4D
`define	OPCODE_4E							8'h4E
`define	OPCODE_4F							8'h4F
`define	OPCODE_FE							8'hFE
`define	OPCODE_FF							8'hFF						// push
//---------------------------------------------------

//------------	cmp		 ------------------------------
`define	OPCODE_38							8'h38
`define	OPCODE_39							8'h39
`define	OPCODE_3A							8'h3A
`define	OPCODE_3B							8'h3B
`define	OPCODE_3C							8'h3C				
`define	OPCODE_3D							8'h3D
//---------------------------------------------------


//------------	and/or ------------------------------
`define	OPCODE_08							8'h08				//or
`define	OPCODE_09							8'h09				//or
`define	OPCODE_0A							8'h0A				//or
`define	OPCODE_0B							8'h0B				//or
`define	OPCODE_0C							8'h0C				//or
`define	OPCODE_0D							8'h0D				//or

`define	OPCODE_20							8'h20				//and
`define	OPCODE_21							8'h21				//and
`define	OPCODE_23							8'h23				//and
`define	OPCODE_24							8'h24				//and
`define	OPCODE_25							8'h25				//and


//`define	OPCODE_80							8'h80				//and,or,add, jcc
//`define	OPCODE_81							8'h81				//and,or,add, jcc
//`define	OPCODE_83							8'h83				//and,or,add, jcc

//---------------------------------------------------

//------------	push/pop ----------------------------
`define	OPCODE_50							8'h50
`define	OPCODE_51							8'h51
`define	OPCODE_52							8'h52
`define	OPCODE_53							8'h53
`define	OPCODE_54							8'h54				
`define	OPCODE_55							8'h55
`define	OPCODE_56							8'h56
`define	OPCODE_57							8'h57
`define	OPCODE_58							8'h58
`define	OPCODE_59							8'h59
`define	OPCODE_5A							8'h5A
`define	OPCODE_5B							8'h5B
`define	OPCODE_5C							8'h5C				
`define	OPCODE_5D							8'h5D
`define	OPCODE_5E							8'h5E
`define	OPCODE_5F							8'h5F

`define	OPCODE_68							8'h68
`define	OPCODE_6A							8'h6A

`define	OPCODE_A0							8'hA0					//0F A0
`define	OPCODE_A8							8'hA8					//0F A8

`define	OPCODE_06							8'h06
`define	OPCODE_0E							8'h0E
`define	OPCODE_16							8'h16
`define	OPCODE_1E							8'h1E

`define	OPCODE_07							8'h07
`define	OPCODE_17							8'h17
`define	OPCODE_1F							8'h1F

`define	OPCODE_A1							8'hA1					//0F A1
`define	OPCODE_A9							8'hA9					//0F A9
//------------	jcc		 ------------------------------
`define	OPCODE_70							8'h70
`define	OPCODE_71							8'h71
`define	OPCODE_72							8'h72
`define	OPCODE_73							8'h73
`define	OPCODE_74							8'h74				
`define	OPCODE_75							8'h75
`define	OPCODE_76							8'h76
`define	OPCODE_77							8'h77
`define	OPCODE_78							8'h78
`define	OPCODE_79							8'h79
`define	OPCODE_7A							8'h7A				
`define	OPCODE_7B							8'h7B
`define	OPCODE_7C							8'h7C
`define	OPCODE_7D							8'h7D
`define	OPCODE_7E							8'h7E				
`define	OPCODE_7F							8'h7F
`define	OPCODE_80							8'h80				
`define	OPCODE_81							8'h81				
`define	OPCODE_82							8'h82
`define	OPCODE_83							8'h83				
`define	OPCODE_84							8'h84				
`define	OPCODE_85							8'h85
`define	OPCODE_86							8'h86
`define	OPCODE_87							8'h87
`define	OPCODE_88							8'h88
`define	OPCODE_89							8'h89
`define	OPCODE_8A							8'h8A				
`define	OPCODE_8B							8'h8B
`define	OPCODE_8C							8'h8C
`define	OPCODE_8D							8'h8D
`define	OPCODE_8E							8'h8E							
`define	OPCODE_8F							8'h8F	
`define	OPCODE_0F							8'h0F	

`define	OPCODE_E3							8'hE3			
//---------------------------------------------------

`define	OPCODE_90							8'h90					// nop
`define	OPCODE_C9							8'hC9					// leave
`define	OPCODE_F8							8'hF8					// CLC
`define	OPCODE_F9							8'hF9					// STC
`define	OPCODE_FA							8'hFA					// CLI
`define	OPCODE_FB							8'hFB					// STI


//------------	mov ---------------------------------
//`define	OPCODE_88							8'h88			
//`define	OPCODE_89							8'h89			

`define	OPCODE_B0							8'hB0
`define	OPCODE_B1							8'hB1
`define	OPCODE_B2							8'hB2
`define	OPCODE_B3							8'hB3
`define	OPCODE_B4							8'hB4
`define	OPCODE_B5							8'hB5
`define	OPCODE_B6							8'hB6
`define	OPCODE_B7							8'hB7
`define	OPCODE_B8							8'hB8
`define	OPCODE_B9							8'hB9
`define	OPCODE_BA							8'hBA
`define	OPCODE_BB							8'hBB
`define	OPCODE_BC							8'hBC
`define	OPCODE_BD							8'hBD
`define	OPCODE_BE							8'hBE
`define	OPCODE_BF							8'hBF
//---------------------------------------------------

//------------	loop	 ------------------------------
`define	OPCODE_E0							8'hE0				
`define	OPCODE_E1							8'hE1
`define	OPCODE_E2							8'hE2
//---------------------------------------------------

//------------	call	 ------------------------------
`define	OPCODE_E8							8'hE8

//---------------------------------------------------

//------------	ret	 ------------------------------
`define	OPCODE_C3							8'hC3
`define	OPCODE_CB							8'hC3

//---------------------------------------------------

//------------	jmp		 ------------------------------
`define	OPCODE_E9							8'hE9				
`define	OPCODE_EB							8'hEB
//---------------------------------------------------

//------------	not		 ------------------------------
`define	OPCODE_F6							8'hF6				
`define	OPCODE_F7							8'hF7
//---------------------------------------------------

//------------	SAL/SAR/SHL/SHR  --------------------
`define	OPCODE_C0							8'hC0			//SAL/SAR/SHL/SHR			
`define	OPCODE_C1							8'hC1			//SAL/SAR/SHL/SHR
`define	OPCODE_D0							8'hD0			//SAL/SAR/SHL/SHR				
`define	OPCODE_D1							8'hD1			//SAL/SAR/SHL/SHR	
`define	OPCODE_D2							8'hD2			//SAL/SAR/SHL/SHR			
`define	OPCODE_D3							8'hD3			//SAL/SAR/SHL/SHR
//---------------------------------------------------

`define	ADD_REG								3'b000
`define	ADC_REG								3'b010
`define	SUB_REG								3'b101
`define	SBB_REG								3'b011
`define	INC_REG								3'b000
`define	DEC_REG								3'b001
`define	AND_REG								3'b100	
`define	OR_REG								3'b001
`define	MUL_REG								3'b100
`define	DIV_REG								3'b110
`define	NOT_REG								3'b010
`define	SAL_REG								3'b100
`define	SAR_REG								3'b111
`define	SHL_REG								3'b100
`define	SHR_REG								3'b101
`define	RCL_REG								3'b010
`define	RCR_REG								3'b011
`define	ROL_REG								3'b000
`define	ROR_REG								3'b001
`define	JMP_REG								3'b100
`define	CMP_REG								3'b111
`define	PUSH_REG							3'b110
`define	POP_REG								3'b000
`define	CALL_REG							3'b010
`define	SGDT_REG							3'b000
`define	SIDT_REG							3'b001
`define	LGDT_REG							3'b010
`define	LIDT_REG							3'b011
`define	LTR_REG								3'b011
`define	STR_REG								3'b001
`define	SLDT_REG							3'b000
`define	LLDT_REG							3'b010

//算术运算
`define	EXE_ADD_OP						8'b00010000
`define	EXE_SUB_OP						8'b00010001
`define	EXE_ADC_OP						8'b00010010
`define	EXE_SBB_OP						8'b00010011
`define	EXE_INC_OP						8'b00010100
`define	EXE_DEC_OP						8'b00010101
`define	EXE_MUL_OP_8					8'b00010110
`define	EXE_MUL_OP_16					8'b00010111
`define	EXE_MUL_OP_32					8'b00011000
`define	EXE_DIV_OP_8					8'b00011001
`define	EXE_DIV_OP_16					8'b00011010
`define	EXE_DIV_OP_32					8'b00011011
`define	EXE_CMP_OP						8'b00011100

//逻辑运算
`define	EXE_AND_OP						8'b00100100
`define	EXE_OR_OP							8'b00100101
`define	EXE_NOT_OP						8'b00100110

//移位运算
`define	EXE_SAL_OP						8'b00110000
`define	EXE_SAR_OP						8'b00110001
`define	EXE_SHL_OP						8'b00110010
`define	EXE_SHR_OP						8'b00110011
`define	EXE_RCL_OP						8'b00110100
`define	EXE_RCR_OP						8'b00110101
`define	EXE_ROL_OP						8'b00110110
`define	EXE_ROR_OP						8'b00110111

//转移
`define	EXE_JMP_OP_8					8'b10000000
`define	EXE_JMP_OP_16					8'b10000001
`define	EXE_JMP_OP_32					8'b10000010
`define	EXE_JA_OP_8						8'b10000100
`define	EXE_JAE_OP_8					8'b10000101
`define	EXE_JB_OP_8						8'b10000110
`define	EXE_JBE_OP_8					8'b10000111
`define	EXE_JC_OP_8						8'b10001000
`define	EXE_JCXZ_OP_8					8'b10001001
`define	EXE_JECXZ_OP_8				8'b10001010
`define	EXE_JRCXZ_OP_8				8'b10001011
`define	EXE_JE_OP_8						8'b10001100
`define	EXE_JG_OP_8						8'b10001101
`define	EXE_JGE_OP_8					8'b10001110
`define	EXE_JL_OP_8						8'b10001111
`define	EXE_JLE_OP_8					8'b10010001
`define	EXE_JNA_OP_8					8'b10010010
`define	EXE_JNAE_OP_8					8'b10010011
`define	EXE_JNB_OP_8					8'b10010100
`define	EXE_JNBE_OP_8					8'b10010101
`define	EXE_JNC_OP_8					8'b10010110
`define	EXE_JNE_OP_8					8'b10010111
`define	EXE_JNG_OP_8					8'b10011000
`define	EXE_JNGE_OP_8					8'b10011001
`define	EXE_JNL_OP_8					8'b10011010
`define	EXE_JNLE_OP_8					8'b10011011
`define	EXE_JNO_OP_8					8'b10011100
`define	EXE_JNP_OP_8					8'b10011101
`define	EXE_JNS_OP_8					8'b10011110
`define	EXE_JNZ_OP_8					8'b10011111
`define	EXE_JO_OP_8						8'b10100000
`define	EXE_JP_OP_8						8'b10100001
`define	EXE_JPE_OP_8					8'b10100010
`define	EXE_JPO_OP_8					8'b10100011
`define	EXE_JS_OP_8						8'b10100100
`define	EXE_JZ_OP_8						8'b10100101
`define	EXE_JAE_OP_16					8'b10100110
`define	EXE_JB_OP_16					8'b10100111
`define	EXE_JBE_OP_16					8'b10101000
`define	EXE_JC_OP_16					8'b10101001
`define	EXE_JCXZ_OP_16				8'b10101010
`define	EXE_JECXZ_OP_16				8'b10101011
`define	EXE_JRCXZ_OP_16				8'b10101100
`define	EXE_JE_OP_16					8'b10101101
`define	EXE_JG_OP_16					8'b10101110
`define	EXE_JGE_OP_16					8'b10101111
`define	EXE_JL_OP_16					8'b10110000
`define	EXE_JLE_OP_16					8'b10110001
`define	EXE_JNA_OP_16					8'b10110010
`define	EXE_JNAE_OP_16				8'b10110011
`define	EXE_JNB_OP_16					8'b10110100
`define	EXE_JNBE_OP_16				8'b10110101
`define	EXE_JNC_OP_16					8'b10110110
`define	EXE_JNE_OP_16					8'b10110111
`define	EXE_JNG_OP_16					8'b10111000
`define	EXE_JNGE_OP_16				8'b10111001
`define	EXE_JNL_OP_16					8'b10111010
`define	EXE_JNLE_OP_16				8'b10111011
`define	EXE_JNO_OP_16					8'b10111100
`define	EXE_JNP_OP_16					8'b10111101
`define	EXE_JNS_OP_16					8'b10111110
`define	EXE_JNZ_OP_16					8'b10111111
`define	EXE_JO_OP_16					8'b11000000
`define	EXE_JP_OP_16					8'b11000001
`define	EXE_JPE_OP_16					8'b11000010
`define	EXE_JPO_OP_16					8'b11000011
`define	EXE_JS_OP_16					8'b11000100
`define	EXE_JZ_OP_16					8'b11000101
`define	EXE_JAE_OP_32					8'b11000110
`define	EXE_JB_OP_32					8'b11000111
`define	EXE_JBE_OP_32					8'b11001000
`define	EXE_JC_OP_32					8'b11001001
`define	EXE_JCXZ_OP_32				8'b11001010
`define	EXE_JECXZ_OP_32				8'b11001011
`define	EXE_JRCXZ_OP_32				8'b11001100
`define	EXE_JE_OP_32					8'b11001101
`define	EXE_JG_OP_32					8'b11001110
`define	EXE_JGE_OP_32					8'b11001111
`define	EXE_JL_OP_32					8'b11010000
`define	EXE_JLE_OP_32					8'b11010001
`define	EXE_JNA_OP_32					8'b11010010
`define	EXE_JNAE_OP_32				8'b11010011
`define	EXE_JNB_OP_32					8'b11010100
`define	EXE_JNBE_OP_32				8'b11010101
`define	EXE_JNC_OP_32					8'b11010110
`define	EXE_JNE_OP_32					8'b11010111
`define	EXE_JNG_OP_32					8'b11011000
`define	EXE_JNGE_OP_32				8'b11011001
`define	EXE_JNL_OP_32					8'b11011010
`define	EXE_JNLE_OP_32				8'b11011011
`define	EXE_JNO_OP_32					8'b11011100
`define	EXE_JNP_OP_32					8'b11011101
`define	EXE_JNS_OP_32					8'b11011110
`define	EXE_JNZ_OP_32					8'b11011111
`define	EXE_JO_OP_32					8'b11100000
`define	EXE_JP_OP_32					8'b11100001
`define	EXE_JPE_OP_32					8'b11100010
`define	EXE_JPO_OP_32					8'b11100011
`define	EXE_JS_OP_32					8'b11100100
`define	EXE_JZ_OP_32					8'b11100101
`define	EXE_JA_OP_16					8'b11100110
`define	EXE_JA_OP_32					8'b11100111
`define	EXE_LOOPNE_OP					8'b11101000
`define	EXE_LOOP_OP						8'b11101001
`define	EXE_LOOPE_OP					8'b11101010
`define	EXE_CALL_OP_32				8'b11101011
`define	EXE_RET_OP_16					8'b11101100
`define	EXE_RET_OP_32					8'b11101101
`define	EXE_CALLREG_OP_16			8'b11101110
`define	EXE_CALLREG_OP_32			8'b11101111


//赋值
`define	EXE_MOV_IMM_OP				8'b00101100
`define	EXE_MOV_REG_OP				8'b00101101
`define	EXE_PUSH_REG16_OP			8'b00101110
`define	EXE_PUSH_REG32_OP			8'b00101111
`define	EXE_PUSH_IMM8_OP			8'b11110000
`define	EXE_PUSH_IMM16_OP			8'b11110001
`define	EXE_PUSH_IMM32_OP			8'b11110010
`define	EXE_POP_REG16_OP			8'b11110011
`define	EXE_POP_REG32_OP			8'b11110100

//标志位设置
`define	EXE_CF_SET						8'b01000000
`define	EXE_MUL_SET						8'b01000001
`define	EXE_DIV_SET						8'b01000010
`define	EXE_ESP_SET						8'b01000011

//系统指令设置
`define	EXE_NOP_OP						8'b00000000
`define	EXE_STI_OP						8'b11110101
`define	EXE_STC_OP						8'b11110110
`define	EXE_CLI_OP						8'b11110111
`define	EXE_CLC_OP						8'b11111000
`define	EXE_SIDT_OP						8'b11111001
`define	EXE_LEA_OP						8'b11111010
`define	EXE_LEAVE_OP					8'b11111011
`define	EXE_LIDT_OP						8'b11111100
`define	EXE_LGDT_OP						8'b11111101
`define	EXE_LTR_OP						8'b11111110
`define	EXE_SGDT_OP						8'b11111111
`define	EXE_SLDT_OP						8'b00000001
`define	EXE_STR_OP						8'b00000010
`define	EXE_LLDT_OP						8'b00000011
`define	EXE_SYSCALL_OP				8'b00000100

`define	EXE_RES_NOP						3'b000
`define	EXE_RES_LOGIC					3'b001
`define	EXE_RES_MOV						3'b010
`define	EXE_RES_SHIFT					3'b011
`define	EXE_RES_EXP						3'b100
`define	EXE_RES_ARITH					3'b101
`define	EXE_RES_JMP						3'b110
`define	EXE_RES_SYS						3'b111

`define	InstAddrBus						31:0
`define	InstBus								31:0
`define	InstBus8							7:0						//0~128

`define	InstMemNum						131071
`define	InstMemNumLog2				17

`define	RegAddrBus						4:0
`define	RegAddrBusX86					2:0
`define	RegBus								31:0
`define	RegWidth							32
`define	DoubleRegWidth				64
`define	DoubleRegBus					63:0
`define	RegNum								32
`define	RegNumLog2						5
`define	NOPRegAddr						5'b00000
`define	NOPRegAddrX86					3'b000

//---------------------------------------------------
//modi on 2015-12-22
//`define	InstWidth							383:0
//`define	InstLen								384				//384bit
`define	InstWidth							95:0
`define	InstLen								96				//96bit
//---------------------------------------------------

`define	Num32									32
`define	Num24									24
`define	Num16									16
`define	Num8									8

`define	AL										5'b00000
`define	AX										5'b00001
`define	EAX										5'b00011
`define	CL										5'b00100
`define	CX										5'b00101
`define	ECX										5'b00111
`define	DL										5'b01000
`define	DX										5'b01001
`define	EDX										5'b01011
`define	BL										5'b01100
`define	BX										5'b01101
`define	EBX										5'b01111
`define	AH										5'b10000
`define	SP										5'b10001
`define	ESP										5'b10011
`define	CH										5'b10100
`define	BP										5'b10101
`define	EBP										5'b10111
`define	DH										5'b11000
`define	SI										5'b11001
`define	ESI										5'b11011
`define	BH										5'b11100
`define	DI										5'b11101
`define	EDI										5'b11111

`define	WRONG_REG							5'b11110

`define	EFLAGS								5'b00010

`define	ES										5'b00110
`define	CS										5'b01010
`define	SS										5'b01110
`define	DS										5'b10010
`define	FS										5'b10110
`define	GS										5'b11010



//EFLAGS
`define	CF										5'b00000
`define	PF										2
`define	ZF										6
`define	SF										7
`define	IF										9
`define	OF										11

`define	DIV_STATE_0						1
`define	DIV_STATE_1						2
`define	DIV_STATE_2						3
`define	DIV_STATE_3						4
`define	DIV_STATE_99					0


`define DataBus64 						63:0
`define	RegBus64							63:0

//异常
`define	EXP_0									0
`define	EXP_1									1
`define	EXP_2									2
`define	EXP_3									3
`define	EXP_4									4
`define	EXP_5									5
`define	EXP_6									6
`define	EXP_7									7
`define	EXP_8									8
`define	EXP_9									9
`define	EXP_10								10
`define	EXP_11								11
`define	EXP_12								12
`define	EXP_13								13
`define	EXP_14								14
`define	EXP_15								15
`define	EXP_16								16
`define	EXP_17								17
`define	EXP_18								18
`define	EXP_19								19

//中断
`define	EXP_32								32
`define	EXP_33								33
`define	EXP_34								34
`define	EXP_35								35
`define	EXP_36								36
`define	EXP_37								37
`define	EXP_38								38
`define	EXP_39								39
`define	EXP_40								40
`define	EXP_41								41
`define	EXP_42								42
`define	EXP_43								43
`define	EXP_44								44
`define	EXP_45								45
`define	EXP_46								46
`define	EXP_47								47

//syscall
`define	EXP_80								8'h80

`define BUS_IDLE 							3'b000
`define BUS_BUSY 							3'b001
`define BUS_WAIT_FOR_FLUSHING 3'b010
`define BUS_WAIT_FOR_STALL 		3'b011	
                                 
//bus
`define	YES										1'b1
`define	NO										1'b0
`define	MASTER_0							2'b00
`define	MASTER_1							2'b01
`define	MASTER_2							2'b10
`define	MASTER_3							2'b11		
`define	SLAVE_0								0
`define	SLAVE_1								1
`define	SLAVE_2								2
`define	SLAVE_3								3
`define	SLAVE_4								4
`define	SLAVE_5								5
`define	SLAVE_6								6
`define	SLAVE_7								7
//`define	WordAddrBus						29:0 
`define	WordAddrBus						31:0 
`define	WordDataBus						31:0
`define	WordAddrWith					29
`define	WordDataWith					32
`define	READ									1'b0	
`define	WRITE									1'b1
`define	BUS_SLAVE_INDEX_3			3
`define	BusSlaveIndexLoc			29:27

//gpio
`define	GpioAddrBus						1:0
//`define	GPIO_IN_CH						4
//`define	GPIO_OUT_CH						18
`define	GPIO_IN_CH						16
`define	GPIO_OUT_CH						32
`define	GPIO_IO_CH						16
`define	GpioAddrBus						1:0
`define	GPIO_ADDR_W						2
`define	GpioAddrLoc						1:0
`define	GPIO_ADDR_IN_DATA			2'h0
`define	GPIO_ADDR_OUT_DATA		2'h1
`define	GPIO_ADDR_IO_DATA			2'h2
`define	GPIO_ADDR_IO_DIR			2'h3
`define	GPIO_DIR_IN						1'b0
`define	GPIO_DIR_OUT					1'b1


//uart
`define	UART_DIV_RATE					9'd260
`define	UART_DIV_CNT_W				9
`define	UartDivCntBus					8:0
`define	UartAddrBus						0:0
`define	UART_ADDR_W						1
`define	UartAddrLoc						0:0
`define	UART_ADDR_STATUS			1'h0
`define	UART_ADDR_DATA				1'h1
`define	UartCtrlIrqRx					0
`define	UartCtrlIrqTx					1
`define	UartCtrlBusyRx				2
`define	UartCtrlBusyTx				3
`define	UartStateBus					0:0
`define	UART_STATE_IDLE				1'b0
`define	UART_STATE_TX					1'b1
`define	UART_STATE_RX					1'b1
`define	UartBitCntBus					3:0
`define	UART_BIT_CNT_W				4
`define	UART_BIT_CNT_START		4'h0
`define	UART_BIT_CNT_MSB			4'h8
`define	UART_BIT_CNT_STOP			4'h9
`define	UART_START_BIT				1'b0
`define	UART_STOP_BIT					1'b1


//general
`define	ENABLE								1'b1
`define	DISABLE								1'b0
`define	ENABLE_								1'b0
`define	DISABLE_							1'b1
`define	BYTE_DATA_W						8	
`define	ByteDataBus						7:0	
`define	BYTE_MSB							7	
`define	WORD_DATA_W						32	
`define	WordDataBus						31:0
`define	LSB										0	
`define	LOW										1'b0

//`define	T_1b_2b								0:0
`define	T_1b_2b								1:0