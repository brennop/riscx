/* TopDE.v */


`ifndef PARAM
	`include "params.v"
`endif

module TopDE (
	input clock,
	output [31:0] Instruction,
//	output [31:0] registerRead1,
//	output [31:0] registerRead2,
	output [31:0] PC,
	output [31:0] ReadData,
	output [31:0] dataToWrite,
//	
//	output [4:0] RS1,
//	output [4:0] RS2,
//	output [4:0] Rd,
//	
	output [1:0] OrigWriteData,
	output MemRead,
	output [1:0] OrigPC,
	output [3:0] ALUControl,
	output MemWrite,
	output OrigULA,
	output RegWrite,
//	
	output [31:0] AluResult,
	output [31:0] Register
//	output [31:0] Immediate,
);

//assign RS1 = Instruction[19:15];
//assign RS2 = Instruction[24:20];
//assign Rd = Instruction[11:7];


Uniciclo uniciclo (
	.clock(clock), 
	.oInstruction(Instruction), 
//	.oRegisterRead1(registerRead1), 
//	.oRegisterRead2(registerRead2),
	.oPC(PC),
	.oDataRead(ReadData),
	.oDataToWrite(dataToWrite),
//	
	.dOrigWriteData(OrigWriteData),
	.dMemRead(MemRead),
	.dOrigPC(OrigPC),
	.dALUControl(ALUControl),
	.dMemWrite(MemWrite),
	.dOrigALU(OrigULA),
	.dRegWrite(RegWrite),
//	
	.dAluResult(AluResult),
	.Register(Register)
//	.dImmediate(Immediate),
//	.RAM(RAM)
);

endmodule
