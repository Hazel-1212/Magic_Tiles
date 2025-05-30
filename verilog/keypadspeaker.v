module music_dual_system(
    input sys_clk,
    input sys_rst_n,
    input [1:0] mode_switch,

    // keyboard1
    input [3:0] row1,
    output reg [2:0] col1,
    output reg speaker1,

    // keyboard2
    input [3:0] row2,
    output reg [2:0] col2,
    output reg speaker2,
    
    output reg [3:0] note1,
    output reg [3:0] note2
);

// Internal states
reg [19:0] scan_counter = 0;
reg [1:0] col_sel = 0;

reg [24:0] sound_remain_1 = 0;
reg [24:0] sound_remain_2 = 0; // Make sound remain after pressed

reg [19:0] debounce_cnt1 = 0, debounce_cnt2 = 0;
reg key_pressed1 = 0, key_pressed2 = 0;
reg valid_note1 = 0, valid_note2 = 0;

reg [31:0] tone_period1 = 0, tone_period2 = 0;
reg [31:0] pwm_counter1 = 0, pwm_counter2 = 0;

localparam ONE_SEC_COUNT = 25'd50_000_000; // 0.5 second

// === Keypad Scan Timing ===
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        scan_counter <= 0;
        sound_remain_1 <= 0;
        sound_remain_2 <= 0;
        col_sel <= 0;
    end else begin

        //keypad 1
        if(row1 != 4'b0000)begin // keypad_1 is pressed
            sound_remain_1 <=0;
        end
        else if(row1 == 4'b0000)begin // keypad_1 not pressed
            sound_remain_1 <= sound_remain_1 + 1 ;
        end

        //keypad 2
        if(row2 != 4'b0000)begin
            sound_remain_2 <=0;
        end
        else if(row2 == 4'b0000)begin
            sound_remain_2 <= sound_remain_2 + 1 ;
        end
        
        // col to scan changes
        if (scan_counter >= 20'd99999) begin
            scan_counter <= 0;
            col_sel <= (col_sel == 2) ? 0 : col_sel + 1;
        end else begin
            scan_counter <= scan_counter + 1;
        end
    end
end

// === Column Select ===
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        col1 <= 3'b000;
        col2 <= 3'b000;
    end else begin
        case (col_sel)
            2'd0: begin col1 <= 3'b100; col2 <= 3'b100; end
            2'd1: begin col1 <= 3'b010; col2 <= 3'b010; end
            2'd2: begin col1 <= 3'b001; col2 <= 3'b001; end
            default: begin col1 <= 3'b000; col2 <= 3'b000; end
        endcase
    end
end

reg [3:0] prev_note1 = 4'b1111;
reg [3:0] prev_note2 = 4'b1111;
// === Keyboard 1 Logic ===
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        note1 <= 4'd15;
        debounce_cnt1 <= 0;
        key_pressed1 <= 0;
        valid_note1 <= 0;
    end else begin
        if (row1 != 4'b0000) begin
            debounce_cnt1 <= debounce_cnt1 + 1;
            if (debounce_cnt1 > 20'd2000 && !key_pressed1) begin
                key_pressed1 <= 1;
                valid_note1 <= 1;
                case ({row1, col_sel})
                    6'b1000_00: note1 <= 4'd12;
                    6'b1000_01: note1 <= 4'd11;
                    6'b1000_10: note1 <= 4'd10;
                    6'b0100_00: note1 <= 4'd9;
                    6'b0100_01: note1 <= 4'd8;
                    6'b0100_10: note1 <= 4'd7;
                    6'b0010_00: note1 <= 4'd6;
                    6'b0010_01: note1 <= 4'd5;
                    6'b0010_10: note1 <= 4'd4;
                    6'b0001_00: note1 <= 4'd3;
                    6'b0001_01: note1 <= 4'd2;
                    6'b0001_10: note1 <= 4'd1;
                    default: note1 <= 4'd15;
                endcase
            end
        end 
        else begin
            debounce_cnt1 <= 0;
            key_pressed1 <= 0;
            valid_note1 <= 0;
            if (sound_remain_1 ==  ONE_SEC_COUNT )begin
                note1 <= 4'd15; // <== Reset note when no key pressed
            end
        end

        // Debounce logic
        prev_note1 <= note1;
    end
end

// === Keyboard 2 Logic ===
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        note2 <= 4'd 0;
        debounce_cnt2 <= 0;
        key_pressed2 <= 0;
        valid_note2 <= 0;
    end else begin
        if (row2 != 4'b0000) begin
            debounce_cnt2 <= debounce_cnt2 + 1;
            if (debounce_cnt2 > 20'd2000 && !key_pressed2) begin
                key_pressed2 <= 1;
                valid_note2 <= 1;
                case ({row2, col_sel})
                    6'b1000_00: note2 <= 4'd11;
                    6'b1000_01: note2 <= 4'd12;
                    6'b1000_10: note2 <= 4'd10;
                    6'b0100_00: note2 <= 4'd8;
                    6'b0100_01: note2 <= 4'd9;
                    6'b0100_10: note2 <= 4'd7;
                    6'b0010_00: note2 <= 4'd5;
                    6'b0010_01: note2 <= 4'd6;
                    6'b0010_10: note2 <= 4'd4;
                    6'b0001_00: note2 <= 4'd2;
                    6'b0001_01: note2 <= 4'd3;
                    6'b0001_10: note2 <= 4'd1;
                    default: note2 <= 4'd15;
                endcase
            end
        end else begin
            debounce_cnt2 <= 0;
            key_pressed2 <= 0;
            valid_note2 <= 0;
            if (sound_remain_2 ==  ONE_SEC_COUNT )begin
                note2 <= 4'd15; // <== Reset note when no key pressed
            end
        end
        // Debounce logic
        prev_note2 <= note2;
    end
end

// === Tone Period Assignment for speaker1 ===
always @(*) begin
    case (mode_switch)
        2'b00: case (note1)
            4'd1: tone_period1 = 142975;
            4'd2: tone_period1 = 127551;
            4'd3: tone_period1 = 113636;
            4'd4: tone_period1 = 101192;
            4'd5: tone_period1 = 95556;
            4'd6: tone_period1 = 85122;
            4'd7: tone_period1 = 71563;
            4'd8: tone_period1 = 67515;
            4'd9: tone_period1 = 63776;
            4'd10: tone_period1 = 50619;
            4'd11: tone_period1 = 47778;
            4'd12: tone_period1 = 37927;
            default: tone_period1 = 0;
        endcase
        2'b01: case (note1)
            4'd1: tone_period1 = 142975;
            4'd2: tone_period1 = 113636;
            4'd3: tone_period1 = 95556;
            4'd4: tone_period1 = 75850;
            4'd5: tone_period1 = 63776;
            4'd6: tone_period1 = 56818;
            4'd7: tone_period1 = 47778;
            4'd8: tone_period1 = 37927;
            default: tone_period1 = 0;
        endcase
        2'b10: case (note1)
            4'd1: tone_period1 = 286255;
            4'd2: tone_period1 = 255102;
            4'd3: tone_period1 = 227273;
            4'd4: tone_period1 = 214617;
            4'd5: tone_period1 = 191076;
            default: tone_period1 = 0;
        endcase
        default: tone_period1 = 0;
    endcase
end

// === Tone Period Assignment for speaker2 ===
always @(*) begin
    case (mode_switch)
        2'b00: case (note2)
            4'd1: tone_period2 = 63766;
            4'd2: tone_period2 = 56818;
            4'd3: tone_period2 = 50619;
            4'd4: tone_period2 = 47778;
            4'd5: tone_period2 = 42551;
            4'd6: tone_period2 = 37927;
            4'd7: tone_period2 = 35794;
            4'd8: tone_period2 = 31888;
            4'd9: tone_period2 = 28409;
            default: tone_period2 = 0;
        endcase
        2'b01: case (note2)
            4'd1: tone_period2 = 75850;
            4'd2: tone_period2 = 63776;
            4'd3: tone_period2 = 56818;
            4'd4: tone_period2 = 50619;
            4'd5: tone_period2 = 47778;
            4'd6: tone_period2 = 42551;
            4'd7: tone_period2 = 37927;
            default: tone_period2 = 0;
        endcase
        2'b10: case (note2)
            4'd1: tone_period2 = 95556;
            4'd2: tone_period2 = 85122;
            4'd3: tone_period2 = 75850;
            4'd4: tone_period2 = 71563;
            4'd5: tone_period2 = 63776;
            4'd6: tone_period2 = 56818;
            4'd7: tone_period2 = 53603;
            4'd8: tone_period2 = 47778;
            4'd9: tone_period2 = 42551;
            default: tone_period2 = 0;
        endcase
        default: tone_period2 = 0;
    endcase
end

// === Speaker 1 PWM Output ===
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        pwm_counter1 <= 0;
        speaker1 <= 0;
    end else if (tone_period1 != 0) begin
        if (pwm_counter1 >= tone_period1) begin
            pwm_counter1 <= 0;
            speaker1 <= ~speaker1;
        end else begin
            pwm_counter1 <= pwm_counter1 + 1;
        end
    end else begin
        pwm_counter1 <= 0;
        speaker1 <= 0;
    end
end

// === Speaker 2 PWM Output ===
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        pwm_counter2 <= 0;
        speaker2 <= 0;
    end else if (tone_period2 != 0) begin
        if (pwm_counter2 >= tone_period2) begin
            pwm_counter2 <= 0;
            speaker2 <= ~speaker2;
        end else begin
            pwm_counter2 <= pwm_counter2 + 1;
        end
    end else begin
        pwm_counter2 <= 0;
        speaker2 <= 0;
    end
end

endmodule