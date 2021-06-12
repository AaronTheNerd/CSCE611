module alu_testtop;

/** RISC-V register file testbench for CSCE611 Fall 2020
 *
 * Copyright 2020 Jason Bakos, Philip Conrad, Charles Daniels
 * /

/** test vector format
 *
 * Each vector is encoded as ASCII hexadecimal text, with the following
 * fields, from MSB to LSB:
 *
 * FIELD    SIZE (bits)     PURPOSE
 * mark     4               If mark equals 0x0, do nothing. If mark equals
 *                          0x1, run the test vector. If mark equals 0x4,
 *                          $finish().
 *
 * index    16              Used when printing output to make it easier for
 *                          a human reader to identify the relevant test
 *
 * op       4               ALU op input.
 *
 * A        32              ALU A input.
 *
 * B        32              ALU B input.
 *
 * R        32              Expected ALU output.
 *
 * Each vector has a total size of 120 bits, or 30 hexadecimal characters.
 *
 * The last line of output from this testbench will indicate the number of
 * test vectors that passed, and the number that encountered errors.
 */

logic clk, err;
logic [ 3:0] mark, op;
logic [15:0] index;
logic [31:0] A, B, R, R_exp, errcount, okcount, vecno;
logic [120:0] vector;
logic [120:0] vectors[10000:0];

alu dut(.A(A), .B(B), .op(op), .R(R));

initial begin

	vecno = 0;
	errcount = 0;
	okcount = 0;
	clk = 0;

	$readmemh("testbench/alu_vectors.txt", vectors);
end

always begin
	 clk = 1'b1; #5; clk = 1'b0; #5;
end

always @(posedge clk) begin
	vector = vectors[vecno];
	mark  = vector[119:116];

	if (mark != 4'h0) begin
		R_exp = vector[ 31:0  ];
		B     = vector[ 63:32 ];
		A     = vector[ 95:64 ];
		op    = vector[ 99:96 ];
		index = vector[115:100];

		$display("DEBUG: vecno=%1d clk=%1d mark=0x%01x index=0x%04x A=0x%08x B=0x%08x op=0x%1x R=0x%08x", vecno, clk, mark, index, A, B, op,  R);
	end
end

always @(negedge clk) begin

	if (mark == 4'h4) begin
		$display("DEBUG: errcount=%1d okcount=%1d", errcount, okcount);
		$finish();

	end else if (mark == 4'h1) begin
		if (R === R_exp) begin
			okcount = okcount + 1;
			$display("DEBUG: vecno=%1d clk=%1d index=0x%04x R=0x%08x R_exp=0x%08x okcount=%1d errcount=%1d", vecno, clk, index, R, R_exp, okcount, errcount);
		end else begin
			errcount = errcount + 1;
			$display("ERROR: vecno=%1d clk=%1d index=0x%04x R=0x%08x R_exp=0x%08x okcount=%1d errcount=%1d", vecno, clk, index, R, R_exp, okcount, errcount);
		end
	end

	vecno = vecno + 1;
end

endmodule
