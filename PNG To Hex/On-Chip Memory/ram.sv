/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module  frameROM
(
		input [18:0] read_address,
		input Clk,

		output logic [3:0] data_Out
);

logic [3:0] mem [0:307199];

initial
begin
	 $readmemh("scripts/sprite_bytes/back.txt", mem);
end


always_ff @ (posedge Clk) begin
	data_Out<= mem[read_address];
end

endmodule
