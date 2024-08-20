module memory(input [15:0] addr, input WRITE, input READ, input [7:0] data_in, output [7:0] data_out);
	initial begin
		$readmemh("hex_mem.txt", mem);
		$display("Memory contents:");
		for (integer i = 0; i < 20; i++) begin
			$display("[%2d] = %h", i, mem[i]);
		end
	end

	reg [7:0] mem[0:65535];

	assign data_out = (READ)? mem[addr] : 8'bz;
	always @(posedge WRITE) begin
		mem[addr] <= data_in;
		$display("[%0t] Writing %hH to address %hH", $time, mem[addr], addr);
	end
endmodule