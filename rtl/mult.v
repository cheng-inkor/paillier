`timescale 1ns / 1ps
module multiply(              // 乘法�?
    input         clk,        // 时钟
    input         rst_n,
    input         mult_begin, // 乘法�?始信�?
    input  [4095:0] mult_op1,   // 乘法源操作数1
    input  [4095:0] mult_op2,   // 乘法源操作数2
    output [8191:0] product,    // 乘积
    output        mult_end   // 乘法结束信号
);
    //乘法正在运算信号和结束信�?
    reg mult_valid;
    reg  [4095:0] multiplier;
    
    assign mult_end = mult_valid & ~(|multiplier); //乘法结束信号：乘数全0
    always @(posedge clk or negedge rst_n)   //�?
    begin
        if(!rst_n) begin
            mult_valid <= 1'b0;
        end
        else if (!mult_begin || mult_end)    //如果没有�?始或者已经结束了
        begin
            mult_valid <= 1'b0;     //mult_valid 赋�?�成0，说明现在没有进行有效的乘法运算
        end
        else
        begin
            mult_valid <= 1'b1;
       //     test <= 1'b1;
        end
    end

    //两个源操作取绝对值，正数的绝对�?�为其本身，负数的绝对�?�为取反�?1
    wire        op1_sign;      //操作�?1的符号位
    wire        op2_sign;      //操作�?2的符号位
    wire [4095:0] op1_absolute;  //操作�?1的绝对�??
    wire [4095:0] op2_absolute;  //操作�?2的绝对�??
    assign op1_sign = mult_op1[4095];
    assign op2_sign = mult_op2[4095];
    assign op1_absolute = op1_sign ? (~mult_op1+1) : mult_op1;
    assign op2_absolute = op2_sign ? (~mult_op2+1) : mult_op2;
    //加载被乘数，运算时每次左移一�?
    reg  [8191:0] multiplicand;
    always @ (posedge clk or negedge rst_n)  //�?
    begin
        if(!rst_n) begin
            multiplicand <= 8192'd0;
        end
        else if (mult_valid)
        begin    // 如果正在进行乘法，则被乘数每时钟左移�?�?
            multiplicand <= {multiplicand[8190:0],1'b0};  //被乘数x每次左移�?位�??
        end
        else if (mult_begin) 
        begin   // 乘法�?始，加载被乘数，为乘�?1的绝对�??
            multiplicand <= {4096'd0,op1_absolute};
        end
    end

    //加载乘数，运算时每次右移�?位，相当于y

    
    always @ (posedge clk or negedge rst_n)  //�?
    begin 
        if(!rst_n) begin
            multiplier <= 4096'd0;
        end
        else if(mult_valid)
        begin       //如果正在进行乘法，则乘数每时钟右移一�?
            multiplier <= {1'b0,multiplier[4095:1]}; //相当于乘数y右移�?�?
        end
        else if(mult_begin)
        begin   //乘法�?始，加载乘数，为乘数2的绝对�??
            multiplier <= op2_absolute;
        end

    end
    // 部分积：乘数末位�?1，由被乘数左移得到；乘数末位�?0，部分积�?0
    wire [8191:0] partial_product;
    assign partial_product = multiplier[0] ? multiplicand:8192'd0;        //若此时y的最低位�?1，则把x赋�?�给部分积partial_product，否则把0赋�?�给partial_product
    
    //累加�?
    reg [8191:0] product_temp;		//临时结果
    always @ (posedge clk or negedge rst_n)  //�?//clk信号�?0变为1时，�?发此段语句的执行，但语句的执行需要时�?
    begin
        if(!rst_n) begin
            product_temp <= 8192'd0;
        end
        else if (mult_valid)
        begin
            product_temp <= product_temp + partial_product;
        end      
        else if (mult_begin)
        begin
        product_temp <= 8192'd0;
        end
     end
     
    //乘法结果的符号位和乘法结�?
    reg product_sign;	//乘积结果的符�?
    always @ (posedge clk or negedge rst_n)  // 乘积�?
    begin
        if(!rst_n) begin
            product_sign <= 1'b0;
        end
        else if (mult_valid)
        begin
              product_sign <= op1_sign ^ op2_sign;
        end
    end 
    //若乘法结果为负数，则�?要对结果取反+1
    
    assign product = product_sign ? (~product_temp+1) : product_temp;
endmodule
