`timescale 1ns/1ps
module tb_fir;
    reg clk = 0;
    reg rst;
    reg signed [15:0] sample_in;
    reg valid_in;
    wire signed [31:0] sample_out;
    wire valid_out;

    // instantiate FIR
    fir #(.N(8), .DATA_WIDTH(16), .COEFF_WIDTH(16)) uut (
        .clk(clk), .rst(rst), .sample_in(sample_in), .valid_in(valid_in),
        .sample_out(sample_out), .valid_out(valid_out)
    );

    always #5 clk = ~clk; // 100 MHz style for simulation clarity

    integer t;
    initial begin
        $dumpfile("fir.vcd");
        $dumpvars(0, tb_fir);
        rst = 1; valid_in = 0; sample_in = 0;
        #20;
        rst = 0;

        // ---------- IMPULSE RESPONSE ----------
        // apply an impulse: sample = 1.0 -> in fixed Q1.15 => 1.0 * 2^15 = 32768 (overflow for signed 16-bit)
        // Instead we use Q0.15 <= 1.0 fits as +32767 max signed 16-bit, choose 0x7FFF
        // Use input value = 1.0 represented as 32767 (approx)
        $display("Impulse response:");
        sample_in = 16'sd32767; valid_in = 1; #10; // cycle 1: impulse
        sample_in = 0; valid_in = 1; #10;
        // continue sending zeros to observe full N outputs
        for (t=0; t<12; t=t+1) begin
            sample_in = 0;
            valid_in = 1;
            #10;
        end
        valid_in = 0;
        #40;

        // ---------- STEP RESPONSE ----------
        $display("\nStep response:");
        // step: persist value 1.0 for many cycles
        sample_in = 16'sd32767; valid_in = 1;
        for (t=0; t<16; t=t+1) begin
            #10;
        end
        valid_in = 0;
        #20;

        $finish;
    end

    // print outputs when valid_out asserted
    always @(posedge clk) begin
        if (valid_out) begin
            // convert sample_out (wide) back to floating approximate for readability:
            // sample_out is sum of (sample_in * coeff_int). sample_in was in Q0.15 ~ 32767
            // To get decimal result in floating: result_float = sample_out / (2^15 * 2^15) ??? but we will print integer value
            $display("t=%0t out_raw=%0d", $time, sample_out);
        end
    end

endmodule
