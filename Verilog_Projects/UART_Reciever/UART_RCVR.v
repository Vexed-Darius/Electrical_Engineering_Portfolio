module UART_RCVR #(parameter word_size = 8, half_word = word_size / 2)
	(output read_not_ready_out,
   output Error1, Error2, SampleClkLED, SerialLED,
	output reg ShiftLED, LoadLED, BC_eq_8LED,
	output reg [6:0] SevSegOne, SevSegTwo,
   input Serial_in,
   input read_not_ready_in,
   input Sample_clk,
   input rst_b
	);
	
	assign SampleClkLED = Sample_clk;
	assign SerialLED	  = Serial_in;

	wire [word_size-1:0] RCV_datareg;
	
   Control_Unit M0 (
       read_not_ready_out, // output from the controller to the host
       Error1,             // output to host (host is not ready to receive data)
       Error2,             // output to host (stop bit is missing)
       clr_Sample_counter, // output to DataPath (clear Sample count)
       inc_Sample_counter, // output to DataPath (increment Sample count)
       clr_Bit_counter,    // output to DataPath (clear Bit counter)
       inc_Bit_counter,    // output to DataPath (increment Bit counter)
       shift,              // output to DataPath
       load,               // output to DataPath
       read_not_ready_in,  // input from the host
       ser_in_0,           // input from the DataPath (flagging zero input data)
       SC_eq_3,            // input from the DataPath (flagging center bit)
       SC_lt_7,            // input from the DataPath (Sample counter less than 7)
       BC_eq_8,            // input from the DataPath (Bit counter reached 8)
       Sample_clk,         // input high rate sample clock
       rst_b               // input reset
	);

   DataPath_Unit M1 (
       RCV_datareg,        // output parallel data word to the host
       ser_in_0,           // output flag to the controller
       SC_eq_3,            // output flag to the controller
       SC_lt_7,            // output flag to the controller
       BC_eq_8,            // output flag to the controller
       Serial_in,          // input serial bit from transmission link
       clr_Sample_counter, // input from controller
       inc_Sample_counter, // input from controller
       clr_Bit_counter,    // input from controller
       inc_Bit_counter,    // input from controller
       shift,              // input from controller
       load,               // input from controller
       Sample_clk,         // overall input sample clock
       rst_b               // overall input reset
    );
	 
	parameter BLANK 	 = 7'b111_0000;
	parameter ZERO  	 = 7'b100_0000;
	parameter ONE	 	 = 7'b111_1001;
	parameter TWO	 	 = 7'b010_0100;
	parameter THREE 	 = 7'b011_0000;
	parameter FOUR	 	 = 7'b001_1001;
	parameter FIVE	 	 = 7'b001_0010;
	parameter SIX	 	 = 7'b000_0010;
	parameter SEVEN	 = 7'b111_1000;
	parameter EIGHT	 = 7'b000_0000;
	parameter NINE	 	 = 7'b001_1000;
	parameter a			 = 7'b000_1000;
	parameter b			 = 7'b000_0011;
	parameter c			 = 7'b100_0110;
	parameter d			 = 7'b010_0001;
	parameter e			 = 7'b000_0110;
	parameter f			 = 7'b000_1110;
	
	always @ (posedge Sample_clk or negedge rst_b) begin
        if (~rst_b) begin
            // Reset LEDs to known state on reset
            ShiftLED <= 0;
            LoadLED <= 0;
            BC_eq_8LED <= 0;
        end else begin
            // Update LEDs based on clocked signals
            ShiftLED <= shift;
            LoadLED <= load;
            BC_eq_8LED <= BC_eq_8;
        end
    end
	
	always @ * begin	
		case (RCV_datareg[3:0])   // LS part of Serial to right display
		4'h0: SevSegOne = ZERO;
		4'h1: SevSegOne = ONE;
		4'h2: SevSegOne = TWO;
		4'h3: SevSegOne = THREE;
		4'h4: SevSegOne = FOUR;
		4'h5: SevSegOne = FIVE;
		4'h6: SevSegOne = SIX;
		4'h7: SevSegOne = SEVEN;
		4'h8: SevSegOne = EIGHT;
		4'h9: SevSegOne = NINE;
		4'hA: SevSegOne = a;
		4'hB: SevSegOne = b;
		4'hC: SevSegOne = c;
		4'hD: SevSegOne = d;
		4'hE: SevSegOne = e;
		4'hF: SevSegOne = f;
		default: SevSegOne = BLANK;
		endcase

		case (RCV_datareg[7:4])   // MS part of serial to left display
		4'h0: SevSegTwo = ZERO;
		4'h1: SevSegTwo = ONE;
		4'h2: SevSegTwo = TWO;
		4'h3: SevSegTwo = THREE;
		4'h4: SevSegTwo = FOUR;
		4'h5: SevSegTwo = FIVE;
		4'h6: SevSegTwo = SIX;
		4'h7: SevSegTwo = SEVEN;
		4'h8: SevSegTwo = EIGHT;
		4'h9: SevSegTwo = NINE;
		4'hA: SevSegTwo = a;
		4'hB: SevSegTwo = b;
		4'hC: SevSegTwo = c;
		4'hD: SevSegTwo = d;
		4'hE: SevSegTwo = e;
		4'hF: SevSegTwo = f;
		default: SevSegTwo = BLANK;
		endcase
	end
