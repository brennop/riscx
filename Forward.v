
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
  
  input wire [4:0] EX_MEM.rd,
  input wire [4:0] MEM_WB.rd,
  
  input EX_MEM.RegWrite,
  input MEM_WB.RegWrite,
  
  output [1:0] forwardA,
  output [1:0] forwardB,
);


if(EX_MEM.RegWrite
	&& EX_MEM.rd != 32'b0
	&& EX_MEM.rd == rs1))
	assign forwardA = FORWARD_EX_MEM;

else if(MEM_WB.RegWrite
	&& MEM_WB.rd != 32'b0
	&& MEM_WB.rd == rs1))
	assign forwardA = FORWARD_MEM_WB;

else assign forwardA = FORWARD_NONE;

if(EX_MEM.RegWrite
	&& EX_MEM.rd != 32'b0
	&& EX_MEM.rd == rs2))
	assign forwardB = FORWARD_EX_MEM;

else if(MEM_WB.RegWrite
	&& MEM_WB.rd != 32'b0
	&& MEM_WB.rd == rs2))
	assign forwardB = FORWARD_MEM_WB;

else assign forwardB = FORWARD_NONE;

endmodule