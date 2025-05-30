module key_pulse_gen (
    input wire clk,
    input wire rst,
    input wire [3:0] clean_in,
    output reg pulse
);

reg [3:0] prev;

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        prev <= 4'b1111;
        pulse <= 0;
    end else begin
        if (clean_in != prev && clean_in != 4'b1111) begin
            pulse <= 1;
        end else begin
            pulse <= 0;
        end
        prev <= clean_in;
    end
end

endmodule
