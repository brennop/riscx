

module InstructionMemory (
	input [31:0] address, 
	output [31:0] instruction
);

reg [31:0] MI[0:255];

initial
begin
MI[0]=32'h00a00513;   // addi a0 zero 10
MI[1]=32'h00100593;   // addi a1 zero 1
MI[2]=32'h00400313;   // addi t1 zero 4
MI[3]=32'h00a6a023;   // PROC: sw a0 0(a3)
MI[4]=32'h006686b3;   // add a3 a3 t1
MI[5]=32'h40b50533;   // sub a0 a0 a1
MI[6]=32'h00052633;   // slt a2 a0 zero
MI[7]=32'hfe0608e3;   // beq a2 zero PROC
MI[8]=32'h0006f6b3;   // and a3 a3 zero
MI[9]=32'h0066e6b3;  // or a3 a3 t1
MI[10]=32'h00d686b3;  // add a3 a3 a3
MI[11]=32'h0006a903;  // lw s2 0(a3)
MI[12]=32'h000000ef;  // END: jal END             
end


assign instruction = MI[address>>2];

endmodule