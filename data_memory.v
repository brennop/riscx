
module DataMemory (
	input wire clock, write, read,
	input [31:0] iAddress, 
	input [31:0] iData, 
	output [31:0] oData
);

reg [31:0] MD[0:255];

reg [8:0] i;

initial
	begin
		for (i = 0; i <= 255; i = i + 1'b1)
			MD[i] = 32'd0;
	end

always @(posedge clock)
begin
	if(write && !read) MD[iAddress>>2] <= iData;
end

always @(negedge clock)
begin
	if(read && !write) oData <= MD[iAddress>>2];
end

endmodule