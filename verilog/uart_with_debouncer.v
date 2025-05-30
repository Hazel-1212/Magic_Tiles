module uart_with_debouncer (
    input clk,
    input rst,
    input [3:0] note1,
    input [3:0] note2,
    input endgame,
    input wire uart_rx,
    output wire uart_tx,
    output wire [7:0] uart_data_rx,
    output wire uart_ready_rx
);

// === Internal Wires and Regs ===
wire uart_ready;
reg uart_send;
reg [7:0] uart_data;

wire btn_pressed;
wire key_pulse_left;
wire key_pulse_right;
wire [3:0] btn_debounced_left;
wire [3:0] btn_debounced_right;

// === Button Debounce ===
assign btn_pressed= key_pulse_left | key_pulse_right;

// FSM state
reg [1:0] state;
parameter IDLE = 2'd0,
          SEND1 = 2'd1,
           SEND_WAIT = 2'd2,
           WAIT1 = 2'd2,
           SEND2 = 2'd3;

// === UART Send FSM ===
always @(posedge clk or negedge rst) begin
    if (~rst) begin
        uart_send <= 0;
        uart_data <=  8'h0;
        state <= IDLE;
    end 
    else if (endgame)begin

        uart_send <= 0;  // Default to no send
        case (state)
        IDLE: begin
            uart_send <= 0;
            if (btn_pressed) begin
                state <= SEND1;
            end
        end

        SEND1: begin
            if (uart_ready) begin
                uart_data <= 8'h52;  // ASCII 'R'
                uart_send <= 1;
                state <= SEND_WAIT;
            end
        end

        SEND_WAIT: begin
            uart_send <= 0;  // De-assert after 1 cycle
            state <= IDLE;
        end

        default: begin
            uart_send <= 0;
            state <= IDLE;
        end
    endcase

    end

    else begin
        uart_send <= 0;  // Default to no send

        case (state)
            IDLE: begin
                if (btn_pressed) begin
                    state <= SEND1;
                end
            end

            SEND1: begin
                if (uart_ready) begin
                    uart_data <= 8'h40 + note1;  // Start from A as ASCII
                    uart_send <= 1;
                    state <= WAIT1;
                end
            end

            WAIT1: begin
                if (!uart_send && uart_ready) begin
                    state <= SEND2;
                end
            end

            SEND2: begin
                if (uart_ready) begin
                    uart_data <= 8'h60 + note2;  // Start from a as ASCII
                    uart_send <= 1;
                    state <= IDLE;
                end
            end

            default: state <= IDLE;
        endcase
    end
end



// === Debouncers ===
debouncer btn_debouncer_l (
    .clk(clk),
    .rst(rst),
    .noisy(note1),
    .clean(btn_debounced_left)
);

debouncer btn_debouncer_r (
    .clk(clk),
    .rst(rst),
    .noisy(note2),
    .clean(btn_debounced_right)
);

key_pulse_gen key_pulse_gen_l (
    .clk(clk),
    .rst(rst),
    .clean_in(btn_debounced_left),
    .pulse(key_pulse_left)
);

key_pulse_gen key_pulse_gen_r (
    .clk(clk),
    .rst(rst),
    .clean_in(btn_debounced_right),
    .pulse(key_pulse_right)
);

// === UART Transmitter ===
UART_TX_CTRL uart_transmitter (
    .SEND(uart_send),
    .DATA(uart_data),
    .CLK(clk),
    .READY(uart_ready),
    .UART_TX(uart_tx)
);

// === UART Receiver ===
UART_RX_CTRL uart_receiver (
    .CLK(clk),
    .UART_RX(uart_rx),
    .DATA(uart_data_rx),
    .READY(uart_ready_rx)
);

endmodule