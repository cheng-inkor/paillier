`timescale 1ns/1ps
`include "../rtl/_parameter.v"

module paillier_demo_top #(
    parameter   RSA_WIDTH = 4096,
    parameter   DATA_WIDTH = 128,
    parameter   DATA_NUMBER = 32
)
(
    input   clk,
    input   rst_n,
    input   go,
    input   [(RSA_WIDTH - 1) : 0]  m,
    input   [(RSA_WIDTH - 1) : 0]  r,
    input   [(RSA_WIDTH - 1) : 0]  n,
    input   [(RSA_WIDTH - 1) : 0]  exp_n,
    input   [(RSA_WIDTH - 1) : 0]  g,
    output  wire  [(RSA_WIDTH - 1) : 0]  result,
    output  wire                         done

);

    wire done_x;
    wire done_y;
    wire [(DATA_WIDTH - 1) : 0] mod_inv_x;
    wire [(DATA_WIDTH - 1) : 0] mod_inv_y;
    wire [(RSA_WIDTH  - 1):0] result_x;
    wire [(RSA_WIDTH  - 1):0] result_y;
    reg  done_1;
    reg  done_2;
    reg  data_1;
    reg  data_2;
    reg  task_start;

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            done_1 <= 1'b0;
            done_2 <= 1'b0;
            data_1 <= 4096'd0;
            data_2 <= 4096'd0;
        end else if (!task_start) begin
            if(done_x) begin
                done_1 <= 1'b1;
                data_1 <= result_x;
            end else if(done_y) begin
                done_2 <= 1'b1;
                data_2 <= result_y;
            end 
        end else begin
            done_1 <= done_1;
            done_2 <= done_2;
            data_1 <= data_1;
            data_2 <= data_2;
            if(done) begin
                done_1 <= 1'b0;
                done_2 <= 1'b0;
                data_1 <= 4096'd0;
                data_2 <= 4096'd0;
            end
        end
    end

    always@(posedge clk)begin
        if (done_1 & done_2) begin
            task_start <= 1'b1;
        end
        else begin
            task_start <= 1'b0;
        end
    end 


    rsa4k #(
        .RSA_WIDTH(RSA_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .DATA_NUMBER(DATA_NUMBER)
    )
    rsa4k_0
    (
        .clk(clk),
        .rst_n(rst_n),
        .go(go),
        .message(g),
        .exponent(m),
        .modulus(exp_n),
        .cypher(result_x),
        .mod_inv(mod_inv_x),
        .done(done_x)
    );

    rsa4k #(
        .RSA_WIDTH(RSA_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .DATA_NUMBER(DATA_NUMBER)
    )
    rsa4k_1
    (
        .clk(clk),
        .rst_n(rst_n),
        .go(go),
        .message(r),
        .exponent(n),
        .modulus(exp_n),
        .cypher(result_y),
        .mod_inv(mod_inv_y),
        .done(done_y)
    );

    /*mod_mul #(
        .RSA_WIDTH(RSA_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .DATA_NUMBER(DATA_NUMBER)
    )
    mod_mul_0
    (
        .clk(clk),
        .rst_n(rst_n),
        .done_x(done_x),
        .done_y(done_y),
        .data_x(result_x),
        .data_y(result_y),
        .modulus(exp_n),
        .mod_inv(mod_inv_x),
        .result_iddmm(result),
        .done(done)
    );
    */

    montgomery montgomery_u
    (
        .mpand(result_x),
        .mplier(result_y),
        .modulus(exp_n),
        .clk(clk),
        .rst_n(rst_n),
        .ds(task_start),
        .ready(done),
        .product(result)

    );



endmodule