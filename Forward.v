
`ifndef PARAM
  `include "params.v"
`endif

/*
 *
 *		Unidade de Forwarding
 * 
 */

module ForwardingUnit (
  input wire [4:0] rs1,
  input wire [4:0] rs2,
  
  input wire [4:0] EX_MEM_rd,
  input wire [4:0] MEM_WB_rd,
  
  input EX_MEM_RegWrite,
  input MEM_WB_RegWrite,
  
  output [1:0] forwardA,
  output [1:0] forwardB
);

always @*
	begin
		if(EX_MEM_RegWrite
			&& EX_MEM_rd != 32'b0
			&& EX_MEM_rd == rs1)
			forwardA <= FORWARD_EX_MEM;

		else if(MEM_WB_RegWrite
			&& MEM_WB_rd != 32'b0
			&& MEM_WB_rd == rs1)
			forwardA <= FORWARD_MEM_WB;

		else forwardA <= FORWARD_NONE;
	end

always @*
	begin
		if(EX_MEM_RegWrite
			&& EX_MEM_rd != 32'b0
			&& EX_MEM_rd == rs2)
			forwardB <= FORWARD_EX_MEM;

		else if(MEM_WB_RegWrite
			&& MEM_WB_rd != 32'b0
			&& MEM_WB_rd == rs2)
			forwardB <= FORWARD_MEM_WB;

		else forwardB <= FORWARD_NONE;
	end

endmodule