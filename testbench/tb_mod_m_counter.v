module tb_mod_m_counter;

reg clk, rst;
wire [3:0] q;
wire max_tick;


// dut instantiation
mod_m_counter mod_m_counter1(
	.clk(clk),
	.rst(rst),
	.max_tick(max_tick),
	.q(q)
);

// clk generation
initial
	forever
		#5 clk = ~clk;
// Simulation control
initial
	#5000 $stop;
	
//the testbench
initial
	begin
		clk = 0;
		rst = 0;
		#10
		rst = 1;
		#20
		rst = 0;
	end


endmodule