module mult_tb();
    reg                  clk;
    reg                  rst_n;
    reg                  mult_begin;
    reg     [4095:0]     mult_op1;
    reg     [4095:0]     mult_op2;
    wire    [8191:0]     product;
    wire                 mult_end;

    initial begin

        $dumpfile("rsa4k.vcd");
  		$dumpvars(0);

        clk = 0;

        #10
        rst_n = 0;
        #10
        rst_n = 1;
        mult_begin = 0;
        $display("Test Case begin: 1. mult ");
        mult_op1 = 4096'd225;
        mult_op2 = 4096'd320;
        mult_begin = 1;
        #10
        wait(mult_end);
        $display("result: \n0x%x",product);

        $finish;

    end


    always begin
        #5 clk = ~clk;
    end

    multiply multiply_0 (
        .clk(clk),
        .rst_n(rst_n),
        .mult_begin(mult_begin),
        .mult_op1(mult_op1),
        .mult_op2(mult_op2),
        .product(product),
        .mult_end(mult_end)
    );


endmodule