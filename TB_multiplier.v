// Author: Dylan Boland

module TB_multiplier;

	// ==== Parameters ====
	localparam WIDTH_A = 10;                // number of bits in input a
	localparam WIDTH_B = 8;                 // number of bits in input b
	localparam WIDTH_C = WIDTH_A + WIDTH_B; // number of bits in the product of a and b
	localparam CLK_PERIOD = 30;             // clock period in ns

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
	
	// ==== Test bench Variables Used during Randomisation ====
	bit [WIDTH_A-1:0] num1;
	bit [WIDTH_B-1:0] num2;

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
	function int multiply (input int num1, num2);
		begin
			multiply = num1*num2;
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
			@(posedge clk);
			#1;
			// ==== Check the Output ====
			if (c == multiply(a, b)) begin
				pass_cnt = pass_cnt + 1;
			end else begin
				error_cnt = error_cnt + 1;
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
		repeat (10) begin
			// ==== Generate Some Random Numbers ====
			num1 = $random;
			num2 = $random;
			update_inputs_check_output(num1, num2);
		end
		#50;
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
		



