module light_show(
    input clk,
    input endgame,
    input right_win,
    output wire red,
    output wire green,
    output wire blue
);

    reg red_reg = 0;
    reg green_reg = 0;
    reg blue_reg = 0;

    assign red = red_reg;
    assign green = green_reg;
    assign blue = blue_reg;

    reg [2:0] dir = 0;
    reg [25:0] counter = 0;
    wire slow_clk = counter[20];  // slower bit to get visible color fading

    reg [18:0] pwm_counter = 0;
    reg [7:0] pwm_percentage_red   = 50;
    reg [7:0] pwm_percentage_green = 0;
    reg [7:0] pwm_percentage_blue  = 0;

    reg prev_slow_clk = 0;

    always @(posedge clk) begin
        counter <= counter + 1;
        pwm_counter <= pwm_counter + 1;

        // PWM output generation
        red_reg   <= (pwm_percentage_red   > 0 && (pwm_counter % 101) < pwm_percentage_red);
        green_reg <= (pwm_percentage_green > 0 && (pwm_counter % 101) < pwm_percentage_green);
        blue_reg  <= (pwm_percentage_blue  > 0 && (pwm_counter % 101) < pwm_percentage_blue);

        // Edge detection for slow clock
        if (!prev_slow_clk && slow_clk) begin
            if (endgame) begin
                // Winner color display
                if (right_win) begin
                    pwm_percentage_red   <= 50;
                    pwm_percentage_green <= 0;
                    pwm_percentage_blue  <= 0;
                end else begin
                    pwm_percentage_red   <= 0;
                    pwm_percentage_green <= 0;
                    pwm_percentage_blue  <= 50;
                end
            end else begin
                // Cycling RGB
                case (dir)
                    0: begin
                        if (pwm_percentage_red > 0)
                            pwm_percentage_red <= pwm_percentage_red - 1;
                        else
                            dir <= 1;
                        pwm_percentage_green <= pwm_percentage_green + 1;
                        pwm_percentage_blue  <= 0;
                    end
                    1: begin
                        if (pwm_percentage_green > 0)
                            pwm_percentage_green <= pwm_percentage_green - 1;
                        else
                            dir <= 2;
                        pwm_percentage_blue  <= pwm_percentage_blue + 1;
                        pwm_percentage_red   <= 0;
                    end
                    2: begin
                        if (pwm_percentage_blue > 0)
                            pwm_percentage_blue <= pwm_percentage_blue - 1;
                        else
                            dir <= 0;
                        pwm_percentage_red   <= pwm_percentage_red + 1;
                        pwm_percentage_green <= 0;
                    end
                endcase
            end
        end

        prev_slow_clk <= slow_clk;
    end

endmodule

