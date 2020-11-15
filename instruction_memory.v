

module InstructionMemory (
	input [31:0] address, 
	output [31:0] instruction
);

reg [31:0] MI[0:255];

initial
begin
MI[0]=32'h00a00513;
MI[1]=32'h00100593;
MI[2]=32'h00400313;
MI[3]=32'h000006b3;
MI[4]=32'h00a6a023;
MI[5]=32'h006686b3;
MI[6]=32'h40b50533;
MI[7]=32'h00052633;
MI[8]=32'hfe0608e3;
MI[9]=32'h0006f6b3;
MI[10]=32'h0066e6b3;
MI[11]=32'h0006a903;
MI[12]=32'h000000ef;
end


assign instruction = MI[address>>2];

endmodule