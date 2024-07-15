////////////////////////////////////////////////////////////////////////////////
// File:        mod.v
// Description: Modular computation to compute parameters r and t.
// Author:      Aruna Jayasena
// Date:        March 17, 2024
// Version:     1.0
// Revision:    -
// Company:     archfx.github.io
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
`include "../rtl/_parameter.v"


module rtMod#(
    parameter   RSA_WIDTH = 4096
)
(
    input wire clk,
    input wire rst_n,
    input wire go,
    input wire mode,
    input wire [RSA_WIDTH-1:0] n,
    output wire [RSA_WIDTH-1:0] r,
    output reg done
);
 
localparam [RSA_WIDTH + 1 : 0] mainreg = { 2'd1, `RSA_WIDTH'd0};
wire [RSA_WIDTH*2+1:0] r2; 
reg [11:0] count;
reg [RSA_WIDTH*2+1:0] r_temp;

assign r = r_temp[RSA_WIDTH-1:0];
 
localparam op_R = 0, op_T =1;
 
localparam START = 0, SUB = 1, DONE =2 , R2= 3;
//wire [127:0] r2;
//wire [RSA_WIDTH*2+1:0] r2;
//assign r2 = 'd16300;
assign r2 = mainreg % n;

  
always @(posedge clk or negedge rst_n) begin

    if(!rst_n) begin
        r_temp <= r2;
        done <= 0;
        count <= 0;
        //r2 <= 0;
    end
   
   else  begin
    if (go) begin
        r_temp <= mainreg;
        done <= 0;
        count<=SUB;
        //r2 <= r_temp;
    end

    case (count)
        SUB: begin
            if (r_temp > n) begin
                r_temp <= r_temp % n;  // r = r % n, if r > n, 原始的r_temp高两位为11�? 必然经过这个步骤�?次，随后由于比这个数小�?�只要不计算t的情况下，均不会发生变化�?
                count<=SUB;
                if (mode == op_R) begin
                    done <= 1;
                end
            end
            else begin 
                if (mode == op_T) begin
                    count <= R2;
                    done <= 0;
                end
            end
        end
        R2: begin
            r_temp <= (r_temp * r_temp)%n; // t = t^2 % n;  -> 如果更换为模乘运算的话，�?要将这里的t*t改成 x*y，并重新规划模乘顺序�?
            done <= 0;
            count<=DONE;
        end
        DONE: begin
            done <= 1;
        end
        default: begin
        end
    endcase
    end
end
 
endmodule
 
 
