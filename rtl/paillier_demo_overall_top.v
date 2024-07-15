`timescale 1ns/1ps
`include "../rtl/_parameter.v"

module paillier_demo_overall_top #(
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
    input   [(RSA_WIDTH - 1) : 0]  c,
    input   [(RSA_WIDTH - 1) : 0]  c1,
    input   [(RSA_WIDTH - 1) : 0]  c2,
    input   [(RSA_WIDTH - 1) : 0]  n,
    input   [(RSA_WIDTH - 1) : 0]  exp_n,
    input   [(RSA_WIDTH - 1) : 0]  g,
    input   [(RSA_WIDTH - 1) : 0]  lambda,
    input   [(RSA_WIDTH - 1) : 0]  mu,
    input   [3:0]                  state,
    output  reg  [(RSA_WIDTH - 1) : 0]  result,
    output  reg                         done   

);

    localparam encry = 4'b0001;
    localparam decry = 4'b0010;
    localparam homo_add = 4'b0100;
    localparam homo_mul = 4'b1000;
    
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

    reg [(RSA_WIDTH  - 1):0]  num_A;
    wire [(RSA_WIDTH  - 1):0]  num_B;
    reg [(RSA_WIDTH  - 1):0]  num_mult;

    wire [(RSA_WIDTH  - 1):0]  shang;
    wire [(RSA_WIDTH  - 1):0]  yushu;
    reg                        ready_flag;
    reg                        start_flag;

    reg [(RSA_WIDTH - 1) : 0]  message_rsa4k_0;
    reg [(RSA_WIDTH - 1) : 0]  exponent_rsa4k_0;
    reg [(RSA_WIDTH - 1) : 0]  modulus_rsa4k_0;
    wire [(RSA_WIDTH - 1) : 0]  cypher_rsa4k_0;
    wire                        done_rsa4k_0;
    reg                        done_mult_add;

    reg                        go_rsa4k_0;

    reg                        ready_div;

    wire [(RSA_WIDTH*2 - 1) : 0]  mult_product;

    wire                        done_mult;
    reg                        go_mult;

    wire                        valid_divu;
    reg                        done_exp;
    wire                        done_encry_exp;

    reg [(RSA_WIDTH - 1) : 0]  mpand;
    reg [(RSA_WIDTH - 1) : 0]  mplier;
    reg [(RSA_WIDTH - 1) : 0]  modulus_mod_mul;
    wire                        ready_mod_mul;
    wire [(RSA_WIDTH - 1) : 0]  result_mod_mul;

    always@(*) begin
        go_mult <= 1'b0;
        case(state) 
            encry: begin

                message_rsa4k_0 <= g;
                exponent_rsa4k_0 <= r;
                modulus_rsa4k_0 <= exp_n;
                go_rsa4k_0 <= go;

                go_mult <= go;

                mpand <= cypher_rsa4k_0;
                mplier <= num_mult;
                modulus_mod_mul <= exp_n;
                start_flag <= done_encry_exp;
                done <= ready_mod_mul;
                result <= result_mod_mul;

                ready_div <= 1'b0;
            end
            decry: begin
                message_rsa4k_0 <= c;
                exponent_rsa4k_0 <= lambda;
                modulus_rsa4k_0 <= exp_n;
                go_rsa4k_0 <= go;

                mpand <= shang;
                mplier <= mu;
                modulus_mod_mul <= n;
                start_flag <= valid_divu;
                done <= ready_mod_mul;
                result <= result_mod_mul;

                ready_div <= done_rsa4k_0;
            end
            homo_add: begin
                message_rsa4k_0 <= 4096'd0;
                exponent_rsa4k_0 <= 4096'd0;
                modulus_rsa4k_0 <= exp_n;
                go_rsa4k_0 <= 1'b0;

                mpand <= c1;
                mplier <= c2;
                modulus_mod_mul <= exp_n;
                start_flag <= go;
                done <= ready_mod_mul;
                result <= result_mod_mul;

                ready_div <= 1'b0;
            end
            homo_mul: begin
                message_rsa4k_0 <= c;
                exponent_rsa4k_0 <= m;
                modulus_rsa4k_0 <= exp_n;
                go_rsa4k_0 <= go;

                mpand <= 4096'd0;
                mplier <= 4096'd0;
                modulus_mod_mul <= 4096'd0;
                start_flag <= 1'b0;

                done <= done_rsa4k_0;
                result <= cypher_rsa4k_0;

                ready_div <= 1'b0;                
            end
            default: begin
                message_rsa4k_0 <= 4096'd0;
                exponent_rsa4k_0 <= 4096'd0;
                modulus_rsa4k_0 <= 4096'd0;
                go_rsa4k_0 <= 1'b0;

                mpand <= 4096'd0;
                mplier <= 4096'd0;
                modulus_mod_mul <= 4096'd0;
                start_flag <= 1'b0;
                done <= 1'b0;
                result <= 4096'd0;

                ready_div <= 1'b0;                
            end
        endcase
    end


    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            done_1 <= 1'b0;
            done_2 <= 1'b0;
            data_1 <= 4096'd0;
            data_2 <= 4096'd0;
        end  
        else if(ready_mod_mul) begin
                done_1 <= 1'b0;
                done_2 <= 1'b0;
                data_1 <= 4096'd0;
                data_2 <= 4096'd0;
        end
        else if (!done_encry_exp) begin
            if(done_rsa4k_0) begin
                done_1 <= 1'b1;
                data_1 <= cypher_rsa4k_0;
            end else if(done_mult_add) begin
                done_2 <= 1'b1;
                data_2 <= num_mult;
            end 
        end
        else begin
                done_1 <= done_1;
                done_2 <= done_2;
                data_1 <= data_1;
                data_2 <= data_2;
        end
    end


   always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            num_A <= 4096'd0;
            num_mult <= 4096'd0;        
        end
        else begin
            if(ready_div) begin
                num_A <= (cypher_rsa4k_0 - 1'd1);
            end
            else begin
                num_A <= num_A;
            end
            if(done_mult) begin
                num_mult <= (num_B + 1'd1);
            end
            else begin
                num_mult <= num_mult;
            end
        end        
   end
    
    //assign num_A = ready_div ? (cypher_rsa4k_0 - 1'd1) : num_A ;

    assign num_B = mult_product[4095:0];

    //assign num_mult = done_mult ? (num_B + 1'd1) : num_mult ;


    always@(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        done_mult_add <= 0;
      end else if(done_mult) begin
        if(num_mult == (num_B + 1'd1)) begin
            done_mult_add <= 1'b1;
        end else begin
            done_mult_add <= done_mult_add;
        end
      end else begin
        done_mult_add <= 0;
      end
    end

    always@(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        ready_flag <= 0;
      end else if(!valid_divu) begin
        if(num_A == (cypher_rsa4k_0 - 1'd1)) begin
            ready_flag <= 1'b1;
        end else begin
            ready_flag <= ready_flag;
        end
      end else begin
        ready_flag <= 0;
      end
    end

    /*always@(posedge clk)begin
        if(ready_mod_mul) begin
            done_encry_exp <= 1'b0;
        end 
        else if (done_1 & done_2) begin
            done_encry_exp <= 1'b1;
        end
        else begin
            done_encry_exp <= 1'b0;
        end
    end 
    */
    
    //assign done_encry_exp = ready_mod_mul ? 1'b0 : (done_1 & done_2) ? 1'b1 : done_encry_exp;
    // assign done_encry_exp = ready_mod_mul ? 1'b0 : (done_1 & done_2) ? 1'b1 : 1'b0;

    assign done_encry_exp = ready_mod_mul ? 1'b0 : (done_1 & done_2) ;

    rsa4k #(
        .RSA_WIDTH(RSA_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .DATA_NUMBER(DATA_NUMBER)
    )
    rsa4k_0
    (
        .clk(clk),
        .rst_n(rst_n),
        .go(go_rsa4k_0),
        .message(message_rsa4k_0),
        .exponent(exponent_rsa4k_0),
        .modulus(modulus_rsa4k_0),
        .cypher(cypher_rsa4k_0),
        .mod_inv(mod_inv_x),
        .done(done_rsa4k_0)
    );

    multiply multiply_u(
        .clk(clk),
        .rst_n(rst_n),
        .mult_begin(go_mult),
        .mult_op1(n),
        .mult_op2(m),
        .product(mult_product),
        .mult_end(done_mult)

    );

    DIVU divu_u
    (
        .dividend(num_A),
        .divisor(n),
        .start(ready_flag),
        .clk(clk),
        .rst_n(rst_n),
        .q(shang),
        .r(yushu),
        .valid(valid_divu)
    );


    montgomery montgomery_u
    (
        .mpand(mpand),
        .mplier(mplier),
        .modulus(modulus_mod_mul),
        .clk(clk),
        .rst_n(rst_n),
        .ds(start_flag),
        .ready(ready_mod_mul),
        .product(result_mod_mul)

    );





endmodule