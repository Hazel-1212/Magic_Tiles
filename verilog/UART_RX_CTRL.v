module UART_RX_CTRL (
    input wire CLK,         // 100 MHz clock
    input wire UART_RX,     // Serial input
    output reg [7:0] DATA,  // Received byte
    output reg READY        // High for 1 clock cycle when byte received
);

    // State definitions (2-bit encoding)
    parameter IDLE    = 2'b00;
    parameter START   = 2'b01;
    parameter RECEIVE = 2'b10;
    parameter STOP    = 2'b11;

    reg [1:0] state = IDLE;

    // Timing constants for 9600 baud @ 100 MHz
    parameter BIT_TMR_MAX = 10416;   // 100_000_000 / 9600
    parameter BIT_MID     = 5208;    // Midpoint for sampling

    reg [13:0] bit_timer = 0;        // Enough bits to count to 10416
    reg [2:0] bit_index = 0;         // 0 to 7 (8 bits)
    reg [7:0] shift_reg = 0;

    always @(posedge CLK) begin
        case (state)
            IDLE: begin
                READY <= 0;
                if (UART_RX == 0) begin  // Detect start bit
                    bit_timer <= 0;
                    bit_index <= 0;
                    state <= START;
                end
            end

            START: begin
                bit_timer <= bit_timer + 1;
                if (bit_timer == BIT_MID) begin
                    if (UART_RX == 0) begin  // Confirm start bit still valid
                        bit_timer <= 0;
                        state <= RECEIVE;
                    end else begin
                        state <= IDLE;  // False start bit
                    end
                end
            end

            RECEIVE: begin
                bit_timer <= bit_timer + 1;
                if (bit_timer == BIT_TMR_MAX) begin
                    shift_reg[bit_index] <= UART_RX;
                    bit_index <= bit_index + 1;
                    bit_timer <= 0;
                    if (bit_index == 3'd7) begin
                        state <= STOP;
                    end
                end
            end

            STOP: begin
                bit_timer <= bit_timer + 1;
                if (bit_timer == BIT_TMR_MAX) begin
                    if (UART_RX == 1) begin  // Stop bit should be high
                        DATA <= shift_reg;
                        READY <= 1;
                    end
                    state <= IDLE;
                end
            end
        endcase
    end

endmodule
