
`ifndef PARAM
	`include "params.v"
`endif

/*
	_Datapath do Uniciclo_
*/

module Uniciclo (
	input clock,
	
	/* sinais de debug */
	output [31:0] oPC,
	output [31:0] oInstruction,
	output [31:0] oDataRead,
	output [31:0] oDataToWrite,
		
	output [1:0] dOrigWriteData,
	output dMemRead,
	output [1:0] dOrigPC,
	output [3:0] dALUControl,
	output dMemWrite,
	output dOrigALU,
	output dRegWrite,
	
	output [31:0] dAluResult,
	output [31:0] Register
);

// Nosso PC é um registrador de 32 bits
reg [31:0] pc = 32'b0;

/*
 * Fios do Datapath
 */
wire [31:0] pcNext;				// O que será escrito em PC
wire [31:0] pc4;					// PC + 4
wire [31:0] pcImm;				// PC + immediate

wire [31:0] instruction; 	// instrução que foi buscada da memória de instr.

wire [31:0] registerRead1,	// O que foi lido de RS1 
						registerRead2;	// O que foi lido de RS2

wire [31:0] dataToWrite; 		// O que será escrito em Rd

wire [31:0] immediate;		// Imediato gerado
wire [31:0] readData; 		// O que foi lido da mem dados
wire [31:0] aluInputB;		// Segunda entrada da ALU (Immediate/Register)

/*
 * Sinais/Fios do Controle
 */
wire [1:0] OrigWriteData;	// Origem do que será escrito em rd
wire MemRead;					// Se vamos ler da memória de dados
wire [1:0] OrigPC;			// Origem do que será escrito em pc
wire [3:0] ALUControl;		// Instrução a ser executada na ALU
wire MemWrite;					// Se vamos escrever na mem de dados
wire OrigALU;					// Origem do segundo arg da ALU
wire RegWrite;					// Se vamos escrever em Rd

// ALU
wire [31:0] aluResult;

assign pc4 = pc + 4;
assign pcImm = pc + immediate;

/*
 * Multiplexadores
 */

 // O que será escrito em PC
always @*
	case(OrigPC)
		PC4: 			pcNext <= pc4;
		PCBEQ: 		pcNext <= (registerRead1 == registerRead2 ? pcImm : pc4);
		PCIMM: 		pcNext <= pcImm;
		default: 	pcNext <= pc4;
	endcase
	
 // O que será escrito em rd 
always @*
	case(OrigWriteData)
		ORIG_MEM: dataToWrite <= readData;
		ORIG_ALU: dataToWrite <= aluResult;
		ORIG_PC4: dataToWrite <= pc4;
		ORIG_LUI: dataToWrite <= immediate;
	endcase

 // Segunda entrada da ALU
always @*
	case(OrigALU)
		ORIG_REG: aluInputB <= registerRead2;
		ORIG_IMM: aluInputB <= immediate;
	endcase

	
/*
 * Estruturas / Módulos
 */

// Memória de Instruções
InstructionMemory instructionMemory (
	.address(pc), 
	.instruction(instruction)
);

// Memória de Dados
DataMemory dataMemory (
	.clock(clock),
	.write(MemWrite),
	.read(MemRead),
	.iAddress(aluResult),
	.iData(registerRead2),
	.oData(readData)
);

// Gerador de Imediatos
ImmediateGenerator immGen (
	.iInstruction(instruction),
	.oImmediate(immediate)
);

// Banco de Registradores
Registers registers (
	.clock(clock), 
	.writeRegister(RegWrite), 
	.rs1(instruction[19:15]), 
	.rs2(instruction[24:20]), 
	.rd(instruction[11:7]), 
	.registerRead1(registerRead1), 
	.registerRead2(registerRead2),
	.dataToWrite(dataToWrite),
	.watch(Register)
);

// Controle
Control control (
	.instruction(instruction),
	.OrigWriteData(OrigWriteData),
	.MemRead(MemRead),
	.OrigPC(OrigPC),
	.ALUControl(ALUControl),
	.MemWrite(MemWrite),
	.OrigALU(OrigALU),
	.RegWrite(RegWrite)	
);

// ALU (ULA)
ALU alu (
	.iControl(ALUControl),
	.iA(registerRead1),
	.iB(aluInputB),
	.oResult(aluResult)
);

/*
  Colocamos o valor do próximo PC em
	PC na borda de subida do clock 
	(fim/início de um ciclo)
*/
always @(posedge clock)
begin
	pc <= pcNext;
end

/*
 * Sinais de Debug/Saída
 */

assign oPC = pc;
assign oInstruction = instruction;
assign oDataRead = readData;
assign oDataToWrite = dataToWrite;

assign dOrigWriteData = OrigWriteData;
assign dMemRead = MemRead;
assign dOrigPC = OrigPC;
assign dALUControl = ALUControl;
assign dMemWrite = MemWrite;
assign dOrigALU = OrigALU;
assign dRegWrite = RegWrite;

assign dAluResult = aluResult;
assign dImmediate = immediate;

endmodule