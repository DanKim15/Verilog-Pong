module Counter #(parameter COUNT_LIMIT = 100)(
	input i_clk,
	output reg [$clog2(COUNT_LIMIT + 1):0] o_counter,
	output reg o_done);
	
	always @(posedge i_clk)
	begin
		if (o_counter < COUNT_LIMIT)
		begin
			o_counter <= o_counter + 1;
			o_done <= 1'b0;
		end
		else
		begin
			o_counter <= 1'b0;
			o_done <= 1'b1;
		end
	end
	
endmodule