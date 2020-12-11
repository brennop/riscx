
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

// Verificações do Forward para o RS1
always @*
	begin
    // Forward da etapa de execução
		if(EX_MEM_RegWrite
			&& EX_MEM_rd != 32'b0
			&& EX_MEM_rd == rs1)
			forwardA <= FORWARD_EX_MEM;

    // Forward da etada de leitura
		else if(MEM_WB_RegWrite
			&& MEM_WB_rd != 32'b0
			&& MEM_WB_rd == rs1)
			forwardA <= FORWARD_MEM_WB;

    // nenhum forward
		else forwardA <= FORWARD_NONE;
	end

// Verificações do Forward para o RS2
always @*
	begin
    // Forward da etapa de execução
		if(EX_MEM_RegWrite
			&& EX_MEM_rd != 32'b0
			&& EX_MEM_rd == rs2)
			forwardB <= FORWARD_EX_MEM;

    // Forward da etada de leitura
		else if(MEM_WB_RegWrite
			&& MEM_WB_rd != 32'b0
			&& MEM_WB_rd == rs2)
			forwardB <= FORWARD_MEM_WB;

    // nenhum forward
		else forwardB <= FORWARD_NONE;
	end

endmodule