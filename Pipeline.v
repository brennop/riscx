
`ifndef PARAM
	`include "params.v"
`endif

/*
	_Datapath do Pipeline_
*/

module Pipeline (
	input clock,
	
  // Sinais de Debug
	output [31:0] dInstruction,
	output [31:0] dInstructionID,
	output [31:0] dPC,
	
	output [9:0] dControl,
	output [9:0] dID_EX_Control,

	input  [4:0]  dRegisterToWatch,
	output [31:0] dRegister,
	
	output dEQ,
	output [31:0] dRegisterReadA,
	output [31:0] dRegisterReadB,
	output [3:0] forwardBranch,

	output [31:0] dAluResult
);

// Sinais de Debug
always @*
begin
	dInstruction <= instruction;
	dPC <= PC;
	
	dControl <= control;
	dID_EX_Control <= ID_EX_Control;
	
	dInstructionID <= IF_ID_Instruction;
	
	dEQ <= EQ;
	dRegisterReadB <= branchInputB;
	dRegisterReadA <= branchInputA;
	forwardBranch <= {ForwardBranchA, ForwardBranchB};

	dAluResult <= aluResult;
end


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
reg [31:0] ID_EX_registerReadA;
reg [31:0] ID_EX_registerReadB;
reg [31:0] ID_EX_Immediate;
reg [31:0] ID_EX_Instruction;


// EX_MEM
reg [31:0] EX_MEM_Instruction;
reg [31:0] EX_MEM_ALUResult;
reg [31:0] EX_MEM_registerReadB;

// MEM_WB
reg [31:0] MEM_WB_Instruction;
reg [31:0] MEM_WB_ALUResult;
reg [31:0] MEM_WB_ReadData;

/*
 *
 *		Sinais/Fios do Datapath
 *
 */
 
wire [31:0] instruction;
wire [31:0] nextPC;
wire [31:0] immediate;

wire [31:0] pc4 = PC + 32'd4;		
wire [31:0] pcImm = IF_ID_PC + immediate;	

wire EQ = branchInputA == branchInputB;

/* Banco de Registradores */
wire [31:0] registerInputData;// Dado a ser escrito em rd
wire [31:0] registerReadA;
wire [31:0] registerReadB;

wire [31:0] forwardBOutput;

wire [31:0] forwardRegisterInputData;

/* ALU */
wire [31:0] aluInputA;
wire [31:0] aluInputB;
wire [31:0] aluResult;

wire [31:0] readData;

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

wire [1:0] ForwardBranchA;
wire [1:0] ForwardBranchB;

wire [31:0] branchInputA;
wire [31:0] branchInputB;

/* Hazard Detection */

wire ControlReset;
wire PCWrite;
wire IF_IDWrite;
wire IF_Flush;


/*
 *		Escrita nos Registradores
 */	

always @(posedge clock)
begin
	if(PCWrite) PC <= nextPC;
	
	/* IF_ID */
	if(IF_IDWrite) 
		begin
			IF_ID_Instruction <= IF_Flush ? 32'h00000033 : instruction;
			IF_ID_PC <= PC;
		end
	
	/* ID_EX */
	ID_EX_Instruction <= IF_ID_Instruction;
	ID_EX_registerReadA <= registerReadA;
	ID_EX_registerReadB <= registerReadB;
	ID_EX_Immediate 	<= immediate;


	/* EX_MEM */
	EX_MEM_Instruction 	<= ID_EX_Instruction;
	EX_MEM_ALUResult 		<= aluResult;
	EX_MEM_registerReadB <= forwardBOutput;

	/* MEM_WB */
	MEM_WB_Instruction 	<= EX_MEM_Instruction;
	MEM_WB_ALUResult 		<= EX_MEM_ALUResult;
	MEM_WB_ReadData   	<= readData;
	
	/* Control */
	ID_EX_Control <= ControlReset ? 10'b0 : control;
	EX_MEM_Control <= ID_EX_Control[6:0];
	MEM_WB_Control <= EX_MEM_Control[2:0];
end

/*
 *
 * Multiplexadores
 *
 */

// Origem do PC
always @*
	case(control[9:8])
		PC4: nextPC <= pc4;
		PCBEQ: nextPC <= EQ ? pcImm : pc4;
		PCIMM: nextPC <= pcImm;
		default: nextPC <= pc4;
	endcase

// Forward A
always @*
	case(ForwardA)
		FORWARD_EX_MEM: aluInputA <= EX_MEM_ALUResult;
		FORWARD_MEM_WB: aluInputA <= registerInputData;
		FORWARD_NONE: 	 aluInputA <= ID_EX_registerReadA;
		default: 		 aluInputA <= 32'b0;
	endcase
	
// Forward B
always @*
case(ForwardB)
	FORWARD_EX_MEM: forwardBOutput <= EX_MEM_ALUResult;
	FORWARD_MEM_WB: forwardBOutput <= registerInputData;
	FORWARD_NONE: 	 forwardBOutput <= ID_EX_registerReadB;	
	default: 		 forwardBOutput <= 32'b0;
endcase

// Forward B
always @*
case(ID_EX_Control[7])
	ORIG_REG: aluInputB <= forwardBOutput;
	ORIG_IMM: aluInputB <= ID_EX_Immediate;
endcase

// Forward Branch A
always @*
	case(ForwardBranchA)
		FORWARD_EX_MEM: branchInputA <= aluResult;
		FORWARD_MEM_WB: branchInputA <= forwardRegisterInputData;
		FORWARD_NONE: 	 branchInputA <= registerReadA;
		default: 		 branchInputA <= 32'b0;
	endcase
	
// Forward Branch B
always @*
	case(ForwardBranchB)
		FORWARD_EX_MEM: branchInputB <= aluResult;
		FORWARD_MEM_WB: branchInputB <= forwardRegisterInputData;
		FORWARD_NONE: 	 branchInputB <= registerReadB;	
		default: 		 branchInputB <= 32'b0;
	endcase

// registerInputData
always @*
	case(MEM_WB_Control[1:0])
		ORIG_ALU: registerInputData <= MEM_WB_ALUResult;
		ORIG_MEM: registerInputData <= MEM_WB_ReadData;
		default: registerInputData <= MEM_WB_ALUResult;
	endcase

// ForwardRegisterInputData
always @*
	case(EX_MEM_Control[1:0])
		ORIG_ALU: forwardRegisterInputData <= EX_MEM_ALUResult;
		ORIG_MEM: forwardRegisterInputData <= readData;
		default: forwardRegisterInputData <= EX_MEM_ALUResult;
	endcase
	
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

// Memória de Dados
DataMemory dataMemory (
	.clock(clock),
	.write(EX_MEM_Control[4]),
	.read(EX_MEM_Control[3]),
	.iAddress(EX_MEM_ALUResult),
	.iData(EX_MEM_registerReadB),
	.oData(readData)
);


// Banco de Registradores
Registers registers (
	.clock(clock),
	.writeRegister(MEM_WB_Control[2]),
	.rs1(IF_ID_Instruction[19:15]),
	.rs2(IF_ID_Instruction[24:20]),
	.rd(MEM_WB_Instruction[11:7]),
	.registerRead1(registerReadA),
	.registerRead2(registerReadB),
	.dataToWrite(registerInputData),
	.watchRegisterValue(dRegister),
	.watchRegister(dRegisterToWatch)
);

// Controle
PipelineControl pipeControl(
	.opcode(IF_ID_Instruction[6:0]),
	.oControl(control)
);

// Controle da ULA
ALUControl aluControl (
	.iALUOp(ID_EX_Control[6:5]),
	.funct3(ID_EX_Instruction[14:12]),
	.funct7(ID_EX_Instruction[31:25]),
	.oALUControl(ALUControlSignal)
);

// ALU (ULA)
ALU alu (
	.iControl(ALUControlSignal),
	.iA(aluInputA),
	.iB(aluInputB),
	.oResult(aluResult)
);

// Gerador de Imediatos
ImmediateGenerator immGen (
	.iInstruction(IF_ID_Instruction),
	.oImmediate(immediate)
);

// Forwarding
ForwardingUnit fu (
  .rs1(ID_EX_Instruction[19:15]),
  .rs2(ID_EX_Instruction[24:20]),
  
  .EX_MEM_rd(EX_MEM_Instruction[11:7]),
  .MEM_WB_rd(MEM_WB_Instruction[11:7]),
  
  .EX_MEM_RegWrite(EX_MEM_Control[2]),
  .MEM_WB_RegWrite(MEM_WB_Control[2]),
  
  .forwardA(ForwardA),
  .forwardB(ForwardB)
);

// Forwarding
ForwardingUnit fuBeq (
  .rs1(IF_ID_Instruction[19:15]),
  .rs2(IF_ID_Instruction[24:20]),
  
  .EX_MEM_rd(ID_EX_Instruction[11:7]),
  .MEM_WB_rd(EX_MEM_Instruction[11:7]),
  
  .EX_MEM_RegWrite(ID_EX_Control[2]),
  .MEM_WB_RegWrite(EX_MEM_Control[2]),
  
  .forwardA(ForwardBranchA),
  .forwardB(ForwardBranchB)
);


HazardDetection hd (
  .opcode(IF_ID_Instruction[6:0]),
  .rs1(IF_ID_Instruction[19:15]),
  .rs2(IF_ID_Instruction[24:20]),
  .ID_EX_rd(ID_EX_Instruction[11:7]),
  
  .ID_EX_MemRead(ID_EX_Control[3]),
  .EQ(EQ),
  
  .ControlReset,
  .PCWrite,
  .IF_IDWrite,
  .IF_Flush
);

endmodule