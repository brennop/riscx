
module DataMemory (
	input wire clock, write, read,
	input [31:0] iAddress, 
	input [31:0] iData, 
	output [31:0] oData
);

reg [31:0] MD[0:255];

initial
begin
MD[0]=32'h00000000;
end

always @(posedge clock)
begin
	if(read) oData <= MD[iAddress>>2];
	if(write) MD[iAddress>>2] <= iData;
end

endmodule