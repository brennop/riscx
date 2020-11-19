
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
  output wire       WritePC,
  output wire       Branch
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
      Branch                    <= FALSE; 

      nextState                 <= STATE_DECODE;
    end
  STATE_DECODE:
    begin
      MemoryAddressOrigin       <= ADDRESS_DONTCARE;
      WriteMemory               <= FALSE;
      ReadMemory                <= FALSE;
      WriteInstructionRegister  <= FALSE;
      RegisterInputOrigin       <= REGISTER_DONTCARE;
      WriteRegister             <= FALSE;
      WriteCurrentPC            <= FALSE;
      ALUInputAOrigin           <= INPUT_A_CURRENT_PC;
      ALUInputBOrigin           <= INPUT_B_IMMEDIATE;
      ALUControl                <= ALU_ADD;
      PCOrigin                  <= PC_ALU;
      WritePC                   <= FALSE; 
      Branch                    <= FALSE; 

      case(opcode)
        LOAD, STORE:  nextState <= STATE_LOAD_STORE;
        TIPOR:        nextState <= STATE_TIPOR;
        BRANCH:       nextState <= STATE_BRANCH;
        JUMP:         nextState <= STATE_JUMP;
        default:      nextState <= STATE_FETCH;
      endcase
    end
  STATE_LOAD_STORE:
    begin
      MemoryAddressOrigin       <= ADDRESS_DONTCARE;
      WriteMemory               <= FALSE;
      ReadMemory                <= FALSE;
      WriteInstructionRegister  <= FALSE;
      RegisterInputOrigin       <= REGISTER_DONTCARE;
      WriteRegister             <= FALSE;
      WriteCurrentPC            <= FALSE;
      ALUInputAOrigin           <= INPUT_A_REGISTER;
      ALUInputBOrigin           <= INPUT_B_IMMEDIATE;
      ALUControl                <= ALU_ADD;
      PCOrigin                  <= PC_ALU;
      WritePC                   <= FALSE; 
      Branch                    <= FALSE; 

      case(opcode)
        LOAD:         nextState <= STATE_LOAD;
        STORE:        nextState <= STATE_STORE;
        default:      nextState <= STATE_FETCH;
      endcase
    end
  STATE_LOAD:
    begin
      MemoryAddressOrigin       <= ADDRESS_ALU_REG;
      WriteMemory               <= FALSE;
      ReadMemory                <= TRUE;
      WriteInstructionRegister  <= FALSE;
      RegisterInputOrigin       <= REGISTER_DONTCARE;
      WriteRegister             <= FALSE;
      WriteCurrentPC            <= FALSE;
      ALUInputAOrigin           <= INPUT_A_DONTCARE;
      ALUInputBOrigin           <= INPUT_B_DONTCARE;
      ALUControl                <= ALU_ADD;
      PCOrigin                  <= PC_ALU;
      WritePC                   <= FALSE; 
      Branch                    <= FALSE; 

      nextState                 <= STATE_LOAD_SAVE;
    end
  STATE_LOAD_SAVE:
    begin
      MemoryAddressOrigin       <= ADDRESS_DONTCARE;
      WriteMemory               <= FALSE;
      ReadMemory                <= FALSE;
      WriteInstructionRegister  <= FALSE;
      RegisterInputOrigin       <= REGISTER_MEMORY;
      WriteRegister             <= TRUE;
      WriteCurrentPC            <= FALSE;
      ALUInputAOrigin           <= INPUT_A_DONTCARE;
      ALUInputBOrigin           <= INPUT_B_DONTCARE;
      ALUControl                <= ALU_ADD;
      PCOrigin                  <= PC_ALU;
      WritePC                   <= FALSE; 
      Branch                    <= FALSE; 

      nextState                 <= STATE_FETCH;
    end
  STATE_STORE:
    begin
      MemoryAddressOrigin       <= ADDRESS_ALU_REG;
      WriteMemory               <= TRUE;
      ReadMemory                <= FALSE;
      WriteInstructionRegister  <= FALSE;
      RegisterInputOrigin       <= REGISTER_DONTCARE;
      WriteRegister             <= FALSE;
      WriteCurrentPC            <= FALSE;
      ALUInputAOrigin           <= INPUT_A_DONTCARE;
      ALUInputBOrigin           <= INPUT_B_DONTCARE;
      ALUControl                <= ALU_ADD;
      PCOrigin                  <= PC_ALU;
      WritePC                   <= FALSE; 
      Branch                    <= FALSE; 

      nextState                 <= STATE_FETCH;
    end
  STATE_TIPOR:
    begin
      MemoryAddressOrigin       <= ADDRESS_DONTCARE;
      WriteMemory               <= FALSE;
      ReadMemory                <= FALSE;
      WriteInstructionRegister  <= FALSE;
      RegisterInputOrigin       <= REGISTER_DONTCARE;
      WriteRegister             <= FALSE;
      WriteCurrentPC            <= FALSE;
      ALUInputAOrigin           <= INPUT_A_REGISTER;
      ALUInputBOrigin           <= INPUT_B_REGISTER;
      PCOrigin                  <= PC_ALU;
      WritePC                   <= FALSE; 
      Branch                    <= FALSE; 

			case(funct3)
				FUNCT3_ADD: 
          case(funct7)
            FUNCT7_ADD: ALUControl <= ALU_ADD;
            FUNCT7_SUB: ALUControl <= ALU_SUB;
            default:    ALUControl <= ALU_ADD;
          endcase
				FUNCT3_SLT: ALUControl <= ALU_SLT;
				FUNCT3_OR : ALUControl <= ALU_OR;
				FUNCT3_AND: ALUControl <= ALU_AND;
				default: 	ALUControl <= ALU_ADD;
			endcase

      nextState                 <= STATE_TIPOR_SAVE;
    end
  STATE_TIPOR_SAVE:
    begin
      MemoryAddressOrigin       <= ADDRESS_DONTCARE;
      WriteMemory               <= FALSE;
      ReadMemory                <= FALSE;
      WriteInstructionRegister  <= FALSE;
      RegisterInputOrigin       <= REGISTER_ALU;
      WriteRegister             <= TRUE;
      WriteCurrentPC            <= FALSE;
      ALUInputAOrigin           <= INPUT_A_DONTCARE;
      ALUInputBOrigin           <= INPUT_B_DONTCARE;
      ALUControl                <= ALU_ADD;
      PCOrigin                  <= PC_ALU;
      WritePC                   <= FALSE; 
      Branch                    <= FALSE; 

      nextState                 <= STATE_FETCH;
    end
  STATE_BRANCH:
    begin
      MemoryAddressOrigin       <= ADDRESS_DONTCARE;
      WriteMemory               <= FALSE;
      ReadMemory                <= FALSE;
      WriteInstructionRegister  <= FALSE;
      RegisterInputOrigin       <= REGISTER_DONTCARE;
      WriteRegister             <= FALSE;
      WriteCurrentPC            <= FALSE;
      ALUInputAOrigin           <= INPUT_A_REGISTER;
      ALUInputBOrigin           <= INPUT_B_REGISTER;
      ALUControl                <= ALU_SUB;
      PCOrigin                  <= PC_ALU;
      WritePC                   <= FALSE; 
      Branch                    <= TRUE; 

      nextState                 <= STATE_FETCH;
    end
  STATE_JUMP:
    begin
      MemoryAddressOrigin       <= ADDRESS_DONTCARE;
      WriteMemory               <= FALSE;
      ReadMemory                <= FALSE;
      WriteInstructionRegister  <= FALSE;
      RegisterInputOrigin       <= REGISTER_PC4;
      WriteRegister             <= TRUE;
      WriteCurrentPC            <= FALSE;
      ALUInputAOrigin           <= INPUT_A_DONTCARE;
      ALUInputBOrigin           <= INPUT_B_DONTCARE;
      ALUControl                <= ALU_ADD;
      PCOrigin                  <= PC_ALU;
      WritePC                   <= TRUE; 
      Branch                    <= FALSE; 

      nextState                 <= STATE_FETCH;
    end
  default:
    begin
      MemoryAddressOrigin       <= ADDRESS_DONTCARE;
      WriteMemory               <= FALSE;
      ReadMemory                <= FALSE;
      WriteInstructionRegister  <= FALSE;
      RegisterInputOrigin       <= REGISTER_DONTCARE;
      WriteRegister             <= FALSE;
      WriteCurrentPC            <= FALSE;
      ALUInputAOrigin           <= INPUT_A_DONTCARE;
      ALUInputBOrigin           <= INPUT_B_DONTCARE;
      ALUControl                <= ALU_ADD;
      PCOrigin                  <= PC_ALU;
      WritePC                   <= FALSE; 
      Branch                    <= FALSE; 

      nextState                 <= STATE_FETCH;
    end
 endcase
 
endmodule