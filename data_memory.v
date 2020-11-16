
module DataMemory (
	input wire clock, write, read,
	input [31:0] iAddress, 
	input [31:0] iData, 
	output [31:0] oData
);

wire [31:0] address = (iAddress - 32'h10010000) >> 2;

reg [31:0] MD[0:255];

reg [8:0] i;

initial
	begin
		for (i = 0; i <= 255; i = i + 1'b1)
			MD[i] = 32'd0;
	end

always @(posedge clock)
begin
	if(write && !read) MD[address] <= iData;
end

always @(negedge clock)
begin
	if(read && !write) oData <= MD[address];
end

endmodule