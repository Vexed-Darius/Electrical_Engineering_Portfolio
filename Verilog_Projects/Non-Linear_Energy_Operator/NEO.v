	module NEO (Enable, Load, clk, rst, Full, Data_out, Data_in, write_en);
		input Enable, Load, clk, Full, rst;
		output write_en;
		
		parameter Data_width = 8;		// Sets the width of the Data
		
		wire start;
		
		input  signed [Data_width-1:0] Data_in;			// Sets Data_in width
		output signed [Data_width*2-1:0] Data_out;		// Sets Data_out width
		
		Controller M1 (Enable, Load, rst, clk, Full, start, write_en);
		
		Datapath	  M0 (Data_out, Data_in, clk, rst, start);
	
	endmodule
	
	module Controller (Enable, Load, rst, clk, Full, start, write_en);
		input	Full, Enable, Load, clk, rst;
		output reg start, write_en;
		
		parameter Idle = 1'b0;	// Machine is idle when waiting for start
		parameter DSP	= 1'b1;	// Performs NEO DSP
		reg state, next_state;
		
		always @ (posedge clk or posedge rst)
			if (rst)
				state <= Idle;
			else
				state <= next_state;
				
		always @ *
			begin
			start = 0;
			write_en =0;
				case (state)
				Idle: if (Enable)
						next_state <= DSP;	// Next_state goes to digital signal processing state
						else
						next_state <= Idle;	// Remain in idle if not enabled
						
				DSP:	if (~Full) begin		// If the Memory dump is not full begin
						start = 1;				// Set start signal to high for Datapath
						if (Load)
						write_en = 1; end		// Sets write_en to high for memory
						else if (Full)
						next_state <= Idle;	// Stops the DSP if memory is full
				endcase
			end	
	endmodule
	
	module Datapath (Data_out, Data_in, clk, rst, start);
		parameter Data_width = 8;						// Sets the width of the Data
		input signed [Data_width-1:0] Data_in;				// Input to datapath
		input clk, rst, start;							// Inputs from Controller and sync
		output reg signed [Data_width*2-1:0] Data_out;	// Output from datapath
		
		reg signed [Data_width-1:0] 	Current, Prev, Ahead;	// Registers for holding prev, current, and future values
		
		always @ (posedge clk)
			begin
				if (rst) begin
					Data_out <= 0;		// Data_out is set to 0
					Current <= 0;		// Current reg is set to 0
					Prev <= 0;			// Prev reg is set to 0
					Ahead <= 0; end	// Ahead reg is set to 0
					
			 else if (start) begin
					Prev <= Current;	// Prev reg is now current reg
					Current <= Ahead;	// Current reg is now ahead reg
					Ahead <= Data_in;	// Ahead reg is now data_in

					Data_out <= (Current * Current) - (Prev * Ahead); end	// Performs NEO equation to output value
			end
	endmodule