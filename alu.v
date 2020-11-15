
`ifndef PARAM
	`include "params.v"
`endif

module ALU (
	input 		 [4:0]  iControl,
	input signed [31:0] iA, 
	input signed [31:0] iB,
	output 		 [31:0] oResult
);

always @*
	case (iControl)
		ALU_AND: oResult <= iA & iB;
		ALU_OR:	oResult <= iA | iB;
		ALU_ADD: oResult <= iA + iB;
		ALU_SUB:	oResult <= iA - iB;
		ALU_SLT: oResult <= iA < iB;
		default: oResult <= iA;
	endcase


endmodule