//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  03-03-2017                               --
//                                                                       --
//    Spring 2017 Distribution                                           --
//                                                                       --
//    For use with ECE 385 Lab 7                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------


module  color_mapper ( input        [9:0] BallX, BallY,       // Ball coordinates
                                          BallS,              // Ball size (defined in ball.sv)
                                          DrawX, DrawY,       // Coordinates of current drawing pixel
                       output logic [7:0] VGA_R, VGA_G, VGA_B, // VGA RGB output
							  
							  input			[9:0] BlockX, BlockY, BlockW, BlockH,
							  
							  
							  input			[9:0] BrickX, BrickY, BrickW, BrickH,
							  input		int Bricks[4][10],
							  input		[3:0]sprite_in,
							  output		[18:0]read_addr,
							  input		[3:0]start_in,
							  output		[18:0]start_addr,
							  input	int ball_start, lose, wingame,
							  input [3:0] win_in,
							  output		[18:0]win_addr,
							  output [18:0] lose_addr,
							  input [3:0] lose_in,
							  input [3:0] heart_in,
								output [18:0] heart_addr,
								input int lives_count
							  );
    
    
    logic ball_on, block_on;
    logic [7:0] Red, Green, Blue;
	 
//	 logic tetris_on;
//	 parameter [9:0] tetris_X_Center=320;  // Center position on the X axis
//    parameter [9:0] tetris_Y_Center=240;  // Center position on the Y axis
//	 parameter [9:0] tetris_width = 10; //half of the actual width
//	 parameter [9:0] tetris_height = 10; //half of the actual height
     
    int DistX, DistY, Size, DistBlockX, DistBlockY, BlockWidth, BlockHeight;
    assign DistX = DrawX - BallX;
    assign DistY = DrawY - BallY;
    assign Size = BallS;
	 
	 assign BlockWidth = BlockW;
	 assign BlockHeight = BlockH;
	 
	 assign DistBlockX = DrawX - BlockX;
	 assign DistBlockY = DrawY - BlockY;
	 
	 logic start_on;
	 parameter [9:0] start_X_Center=320;  // Center position on the X axis
    parameter [9:0] start_Y_Center=240;  // Center position on the Y axis
	 parameter [9:0] start_width = 76; //half of the actual width
	 parameter [9:0] start_height = 57; //half of the actual height
	 
	 
	 
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;
    
	 always_comb
	 begin
		if(ball_start)
		begin
			if(DrawX >= start_X_Center - start_width && DrawX <= start_X_Center + start_width &&
				DrawY >= start_Y_Center - start_height && DrawY <= start_Y_Center + start_height
			)
				start_on = 1'b1;
			else
				start_on = 1'b0;
		end
		else 
			start_on = 1'b0;
	 end
	 
	 logic win_on, lose_on, heart_on_0, heart_on_1, heart_on_2;
	 
	 parameter [9:0] heart_X_Center_0= 40;  // Center position on the X axis
	 parameter [9:0] heart_X_Center_1= 72;  // Center position on the X axis
	 parameter [9:0] heart_X_Center_2= 104;  // Center position on the X axis

    parameter [9:0] heart_Y_Center= 440;  // Center position on the Y axis
	 parameter [9:0] heart_width = 16; //half of the actual width
	 parameter [9:0] heart_height = 16; //half of the actual height

	 always_comb
	 begin
		if(DrawX >= heart_X_Center_0 - heart_width && DrawX <= heart_X_Center_0 + heart_width &&
			DrawY >= heart_Y_Center - heart_height && DrawY <= heart_Y_Center + heart_height
		)begin
			if(lives_count <= 2)
				begin
					heart_on_0 = 1'b1;
				end
			else begin
				heart_on_0 = 1'b0;
			end
		end
		else
			begin
				heart_on_0 = 1'b0;
			end
	 end
		
		
		always_comb
		begin
		if(DrawX >= heart_X_Center_1 - heart_width && DrawX <= heart_X_Center_1 + heart_width &&
			DrawY >= heart_Y_Center - heart_height && DrawY <= heart_Y_Center + heart_height
		)begin
			if(lives_count <= 1)
				begin
					heart_on_1 = 1'b1;
				end
			else begin
				heart_on_1 = 1'b0;
			end
		end
		else
			begin
				heart_on_1 = 1'b0;
			end
		end


		always_comb
		begin
		if(DrawX >= heart_X_Center_2 - heart_width && DrawX <= heart_X_Center_2 + heart_width &&
			DrawY >= heart_Y_Center - heart_height && DrawY <= heart_Y_Center + heart_height
		)begin
			if(lives_count == 0)
				begin
					heart_on_2 = 1'b1;
				end
			else begin
				heart_on_2 = 1'b0;
			end
		end
		else 
			begin
				heart_on_2 = 1'b0;
			end
	 end
	 
	 
	 
	logic [18:0] heart_addr_0, heart_addr_1, heart_addr_2;
	assign heart_addr_0 = (DrawY - (heart_Y_Center - heart_height)) * 32 + (DrawX - (heart_X_Center_0 - heart_width));
	assign heart_addr_1 = (DrawY - (heart_Y_Center - heart_height)) * 32 + (DrawX - (heart_X_Center_1 - heart_width));
	assign heart_addr_2 = (DrawY - (heart_Y_Center - heart_height)) * 32 + (DrawX - (heart_X_Center_2 - heart_width));
	
	
	
	
	always_comb begin
		if(heart_on_0 == 1'b1)
			heart_addr = heart_addr_0;
		else if(heart_on_1 == 1'b1)
			heart_addr = heart_addr_1;
		else
			heart_addr = heart_addr_2;
	end

	 
	 
	 
	 
	 
	 parameter [9:0] win_X_Center=320;  // Center position on the X axis
    parameter [9:0] win_Y_Center=240;  // Center position on the Y axis
	 parameter [9:0] win_width = 220; //half of the actual width
	 parameter [9:0] win_height = 31; //half of the actual height

	 always_comb
	 begin
		if(wingame)
		begin
			if(DrawX >= win_X_Center - win_width && DrawX <= win_X_Center + win_width &&
				DrawY >= win_Y_Center - win_height && DrawY <= win_Y_Center + win_height
			)
				win_on = 1'b1;
			else
				win_on = 1'b0;
		end
		else 
			win_on = 1'b0;
	 end
	 
	 
	 
	 parameter [9:0] lose_X_Center=320;  // Center position on the X axis
    parameter [9:0] lose_Y_Center=240;  // Center position on the Y axis
	 parameter [9:0] lose_width = 119; //half of the actual width
	 parameter [9:0] lose_height = 100; //half of the actual height

	 always_comb
	 begin
		if(lose)
		begin
			if(DrawX >= lose_X_Center - lose_width && DrawX <= lose_X_Center + lose_width &&
				DrawY >= lose_Y_Center - lose_height && DrawY <= lose_Y_Center + lose_height
			)
				lose_on = 1'b1;
			else
				lose_on = 1'b0;
		end
		else 
			lose_on = 1'b0;
	 end
	 
	 
	 
    always_comb
    begin : Ball_on_proc
        if ( ( DistX*DistX + DistY*DistY) <= (Size * Size) ) 
            ball_on = 1'b1;
        else 
            ball_on = 1'b0;
    end
	 
	 
	
	always_comb
	begin
		if(DistBlockX*DistBlockX <= BlockWidth*BlockWidth && DistBlockY*DistBlockY <= BlockHeight*BlockHeight)
			block_on = 1'b1;
		else
			block_on = 1'b0;
	end
	
	assign read_addr = DrawY * 640 + DrawX; //we flipped the two coordinates
	assign start_addr = (DrawY - (start_Y_Center - start_height)) * 152 + (DrawX - (start_X_Center - start_width));
	
	assign win_addr = (DrawY - (win_Y_Center - win_height)) * 440 + (DrawX - (win_X_Center - win_width));
	
	assign lose_addr = (DrawY - (lose_Y_Center - lose_height)) * 238 + (DrawX - (lose_X_Center - lose_width));
	
	


	always_comb
    begin : RGB_Display
		  if(DrawY <= 10'd4 * BrickH && Bricks[int'(DrawY/BrickH)][int'(DrawX/BrickW)]==1'd1)
		  begin
			Red = int'(DrawY/BrickH) * 8'h33 + int'(DrawX/BrickW) * 8'h36;
			Green = int'(DrawY/BrickH) * 8'h20 + int'(DrawX/BrickW) * 8'h15;
			Blue = int'(DrawY/BrickH) * 8'h1 + int'(DrawX/BrickW) * 8'h6;
		  end
		  else if(block_on == 1'b1)
		  begin
			   Red = 8'hff;
            Green = 8'hff;
            Blue = 8'hff;
		  end
        else if ((ball_on == 1'b1)) 
        begin
            // White ball
            Red = 8'hff;
            Green = 8'hff;
            Blue = 8'hff;
        end
		  else if (start_on == 1'b1)
		  begin
				if(start_in == 3'b1)
				begin
					Red = 8'hff;
					Green = 8'hff;
					Blue = 8'hff;
				end
				else
			begin	
			 case(sprite_in)
					default:
					begin
						Red = 8'h00; 
						Green = 8'h00;
						Blue = 8'h07;
					end
				3'd1:
				 begin
				 		Red = 8'h07; 
						Green = 8'h07;
						Blue = 8'h0F;
				 end
				3'd2:
				 begin
				 		Red = 8'h0F; 
						Green = 8'h07;
						Blue = 8'h0F;
				 end
				3'd3:
				 begin
				 		Red = 8'h0F; 
						Green = 8'h0B;
						Blue = 8'h0F;
				 end
				3'd4:
				 begin
				 		Red = 8'h17; 
						Green = 8'h0F;
						Blue = 8'h23;
				 end
				 3'd5:
				 begin
				 		Red = 8'h73; 
						Green = 8'h33;
						Blue = 8'h1B;
				 end
				 3'd6:
				 begin
				 		Red = 8'h87; 
						Green = 8'h3B;
						Blue = 8'h1F;
				 end
				 3'd7:
				 begin
				 		Red = 8'hBB; 
						Green = 8'h63;
						Blue = 8'h33;
				 end
				 3'd8:
				 begin
				 		Red = 8'h0B; 
						Green = 8'h13;
						Blue = 8'h33;
				 end
				 3'd9:
				 begin
				 		Red = 8'h13; 
						Green = 8'h0F;
						Blue = 8'h27;
				 end
				 
				 3'd10:
				 begin
				 		Red = 8'h1B; 
						Green = 8'h17;
						Blue = 8'h23;
				 end
				 3'd11:
				 begin
				 		Red = 8'h1F; 
						Green = 8'h17;
						Blue = 8'h3F;
				 end
				 3'd12:
				 begin
				 		Red = 8'h33; 
						Green = 8'h23;
						Blue = 8'h3F;
				 end
				 3'd13:
				 begin
				 		Red = 8'h1F; 
						Green = 8'h13;
						Blue = 8'h2F;
				 end
				 3'd14:
				 begin
				 		Red = 8'h43; 
						Green = 8'h0F;
						Blue = 8'h27;
				 end
			 endcase
        end
		  
		  end
		  else if (win_on == 1'b1)
		  begin
				if(win_in == 4'd1)
				begin
					Red = 8'hff;
					Green = 8'hff;
					Blue = 8'hff;
				end
				else
			begin	
			 case(sprite_in)
					default:
					begin
						Red = 8'h00; 
						Green = 8'h00;
						Blue = 8'h07;
					end
				3'd1:
				 begin
				 		Red = 8'h07; 
						Green = 8'h07;
						Blue = 8'h0F;
				 end
				3'd2:
				 begin
				 		Red = 8'h0F; 
						Green = 8'h07;
						Blue = 8'h0F;
				 end
				3'd3:
				 begin
				 		Red = 8'h0F; 
						Green = 8'h0B;
						Blue = 8'h0F;
				 end
				3'd4:
				 begin
				 		Red = 8'h17; 
						Green = 8'h0F;
						Blue = 8'h23;
				 end
				 3'd5:
				 begin
				 		Red = 8'h73; 
						Green = 8'h33;
						Blue = 8'h1B;
				 end
				 3'd6:
				 begin
				 		Red = 8'h87; 
						Green = 8'h3B;
						Blue = 8'h1F;
				 end
				 3'd7:
				 begin
				 		Red = 8'hBB; 
						Green = 8'h63;
						Blue = 8'h33;
				 end
				 3'd8:
				 begin
				 		Red = 8'h0B; 
						Green = 8'h13;
						Blue = 8'h33;
				 end
				 3'd9:
				 begin
				 		Red = 8'h13; 
						Green = 8'h0F;
						Blue = 8'h27;
				 end
				 
				 3'd10:
				 begin
				 		Red = 8'h1B; 
						Green = 8'h17;
						Blue = 8'h23;
				 end
				 3'd11:
				 begin
				 		Red = 8'h1F; 
						Green = 8'h17;
						Blue = 8'h3F;
				 end
				 3'd12:
				 begin
				 		Red = 8'h33; 
						Green = 8'h23;
						Blue = 8'h3F;
				 end
				 3'd13:
				 begin
				 		Red = 8'h1F; 
						Green = 8'h13;
						Blue = 8'h2F;
				 end
				 3'd14:
				 begin
				 		Red = 8'h43; 
						Green = 8'h0F;
						Blue = 8'h27;
				 end
			 endcase
        end
		  
		  end
		  else if (lose_on == 1'b1)
		  begin
				if(lose_in == 4'd1)
				begin
					Red = 8'hff;
					Green = 8'hff;
					Blue = 8'hff;
				end
				else
			begin	
			 case(sprite_in)
					default:
					begin
						Red = 8'h00; 
						Green = 8'h00;
						Blue = 8'h07;
					end
				3'd1:
				 begin
				 		Red = 8'h07; 
						Green = 8'h07;
						Blue = 8'h0F;
				 end
				3'd2:
				 begin
				 		Red = 8'h0F; 
						Green = 8'h07;
						Blue = 8'h0F;
				 end
				3'd3:
				 begin
				 		Red = 8'h0F; 
						Green = 8'h0B;
						Blue = 8'h0F;
				 end
				3'd4:
				 begin
				 		Red = 8'h17; 
						Green = 8'h0F;
						Blue = 8'h23;
				 end
				 3'd5:
				 begin
				 		Red = 8'h73; 
						Green = 8'h33;
						Blue = 8'h1B;
				 end
				 3'd6:
				 begin
				 		Red = 8'h87; 
						Green = 8'h3B;
						Blue = 8'h1F;
				 end
				 3'd7:
				 begin
				 		Red = 8'hBB; 
						Green = 8'h63;
						Blue = 8'h33;
				 end
				 3'd8:
				 begin
				 		Red = 8'h0B; 
						Green = 8'h13;
						Blue = 8'h33;
				 end
				 3'd9:
				 begin
				 		Red = 8'h13; 
						Green = 8'h0F;
						Blue = 8'h27;
				 end
				 
				 3'd10:
				 begin
				 		Red = 8'h1B; 
						Green = 8'h17;
						Blue = 8'h23;
				 end
				 3'd11:
				 begin
				 		Red = 8'h1F; 
						Green = 8'h17;
						Blue = 8'h3F;
				 end
				 3'd12:
				 begin
				 		Red = 8'h33; 
						Green = 8'h23;
						Blue = 8'h3F;
				 end
				 3'd13:
				 begin
				 		Red = 8'h1F; 
						Green = 8'h13;
						Blue = 8'h2F;
				 end
				 3'd14:
				 begin
				 		Red = 8'h43; 
						Green = 8'h0F;
						Blue = 8'h27;
				 end
			 endcase
        end
		  
		  end
		  
		  else if (heart_on_0 == 1'b1 || heart_on_1 == 1'b1 || heart_on_2 == 1'b1)begin	
			case(heart_in)
				default:

			begin	
			 case(sprite_in)
					default:
					begin
						Red = 8'h00; 
						Green = 8'h00;
						Blue = 8'h07;
					end
				3'd1:
				 begin
				 		Red = 8'h07; 
						Green = 8'h07;
						Blue = 8'h0F;
				 end
				3'd2:
				 begin
				 		Red = 8'h0F; 
						Green = 8'h07;
						Blue = 8'h0F;
				 end
				3'd3:
				 begin
				 		Red = 8'h0F; 
						Green = 8'h0B;
						Blue = 8'h0F;
				 end
				3'd4:
				 begin
				 		Red = 8'h17; 
						Green = 8'h0F;
						Blue = 8'h23;
				 end
				 3'd5:
				 begin
				 		Red = 8'h73; 
						Green = 8'h33;
						Blue = 8'h1B;
				 end
				 3'd6:
				 begin
				 		Red = 8'h87; 
						Green = 8'h3B;
						Blue = 8'h1F;
				 end
				 3'd7:
				 begin
				 		Red = 8'hBB; 
						Green = 8'h63;
						Blue = 8'h33;
				 end
				 3'd8:
				 begin
				 		Red = 8'h0B; 
						Green = 8'h13;
						Blue = 8'h33;
				 end
				 3'd9:
				 begin
				 		Red = 8'h13; 
						Green = 8'h0F;
						Blue = 8'h27;
				 end
				 
				 3'd10:
				 begin
				 		Red = 8'h1B; 
						Green = 8'h17;
						Blue = 8'h23;
				 end
				 3'd11:
				 begin
				 		Red = 8'h1F; 
						Green = 8'h17;
						Blue = 8'h3F;
				 end
				 3'd12:
				 begin
				 		Red = 8'h33; 
						Green = 8'h23;
						Blue = 8'h3F;
				 end
				 3'd13:
				 begin
				 		Red = 8'h1F; 
						Green = 8'h13;
						Blue = 8'h2F;
				 end
				 3'd14:
				 begin
				 		Red = 8'h43; 
						Green = 8'h0F;
						Blue = 8'h27;
				 end
			 endcase
        end
		  
				3'd1: begin
					Red = 8'h00;
					Green = 8'h00;
					Blue = 8'h00;
				end
				3'd2:
				begin
					Red = 8'hff;
					Green = 8'hff;
					Blue = 8'hff;
				end
				3'd3:
				begin
					Red = 8'hff;
					Green = 8'h00;
					Blue = 8'h00;
				end
			endcase
		  end
		  
        else 
        begin	
			 case(sprite_in)
					default:
					begin
						Red = 8'h00; 
						Green = 8'h00;
						Blue = 8'h07;
					end
				3'd1:
				 begin
				 		Red = 8'h07; 
						Green = 8'h07;
						Blue = 8'h0F;
				 end
				3'd2:
				 begin
				 		Red = 8'h0F; 
						Green = 8'h07;
						Blue = 8'h0F;
				 end
				3'd3:
				 begin
				 		Red = 8'h0F; 
						Green = 8'h0B;
						Blue = 8'h0F;
				 end
				3'd4:
				 begin
				 		Red = 8'h17; 
						Green = 8'h0F;
						Blue = 8'h23;
				 end
				 3'd5:
				 begin
				 		Red = 8'h73; 
						Green = 8'h33;
						Blue = 8'h1B;
				 end
				 3'd6:
				 begin
				 		Red = 8'h87; 
						Green = 8'h3B;
						Blue = 8'h1F;
				 end
				 3'd7:
				 begin
				 		Red = 8'hBB; 
						Green = 8'h63;
						Blue = 8'h33;
				 end
				 3'd8:
				 begin
				 		Red = 8'h0B; 
						Green = 8'h13;
						Blue = 8'h33;
				 end
				 3'd9:
				 begin
				 		Red = 8'h13; 
						Green = 8'h0F;
						Blue = 8'h27;
				 end
				 
				 3'd10:
				 begin
				 		Red = 8'h1B; 
						Green = 8'h17;
						Blue = 8'h23;
				 end
				 3'd11:
				 begin
				 		Red = 8'h1F; 
						Green = 8'h17;
						Blue = 8'h3F;
				 end
				 3'd12:
				 begin
				 		Red = 8'h33; 
						Green = 8'h23;
						Blue = 8'h3F;
				 end
				 3'd13:
				 begin
				 		Red = 8'h1F; 
						Green = 8'h13;
						Blue = 8'h2F;
				 end
				 3'd14:
				 begin
				 		Red = 8'h43; 
						Green = 8'h0F;
						Blue = 8'h27;
				 end
			 endcase
        end
    end 
    
endmodule
