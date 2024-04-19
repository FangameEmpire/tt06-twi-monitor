module Shift_In 
#(
	parameter WIDTH = 8
)
(
	clk, 
	reset, 
	enable, 
	in, 
	out, 
	new_data
);
	// Ports
	input logic clk, reset, enable;
	input logic in;
	output logic [WIDTH - 1:0] out;
	output logic new_data;
	
	// Counter
	reg [$clog2(WIDTH):0] bits_received;
	
	// Shift Register
	reg [WIDTH - 1:0] data_internal;
	
	// Shift logic
	always @(posedge clk) begin
		out <= out;
		bits_received <= bits_received;
		data_internal <= data_internal;
		new_data <= 1'b0;
		if (reset) begin
			out <= 0;
			bits_received <= 0;
			data_internal <= 0;
		end else if (enable) begin
			data_internal <= {data_internal[WIDTH - 2:0], in};
			if (bits_received == WIDTH) begin
				bits_received <= 0;
				out <= data_internal;
				new_data <= 1'b1;
			end else begin
				bits_received <= bits_received + 1;
			end
		end
	end // always @(posedge clk)
	
endmodule // Shift_In
