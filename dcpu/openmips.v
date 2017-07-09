`include "defines.v"

module	openmips(
	input		wire									clk,
	input		wire									rst,	
	
	input wire[5:0]           		int_i,	
	
	//指令wishbone总线
	input	wire	[`WordDataBus]		ibus_rd_data,
	input	wire										ibus_ready,
	input	wire										ibus_get,
	output	wire									ibus_req,
	output	wire[`WordAddrBus]		ibus_addr,
	output	wire									ibus_as,
	output	wire									ibus_rw,
	output	wire[`WordDataBus]		ibus_wr_data, 
	
  //数据wishbone总线
	input	wire	[`WordDataBus]		dbus_rd_data,
	input	wire										dbus_ready,
	input	wire										dbus_get,
	output	wire									dbus_req,
	output	wire[`WordAddrBus]		dbus_addr,
	output	wire									dbus_as,
	output	wire									dbus_rw,
	output	wire[`WordDataBus]		dbus_wr_data,
		
	output wire              			timer_int_o	
	
);

	wire 												flush;
	wire[`InstBus] 							inst_1_i;
	
	wire[`InstAddrBus]					pc;
	wire[`InstAddrBus]					id_pc_i;
	wire[`InstBus]							id_inst_i;
	
	wire[`AluOpBus]							id_aluop_o;
	wire[`AluSelBus]						id_alusel_o;
	wire[`RegBus]								id_reg1_o;
	wire[`RegBus]								id_reg2_o;
	wire												id_wreg_o;
	wire[`RegAddrBus]						id_wd_o;
	
	wire[`AluOpBus]							ex_aluop_i;
	wire[`AluSelBus]						ex_alusel_i;
	wire[`RegBus]								ex_reg1_i;
	wire[`RegBus]								ex_reg2_i;
	wire												ex_wreg_i;
	wire[`RegAddrBus]						ex_wd_i; 	
	
	wire												ex_wreg_o;
	wire[`RegAddrBus]						ex_wd_o;
	wire[`RegBus]								ex_wdata_o;	
	
	wire[`RegBus]								ex_reg_val_o;
	wire[`AluOpBus]							ex_reg_aluop_o;
	wire												ex_reg_fl_o;	                    				
	wire[`RegAddrBus]						ex_reg_dest_addr_o;	                    				
	wire[`AluSelBus]						ex_reg_alusel_o;
	
	
	wire												mem_wreg_i;
	wire[`RegAddrBus]						mem_wd_i;
	wire[`RegBus]								mem_wdata_i;  
	wire												mem_wreg_o;
	wire[`RegAddrBus]						mem_wd_o;
	wire[`RegBus]								mem_wdata_o;                    				
	                    				
	wire												wb_wreg_i;
	wire[`RegAddrBus]						wb_wd_i;
	wire[`RegBus]								wb_wdata_i;
	                    				
	wire												reg1_read;	
	wire												reg2_read;	
	wire[`RegBus]								reg1_data;	                    				
	wire[`RegBus]								reg2_data;
	wire[`RegAddrBus]						reg1_addr;
	wire[`RegAddrBus]						reg2_addr;
	                    				
	wire[1:0] 									cnt_o;
	wire[1:0] 									cnt_i;	                    				
	                    				
	wire[5:0] 									stall;
	wire 												stallreq_from_id;	
	wire 												stallreq_from_ex;
	wire												stallreq_from_fi;	
	wire 												stallreq_from_mem;
	wire 												stallreq_from_if;
		                    				
	wire[`RegBus]								div_s_o;	
	wire[`RegBus]								div_b_o;	
	wire[2:0]										state_o;
	wire												flg_start_div;			
	wire[`RegBus]								res_o;	
	
	wire[`InstAddrBus]					jmp_addr_o;
	wire												jmp_fl_o;
	                    				
	wire[`InstAddrBus]					mem_addr_o_t;
	wire[`InstAddrBus]					mem_data_o_t;
	wire[`AluOpBus]							aluop_o_t;
	                    				
	wire[`AluOpBus]							ex_aluop_o_t;
	wire[`InstAddrBus]					ex_mem_addr_o_t;
	wire[`InstAddrBus]					ex_mem_data_o_t; 
	
	wire[`InstAddrBus]					id_pc_o;
	wire[`InstAddrBus]					ex_pc_i;
	                      			
	wire[`InstAddrBus]					ret_addr_o;
	wire												ret_fl_o;	
	
	wire[`RegBus64]							idt_i;
	wire[`RegBus64]							gdt_i;
	wire[`RegBus64]							ldt_i;
	wire[`RegBus64]							tr_i;	
	wire[`RegBus64]							idt_o;
	wire[`RegBus64]							gdt_o;
	wire[`RegBus64]							ldt_o;
	wire[`RegBus64]							tr_o;
	
	wire 												we64;
	
	wire[`RegBus64]							ex_idt_o;
	wire[`RegBus64]							ex_gdt_o;
	wire[`RegBus64]							ex_ldt_o;
	wire[`RegBus64]							ex_tr_o;
	                 	
	wire[`RegBus64]							ex_mem_idt_o;
	wire[`RegBus64]							ex_mem_gdt_o;
	wire[`RegBus64]							ex_mem_ldt_o;
	wire[`RegBus64]							ex_mem_tr_o;	                 	
	                 	
	wire[`RegBus64]							mem_idt_o;
	wire[`RegBus64]							mem_gdt_o;
	wire[`RegBus64]							mem_ldt_o;
	wire[`RegBus64]							mem_tr_o;	
	                 	
	wire[`RegBus64]							wb_idt_o;
	wire[`RegBus64]							wb_gdt_o;
	wire[`RegBus64]							wb_ldt_o;
	wire[`RegBus64]							wb_tr_o;
	
	wire              					ex_w_reg64_o;	
	wire              					ex_mem_w_reg64_o;	
	wire              					mem_w_reg64_o;		
	wire              					wb_w_reg64_o;
	
	wire[`InstAddrBus]					mem_addr_j_o_t;
	wire[`InstAddrBus]					mem_data_j_o_t;
	                    				
	wire[`InstAddrBus]					ex_mem_addr_j_o_t;
	wire[`InstAddrBus]					ex_mem_data_j_o_t;
	                    				
	wire[`ByteWidth]						exp_no_o;
	wire[`InstAddrBus]					exp_retpc_o;
	                    				
	wire[`ByteWidth]						ex_mem_exp_no_o_t;	                    				
	wire[`InstAddrBus]					ex_mem_exp_retpc_o_t;
	
	wire[`InstAddrBus]					mem_exp_retaddr_o_t;
	wire												mem_exp_fl_t;
	wire[`InstAddrBus]					mem_exp_pc_to_o_t;
	                      			
	wire[`InstAddrBus]					exp_pc_t;	                      			
	wire[`ByteWidth]						data_i_t;
	wire[`ByteWidth]						port_i_t;	                      			
	wire[`WordWidth]      			int_status_t;
	wire[`RegBus] 							count_o;
	
				
	//连接数据存储器data_ram
	wire[`RegBus]           		ram_data_i;
	wire[`RegBus]           		ram_addr_o;
	wire[`RegBus]           		ram_data_o;
	wire                    		ram_we_o;
	wire[3:0]               		ram_sel_o;
	wire			              		ram_ce_o;
	
	wire												ram_we_o64;
	wire[7:0]										ram_sel_o64;	
	wire[`DataBus64]						ram_data_i64;
	wire[`DataBus64]						ram_data_o64;		                    				
	wire												ram_flg64;	
	wire 												rom_ce;

	pc_reg pc_reg0(
								.clk(clk), 
								.rst(rst), 
								.stall(stall),								
								.jmp_addr_pc(jmp_addr_o),
								.jmp_fl_pc(jmp_fl_o),
								.ret_addr_pc(ret_addr_o),
								.ret_fl_pc(ret_fl_o),
								.exp_addr_pc(mem_exp_pc_to_o_t),
								.exp_fl_pc(mem_exp_fl_t),
								.flush(flush),
								.pc(pc), 
								.ce(rom_ce)								
								);	
		
	if_id	if_id0( 
							.clk(clk), 
							.rst(rst), 
							.stall(stall),							
							.flush(flush),							
							.if_pc(pc),	
							.if_inst(inst_1_i),							
							.id_pc(id_pc_i), 
							.id_inst(id_inst_i)
							);
	
	id id0( 
						.rst(rst), 
						.pc_i(id_pc_i), 
						.inst_i(id_inst_i), 
						.reg1_data_i(reg1_data), 
						.reg2_data_i(reg2_data), 
						.ex_wreg_i(ex_wreg_o), 
						.ex_wdata_i(ex_wdata_o), 
						.ex_wd_i(ex_wd_o),
						.mem_wreg_i(mem_wreg_o), 
						.mem_wdata_i(mem_wdata_o), 
						.mem_wd_i(mem_wd_o),
						.reg1_read_o(reg1_read),
						.reg2_read_o(reg2_read), 
						.reg1_addr_o(reg1_addr), 
						.reg2_addr_o(reg2_addr), 
						.aluop_o(id_aluop_o), 
						.alusel_o(id_alusel_o),
						.reg1_o(id_reg1_o), 
						.reg2_o(id_reg2_o), 
						.wd_o(id_wd_o), 
						.wreg_o(id_wreg_o),
						.stallreq(stallreq_from_id),
						//---------------------------------------------------
						//modi on 2015-12-22
						//.stallreq_to_id(stallreq_to_id),
						//---------------------------------------------------
						.ex_reg_fl(ex_reg_fl_o),
						.ex_reg_val(ex_reg_val_o),
						.ex_reg_aluop(ex_reg_aluop_o),
						.ex_reg_alusel(ex_reg_alusel_o),
						.ex_reg_dest_addr(ex_reg_dest_addr_o),
						.pc_o(id_pc_o)
						);
						
	regfile regfile1( 
						.clk(clk), 
						.rst(rst), 
						.we(wb_wreg_i), 
						.waddr(wb_wd_i), 
						.wdata(wb_wdata_i), 
						.re1(reg1_read), 
						.raddr1(reg1_addr),
						.rdata1(reg1_data), 
						.re2(reg2_read), 
						.raddr2(reg2_addr), 
						.rdata2(reg2_data)
						);
											
	id_ex	id_ex0( 
						.clk(clk), 
						.rst(rst), 
						.stall(stall),						
						.flush(flush),
						.id_aluop(id_aluop_o), 
						.id_alusel(id_alusel_o), 
						.id_reg1(id_reg1_o), 
						.id_reg2(id_reg2_o), 
						.id_wd(id_wd_o), 
						.id_wreg(id_wreg_o), 
						.ex_aluop(ex_aluop_i), 
						.ex_alusel(ex_alusel_i), 
						.ex_reg1(ex_reg1_i), 
						.ex_reg2(ex_reg2_i),
						.ex_wd(ex_wd_i), 
						.ex_wreg(ex_wreg_i),
						
						.id_pc_i(id_pc_o),
						.ex_pc_o(ex_pc_i)
						);
									
	ex	ex0( 
						.rst(rst), 
						.aluop_i(ex_aluop_i), 
						.alusel_i(ex_alusel_i), 
						.reg1_i(ex_reg1_i), 
						.reg2_i(ex_reg2_i), 
						.wd_i(ex_wd_i), 
						.wreg_i(ex_wreg_i),
						.wd_o(ex_wd_o),  
						.wreg_o(ex_wreg_o), 
						.wdata_o(ex_wdata_o),						
						.cnt_i(cnt_i),
						.cnt_o(cnt_o),						
						.stallreq(stallreq_from_ex),
						.div_state_i(state_o),
						.div_res_i(res_o),
						.start_div_o(flg_start_div_o),
						.div_s_o(div_s_o),					//被除数
						.div_b_o(div_b_o),					//除数
						.reg_val(ex_reg_val_o),
						.reg_aluop(ex_reg_aluop_o),
						.reg_alusel(ex_reg_alusel_o),
						.reg_fl(ex_reg_fl_o),
						.reg_dest_addr_o(ex_reg_dest_addr_o),
						.jmp_addr(jmp_addr_o),
						.jmp_fl(jmp_fl_o),						
						.mem_addr_o(mem_addr_o_t),
						.mem_data_o(mem_data_o_t),
						.mem_aluop_o(aluop_o_t),						
						.mem_pc_i(ex_pc_i),						
						.mem_addr_j_o(mem_addr_j_o_t),
						.mem_data_j_o(mem_data_j_o_t),						
						.ex_idt_i(idt_o),
						.ex_gdt_i(gdt_o),
						.ex_ldt_i(ldt_o),
						.ex_tr_i(tr_o),						
						.ex_idt_o(ex_idt_o),
						.ex_gdt_o(ex_gdt_o),
						.ex_ldt_o(ex_ldt_o),
						.ex_tr_o (ex_tr_o),						
						.ex_w_reg64_o(ex_w_reg64_o),	
						.mem_idt_i(mem_idt_o),
						.mem_gdt_i(mem_gdt_o),
						.mem_ldt_i(mem_ldt_o),
						.mem_tr_i(mem_tr_o), 
						.mem_w_reg64_i(mem_w_reg64_o),						
						.wb_idt_i(wb_idt_o),
						.wb_gdt_i(wb_gdt_o),
						.wb_ldt_i(wb_ldt_o),
						.wb_tr_i(wb_tr_o),
						.wb_w_reg64_i(wb_w_reg64_o),						
						.exp_no(exp_no_o),
						.exp_retpc(exp_retpc_o),						
						.timer_int_o(timer_int_o),
						.int_status_i(int_status_t)						
						);
						
	ex_mem	ex_mem0( 
						.clk(clk), 
						.rst(rst), 
						.stall(stall),						
						.flush(flush),
						.ex_wd(ex_wd_o), 
						.ex_wreg(ex_wreg_o), 
						.ex_wdata(ex_wdata_o), 
						.ex_mem_aluop_i(aluop_o_t),
						.ex_mem_addr_i(mem_addr_o_t),
						.ex_mem_data_i(mem_data_o_t),						
						.ex_mem_aluop_o(ex_aluop_o_t),
						.ex_mem_addr_o(ex_mem_addr_o_t),
						.ex_mem_data_o(ex_mem_data_o_t),						
						.ex_mem_idt_i(ex_idt_o),
						.ex_mem_gdt_i(ex_gdt_o),
						.ex_mem_ldt_i(ex_ldt_o),
						.ex_mem_tr_i(ex_tr_o), 						
						.ex_mem_idt_o(ex_mem_idt_o),
						.ex_mem_gdt_o(ex_mem_gdt_o),
						.ex_mem_ldt_o(ex_mem_ldt_o),
						.ex_mem_tr_o(ex_mem_tr_o),						
						.ex_mem_w_reg64_i(ex_w_reg64_o), 
						.ex_mem_w_reg64_o(ex_mem_w_reg64_o),
						.ex_mem_addr_j_i(mem_addr_j_o_t),
						.ex_mem_data_j_i(mem_data_j_o_t),						
						.ex_mem_addr_j_o(ex_mem_addr_j_o_t),
						.ex_mem_data_j_o(ex_mem_data_j_o_t),
						.ex_mem_exp_no_i(exp_no_o),
						.ex_mem_exp_no_o(ex_mem_exp_no_o_t),						
						.ex_mem_exp_retpc_i(ex_pc_i),
						.ex_mem_exp_retpc_o(ex_mem_exp_retpc_o_t),
						.mem_wd(mem_wd_i), 
						.mem_wreg(mem_wreg_i),
						.mem_wdata(mem_wdata_i),
						.cnt_i(cnt_o),	
						.cnt_o(cnt_i)
						);
										
	mem	mem0( 
						.rst(rst), 
						.wd_i(mem_wd_i), 
						.wreg_i(mem_wreg_i), 
						.wdata_i(mem_wdata_i),
						.m_mem_aluop_i(ex_aluop_o_t),
						.m_mem_addr_i(ex_mem_addr_o_t),
						.m_mem_data_i(ex_mem_data_o_t),						
						.dm_data_i(ram_data_i),
						.dm_we(ram_we_o),
						.dm_addr(ram_addr_o),
						.dm_sel(ram_sel_o),	
						.dm_data_o(ram_data_o),
						.dm_ce(ram_ce_o),
						.ret_addr(ret_addr_o),
						.ret_fl(ret_fl_o),
						.dm_we64(ram_we_o64),
						.dm_sel64(ram_sel_o64),	
						.dm_data_i64(ram_data_i64),
						.dm_data_o64(ram_data_o64),							
						.m_mem_idt_i(ex_mem_idt_o),
						.m_mem_gdt_i(ex_mem_gdt_o),
						.m_mem_ldt_i(ex_mem_ldt_o),
						.m_mem_tr_i(ex_mem_tr_o),						
						.m_mem_idt_o(mem_idt_o),
						.m_mem_gdt_o(mem_gdt_o),
						.m_mem_ldt_o(mem_ldt_o),
						.m_mem_tr_o (mem_tr_o), 						
						.m_mem_w_reg64_i(ex_mem_w_reg64_o),
						.m_mem_w_reg64_o(mem_w_reg64_o),
						.dm_flg64(ram_flg64),
						.m_mem_addr_j_i(ex_mem_addr_j_o_t),
						.m_mem_data_j_i(ex_mem_data_j_o_t),
						.mem_exp_no_i(ex_mem_exp_no_o_t),	    
						.mem_exp_pc_i(ex_mem_exp_retpc_o_t),     
						.mem_exp_pc_to_i(exp_pc_t),  
						.mem_exp_retaddr_o(mem_exp_retaddr_o_t),
						.mem_exp_fl(mem_exp_fl_t),       
						.mem_exp_pc_to_o(mem_exp_pc_to_o_t), 
						.wd_o(mem_wd_o), 
						.wreg_o(mem_wreg_o), 
						.wdata_o(mem_wdata_o)
						);
	
	mem_wb	mem_wb0( 
						.clk(clk), 
						.rst(rst), 
						.stall(stall),						
						.flush(flush),						
						.mem_wd(mem_wd_o), 
						.mem_wreg(mem_wreg_o), 
						.mem_wdata(mem_wdata_o), 
						.mem_wb_idt_i(mem_idt_o),
						.mem_wb_gdt_i(mem_gdt_o),
						.mem_wb_ldt_i(mem_ldt_o),
						.mem_wb_tr_i(mem_tr_o),						
						.mem_wb_idt_o(wb_idt_o),
						.mem_wb_gdt_o(wb_gdt_o),
						.mem_wb_ldt_o(wb_ldt_o),
						.mem_wb_tr_o(wb_tr_o),						
						.mem_wb_reg64_i(mem_w_reg64_o), 
						.mem_wb_reg64_o(wb_w_reg64_o), 
						.wb_wd(wb_wd_i),
						.wb_wreg(wb_wreg_i), 
						.wb_wdata(wb_wdata_i)
						);
	
