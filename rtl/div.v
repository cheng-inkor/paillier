`timescale 1ns / 1ps
module DIVU(
    input [4095:0] dividend,
    input [4095:0] divisor,
    input start,
    input clk,
    input rst_n,
    output [4095:0] q,
    output [4095:0] r,
    output reg valid
    );
    wire ready;
    reg  busy;
    reg [13:0] count;
    reg [4095:0] reg_q;
    reg [4095:0] reg_r;
    reg [4095:0] reg_b;
    reg r_sign;
    //assign ready=~valid2&valid;
    wire [4096:0] sub_add=r_sign?({reg_r,q[4095]}+{1'b0,reg_b}):
                                ({reg_r,q[4095]}-{1'b0,reg_b});
    assign r=r_sign?reg_r+reg_b:reg_r;
    assign q=reg_q;
    
    always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        count<=0;
        valid<=0;
        busy <=0;
    //    valid2<=0;
    end
    else begin
    //    valid2<=valid;
        if(start)begin
            reg_r<=4096'b0;
            r_sign<=0;
            reg_q<=dividend;
            reg_b<=divisor;
            count<=0;
            valid<=0;
            busy<=1;       
            if(busy)begin
                reg_r<=sub_add[4095:0];
                r_sign<=sub_add[4096];
                reg_q<={reg_q[4094:0],~sub_add[4096]};
                count<=count+1;
                if(count==4095) begin
                    valid<=1;
                    busy <=0;
                end
            end
        end else begin
            reg_r<=4096'b0;
            r_sign<=0;
            reg_q<=4096'b0;
            reg_b<=4096'b0;
            count<=0;
            valid<=0;
            busy<=0;
        end
    end
    end                            
endmodule
