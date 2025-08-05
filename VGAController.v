	module VGAController(
	input i_clk,
	input i_pb,
	input signed [10:0] i_ball_x,
	input signed [10:0] i_ball_y,
	input signed [10:0] i_paddle1_y,
	input signed [10:0] i_paddle2_y,
	input i_finish,
	output [3:0] o_red,
	output [3:0] o_green,
	output [3:0] o_blue,
	output o_hsync,
	output o_vsync,
	output o_frame_tick);
	
	localparam HCOUNT_LIMIT = 799;
	localparam VCOUNT_LIMIT = 524;
	localparam ADDRESSABLE_X_MIN = 144;
	localparam ADDRESSABLE_X_MAX = 784;
	localparam ADDRESSABLE_Y_MIN = 35;
	localparam ADDRESSABLE_Y_MAX = 515;
	
	localparam BALL_WIDTH = 8;
	localparam PADDLE_WIDTH = 8;
	localparam PADDLE_HEIGHT = 80;
	localparam PADDLE1_X = 16;
	localparam PADDLE2_X = 608;
	
	localparam DEFAULT = 0;
	localparam GREEN = 1;
	localparam PINK = 2;
	localparam RED = 3;
	localparam BLUE = 4;
	
	
	reg r_25clk;
	reg r_pb;
	wire w_vcount_incr;
	reg [3:0] r_primary_red, r_primary_green, r_primary_blue, r_secondary_red, r_secondary_green, r_secondary_blue;
	reg [2:0] r_colour_state;
	
	
	wire [$clog2(HCOUNT_LIMIT + 1):0] w_hcounter;
	wire [$clog2(VCOUNT_LIMIT + 1):0] w_vcounter;
	wire w_addressable_h;
	wire w_addressable_v;
	wire w_show_ball;
	wire W_draw_paddle1;
	wire w_draw_paddle2;
	wire w_draw_pixel;
	
	Counter #(.COUNT_LIMIT(HCOUNT_LIMIT)) hcounter_inst(
		.i_clk(r_25clk),
		.o_counter(w_hcounter),
		.o_done(w_vcount_incr));
		
	Counter #(.COUNT_LIMIT(VCOUNT_LIMIT)) vcounter_inst(
		.i_clk(w_vcount_incr),
		.o_counter(w_vcounter),
		.o_done(o_frame_tick));	
		
	always @(posedge i_clk)
	begin
		r_25clk <= ~r_25clk;
		
		r_pb <= i_pb;
		if (!r_pb && i_pb)
			r_colour_state <= (r_colour_state + 1) % 5;
		
		case (r_colour_state)
		DEFAULT:
		begin
			r_primary_red <= 4'hF;
			r_primary_green <= 4'hF;
			r_primary_blue <= 4'hF;
		end
		GREEN:
		begin
			r_primary_red <= 4'h3;
			r_primary_green <= 4'hF;
			r_primary_blue <= 4'h1;
		end
		PINK:
		begin
			r_primary_red <= 4'hF;
			r_primary_green <= 4'h0;
			r_primary_blue <= 4'hF;
			r_secondary_red <= 4'h0;
			r_secondary_green <= 4'h0;
			r_secondary_blue <= 4'h0;
		end
		RED:
		begin
			r_primary_red <= 4'hF;
			r_primary_green <= 4'h0;
			r_primary_blue <= 4'h0;
			r_secondary_red <= 4'h0;
			r_secondary_green <= 4'h0;
			r_secondary_blue <= 4'h0;
		end
		BLUE:
		begin
			r_primary_red <= 4'h0;
			r_primary_green <= 4'h0;
			r_primary_blue <= 4'hF;
		end
		endcase
	end
	
	assign w_addressable_h = w_hcounter < ADDRESSABLE_X_MAX && w_hcounter >= ADDRESSABLE_X_MIN;
	assign w_addressable_v = w_vcounter < ADDRESSABLE_Y_MAX && w_vcounter >= ADDRESSABLE_Y_MIN;
	assign w_draw_ball = i_ball_x + ADDRESSABLE_X_MIN <= w_hcounter && (i_ball_x + ADDRESSABLE_X_MIN + BALL_WIDTH) > w_hcounter && i_ball_y + ADDRESSABLE_Y_MIN <= w_vcounter && (i_ball_y + ADDRESSABLE_Y_MIN + BALL_WIDTH) > w_vcounter && !i_finish;
	assign w_draw_paddle1 = PADDLE1_X + ADDRESSABLE_X_MIN <= w_hcounter && (PADDLE1_X + ADDRESSABLE_X_MIN + PADDLE_WIDTH) > w_hcounter && i_paddle1_y + ADDRESSABLE_Y_MIN <= w_vcounter && (i_paddle1_y + ADDRESSABLE_Y_MIN + PADDLE_HEIGHT) > w_vcounter && !i_finish;
	assign w_draw_paddle2 = PADDLE2_X + ADDRESSABLE_X_MIN <= w_hcounter && (PADDLE2_X + ADDRESSABLE_X_MIN + PADDLE_WIDTH) > w_hcounter && i_paddle2_y + ADDRESSABLE_Y_MIN <= w_vcounter && (i_paddle2_y + ADDRESSABLE_Y_MIN + PADDLE_HEIGHT) > w_vcounter && !i_finish;
	assign w_draw_pixel = w_addressable_h && w_addressable_v && (w_draw_ball || w_draw_paddle1 || w_draw_paddle2);
	assign o_hsync = (w_hcounter < 96) ? 1'b0 : 1'b1;
	assign o_vsync = (w_vcounter < 2) ? 1'b0 : 1'b1;
	assign o_red = (w_draw_pixel) ? r_primary_red : 4'h0;
	assign o_green = (w_draw_pixel) ? r_primary_green : 4'h0;
	assign o_blue = (w_draw_pixel) ? r_primary_blue : 4'h0;
	
endmodule