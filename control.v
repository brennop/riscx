module Control (
	input [31:0] instruction,
	output wire [1:0] OrigWriteData,
	output wire MemRead,
	output wire [1:0] OrigPC,
	output wire [3:0] ALUControl,
	output wire MemWrite,
	output wire OrigULA,
	output wire RegWrite,
);

wire [6:0] opcode = instruction[6:0];
wire [2:0] funct3 = instruction[14:12];

parameter
	LOAD 		= 7'b0000011,
	STORE 	= 7'b0100011,
	TIPOR 	= 7'b0110011,
	TUPOI		= 7'b0010011,
	BRANCH	= 7'b1100011,
	JUMP		= 7'b1101111,
	
	TRUE		= 1'b1,
	FALSE		= 1'b0,
	DONT_CARE	= 1'bx,
	
	PC4		= 2'd0,
	PCBEQ		= 2'd1,
	PCIMM		= 2'd2,
	
	ORIG_REG = 1'b0,
	ORIG_IMM	= 1'b1,
	
	ORIG_MEM = 2'd0,
	ORIG_ALU = 2'd1,
	ORIG_PC4 = 2'd2,
	ORIG_ANY = 2'bxx,
	
	FUNCT3_ADD			= 3'b000,
	FUNCT3_SUB			= 3'b000,
	FUNCT3_SLT			= 3'b010,
	FUNCT3_OR			= 3'b110,
	FUNCT3_AND			= 3'b111;


always @*
	case(opcode)
	begin
		LOAD:
			OrigWriteData <= ORIG_MEM;
			MemRead <= TRUE;
			OrigPC  <= PC4;
			//TODO ALUControl <= sum??
			MemWrite <= FALSE;
			OrigULA <= ORIG_IMM;
			RegWrite <= TRUE;
		STORE:
			OrigWriteData <= ORIG_ANY;
			MemRead <= FALSE;
			OrigPC  <= PC4;
			//TODO ALUControl <= sum??
			MemWrite <= TRUE;
			OrigULA <= ORIG_IMM;
			RegWrite <= FALSE;
		TIPOR:
			OrigWriteData <= ORIG_ALU;
			MemRead <= FALSE;
			OrigPC  <= PC4;
			MemWrite <= TRUE;
			OrigULA <= ORIG_IMM;
			RegWrite <= FALSE;
			
			case(funct3)
			begin
				FUNCT3_ADD: ALUControl <= ALU_ADD;
				FUNCT3_SUB: ALUControl <= ALU_SUB;
				FUNCT3_SLT: ALUControl <= ALU_SLT;
				FUNCT3_OR : ALUControl <= ALU_OR;
				FUNCT3_AND: ALUControl <= ALU_AND;
			end
		BRANCH:
			OrigWriteData <= ORIG_ANY;
			MemRead <= FALSE;
			OrigPC  <= PCBEQ;
			ALUControl <= ALU_SUB;
			MemWrite <= FALSE;
			OrigULA <= DONT_CARE;
			RegWrite <= FALSE;
		JUMP:
			OrigWriteData <= ORIG_PC4;
			MemRead <= FALSE;
			OrigPC  <= PCIMM;
			ALUControl <= ALU_ADD;
			MemWrite <= FALSE;
			OrigULA <= DONT_CARE;
			RegWrite <= FALSE;
	end

endmodule