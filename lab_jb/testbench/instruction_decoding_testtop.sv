module instruction_decoding_testtop;
    logic clk;
    logic [3:0] mark;
    logic [15:0] index, vecno, err_count;
    // Outputs
    logic [2:0] instruction_type, instruction_type_exp;
    logic [6:0] opcode, opcode_exp;
    logic [4:0] rd, rd_exp;
    logic [2:0] funct3, funct3_exp;
    logic [4:0] rs1, rs1_exp;
    logic [4:0] rs2, rs2_exp;
    logic [6:0] funct7, funct7_exp;
    logic [31:0] imm_I, imm_I_exp;
    logic [31:0] imm_U, imm_U_exp;
    logic [12:0] imm_B, imm_B_exp;
    logic [20:0] imm_J, imm_J_exp;
    
    // Input
    logic [31:0] risc_v_command;

    // Vectors
    logic [203:0] vector;
    logic [203:0] vectors[10000:0];

    instruction_decoding dut(.risc_v_command(risc_v_command),
                             .instruction_type(instruction_type),
                             .opcode(opcode),
                             .rd(rd),
                             .funct3(funct3),
                             .rs1(rs1),
                             .rs2(rs2),
                             .funct7(funct7),
                             .imm_I(imm_I),
                             .imm_U(imm_U),
                             .imm_B(imm_B),
                             .imm_J(imm_J));

    initial begin
        vecno = 0;
        err_count = 0;
        clk = 0;
        $display("START: Testing Instruction Decoder");
        $readmemh("testbench/instruction_decoding_vectors.txt", vectors);
    end

    always begin
        clk = 1'b1;
        #5;
        clk = 1'b0;
        #5;
    end

    always @(posedge clk) begin
        vector = vectors[vecno];
        mark = vector[203:200];
        
        if (mark != 4'h0) begin
            imm_J_exp = vector[20:0];
            imm_B_exp = vector[36:24];
            imm_U_exp = vector[71:40];
            imm_I_exp = vector[103:72];
            funct7_exp = vector[110:104];
            rs2_exp = vector[116:112];
            rs1_exp = vector[124:120];
            funct3_exp = vector[130:128];
            rd_exp = vector[136:132];
            opcode_exp = vector[146:140];
            instruction_type_exp = vector[150:148];
            risc_v_command = vector[183:152];
            index = vector[188:184];
        end
    end

    always @(negedge clk) begin
        if (mark == 4'h4) begin
            $display("FINAL: Errors: %1d", err_count);
            $finish();
        end else if (mark == 4'h1) begin
            if (instruction_type_exp != instruction_type
                    || opcode_exp != opcode
                    || rd_exp != rd
                    || funct3_exp != funct3
                    || rs1_exp != rs1
                    || rs2_exp != rs2
                    || funct7_exp != funct7
                    || imm_I_exp != imm_I
                    || imm_U_exp != imm_U
                    || imm_B_exp != imm_B
                    || imm_J_exp != imm_J) begin
                err_count = err_count + 1;
                $display("ERROR: #%1d index=0x%04X command=0x%08X", vecno, index, risc_v_command);
                $display("DEBUG: SHOW VARS");
                $display("       instruction_type_exp = 0x%01x : instruction_type = 0x%01x", instruction_type_exp, instruction_type);
                $display("       opcode_exp = 0x%02x : opcode = 0x%02x", opcode_exp, opcode);
                $display("       rd_exp = 0x%02x : rd = 0x%02x", rd_exp, rd);
                $display("       funct3_exp = 0x%01x : funct3 = 0x%01x", funct3_exp, funct3);
                $display("       rs1_exp = 0x%02x : rs1 = 0x%02x", rs1_exp, rs1);
                $display("       rs2_exp = 0x%02x : rs2 = 0x%02x", rs2_exp, rs2);
                $display("       funct7_exp = 0x%02x : funct7 = 0x%02x", funct7_exp, funct7);
                $display("       imm_I_exp = 0x%08x : imm_I = 0x%08x", imm_I_exp, imm_I);
                $display("       imm_U_exp = 0x%08x : imm_U = 0x%08x", imm_U_exp, imm_U);
                $display("       imm_J_exp = 0x%05x : imm_J = 0x%05x", imm_J_exp, imm_J);
                $display("       imm_B_exp = 0x%04x : imm_B = 0x%04x", imm_B_exp, imm_B);
            end
        end
        vecno = vecno + 1;
    end
endmodule