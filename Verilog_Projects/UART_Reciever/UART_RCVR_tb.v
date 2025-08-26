	module UART_RCVR_tb();
	
	parameter word_size = 8; half_word = word_size/2;
	parameter Num_counter_bits = 4;
	parameter Num_state_bits = 2;
	
	wire [word_size-1:0] RCV_datareg;
	wire	read_not_ready_out, Error1, Error2, SampleClkLED, SerialLED
	
	reg Serial_in, read_not_ready_out;
	reg Sample
	
	UART_RCVR	(read_not_ready_out,
					Error1, Error2, SampleClkLED, SerialLED,
					ShiftLED, LoadLED, BC_eq_8LED,
					SevSegOne, SevSegTwo,
					Serial_in,
					read_not_ready_in,
					Sample_clk,
					rst_b);
					
	assign SC_eq_3						= UUT.SC_eq_3;
	assign SC_lt_7						= UUT.SC_lt_7;
	assign BC_eq_8						= UUT.BC_eq_8;
	assign state						= UUT.M0.state;
	assign clr_Sample_counter		= UUT.clr_Sample_counter;
	assign inc_Sample_counter		= UUT.inc_sample_counter;
	assign clr_bit_counter			= UUT.