ctrl ctrl0(
		.rst(rst),	
		.stallreq_from_id(stallreq_from_id),
		.stallreq_from_ex(stallreq_from_ex),	
		.stallreq_from_if(stallreq_from_if),
		.stallreq_from_mem(stallreq_from_mem),
		//---------------------------------------------------
		// modi on 2015-12-22
		//.stallreq_to_id(stallreq_to_id),	
		//---------------------------------------------------	
		.stallreq_from_fi(stallreq_from_fi),
		.stall(stall)       	
	);
	
	
div	div0(
	.clk(clk),
	.rst(rst),
	.div_s(div_s_o),
	.div_b(div_b_o),
	.flg_start_div(flg_start_div_o),
	.state(state_o),
	.res(res_o)					//除法运算结果
);

sys64b_reg sys64b_reg0(

	.clk(clk),
	.rst(rst),
	.we(wb_w_reg64_o),
	.idt_i(wb_idt_o),
	.gdt_i(wb_gdt_o),
	.ldt_i(wb_ldt_o),
	.tr_i(wb_tr_o),
	.idt_o(idt_o),
	.gdt_o(gdt_o),
	.ldt_o(ldt_o),
	.tr_o(tr_o)
	
);

expt expt0(
	.clk(clk),
	.rst(rst),
	.exp_no_i(ex_mem_exp_no_o_t),
	.exp_pc(exp_pc_t),
	.flush(flush),
	.int_i(int_i),
	.timer_int_o(timer_int_o),
	.count_o(count_o)
);

