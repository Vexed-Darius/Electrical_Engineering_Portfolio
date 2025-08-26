	module NEO_tbx;
		reg Enable, Load, clk, Full, rst;			// User/Memory controlled signals
		reg signed [7:0] INPUT;							// Input signal
		wire signed [15:0] OUTPUT;						// NEO output
		integer file_out, i;								// Temp integers for controlling read/write for loops
		reg signed [7:0] input_data [0:255];		// input_data is the data that is coming from MATLAB txt file
		reg signed [15:0] output_buffer [0:255];	// buffered output to account for clock cycle delay
		integer delay = 3;								// Delay is representing the 3 cycles the NEO is 0

		NEO UUT (.Enable(Enable), .Load(Load), .clk(clk), 
			.rst(rst), .Full(Full), .Data_out(OUTPUT), .Data_in(INPUT));

		initial clk = 0;			// Sets clock speed
		always #10 clk = ~clk;

		initial $readmemh("input_data.hex", input_data);	// Reads the file and puts the value into input_data

		initial begin
			rst = 1; Enable = 0; Load = 0; Full = 0;			// Initialize all control values
			#40 rst = 0; Enable = 1; Load = 1;

			file_out = $fopen("output_data.txt", "w");		// Defines the output file and sets to write mode

			for (i = 0; i < 256; i = i + 1) begin				// For loop for reading input_data.hex file
				INPUT = input_data[i];
				#20;
				if (i >= delay)
					output_buffer[i - delay] = OUTPUT;			// When the first 3 '0' values are passed, start saving
			end

			for (i = 0; i < 256 - delay; i = i + 1)			// For loop for writing output_buffer to data_out.txt
				$fwrite(file_out, "%d\n", output_buffer[i]);

			$fclose(file_out);	// Closes output_data.txt
			$stop;					// Stops simulation w/o need of finish prompt
		end
	endmodule
