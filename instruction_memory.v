
/*
	Memória de Instruções
	Recebe um endereço (PC) e lê
	a instrução naquele endereço
*/
module InstructionMemory (
	input [31:0] address, 
	output [31:0] instruction
);

// A memória de instruções é implementada 
// como um array de 256 registradores
reg [31:0] MI[0:255];

// Aqui fazemos a atribuição dos dados da 
// memória, com o programa a ser executado 
initial
begin
MI[0]=32'h10010437;   // 			lui s0, 0x10010 	# carregar o começo do .data em s0
MI[1]=32'h00442483;   // 			lw s1, 4(s0) 		# s1 = 100
MI[2]=32'h009484b3;   // 			add s1, s1, s1 	# s1 = 200
MI[3]=32'h00842283;   // 			lw t0, 8(s0)		# t1 = 50
MI[4]=32'h405484b3;   // 			sub s1, s1, t0 	# s1 = 150
MI[5]=32'h0092f333;   // 			and t1, t0, s1 	# t1 = 18
MI[6]=32'h006484b3;   // 			add s1, s1, t1 	# s1 = 168
MI[7]=32'h0092e333;   // 			or t1, t0, s1		# t1 = 186
MI[8]=32'h006484b3;   // 			add s1, s1, t1 	# s1 = 354
MI[9]=32'h0092a333;   // 			slt t1, t0, s1 	# t1 = 1
MI[10]=32'h006484b3;  // 			add s1, s1, t1		# s1 = 355
MI[11]=32'h0054a333;  // 			slt t1, s1, t0		# t1 = 0
MI[12]=32'h006484b3;  // 			add s1, s1, t1		# s1 = 355
MI[13]=32'h00c42303;  // 			lw t1, 12(s0)		# t1 = 305
MI[14]=32'h405484b3;  // Proc:	sub s1, s1, t0		# s1 = 305
MI[15]=32'hfe648ee3;  // 			beq s1, t1, Proc	# s1 = 255
MI[16]=32'h00942023;  // 			sw, s1, 0(s0)		# 0(s0) = 255
MI[17]=32'h00042903;  // 			lw, s2, 0(s0)		# s2 = 255
MI[18]=32'h000000ef;  // end:		jal end				# end          
end

// Precisamos deslocar o endereço para a esquerda 
// (dividir por 2) já que nossa memória não é 
// byte addressing assim como o PC 
assign instruction = MI[(address - TEXT)>>2];

// Só precisamos da leitura já que 
// nossa memória de instruções não
// será escrita durante a execução

endmodule