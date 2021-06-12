module ram(input logic clk,
               input logic rst,
               input logic[11:0] pc,
               output logic [31:0] instruction);
    logic [31:0] instructions [4095:0];

    initial begin
        $readmemh("/media/sf_CSCE611/lab_riu/program.rom", instructions);
    end

    always begin
		if (rst) instruction = 32'b0;
	    else instruction = instructions[pc];
	end
endmodule