C8259A	C8259A0(
	.clk(clk),
	.rst(rst),	
	.data_i(data_i_t),
	.port_i(port_i_t),	
	.int_status(int_status_t)	
);



	bus_if dbus_if(
		.clk(clk),
		.rst(rst),
	
		//来自控制模块ctrl
		.stall_i(stall),
		.flush_i(flush),
	
		//CPU侧读写操作信息
		.cpu_ce_i(ram_ce_o),
		.cpu_data_i(ram_data_o),
		.cpu_addr_i(ram_addr_o),
		.cpu_we_i(ram_we_o),
		.cpu_sel_i(ram_sel_o),
		.cpu_data_o(ram_data_i),
		
		.bus_rd_data(dbus_rd_data ),
		.bus_ready(dbus_ready ), 
		.bus_get(dbus_get ),  
		.bus_req(dbus_req ),  
		.bus_addr(dbus_addr ), 
		.bus_as(dbus_as ),  
		.bus_rw(dbus_rw ),  
		.bus_wr_data(dbus_wr_data ),
		
		.stallreq(stallreq_from_mem)	       
	
);	


	bus_if ibus_if(
		.clk(clk),
		.rst(rst),
	
		//来自控制模块ctrl
		.stall_i(stall),
		.flush_i(flush),
	
		//CPU侧读写操作信息
		.cpu_ce_i(rom_ce),		
		.cpu_data_i(32'h00000000),
		.cpu_addr_i(pc),
		.cpu_we_i(1'b0),
		.cpu_sel_i(4'b1111),
		.cpu_data_o(inst_1_i),		
		
		.bus_rd_data(ibus_rd_data ),
		.bus_ready(ibus_ready ), 
		.bus_get(ibus_get ),  
		.bus_req(ibus_req ),  
		.bus_addr(ibus_addr ), 
		.bus_as(ibus_as ),  
		.bus_rw(ibus_rw ),  
		.bus_wr_data(ibus_wr_data ),
		
		.stallreq(stallreq_from_if)	       
	
);	 

endmodule