
/*
	Memória de Dados
*/

module DataMemory (
	input wire clock, write, read,
	input [31:0] iAddress, 
	input [31:0] iData, 
	output [31:0] oData
);

// Nossa memória de dados começa no endereço 0x10010000
// e não é Byte Adressing, por isso preciamos converter
// o dado que vem de um load/store
wire [31:0] address = (iAddress - 32'h10010000) >> 2;

// A memória de dados é implementada 
// como um array de 256 registradores
reg [31:0] MD[0:255];

// Precisamos fazer a atribuição inicial de memória
// com os dados gerados pelo .data do nosso programa
// e o restante dos endereços com o valor 0
reg [8:0] i;
initial
	begin
		MD[0] = 32'd0;
		MD[1] = 32'd100;
		MD[2] = 32'd50;
		MD[3] = 32'd305;		
		for (i = 4; i <= 255; i = i + 1'b1)
			MD[i] = 32'd0;
	end

// A escrita ocorre de maneira síncrona, 
// na borda de subida do clock
always @(posedge clock)
begin
	// Se a escrita está habilitada e a leitura
	// está desabilitada, escrevemos no endereço
	// address o valor de entrada (iData)
	if(write && !read) MD[address] <= iData;
end

// A leitura ocorre de modo assíncrono.
// Se a leitura estiver habilitada, colocamos
// em oData o valor da memória no endereço address
assign oData = read ? MD[address] : 32'b0;


endmodule