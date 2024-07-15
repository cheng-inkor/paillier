module mod_mul#(
    parameter   RSA_WIDTH = 4096,
    parameter   DATA_WIDTH = 128,
    parameter   DATA_NUMBER = 32
)
(
    input   clk,
    input   rst_n,
    input   done_x,
    input   done_y,
    input   [(RSA_WIDTH - 1) : 0]   data_x,
    input   [(RSA_WIDTH - 1) : 0]   data_y,
    input   [(RSA_WIDTH - 1) : 0]   modulus, 
    input   [(DATA_WIDTH - 1) : 0 ] mod_inv,
    output  reg  [(RSA_WIDTH - 1) : 0]  result_iddmm,
    output  reg                         done

);

    wire  [DATA_WIDTH-1:0]                          wr_x;
    wire  [DATA_WIDTH-1:0]                          wr_y;
    wire  [DATA_WIDTH-1:0]                          wr_m;
    reg   [DATA_WIDTH-1:0]                          wr_m1              = 0 ;//m1=(-1*(mod_inv(m,2**K)))%2**K

    reg                                             task_req           = 0 ;
    reg                                             wr_ena             = 0 ;
    reg   [$clog2(DATA_NUMBER)-1:0]                 wr_addr            = 0 ;
    wire                                            res_val;
    wire  [DATA_WIDTH-1:0]                          res;
    wire                                            task_end;
    reg                                             done_1;
    reg                                             done_2;
    reg   [(RSA_WIDTH - 1) : 0]                     data_1;
    reg   [(RSA_WIDTH - 1) : 0]                     data_2;




    parameter MULT_METHOD  = "TRADITION" ;// | COMMON ? | TRADITION 10| VEDIC8    8|
    parameter ADD1_METHOD  = "3-2_PIPE1" ;// | COMMON ? | 3-2_PIPE1 1 | 3-2_PIPE2 2|
    parameter ADD2_METHOD  = "3-2_DELAY2";// | COMMON   | 3-2_DELAY2  |            |
    
    parameter MULT_LATENCY = MULT_METHOD == "COMMON"      ?0 :
                             MULT_METHOD == "TRADITION"   ?10:
                             MULT_METHOD == "VEDIC8"      ?8 :'dx;
    parameter ADD1_LATENCY = ADD1_METHOD == "COMMON"      ?0 :
                             ADD1_METHOD == "3-2_PIPE1"   ?1 : 
                             ADD1_METHOD == "3-2_PIPE2"   ?2 :'dx;

    initial begin
        if (ADD2_METHOD == "3-2_DELAY2") begin
            if (MULT_LATENCY*3+ADD1_LATENCY>=63) begin
                $display("\nCaution: pipeline failed(%0d)\n",MULT_LATENCY*3+ADD1_LATENCY);
                $stop;
            end
        end else if(ADD2_METHOD == "COMMON")begin
            if (MULT_LATENCY*3+ADD1_LATENCY>=31) begin
                $display("\nCaution: pipeline failed(%0d)\n",MULT_LATENCY*3+ADD1_LATENCY);
                $stop;
            end
        end
    end

    assign wr_x = data_1[wr_addr*DATA_WIDTH +: DATA_WIDTH] ;
    assign wr_y = data_2[wr_addr*DATA_WIDTH +: DATA_WIDTH] ;
    assign wr_m = modulus[wr_addr*DATA_WIDTH +: DATA_WIDTH] ;

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            done_1 <= 1'b0;
            done_2 <= 1'b0;
            data_1 <= 4096'd0;
            data_2 <= 4096'd0;
        end else if (!task_req) begin
            if(done_x) begin
                done_1 <= 1'b1;
                data_1 <= data_x;
            end else if(done_y) begin
                done_2 <= 1'b1;
                data_2 <= data_y;
            end 
        end else begin
            done_1 <= done_1;
            done_2 <= done_2;
            data_1 <= data_1;
            data_2 <= data_2;
            if(task_end) begin
                done_1 <= 1'b0;
                done_2 <= 1'b0;
                data_1 <= 4096'd0;
                data_2 <= 4096'd0;
            end
        end
    end


    mmp_iddmm_sp #(
    .MULT_METHOD  ( MULT_METHOD  ),
    .ADD1_METHOD  ( ADD1_METHOD  ),
    .ADD2_METHOD  ( ADD2_METHOD  ),
    .MULT_LATENCY ( MULT_LATENCY ),        
    .ADD1_LATENCY ( ADD1_LATENCY ) 
    )mmp_iddmm_sp_0 (
    .clk                     ( clk                                  ),
    .rst_n                   ( rst_n                                ),

    .wr_ena                  ( wr_ena                               ),
    .wr_addr                 ( wr_addr    [$clog2(DATA_NUMBER)-1:0] ),
    .wr_x                    ( wr_x       [DATA_WIDTH-1:0]          ),
    .wr_y                    ( wr_y       [DATA_WIDTH-1:0]          ),
    .wr_m                    ( wr_m       [DATA_WIDTH-1:0]          ),
    .wr_m1                   ( wr_m1      [DATA_WIDTH-1:0]          ),

    .task_req                ( task_req                             ),
    .task_end                ( task_end                             ),
    .task_grant              ( res_val                              ),
    .task_res                ( res        [DATA_WIDTH-1:0]          )
    );


    reg [3:0] st = 0;

    always@(posedge clk)begin
        if (res_val) begin
            result_iddmm <= {res,result_iddmm[DATA_WIDTH*DATA_NUMBER-1:DATA_WIDTH]};
        end
    end     

    always@(posedge clk)begin
        case (st)
            0:begin
                if (task_req) begin     // 暂时感觉没问题，后续再看看
                    st      <=  st+1;
                    wr_ena  <=  1;
                    wr_addr <=  1'd0;
                    wr_m1   <=  mod_inv;
                end
                end 
            1:begin
                if (wr_addr == DATA_NUMBER-1) begin
                    wr_ena  <=  0;
                    st      <=  2;
                end else begin
                    wr_addr <= wr_addr+1'd1;
                end
                end 
            2:begin
                st  <=  0;
                end 
            default:; 
        endcase
    end
    
    always@(posedge clk)begin
        if (task_end) begin
        //    $display("[mmp_iddmm_sp_tb.v]result_iddmm: \n0x%x",result_iddmm);
            done <= 1'b1;
        end
        else begin
            done <= 1'b0;
        end
    end 

    always@(posedge clk)begin
        if (done_1 & done_2) begin
            task_req <= 1'b1;
        end
        else begin
            task_req <= 1'b0;
        end
    end 


endmodule