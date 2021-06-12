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
	logic [31:0] hexes, hexes_old;
	logic we;
	initial begin
		hexes = 32'b0;
		hexes_old = 32'b0;
		we = 1'b0;
	end
	cpu dut(.clk(CLOCK_50), .rst(KEY[3]), .sw_F(SW), .HEX_out(hexes), .out_we(we));
	always @(posedge CLOCK_50) begin
		if (we === 1'b1) assign hexes_old = hexes;
	end
	hexdecoder seg0(hexes_old[3:0], HEX0);
	hexdecoder seg1(hexes_old[7:4], HEX1);
	hexdecoder seg2(hexes_old[11:8], HEX2);
	hexdecoder seg3(hexes_old[15:12], HEX3);
	hexdecoder seg4(hexes_old[19:16], HEX4);
	hexdecoder seg5(hexes_old[23:20], HEX5);
	hexdecoder seg6(hexes_old[27:24], HEX6);
	hexdecoder seg7(hexes_old[31:28], HEX7);
endmodule
