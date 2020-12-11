
`ifndef PARAM
  `include "params.v"
`endif

/*
 *
 *		Unidade de Detecção de Hazards
 * 
 */

module HazardDetection (
  input wire [6:0] opcode,
  input wire [4:0] rs1, rs2,
  input wire [4:0] ID_EX_rd,
  
  input wire ID_EX_MemRead,
  input wire EQ,
  
  output ControlReset,
  output PCWrite,
  output IF_IDWrite,
  output IF_Flush
);


// Operação seguida de LOAD
// com registrador indisponível
always @*
begin
  // Se há está ocorrento uma leitura
  // em um registrador que será utilizado
	if(ID_EX_MemRead && 
		(ID_EX_rd == rs1 || 
		 ID_EX_rd == rs2 ))
		 begin
       // Seta o mux para zerar o controle
			ControlReset <= TRUE;
      // Desativa o write das duas primeiras etapas
      // para realizar um stall
			IF_IDWrite 	 <= FALSE;
			PCWrite 		 <= FALSE;
		 end

  // funcionamento normal
	else
		begin
			ControlReset <= FALSE;
			IF_IDWrite 	 <= TRUE;
			PCWrite 		 <= TRUE;
		end
end

// Branch será realizado
assign IF_Flush = (opcode == BRANCH && EQ);

endmodule