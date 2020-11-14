module Control (
	input [31:0] instruction,
	output wire Mem2Reg,
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
	
	PC4		= 2'b0,
	PCBEQ		= 2'b1,
	PCIMM		= 2'b2,
	
	ORIG_REG = 1'b0,
	ORIG_IMM	= 1'b1,
	
	FUNCT3_ADD			= 3'b000,
	FUNCT3_SUB			= 3'b000,
	FUNCT3_SLT			= 3'b010,
	FUNCT3_OR			= 3'b110,
	FUNCT3_AND			= 3'b111;


always @*
	case(opcode)
	begin
		LOAD:
			Mem2Reg <= TRUE;
			MemRead <= TRUE;
			OrigPC  <= PC4;
			//TODO ALUControl <= sum??
			MemWrite <= FALSE;
			OrigULA <= ORIG_IMM;
			RegWrite <= TRUE;
		STORE:
			Mem2Reg <= DONT_CARE;
			MemRead <= FALSE;
			OrigPC  <= PC4;
			//TODO ALUControl <= sum??
			MemWrite <= TRUE;
			OrigULA <= ORIG_IMM;
			RegWrite <= FALSE;
		TIPOR:
			Mem2Reg <= FALSE;
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
			Mem2Reg <= DONT_CARE;
			MemRead <= FALSE;
			OrigPC  <= PCBEQ;
			ALUControl <= ALU_SUB;
			MemWrite <= FALSE;
			OrigULA <= ORIG_REG;
			RegWrite <= FALSE;
		JUMP:
	end

endmodule