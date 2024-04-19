// Monitors a signal for positive and negative edges. Useful for generating enables from slowed clocks.
// Outputs 1-cycle pulse on first positive or negative cycle of input.
module Edge_Detector(
	clk, 
	reset, 
	in, 
	posedge_detected, 
	negedge_detected
);
	// Ports
	input logic clk, reset;
	input logic in;
	output logic posedge_detected, negedge_detected;
	
	// Store previous value
	reg prev;
	always @(posedge clk) begin
		if (reset) 	prev <= 1'b0;
		else 		prev <= in;
	end // always @(posedge clk)
	
	// Detect edges
	assign posedge_detected = in & ~prev & ~reset;
	assign negedge_detected = ~in & prev & ~reset;
	
endmodule // Edge_Detector

module Edge_Detector_Testbench();
	// Ports
	logic clk, reset;
	logic in;
	logic posedge_detected, negedge_detected;

	// Device under test
	Edge_Detector dut (.*);

	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end
	
	initial begin		
		/* NOP */ 	repeat(01) @(posedge clk);
		
		// Reset
		reset <= 1; repeat(01) @(posedge clk);
		reset <= 0;	repeat(01) @(posedge clk);
		
		// Test edge detection
		in <= 0; 	repeat(12) @(posedge clk);
		in <= 1; 	repeat(01) @(posedge clk);
		in <= 0; 	repeat(04) @(posedge clk);
		in <= 1; 	repeat(05) @(posedge clk);
		in <= 0; 	repeat(02) @(posedge clk);
		in <= 1; 	repeat(03) @(posedge clk);
		in <= 0; 	repeat(04) @(posedge clk);
		in <= 1; 	repeat(02) @(posedge clk);
		in <= 0; 	repeat(04) @(posedge clk);
		in <= 1; 	repeat(01) @(posedge clk);
		in <= 0; 	repeat(01) @(posedge clk);
		in <= 1; 	repeat(01) @(posedge clk);
		in <= 0; 	repeat(01) @(posedge clk);
		
		// Test synchronous reset
		in <= 1; 	repeat(05) @(posedge clk);
		reset <= 1;	repeat(05) @(posedge clk);
		in <= 0; 	repeat(05) @(posedge clk);
		reset <= 0;	repeat(05) @(posedge clk);
		reset <= 1;	repeat(05) @(posedge clk);
		in <= 1; 	repeat(05) @(posedge clk);
		reset <= 0;	repeat(05) @(posedge clk);
		in <= 0; 	repeat(05) @(posedge clk);
		
		// End the simulation.
		$stop;
	end
endmodule // Metastability_Buffer_Testbench

module Posedge_Detector(
	clk, 
	reset, 
	in, 
	posedge_detected
);
	// Ports
	input logic clk, reset;
	input logic in;
	output logic posedge_detected;
	
	// Store previous value
	reg prev;
	always @(posedge clk) begin
		if (reset) 	prev <= 1'b0;
		else 		prev <= in;
	end // always @(posedge clk)
	
	// Detect positive edge
	assign posedge_detected = in & ~prev & ~reset;
	
endmodule // Posedge_Detector

module Negedge_Detector(
	clk, 
	reset, 
	in, 
	negedge_detected
);
	// Ports
	input logic clk, reset;
	input logic in;
	output logic negedge_detected;
	
	// Store previous value
	reg prev;
	always @(posedge clk) begin
		if (reset) 	prev <= 1'b0;
		else 		prev <= in;
	end // always @(posedge clk)
	
	// Detect negative edge
	assign negedge_detected = ~in & prev & ~reset;
	
endmodule // Negedge_Detector
