`timescale 1ns/1ps
`include "../rtl/_parameter.v"

module paillier_demo_decry_top #(
    parameter   RSA_WIDTH = 4096,
    parameter   DATA_WIDTH = 128,
    parameter   DATA_NUMBER = 32
)
(
    input   clk,
    input   rst_n,
    input   go,
    input   [(RSA_WIDTH - 1) : 0]  c,
    input   [(RSA_WIDTH - 1) : 0]  n,
    input   [(RSA_WIDTH - 1) : 0]  exp_n,
    input   [(RSA_WIDTH - 1) : 0]  lambda,
    input   [(RSA_WIDTH - 1) : 0]  mu,
    output  wire  [(RSA_WIDTH - 1) : 0]  result,
    output  wire                         done

);

    wire done_x;
    //wire done_y;
    wire [(DATA_WIDTH - 1) : 0] mod_inv_x;
    //wire [(DATA_WIDTH - 1) : 0] mod_inv_y;
    wire [(RSA_WIDTH  - 1):0] result_x;
    //wire [(RSA_WIDTH  - 1):0] result_y;
    //reg  done_1;
    //reg  done_2;
    //reg  data_1;
    //reg  data_2;
    wire  task_start;


    wire [(RSA_WIDTH  - 1):0] num_A;
    wire [(RSA_WIDTH  - 1):0] shang;
    wire [(RSA_WIDTH  - 1):0] yushu;
    reg                       ready_flag;


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
        .message(c),
        .exponent(lambda),
        .modulus(exp_n),
        .cypher(result_x),
        .mod_inv(mod_inv_x),
        .done(done_x)
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

    assign num_A = done_x ? (result_x - 1'd1) : num_A ;

    always@(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        ready_flag <= 0;
      end else if(!task_start) begin
        if(num_A == (result_x - 1'd1)) begin
            ready_flag <= 1'b1;
        end else begin
            ready_flag <= ready_flag;
        end
      end else begin
        ready_flag <= 0;
      end
    end

    DIVU divu_u
    (
        .dividend(num_A),
        .divisor(n),
        .start(ready_flag),
        .clk(clk),
        .rst_n(rst_n),
        .q(shang),
        .r(yushu),
        .valid(task_start)
    );


    montgomery montgomery_u
    (
        .mpand(shang),
        .mplier(mu),
        .modulus(n),
        .clk(clk),
        .rst_n(rst_n),
        .ds(task_start),
        .ready(done),
        .product(result)

    );



endmodule