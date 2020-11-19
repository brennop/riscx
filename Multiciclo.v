
`ifndef PARAM
	`include "params.v"
`endif

/*
	_Datapath do Multiciclo_
*/

module Multiciclo (
	input clock
);

/*
 *		Registradores
 */
 
reg [31:0] PC = 32'b0;

/*
 *		Sinais/Fios do Datapath
 */
 
wire [31:0] address;				// Endereço da memória
wire [31:0] registerReadB;		// Dado lido do registrador rs2
wire [31:0] ReadData;			// Dado lido da memória

/*
 *		Sinais do Controle
 */
wire WriteMemory;					// Sinal de habilitação de escrita na memória
wire ReadMemory;					// Sinal de habilitação de leitura da memória


/*
 * 	Estruturas / Módulos
 */

Memory memory(
	.clock(clock),
	.iAddress(address), 
	.iData(registerReadB), 
	.write(WriteMemory),
	.read(ReadMemory),
	.oData(ReadData),
);