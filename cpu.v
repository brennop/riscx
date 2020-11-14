/*
 * CPU
 *
 */
 
 module CPU (
	input clock,
	output reg [31:0] oInstruction,
	output [31:0] registerRead1,
	output [31:0] registerRead2
);

reg [31:0] pc = 32'b0;
wire [31:0] instruction;

InstructionMemory instructionMemory (pc, instruction);


always @(posedge clock)
begin
	oInstruction <= instruction;
end

endmodule