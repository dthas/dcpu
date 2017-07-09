
`include "defines.v"


module	dcpu(
	input		wire										clk,
	input		wire										rst,
	
	input wire                  		uart_in,
	output wire                   	uart_out,
	
	//GPIO??
	input wire[`GPIO_IN_CH-1:0]     gpio_i,
	output wire[`GPIO_OUT_CH-1:0]   gpio_o,
	
	input wire[7:0]           			flash_data_i,
	//output wire[31:0]         			flash_addr_o,
	output wire[21:0]         			flash_addr_o,
	output wire               			flash_we_o,
	output wire               			flash_rst_o,
	output wire               			flash_oe_o,
	output wire               			flash_ce_o, 
                            			
	output wire 										sdr_clk_o,
  output wire 										sdr_cs_n_o,
  output wire 										sdr_cke_o,
  output wire 										sdr_ras_n_o,
  output wire 										sdr_cas_n_o,
  output wire 										sdr_we_n_o,
  output wire[1:0] 								sdr_dqm_o,
  output wire[1:0] 								sdr_ba_o,
  output wire[12:0] 							sdr_addr_o,
  inout wire[15:0] 								sdr_dq_io
);

  wire[5:0] int;
  wire timer_int;
  wire gpio_int;
  wire uart_int;
  wire[31:0] gpio_i_temp;
  
	//bus_master
	wire[`WordAddrBus]		m0_addr;
	wire									m0_as;
	wire									m0_rw;
	wire									m0_get;
	wire[`WordDataBus]		m0_data_i;
	
	wire[`WordAddrBus]		m1_addr;
	wire									m1_as;
	wire									m1_rw;
	wire									m1_get;
	wire[`WordDataBus]		m1_data_i;
	
	wire[`WordAddrBus]		m2_addr;
	wire									m2_as;
	wire									m2_rw;
	wire									m2_get;
	wire[`WordDataBus]		m2_data_i;
	
	wire[`WordAddrBus]		m3_addr;
	wire									m3_as;
	wire									m3_rw;
	wire									m3_get;
	wire[`WordDataBus]		m3_data_i;
	
	wire[`WordAddrBus]		m_addr;
	wire									m_as;
	wire									m_rw;
	wire[`WordDataBus]		m_data_o;
	
	//bus_slave
	wire									s0_cs;
	wire									s0_ready;
	wire[`WordDataBus]		s0_data_i;
	
	wire									s1_cs;
	wire									s1_ready;
	wire[`WordDataBus]		s1_data_i;
	
	wire									s2_cs;
	wire									s2_ready;
	wire[`WordDataBus]		s2_data_i;
	
	wire									s3_cs;
	wire									s3_ready;
	wire[`WordDataBus]		s3_data_i;
	
	wire									s4_cs;
	wire									s4_ready;
	wire[`WordDataBus]		s4_data_i;
	
	wire									s5_cs;
	wire									s5_ready;
	wire[`WordDataBus]		s5_data_i;
	
	wire									s6_cs;
	wire									s6_ready;
	wire[`WordDataBus]		s6_data_i;
	
	wire									s7_cs;
	wire									s7_ready;
	wire[`WordDataBus]		s7_data_i;
	
	wire									s_ready;
	wire[`WordDataBus]		s_data_o;
	
	//bus ctrl
	wire									m0_req;
	wire									m1_req;
	wire									m2_req;
	wire									m3_req;		
	
		
	//uart
	wire									irq_uart_rx;
	wire									irq_uart_tx;	
	
	
  wire       sdram_init_done;
  
  assign int = {3'b000, gpio_int, uart_int, timer_int};
  assign sdr_clk_o = clk;
  
  
 openmips openmips0(
		.clk(clk),
		.rst(rst),
		
		.int_i(int),
		
		.ibus_rd_data(s_data_o ),
		.ibus_ready(s5_ready ),  
		.ibus_get(m1_get ),    
		.ibus_req(m1_req ),    
		.ibus_addr(m1_addr ),   
		.ibus_as(m1_as ),     
		.ibus_rw(m1_rw ),     
		.ibus_wr_data(m1_data_i ),  	
  
		.dbus_rd_data(s_data_o ),
		.dbus_ready(s3_ready ),  				// uart test
		.dbus_get(m0_get ),    
		.dbus_req(m0_req ),    
		.dbus_addr(m0_addr ),   
		.dbus_as(m0_as ),     
		.dbus_rw(m0_rw ),     
		.dbus_wr_data(m0_data_i ),
	
		.timer_int_o(timer_int)	
	
);




	gpio_top gpio_top0(		
		.clk(clk),
		.rst(rst),		
		.cs(s4_cs),
		.as(m0_as),
		.rw(m0_rw),
		.addr(m_addr[`GpioAddrLoc]),
		.wr_data(m0_data_i),
		.rd_data(s4_data_i),
		.rdy(s4_ready), 
		.gpio_in(gpio_i), 
		.gpio_out(gpio_o)

	);



	

uart_top uart_top0 (		
		.clk(clk),
		.rst(rst),		
		.cs(s3_cs),
		.as(m0_as),
		.rw(m0_rw),
		.addr(m_addr[`UartAddrLoc]),
		.wr_data(m0_data_i),
		.rd_data(s3_data_i),
		.rdy(s3_ready),		
		.irq_rx(irq_uart_rx),
		.irq_tx(irq_uart_tx),		
		.rx(uart_in),
		.tx(uart_out)
	);





	flash_top flash_top0(
    .clk_i(clk),
    .rst_i(rst),
    //.adr_i({m_addr[29:0],2'b00}),
    //.adr_i(m1_addr),
    .adr_i(m_addr),
    .dat_o(s5_data_i),
    .dat_i(s_data_o),
    
   	.stb_i(s5_cs),
		.we_i(m1_rw),			
		.ready_o(s5_ready),   
    
    .flash_adr_o(flash_addr_o),
    .flash_dat_i(flash_data_i),    
    .flash_rst(flash_rst_o),
    .flash_oe(flash_oe_o),
    .flash_ce(flash_ce_o),
    .flash_we(flash_we_o)
  );

/*
  sdrc_top sdrc_top0(
     .cfg_sdr_width(2'b01),
     .cfg_colbits(2'b00),
     
     .wb_rst_i(rst),
     .wb_clk_i(clk),
                    
     .wb_stb_i(m0_as),
     .wb_ack_o(s0_ack_i),
     .wb_addr_i({m_addr[25:2],2'b00}),
     .wb_we_i(m0_rw),
     .wb_dat_i(s_data_o),
     .wb_sel_i(4'b1111),
     .wb_dat_o(s0_data_i),
     .wb_cyc_i(m0_get),
     .wb_cti_i(3'b000),
		
		//Interface to SDRAMs
     .sdram_clk(clk),
     .sdram_resetn(~rst),
     .sdr_cs_n(sdr_cs_n_o),
     .sdr_cke(sdr_cke_o),
     .sdr_ras_n(sdr_ras_n_o),
     .sdr_cas_n(sdr_cas_n_o),
     .sdr_we_n(sdr_we_n_o),
     .sdr_dqm(sdr_dqm_o),
     .sdr_ba(sdr_ba_o),
     .sdr_addr(sdr_addr_o),
     .sdr_dq(sdr_dq_io),
                    
		//Parameters
     .sdr_init_done(sdram_init_done),
     .cfg_req_depth(2'b11),
     .cfg_sdr_en(1'b1),
     .cfg_sdr_mode_reg(13'b0000000110001),
     .cfg_sdr_tras_d(4'b1000),
     .cfg_sdr_trp_d(4'b0010),
     .cfg_sdr_trcd_d(4'b0010),
     .cfg_sdr_cas(3'b100),
     .cfg_sdr_trcar_d(4'b1010),
     .cfg_sdr_twr_d(4'b0010),
     .cfg_sdr_rfsh(12'b011010011000),
	   .cfg_sdr_rfmax(3'b100)
  );
  
 */ 
  
  

	bus_top	bus_top0(
	.clk(clk ),
	.rst(rst ),
	
	//bus_master
	.m0_addr(m0_addr ),
	.m0_as(m0_as ),
	.m0_rw(m0_rw ),
	.m0_data_i(m0_data_i ),
	
	.m1_addr(m1_addr ),
	.m1_as(m1_as ),
	.m1_rw(m1_rw ),
	.m1_data_i(m1_data_i ),
	
	.m2_addr(m2_addr ),
	.m2_as(m2_as ),
	.m2_rw(m2_rw ),
	.m2_data_i(m2_data_i ),
	
	.m3_addr(m3_addr ),
	.m3_as(m3_as ),
	.m3_rw(m3_rw ),
	.m3_data_i(m3_data_i ),
	
	.m_addr(m_addr ),
	.m_as(m_as ),
	.m_rw(m_rw ),
	.m_data_o(m_data_o ),
	
	//bus_slave
	.s0_ready(s0_ready ),
	.s0_data_i(s0_data_i ),
	
	.s1_ready(s1_ready ),
	.s1_data_i(s1_data_i ),
	
	.s2_ready(s2_ready ),
	.s2_data_i(s2_data_i ),
	
	.s3_ready(s3_ready ),
	.s3_data_i(s3_data_i ),
	
	.s4_ready(s4_ready ),
	.s4_data_i(s4_data_i ),
	
	.s5_ready(s5_ready ),
	.s5_data_i(s5_data_i ),
	
	.s6_ready(s6_ready ),
	.s6_data_i(s6_data_i ),
	
	.s7_ready(s7_ready ),
	.s7_data_i(s7_data_i ),
	
	.s_ready(s_ready ),
	.s_data_o(s_data_o ),
	
	//bus ctrl
	.m0_req(m0_req ),
	.m1_req(m1_req ),
	.m2_req(m2_req ),
	.m3_req(m3_req ),	
	
	.m0_get(m0_get ),
	.m1_get(m1_get ),
	.m2_get(m2_get ),
	.m3_get(m3_get ),
	
	//bus dec
	.s_addr(m_addr ),
	
	.s0_cs(s0_cs ),
	.s1_cs(s1_cs ),
	.s2_cs(s2_cs ),
	.s3_cs(s3_cs ),
	.s4_cs(s4_cs ),
	.s5_cs(s5_cs ),
	.s6_cs(s6_cs ),
	.s7_cs(s7_cs )
	
);
	
	
	
	
	
	
	

endmodule