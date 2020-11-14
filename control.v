
`ifndef PARAM
	`include "params.v"
`endif

module Control (
	input [31:0] instruction,
	output [1:0] OrigWriteData,
	output MemRead,
	output [1:0] OrigPC,
	output [3:0] ALUControl,
	output MemWrite,
	output OrigULA,
	output RegWrite
);

wire [6:0] opcode = instruction[6:0];
wire [2:0] funct3 = instruction[14:12];
wire [6:0] funct7	= instruction[31:25];

always @*
	case(opcode)
		LOAD:
		begin
			OrigWriteData <= ORIG_MEM;
			MemRead <= TRUE;
			OrigPC  <= PC4;
			ALUControl <= ALU_ADD;
			MemWrite <= FALSE;
			OrigULA <= ORIG_IMM;
			RegWrite <= TRUE;
		end
		STORE:
		begin
			OrigWriteData <= ORIG_ANY;
			MemRead <= FALSE;
			OrigPC  <= PC4;
			ALUControl <= ALU_ADD;
			MemWrite <= TRUE;
			OrigULA <= ORIG_IMM;
			RegWrite <= FALSE;
		end
		TIPOR:
		begin
			OrigWriteData <= ORIG_ALU;
			MemRead <= FALSE;
			OrigPC  <= PC4;
			MemWrite <= TRUE;
			OrigULA <= ORIG_IMM;
			RegWrite <= TRUE;
			
			case(funct3)
				FUNCT3_ADD: ALUControl <= (funct7 == 7'b0100000) ? ALU_SUB : ALU_ADD;
				FUNCT3_SLT: ALUControl <= ALU_SLT;
				FUNCT3_OR : ALUControl <= ALU_OR;
				FUNCT3_AND: ALUControl <= ALU_AND;
				default: 	ALUControl <= ALU_ADD;
			endcase
		end
		BRANCH:
		begin
			OrigWriteData <= ORIG_ANY;
			MemRead <= FALSE;
			OrigPC  <= PCBEQ;
			ALUControl <= ALU_SUB;
			MemWrite <= FALSE;
			OrigULA <= DONT_CARE;
			RegWrite <= FALSE;
		end
		JUMP:
		begin
			OrigWriteData <= ORIG_PC4;
			MemRead <= FALSE;
			OrigPC  <= PCIMM;
			ALUControl <= ALU_ADD;
			MemWrite <= FALSE;
			OrigULA <= DONT_CARE;
			RegWrite <= FALSE;
		end
		default:
		begin
			OrigWriteData <= ORIG_ANY;
			MemRead <= DONT_CARE;
			OrigPC  <= ORIG_ANY;
			ALUControl <= ALU_ADD;
			MemWrite <= DONT_CARE;
			OrigULA <= DONT_CARE;
			RegWrite <= DONT_CARE;
		end
	endcase

endmodule