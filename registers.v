module Registers (
	input wire clock, writeRegister,
	input wire [4:0] rs1, rs2, rd,
	input wire [31:0] dataToWrite,
	
	output wire [31:0] registerRead1, registerRead2
);

reg [31:0] registers[31:0];

initial 
begin
	registers[0] = 32'd0;
	registers[1] = 32'd0;
	registers[2] = 32'h3fc; // SP = 255 * 4
	registers[3] = 32'd0;
	registers[4] = 32'd0;
	registers[5] = 32'd0;
	registers[6] = 32'd0;
	registers[7] = 32'd0;
	registers[8] = 32'd0;
	registers[9] = 32'd0;
	registers[10] = 32'd0;
	registers[11] = 32'd0;
	registers[12] = 32'd0;
	registers[13] = 32'd0;
	registers[14] = 32'd0;
	registers[15] = 32'd0;
	registers[16] = 32'd0;
	registers[17] = 32'd0;
	registers[18] = 32'd0;
	registers[19] = 32'd0;
	registers[20] = 32'd0;
	registers[21] = 32'd0;
	registers[22] = 32'd0;
	registers[23] = 32'd0;
	registers[24] = 32'd0;
	registers[25] = 32'd0;
	registers[26] = 32'd0;
	registers[27] = 32'd0;
	registers[28] = 32'd0;
	registers[29] = 32'd0;
	registers[30] = 32'd0;
	registers[31] = 32'd0;
end

assign registerRead1 = registers[rs1];
assign registerRead2 = registers[rs2];

always @(posedge clock) 
begin
	if(writeRegister && (rd != 5'b0)) registers[rd] <= dataToWrite;
end

endmodule