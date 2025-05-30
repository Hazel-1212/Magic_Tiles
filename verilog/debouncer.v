module debouncer (
    input wire clk,
    input wire rst,
    input wire [3:0] noisy,       // Noisy input from keypad
    output reg [3:0] clean        // Clean, debounced value
);

reg [15:0] count [3:0];
reg [3:0] stable;

parameter THRESHOLD = 16'd50000; // Adjust as needed for your clock

integer i;
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        clean <= 4'b1111;
        stable <= 4'b1111;
        for (i = 0; i < 4; i = i + 1) begin
            count[i] <= 0;
        end
    end else begin
        for (i = 0; i < 4; i = i + 1) begin
            if (noisy[i] != stable[i]) begin
                count[i] <= count[i] + 1;
                if (count[i] >= THRESHOLD) begin
                    stable[i] <= noisy[i];
                    clean[i] <= noisy[i];
                    count[i] <= 0;
                end
            end else begin
                count[i] <= 0;
            end
        end
    end
end

endmodule

