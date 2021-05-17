/*
Code from FPGA prototyping with verilog examples
Chapter 8, Listing 8.1

*/

module uart_rx
	#(
	parameter DBIT = 8, // # of data bits
	parameter SB_TICK = 16 // # of ticks for stop bit
	)
	(
	input wire clk, rst,
	input wire rx, s_tick,
	output reg rx_done_tick,
	output wire [7:0] dout
	);
	
	// States
	localparam [1:0]
		IDLE = 2'd0,
		START = 2'd1,
		DATA = 2'd2,
		STOP = 2'd3;
		
	// local signals
	reg [1:0] current_state, next_state;
	reg [3:0] s_reg, s_next;
	reg [2:0] n_reg, n_next;
	reg [7:0] b_reg, b_next;
	
	// Physical Registers
	always@(posedge clk, posedge rst)
		if(rst)
			begin
				current_state <= IDLE;
				s_reg <= 0;
				n_reg <= 0;
				b_reg <= 0;
			end
		else
			begin
				current_state <= next_state;
				s_reg <= s_next;
				n_reg <= n_next;
				b_reg <= b_next;
			end
			
	// FSM Next state logic
	always@*
	begin
		next_state = current_state;
		rx_done_tick = 1'b0;
		s_next = s_reg;
		n_next = n_reg;
		b_next = b_reg;
		
		case(current_state)
			IDLE:
				if(~rx)
				begin
					next_state = START;
					s_next = 0;
				end
			START:
				if(s_tick)
					if(s_reg == 7)
					begin
						next_state = DATA;
						s_next = 0;
						n_next = 0;
					end
				else
					s_next = s_reg +1;
			DATA:
				if(s_tick)
					if(s_reg == 15)
					begin
						s_next = 0;
						b_next = {rx, b_reg[7:1]};
						if(n_reg == (DBIT -1))
							next_state = STOP;
						else
							n_next = n_reg + 1;
					end
				else
					s_next = s_reg + 1;
			STOP:
				if(s_tick)
					if(s_reg == (SB_TICK - 1))
					begin
						next_state = IDLE;
						rx_done_tick = 1'b1;
					end
				else
					s_next = s_reg + 1;
		endcase
	end// always@* next_state logic
	
	// Output
	assign dout = b_reg;
	
endmodule
	
	