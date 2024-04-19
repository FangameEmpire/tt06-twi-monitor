module TWI_Monitor (
	clk, 
	reset, 
	enable, 
	SDA, 
	SCL, 
	TX
);

	// Ports
	input logic clk, reset, enable;
	input logic SDA, SCL;
	output logic TX;
	
	// TWI Start/Stop Condition detection
	wire start_detected, stop_detected;
	I2C_Start_Stop_Detector cond_detector (.*);
	
	// Convert SCL posedge to single-cycle pulse
	wire SCL_pos;
	Posedge_Detector SCL_pulser (.clk, .reset, .in(SCL), .posedge_detected(SCL_pos));
	
	// 18-bit shift register for address and data frames
	// 18 bits for: {7 bit address, Read/Write, N/Ack, 8 bit data, N/Ack}
	wire new_data_ready;
	wire [17:0] current_data;
	Shift_In #(.WIDTH(18)) twi_frame_buffer (.clk, .reset(reset | start_detected), .enable(SCL_pos), .in(SDA), .out(current_data), .new_data(new_data_ready));
	
	// Hold data for the UART TX
	// Save TWI frame if a new frame is available and if UART is not busy
	// Can miss frames if they come too fast, not going to matter for such a low-level project
	wire TX_available;
	reg [7:0] TX_buffer;
	reg [17:0] current_data_buffer;
	always_ff @(posedge clk) begin
		if (reset) begin
			current_data_buffer <= 18'b0;
		end else if (enable & new_data_ready & TX_available) begin
			current_data_buffer <= current_data;
		end else begin 
			current_data_buffer <= current_data_buffer;
		end
	end // always_ff (@posedge clk)
	
	// Send data to UART TX by chopping a frame into 3 bytes and sending them serially
	wire TX_busy, TX_start;
	TWI_Frame_Presenter TX_loader (.clk, .reset, .enable, .frame(current_data_buffer), .TX_feed(TX_buffer), 
								   .new_data_ready, .TX_busy, .TX_start, .TX_available);
	
	// UART TX
	async_transmitter #(.FREQUENCY(50000000), .BAUD(115200)) TX_to_user (.clk, .TxD_start(TX_start), .TxD_data(TX_buffer), .TxD(TX), .TxD_busy(TX_busy));
	
endmodule // TWI_Monitor
