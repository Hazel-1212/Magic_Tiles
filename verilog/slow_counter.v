module slow_counter_to_uart (
    input wire clk,          // 100 MHz system clock
    input wire rst,          // Active-low reset
    output wire tx           // UART TX line
);

    reg tx_start = 0;
    reg [7:0] tx_data = 0;
    reg [7:0] count = 0;
    wire tx_busy;

    reg [26:0] tick_counter = 0;
    parameter integer TICKS_0_25S = 25_000_000;  // 0.25s = 100MHz * 0.25

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            tick_counter <= 0;
            count <= 0;
            tx_start <= 0;
        end else begin
            if (tick_counter >= TICKS_0_25S - 1) begin
                tick_counter <= 0;
                if (!tx_busy) begin
                    tx_data <= count;
                    count <= count + 1;
                    tx_start <= 1;
                end
            end else begin
                tick_counter <= tick_counter + 1;
                tx_start <= 0;
            end
        end
    end

    slow_counter_uart uart (
        .CLK(clk),
        .SEND(tx_start),
        .DATA(tx_data),
        .READY(),        // Not used here
        .UART_TX(tx),
        .BUSY(tx_busy)
    );

endmodule

