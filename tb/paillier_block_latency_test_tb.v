`timescale 1ns/1ps

`include "../rtl/_parameter.v"

module paillier_block_latency_test_tb();
    reg             clk;
    reg             rst_n;
    reg     [127:0] number_1;
    reg     [127:0] number_2;
    reg     [3:0]   state;
    wire            done;
    wire            output_start;
    wire    [127:0] result;

    initial begin
        $dumpfile("rsa4k.vcd");
  		$dumpvars(0);

        clk = 0;

        #200
        rst_n = 0;
        #10
        rst_n = 1;
        
        state = 4'b0000;
        
        #5
        $display("Test Case begin: 1. encry ");
        number_1 = 128'd8;
        number_2 = 128'd3;
        state = 4'b0001;
        
        #10
        number_1 = 128'd0;
        number_2 = 128'd0;

        #10
        wait(output_start);
        $display("[paillier_demo_overall_top_tb.v]result: \n0x%x",result); 
        wait(done);

        clk = 0;

        #10
        rst_n = 0;
        #10
        rst_n = 1;
        
        state = 4'b0000;

        #5
        $display("Test Case begin: 2. decry ");
        number_1 = 128'd33524;
        number_2 = 128'd0;
        state = 4'b0010;
        
        #10
        number_1 = 128'd0;
        number_2 = 128'd0;

        #10
        wait(output_start);
        $display("[paillier_demo_overall_top_tb.v]result: \n0x%x",result);
        wait(done);

        clk = 0;

        #10
        rst_n = 0;
        #10
        rst_n = 1;
        
        state = 4'b0000;

        #5
        $display("Test Case begin: 3. homo add ");
        number_1 = 128'd226;
        number_2 = 128'd3409;
        state = 4'b0100;
        
        #10
        number_1 = 128'd0;
        number_2 = 128'd0;

        #10
        wait(output_start);
        $display("[paillier_demo_overall_top_tb.v]result: \n0x%x",result);
        wait(done);

        clk = 0;

        #10
        rst_n = 0;
        #10
        rst_n = 1;
        
        state = 4'b0000;

        #5
        $display("Test Case begin: 4. homo mul ");
        number_1 = 128'd10;
        number_2 = 128'd226;
        state = 4'b1000;
        
        #10
        number_1 = 128'd0;
        number_2 = 128'd0;

        #10
        wait(output_start);
        $display("[paillier_demo_overall_top_tb.v]result: \n0x%x",result);
        wait(done);

        $finish;
    end


    always begin
        #5 clk = ~clk;
    end

    paillier_block_latency_test 
    paillier_block_latency_test_u
    (
        .clk(clk),
        .rst_n(rst_n),
        .number_1(number_1),
        .number_2(number_2),
        .state(state),
        .output_start(output_start),
        .done(done),
        .result(result)
    );



endmodule