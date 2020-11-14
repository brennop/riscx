

module InstructionMemory (
	input [31:0] address, 
	output [31:0] instruction
);

reg [31:0] MI[0:255];

initial
begin
MI[0]=32'h00a50533;
MI[1]=32'h40b50533;
MI[2]=32'hff9ff0ef;
end


assign instruction = MI[address>>2];

endmodule