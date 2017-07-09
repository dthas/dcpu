`include "defines.v"

`include "timescale.v"

module	uart_ctrl(
		input	wire				clk,
		input	wire				rst,

		input	wire				cs,
		input	wire				as,
		input	wire				rw,
		input	wire	[`UartAddrBus]		addr,		
		input	wire	[`WordDataBus]		wr_data,
		output	reg	[`WordDataBus]		rd_data,
		output	reg				rdy,

		output	reg				irq_rx,
		output	reg				irq_tx,

		input	wire				rx_busy,
		input	wire				rx_end,
		input	wire	[`ByteDataBus]		rx_data,

		input	wire				tx_busy,
		input	wire				tx_end,
		output	reg				tx_start,
		output	reg	[`ByteDataBus]		tx_data		
		);

	//===========================================================================
	// internal
	//===========================================================================
	reg	[`ByteDataBus]		rx_buf;

	//===========================================================================
	// sending logic
	//===========================================================================
	always @(posedge clk) begin
		if(rst == `RstEnable) begin
			rd_data		<= #1 `WORD_DATA_W'h0;
			rdy		<= #1 `DISABLE_;
			irq_rx		<= #1 `DISABLE;
			irq_tx		<= #1 `DISABLE;
			rx_buf		<= #1 `BYTE_DATA_W'h0;
			tx_start	<= #1 `DISABLE;
			tx_data		<= #1 `BYTE_DATA_W'h0;

		end else begin
			//-----------------------------------------------------------------------------
			// build ready signal
			//-----------------------------------------------------------------------------
			if((cs == `ENABLE_) && (as == `ENABLE_)) begin
				rdy		<= #1 `ENABLE_;
			end else begin
				rdy		<= #1 `DISABLE_;
			end

			//-----------------------------------------------------------------------------
			// read access
			//-----------------------------------------------------------------------------
			if((cs == `ENABLE_) && (as == `ENABLE_) && (rw == `READ)) begin
				case (addr)
					`UART_ADDR_STATUS:	begin
						rd_data		<= #1 {{ `WORD_DATA_W-4{1'b0}}, tx_busy, rx_busy, irq_tx, irq_rx};
					end

					`UART_ADDR_DATA:	begin
						rd_data		<= #1 {{ `BYTE_DATA_W*2{1'b0}}, rx_buf};
					end
				endcase
			end else begin
				rd_data		<= #1 `WORD_DATA_W'h0;
			end

			//-----------------------------------------------------------------------------
			// write access: control reg 0
			//-----------------------------------------------------------------------------
			if(tx_end == `ENABLE) begin
				irq_tx	<= #1 `ENABLE;
			end else if((cs == `ENABLE_) && (as == `ENABLE_) && (rw == `WRITE) && (addr == `UART_ADDR_STATUS)) begin
				irq_tx	<= #1 wr_data[`UartCtrlIrqTx];
			end

			if(rx_end == `ENABLE) begin
				irq_rx	<= #1 `ENABLE;
			end else if((cs == `ENABLE_) && (as == `ENABLE_) && (rw == `WRITE) && (addr == `UART_ADDR_STATUS)) begin
				irq_rx	<= #1 wr_data[`UartCtrlIrqRx];
			end

			//-----------------------------------------------------------------------------
			// write access: control reg 1
			//-----------------------------------------------------------------------------
			if((cs == `ENABLE_) && (as == `ENABLE_) && (rw == `WRITE) && (addr == `UART_ADDR_DATA)) begin
				tx_start	<= #1 `ENABLE;
				tx_data		<= #1 wr_data[`BYTE_MSB:`LSB];
			end else begin
				tx_start	<= #1 `DISABLE;
				tx_data		<= #1 `BYTE_DATA_W'h0;
			end

			//-----------------------------------------------------------------------------
			// receive data
			//-----------------------------------------------------------------------------
			if(rx_end == `ENABLE) begin
				rx_buf		<= #1 rx_data;
			end		
		end
	end
	

endmodule
