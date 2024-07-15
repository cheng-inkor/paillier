`timescale 1ns/1ps

module ModInv_tb();
    reg                          clk;
    reg                          go;
    reg          [4095:0]        n;
    wire  signed [63:0]          modulo_inv;
    wire                         valid;

initial begin
    
    clk = 0;

    #10

    go = 1;

    #10

    n = 4096'h1;

    go = 0;
    #10
    wait(valid);
    $display("First result out");
    $display("Result: 0x%h", modulo_inv);
    go = 1;

    #100
    go = 1;
    #10

    n = 4096'h10;
    go = 0;
    #10
    wait(valid);
    $display("Second result out");
    $display("Result: 0x%h", modulo_inv);
    go = 1;

    #100
    go = 1;
    #10

    n = 4096'h10000;
    go = 0;
    #10
    wait(valid);
    $display("Third result out");
    $display("Result: 0x%h", modulo_inv);
    go = 1;


    $finish;
end




always begin
  #5    clk = ~clk;
end


modInv modInv_u (
    .clk(clk),
    .go(go),
    .n(n),
    .modulo_inv(modulo_inv),
    .valid(valid)
);

endmodule