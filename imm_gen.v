
`ifndef PARAM
	`include "params.v"
`endif

module ImmediateGenerator (
	input [31:0] iInstruction,
	output logic [31:0] oImmediate
);

always @*
	case (iInstruction[6:0])
		LOAD, TIPOI:
			oImmediate <= {{20{iInstruction[31]}}, iInstruction[31:20]};
		STORE:
			oImmediate <= {{20{iInstruction[31]}}, iInstruction[31:25], iInstruction[11:7]};
		JUMP:
			oImmediate <= {{12{iInstruction[31]}}, iInstruction[19:12], iInstruction[20], iInstruction[30:21], 1'b0};
		BRANCH:
			oImmediate <= {{20{iInstruction[31]}}, iInstruction[7], iInstruction[30:25], iInstruction[11:8], 1'b0};
		default:
			oImmediate <= 32'b0;
	endcase
endmodule