
`ifndef PARAM
	`include "params.v"
`endif

/*
	_Datapath do Pipeline_
*/

module Pipeline (
	input clock,
	
	output [31:0] dInstruction,
	input  [4:0]  dRegisterToWatch,
	output [31:0] dRegister
);




/*
 *
 *		Registradores
 *
 */
 
reg [31:0] 	PC = TEXT;

// IF_ID
reg [31:0] IF_ID_Instruction;
reg [31:0] IF_ID_PC;

// ID_EX
reg [31:0] ID_EX_PC;
reg [31:0] ID_EX_registerReadA;
reg [31:0] ID_EX_registerReadB;
reg [31:0] ID_EX_Immediate;
reg [31:0] ID_EX_Instruction;


// EX_MEM
reg [31:0] EX_MEM_Instruction;

// MEM_WB
reg [31:0] MEM_WB_Instruction;

/*
 *
 *		Sinais/Fios do Datapath
 *
 */
 
wire [31:0] instruction;
wire [31:0] nextPC;
wire [31:0] immediate;

/* Banco de Registradores */
wire [31:0] registerInputData;// Dado a ser escrito em rd
wire [31:0] registerReadA;
wire [31:0] registerReadB;

/* ALU */
wire [31:0] aluInputA;
wire [31:0] aluInputB;
wire [31:0] aluResult;
wire zero;

/*
 *
 *		Sinais/Fios de Controle
 *
 */

wire [9:0] control;
wire [3:0] ALUControlSignal;


/* Registradores de Controle */

reg [9:0] ID_EX_Control;
reg [6:0] EX_MEM_Control;
reg [2:0] MEM_WB_Control;

/* Forward */

wire [1:0] ForwardA;
wire [1:0] ForwardB;



/*
 *		Escrita nos Registradores
 */	

always @(posedge clock)
begin
	// PC <= nextPC;
	
	/* IF_ID */
	IF_ID_Instruction <= instruction;
	IF_ID_PC <= PC;
	
	/* ID_EX */
	ID_EX_Instruction <= IF_ID_Instruction;
	ID_EX_PC 			<= IF_ID_PC;
	ID_EX_registerReadA <= registerReadA;
	ID_EX_registerReadB <= registerReadB;
	ID_EX_Immediate 	<= immediate;


	/* EX_MEM */
	EX_MEM_Instruction <= ID_EX_Instruction;

	/* MEM_WB */
	MEM_WB_Instruction <= EX_MEM_Instruction;
	
	/* Control */
	ID_EX_Control <= control;
	EX_MEM_Control <= ID_EX_Control;
	MEM_WB_Control <= EX_MEM_Control;
end

/*
 *
 * Multiplexadores
 *
 */

// Origem do PC

 


/*
 *
 * 	Estruturas / Módulos
 *
 */
 
// Memória de Instruções
InstructionMemory instructionMemory (
	.address(PC), 
	.instruction(instruction)
);


// Banco de Registradores
Registers registers (
	.clock(clock),
	.writeRegister(MEM_WB_Control[2]),
	.rs1(IF_ID_Instruction[19:15]),
	.rs2(IF_ID_Instruction[24:20]),
	.rd(IF_ID_Instruction[11:7]),
	.registerRead1(registerReadA),
	.registerRead2(registerReadB),
	.dataToWrite(registerInputData),
	.watchRegisterValue(dRegister),
	.watchRegister(dRegisterToWatch)
);

// Controle da ULA
ALUControl aluControl (
	.iALUOp(ID_EX_Control[8:7]),
	.funct3(ID_EX_Instruction[14:12]),
	.funct7(ID_EX_Instruction[31:25]),
	.oALUControl(ALUControlSignal)
);

// ALU (ULA)
ALU alu (
	.iControl(ALUControlSignal),
	.iA(aluInputA),
	.iB(aluInputB),
	.oResult(aluResult),
	.oZero(zero)
);

// Forwarding
ForwardingUnit fu (
  .rs1(ID_EX_Instruction[19:15]),
  .rs2(ID_EX_Instruction[24:20]),
  
  .EX_MEM.rd(EX_MEM_Instruction[11:7]),
  .MEM_WB.rd(MEM_WB_Instruction[11:7]),
  
  .EX_MEM.RegWrite(EX_MEM_Control[2]),
  .MEM_WB.RegWrite(MEM_WB_Control[2]),
  
  .forwardA(ForwardA),
  .forwardB(ForwardB),
);


