
`ifndef PARAM
	`include "params.v"
`endif

/*
	_Controle_
*/

module Control (
	input  [6:0] opcode,
	output [9:0] oControl
);

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
			oControl <= { ORIG_IMM, OP_ADD, FALSE, TRUE, PC4, TRUE, ORIG_MEM};
		end
		/* 
			no store precisamos somar um IMM e um reg,
			escrever do banco de registradores na memória
			de dados e incrementar o PC em 4
		*/
		STORE:
		begin
			oControl <= { ORIG_IMM, OP_ADD, TRUE, FALSE, PC4, FALSE, ORIG_ALU};
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
			oControl <= { ORIG_REG, OP_ANY, FALSE, FALSE, PC4, TRUE, ORIG_ALU};
		end
		/* 
			a instrução lui (tipo U) sinaliza para ALU realizar
			uma soma, e coloca um dos operandos com o valor do
			imediato gerado. O PC é incrementado em 4 e a memória 
			de dados não é utilizada
		*/
		TIPOU:
		begin
			oControl <= { ORIG_IMM, OP_FWD, FALSE, FALSE, PC4, TRUE, ORIG_LUI};
		end
		/* 
			em um branch sinalizamos que o pc deve receber
			o valor que o branch control selecionar
		*/
		BRANCH:
		begin
			oControl <= { ORIG_IMM, OP_SUB, FALSE, FALSE, PCBEQ, FALSE, ORIG_ALU};
		end
		/* 
			em um jal sinalizamos que o pc deve receber
			o valor de pc + imm e que vamos escrever o
			valor de pc + 4 no rd
		*/
		JUMP:
		begin
			oControl <= { ORIG_IMM, OP_ADD, FALSE, FALSE, PCIMM, TRUE, ORIG_LUI};
		end
		default:
		begin
			oControl <= 10'b0;
		end
	endcase

endmodule