
`ifndef PARAM
	`include "params.v"
`endif

/*
	_Datapath do Multiciclo_
*/

module Multiciclo (
	input clock,
	
  // Outputs de DEBUG
	output [31:0] dInstruction,
	input [4:0] dRegisterToWatch,
	output [31:0] dRegister,
	
	output [31:0] dAddress,
	output [31:0] dAddressMapped,
	output [31:0] dReadData,
	
	output [3:0]  dState,
	output [31:0] dAluResult,
	
	output [6:0] f7,
	output [2:0] f3,
	output [3:0] dAluControl,
	output [3:0] dAluOp,

	output [31:0] dImmediate
);

/*
 *		Registradores
 */
 
reg [31:0] PC = TEXT; // PC
reg [31:0] CurrentPC; // PCback

reg [31:0] InstructionRegister; // Registrador de Instrução
reg [31:0] DataRegister;        // Registrador de Dados

reg [31:0] RegisterReadA;       // Dado lido do registrador
reg [31:0] RegisterReadB;       // Dado lido do registrador

reg [31:0] ALURegister; // Saida da ULA

/*
 *		Sinais/Fios do Datapath
 */
 
wire [31:0]	nextData;			 
wire [31:0] address;				    // Endereço da memória
wire [31:0] readData;			      // Dado lido da memória
wire [31:0] registerInputData;  // Dado a ser escrito em rd
wire [31:0] immediate;			    // Imediato gerado 

wire [31:0] registerReadA;      // Dado lido do registrador
wire [31:0] RegisterReadB;      // Dado lido do registrador

wire [31:0] aluInputA;          // Entrada da ULA
wire [31:0] aluInputB;          // Entrada da ULA
wire [31:0] aluResult;          // Resultado da ULA
wire zero;


/*
 *		Instrução
 */
 
wire [6:0]	opcode;
wire [2:0]	funct3;
wire [6:0]	funct7;
wire [4:0]	rs1;
wire [4:0]	rs2;
wire [4:0]	rd;

always @*
begin
	opcode <= InstructionRegister[6:0];
	funct3 <= InstructionRegister[14:12];
	funct7 <= InstructionRegister[31:25];
	rs1	   <= InstructionRegister[19:15];
	rs2	   <= InstructionRegister[24:20];
	rd     <= InstructionRegister[11:7];
end

/*
 *		Sinais do Controle
 */
wire WriteMemory;						// Sinal de habilitação de escrita na memória
wire ReadMemory;						// Sinal de habilitação de leitura da memória
wire WriteInstructionRegister;	// Sinal de habilitação de escrita no reg de instrução
wire WriteRegister;					// Sinal de habilitação de escrita no banco de registradores
wire WriteCurrentPC;					// Sinal de habilitação de escrita no CurrentPC
wire WritePC;							// Sinal de habilitação de escrita no PC

wire 		  Branch;							// Sinal de controle indicando um branch (WritePCCond)
wire [0:1] ALUOp;								// Sinal de controle para o controlador da ALU
wire [3:0] ALUControlSignal;				// Sinal de controle para a ALU

wire 		  MemoryAddressOrigin;			// Origem do Endereço da memória
wire [0:1] RegisterInputOrigin;			// Origem do dado a ser escrito em rd
wire [0:1] ALUInputAOrigin;				//	Origem do input A da ALU
wire [0:1] ALUInputBOrigin;				// Origem do input B da ALU
wire 		  PCOrigin;							// Origem do dado a ser escrito em PC

/*
 *		Multiplexadores
 */

// Origem do que será escrito em PC
always @*
	case(PCOrigin)
		PC_ALU:		nextData <= aluResult;
		PC_ALU_REG:	nextData <= ALURegister;
	endcase

// Origem do que será escrito em rd
always @*
	case(RegisterInputOrigin)
		REGISTER_ALU:		registerInputData <= ALURegister;
		REGISTER_PC4:		registerInputData	<= PC;
		REGISTER_MEMORY: 	registerInputData	<= DataRegister;
		REGISTER_IMM:		registerInputData <= immediate;
		default:				registerInputData <= 32'b0; // DONT-CARE
	endcase
 
// Origem A da ULA
always @*
	case(ALUInputAOrigin)
		INPUT_A_CURRENT_PC:	aluInputA <= CurrentPC;
		INPUT_A_PC:				aluInputA <= PC;
		INPUT_A_REGISTER: 	aluInputA <= RegisterReadA;
		default:					aluInputA <= 32'b0; // DONT-CARE
	endcase
 
// Origem B da ULA
always @*
	case(ALUInputBOrigin)
		INPUT_B_REGISTER:		aluInputB <= RegisterReadB;
		INPUT_B_4:				aluInputB <= 32'd4;
		INPUT_B_IMMEDIATE: 	aluInputB <= immediate;
		default:					aluInputB <= 32'b0; // DONT-CARE
	endcase

// Origem do endereço da memória
always @*
	case(MemoryAddressOrigin)
		ADDRESS_PC:			address <= PC;
		ADDRESS_ALU_REG:	address <= ALURegister;
	endcase

/*
 *		Escrita nos Registradores
 */	

always @(posedge clock)
begin
	if(WritePC || (Branch && zero)) 	PC <= nextData; // Branch/Jump tomado
	if(WriteCurrentPC) 					CurrentPC <= PC;      // Escrita no PC
	if(WriteInstructionRegister)		InstructionRegister <= readData; // Instrução
	
  // demais registradores sem sinais de escrita
	DataRegister <= readData;
	ALURegister <= aluResult;
	RegisterReadA <= registerReadA;
	RegisterReadB <= registerReadB;
end

/*
 * 	Estruturas / Módulos
 */

 
// Memória de Dados/Instruções
Memory memory(
	.clock(clock),
	.iAddress(address), 
	.iData(registerReadB), 
	.write(WriteMemory),
	.read(ReadMemory),
	.oData(readData),
	.oAddress(dAddressMapped)
);

// Controle do Multiciclo (Máquina de Estados)
MulticicloControl control (
	.clock(clock),
	.opcode(opcode),
	
	.MemoryAddressOrigin(MemoryAddressOrigin),
	.WriteMemory(WriteMemory),
	.ReadMemory(ReadMemory),
	.WriteInstructionRegister(WriteInstructionRegister),
	.RegisterInputOrigin(RegisterInputOrigin),
	.WriteRegister(WriteRegister),
	.WriteCurrentPC(WriteCurrentPC),
	.ALUInputAOrigin(ALUInputAOrigin),
	.ALUInputBOrigin(ALUInputBOrigin),
	.ALUOp(ALUOp),
	.PCOrigin(PCOrigin),
	.WritePC(WritePC),
	.Branch(Branch),
	
	
	.oState(dState)
);

// Controle da ALU
ALUControl aluControl (
	.iALUOp(ALUOp),
	.funct3(funct3),
	.funct7(funct7),
	.oALUControl(ALUControlSignal)
);

// Banco de Registradores
Registers registers (
	.clock(clock), 
	.writeRegister(WriteRegister), 
	.rs1(rs1), 
	.rs2(rs2), 
	.rd(rd), 
	.registerRead1(registerReadA), 
	.registerRead2(registerReadB),
	.dataToWrite(registerInputData),
	.watchRegisterValue(dRegister),
	.watchRegister(dRegisterToWatch)
);

// Gerador de Imediatos
ImmediateGenerator immGen (
	.iInstruction(InstructionRegister),
	.oImmediate(immediate)
);

// ALU (ULA)
ALU alu (
	.iControl(ALUControlSignal),
	.iA(aluInputA),
	.iB(aluInputB),
	.oResult(aluResult),
	.oZero(zero)
);

/*
 * 	Debug
 */

always @*
begin
	dInstruction <= InstructionRegister;
	dReadData <= readData;
	
	dAddress <= address;
	
	f7 <= funct7;
	f3 <= funct3;
	dAluControl <= ALUControlSignal;
	dAluOp		<= ALUOp;
	
	dAluResult <= aluResult;
	dImmediate <= immediate;
end


endmodule