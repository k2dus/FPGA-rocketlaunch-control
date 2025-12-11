module top (clk, btn, num, led, reset);
    //Input and outputs
    input clk, btn, reset;
    
    
    output reg led;
    output reg [3:0] num; // reg bc it is a variable stored in a 4 bit register

    //State Register
    reg [1:0] state;
    
    //State Encoding
    parameter [1:0] INIT     = 2'b00; 
    parameter [1:0] COUNTDOWN = 2'b01;
    parameter [1:0] LAUNCH   = 2'b10;
    
    initial begin
        state = INIT;
     end
    
    // High-Level State Machine
    always@(posedge clk) begin
            case (state)
                INIT: begin
                    num <= 4'd9;
                    led <= 0;
                    if (btn) state <= COUNTDOWN;
                end
                COUNTDOWN: begin
                    if (num == 0) begin
                        state <= LAUNCH;
                    end else begin
                        num <= num - 4'd1;
                    end
                    if (reset) state <= INIT;
                end
                LAUNCH: begin
                    led <= 1;
                    // Stay in LAUNCH state until reset
                    if (reset) state <= INIT;
                end
                default: state <= INIT;
            endcase
        end
endmodule

module num_to_7seg(num, seg7);
    input [3:0] num;
    output reg [6:0] seg7;
    
    always @(*) begin
        case (num)
            4'd0: seg7 = 7'h7E;
            4'd1: seg7 = 7'h30;
            4'd2: seg7 = 7'h6D;
            4'd3: seg7 = 7'h79;
            4'd4: seg7 = 7'h33;
            4'd5: seg7 = 7'h5B;
            4'd6: seg7 = 7'h5F;
            4'd7: seg7 = 7'h70;
            4'd8: seg7 = 7'h7F;
            4'd9: seg7 = 7'h73;
            default: seg7 = 7'h00;
        endcase
    end
endmodule

module clk_div (clk_in, clk_out);
    input clk_in;
    output reg clk_out = 0;
    
    reg [22:0] counter = 0;
    parameter [22:0] max_count = 23'd6_000_000;
    
    // No initial block needed - hardware starts in defined state
    
    always@(posedge clk_in) begin
        if (counter < max_count) begin
            counter <= counter + 1;
        end else begin
            clk_out <= !clk_out;
            counter <= 0;
        end
    end
    
endmodule

// Top-level module for hardware implementation
module countdown_system(
    input clk_in,     // 12Mhz
    input reset,      // reset button
    input button,         // Start button (active high)
    output [6:0] seg7,    // 7-segment display output
    output led            // Launch LED
);

    wire clk_slow;        // Divided clock
    wire [3:0] count_num; // Count value
    
    // Instantiate clock divider
    clk_div clock_divider(
        .clk_in(clk_in),
        .clk_out(clk_slow)
    );
    
    // Instantiate main state machine
    top main_controller(
        .clk(clk_slow),
        .btn(button),
        .num(count_num),
        .led(led),
        .reset(reset)
    );
    
    // Instantiate 7-segment display driver
    num_to_7seg display_driver(
        .num(count_num),
        .seg7(seg7)
    );
    
endmodule