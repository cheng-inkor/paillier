`timescale 1ns/1ps
`include "../rtl/_parameter.v"

module paillier_block_latency_test #(
    parameter   RSA_WIDTH = 4096,
    parameter   DATA_WIDTH = 128,
    parameter   DATA_NUMBER = 32
    
)
(
    input                              clk,
    input                              rst_n,
//  input                              go,
    input       [(DATA_WIDTH - 1) : 0] number_1,
    input       [(DATA_WIDTH - 1) : 0] number_2,
    input       [3:0]                  state,
    output  wire                       output_start,
    output  reg                        done,
    output  reg [(DATA_WIDTH - 1) : 0] result
);
    localparam encry = 4'b0001;
    localparam decry = 4'b0010;
    localparam homo_add = 4'b0100;
    localparam homo_mul = 4'b1000;

    localparam n = 4096'd209;
    localparam exp_n = 4096'd43681;
    localparam g = 4096'd15461;
    localparam lambda = 4096'd90;
    localparam mu = 4096'd72;

    reg   [(RSA_WIDTH - 1) : 0]  reg_m;
    reg   [(RSA_WIDTH - 1) : 0]  reg_r;
    reg   [(RSA_WIDTH - 1) : 0]  reg_c;
    reg   [(RSA_WIDTH - 1) : 0]  reg_c1;
    reg   [(RSA_WIDTH - 1) : 0]  reg_c2;
    reg                          data_done;
    reg                          output_signal;
    reg   [5:0]                  i;
    reg   [5:0]                  j;
    wire   [(RSA_WIDTH - 1) : 0]  reg_result;
    wire   [(RSA_WIDTH - 1) : 0]  cal_result;   

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            reg_m   <= 4096'd0;
            reg_r   <= 4096'd0;
            reg_c   <= 4096'd0;
            reg_c1  <= 4096'd0;
            reg_c2  <= 4096'd0;
            data_done <= 1'b0;
            i         <= 6'b0;
        end
        else begin

            if(state == encry) begin
               
                if(i == DATA_NUMBER) begin
                    data_done <= 1'b1;
                    if(data_done) begin
                        reg_m <= reg_m;
                        reg_r <= reg_r;
                        if(done == 1'b1) begin
                            data_done <= 1'b0;
                            i <= 6'b0;
                            reg_m <= 4096'd0;
                            reg_r <= 4096'd0;
                        end
                    end
                end
                else begin
                
                    reg_m [DATA_WIDTH*i+ (DATA_WIDTH-1) -: DATA_WIDTH] <= number_1;
                    reg_r [DATA_WIDTH*i+ (DATA_WIDTH-1) -: DATA_WIDTH] <= number_2;
                
                    i <= i + 1;
                end
            end
            else if(state == decry) begin
  
                if(i == DATA_NUMBER) begin
                    data_done <= 1'b1;
                    if(data_done)  begin
                        reg_c <= reg_c;
                        if(done == 1'b1) begin
                            data_done <= 1'b0;
                            i <= 6'b0;
                            reg_c <= 4096'd0;
                        end
                    end
                end 
                else begin
                    reg_c [DATA_WIDTH*i+ (DATA_WIDTH-1) -: DATA_WIDTH] <= number_1;
   
                    i <= i + 1;
                end                          
            end
            else if(state == homo_add) begin

                if(i == DATA_NUMBER) begin
                    data_done <= 1'b1;
                    if(data_done) begin
                        reg_c1 <= reg_c1;
                        reg_c2 <= reg_c2;
                        if(done == 1'b1) begin
                            data_done <= 1'b0;
                            i <= 6'b0;
                            reg_c1 <= 4096'd0;
                            reg_c2 <= 4096'd0;
                        end
                    end
                end 
                else begin
                
                    reg_c1 [DATA_WIDTH*i+ (DATA_WIDTH-1) -: DATA_WIDTH] <= number_1;
                    reg_c2 [DATA_WIDTH*i+ (DATA_WIDTH-1) -: DATA_WIDTH] <= number_2;

                    i <= i + 1;                
                end               
            end
            else if(state == homo_mul) begin

                if(i == DATA_NUMBER) begin
                    data_done <= 1'b1;
                    if(data_done) begin
                    reg_m <= reg_m;
                    reg_c <= reg_c;
                        if(done == 1'b1) begin
                            data_done <= 1'b0;
                            i <= 6'b0;
                            reg_m <= 4096'd0;
                            reg_c <= 4096'd0;
                        end
                    end
                end
                else begin
                    reg_m [DATA_WIDTH*i+ (DATA_WIDTH-1) -: DATA_WIDTH] <= number_1;
                    reg_c [DATA_WIDTH*i+ (DATA_WIDTH-1) -: DATA_WIDTH] <= number_2;

                    i <= i + 1;                
                end                
            end
        end
    end

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            output_signal <= 0;
        end 
        else begin
            if(output_start == 1'b1) begin
              output_signal <= 1'b1;
            end
            else begin
              if(j == DATA_NUMBER) begin
                output_signal <= 1'b0;
              end
                output_signal <= output_signal;
            end
        end
    end

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            done <= 0;
            result <= 128'd0;
            j = 6'd0;
        end 
        else begin
             done <= 0;   // using this when done signal needs to be kept only 1 clk;
            if(output_signal == 1'b1) begin
                if(j == DATA_NUMBER) begin
                    j = 6'd0;
                    done <= 1'b1;
                end
                else begin
                
                    result <= reg_result[DATA_WIDTH*j+ (DATA_WIDTH-1) -: DATA_WIDTH];

                    j <= j + 1;                
                end
            end
        end
    end

    paillier_demo_overall_top #(
        .RSA_WIDTH(RSA_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .DATA_NUMBER(DATA_NUMBER)
    )
    paillier_demo_overall_top_u (
        .clk(clk),
        .rst_n(rst_n),
        .go(data_done),
        .m(reg_m),
        .r(reg_r),
        .c(reg_c),
        .c1(reg_c1),
        .c2(reg_c2),
        .n(n),
        .exp_n(exp_n),
        .g(g),
        .lambda(lambda),
        .mu(mu),
        .state(state),
        .result(reg_result),
        .done(output_start)
    );


endmodule