endmodule

module Control_Unit #(parameter word_size = 8, half_word_size = word_size / 2, Num_state_bits = 2,
    idle     = 2'b00, starting = 2'b01, receiving = 2'b10)
	 
	(output reg read_not_ready_out,
   Error1, Error2,
   clr_Sample_counter,
   inc_Sample_counter,
   clr_Bit_counter,
   inc_Bit_counter,
   shift,
   load,
   input read_not_ready_in,
   ser_in_0,
   SC_eq_3,
   SC_lt_7,
   BC_eq_8,
   Sample_clk,
   rst_b);

	reg [word_size-1:0] RCV_shftreg;
	reg [Num_state_bits-1:0] state, next_state;

	always @ (posedge Sample_clk)
		 if (~rst_b) state <= idle;
		 else        state <= next_state;

	always @ *
		begin
		 // default values
		 read_not_ready_out   = 0;
		 Error1               = 0;
		 Error2               = 0;
		 clr_Sample_counter   = 0;
		 inc_Sample_counter   = 0;
		 clr_Bit_counter      = 0;
		 inc_Bit_counter      = 0;
		 shift                = 0;
		 load                 = 0;
		 next_state           = idle;
		 
	case (state)
		 idle : if (ser_in_0) next_state = starting;
					else next_state = idle;

	starting : if (ser_in_0 == 1'b0) // not enough samples of zero for start-bit
					begin 
					//next_state = receiving;
					next_state = idle;
					clr_Sample_counter = 1; end
				else if (SC_eq_3 == 1'b1)	// enough samples confirming a 0 start bit
					begin
					next_state = receiving;
					clr_Sample_counter = 1; end
				else begin	// still checking the validity of start-bit
					inc_Sample_counter = 1;
					next_state = starting; end

	receiving : if (SC_lt_7 == 1'b1)
					begin inc_Sample_counter = 1;
					next_state = receiving; end
				else begin
					clr_Sample_counter = 1;
					if (!BC_eq_8) begin
					shift = 1;
					inc_Bit_counter = 1;
					next_state = receiving; end
				else begin
					next_state = idle;
					read_not_ready_out = 1;
					clr_Bit_counter = 1;
					if (read_not_ready_in)
					Error1 = 1;
					else if (ser_in_0)
					Error2 = 1;
					else
					load = 1;
					end		 
			end
	default : next_state = idle;
	endcase
	end
endmodule

module DataPath_Unit #(parameter word_size = 8, half_word = word_size / 2, NUM_counter_bits = 4)
							(output reg [word_size -1 : 0] RCV_datareg, output ser_in_0, SC_eq_3, SC_lt_7, BC_eq_8,
							input Serial_in, rst_b, clr_sample_counter, inc_sample_counter, clr_Bit_counter, 
							inc_Bit_counter, shift, load, Sample_clk);

	reg [word_size-1 : 0] RCV_shiftreg;
	reg [NUM_counter_bits-1 : 0] Sample_counter; // 0-7 count
	reg [NUM_counter_bits : 0] Bit_counter; // 0-8 count

	assign ser_in_0 = (Serial_in == 1'b0);
	assign BC_eq_8 = (Bit_counter == word_size);
	assign SC_lt_7 = (Sample_counter < word_size-1);
	assign SC_eq_3 = (Sample_counter == half_word-1);

	always @ (posedge Sample_clk)
		if (!rst_b)
			begin
				Sample_counter <= 0;
				Bit_counter <= 0;
				RCV_datareg <= 0;
				RCV_shiftreg <= 0;
			end
	else begin
			if (clr_sample_counter)
			Sample_counter <= 0;
			else if (inc_sample_counter)
			Sample_counter <= (Sample_counter + 1);

			if (clr_Bit_counter)
			Bit_counter <= 0;
			else if (inc_Bit_counter)
			Bit_counter <= (Bit_counter + 1);

			if (shift)
			RCV_shiftreg <= {Serial_in, RCV_shiftreg [word_size-1:1]};
			if (load)
			RCV_datareg <= RCV_shiftreg;
	end
endmodule
