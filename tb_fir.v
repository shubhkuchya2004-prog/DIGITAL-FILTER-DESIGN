// fir.v
// Simple synchronous FIR filter (N-tap) with signed fixed-point coefficients (Q1.15)
// Parameterized: N, DATA_WIDTH, COEFF_WIDTH
module fir #(
    parameter N = 8,
    parameter DATA_WIDTH = 16,     // input sample width (signed)
    parameter COEFF_WIDTH = 16     // coeff width (signed Q1.15)
)(
    input  wire clk,
    input  wire rst,               // synchronous reset (active high)
    input  wire signed [DATA_WIDTH-1:0] sample_in,
    input  wire valid_in,
    output reg  signed [DATA_WIDTH+COEFF_WIDTH-1:0] sample_out, // wide result
    output reg  valid_out
);

    // coefficient memory (signed Q1.15). Edit these decimal integer values to change filter.
    // For h = [0.05,0.10,0.15,0.20,0.20,0.15,0.10,0.05]
    localparam signed [COEFF_WIDTH-1:0] coeffs [0:N-1] = {
        16'sd1638,  // 0: 0.05  -> 0.05*2^15 = 1638.4 -> 1638
        16'sd3277,  // 1: 0.10  -> 3276.8 -> 3277
        16'sd4915,  // 2: 0.15
        16'sd6554,  // 3: 0.20
        16'sd6554,  // 4: 0.20 (symmetric)
        16'sd4915,  // 5: 0.15
        16'sd3277,  // 6: 0.10
        16'sd1638   // 7: 0.05
    };

    // shift register to store past N samples
    reg signed [DATA_WIDTH-1:0] shift_reg [0:N-1];
    integer i;

    // Multiply-accumulate width: DATA_WIDTH + COEFF_WIDTH bits
    reg signed [DATA_WIDTH+COEFF_WIDTH-1:0] mac;
    reg valid_reg;

    always @(posedge clk) begin
        if (rst) begin
            for (i=0; i<N; i=i+1) shift_reg[i] <= 0;
            sample_out <= 0;
            valid_out <= 0;
            mac <= 0;
            valid_reg <= 0;
        end else begin
            // shift the samples on valid_in (streaming)
            if (valid_in) begin
                // shift right: newest sample goes to shift_reg[0]
                for (i=N-1; i>0; i=i-1) shift_reg[i] <= shift_reg[i-1];
                shift_reg[0] <= sample_in;
            end

            // perform multiply-accumulate every cycle (combinational style inside sequential block)
            // mac = sum_{k=0}^{N-1} shift_reg[k] * coeffs[k]
            mac = 0;
            for (i=0; i<N; i=i+1) begin
                // extend operands to signed (DATA_WIDTH + COEFF_WIDTH)
                mac = mac + ( $signed(shift_reg[i]) * $signed(coeffs[i]) );
            end

            // Provide output and valid: output valid one cycle after input valid
            // (We use a simple one-cycle latency)
            valid_reg <= valid_in;
            valid_out <= valid_reg;
            sample_out <= mac; // result is in Q(??): input Q * coeff Q => Q-format sum -> Q(1.15 + 1.15) notionally
        end
    end

endmodule
