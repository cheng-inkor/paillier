`timescale 1ns/1ps

`include "../rtl/_parameter.v"

module paillier_demo_top_tb ();
    reg clk;
    reg rst_n;
    parameter [15:0] width  = 4096;
    reg [(width - 1):0] c, mu, n, exp_n, lambda;
    reg go;
    wire done;
    wire [(width - 1):0] result; 

    initial begin

        $dumpfile("rsa4k.vcd");
  		$dumpvars(0);

        clk = 0;

        #10
        rst_n = 0;
        #10
        rst_n = 1;
        go = 0;

        #10
        $display("Test Case begin: 1. simple one to test ");
        c = 4096'd32948;
        lambda = 4096'd90;
        n = 4096'd209;
        exp_n = 4096'd43681;
        mu = 4096'd153;

        go = 1;
        #10
        wait(done);
        $display("[paillier_demo_top_tb.v]result: \n0x%x",result);

        $finish;

    end


    always begin
        #5 clk = ~clk;
    end

    paillier_demo_decry_top#(
        .RSA_WIDTH(4096),
        .DATA_WIDTH(128),
        .DATA_NUMBER(32)
    ) 
    paillier_demo_decry_top_u(
        .clk(clk),
        .rst_n(rst_n),
        .go(go),
        .c(c),
        .n(n),
        .exp_n(exp_n),
        .lambda(lambda),
        .mu(mu),
        .result(result),
        .done(done)
    );
    
endmodule