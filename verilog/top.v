module top(
    input clk,
    input rst,

    input [1:0] mode_switch,
    output [1:0] rail,

    input [3:0] row1,
    output [2:0] col1,
    output speaker1,

    input [3:0] row2,
    output [2:0] col2,
    output speaker2,

    input wire uart_rx,
    output wire uart_tx,

    output notes_left,
    output notes_right,

    output [6:0] seg,
    output [7:0] an,

    output red, green, blue,
    output red_r, green_r, blue_r,
    
    output reg [1:0] send_note,

    output counter
);

    //assign song = mode_switch[0];

    wire [3:0] note1, note2;
    wire [7:0] score1, score2;
    wire [7:0] uart_data_rx;
    wire uart_ready_rx;

    reg left_hand_add_one = 1'b0;
    reg right_hand_add_one = 1'b0;
    reg endgame = 0;
    reg right_win = 0;
    // === Music System ===
    music_dual_system music_dual_system_inst (
        .sys_clk(clk), .sys_rst_n(rst), .mode_switch(mode_switch),
        .row1(row1), .col1(col1), .speaker1(speaker1),
        .row2(row2), .col2(col2), .speaker2(speaker2),
        .note1(note1), .note2(note2)
    );

    // === UART & Debouncer ===
    uart_with_debouncer uart_with_debouncer_inst (
        .clk(clk), .rst(rst),
        .note1(note1), .note2(note2),
        .endgame(endgame),
        .uart_rx(uart_rx), .uart_tx(uart_tx),
        .uart_data_rx(uart_data_rx),
        .uart_ready_rx(uart_ready_rx)
    );

   // reg [1:0] send_note= 2'b00; //Signal to send notes to the notes_sender module
    // === Debounce new UART char ===
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            left_hand_add_one <= 0;
            right_hand_add_one <= 0;
            send_note <= 2'b00;
        end else begin
            left_hand_add_one <= 0;
            right_hand_add_one <= 0;
            if (uart_ready_rx) begin
                if (uart_data_rx == 8'h43)      // 'C'
                    left_hand_add_one <= 1;
                else if (uart_data_rx == 8'h63)  // 'c'
                    right_hand_add_one <= 1;
                else if (uart_data_rx == 8'h52)  // 'R': require for the notes
                    send_note <= 2'b01;
                else if (uart_data_rx == 8'h72)  //''r'
                    send_note <= 2'b10;
               
            end
        end
    end

    // === Scoring System ===
    score score_adder (
        .clk(clk), .rst(rst),
        .left_hand_add_one(left_hand_add_one),
        .right_hand_add_one(right_hand_add_one),
        .score1(score1), .score2(score2)
    );

    // === Game State ===
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            endgame <= 0;
            right_win <= 0;
        end else begin
            if (score1 >= 60) begin
                endgame <= 1;
                right_win <= 0;
            end else if (score2 >= 60) begin
                endgame <= 1;
                right_win <= 1;
            end
        end
    end

    // === Score Display ===
    score_display score_display_inst (
        .clk(clk),
        .score1(score1),
        .score2(score2),
        .an(an),
        .seg(seg)
    );

    // === Light Show ===
    wire red_wire, green_wire, blue_wire;
    wire red_r_wire, green_r_wire, blue_r_wire;

    assign red = red_wire;
    assign green = green_wire;
    assign blue = blue_wire;
    assign red_r = red_r_wire;
    assign green_r = green_r_wire;
    assign blue_r = blue_r_wire;

    light_show light_left(
        .clk(clk), .endgame(endgame), .right_win(right_win),
        .red(red_wire), .green(green_wire), .blue(blue_wire)
    );

    light_show light_right(
        .clk(clk), .endgame(endgame), .right_win(right_win),
        .red(red_r_wire), .green(green_r_wire), .blue(blue_r_wire)
    );

    wire [2:0] three_bit_rail;
    // === Random Rail Generator ===
    top_LFSR rail_gen(
        .clk(clk),
        .reset_n(rst),
        .rail(three_bit_rail)
    );
    assign rail = three_bit_rail[1:0];

   music_rom_left rom_l (
        .clk(clk), 
        .rst(send_note[0]),
        .song(mode_switch[0]),
        .tx(notes_left)
    );
    
    music_rom_right rom_r (
        .clk(clk), 
        .rst(send_note[1]),
        .song(mode_switch[0]),
        .tx(notes_right)
    );
  
  slow_counter_to_uart slow_counter(
    .clk(clk),
    .rst(rst),
    .tx(counter)
  );
endmodule
