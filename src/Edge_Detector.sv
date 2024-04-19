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
