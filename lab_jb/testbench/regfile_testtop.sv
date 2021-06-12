module regfile_testtop;

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
 * mark     4               If mark equals 0x0, do nothing. If mark equals 0x1,
 *                          run the test vector. If mark equals 0x2, set the
 *                          inputs, but don't check the outputs. If mark
 *                          equals 0x4, $finish().
 *
 * index    16              Used when printing output to make it easier for
 *                          a human reader to identify the relevant test
 *                          vector.
 *
 * we       4               LSB used as write-enable this cycle, higher order
 *                          3 bits are ignored.
 *
 * addr1    8               Least significant 5 bits used as readaddr1 this
 *                          cycle, higher order 3 bits are ignored.
 *
 * addr2    8               Least significant 5 bits used as readaddr2 this
 *                          cycle, higher order 3 bits are ignored.
 *
 * addrw    8               Least significant 5 bits used as writeaddr this
 *                          cycle, higher order 3 bits are ignored.
 *
 * data1    32              Expected value of readdata1 this cycle.
 *
 *
 * data2    32              Expected value of readdata2 this cycle.
 *
 * dataw    32              Value of readdataw this cycle.
 *
 * Thus, each vector has a total size of 144 bits, or 36 hexadecimal
 * characters.
 *
 * The last line of output from this testbench will indicate the number of
 * test vectors that passed, and the number that encountered errors.
 */


logic         clk, we, err;
logic [  4:0] readaddr1, readaddr2, writeaddr;
logic [ 31:0] writedata, readdata1, readdata2, readdata1_exp, readdata2_exp;
logic [ 15:0] index;
logic [  3:0] mark;
logic [143:0] vector;
logic [ 31:0] vecno, errcount, okcount;
logic [143:0] vectors[10000:0];

regfile32x32 dut(
	.clk(clk),
	.we(we),
	.readaddr1(readaddr1),
	.readaddr2(readaddr2),
	.writeaddr(writeaddr),
	.writedata(writedata),
	.readdata1(readdata1),
	.readdata2(readdata2)
);

initial begin
	clk           <= 0;
	we            <= 0;
	readaddr1     <= 0;
	readaddr2     <= 0;
	writeaddr     <= 0;
	writedata     <= 0;
	readdata1     <= 0;
	readdata2     <= 0;
	readdata1_exp <= 0;
	readdata2_exp <= 0;
	index         <= 0;
	mark          <= 0;
	vector        <= 0;
	vecno         <= 0;
	errcount      <= 0;
	okcount       <= 0;

	$readmemh("testbench/regfile_vectors.txt", vectors);
end

always begin
	clk = 1'b1; #5; clk = 1'b0 ; #5;
end

always @(posedge clk) begin
	vector = vectors[vecno];
	mark   = vector[143:140];

	if (mark != 4'h0) begin
		writedata     = vector[ 31:0  ];
		readdata2_exp = vector[ 63:32 ];
		readdata1_exp = vector[ 95:64 ];
		writeaddr     = vector[100:96 ];  // 103:96
		readaddr2     = vector[108:104]; // 111:104
		readaddr1     = vector[116:112]; // 119:112
		we            = vector[120:120]; // 123:120
		index         = vector[139:124];

		$display("DEBUG: vecno=%1d clk=%1d writedata=0x%08x readdata1_exp=0x%08x readdata2_exp=0x%08x writeaddr=0x%02x readaddr1=0x%02x readaddr2=0x%02x we=%1d index=0x%04x mark=0x%01x", vecno, clk, writedata, readdata1_exp, readdata2_exp, writeaddr, readaddr2, readaddr1, we, index, mark);
	end else begin
		writedata     = 0;
		readdata2_exp = 0;
		readdata1_exp = 0;
		writeaddr     = 0;
		readaddr2     = 0;
		readaddr1     = 0;
		we            = 0;
		index         = 0;
	end
end

always @(negedge clk) begin
	if (mark != 4'h4) begin
		$display("DEBUG: vecno=%1d clk=%1d index=0x%04x readdata1=0x%08x readdata2=0x%08x", vecno, clk, index, readdata1, readdata2);
	end

	if (mark == 4'h4) begin
		$display("DEBUG: errcount=%1d okcount=%1d", errcount, okcount);
		$finish();

	end else if (mark ==4'h1) begin
		err = 0;

		if (readdata1_exp !== readdata1) begin
			err = 1;
			$display("ERROR: vecno=%1d clk=%1d index=0x%04x readdata1_exp=0x%08x readdata1=0x%08x errcount=%1d okcount=%1d", vecno, clk, index, readdata1_exp, readdata1, errcount, okcount);
		end

		if (readdata2_exp !== readdata2) begin
			err = 1;
			$display("ERROR: vecno=%1d clk=%1d index=0x%04x readdata2_exp=0x%08x readdata2=0x%08x errcount=%1d okcount=%1d", vecno, clk, index, readdata2_exp, readdata2, errcount, okcount);
		end

		if ((readdata2_exp === readdata2) && (readdata1_exp == readdata1)) begin
			okcount = okcount + 1;
		end

		if (err != 0 ) begin
			errcount = errcount + 1;
		end

	end
	
	vecno = vecno + 1;
end

endmodule
