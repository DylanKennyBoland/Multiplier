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
	wire [WIDTH_C-1:0] a_sign_extended;
	wire [WIDTH_C-1:0] b_sign_extended;
	wire [WIDTH_A:0] a_twos_complement;
	wire [WIDTH_B:0] b_twos_complement;
	wire a_is_negative; // 1-bit signal to indicate if input a is negative
	wire b_is_negative; // and another 1-bit signal to indicate if input b is negative
	reg [WIDTH_C-1:0] product_reg;
	reg [WIDTH_C-1:0] product;
	
	// ==== Logic for Sign Extending the Inputs ====
	assign a_sign_extended = {{(WIDTH_B){a[WIDTH_A-1]}}, a};
	assign b_sign_extended = {{(WIDTH_A){b[WIDTH_B-1]}}, b};
	
	// ==== Logic for Forming the Two's complement of the Inputs a and b ====
	assign a_twos_complement = ~{{a[WIDTH_A-1]}, a} + 1'b1;
	assign b_twos_complement = ~{{b[WIDTH_B-1]}, b} + 1'b1;
	
	// ==== Logic for Sign-indicator Signals ====
	// I am just adding these signals to try and improve
	// the readability of the module.
	assign a_is_negative = a[WIDTH_A-1]; // if the MSB is 1, then input a is negative, otherwise it's positive
	assign b_is_negative = b[WIDTH_B-1];
	
	// ==== Logic for the Multiplication ====
	always @ (*) begin
		integer i; // variable for the for loop below
		product = {WIDTH_C{1'b0}};
		if (WIDTH_B < WIDTH_A) begin
			// If input b has less bits than input a, then we will make input
			// b the "multiplier" in order to minimise the number of partial
			// products that we have to add together.
			for (i = 0; i < WIDTH_B; i = i + 1) begin
				if ((i == (WIDTH_B-1)) & b_is_negative) begin
					// If b is a negative quantity (which will be the case if the
					// MSB is 1) then the last partial product is the complement of
					// input a
					product = product + (a_twos_complement << i);
				end else begin
					product = product + ((a_sign_extended << i) & {WIDTH_C{b[i]}});
				end
			end
		end else begin
			// If it happens that input a has less bits than input b, then
			// making it the "multiplier" will minimise the number of partial
			// products that we will have to add together. If input a and
			// b have the same number of bits then it does not matter which is
			// the multiplier and which is the multiplicand.
			for (i = 0; i < WIDTH_A; i = i + 1) begin
				if ((i == (WIDTH_A-1)) & a_is_negative) begin
					// If a is a negative quantity (which will be the case if the
					// MSB is 1) then the last partial product is the complement of
					// input b
					product = product + (b_twos_complement << i);
				end else begin
					product = product + ((b_sign_extended << i) & {WIDTH_C{a[i]}});
				end
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





