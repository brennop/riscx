
`ifndef PARAM
  `include "params.v"
`endif

/*
 *
 *		_Controle da ALU_
 * 
 */

module ALUControl (
  input wire iALUOp,
  input wire [0:2] funct3,
  input wire [0:6] funct7,
  output oALUControl,
);

always @*
	case(iALUOp)
		OP_ADD: oALUControl <= ALU_ADD;
		OP_SUB: OALUControl <= ALU_SUB;
		OP_ANY:
			case(funct3)
				FUNCT3_ADD: 
          case(funct7)
            FUNCT7_ADD: ALUControl <= ALU_ADD;
            FUNCT7_SUB: ALUControl <= ALU_SUB;
            default:    ALUControl <= ALU_ADD;
          endcase
				FUNCT3_SLT: ALUControl <= ALU_SLT;
				FUNCT3_OR : ALUControl <= ALU_OR;
				FUNCT3_AND: ALUControl <= ALU_AND;
				default: 	ALUControl <= ALU_ADD;
			endcase
		default: oALUControl <= ALU_ADD;
	endcase

endmodule