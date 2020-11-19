
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
	
	output [31:0] oAddress
);
 
// A memória é implementada como um array de 512 posições
reg [31:0] memory[0:511];

initial
begin
memory[0]=32'h10010437;   // 			lui s0, 0x10010 	# carregar o começo do .data em s0
memory[1]=32'h00442483;   // 			lw s1, 4(s0) 		# s1 = 100
memory[2]=32'h009484b3;   // 			add s1, s1, s1 	# s1 = 200
memory[3]=32'h00842283;   // 			lw t0, 8(s0)		# t1 = 50
memory[4]=32'h405484b3;   // 			sub s1, s1, t0 	# s1 = 150
memory[5]=32'h0092f333;   // 			and t1, t0, s1 	# t1 = 18
memory[6]=32'h006484b3;   // 			add s1, s1, t1 	# s1 = 168
memory[7]=32'h0092e333;   // 			or t1, t0, s1		# t1 = 186
memory[8]=32'h006484b3;   // 			add s1, s1, t1 	# s1 = 354
memory[9]=32'h0092a333;   // 			slt t1, t0, s1 	# t1 = 1
memory[10]=32'h006484b3;  // 			add s1, s1, t1		# s1 = 355
memory[11]=32'h0054a333;  // 			slt t1, s1, t0		# t1 = 0
memory[12]=32'h006484b3;  // 			add s1, s1, t1		# s1 = 355
memory[13]=32'h00c42303;  // 			lw t1, 12(s0)		# t1 = 305
memory[14]=32'h405484b3;  // Proc:	sub s1, s1, t0		# s1 = 305
memory[15]=32'hfe648ee3;  // 			beq s1, t1, Proc	# s1 = 255
memory[16]=32'h00942023;  // 			sw, s1, 0(s0)		# 0(s0) = 255
memory[17]=32'h00042903;  // 			lw, s2, 0(s0)		# s2 = 255
memory[18]=32'h000000ef;  // end:		jal end				# end  

memory[256] = 32'd0;
memory[257] = 32'd100;
memory[258] = 32'd50;
memory[259] = 32'd305;	        
end

wire [31:0] address;

assign address = ((iAddress < DATA) ? (iAddress - TEXT) : (iAddress - DATA)) >> 2;

always @(posedge clock)
begin
	if(write) 	memory[address] <= iData;
end

assign oData = read ? memory[address] : 32'b0;
assign oAddress = address;

endmodule