module uart
	#(// default setting 19,200 baud, 8 databits, 1 stop bit
	parameter 	DBIT = 8, // # of data bits
				SB_TICK = 16, // # of ticks for stop bit
				DVSR = 163, // baud rate divisor
							// clk_freq/(16*baud)
				DVSR_BIT = 8, // # bits of DVSR
	)
	(
	input wire clk, rst,
	input wire rd_uart, wr_uart, rx,
	input wire [7:0] w_data,
	output wire tx_full, rx_empty, tx,
	output wire [7:0] r_data
	);
	
	//signal declaration
	wire tick, rx_done_tick, tx_done_tick;
	wire tx_empty, tx_fifo_not_empty;
	wire [7:0] tx_fifo_out, rx_data_out;
	
	//body
	