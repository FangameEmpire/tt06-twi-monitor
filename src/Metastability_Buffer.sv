// Two DFFs in Serial. Used to buffer input from user or CDC.
module Metastability_Buffer
(
	clk, 
	reset, 
	user_in, 
	user_out
);
	// Ports
	input logic clk, reset;
	input logic user_in;
	output logic user_out;
	
	// FSM states
	enum {none, detect, hold} ps,ns;
	
	// State logic
	always_comb begin
		case(ps)
			none: 	if (user_in)	ns = detect;
					else 			ns = none;
			detect: if (user_in) 	ns = hold;
					else 			ns = none;
			hold: 	if (user_in) 	ns = hold;
					else 			ns = none;
			default: ns = none;
		endcase
	end
	
	// State registers
	always_ff @(posedge clk) begin
		if (reset)
			ps <= none;
		else
			ps <= ns;
	end
	
	// Output state
	assign user_out = (ps == hold);
	
endmodule // Metastability_Buffer

module Metastability_Buffer_Testbench();
	// Ports
	logic clk, reset;
	logic user_in;
	logic user_out;

	// Device under test
	Metastability_Buffer dut (.*);

	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin		
		/* NOP */ 		repeat(01) @(posedge clk);
		
		// Reset
		reset <= 1; 	repeat(01) @(posedge clk);
		reset <= 0;		repeat(01) @(posedge clk);
		
		// Test buffering
		user_in <= 0; 	repeat(12) @(posedge clk);
		user_in <= 1; 	repeat(01) @(posedge clk);
		user_in <= 0; 	repeat(04) @(posedge clk);
		user_in <= 1; 	repeat(05) @(posedge clk);
		user_in <= 0; 	repeat(02) @(posedge clk);
		user_in <= 1; 	repeat(03) @(posedge clk);
		user_in <= 0; 	repeat(04) @(posedge clk);
		user_in <= 1; 	repeat(02) @(posedge clk);
		user_in <= 0; 	repeat(04) @(posedge clk);
		
		// Test synchronous reset
		user_in <= 1; 	repeat(05) @(posedge clk);
		reset <= 1;		repeat(05) @(posedge clk);
		reset <= 0;		repeat(05) @(posedge clk);
		
		// End the simulation.
		$stop;
	end
endmodule // Metastability_Buffer_Testbench
