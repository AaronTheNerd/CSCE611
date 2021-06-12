/* RISC-V register file for CSCE611 Fall 2020
*
* Copyright 2020 Jason Bakos, Philip Conrad, Charles Daniels
*/

module regfile32x32 (
	input  logic       we,
	input  logic       clk,
	input  logic [ 4:0] readaddr1,
	input  logic [ 4:0] readaddr2,
	input  logic [ 4:0] writeaddr,
	output logic [31:0] readdata1,
	output logic [31:0] readdata2,
	input  logic [31:0] writedata);

	logic [31:0] mem[31:0];

	assign readdata1 = readaddr1 == 5'b0 ? 32'b0 :
			readaddr1 == writeaddr && we ? writedata : mem[readaddr1];

	assign readdata2 = readaddr2 == 5'b0 ? 32'b0 :
			readaddr2 == writeaddr && we ? writedata : mem[readaddr2];

	always_ff @(posedge clk) begin
		if (we) mem[writeaddr] <= writedata;
	end

endmodule

