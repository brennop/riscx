
`ifndef PARAM
	`include "params.v"
`endif


/*
	ALU (Unidade Lógica e Aritmética)
*/

module ALU (
	input 		 		[4:0]  iControl,
	input signed 	[31:0] iA, 
	input signed 	[31:0] iB,
	output 		 		[31:0] oResult
);

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