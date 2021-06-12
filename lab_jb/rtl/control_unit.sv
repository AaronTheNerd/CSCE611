module control_unit(input logic [2:0] instruction_type,
                    input logic [2:0] funct3,
                    input logic [6:0] funct7,
                    input logic [31:0] imm_I,
                    input logic stall_EX,
                    output logic reg_we,
                    output logic hex_we,
                    output logic zero,
                    output logic [3:0] op);
    always_comb begin
        hex_we = 1'b0;
        reg_we = 1'b1;
        zero = 1'bX;
        if (stall_EX) begin
            op = 4'bX;
            reg_we = 1'b0;
        end else if (instruction_type == 3'b001) begin // R
            case ({funct3, funct7})
                10'b0000000000: op = 4'b0011; // add
                10'b0000100000: op = 4'b0100; // sub
                10'b1110000000: op = 4'b0000; // and
                10'b1100000000: op = 4'b0001; // or
                10'b1000000000: op = 4'b0010; // xor
                10'b0010000000: op = 4'b1000; // sll
                10'b1010100000: op = 4'b1010; // sra
                10'b1010000000: op = 4'b1001; // srl
                10'b0100000000: op = 4'b1100; // slt
                10'b0110000000: op = 4'b1101; // sltu
                10'b0000000001: op = 4'b0101; // mul
                10'b0010000001: op = 4'b0110; // mulh
                10'b0110000001: op = 4'b0111; // mulhu
                default: op = 4'bX;
            endcase
        end else if (instruction_type == 3'b010) begin // I
            case (funct3)
                3'b000: op = 4'b0011; // addi
                3'b111: op = 4'b0000; // andi
                3'b110: op = 4'b0001; // ori
                3'b100: op = 4'b0010; // xori
                3'b001: op = 4'b1000; // slli
                3'b101: op = (funct7 == 7'b0) ? 4'b1001 : 4'b1010; // srai & srli
                default: op = 4'bX;
            endcase
        end else if (instruction_type == 3'b101) begin // B
            reg_we = 1'b0;
            case (funct3)
                3'b000: begin // beq
                    op = 4'b0100;
                    zero = 1'b1;
                end 3'b101: begin // bge
                    op = 4'b1100;
                    zero = 1'b1;
                end 3'b111: begin // bgeu
                    op = 4'b1101;
                    zero = 1'b1;
                end 3'b100: begin // blt
                    op = 4'b1100;
                    zero = 1'b0;
                end 3'b110: begin // bltu
                    op = 4'b1101;
                    zero = 1'b0;
                end 3'b001: begin // bne ? 
                    op = 4'b0100;
                    zero = 1'b0;
                end default: begin
                    op = 4'bX;
                    zero = 1'bX;
                end
            endcase
        end else begin // J, U, csrrw
            op = 4'bX;
            if (instruction_type == 3'b100 && imm_I[11:0] == 12'hf02) begin // csrrw
                hex_we = 1'b1;
                reg_we = 1'b0;
            end
        end
    end
endmodule