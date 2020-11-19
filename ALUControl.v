
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
  input wire [2:0] funct3,
  input wire [6:0] funct7,
  output oALUControl
);

always @*
	case(iALUOp)
		OP_ADD: oALUControl <= ALU_ADD;
		OP_SUB: oALUControl <= ALU_SUB;
		OP_ANY:
			case(funct3)
				FUNCT3_ADD: 
          case(funct7)
            FUNCT7_ADD: oALUControl <= ALU_ADD;
            FUNCT7_SUB: oALUControl <= ALU_SUB;
            default:    oALUControl <= ALU_ADD;
          endcase
				FUNCT3_SLT: oALUControl <= ALU_SLT;
				FUNCT3_OR : oALUControl <= ALU_OR;
				FUNCT3_AND: oALUControl <= ALU_AND;
				default: 	oALUControl <= ALU_ADD;
			endcase
		default: oALUControl <= ALU_ADD;
	endcase

endmodule