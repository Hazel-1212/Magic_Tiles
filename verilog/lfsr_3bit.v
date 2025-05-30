module lfsr_3bit (
    input wire clk,
    input wire reset,
    output reg [2:0] random
);

    reg [3:0] lfsr_reg;

    wire feedback = lfsr_reg[3] ^ lfsr_reg[2];  // XOR tap

    always @(posedge clk or negedge reset) begin
        if (~reset)
            lfsr_reg <= 4'b1011;  // initial seed (ä¸èƒ½?‚º0)
        else
            lfsr_reg <= {lfsr_reg[2:0], feedback};
    end

    // use lower 3 bits as random output (range: 1??7)
    always @(*) begin
        if (lfsr_reg[2:0] == 3'b000)
            random = 3'b001;  // avoid 0
        else
            random = lfsr_reg[2:0];
    end

endmodule
