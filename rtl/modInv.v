////////////////////////////////////////////////////////////////////////////////
// File:        modInv.v
// Description: Compute Modular inverse of a prime number
// Author:      Aruna Jayasena
// Date:        March 17, 2024
// Version:     1.0
// Revision:    -
// Company:     archfx.github.io
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
module modInv #(
    parameter   RSA_WIDTH = 4096,
    parameter   DATA_WIDTH = 128
)
(
    input clk, go,
    input [RSA_WIDTH-1:0] n,
    output reg signed [DATA_WIDTH-1:0] modulo_inv,
    output reg valid
);

reg signed [RSA_WIDTH:0] a, b;
reg signed [DATA_WIDTH-1:0] x, y, prev_x, prev_y, temp_a, temp_x, temp_y;
reg signed [RSA_WIDTH:0] quotient;
localparam [RSA_WIDTH:0] m = 4097'd2**DATA_WIDTH;  //2�?64次方


always @(posedge clk) begin
    if (go) begin
        a <= n;
        b <= m;
        x <= `RSA_WIDTH'd0;
        y <= `RSA_WIDTH'd1;
        prev_x <= `RSA_WIDTH'd1;
        prev_y <= `RSA_WIDTH'd0;
        valid <= 1'b0;
        quotient =0;
    end
    else begin
        // $display("b : %d", b);
        if (b != `RSA_WIDTH'd0) begin
            quotient = a / b;
            // $display("prev_x : %d", prev_x);
            a <= b;
            b <= a % b;
            x <= prev_x - (quotient * x);
            prev_x <= x;
            y <= prev_y - (quotient * y);
            prev_y <= y;
        end else begin
            if (a != `RSA_WIDTH'd1) begin
                // Modulo inverse does not exist
                valid <= 1'b0;
            end else begin
                // Modulo inverse exists
                modulo_inv <= (-(prev_x % m) % m);
                valid <= 1'b1;
            end
        end
    end
end

endmodule


