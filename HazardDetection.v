
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
	if(ID_EX_MemRead && 
		(ID_EX_rd == rs1 || 
		 ID_EX_rd == rs2 ))
		 begin
			ControlReset <= TRUE;
			IF_IDWrite 	 <= FALSE;
			PCWrite 		 <= FALSE;
		 end

	else
		begin
			ControlReset <= FALSE;
			IF_IDWrite 	 <= TRUE;
			PCWrite 		 <= TRUE;
		end
end

assign IF_Flush = (opcode == BRANCH && EQ);

endmodule