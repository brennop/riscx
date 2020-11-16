
`ifndef PARAM
	`include "params.v"
`endif

module Datapath (
	input clock,
	
	/* sinais de debug */
	output [31:0] oPC,
	output [31:0] oInstruction,
	output [31:0] oRegisterRead1,
	output [31:0] oRegisterRead2,
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
	output [31:0] dImmediate,
	output [31:0] Register
//	output [31:0] RAM [0:3]
);

reg [31:0] pc = 32'b0;

wire [31:0] pcNext;
wire [31:0] pc4;
wire [31:0] pcImm;

wire [31:0] instruction;

wire [31:0] registerRead1, 
				registerRead2;
wire [31:0] dataToWrite; 	// O que será escrito em Rd

wire [31:0] immediate;

wire [31:0] readData; 		// O que foi lido da mem dados

wire [31:0] aluInputB;

// Sinais / Fios de Controle
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

// Multiplexadores
always @*
	case(OrigPC)
		PC4: 		pcNext <= pc4;
		PCBEQ: 	pcNext <= (registerRead1 == registerRead2 ? pcImm : pc4);
		PCIMM: 	pcNext <= pcImm;
		default: pcNext <= pc4;
	endcase
	
always @*
	case(OrigWriteData)
		ORIG_MEM: dataToWrite <= readData;
		ORIG_ALU: dataToWrite <= aluResult;
		ORIG_PC4: dataToWrite <= pc4;
		ORIG_LUI: dataToWrite <= immediate;
	endcase

always @*
	case(OrigALU)
		ORIG_REG: aluInputB <= registerRead2;
		ORIG_IMM: aluInputB <= immediate;
	endcase

	
// Instanciação das Estruturas
InstructionMemory instructionMemory (
	.address(pc), 
	.instruction(instruction)
);

DataMemory dataMemory (
	.clock(clock),
	.write(MemWrite),
	.read(MemRead),
	.iAddress(aluResult),
	.iData(registerRead2),
	.oData(readData)
//	.RAM(RAM)
);

ImmediateGenerator immGen (
	.iInstruction(instruction),
	.oImmediate(immediate)
);

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

ALU alu (
	.iControl(ALUControl),
	.iA(registerRead1),
	.iB(aluInputB),
	.oResult(aluResult)
);

assign oInstruction = instruction;
assign oRegisterRead1 = registerRead1;
assign oRegisterRead2 = registerRead2;
assign oDataRead = readData;
assign oPC = pc;

assign dOrigWriteData = OrigWriteData;
assign dMemRead = MemRead;
assign dOrigPC = OrigPC;
assign dALUControl = ALUControl;
assign dMemWrite = MemWrite;
assign dOrigALU = OrigALU;
assign dRegWrite = RegWrite;

assign dAluResult = aluResult;
assign dImmediate = immediate;

assign oDataToWrite = dataToWrite;

always @(posedge clock)
begin
	pc <= pcNext;
end

endmodule