//-------------------------------------------------------------------------
//      lab7_usb.sv                                                      --
//      Christine Chen                                                   --
//      Fall 2014                                                        --
//                                                                       --
//      Fall 2014 Distribution                                           --
//                                                                       --
//      For use with ECE 385 Lab 7                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module lab8( input               CLOCK_50,
             input        [3:0]  KEY,          //bit 0 is set up as Reset
             output logic [6:0]  HEX0, HEX1,
             // VGA Interface 
             output logic [7:0]  VGA_R,        //VGA Red
                                 VGA_G,        //VGA Green
                                 VGA_B,        //VGA Blue
             output logic        VGA_CLK,      //VGA Clock
                                 VGA_SYNC_N,   //VGA Sync signal
                                 VGA_BLANK_N,  //VGA Blank signal
                                 VGA_VS,       //VGA virtical sync signal
                                 VGA_HS,       //VGA horizontal sync signal
             // CY7C67200 Interface
             inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
             output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
             output logic        OTG_CS_N,     //CY7C67200 Chip Select
                                 OTG_RD_N,     //CY7C67200 Write
                                 OTG_WR_N,     //CY7C67200 Read
                                 OTG_RST_N,    //CY7C67200 Reset
           //  input               OTG_INT,      //CY7C67200 Interrupt
             // SDRAM Interface for Nios II Software
             output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
             inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
             output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
             output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
             output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
                                 DRAM_CAS_N,   //SDRAM Column Address Strobe
                                 DRAM_CKE,     //SDRAM Clock Enable
                                 DRAM_WE_N,    //SDRAM Write Enable
                                 DRAM_CS_N,    //SDRAM Chip Select
                                 DRAM_CLK      //SDRAM Clock
                    );
    
    logic Reset_h, Clk;
    logic [15:0] keycode;
    
    assign Clk = CLOCK_50;
    assign {Reset_h} = ~(KEY[0]);  // The push buttons are active low
    
    logic [1:0] hpi_addr;
    logic [15:0] hpi_data_in, hpi_data_out;
    logic hpi_r, hpi_w,hpi_cs;
    logic [3:0] data_Out, heart_Out;
	 logic [3:0]start_Out, win_Out, lose_Out;
	 
	frameROM frame(.read_address(read_addr), 
						.Clk(Clk), 
						.data_Out(data_Out)
						);
						
	startROM start(.read_address(start_addr), 
						.Clk(Clk), 
						.data_Out(start_Out)
						);
						
	winROM win(.read_address(win_addr), 
					.Clk(Clk), 
					.data_Out(win_Out));
					
	GameOverROM losegame(.read_address(lose_addr), 
					.Clk(Clk), 
					.data_Out(lose_Out));
					
					
	heartROM hearts(.read_address(heart_addr), 
					.Clk(Clk), 
					.data_Out(heart_Out));
					
    // Interface between NIOS II and EZ-OTG chip
    hpi_io_intf hpi_io_inst(
                            .Clk(Clk),
                            .Reset(Reset_h),
                            // signals connected to NIOS II
                            .from_sw_address(hpi_addr),
                            .from_sw_data_in(hpi_data_in),
                            .from_sw_data_out(hpi_data_out),
                            .from_sw_r(hpi_r),
                            .from_sw_w(hpi_w),
                            .from_sw_cs(hpi_cs),
                            // signals connected to EZ-OTG chip
                            .OTG_DATA(OTG_DATA),    
                            .OTG_ADDR(OTG_ADDR),    
                            .OTG_RD_N(OTG_RD_N),    
                            .OTG_WR_N(OTG_WR_N),    
                            .OTG_CS_N(OTG_CS_N),    
                            .OTG_RST_N(OTG_RST_N),   
 //                           .OTG_INT(OTG_INT)
    );
     
     //The connections for nios_system might be named different depending on how you set up Qsys
     nios_system nios_system(
                             .clk_clk(Clk),         
                             .reset_reset_n(KEY[0]),   
                             .sdram_wire_addr(DRAM_ADDR), 
                             .sdram_wire_ba(DRAM_BA),   
                             .sdram_wire_cas_n(DRAM_CAS_N),
                             .sdram_wire_cke(DRAM_CKE),  
                             .sdram_wire_cs_n(DRAM_CS_N), 
                             .sdram_wire_dq(DRAM_DQ),   
                             .sdram_wire_dqm(DRAM_DQM),  
                             .sdram_wire_ras_n(DRAM_RAS_N),
                             .sdram_wire_we_n(DRAM_WE_N), 
                             .sdram_out_clk(DRAM_CLK),
                             .keycode_export(keycode),  
                             .otg_hpi_address_export(hpi_addr),
                             .otg_hpi_data_in_port(hpi_data_in),
                             .otg_hpi_data_out_port(hpi_data_out),
                             .otg_hpi_cs_export(hpi_cs),
                             .otg_hpi_r_export(hpi_r),
                             .otg_hpi_w_export(hpi_w)
    );
    
	 
	 logic [9:0] BallX, BallY, BallS, DrawX, DrawY, BlockX, BlockY, BlockW, BlockH, BrickX, BrickY, BrickW, BrickH;
	 logic frame_clk, Brick_Broke;
	 int BreakX, BreakY;
	 assign VGA_VS = frame_clk;
	 int ball_start, lose, wingame, heart;
	 

	 
    //Fill in the connections for the rest of the modules 
    VGA_controller vga_controller_instance(.Clk(Clk), 
														 .Reset(Reset_h), 
														 .VGA_HS(VGA_HS), 
														 .VGA_VS(frame_clk), 
														 .VGA_CLK(VGA_CLK), 
														 .VGA_BLANK_N(VGA_BLANK_N), 
														 .VGA_SYNC_N(VGA_SYNC_N),
														 .DrawX(DrawX),
														 .DrawY(DrawY)
														 );
   
    ball ball_instance(.Reset(Reset_h), 
							  .frame_clk(frame_clk),
							  .key(keycode[7:0]), 
							  .BallX(BallX), 
							  .BallY(BallY), 
							  .BallS(BallS),
							  				.BlockX(BlockX), 
											.BlockY(BlockY), 
											.BlockW(BlockW), 
											.BlockH(BlockH),
											.BrickX(BrickX), 
											.BrickY(BrickY), 
											.BrickW(BrickW), 
											.BrickH(BrickH),
							.Bricks(Bricks),
							.Brick_Broke(Brick_Broke),
							.BreakX(BreakX), 
							.BreakY(BreakY),
							.ball_start(ball_start),
							.wingame(wingame),
							.Block_X_Motion(Block_X_Motion_Out),
							.lose(lose),
							.lives_count(lives_count)
							);
							int lives_count;
											
							  
    block block_instance(.Reset(Reset_h),
								 .frame_clk(frame_clk),          // The clock indicating a new frame (~60Hz)
								 .key(keycode[7:0]),
								 .BlockX(BlockX), 
								 .BlockY(BlockY), 
								 .BlockW(BlockW), 
								 .BlockH(BlockH),
								 .Block_X_Motion_Out(Block_X_Motion_Out)
								 ); // Block coordinates and size)
			logic[9:0] Block_X_Motion_Out;
			int Bricks[4][10];
	 Brick brick_instance(.Reset(Reset_h),
								 .frame_clk(frame_clk),								 // The clock indicating a new frame (~60Hz)
								 .BreakX(BreakX), 
								 .BreakY(BreakY),
								 .Brick_Broke(Brick_Broke),
								 .Bricks(Bricks),
								 .BrickX(BrickX),
								 .BrickY(BrickY), 
								 .BrickW(BrickW), 
								 .BrickH(BrickH), // brick coordinates of top left corner and size of individual brick
								 .keycode(keycode)
              );
				  
				  
    color_mapper color_instance(.BallX(BallX), 
										  .BallY(BallY), 
										  .BallS(BallS), 
										  .DrawX(DrawX), 
										  .DrawY(DrawY),
										  .VGA_R(VGA_R),
										  .VGA_G(VGA_G),
										  .VGA_B(VGA_B),
											.BlockX(BlockX), 
											.BlockY(BlockY), 
											.BlockW(BlockW), 
											.BlockH(BlockH),
											.BrickX(BrickX), 
											.BrickY(BrickY), 
											.BrickW(BrickW), 
											.BrickH(BrickH),
											.Bricks(Bricks),
											.sprite_in(data_Out),
											.read_addr(read_addr),
											.start_in(start_Out),
											.start_addr(start_addr),
											.ball_start(ball_start),
											.lose(lose),
											.wingame(wingame),
											.win_in(win_Out),
											.win_addr(win_addr),
											.lose_addr(lose_addr),
											.lose_in(lose_Out),
											.heart_in(heart_Out),
											.heart_addr(heart_addr),
											.lives_count(lives_count)
											
										  );
										  
    logic[18:0] read_addr, heart_addr;
	 logic[18:0] start_addr, win_addr, lose_addr;
	 
    HexDriver hex_inst_0 (keycode[3:0], HEX0);
    HexDriver hex_inst_1 (keycode[7:4], HEX1);
    
endmodule



