module instruction_decoding(input logic [31:0] risc_v_command, 
                            output logic [2:0] instruction_type,
                            output logic [6:0] opcode,
                            output logic [4:0] rd,
                            output logic [2:0] funct3,
                            output logic [4:0] rs1,
                            output logic [4:0] rs2,
                            output logic [6:0] funct7,
                            output logic [31:0] imm_I,
                            output logic [31:0] imm_U,
                            output logic [12:0] imm_B,
                            output logic [20:0] imm_J);
    assign opcode = risc_v_command[6:0];
    assign rd = risc_v_command[11:7];
    assign funct3 = risc_v_command[14:12];
    assign rs1 = risc_v_command[19:15];
    assign rs2 = risc_v_command[24:20];
    assign funct7 = risc_v_command[31:25];
    assign imm_I = {{20{risc_v_command[31]}}, risc_v_command[31:20]};
    assign imm_U = {risc_v_command[31:12], 12'b0};
    assign imm_B = {risc_v_command[31], risc_v_command[7], risc_v_command[30:25], risc_v_command[11:8], 1'b0};
    assign imm_J = {risc_v_command[31], risc_v_command[19:12], risc_v_command[20], risc_v_command[30:21], 1'b0};
    assign instruction_type =
        (opcode == 7'b0110011) ? 3'b001 : // R
        (opcode == 7'b0010011) ? 3'b010 : // I
        (opcode == 7'b0110111) ? 3'b011 : // U
        (opcode == 7'b1110011) ? 3'b100 : // csrrw
        (opcode == 7'b1100011) ? 3'b101 : // B
        (opcode == 7'b1101111) ? 3'b110 : // jal
        (opcode == 7'b1100111) ? 3'b111 : 3'b000; // jalr & default
endmodule