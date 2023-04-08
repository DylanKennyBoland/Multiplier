// Author: Dylan Boland

module multiplier #
	(
	// ==== Parameters ====
	parameter WIDTH_A = 10, // number of bits in input a
	parameter WIDTH_B = 8,  // number of bits in input b
	localparam WIDTH_C = WIDTH_A + WIDTH_B
	)
	(
	// ==== Inputs ====
	input clk,             // input clock signal
	input rst_n,           // input active-low reset signal which is asynchronous
	input data_valid,      // one-bit signal that indicates that both input values are valid (and can be used)
	input [WIDTH_A-1:0] a, // signed input (two's complement form)
	input [WIDTH_B-1:0] b, // signed input (two's complement form)
	// ==== Outputs ====
	output [WIDTH_C-1:0] c // the product of a and b
	);

	// ==== Internal Signals ====
	reg [WIDTH_C-1:0] product_reg;
	reg [WIDTH_C-1:0] product;
	// Creating the signals below to improve readability
	wire msb_a = a[WIDTH_A-1]; // the most-significant bit of input a
	wire msb_b = b[WIDTH_B-1]; // the most significant bit of input b

	// ==== Logic for the Multiplication ====
	always @ (*) begin
		integer i; // variable for the for loop below
		product = {WIDTH_C{1'b0}};
		if (WIDTH_B < WIDTH_A) begin
			// If input b has less bits than input a, then we will make input
			// b the "multiplier" in order to minimise the number of partial
			// products that we have to add together.
			for (i = 0; i < WIDTH_B; i = i + 1) begin
				product = product + ((a & {WIDTH_A{b[i]}}) << i);
			end
		end else begin
			// If it happens that input a has less bits than input b, then
			// making it the "multiplier" will minimise the number of partial
			// products that we will have to add together. If input a and
			// b have the same number of bits then it does not matter which is
			// the multiplier and which is the multiplicand.
			for (i = 0; i < WIDTH_A; i = i + 1) begin
				product = product + ((b & {WIDTH_B{a[i]}}) << i);
			end
		end
	end
	
	// ==== Logic for Updating the Register ====
	always @ (posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			// reset the register
			product_reg <= {WIDTH_C{1'b0}};
		end else begin
			if (data_valid) begin
				// only update the register if the input data is valid
				product_reg <= product;
			end
			// otherwise, hold onto the current value in the register
		end
	end

	// ==== Logic for Driving the Output ====
	assign c = product_reg;

endmodule





