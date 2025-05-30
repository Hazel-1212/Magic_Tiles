module score_display ( 
    input clk,
    input [7:0] score1,
    input [7:0] score2,
    output reg [7:0] an,
    output reg [6:0] seg
);

    reg [10:0] refresh_counter = 0;  // Reduced to fit visible refresh rate
    reg [2:0] digit_select = 0;      // Selects digits 0 to 7
    reg [3:0] digit;                 // Current digit value for display

    // Display refresh logic
    always @(posedge clk) begin
        refresh_counter <= refresh_counter + 1;
        if (refresh_counter == 0) begin  // Clock divided by ~1M (about 100Hz if clk = 100MHz)
            digit_select <= digit_select + 1;
        end
    end
    

    // Assign digit value based on current digit_select
    always @(*) begin
        case (digit_select)
            3'd0: digit = score2 % 10;
            3'd1: digit = score2 / 10;
            3'd2: digit = 4'd15;  // blank
            3'd3: digit = 4'd15;
            3'd4: digit = score1 % 10;
            3'd5: digit = score1 / 10;
            3'd6: digit = 4'd15;
            3'd7: digit = 4'd15;
            default: digit = 4'd15;
        endcase
    end

    // Anode control (active low)
    always @(*) begin
        an = ~(8'b00000001 << digit_select);  // Only one digit active at a time
    end

    // Segment decoder
    always @(*) begin
        case (digit)
            4'd0: seg = 7'b1000000;
            4'd1: seg = 7'b1111001;
            4'd2: seg = 7'b0100100;
            4'd3: seg = 7'b0110000;
            4'd4: seg = 7'b0011001;
            4'd5: seg = 7'b0010010;
            4'd6: seg = 7'b0000010;
            4'd7: seg = 7'b1111000;
            4'd8: seg = 7'b0000000;
            4'd9: seg = 7'b0010000;
            default: seg = 7'b1111111; // blank
        endcase
    end

endmodule

