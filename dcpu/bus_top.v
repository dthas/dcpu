 `include "defines.v"

module	bus_top(
	input		wire									clk,
	input		wire									rst,
	
	//bus_master
	input		wire[`WordAddrBus]		m0_addr,
	input		wire									m0_as,
	input		wire									m0_rw,	
	input		wire[`WordDataBus]		m0_data_i,
	
	input		wire[`WordAddrBus]		m1_addr,
	input		wire									m1_as,
	input		wire									m1_rw,	
	input		wire[`WordDataBus]		m1_data_i,
	
	input		wire[`WordAddrBus]		m2_addr,
	input		wire									m2_as,
	input		wire									m2_rw,	
	input		wire[`WordDataBus]		m2_data_i,
	
	input		wire[`WordAddrBus]		m3_addr,
	input		wire									m3_as,
	input		wire									m3_rw,	
	input		wire[`WordDataBus]		m3_data_i,
	
	output	wire[`WordAddrBus]		m_addr,
	output	wire									m_as,
	output	wire									m_rw,
	output	wire[`WordDataBus]		m_data_o,
	
	//bus_slave	
	input		wire									s0_ready,
	input		wire[`WordDataBus]		s0_data_i,	
	
	input		wire									s1_ready,
	input		wire[`WordDataBus]		s1_data_i,
	
	input		wire									s2_ready,
	input		wire[`WordDataBus]		s2_data_i,
	
	input		wire									s3_ready,
	input		wire[`WordDataBus]		s3_data_i,
	
	input		wire									s4_ready,
	input		wire[`WordDataBus]		s4_data_i,
	
	input		wire									s5_ready,
	input		wire[`WordDataBus]		s5_data_i,
	
	input		wire									s6_ready,
	input		wire[`WordDataBus]		s6_data_i,
	
	input		wire									s7_ready,
	input		wire[`WordDataBus]		s7_data_i,
	
	output	wire									s_ready,
	output	wire[`WordDataBus]		s_data_o,
	
	//bus ctrl
	input		wire									m0_req,
	input		wire									m1_req,
	input		wire									m2_req,
	input		wire									m3_req,	
	
	output	wire									m0_get,
	output	wire									m1_get,
	output	wire									m2_get,
	output	wire									m3_get,
	
	//bus dec
	input		wire[`WordAddrBus]		s_addr,
	
	output	wire									s0_cs,
	output	wire									s1_cs,
	output	wire									s2_cs,
	output	wire									s3_cs,
	output	wire									s4_cs,
	output	wire									s5_cs,
	output	wire									s6_cs,
	output	wire									s7_cs
	
);


bus_dec bus_dec0( 
							.s_addr(s_addr), 
							.s0_cs(s0_cs), 
							.s1_cs(s1_cs), 
							.s2_cs(s2_cs), 
							.s3_cs(s3_cs),
							.s4_cs(s4_cs), 
							.s5_cs(s5_cs), 
							.s6_cs(s6_cs), 
							.s7_cs(s7_cs)
							);
							
bus_ctrl bus_ctrl0( 
							.clk(clk),
							.rst(rst),							 
							.m0_req(m0_req), 
							.m1_req(m1_req), 
							.m2_req(m2_req), 
							.m3_req(m3_req),
							.m0_get(m0_get), 
							.m1_get(m1_get), 
							.m2_get(m2_get), 
							.m3_get(m3_get) 
							);
							
bus_master bus_master0( 							
							.m0_addr(m0_addr), 
							.m0_as(m0_as), 
							.m0_rw(m0_rw), 
							.m0_get(m0_get), 
							.m0_data_i(m0_data_i),
							.m1_addr(m1_addr), 
							.m1_as(m1_as), 
							.m1_rw(m1_rw), 
							.m1_get(m1_get), 
							.m1_data_i(m1_data_i),
							.m2_addr(m2_addr), 
							.m2_as(m2_as), 
							.m2_rw(m2_rw), 
							.m2_get(m2_get), 
							.m2_data_i(m2_data_i),
							.m3_addr(m3_addr), 
							.m3_as(m3_as), 
							.m3_rw(m3_rw), 
							.m3_get(m3_get), 
							.m3_data_i(m3_data_i),
							.m_addr(m_addr), 
							.m_as(m_as), 
							.m_rw(m_rw), 
							.m_data_o(m_data_o)
							);
							
bus_slave	bus_slave0(
							.s0_cs(s0_cs), 
							.s0_ready(s0_ready), 
							.s0_data_i(s0_data_i),
							.s1_cs(s1_cs), 
							.s1_ready(s1_ready), 
							.s1_data_i(s1_data_i),
							.s2_cs(s2_cs), 
							.s2_ready(s2_ready), 
							.s2_data_i(s2_data_i),
							.s3_cs(s3_cs), 
							.s3_ready(s3_ready), 
							.s3_data_i(s3_data_i),
							.s4_cs(s4_cs), 
							.s4_ready(s4_ready), 
							.s4_data_i(s4_data_i),
							.s5_cs(s5_cs), 
							.s5_ready(s5_ready), 
							.s5_data_i(s5_data_i),
							.s6_cs(s6_cs), 
							.s6_ready(s6_ready), 
							.s6_data_i(s6_data_i),
							.s7_cs(s7_cs), 
							.s7_ready(s7_ready), 
							.s7_data_i(s7_data_i),
							.s_ready(s_ready), 
							.s_data_o(s_data_o)
							);

endmodule