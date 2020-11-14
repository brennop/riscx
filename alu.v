module ALU (
	input 		 [4:0]  iControl,
	input signed [31:0] iA, 
	input signed [31:0] iB,
	output 		 [31:0] oResult
);

parameter 
	ALU_AND 	= 4'b0000,
	ALU_OR	= 4'b0001,
	ALU_ADD	= 4'b0010,
	ALU_SUB	= 4'b0110,
	ALU_SLT 	= 4'b0111;

always @*
	case (iControl)
	begin
		ALU_AND: oResult <= iA & iB;
		ALU_OR:	oResult <= iA | iB;
		ALU_ADD: oResult <= iA + iB;
		ALU_SUB:	oResult <= iA - iB;
		ALU_SLT: oResult <= iA < iB;
	end
	endcase


endmodule