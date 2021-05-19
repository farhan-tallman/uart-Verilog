module tb_fifo;

reg clk, rst;
reg rd, wr;
reg [7:0] w_data;
wire empty, full;
wire [7:0] r_data;

//DUT instantiation

fifo fifo1(
	.clk(clk),
	.rst(rst),
	.rd(rd),
	.wr(wr),
	.w_data(w_data),
	.empty(empty),
	.full(full),
	.r_data(r_data)
	);

//clock 
initial
	forever
		#5 clk = ~clk;
//simulation control
initial
	#5000 $stop;
	
//testbench
initial
	begin
	clk = 0;
	w_data = 0;
	wr = 0;
	rd = 0;
	rst = 1;
	#20
	rst = 0;
	
	@(posedge clk)
		begin
		wr = 1;
		#5 w_data = w_data + 1;
		
		end

	end

//always@(posedge clk)
//	#5 w_data = w_data + 1;
	
