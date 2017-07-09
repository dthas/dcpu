 `include "defines.v"

module	bus_master(
	input		wire[`WordAddrBus]		m0_addr,
	input		wire									m0_as,
	input		wire									m0_rw,
	input		wire									m0_get,
	input		wire[`WordDataBus]		m0_data_i,
	
	input		wire[`WordAddrBus]		m1_addr,
	input		wire									m1_as,
	input		wire									m1_rw,
	input		wire									m1_get,
	input		wire[`WordDataBus]		m1_data_i,
	
	input		wire[`WordAddrBus]		m2_addr,
	input		wire									m2_as,
	input		wire									m2_rw,
	input		wire									m2_get,
	input		wire[`WordDataBus]		m2_data_i,
	
	input		wire[`WordAddrBus]		m3_addr,
	input		wire									m3_as,
	input		wire									m3_rw,
	input		wire									m3_get,
	input		wire[`WordDataBus]		m3_data_i,
	
	output	reg[`WordAddrBus]			m_addr,
	output	reg										m_as,
	output	reg										m_rw,
	output	reg[`WordDataBus]			m_data_o
	
);


	always	@ (*)	begin
		if(m0_get == `YES) begin
				m_addr		= m0_addr;
				m_as			= m0_as;
				m_rw			= m0_rw;
				m_data_o	= m0_data_i;
		end else	if(m1_get == `YES) begin
				m_addr		= m1_addr;
				m_as			= m1_as;
				m_rw			= m1_rw;
				m_data_o	= m1_data_i;
		end else	if(m2_get == `YES) begin
				m_addr		= m2_addr;
				m_as			= m2_as;
				m_rw			= m2_rw;
				m_data_o	= m2_data_i;	
		end else	if(m3_get == `YES) begin
				m_addr		= m3_addr;
				m_as			= m3_as;
				m_rw			= m3_rw;
				m_data_o	= m3_data_i;	
		end else	begin
				m_addr		= `WordAddrWith'h0;
				m_as			= `NO;
				m_rw			= `READ;
				m_data_o	= `WordDataWith'h0;	
		end
	end

endmodule