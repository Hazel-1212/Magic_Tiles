module slow_counter_uart (
    input wire CLK,
    input wire SEND,
    input wire [7:0] DATA,
    output wire READY,
    output wire UART_TX,
    output wire BUSY
);

    parameter RDY = 2'd0, LOAD_BIT = 2'd1, SEND_BIT = 2'd2;

    localparam BIT_TMR_MAX = 14'd10416;  // 100MHz / 9600 baud
    localparam BIT_INDEX_MAX = 10;

    reg [1:0] txState = RDY;
    reg [13:0] bitTmr = 0;
    reg [3:0] bitIndex = 0;
    reg txBit = 1'b1;
    reg [9:0] txData = 10'b1111111111;

    assign READY = (txState == RDY);
    assign BUSY = ~READY;
    assign UART_TX = txBit;
    wire bitDone = (bitTmr == BIT_TMR_MAX);

    always @(posedge CLK) begin
        case (txState)
            RDY: begin
                if (SEND) begin
                    txData <= {1'b1, DATA, 1'b0}; // Stop, data, start
                    txState <= LOAD_BIT;
                    bitIndex <= 0;
                end
            end
            LOAD_BIT: begin
                txBit <= txData[bitIndex];
                txState <= SEND_BIT;
            end
            SEND_BIT: begin
                if (bitDone) begin
                    if (bitIndex == BIT_INDEX_MAX - 1) begin
                        txState <= RDY;
                    end else begin
                        bitIndex <= bitIndex + 1;
                        txState <= LOAD_BIT;
                    end
                end
            end
            default: txState <= RDY;
        endcase
    end

    always @(posedge CLK) begin
        if (txState == RDY || bitDone)
            bitTmr <= 0;
        else
            bitTmr <= bitTmr + 1;
    end

endmodule

