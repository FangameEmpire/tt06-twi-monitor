module TWI_Frame_Presenter (
	clk, 
	reset, 
	enable, 
	frame, 
	TX_feed, 
	new_data_ready, 
	TX_busy, 
	TX_start, 
	TX_available
);

	// System ports
	input logic clk, reset, enable;
	
	// Data ports
	input logic [17:0] frame;
	output logic [7:0] TX_feed;
	
	// Control ports
	input logic new_data_ready, TX_busy;
	output logic TX_start, TX_available; 
	
	// FSM states
	enum {idle, start_addr, send_addr, start_data, send_data, start_acks, send_acks} ps, ns;
	
	// Next state logic
	always_comb begin
		case (ps)
			idle: begin
				if (new_data_ready) ns = start_addr;
				else				ns = idle;
			end
			start_addr: begin
				if (TX_busy)		ns = send_addr;
				else				ns = start_addr;
			end
			send_addr: begin
				if (~TX_busy)		ns = start_data;
				else				ns = send_addr;
			end
			start_data: begin
				if (TX_busy)		ns = send_data;
				else				ns = start_data;
			end
			send_data: begin
				if (~TX_busy)		ns = start_acks;
				else				ns = send_data;
			end
			start_acks: begin
				if (TX_busy)		ns = send_acks;
				else				ns = start_acks;
			end
			send_acks: begin
				if (~TX_busy)		ns = idle;
				else				ns = send_acks;
			end
		endcase // ps
	end // always_comb
	
	// FSM registers
	always_ff @(posedge clk) begin
		if (reset)			ps <= idle;
		else if (~enable)	ps <= ps;
		else				ps <= ns;
	end // always_ff @(posedge clk)
	
	// Outputs to control TX, frame buffer
	assign TX_start = ((ps == start_addr)  | (ps == start_data) | (ps == start_acks));
	assign TX_available = (ps == idle);
	
	// Present sections of frame to the UART transmitter
	always_comb begin
		case (ps)
			start_addr:	TX_feed = frame[17:10];
			send_addr:	TX_feed = frame[17:10];
			start_data:	TX_feed = frame[08:01];
			send_data:	TX_feed = frame[08:01];
			start_acks:	TX_feed = {{4{frame[9]}}, {4{frame[0]}}};
			send_acks:	TX_feed = {{4{frame[9]}}, {4{frame[0]}}};
			default:	TX_feed = 8'b0;
		endcase // ps
	end // always_comb
	
endmodule // TWI_Frame_Presenter

module TWI_Frame_Presenter_Testbench();
	localparam WIDTH = 18;

	// System ports
	logic clk, reset, enable;
	
	// Data ports
	logic [17:0] frame;
	logic [7:0] TX_feed;
	
	// Control ports
	logic new_data_ready, TX_busy;
	logic TX_start, TX_available; 

	// Device under test
	TWI_Frame_Presenter dut (.*);

	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	// SCL is far slower than clk
	localparam ov = 3;
	
	// Display current test
	string current_test;
	
	initial begin		
		// Reset
		current_test = "Reset";
		reset <= 1; enable <= 0;							repeat(01) @(posedge clk);
		frame <= 18'b0;	new_data_ready <= 0; TX_busy <= 0;	repeat(01) @(posedge clk);
		reset <= 0;	enable <= 1;							repeat(01) @(posedge clk);
		
		// New data ready
		current_test = "New Data";
		frame <= {8'h22, 1'b1, 8'h77, 1'b0}; new_data_ready <= 1;	repeat(01) @(posedge clk);
		new_data_ready <= 0;										repeat(01) @(posedge clk);
		
		// Send address
		current_test = "Addr";
		TX_busy <= 1;	repeat(ov) @(posedge clk);
		TX_busy <= 0;	repeat(ov) @(posedge clk);
		
		// Send data
		current_test = "Data";
		TX_busy <= 1;	repeat(ov) @(posedge clk);
		TX_busy <= 0;	repeat(ov) @(posedge clk);
		
		// Send acks
		current_test = "Acks";
		TX_busy <= 1;	repeat(ov) @(posedge clk);
		TX_busy <= 0;	repeat(ov) @(posedge clk);
		
		// Reset
		current_test = "Reset";
		reset <= 1;	repeat(01) @(posedge clk);
		reset <= 0;	repeat(01) @(posedge clk);
		
		// Repeated data transfers
		current_test = "Multiple frames";
		frame <= {8'h53, 1'b1, 8'h16, 1'b1}; new_data_ready <= 1;	repeat(01) @(posedge clk);
		new_data_ready <= 0;										repeat(01) @(posedge clk);
		for (int i = 0; i < 5; i++) begin
			TX_busy <= 1;	repeat(01) @(posedge clk);
			TX_busy <= 0;	repeat(01) @(posedge clk);
		end // for i
		
		new_data_ready <= 1;	repeat(01) @(posedge clk);
		new_data_ready <= 0;	repeat(01) @(posedge clk);
		
		for (int i = 0; i < 5; i++) begin
			TX_busy <= 1;	repeat(01) @(posedge clk);
			TX_busy <= 0;	repeat(01) @(posedge clk);
		end // for i
		
		// Frame interruption
		current_test = "Frame input changes when TX_available is false";
		frame <= {8'hAA, 1'b0, 8'hBB, 1'b0}; new_data_ready <= 1;	repeat(01) @(posedge clk);
		new_data_ready <= 0;										repeat(01) @(posedge clk);
		TX_busy <= 1;	repeat(01) @(posedge clk);
		TX_busy <= 0;	repeat(01) @(posedge clk);
		TX_busy <= 1;	repeat(01) @(posedge clk);
		TX_busy <= 0;	repeat(01) @(posedge clk);
		
		frame <= {8'hCC, 1'b1, 8'hDD, 1'b1}; new_data_ready <= 1;	repeat(01) @(posedge clk);
		new_data_ready <= 0;										repeat(01) @(posedge clk);
		TX_busy <= 1;	repeat(01) @(posedge clk);
		TX_busy <= 0;	repeat(01) @(posedge clk);
		
		frame <= {8'hEE, 1'b0, 8'hFF, 1'b0}; new_data_ready <= 1;	repeat(01) @(posedge clk);
		new_data_ready <= 0;										repeat(01) @(posedge clk);
		TX_busy <= 1;	repeat(01) @(posedge clk);
		TX_busy <= 0;	repeat(01) @(posedge clk);
		
		// End the simulation.
		$stop;
	end
endmodule // TWI_Frame_Presenter_Testbench