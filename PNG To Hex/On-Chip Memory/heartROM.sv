/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module  heartROM
(
		input [18:0] read_address,
		input Clk,

		output logic [3:0] data_Out
);

logic [3:0] mem [0:1023];

initial
begin
	 $readmemh("scripts/sprite_bytes/heart.txt", mem);
end


always_ff @ (posedge Clk) begin
	data_Out<= mem[read_address];
end

endmodule