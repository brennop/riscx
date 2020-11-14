/* TopDE.v */

module TopDE (
	input clock,
	output [31:0] Instruction,
	output [31:0] registerRead1,
	output [31:0] registerRead2
);

wire [31:0] mInstr, mRead1, mRead2;

assign Instruction = mInstr;
assign registerRead1 = mRead1;
assign registerRead2 = mRead2;


Datapath dp (
	.clock(clock), 
	.oInstruction(mInstr), 
	.oRegisterRead1(mRead1), 
	.oRegisterRead2(mRead2)
);

endmodule
