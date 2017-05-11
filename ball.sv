//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  03-03-2017                               --
//    Spring 2017 Distribution                                           --
//                                                                       --
//    For use with ECE 298 Lab 7                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  ball ( input         Reset, 
                             frame_clk,          // The clock indicating a new frame (~60Hz)
					input  [7:0]  key,
               output [9:0]  BallX, BallY, BallS, // Ball coordinates and size
					
					input	[9:0]	BlockX, BlockY, BlockW, BlockH,
					input [9:0] BrickX, BrickY, BrickW, BrickH,
					input int Bricks[4][10],
					output Brick_Broke,
					output int BreakX, BreakY,
					output int ball_start, wingame,
					input [9:0] Block_X_Motion,
					output int lose,
					output int lives_count
              );
    
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion;
    logic [9:0] Ball_X_Pos_in, Ball_X_Motion_in, Ball_Y_Pos_in, Ball_Y_Motion_in;
     
    parameter [9:0] Ball_X_Center=323;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center=240;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=479;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step=2;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step=2;      // Step size on the Y axis
    parameter [9:0] Ball_Size=2;        // Ball size

    
	 assign lives_count = lives;
    assign BallX = Ball_X_Pos;
    assign BallY = Ball_Y_Pos;
    assign BallS = Ball_Size;
    assign Brick_Broke = Brick_Br;
	 logic flag, Brick_Br;
	 
	 int bricksbroken, lives_in;
	 initial
	 begin
		ball_start = 1;
		wingame = 0;
		lose = 0;
		bricksbroken_in = 0;
		bricksbroken = 0;
		lives = 0;
		lives_in = 0;
	 end
	 
	 always_comb
	 begin
		if(bricksbroken >= 40)
			wingame = 1;
		else
			wingame = 0;
	 end
	 
	 
    always_ff @ (posedge frame_clk or posedge Reset)
    begin
        if (Reset) // reset
        begin
            Ball_X_Pos <= Ball_X_Center;
            Ball_Y_Pos <= Ball_Y_Center;
            Ball_X_Motion <= 10'd0;
            Ball_Y_Motion <= 10'd0;
        end
		  else if (wingame == 1)begin
				Ball_X_Pos <= Ball_X_Center;
            Ball_Y_Pos <= Ball_Y_Center;
            Ball_X_Motion <= 10'd0;
            Ball_Y_Motion <= 10'd0;
		  end
        else if (lifelose == 1)begin
		      Ball_X_Pos <= Ball_X_Center;
            Ball_Y_Pos <= Ball_Y_Center;
            Ball_X_Motion <= 10'd0;
            Ball_Y_Motion <= 10'd0;
		  end
        else if (key == 8'h15)begin // reset
		      Ball_X_Pos <= Ball_X_Center;
            Ball_Y_Pos <= Ball_Y_Center;
            Ball_X_Motion <= 10'd0;
            Ball_Y_Motion <= 10'd0;
				ball_start <= 1;
		  end // start
		  else if(key == 8'h16)
		  begin
		  		if(flag == 0 && lose != 1 && Ball_X_Motion == 10'd0 && Ball_Y_Motion == 10'd0 && wingame == 0)
				begin
				   Ball_X_Pos <= Ball_X_Pos_in;
					Ball_Y_Pos <= Ball_Y_Pos_in;
					Ball_X_Motion <= 10'd0;
					Ball_Y_Motion <= Ball_Y_Step;
					ball_start <= 0;
				end
				else 
				begin
				   Ball_X_Pos <= Ball_X_Pos_in;
					Ball_Y_Pos <= Ball_Y_Pos_in;
					Ball_X_Motion <= Ball_X_Motion_in;
					Ball_Y_Motion <= Ball_Y_Motion_in;
				end
		  end
		  else
			begin
            Ball_X_Pos <= Ball_X_Pos_in;
            Ball_Y_Pos <= Ball_Y_Pos_in;
            Ball_X_Motion <= Ball_X_Motion_in;
            Ball_Y_Motion <= Ball_Y_Motion_in;
			end
			
//			8'h16: //start
//				if(flag == 0 && lose != 1 && Ball_X_Motion == 10'd0 && Ball_Y_Motion == 10'd0)
//				begin
//				   Ball_X_Pos <= Ball_X_Pos_in;
//					Ball_Y_Pos <= Ball_Y_Pos_in;
//					Ball_X_Motion <= 10'd0;
//					Ball_Y_Motion <= Ball_Y_Step;
//					ball_start <= 0;
//				end
//			endcase
			
			
        //end
    end
    
	 
	 
	 int bricksbroken_in;
    always_ff @ (posedge frame_clk)
	begin
		bricksbroken <= bricksbroken_in;
	end

	
	
	 int lives;
    always_ff @ (posedge frame_clk)
	begin
		lives <= lives_in;
	end


	always_comb
	 begin
		if(lives >= 3)
			lose = 1;
		else
			lose = 0;
	 end
	
	
always_comb
begin
	if(key == 8'h15)begin
		bricksbroken_in = 0;
	end
	
	else if(Brick_Br)
		bricksbroken_in = bricksbroken + 1;
	else
		bricksbroken_in = bricksbroken;
end

always_comb
begin
	if(key == 8'h15)begin
		lives_in = 0;
	end
	else if(lifelose)
		lives_in = lives + 1;
	else
		lives_in = lives;
	
end


logic lifelose;


    always_comb
    begin
        // By default, keep motion unchanged
        Ball_X_Motion_in = Ball_X_Motion;
        Ball_Y_Motion_in = Ball_Y_Motion;
        
        // Be careful when using comparators with "logic" datatype becuase compiler treats 
        //   both sides of the operator UNSIGNED numbers. (unless with further type casting)
        // e.g. Ball_Y_Pos - Ball_Size <= Ball_Y_Min 
        // If Ball_Y_Pos is 0, then Ball_Y_Pos - Ball_Size will not be -4, but rather a large positive number.
		  
		  	
		  
		  flag = 0;
		  Brick_Br = 1'd0;
		  BreakX = 0;
		  BreakY = 0;
		  lifelose = 1'd0;

		  
		  
		  
		  
		if( Ball_Y_Pos + Ball_Size >= Ball_Y_Max )  // Ball is at the bottom edge, BOUNCE!
		begin
			lifelose = 1'd1;
		end
	   else if ( Ball_Y_Pos <= Ball_Y_Min + Ball_Size )  // Ball is at the top edge, BOUNCE!
		begin
			Ball_Y_Motion_in = Ball_Y_Step;
			Ball_X_Motion_in = Ball_X_Motion;
			flag = 1;
		end
	   else if ( Ball_X_Pos + Ball_Size >= Ball_X_Max )  // Ball is at the right side edge, BOUNCE!
		begin
			Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);		// 2's complement.  
			Ball_Y_Motion_in = Ball_Y_Motion;
			flag = 1;

		end
	   else if (Ball_X_Pos <= Ball_X_Min + Ball_Size )  // Ball is at the left edge, BOUNCE!
		begin
			Ball_X_Motion_in = Ball_X_Step;
			Ball_Y_Motion_in = Ball_Y_Motion;
			flag = 1;

		end
		  
		  
		  //bricks
		else if(Ball_Y_Pos - Ball_Size <= 10'd4 * BrickH )begin		// inside where bricks are
		
		
			if(Bricks[int'((Ball_Y_Pos_in - BallS)/BrickH)][int'(Ball_X_Pos_in/BrickW)]==1'd1) // up
				begin
								//vertical bounce lower birck edge
							BreakX = int'((Ball_Y_Pos_in - BallS)/BrickH);
							BreakY = int'(Ball_X_Pos_in/BrickW);
							Ball_Y_Motion_in = (~(Ball_Y_Motion) + 1'b1);		
							Ball_X_Motion_in = Ball_X_Motion;
							Brick_Br = 1'd1;
				end
			else if(Bricks[int'((Ball_Y_Pos_in + BallS)/BrickH)][int'(Ball_X_Pos_in/BrickW)]==1'd1) // down
				begin
								//vertical bounce upper brick edge
							BreakX = int'((Ball_Y_Pos_in + BallS)/BrickH);
							BreakY = int'(Ball_X_Pos_in/BrickW);
							Ball_Y_Motion_in = (~(Ball_Y_Motion) + 1'b1);		
							Ball_X_Motion_in = Ball_X_Motion;
							Brick_Br = 1'd1;
				end
			else if(Bricks[int'((Ball_Y_Pos_in)/BrickH)][int'((Ball_X_Pos_in - BallS)/BrickW)]==1'd1) // right side of brick
				begin
							// horizontal bounce going left brick
						BreakX = int'((Ball_Y_Pos_in)/BrickH);
						BreakY = int'((Ball_X_Pos_in-BallS)/BrickW);		
						Ball_Y_Motion_in = Ball_Y_Motion;		
						Ball_X_Motion_in = (~(Ball_X_Motion) + 1'b1);
						Brick_Br = 1'd1;
				end
			else if(Bricks[int'((Ball_Y_Pos_in)/BrickH)][int'((Ball_X_Pos_in + BallS)/BrickW)]==1'd1) // left side of brick
				begin
							//horizontal bounce left edge of briack
						BreakX = int'((Ball_Y_Pos_in)/BrickH);
						BreakY = int'((Ball_X_Pos_in + BallS)/BrickW);		
						Ball_Y_Motion_in = Ball_Y_Motion;		
						Ball_X_Motion_in =(~(Ball_X_Motion) + 1'b1);
						Brick_Br = 1'd1;
				end
			end
				
		  //block
		  else if( (Ball_Y_Pos + Ball_Size == BlockY - BlockH) && ((Ball_X_Pos - BallS <= BlockX + BlockW) && (Ball_X_Pos+ BallS >= BlockX - BlockW))) 			//block collision
			begin
			   Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);		
				Ball_X_Motion_in = Ball_X_Motion;
				flag = 1;
				if(Ball_X_Motion == 10'd0)
				begin
					Ball_X_Motion_in = Block_X_Motion;
				end
				else
				begin
					Ball_X_Motion_in = Ball_X_Motion;
				end
			end
		  
		  //edges// edit overrides block collision, added the else instead of plain if
			else if(Ball_Y_Pos + Ball_Size >= Ball_Y_Max && Ball_X_Pos + Ball_Size >= Ball_X_Max || //bottom right corner
				Ball_Y_Pos <= Ball_Y_Min + Ball_Size && Ball_X_Pos + Ball_Size >= Ball_X_Max || //top right corner
				Ball_Y_Pos + Ball_Size >= Ball_Y_Max && Ball_X_Pos <= Ball_X_Min + Ball_Size || //bottom left corner
				Ball_Y_Pos <= Ball_Y_Min + Ball_Size && Ball_X_Pos <= Ball_X_Min + Ball_Size) // top left corner
			begin
				Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
				Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
			end

			
        // Update the ball's position with its motion
        Ball_X_Pos_in = Ball_X_Pos + Ball_X_Motion;
        Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;
    end
    
endmodule


