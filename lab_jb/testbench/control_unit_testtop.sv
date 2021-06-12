module control_unit_testtop;
    logic clk;
    logic [3:0] mark;
    logic [15:0] index, vecno, err_count;
    // Inputs
    logic [2:0] instruction_type;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [31:0] imm_I;
    logic stall_EX;
    // Outputs
    logic reg_we, reg_we_exp;
    logic hex_we, hex_we_exp;
    logic zero, zero_exp;
    logic [3:0] op, op_exp;
    // Vectors
    logic [87:0] vector;
    logic [87:0] vectors[10000:0];

    control_unit dut(
        .instruction_type(instruction_type),
        .funct3(funct3),
        .funct7(funct7),
        .imm_I(imm_I),
        .stall_EX(stall_EX),
        .reg_we(reg_we),
        .hex_we(hex_we),
        .zero(zero),
        .op(op));

    initial begin
        vecno = 0;
        err_count = 0;
        clk = 0;
        $display("START: Testing Control Unit");
        $readmemh("testbench/control_unit_vectors.txt", vectors);
    end

    always begin
        clk = 1'b1;
        #5;
        clk = 1'b0;
        #5;
    end

    always @(posedge clk) begin
        vector = vectors[vecno];
        mark = vector[87:84];

        if (mark != 4'h0) begin
            op_exp = vector[3:0];
            zero_exp = vector[4];
            hex_we_exp = vector[8];
            reg_we_exp = vector[12];
            stall_EX = vector[16];
            imm_I = vector[51:20];
            funct7 = vector[58:52];
            funct3 = vector[62:60];
            instruction_type = vector[66:64];
            index = vector[83:68];
        end
    end

    always @(negedge clk) begin
        if (mark == 4'h4) begin
            $display("FINAL: Errors: %1d", err_count);
            $finish();
        end else if (mark == 4'h1) begin
            if (reg_we_exp !== reg_we
                    || hex_we_exp !== hex_we
                    || zero_exp !== zero
                    || op_exp !== op) begin
                err_count = err_count + 1;
                $display("ERROR: #%1d index=0x%04X", vecno, index);
                $display("DEBUG: SHOW VARS");
                $display("       type = 0b%03b", instruction_type);
                $display("       op_exp = 0x%01x : op = 0x%01x", op_exp, op);
                $display("       zero_exp = 0x%01x : zero = 0x%01x", zero_exp, zero);
                $display("       reg_we_exp = 0b%1b : reg_we = 0b%1b", reg_we_exp, reg_we);
                $display("       hex_we_exp = 0b%1b : hex_we = 0b%1b", hex_we_exp, hex_we);
            end
        end
        vecno = vecno + 1;
    end
endmodule