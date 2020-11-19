
`ifndef PARAM
	`include "params.v"
`endif

/*
	_Controle_
*/

module Control (
	input 	[31:0] instruction,
	output 	[1:0] OrigWriteData,
	output 	MemRead,
	output 	[1:0] OrigPC,
	output 	[3:0] ALUControl,
	output 	MemWrite,
	output 	OrigALU,
	output 	RegWrite
);

// Sinais úteis para definir a saída do controle
wire [6:0] opcode = instruction[6:0];
wire [2:0] funct3 = instruction[14:12];
wire [6:0] funct7	= instruction[31:25];

// O controle é um circuito combinacional
// depende apenas do opcode, funct3 e funct7
always @*
	case(opcode)
		/* 
			no load precisamos somar um IMM e um reg,
			ler da memória de dados, escrever da memória
			de dados no banco de registradores e incrementar 
		 	PC em 4 
		*/
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
		/* 
			no store precisamos somar um IMM e um reg,
			escrever do banco de registradores na memória
			de dados e incrementar o PC em 4
		*/
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
		/* 
			nas instruções Tipo-R (add, sub, and, or, slt),
		 	precisamos operar dois regs (OrigALU = ORIG_REG),
			verificar o funct3 e o funct7 para mandar o sinal
			ALUControl correto, e não usamos a memória de dados
			o PC é incrementado em 4.
		*/
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
		/* 
			a instrução lui (tipo U) sinaliza para ALU realizar
			uma soma, e coloca um dos operandos com o valor do
			imediato gerado. O PC é incrementado em 4 e a memória 
			de dados não é utilizada
		*/
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
		/* 
			em um branch sinalizamos que o pc deve receber
			o valor que o branch control selecionar
		*/
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
		/* 
			em um jal sinalizamos que o pc deve receber
			o valor de pc + imm e que vamos escrever o
			valor de pc + 4 no rd
		*/
		JUMP:
		begin
			OrigWriteData <= ORIG_PC4;
			MemRead <= FALSE;
			OrigPC  <= PCIMM;
			ALUControl <= ALU_ADD;
			MemWrite <= FALSE;
			OrigALU <= DONT_CARE;
			RegWrite <= TRUE;
		end
		default:
		begin
			OrigWriteData <= ORIG_ALU;
			MemRead <= DONT_CARE;
			OrigPC  <= PC4;
			ALUControl <= ALU_ADD;
			MemWrite <= DONT_CARE;
			OrigALU <= DONT_CARE;
			RegWrite <= DONT_CARE;
		end
	endcase

endmodule