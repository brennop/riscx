
`ifndef PARAM
	`include "params.v"
`endif


/*
	ALU (Unidade Lógica e Aritmética)
*/

module ALU (
	input 		 	  [3:0]  iControl,
	input signed 	[31:0] iA, 
	input signed 	[31:0] iB,
	output 		 	  [31:0] oResult,
	output			  oZero
);

// Colocamos uma porta NOR entre todos os bits do resultado. Se todos os bits
// forem 0, o resultado será 1. Se pelo menos um bit não for zero, o resultado
// será 0.
assign oZero = ~| oResult;

// A ALU é um circuito combinacional
always @*
	// Pra cara sinal de controle definido, executamos a operação
	// correspondete, e colocamos o valor em oResult
	case (iControl)
		ALU_AND: 	oResult <= iA & iB;
		ALU_OR:		oResult <= iA | iB;
		ALU_ADD: 	oResult <= iA + iB;
		ALU_SUB:	oResult <= iA - iB;
		ALU_SLT: 	oResult <= iA < iB;
		default: 	oResult <= iA;
	endcase


endmodule