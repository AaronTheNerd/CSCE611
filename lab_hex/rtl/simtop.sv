/* Copyright 2020 Jason Bakos, Philip Conrad, Charles Daniels */

/* Top-level module for CSCE611 RISC-V CPU, for running under simulation.  In
 * this case, the I/Os and clock are driven by the simulator. */

module simtop (
	//////////// CLOCK //////////
	input                                   CLOCK_50,
	input                                   CLOCK2_50,
        input                                   CLOCK3_50,

	//////////// LED //////////
	output               [8:0]              LEDG,
	output              [17:0]              LEDR,

	//////////// KEY //////////
	input                [3:0]              KEY,

	//////////// SW //////////
	input               [17:0]              SW,

	//////////// SEG7 //////////
	output               [6:0]              HEX0,
	output               [6:0]              HEX1,
	output               [6:0]              HEX2,
	output               [6:0]              HEX3,
	output               [6:0]              HEX4,
	output               [6:0]              HEX5,
	output               [6:0]              HEX6,
	output               [6:0]              HEX7

);

// your code here

endmodule
