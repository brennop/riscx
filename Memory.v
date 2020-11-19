
`ifndef PARAM
	`include "params.v"
`endif

/*
	Memória de Dados/Instruções
*/
module Memory (
	input wire clock,
	input [31:0] iAddress, 
	input [31:0] iData, 
	input wire write, read,
	output [31:0] oData,
);
 
// A memória é implementada como um array de 512 posições
reg [31:0] memory[0:511];

wire [31:0] address;

assign address = ((iAddress < DATA) ? (iAddress - TEXT) : (iAddress - DATA)) >> 2;

always @(posedge clock)
begin
	if(write) 	memory[address] <= iData;
	if(read) 	oData <= memory[address];
end

endmodule