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

module Shift_In_Testbench();
	localparam WIDTH = 9;

	// Ports
	logic clk, reset, enable;
	logic in;
	logic [WIDTH - 1:0] out;
	logic new_data;

	// Device under test
	Shift_In #(.WIDTH(WIDTH)) dut (.*);

	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	// Display current test
	string current_test;
	
	initial begin		
		// Reset
		current_test = "Reset";
		reset <= 1; 			repeat(01) @(posedge clk);
		reset <= 0;				repeat(01) @(posedge clk);
		enable <= 0; in <= 0;	repeat(01) @(posedge clk);
		
		// Test shifting
		current_test = "Shifting";
		enable <= 1; in <= 0;	repeat(03) @(posedge clk);
		enable <= 1; in <= 1;	repeat(03) @(posedge clk);
		enable <= 1; in <= 0;	repeat(03) @(posedge clk);
		enable <= 1; in <= 1;	repeat(03) @(posedge clk);
		enable <= 1; in <= 0;	repeat(06) @(posedge clk);
		
		// Test enable
		current_test = "Enable";
		for (int i = 0; i < (3 * WIDTH); i++) begin
			enable <= 0;		repeat(01) @(posedge clk);
			in <= $urandom % 2;	repeat(01) @(posedge clk);
			enable <= 1;		repeat(01) @(posedge clk);
		end // for i
		
		// Test synchronous reset
		current_test = "Reset";
		in <= 1; 		repeat(05) @(posedge clk);
		reset <= 1;		repeat(05) @(posedge clk);
		reset <= 0;		repeat(05) @(posedge clk);
		
		// End the simulation.
		$stop;
	end
endmodule // Shift_In_Testbench
