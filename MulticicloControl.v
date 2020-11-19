
`ifndef PARAM
  `include "params.v"
`endif

/*
  _Controle do Multiciclo_
*/

module MulticicloControl (
  input wire clock,
  input wire [0:6] opcode,
  input wire [0:2] funct3,
  input wire [0:6] funct7,
  
  output wire       MemoryAddressOrigin,
  output wire       WriteMemory,
  output wire       ReadMemory,
  output wire       WriteInstructionRegister,
  output wire [0:1] RegisterInputOrigin,
  output wire       WriteRegister,
  output wire       WriteCurrentPC,
  output wire [0:1] ALUInputAOrigin,
  output wire [0:1] ALUInputBOrigin,
  output wire [0:3] ALUControl,
  output wire       PCOrigin,
  output wire       WritePC
);

reg   [0:3] state;       // o estado atual
wire   [0:3] nextState;     // o próximo estado

always @(posedge clock) state <= nextState;

always @*
 case(state)
  STATE_FETCH:
    begin
      MemoryAddressOrigin       <= ADDRESS_PC;
      WriteMemory               <= FALSE;
      ReadMemory                <= TRUE;
      WriteInstructionRegister  <= TRUE;
      RegisterInputOrigin       <= REGISTER_DONTCARE;
      WriteRegister             <= FALSE;
      WriteCurrentPC            <= TRUE;
      ALUInputAOrigin           <= INPUT_A_PC;
      ALUInputBOrigin           <= INPUT_B_4;
      ALUControl                <= ALU_ADD;
      PCOrigin                  <= PC_ALU;
      WritePC                   <= TRUE; 

      nextState                 <= STATE_DECODE;
    end
 endcase