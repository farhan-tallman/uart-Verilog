/*
UART Transmitter code from book
FPGA Prototyping using verilog
listing 8.3

*/

module uart_tx
	#(
	parameter 	DBIT = 8, // # data bits
				SB_TICK = 16 // # of ticks for stop bit
				
	)
	(
	input wire clk, rst,
	input wire tx_start, s_tick,
	input wire [7:0] din,
	output reg tx_done_tick,
	output wire tx
	);
	
	// State symbols declaration
	localparam [1:0]
		IDLE 	= 2'b00,
		START	= 2'b01,
		DATA 	= 2'b10,
		STOP 	= 2'b11;
		
	// Signal declaration
	reg [1:0] current_state, next_state;
	reg [3:0] s_reg , s_next;	// counts the number of ticks 
	reg [2:0] n_reg, n_next;
	reg [7:0] b_reg, b_next;	// holds the data to be transmitted
	reg tx_reg, tx_next;
	
	// body
	// State and data registers
	always@(posedge clk, posedge rst)
		if(rst)
			begin
			current_state <= IDLE;
			s_reg <= 0;
			n_reg <= 0;
			b_reg <= 0;
			tx_reg <= 1'b1;
			end
		else
			begin
			current_state <= next_state;
			s_reg <= s_next;
			n_reg <= n_next;
			b_reg <= b_next;
			tx_reg <= tx_next;
			end
	
	// Next state logic FSM
	always@*
	begin
		next_state = current_state;
		tx_done_tick = 1'b0;
		s_next = s_reg;
		n_next = n_reg;
		b_next = b_reg;
		tx_next = tx_reg;
		case(current_state)
			IDLE:
				begin
				tx_next = 1'b1;
				if(tx_start)
					begin
					next_state = START;
					s_next = 0;
					b_next = din;
					end
				end
			START: // send the start bit
				begin
				tx_next = 1'b0; // send the start bit
				if(s_tick)
					if(s_reg == 15)
						begin
						next_state = DATA;
						s_next = 0;
						n_next = 0;
						end
					else // count 16 ticks of start bit
						s_next = s_reg + 1;
				end //start
			DATA: // send all data
				begin
				tx_next = b_reg[0]; // transmit the LSB of data
				if(s_tick)
					if(s_reg == 15)
						begin
						s_next = 0;
						b_next = b_reg >> 1; // let the next data bit take LSB position
						if(n_reg == (DBIT-1)) // make sure all data bits have been transmitted
							next_state = STOP; 
						else
							n_next = n_reg + 1;	// Counter data bits transmitted till now
						end
					else
						s_next = s_reg + 1; // count number of ticks
				end // DATA
			STOP: // send the stop bit
				begin
				tx_next = 1'b1; // stop bit is 1
				if(s_tick)
					if(s_reg == (SB_TICK-1))
						begin
						next_state = IDLE;
						tx_done_tick = 1'b1;
						end
					else
						s_next = s_reg + 1;
				end
		endcase
	end// next state logic
	
	// output logic
	assign tx = tx_reg;

endmodule