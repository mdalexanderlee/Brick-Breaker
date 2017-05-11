
module  Brick (input         	Reset, 
										frame_clk,          // The clock indicating a new frame (~60Hz)
					input int 		BreakX, BreakY,
					input 			Brick_Broke,
					output int 		Bricks[4][10],
               output [9:0]  	BrickX, BrickY, 
										BrickW, BrickH, // Brick coordinates of top left corner and size of individual Brick
					input [15:0] keycode
              );
    
    logic [9:0] Brick_X_Pos, Brick_Y_Pos;
    logic [9:0] Brick_X_Pos_in, Brick_Y_Pos_in;
     
    parameter [9:0] Brick_X_Center=300;  // Center position on the X axis
    parameter [9:0] Brick_Y_Center=100;  // Center position on the Y axis
	 
    parameter [9:0] Brick_Width=64;        // Brick size
    parameter [9:0] Brick_Height=20;        // Brick size
    	
	 initial
	 begin
	 int col = 0;
	 int row = 0;
		for(row = 0; row < 4; row++)begin
			for(col = 0; col < 10; col++)begin
				Bricks[row][col] = 1;
			end
		end
	 
	 end
	 
    assign BrickX = Brick_X_Pos;
    assign BrickY = Brick_Y_Pos;
    assign BrickW = Brick_Width;
    assign BrickH = Brick_Height;

    always_ff @ (posedge frame_clk or posedge Reset)
    begin
				
            Brick_X_Pos <= Brick_X_Center;
            Brick_Y_Pos <= Brick_Y_Center;
        
    end
    
    always_ff @ (posedge frame_clk)
	 begin
		if(keycode == 8'h15)begin
				int col = 0;
				int row = 0;
				for(row = 0; row < 4; row++)begin
					for(col = 0; col < 10; col++)begin
					Bricks[row][col] = 1;
				end
			end
		end
		else begin
			Bricks[BreakX][BreakY] <= Bricks[BreakX][BreakY];
			if(Brick_Broke == 1'd1)begin
				Bricks[BreakX][BreakY] <= 0;
			end
		end
	 end
endmodule
