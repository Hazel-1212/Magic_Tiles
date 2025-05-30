module music_uart_right (
    input wire clk,             // 系統??��?��?��?��?? 100 MHz
    input wire rst,             // ??��?�步??�設
    input wire tx_start,        // ??��?�傳?�信??��?�傳?��??��?��?��??
    input wire [7:0] tx_data,   // 要傳?��?? ASCII 資�??
    output reg tx,              // UART ?��輸�?��?�接?�� AD2 ??? Python�?
    output reg tx_ready         // 高電位代表可以接??�新??��?��??
);

    parameter CLK_FREQ = 100_000_000; // ??�設系統??��?�為 100 MHz
    parameter BAUD_RATE = 9600;

    localparam BAUD_DIV = CLK_FREQ / BAUD_RATE;
    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3;

    reg [1:0] state;
    reg [13:0] baud_cnt;  // 足�?�大來表�? CLK_FREQ/BAUD_RATE ??��??
    reg [2:0] bit_idx;
    reg [7:0] data_buf;

    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            state <= IDLE;
            tx <= 1'b1;         // UART idle ????�為高電�?
            tx_ready <= 1'b1;
            baud_cnt <= 0;
            bit_idx <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    baud_cnt <= 0;
                    bit_idx <= 0;
                    if (tx_start) begin
                        data_buf <= tx_data;
                        tx_ready <= 1'b0;
                        state <= START;
                    end
                end
                START: begin
                    if (baud_cnt == BAUD_DIV - 1) begin
                        baud_cnt <= 0;
                        tx <= 1'b0; // 起�?��?��?�為 0
                        state <= DATA;
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
                DATA: begin
                    if (baud_cnt == BAUD_DIV - 1) begin
                        baud_cnt <= 0;
                        tx <= data_buf[bit_idx];
                        bit_idx <= bit_idx + 1;
                        if (bit_idx == 3'd7)
                            state <= STOP;
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
                STOP: begin
                    if (baud_cnt == BAUD_DIV - 1) begin
                        baud_cnt <= 0;
                        tx <= 1'b1;      // ??�止位�?�為 1
                        tx_ready <= 1'b1;
                        state <= IDLE;
                    end else begin
                        baud_cnt <= baud_cnt + 1;
                    end
                end
            endcase
        end
    end

endmodule
