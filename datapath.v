
`ifndef PARAM
	`include "params.v"
`endif

module Datapath (
	input clock,
	
	/* sinais de debug */
	output reg [31:0] oInstruction,
	output reg [31:0] oRegisterRead1,
	output reg [31:0] oRegisterRead2
);

reg [31:0] pc = 32'b0;
reg [31:0] pcNext;
wire [31:0] instruction;

wire writeRegister;
wire [31:0] registerRead1, registerRead2;
wire [31:0] dataToWrite; 	// O que será escrito em Rd

wire [31:0] immediate;

wire [31:0] readData; 		// O que foi lido da mem dados

// Sinais / Fios de Controle
wire [1:0] OrigWriteData;	// Origem do que será escrito em rd
wire MemRead;					// Se vamos ler da memória de dados
wire [1:0] OrigPC;			// Origem do que será escrito em pc
wire [3:0] ALUControl;		// Instrução a ser executada na ALU
wire MemWrite;					// Se vamos escrever na mem de dados
wire OrigULA;					// Origem do segundo arg da ALU
wire RegWrite;					// Se vamos escrever em Rd

// ALU
wire [31:0] aluResult;

// Multiplexadores
always @*
	case(OrigPC)
		PC4: 		pcNext <= pc + 32'd4;
		PCBEQ: 	pcNext <= pc + 32'd4;
		PCIMM: 	pcNext <= pc + immediate;
	endcase
	
always @*
	case(OrigWriteData)
		ORIG_MEM: dataToWrite <= readData;
		ORIG_ALU: dataToWrite <= aluResult;
		ORIG_PC4: dataToWrite <= pc + 32'd4;
	endcase

	
// Instanciação das Estruturas
InstructionMemory instructionMemory (pc, instruction);

ImmediateGenerator immGen (
	.iInstruction(instruction),
	.oImmediate(immediate)
);

Registers registers (
	.clock(clock), 
	.writeRegister(writeRegister), 
	.rs1(instruction[19:15]), 
	.rs2(instruction[24:20]), 
	.rd(instruction[11:7]), 
	.registerRead1(registerRead1), 
	.registerRead2(registerRead2)
);

Control control (
	.instruction(instruction),
	.OrigWriteData(OrigWriteData),
	.MemRead(MemRead),
	.OrigPC(OrigPC),
	.ALUControl(ALUControl),
	.MemWrite(MemWrite),
	.OrigULA(OrigULA),
	.RegWrite(RegWrite)	
);


always @(posedge clock)
begin
	oInstruction <= instruction;
	oRegisterRead1 <= registerRead1;
	oRegisterRead2 <= registerRead2;
	pc <= pc + 32'h04;
end

endmodule