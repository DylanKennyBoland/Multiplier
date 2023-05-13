// Author: Dylan Boland

module TB_multiplier;

	// ==== Parameters ====
	localparam WIDTH_A = 10;                // number of bits in input a
	localparam WIDTH_B = 8;                 // number of bits in input b
	localparam WIDTH_C = WIDTH_A + WIDTH_B; // number of bits in the product of a and b
	localparam CLK_PERIOD = 30;             // clock period in ns
	localparam MAX_VAL_A = {1'b0, {(WIDTH_A-1){1'b1}}};
	localparam MAX_VAL_B = {1'b0, {(WIDTH_B-1){1'b1}}};
	localparam MIN_VAL_A = {1'b1, {(WIDTH_A-1){1'b0}}};
	localparam MIN_VAL_B = {1'b1, {(WIDTH_B-1){1'b0}}};
	localparam DEBUG = 1;
	
	// ==== TB Signals ====
	// Inputs
	reg clk;
	reg rst_n;
	reg data_valid;
	reg [WIDTH_A-1:0] a;
	reg [WIDTH_B-1:0] b;
	// Outputs
	wire [WIDTH_C-1:0] c;
	
	// ==== Counter Variables ====
	integer error_cnt = 0;
	integer pass_cnt = 0;
	int num_tests = 5; // the number of times the module inputs are changed
	
	// ==== Test bench Variables Used during Randomisation ====
	bit [WIDTH_A-1:0] num1;
	bit [WIDTH_B-1:0] num2;
	bit a_is_neg;
	bit b_is_neg;

	// ==== Instantiate the Design Under Test (DUT) ====
	multiplier #
		(
		// ==== Parameters ====
		.WIDTH_A(WIDTH_A),
		.WIDTH_B(WIDTH_B)
	) dut // name of instance
		(
		// ==== Inputs ====
		.clk(clk),
		.rst_n(rst_n),
		.data_valid(data_valid),
		.a(a),
		.b(b),
		// ==== Outputs ====
		.c(c)
	);
	
	// ==== Generate the Clock Signal ====
	initial begin
		clk = 1'b0;
		forever begin
			#(CLK_PERIOD/2) clk = ~clk; // toggle the clock signal
		end
	end

	// ==== Tasks and Functions ====
	// Task to reset the DUT
	task reset();
		begin
			@(posedge clk);
			#1 rst_n = 1'b0;
			@(posedge clk);
			#1 rst_n = 1'b1;
		end
	endtask
	
	// Function to return the Product of two Numbers
	function int multiply (input [WIDTH_A-1:0] num1, [WIDTH_B-1:0] num2);
		int int1, int2;
		int1 = $signed(num1);
		int2 = $signed(num2);
		begin
			multiply = int1*int2;
		end
	endfunction

	function void print_summary (input bit dummy_input = 1'b0); // functions in Verilog must have inputs - so supplying a "dummy" or placeholder one here
		begin
			$display("***Test Finished:\nNumber of Passes: %d\nNumber of Errors: %d", pass_cnt, error_cnt);
		end
	endfunction
	
	// Task to Update the Inputs and Check the Output
	task update_inputs_check_output(input [WIDTH_A-1:0] num1, [WIDTH_B-1:0] num2);
		begin
			@(posedge clk);
			#1;
			a = num1;
			b = num2;
			if (DEBUG == 1) begin
				$display("(a = %d, b = %d)", $signed(a), $signed(b));
			end
			@(posedge clk);
			#1;
			// ==== Check the Output ====
			if ($signed(c) == multiply(a, b)) begin
				pass_cnt = pass_cnt + 1;
			end else begin
				error_cnt = error_cnt + 1;
			end
			if (DEBUG == 1) begin
				$display("(c = %d, multiply(a, b) = %d)", $signed(c), multiply(a, b));
			end
		end
	endtask
	
	// ==== Main Testing Logic ====
	initial begin
		// (1) Initialise the input signals
		data_valid = 1'b1; // assume for now that the input data is always valid
		a = {WIDTH_A{1'b0}};
		b = {WIDTH_B{1'b0}};
		rst_n = 1'b1;
		// (2) Apply the reset
		reset();
		// (3) Drive the Input Signals to the DUT
		if ((num_tests == 0) | (num_tests < 0)) begin
			num_tests = $urandom_range(32'd10, 32'd2);
		end
		repeat (num_tests) begin
			// ==== Generate Some Random Numbers ====
			num1 = $urandom_range(32'(MAX_VAL_A), 0);
			num2 = $urandom_range(32'(MAX_VAL_B), 0);
			// ==== Randomly decide if the Inputs should be made Negative ====
			a_is_neg = $random;
			b_is_neg = $random;
			if (DEBUG == 1) begin
				$display("(num1 = %d, num2 = %d)", $signed(num1), $signed(num2));
			end
			if (a_is_neg) begin
				num1 = -1*num1;
				if (DEBUG == 1) begin
					$display("Input a will be negative (num1 = %d)", $signed(num1));
				end
			end
			if (b_is_neg) begin
				num2 = -1*num2;
				if (DEBUG == 1) begin
					$display("Input b will be negative (num2 = %d)", $signed(num2));
				end
			end
			// ==== Update the Inputs and Check the Output ====
			update_inputs_check_output(num1, num2);
		end
		#100;
		// ==== Test the Module when the Inputs have their Maximum Values ====
		update_inputs_check_output(MAX_VAL_A, MAX_VAL_B);
		#50;
		// ==== Test the Module when the Inputs have their Minimum Values ====
		update_inputs_check_output(MIN_VAL_A, MIN_VAL_B);
		#75;
		// (4) Print a summary
		print_summary();
		$finish;
	end
	
	// ==== Get the Waves ====
	initial begin
		$dumpfile("dump.vcd");
		$dumpvars(2);
	end
	
endmodule
		



