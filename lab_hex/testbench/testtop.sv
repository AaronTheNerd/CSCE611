module testtop;
    logic clk;
    logic [3:0] key;
    logic [8:0] ledg;
    logic [17:0] ledr;
    logic [6:0] hex0, hex1, hex2, hex3, hex4, hex5, hex6, hex7;
    logic [17:0] sw;

    assign sw = 18'b0;

    simtop dut (.CLOCK_50(clk),
                .CLOCK2_50(clk),
                .CLOCK3_50(clk),
                .LEDG(ledg),
                .LEDR(ledr),
                .KEY(key),
                .HEX0(hex0),
                .HEX1(hex1),
                .HEX2(hex2),
                .HEX3(hex3),
                .HEX4(hex4),
                .HEX5(hex5),
                .HEX6(hex6),
                .HEX7(hex7),
                .SW(sw));

    always begin
        clk=1'b1;
        #5;
        clk=1'b0;
        #5;
    end

    initial begin
        key[3] = 1'b1;
        #7;
        key[3] = 1'b0;
    end

endmodule
