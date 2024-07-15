`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/27 19:46:16
// Design Name: 
// Module Name: modmult
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module montgomery(
    input [4095:0] mpand, //multiplicand
    input [4095:0] mplier, //multiplier
    input [4095:0] modulus, //modulus
    input clk,      //clock signal
    input rst_n,      //reset signal
    input ds,   
    
    output ready,
    output [4095:0] product //result
);

reg [4095:0] mpreg;
reg [4097:0] mcreg;
wire [4097:0] mcreg1;
wire [4097:0] mcreg2;
reg [4097:0] modreg1;
reg [4097:0] modreg2;
reg [4097:0] prodreg;
wire [4097:0] prodreg1;
wire [4097:0] prodreg2;
wire [4097:0] prodreg3;
wire [4097:0] prodreg4;
wire [1:0] modstate;
reg     first;      //��ɷ�
reg     busy;
reg  [2:0] count;

assign product = prodreg4[4095:0];
assign prodreg1 = mpreg[0] ? (prodreg + mcreg) : prodreg;
assign prodreg2 = prodreg1 - modreg1;
assign prodreg3 = prodreg1 - modreg2;
assign modstate = {prodreg3[4097], prodreg2[4097]}; 
assign prodreg4 = (modstate == 2'b11) ? prodreg1 : ((modstate == 2'b10) ? prodreg2 :prodreg3);

assign mcreg1 = mcreg - modreg1;
assign mcreg2 = mcreg1[4096] ? mcreg : mcreg1;
assign ready = first;

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        first <= 1'b0;
        busy  <= 1'b1;
        count <= 3'd0;
    end
    else begin
        if(busy)begin
            if(ds)begin
                mpreg <= mplier;
                mcreg <= {2'b00, mpand};
                modreg1 <= {2'b00, modulus};
                modreg2 <= {1'b0, modulus, 1'b0};
                prodreg <=  {4098{1'b0}};
                first <= 1'b0;
                busy <= 1'b0;
            end
        end
        else begin
            if(mpreg == 4096'd0) begin
                first <= 1'b1;
                count <= count + 1'b1;
                if(count == 3'd3) begin
                    count <= 3'd0;
                    first <= 1'b0;
                    busy <= 1'b1;                
                end
            end
            else begin
                mcreg <= {mcreg2[4096:0], 1'b0};
                mpreg <= {1'b0, mpreg[4095:1]};
                prodreg <=  prodreg4;
            end
        end
    end
end

endmodule
