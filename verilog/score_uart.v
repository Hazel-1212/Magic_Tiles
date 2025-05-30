module score(
    input clk,                     
    input rst,                     
    input left_hand_add_one,      
    input right_hand_add_one,     
    output reg [7:0] score1,      
    output reg [7:0] score2       
);

reg prev_left = 0;
reg prev_right = 0;

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        score1 <= 8'd0;
        score2 <= 8'd0;
        prev_left <= 0;
        prev_right <= 0;
    end else begin
        // Rising edge detection for left hand
        if (left_hand_add_one && !prev_left) begin
            score1 <= score1 + 1;
        end
        prev_left <= left_hand_add_one;

        // Rising edge detection for right hand
        if (right_hand_add_one && !prev_right) begin
            score2 <= score2 + 1;
        end
        prev_right <= right_hand_add_one;
    end
end

endmodule

