

module InstructionMemory (
	input [31:0] address, 
	output [31:0] instruction
);

reg [31:0] MI[0:255];

initial
begin
MI[0]=32'h00000293;
MI[1]=32'h0fc10417;
MI[2]=32'hffc40413;
MI[3]=32'h00000293;
MI[4]=32'h0fc10417;
MI[5]=32'hffc40413;
end


assign instruction = MI[address>>2];

endmodule