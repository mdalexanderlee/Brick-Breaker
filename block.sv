
module  block (input         Reset,
                             frame_clk,          // The clock indicating a new frame (~60Hz)
					input  [7:0]  key,
               output [9:0]  BlockX, BlockY, BlockW, BlockH, // Block coordinates and size
					output [9:0] Block_X_Motion_Out
					);

    logic [9:0] Block_X_Pos, Block_X_Motion, Block_Y_Pos, Block_Y_Motion;
    logic [9:0] Block_X_Pos_in, Block_X_Motion_in, Block_Y_Pos_in, Block_Y_Motion_in;

    parameter [9:0] Block_X_Center=320;  // Center position on the X axis
    parameter [9:0] Block_Y_Center=400;  // Center position on the Y axis
    parameter [9:0] Block_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] Block_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Block_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Block_Y_Max=479;     // Bottommost point on the Y axis
    parameter [9:0] Block_X_Step=3;      // Step size on the X axis
    parameter [9:0] Block_Y_Step=3;      // Step size on the Y axis
    parameter [9:0] Block_Width=25;        // Block size
    parameter [9:0] Block_Height=2;        // Block size

	 assign Block_X_Motion_Out = Block_X_Motion;
    assign BlockX = Block_X_Pos;
    assign BlockY = Block_Y_Pos;
    assign BlockW = Block_Width;
    assign BlockH = Block_Height;


	 logic right, left;

    always_ff @ (posedge frame_clk or posedge Reset)
    begin
        if (Reset) // reset
        begin
            Block_X_Pos <= Block_X_Center;
            Block_Y_Pos <= Block_Y_Center;
            Block_X_Motion <= 10'd0;
            Block_Y_Motion <= 10'd0;
        end
        else

        begin


		case(key)
			default: // keep moving
				begin
            Block_X_Pos <= Block_X_Pos_in;
            Block_Y_Pos <= Block_Y_Pos_in;
            Block_X_Motion <= 10'd0;
            Block_Y_Motion <= 10'd0;
				end


			8'h04: //A
			begin
				if(left == 1'b1)
				begin
				   Block_X_Pos <= Block_X_Pos_in;
					Block_Y_Pos <= Block_Y_Pos_in;
					Block_Y_Motion <= 10'd0;
					Block_X_Motion <= (~(Block_X_Step) + 1'b1);
				end
				else
				begin
					Block_X_Pos <= Block_X_Min + BlockW;
					Block_Y_Pos <= Block_Y_Pos_in;
					Block_Y_Motion <= 10'd0;
					Block_X_Motion <= 10'd0;
				end
			end
			8'h07: //D
			begin
				if(right == 1'b1)
				begin
				   Block_X_Pos <= Block_X_Pos_in;
					Block_Y_Pos <= Block_Y_Pos_in;
					Block_Y_Motion <= 10'd0;
					Block_X_Motion <= Block_X_Step;
				end
				else
				begin
					Block_X_Pos <= Block_X_Max-BlockW;
					Block_Y_Pos <= Block_Y_Pos_in;
					Block_Y_Motion <= 10'd0;
					Block_X_Motion <= 10'd0;
				end
			end

			endcase
        end
    end

    always_comb
    begin
        // By default, keep motion unchanged
        Block_X_Motion_in = Block_X_Motion;
        Block_Y_Motion_in = Block_Y_Motion;
		    left = 1'b1;
		    right = 1'b1;

		  if((Block_X_Pos + BlockW) >= Block_X_Max )  // Block is at the right edge
			begin
            Block_X_Motion_in = 10'd0;
				right = 1'b0;
			end
		  else if((Block_X_Pos - BlockW) <= (Block_X_Min + 2'd2))  // Block is at the left edge
			begin
            Block_X_Motion_in = 10'd0;
				left = 1'b0;
			end

        // Update the Block's position with its motion
        Block_X_Pos_in = Block_X_Pos + Block_X_Motion;
        Block_Y_Pos_in = Block_Y_Pos + Block_Y_Motion;

    end

endmodule
