module Datapath (
	input clock,
	
	/* sinais de debug */
	output reg [31:0] oInstruction,
	output reg [31:0] oRegisterRead1,
	output reg [31:0] oRegisterRead2
);

reg [31:0] pc = 32'b0;
wire [31:0] instruction;

wire writeRegister;
wire [31:0] registerRead1, registerRead2;

InstructionMemory instructionMemory (pc, instruction);

Registers registers (
	.clock(clock), 
	.writeRegister(writeRegister), 
	.rs1(instruction[19:15]), 
	.rs2(instruction[24:20]), 
	.rd(instruction[11:7]), 
	.registerRead1(registerRead1), 
	.registerRead2(registerRead2)
);


always @(posedge clock)
begin
	oInstruction <= instruction;
	oRegisterRead1 <= registerRead1;
	oRegisterRead2 <= registerRead2;
	pc <= pc + 32'h04;
end

endmodule