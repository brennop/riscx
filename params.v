
`ifndef PARAM
`define PARAM

parameter
	LOAD 		= 7'b0000011,
	STORE 	= 7'b0100011,
	TIPOR 	= 7'b0110011,
	TIPOI		= 7'b0010011,
	TIPOU		= 7'b0110111,
	BRANCH	= 7'b1100011,
	JUMP		= 7'b1101111,
	
	TEXT		= 32'h00400000,
	DATA		= 32'h10010000,
	
	TRUE		= 1'b1,
	FALSE		= 1'b0,
	DONT_CARE	= 1'bx,
	
	PC4		= 2'd0,
	PCBEQ		= 2'd1,
	PCIMM		= 2'd2,
	
	ORIG_REG = 1'b0,
	ORIG_IMM	= 1'b1,
	
	ORIG_MEM = 2'd0,
	ORIG_ALU = 2'd1,
	ORIG_PC4 = 2'd2,
	ORIG_LUI = 2'd3,
	
	STATE_FETCH 	= 4'd0,
	STATE_DECODE	= 4'd1,
	STATE_LWSW		= 4'd2,
	STATE_LOAD		= 4'd3,
	STATE_LOADSAVE	= 4'd4,
	STATE_STORE		= 4'd5,
	STATE_TIPOR		= 4'd6,
	STATE_TIPORSAVE = 4'd7,
	STATE_BEQ		= 4'd8,
	STATE_JAL		= 4'd9,
	
	FUNCT3_ADD			= 3'b000,
	FUNCT3_SUB			= 3'b000,
	FUNCT3_SLT			= 3'b010,
	FUNCT3_OR			= 3'b110,
	FUNCT3_AND			= 3'b111,
	
	ALU_AND 	= 4'b0000,
	ALU_OR	= 4'b0001,
	ALU_ADD	= 4'b0010,
	ALU_SUB	= 4'b0110,
	ALU_SLT 	= 4'b0111;
	
`endif
