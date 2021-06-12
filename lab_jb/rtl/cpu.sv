module cpu(input logic clk,
           input logic rst,
           input logic [17:0] sw_F,
           output logic [31:0] HEX_out,
           output logic out_we);

    // Logic
    // Pipeline
    logic [11:0] pc_F;
    logic [31:0] command_F;
    logic stall_F;

    logic [11:0] pc_EX;
    logic [31:0] command_EX;
    logic [17:0] sw_EX;
    logic [31:0] source1_EX, source2_EX;
    logic [4:0] dest_EX;
    logic reg_we_EX;
    logic hex_we_EX;
    logic [31:0] result_EX;
    logic stall_EX;
    logic cond_EX;
    logic zero_EX;
    logic branch_EX;
    logic [11:0] branch_addr_EX;
    logic jump_EX;
    logic [11:0] jump_addr_EX;

    logic [11:0] pc_WB;
    logic [31:0] result_WB;
    logic [4:0] dest_WB;
    logic reg_we_WB;
    logic hex_we_WB;
    logic stall_WB;

    // Immediate values
    logic [31:0] imm_U;
    logic [20:0] imm_J;
    logic [12:0] imm_B;
    logic [31:0] alu_result;
    logic [31:0] source_data1;
    logic [31:0] source_data2;

    // Ignored Logic
    logic [6:0] opcode_ignore;

    // Wires
    wire [2:0] instruction_type_wire;
    wire [3:0] op_wire;
    wire [2:0] funct3_wire;
    wire [6:0] funct7_wire;
    wire [31:0] imm_I_wire;
    wire [4:0] source_addr1_wire, source_addr2_wire;

    // Internal Modules
    ram program_inst(
        .clk(clk),
        .rst(rst),
        .pc(pc_F),
        .instruction(command_F));
    instruction_decoding decoder_inst(
        .risc_v_command(command_EX),
        .instruction_type(instruction_type_wire),
        .opcode(opcode_ignore),
        .rd(dest_EX),
        .funct3(funct3_wire),
        .rs1(source_addr1_wire),
        .rs2(source_addr2_wire),
        .funct7(funct7_wire),
        .imm_I(imm_I_wire),
        .imm_U(imm_U),
        .imm_B(imm_B),
        .imm_J(imm_J));
    control_unit cu_inst(
        .instruction_type(instruction_type_wire),
        .funct3(funct3_wire),
        .funct7(funct7_wire),
        .imm_I(imm_I_wire),
        .stall_EX(stall_EX),
        .reg_we(reg_we_EX),
        .hex_we(hex_we_EX),
        .zero(cond_EX),
        .op(op_wire));
    alu alu_inst(
        .A(source1_EX),
        .B(source2_EX),
        .op(op_wire),
        .R(alu_result),
        .zero(zero_EX));
    regfile32x32 reg_inst(
        .we(reg_we_WB),
        .clk(clk),
        .readaddr1(source_addr1_wire),
        .readaddr2(source_addr2_wire),
        .writeaddr(dest_WB),
        .readdata1(source_data1),
        .readdata2(source_data2),
        .writedata(result_WB));
        
    always_comb begin // Find Sources and Result
        branch_EX = 1'b0;
        jump_EX = 1'b0;
        if (stall_EX) begin
            stall_F = 1'b0;
        end else if (instruction_type_wire === 3'b001) begin // R
            source1_EX = source_data1;
            source2_EX = source_data2;
            result_EX = alu_result;
        end else if (instruction_type_wire === 3'b010) begin // I
            source1_EX = source_data1;
            source2_EX = imm_I_wire;
            result_EX = alu_result;
        end else if (instruction_type_wire === 3'b011) begin // U
            result_EX = imm_U;
        end else if (instruction_type_wire === 3'b100) begin // csrrw
            if (imm_I_wire[11:0] == 12'hf00) begin
                result_EX = {14'b0, sw_EX};
            end else if(imm_I_wire[11:0] == 12'hf02) begin
                result_EX = source_data1;
            end
        end else if (instruction_type_wire == 3'b101) begin // B
            source1_EX = source_data1;
            source2_EX = source_data2;
            if (cond_EX == zero_EX) begin
                branch_EX = 1'b1;
                stall_F = 1'b1;
                branch_addr_EX = pc_EX + {imm_B[12], imm_B[12:2]};
            end else begin
                stall_F = 1'b0;
                branch_EX = 1'b0;
            end
        end else if (instruction_type_wire == 3'b110) begin // jal
            result_EX = {20'b0, pc_F[11:0]};
            jump_EX = 1'b1;
            stall_F = 1'b1;
            jump_addr_EX = pc_EX + imm_J[13:2];
        end else if (instruction_type_wire == 3'b111) begin // jalr
            stall_F = 1'b1;
            jump_EX = 1'b1;
            jump_addr_EX = source_data1[13:2] + {{2{imm_I_wire[11]}}, imm_I_wire[11:2]};
            result_EX = {20'b0, jump_addr_EX[11:0]};
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1) begin // Set all interior signals to 0
            pc_F = 12'b0;
            command_F = 32'b0;
            pc_EX = 12'b0;
            command_EX = 32'b0;
            sw_EX = 18'b0;
            dest_EX = 5'b0;
            reg_we_EX = 1'b0;
            hex_we_EX = 1'b0;
            stall_EX = 1'b0;
            cond_EX = 1'b0;
            zero_EX = 1'b0;
            pc_WB = 12'b0;
            result_WB = 32'b0;
            dest_WB = 5'b0;
            reg_we_WB = 1'b0;
            hex_we_WB = 1'b0;
            stall_WB = 1'b0;
            imm_U = 32'b0;
            imm_J = 21'b0;
            imm_B = 13'b0;
            alu_result = 32'b0;
            source_data1 = 32'b0;
            source_data2 = 32'b0;
            opcode_ignore = 7'b0;
       end else begin
            // Write Result to reg
            // The result gets written on the posedge of the clock
            // So nothing needs to happen here.
            
            // Find Result of command_EX
            // Since the ALU is async nothing needs to happen here
            // computation-wise. So all I do is instantiate all the vars
            // needed to write next clock cycle
            pc_WB = pc_EX;
            dest_WB = dest_EX;
            reg_we_WB = reg_we_EX;
            hex_we_WB = hex_we_EX;
            result_WB = result_EX;
            stall_WB = stall_EX;

            // Save new command
            command_EX = command_F;
            sw_EX = sw_F;
            stall_EX = stall_F;
            pc_EX = pc_F;

            //stall_F = 1'b0;

            // Iterate PC
            if (branch_EX) begin
                pc_F = branch_addr_EX;
            end else if (jump_EX) begin
                pc_F = jump_addr_EX;
            end else begin
                pc_F = pc_EX + 12'b1;
            end

            if (hex_we_WB) begin
                assign HEX_out = result_WB;
                assign out_we = 1'b1;
            end else begin
                assign HEX_out = 32'b0;
                assign out_we = 1'b0;
            end
       end
    end
endmodule