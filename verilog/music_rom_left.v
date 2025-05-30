module music_rom_left (
    input wire clk,
    input wire rst,
    input song,
    output wire tx
);

reg [6:0] rom [0:58];
reg [5:0] idx;
reg send;
reg [7:0] tx_data;
wire tx_ready;
reg [1:0] state;

music_uart_left uart (
    .clk(clk),
    .rst(rst),
    .tx_start(send),
    .tx_data(tx_data),
    .tx(tx),
    .tx_ready(tx_ready)
);

function [7:0] tile_to_ascii(input [3:0] tile_id);
    tile_to_ascii = "A" + tile_id;  // 'A' + 0??15
endfunction

function [7:0] dur_to_ascii(input [2:0] dur);
    case (dur)
        3'b010: dur_to_ascii = "2"; // 0.5s
        3'b100: dur_to_ascii = "4"; // 1.0s
        default: dur_to_ascii = "X"; // error
    endcase
endfunction

reg [6:0] current;
reg [7:0] send_buf [0:1]; // ?��?��字�??
reg [1:0] send_idx;

reg [6:0] notes_num = 7'd59;
always @(posedge clk or negedge rst) begin
    if (~rst) begin
        notes_num <= 7'd59;
    end
    else begin
        if(~song)begin // love you left hand
        notes_num <= 7'd59;
    rom[0]  = 7'b0000_010; // 0, 0.5s
    rom[1]  = 7'b0011_010; // 3, 0.5s
    rom[2]  = 7'b0100_010; // 4, 0.5s
    rom[3]  = 7'b0101_010; // 5, 0.5s
    rom[4]  = 7'b1001_010; // 9, 0.5s
    rom[5]  = 7'b1100_100; // 12, 1s
    rom[6]  = 7'b0101_010; // 5, 0.5s
    rom[7]  = 7'b0111_010; // 7, 0.5s
    rom[8]  = 7'b1011_100; // 11, 1s
    rom[9]  = 7'b0101_010; // 5, 0.5s
    rom[10] = 7'b1001_010; // 9, 0.5s
    rom[11] = 7'b1010_100; // 10, 1s
    rom[12] = 7'b0101_010; // 5, 0.5s
    rom[13] = 7'b1001_010; // 9, 0.5s
    rom[14] = 7'b1100_010; // 12, 0.5s
    rom[15] = 7'b1001_010; // 9, 0.5s
    rom[16] = 7'b0101_010; // 5, 0.5s
    rom[17] = 7'b0111_010; // 7, 0.5s
    rom[18] = 7'b1011_010; // 11, 0.5s
    rom[19] = 7'b0111_010; // 7, 0.5s
    rom[20] = 7'b0101_010; // 5, 0.5s
    rom[21] = 7'b1000_010; // 8, 0.5s
    rom[22] = 7'b1011_010; // 11, 0.5s
    rom[23] = 7'b1000_010; // 8, 0.5s
    rom[24] = 7'b0010_010; // 2, 0.5s
    rom[25] = 7'b0110_010; // 6, 0.5s
    rom[26] = 7'b1010_010; // 10, 0.5s
    rom[27] = 7'b0110_010; // 6, 0.5s
    rom[28] = 7'b0010_010; // 2, 0.5s
    rom[29] = 7'b0110_010; // 6, 0.5s
    rom[30] = 7'b1010_010; // 10, 0.5s
    rom[31] = 7'b1001_010; // 9, 0.5s
    rom[32] = 7'b0101_010; // 5, 0.5s
    rom[33] = 7'b1001_010; // 9, 0.5s
    rom[34] = 7'b1100_100; // 12, 1s
    rom[35] = 7'b0101_010; // 5, 0.5s
    rom[36] = 7'b0111_010; // 7, 0.5s
    rom[37] = 7'b1011_100; // 11, 1s
    rom[38] = 7'b0100_010; // 4, 0.5s
    rom[39] = 7'b1001_010; // 9, 0.5s
    rom[40] = 7'b1010_100; // 10, 1s
    rom[41] = 7'b0101_010; // 5, 0.5s
    rom[42] = 7'b1001_010; // 9, 0.5s
    rom[43] = 7'b1100_010; // 12, 0.5s
    rom[44] = 7'b1001_010; // 9, 0.5s
    rom[45] = 7'b0001_010; // 1, 0.5s
    rom[46] = 7'b0101_010; // 5, 0.5s
    rom[47] = 7'b1011_010; // 11, 0.5s
    rom[48] = 7'b0101_010; // 5, 0.5s
    rom[49] = 7'b0010_010; // 2, 0.5s
    rom[50] = 7'b0110_010; // 6, 0.5s
    rom[51] = 7'b1010_100; // 10, 1s
    rom[52] = 7'b0101_010; // 5, 0.5s
    rom[53] = 7'b1001_010; // 9, 0.5s
    rom[54] = 7'b1100_010; // 12, 0.5s
    rom[55] = 7'b1001_010; // 9, 0.5s
    rom[56] = 7'b0101_010; // 5, 0.5s
    rom[57] = 7'b1001_010; // 9, 0.5s
    rom[58] = 7'b1100_100; // 12, 1.0s
    end
    else begin
    notes_num <= 7'd54;
    rom[0]  = 7'b0100_100; // 4, 1.0s
    rom[1]  = 7'b0100_100; // 4, 1.0s
    rom[2]  = 7'b0010_010; // 2, 0.5s
    rom[3]  = 7'b0100_010; // 4, 0.5s
    rom[4]  = 7'b0110_010; // 6, 0.5s
    rom[5]  = 7'b0100_010; // 4, 0.5s
    rom[6]  = 7'b0111_010; // 7, 0.5s
    rom[7]  = 7'b0100_010; // 4, 0.5s
    rom[8]  = 7'b0110_010; // 6, 0.5s

