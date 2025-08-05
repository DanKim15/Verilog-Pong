module PongGame(
	input i_clk,
	input [1:0] i_sw,
	input i_pb,
	input i_pb2,
	output [6:0] o_sevseg_p1d1,
	output [6:0] o_sevseg_p1d2,
	output [6:0] o_sevseg_p2d1,
	output [6:0] o_sevseg_p2d2,
	output [3:0] o_red,
	output [3:0] o_green,
	output [3:0] o_blue,
	output o_hsync,
	output o_vsync);
	
	localparam GAME_LIMIT = 5;
	localparam DEBOUNCE_LIMIT = 5000000;
	
	wire [1:0] w_sw;
	wire w_pb, w_pb2;
	wire [3:0] w_score_p1d1;
	wire [3:0] w_score_p1d2;
	wire [3:0] w_score_p2d1;
	wire [3:0] w_score_p2d2;
	wire signed [10:0] w_ball_x;
	wire signed [10:0] w_ball_y;
	wire signed [10:0] w_paddle1_y;
	wire signed [10:0] w_paddle2_y;
	wire w_finish, w_frame_tick;
	
	
	DebounceFilter #(.DEBOUNCE_LIMIT(DEBOUNCE_LIMIT)) debounce_sw0(
		.i_clk(i_clk),
		.i_bouncy(i_sw[0]),
		.o_debounced(w_sw[0]));
		
	DebounceFilter #(.DEBOUNCE_LIMIT(DEBOUNCE_LIMIT)) debounce_sw1(
		.i_clk(i_clk),
		.i_bouncy(i_sw[1]),
		.o_debounced(w_sw[1]));
		
	DebounceFilter #(.DEBOUNCE_LIMIT(DEBOUNCE_LIMIT)) debounce_pb(
		.i_clk(i_clk),
		.i_bouncy(i_pb),
		.o_debounced(w_pb));
		
	DebounceFilter #(.DEBOUNCE_LIMIT(DEBOUNCE_LIMIT)) debounce_pb2(
		.i_clk(i_clk),
		.i_bouncy(i_pb2),
		.o_debounced(w_pb2));
	
	BinaryToSevSeg sevseg_p1d1_inst(
		.i_clk(i_clk),
		.i_bin_num(w_score_p1d1),
		.o_sevseg(o_sevseg_p1d1));
	
	BinaryToSevSeg sevseg_p1d2_inst(
		.i_clk(i_clk),
		.i_bin_num(w_score_p1d2),
		.o_sevseg(o_sevseg_p1d2));
		
	BinaryToSevSeg sevseg_p2d1_inst(
		.i_clk(i_clk),
		.i_bin_num(w_score_p2d1),
		.o_sevseg(o_sevseg_p2d1));
		
	BinaryToSevSeg sevseg_p2d2_inst(
		.i_clk(i_clk),
		.i_bin_num(w_score_p2d2),
		.o_sevseg(o_sevseg_p2d2));
		
	PongStateMachine #(.GAME_LIMIT(GAME_LIMIT)) statemachine_inst(
		.i_clk(i_clk),
		.i_sw(w_sw),
		.i_pb(w_pb),
		.i_frame_tick(w_frame_tick),
		.o_score_p1d1(w_score_p1d1),
		.o_score_p1d2(w_score_p1d2),
		.o_score_p2d1(w_score_p2d1),
		.o_score_p2d2(w_score_p2d2),
		.o_ball_x(w_ball_x),
		.o_ball_y(w_ball_y),
		.o_paddle1_y(w_paddle1_y),
		.o_paddle2_y(w_paddle2_y),
		.o_finish(w_finish));
		
		
	VGAController vgacontroller_inst(
		.i_clk(i_clk),
		.i_pb(w_pb2),
		.i_ball_x(w_ball_x),
		.i_ball_y(w_ball_y),
		.i_paddle1_y(w_paddle1_y),
		.i_paddle2_y(w_paddle2_y),
		.i_finish(w_finish),
		.o_red(o_red),
		.o_green(o_green),
		.o_blue(o_blue),
		.o_hsync(o_hsync),
		.o_vsync(o_vsync),
		.o_frame_tick(w_frame_tick));
	
endmodule	
		
		
		
		
		