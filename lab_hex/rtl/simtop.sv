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

    int unsigned count;
    
    hexdecoder seg7(count[31:28], HEX7);
    hexdecoder seg6(count[27:24], HEX6);
    hexdecoder seg5(count[23:20], HEX5);
    hexdecoder seg4(count[19:16], HEX4);
    hexdecoder seg3(count[15:12], HEX3);
    hexdecoder seg2(count[11:8], HEX2);
    hexdecoder seg1(count[7:4], HEX1);
    hexdecoder seg0(count[3:0], HEX0);

    always_ff @(posedge CLOCK_50, posedge KEY[3]) begin
        if (KEY[3])
            count <= 32'd0;
        else
            count <= count + 1;
    end









endmodule
