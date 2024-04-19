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
