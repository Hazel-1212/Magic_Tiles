module top_LFSR(
    input clk,        // assume 50 MHz clock
    input reset_n,    // active low reset
    output reg [2:0] rail   // connect to AD2 RX (DIO-1)
);
    wire uart_tx;
    wire [2:0] random;      // random number 0~7
    wire uart_ready;
    reg uart_send = 0;
    reg [7:0] uart_data = 8'h41; // default 'A'

    reg [25:0] counter = 0;  // for 0.5s interval at 50MHz
    reg tick = 0;

    // === Instantiate LFSR ===
    lfsr_3bit lfsr_inst (
        .clk(clk),
        .reset(reset_n),   // Make sure lfsr_3bit uses active-low reset too
        .random(random)
    );

    // === 0.5s Tick Generator ===
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            counter <= 0;
            tick <= 0;
        end else if (counter == 10_000_000 - 1) begin  // 0.1 sec
            counter <= 0;
            tick <= 1;
        end else begin
            counter <= counter + 1;
            tick <= 0;
        end
    end

    // === UART Send Logic ===
    reg send_pending = 0;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        rail <= 0;
        uart_send <= 0;
        uart_data <= 8'h41;
        send_pending <= 0;
    end else begin
        rail <= random;

        // Request send at tick
        if (tick) begin
            send_pending <= 1;
            uart_data <= 8'h41 + random;
        end

        // Only send when READY and we have pending data
        if (send_pending && uart_ready) begin
            uart_send <= 1;
            send_pending <= 0;  // Clear after sending
        end else begin
            uart_send <= 0;
        end
    end
end
endmodule

