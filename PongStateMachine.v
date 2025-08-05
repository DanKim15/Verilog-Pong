module PongStateMachine #(GAME_LIMIT = 11)(
	input i_clk,
	input [1:0] i_sw,
	input i_pb,
	input i_frame_tick,
	output [3:0] o_score_p1d1,
	output [3:0] o_score_p1d2,
	output [3:0] o_score_p2d1,
	output [3:0] o_score_p2d2,
	output reg signed [10:0] o_ball_x,
	output reg signed [10:0] o_ball_y,
	output reg signed [10:0] o_paddle1_y,
	output reg signed [10:0] o_paddle2_y,
	output reg o_finish);
	
	localparam RESET = 3'd0;
	localparam SERVE = 3'd1;
	localparam PLAY = 3'd2;
	localparam INCR_SCORE = 3'd3;
	localparam FINISH = 3'd4;
	
	localparam SCREEN_WIDTH = 632;
	localparam SCREEN_HEIGHT = 480;
	localparam BALL_WIDTH = 8;
	localparam PADDLE_WIDTH = 8;
	localparam PADDLE_HEIGHT = 80;
	localparam PADDLE1_X = 16;
	localparam PADDLE2_X = 608;
	localparam PADDLE_VEL = 4;
	
	reg [2:0] r_state;
	reg [($clog2(GAME_LIMIT + 1)):0] r_p1score, r_p2score;
	reg r_pb, r_posedge_pb, r_frame_tick, r_posedge_ftick;
	reg signed [4:0] r_velx;
	reg signed [4:0] r_vely;
	wire [2:0] w_lfsr;
	reg r_scorer;
	reg [5:0] r_blink_counter;
	
	Lfsr lfsr_inst(
	.i_clk(i_clk),
	.o_data(w_lfsr));
	
	
	always @(posedge i_clk)
	begin
		if(r_posedge_pb && r_state != RESET)
			r_state <= RESET;
		else if (r_posedge_pb && r_state == RESET)
		begin
			r_state <= SERVE;
			r_velx <= w_lfsr[0] ? 3 : -3;
			case (w_lfsr[2:1])
			2'b00: r_vely <=  2;
			2'b01: r_vely <=  1;
			2'b10: r_vely <= -2;
			2'b11: r_vely <= -1;
			endcase
		end
		else
		begin
			case (r_state)
			RESET:
			begin
				o_finish <= 1'b0;
				r_p1score <= 0;
				r_p2score <= 0;
				if (r_posedge_ftick)
				begin
					o_ball_x <= (SCREEN_WIDTH - BALL_WIDTH) >> 1;
					o_ball_y <= (SCREEN_HEIGHT - BALL_WIDTH) >> 1;
					o_paddle1_y <= (SCREEN_HEIGHT - PADDLE_HEIGHT) >> 1;
					o_paddle2_y <= (SCREEN_HEIGHT - PADDLE_HEIGHT) >> 1;
				end
			end
			SERVE:
			begin
				
				if (r_posedge_ftick)
				begin
					o_ball_x <= (SCREEN_WIDTH - BALL_WIDTH) >> 1;
					o_ball_y <= (SCREEN_HEIGHT - BALL_WIDTH) >> 1;
					
					r_state <= PLAY;
				end
			end
			PLAY:
			begin
				if (o_ball_x + BALL_WIDTH <= 0)
				begin
					r_p2score <= r_p2score + 1;
					r_state <= INCR_SCORE;
				end
				
				else if (o_ball_x >= SCREEN_WIDTH)
				begin
					r_p1score <= r_p1score + 1;
					r_state <= INCR_SCORE;
				end
				else if ((o_ball_y <= 0 && r_vely < 0) || (o_ball_y + BALL_WIDTH >= SCREEN_HEIGHT && r_vely > 0))
					r_vely <= -r_vely;
				
				else if (r_velx < 0 && o_ball_x < PADDLE1_X + PADDLE_WIDTH && o_ball_x + BALL_WIDTH >= PADDLE1_X && o_ball_y + BALL_WIDTH > o_paddle1_y && o_ball_y < o_paddle1_y + PADDLE_HEIGHT)
				begin
					if (o_ball_y  + BALL_WIDTH - o_paddle1_y > 2 && o_paddle1_y + PADDLE_HEIGHT - o_ball_y > 2)
					begin
						r_vely <= (o_ball_y - o_paddle1_y - ((PADDLE_HEIGHT - BALL_WIDTH) / 2)) / 5;
						r_velx <= -r_velx;
					end
				end
				
				else if (r_velx > 0 && o_ball_x < PADDLE2_X + PADDLE_WIDTH && o_ball_x + BALL_WIDTH >= PADDLE2_X && o_ball_y + BALL_WIDTH > o_paddle2_y && o_ball_y < o_paddle2_y + PADDLE_HEIGHT)
				begin
					if (o_ball_y  + BALL_WIDTH - o_paddle2_y > 2 && o_paddle2_y + PADDLE_HEIGHT - o_ball_y > 2)
					begin
						r_vely <= (o_ball_y - o_paddle2_y - ((PADDLE_HEIGHT - BALL_WIDTH) / 2)) / 5;
						r_velx <= -r_velx;
					end
				end
				
				if (r_posedge_ftick)
				begin
					o_ball_x <= o_ball_x + r_velx;
					o_ball_y <= o_ball_y + r_vely;
					
					if (!i_sw[1])
					begin
						if (o_paddle1_y + PADDLE_HEIGHT < SCREEN_HEIGHT)
							o_paddle1_y <= o_paddle1_y + PADDLE_VEL;
						else
							o_paddle1_y <= SCREEN_HEIGHT - PADDLE_HEIGHT;
					end
					if (i_sw[1])
					begin
						if (o_paddle1_y > 0 && o_paddle1_y - PADDLE_VEL >= 0)
							o_paddle1_y <= o_paddle1_y - PADDLE_VEL;
						else
							o_paddle1_y <= 0;
					end
						
					if (!i_sw[0])
					begin
						if (o_paddle2_y + PADDLE_HEIGHT < SCREEN_HEIGHT)
							o_paddle2_y <= o_paddle2_y + PADDLE_VEL;
						else
							o_paddle2_y <= SCREEN_HEIGHT - PADDLE_HEIGHT;
					end
					if (i_sw[0])
					begin
						if (o_paddle2_y > 0 && o_paddle2_y - PADDLE_VEL >= 0)
							o_paddle2_y <= o_paddle2_y - PADDLE_VEL;
						else
							o_paddle2_y <= 0;
					end
				end
			end
			
			INCR_SCORE:
			begin
				if (r_p1score == GAME_LIMIT || r_p2score == GAME_LIMIT)
					r_state <= FINISH;
				else
				begin
					if (r_posedge_ftick)
					begin
						r_blink_counter <= r_blink_counter + 1;
						if (r_blink_counter >= 60)
						begin
							r_state <= SERVE;
							r_blink_counter <= 0;
						end
					end
				end
			end
			
			FINISH:
			begin
				if (r_posedge_ftick)
				begin
					r_blink_counter <= r_blink_counter + 1;
					if (r_blink_counter >= 30)
					begin
						o_finish <= ~o_finish;
						r_blink_counter <= 0;
					end
				end
			
			end
			
			endcase
		end
				
	end
	
	always @(posedge i_clk)
	begin
		
		r_pb <= i_pb;
		if (!r_pb && i_pb)
			r_posedge_pb <= 1'b1;
		else
			r_posedge_pb <= 1'b0;
		
		r_frame_tick <= i_frame_tick;
		if (!r_frame_tick && i_frame_tick)
			r_posedge_ftick <= 1'b1;
		else
			r_posedge_ftick <= 1'b0;
		
	end	
	
	assign o_score_p1d1 = r_p1score / 10;
	assign o_score_p1d2 = r_p1score % 10;
	assign o_score_p2d1 = r_p2score / 10;
	assign o_score_p2d2 = r_p2score % 10;
	
endmodule