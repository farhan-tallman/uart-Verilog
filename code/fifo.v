module fifo
	#(
	parameter 	B=8, // # bits in word
				W=4  // # address bits
	)
	(
	input wire clk, rst,
	input wire rd, wr,
	input wire [B-1:0] w_data,
	output wire empty, full,
	output wire [B-1:0] r_data
	);
	
	// signal declration
	reg [B-1:0] array_reg [2**W-1:0]; // register array
	reg [W-1:0] w_ptr_reg, w_ptr_next, w_ptr_succ;
	reg [W-1:0] r_ptr_reg, r_ptr_next, r_ptr_succ;
	reg full_reg, empty_reg, full_next, empty_next;
	wire wr_en;
	
	//body
	//Register file write operation
	always@(posedge clk)
		if(wr_en)
			array_reg[w_ptr_reg] <= w_data;
	
	//Register file read operation
	assign r_data = array_reg[r_ptr_reg];
	
	//Write enabled only whne FIFO is not full
	assign wr_en = wr & ~full_reg;
	
	// fifo control
	// register for read and write pointers
	always@(posedge clk, posedge rst)
		if(rst)
			begin
			w_ptr_reg <= 0;
			r_ptr_reg <= 0;
			full_reg <= 1'b0;
			empty_reg <= 1'b1;
			end
		else
			begin
			w_ptr_reg <= w_ptr_next;
			r_ptr_reg <= r_ptr_next;
			full_reg  <= full_next;
			empty_reg <= empty_next;
			end
	
	// next state logic for read and write pointers
	always@*
		begin
		// successive pointer values
		w_ptr_succ = w_ptr_reg + 1;
		r_ptr_succ = r_ptr_reg + 1;
		// default values
		w_ptr_next = w_ptr_reg;
		r_ptr_next = r_ptr_reg;
		full_next = full_reg;
		empty_next = empty_reg;
		case({wr,rd})
			//2'b00: no operation
			2'b01: //read
				if(~empty_reg) // fifo not empty
					begin
					r_ptr_next = r_ptr_succ;
					full_next = 1'b0;
					if(r_ptr_succ == w_ptr_reg) // means that fifo is empty
						empty_next = 1'b1;
					end
			2'b10: //write
				if(~full_reg) // fifo not full
					begin
					w_ptr_next = w_ptr_succ;
					empty_next = 1'b0;
					if(w_ptr_succ == r_ptr_reg) // means that fifo is full
						full_next = 1'b1;
					end
			2'b11: // write and read
				begin
				w_ptr_next = w_ptr_succ;
				r_ptr_next = r_ptr_succ;
				end
		endcase
		end // always@*
	// output
	assign full = full_reg;
	assign empty = empty_reg;

endmodule