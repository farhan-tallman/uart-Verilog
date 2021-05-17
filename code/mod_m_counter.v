
/*
Fpga prototyping, listing 4.11
Mod-m Counter

This counter counts from 0 to m-1 and then wraps around
*/


module mod_m_counter
	#(
	parameter 	N = 4, // number of bits in counter
				M = 10 // Mod-M
	)
	(
	input wire clk, rst,
	output wire max_tick,
	output wire [N-1:0] q
	);

	// signal declaration
	reg [N-1:0] r_reg;
	wire [N-1:0] r_next;
	
	//Physical Registers
	always@(posedge clk, posedge rst)
		if(rst)
			r_reg <= 0;
		else
			r_reg <= r_next;
	
	// next state Logic
	assign r_next = (r_reg == (M-1)) ? 0 : r_reg + 1;
	
	//output logic
	assign q = r_reg;
	assign max_tick = (r_reg == (M-1)) ? 1'b1 : 1'b0;
	
endmodule