rom[9]  = 7'b0100_010; // 4, 0.5s
rom[10] = 7'b0011_010; // 3, 0.5s
rom[11] = 7'b0101_010; // 5, 0.5s
rom[12] = 7'b0111_010; // 7, 0.5s
rom[13] = 7'b0101_010; // 5, 0.5s
rom[14] = 7'b1000_010; // 8, 0.5s
rom[15] = 7'b0101_010; // 5, 0.5s

rom[16] = 7'b0111_010; // 7, 0.5s
rom[17] = 7'b0101_010; // 5, 0.5s
rom[18] = 7'b0010_010; // 2, 0.5s
rom[19] = 7'b0100_010; // 4, 0.5s
rom[20] = 7'b0110_010; // 6, 0.5s
rom[21] = 7'b0100_010; // 4, 0.5s
rom[22] = 7'b0111_010; // 7, 0.5s

rom[23] = 7'b0100_010; // 4, 0.5s
rom[24] = 7'b0110_010; // 6, 0.5s
rom[25] = 7'b0100_010; // 4, 0.5s
rom[26] = 7'b0001_010; // 1, 0.5s
rom[27] = 7'b0011_010; // 3, 0.5s
rom[28] = 7'b0110_010; // 6, 0.5s
rom[29] = 7'b0011_010; // 3, 0.5s

rom[30] = 7'b0111_010; // 7, 0.5s
rom[31] = 7'b0011_010; // 3, 0.5s
rom[32] = 7'b0110_010; // 6, 0.5s
rom[33] = 7'b0011_010; // 3, 0.5s
rom[34] = 7'b0010_010; // 2, 0.5s
rom[35] = 7'b0100_010; // 4, 0.5s
rom[36] = 7'b0110_010; // 6, 0.5s

rom[37] = 7'b0100_010; // 4, 0.5s
rom[38] = 7'b0111_010; // 7, 0.5s
rom[39] = 7'b0100_010; // 4, 0.5s
rom[40] = 7'b0110_010; // 6, 0.5s
rom[41] = 7'b0100_010; // 4, 0.5s
rom[42] = 7'b0011_010; // 3, 0.5s
rom[43] = 7'b0101_010; // 5, 0.5s

rom[44] = 7'b0111_010; // 7, 0.5s
rom[45] = 7'b0101_010; // 5, 0.5s
rom[46] = 7'b1000_010; // 8, 0.5s
rom[47] = 7'b0101_010; // 5, 0.5s
rom[48] = 7'b0111_010; // 7, 0.5s
rom[49] = 7'b0101_010; // 5, 0.5s
rom[50] = 7'b0010_010; // 2, 0.5s

rom[51] = 7'b0100_010; // 4, 0.5s
rom[52] = 7'b0110_010; // 6, 0.5s
rom[53] = 7'b0100_010; // 4, 0.5s

    end
end
end

always @(posedge clk or negedge rst) begin
    if (~rst) begin
        idx <= 0;
        send <= 0;
        send_idx <= 0;
        state <= 0;
    end else begin
        case (state)
            0: begin
                if (idx < notes_num) begin
                    current = rom[idx];
                    send_buf[0] = tile_to_ascii(current[6:3]);
                    send_buf[1] = dur_to_ascii(current[2:0]);
                    send_idx <= 0;
                    state <= 1;
                end
            end
            1: begin
                if (tx_ready) begin
                    tx_data <= send_buf[send_idx];
                    send <= 1;
                    state <= 2;
                end
            end
            2: begin
                send <= 0;
                if (!tx_ready) begin
                    state <= 3;
                end
            end
            3: begin
                if (tx_ready) begin
                    send_idx <= send_idx + 1;
                    if (send_idx == 1) begin
                        idx <= idx + 1;
                        state <= 0;
                    end else begin
                        state <= 1;
                    end
                end
            end
        endcase
    end
end

endmodule
