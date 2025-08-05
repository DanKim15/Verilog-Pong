module Lfsr(
	input i_clk,
	output reg [2:0] o_data);
	
	wire w_xnor;
	always @(posedge i_clk)
		o_data <= {o_data[1:0], w_xnor};
	
	assign w_xnor = o_data[2] ^~ o_data[1];
endmodule