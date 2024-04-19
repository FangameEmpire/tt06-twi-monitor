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
			default: 				ns = idle;
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
