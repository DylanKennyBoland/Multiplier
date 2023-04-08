# Multiplier
A basic modules that takes in two inputs, which are in two's complement form, and multiplies
them to produce the output. There is a data-valid signal (data_valid) which indicates that 
the two inputs are valid.

Parameters:
 - WIDTH_A: the width of input a
 - WIDTH_B: the width of input b
 - WIDTH_C: the width of output c, which equals WIDTH_A + WIDTH_B

Inputs:
 - clk: the clock signal
 - rst_n: active-low reset signal (asynchronous)
 - a: input, of width WIDTH_A
 - b: input, of width WIDTH_B
 - data_valid: indicates that the inputs a and b are valid

Outputs:
 - c: the output (of width WIDTH_C) which is equal to the product of a and b 