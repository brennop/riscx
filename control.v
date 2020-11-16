
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
	output OrigALU,
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
			OrigALU <= ORIG_IMM;
			RegWrite <= TRUE;
		end
		STORE:
		begin
			OrigWriteData <= ORIG_ALU;
			MemRead <= FALSE;
			OrigPC  <= PC4;
			ALUControl <= ALU_ADD;
			MemWrite <= TRUE;
			OrigALU <= ORIG_IMM;
			RegWrite <= FALSE;
		end
		TIPOR:
		begin
			OrigWriteData <= ORIG_ALU;
			MemRead <= FALSE;
			OrigPC  <= PC4;
			MemWrite <= FALSE;
			OrigALU <= ORIG_REG;
			RegWrite <= TRUE;
			
			case(funct3)
				FUNCT3_ADD: ALUControl <= (funct7 == 7'b0100000) ? ALU_SUB : ALU_ADD;
				FUNCT3_SLT: ALUControl <= ALU_SLT;
				FUNCT3_OR : ALUControl <= ALU_OR;
				FUNCT3_AND: ALUControl <= ALU_AND;
				default: 	ALUControl <= ALU_ADD;
			endcase
		end
		TIPOI:
		begin
			OrigWriteData <= ORIG_ALU;
			MemRead <= FALSE;
			OrigPC  <= PC4;
			MemWrite <= FALSE;
			OrigALU <= ORIG_IMM;
			RegWrite <= TRUE;
			ALUControl <= ALU_ADD;
		end
		TIPOU:
		begin
			OrigWriteData <= ORIG_LUI;
			MemRead <= FALSE;
			OrigPC  <= PC4;
			MemWrite <= FALSE;
			OrigALU <= ORIG_IMM;
			RegWrite <= TRUE;
			ALUControl <= ALU_ADD;
		end
		BRANCH:
		begin
			OrigWriteData <= ORIG_ALU;
			MemRead <= FALSE;
			OrigPC  <= PCBEQ;
			ALUControl <= ALU_SUB;
			MemWrite <= FALSE;
			OrigALU <= DONT_CARE;
			RegWrite <= FALSE;
		end
		JUMP:
		begin
			OrigWriteData <= ORIG_PC4;
			MemRead <= FALSE;
			OrigPC  <= PCIMM;
			ALUControl <= ALU_ADD;
			MemWrite <= FALSE;
			OrigALU <= DONT_CARE;
			RegWrite <= FALSE;
		end
		default:
		begin
			OrigWriteData <= ORIG_ALU;
			MemRead <= DONT_CARE;
			OrigPC  <= ORIG_ALU;
			ALUControl <= ALU_ADD;
			MemWrite <= DONT_CARE;
			OrigALU <= DONT_CARE;
			RegWrite <= DONT_CARE;
		end
	endcase

endmodule