
/*
	Banco de Registradores
*/

module Registers (
	input wire clock,  								// o clock, para escrita síncrona
	input wire writeRegister,					// sinal de controle para habilitar a escrita 
	input wire [4:0] rs1, rs2, rd,		// registradores de fonte e destino	
	input wire [31:0] dataToWrite,		// dados a serem escritos no registrador de destino
	
	output wire [31:0] registerRead1, registerRead2, // o que foi lido dos registradores
	
	input  [4:0] watchRegister,
	output [31:0] watchRegisterValue								// debug para observar um registrador
);


// Nosso banco de registradores é definido como
// um array de 32 registradores de 32 bits cada
reg [31:0] registers[31:0];

// Fazemos a inicialização da memória com todos
// os registradores zerados, e o registrador r2
// (sp) com o valor do topo da memória
initial 
begin
	registers[0] = 32'd0;
	registers[1] = 32'd0;
	registers[2] = 32'h3fc; // SP = 255 * 4
	registers[3] = 32'd0;
	registers[4] = 32'd0;
	registers[5] = 32'd0;
	registers[6] = 32'd0;
	registers[7] = 32'd0;
	registers[8] = 32'd0;
	registers[9] = 32'd0;
	registers[10] = 32'd0;
	registers[11] = 32'd0;
	registers[12] = 32'd0;
	registers[13] = 32'd0;
	registers[14] = 32'd0;
	registers[15] = 32'd0;
	registers[16] = 32'd0;
	registers[17] = 32'd0;
	registers[18] = 32'd0;
	registers[19] = 32'd0;
	registers[20] = 32'd0;
	registers[21] = 32'd0;
	registers[22] = 32'd0;
	registers[23] = 32'd0;
	registers[24] = 32'd0;
	registers[25] = 32'd0;
	registers[26] = 32'd0;
	registers[27] = 32'd0;
	registers[28] = 32'd0;
	registers[29] = 32'd0;
	registers[30] = 32'd0;
	registers[31] = 32'd0;
end

assign registerRead1 = registers[rs1]; 	// Valor do registrador RS1
assign registerRead2 = registers[rs2]; 	// Valor do registrador RS2
assign watchRegisterValue = registers[watchRegister];						// Registrador a ser mostrado no wvf

// Escrita síncrona
always @(negedge clock) 
begin
	// Se o write estiver habilitado e não estiver no reg ZERO
	// escrevemos o valor do dataToWrite no registrador RD
	if(writeRegister && (rd != 5'b0)) registers[rd] <= dataToWrite;
end

endmodule