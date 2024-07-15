////////////////////////////////////////////////////////////////////////////////
// File:        rsa4k.v
// Description: Top level test bench to test RSA 4096bits
// Author:      Aruna Jayasena
// Date:        March 17, 2024
// Version:     1.0
// Revision:    -
// Company:     archfx.github.io
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
`include "../rtl/_parameter.v"

module rsa4k#(
    parameter   RSA_WIDTH = 4096,
    parameter   DATA_WIDTH = 128,
    parameter   DATA_NUMBER = 32
)
(
    input clk,
    input rst_n,
    input go,  
	input [(RSA_WIDTH - 1):0]  message,
	input [(RSA_WIDTH - 1):0]  exponent,
	input [(RSA_WIDTH - 1):0]  modulus, 
	output reg [(RSA_WIDTH  - 1):0] cypher,
    output reg [(DATA_WIDTH - 1):0] mod_inv,
    output reg done
);
    localparam   COUNTER_NUM = $clog2(DATA_NUMBER);

    reg [DATA_WIDTH - 1 : 0] m_buf;
    reg [DATA_WIDTH - 1 : 0] e_buf;
    reg [DATA_WIDTH - 1 : 0] n_buf;
	reg [DATA_WIDTH - 1 : 0] r_buf;
    reg [DATA_WIDTH - 1 : 0] t_buf;
    reg startInput;
    reg startCompute;
    reg getResult;
    wire [DATA_WIDTH - 1 : 0] res_out;
    wire [4 : 0] exp_state;
    wire [3 : 0] state;

    //parameter [15:0] width  = 4096;
    
    reg [(RSA_WIDTH - 1):0] r;
	reg [(RSA_WIDTH - 1):0] t;
	reg [DATA_WIDTH - 1:0] nprime0;
	reg [DATA_WIDTH - 1:0] modulo_inv;
    reg [COUNTER_NUM + 1 : 0] counter;

    localparam COMPLETE = 9;
    reg [2:0] buf_state;
    localparam IDLE = 0, GO = 1, SEND_INPUT = 2, READ_OUTPUT = 3, CALC_N0 = 6;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            counter <= 0;
            done <= 0;
            buf_state <= IDLE;
            startInput <= 0;
            startCompute <= 0;
            getResult <= 0;
            m_buf <= `DATA_WIDTH'h0000000000000000;
            e_buf <= `DATA_WIDTH'h0000000000000000;
            n_buf <= `DATA_WIDTH'h0000000000000000;
            r_buf <= `DATA_WIDTH'h0000000000000000;
            t_buf <= `DATA_WIDTH'h0000000000000000;
            nprime0 <= `DATA_WIDTH'h0000000000000000;
            done <= 0;
            r <= 4096'd16300;
            t <= 4096'd22158;     
            modulo_inv <= 128'ha3624110af71eff417535238282e469f;  
        end else begin
            case (buf_state)
                IDLE: begin

                    if(go) begin
                        counter <= 0;
                        startInput <= 0;
                        // buf_state <= SEND_INPUT;
                        done <= 0;
                        getResult <= 0;
                        startCompute <= 0;
                        buf_state <= CALC_N0;
                    end

                    if (exp_state == COMPLETE) begin
                        counter <= 0;
                        buf_state <= READ_OUTPUT;
                        // startCompute <= 1;          
                    end
                
                end

                CALC_N0: begin

                        buf_state <= SEND_INPUT;
                        startInput <= 1;
                        // startCompute <= 1;
                        counter <= 0;
                        nprime0 <= modulo_inv;

                end

                SEND_INPUT: begin
                    m_buf <= message[ ((counter) * `DATA_WIDTH) +: `DATA_WIDTH ];
                    e_buf <= exponent[ ((counter) * `DATA_WIDTH) +: `DATA_WIDTH ];
                    n_buf <= modulus[ ((counter) * `DATA_WIDTH) +: `DATA_WIDTH ];
                    r_buf <= r[ ((counter) * `DATA_WIDTH) +: `DATA_WIDTH ];
                    t_buf <= t[ ((counter) * `DATA_WIDTH) +: `DATA_WIDTH ];
                    counter <= counter +1;

                    if (counter == DATA_NUMBER) begin
                        buf_state <= IDLE;
                        startCompute <= 1;
                        counter <=  0;
                        getResult <= 1;
                        r <= t;
                        t <= r;
                    end
                end

                READ_OUTPUT: begin
                    cypher [ ((counter-1) * `DATA_WIDTH) +: `DATA_WIDTH ]  <= res_out;
                    counter <= counter +1;
                    // $display("Read output Ctr : %d", counter);
                    // $display("Read Input Ctr : %d c_buf: %d", counter, res_out);
                    if (counter == DATA_NUMBER) begin
                        buf_state<= IDLE;
                        // startCompute <= 1;
                        counter <=  0;
                        // getResult <= 1;
                        mod_inv <= modulo_inv;
                        done <=1;
                        buf_state<= IDLE;
                    end
                end

                default: begin
                    buf_state<= IDLE;
                end
            endcase
        end
	end

	ModExp #(
        .DATA_WIDTH(DATA_WIDTH),
        .DATA_NUMBER(DATA_NUMBER)
    )
    modexp0(
		.clk(clk), .rst_n(rst_n), .m_buf(m_buf), .e_buf(e_buf),  .n_buf(n_buf), .r_buf(r_buf), .t_buf(t_buf), .nprime0(nprime0),
		.startInput(startInput), .startCompute(startCompute), .getResult(getResult), 
		.exp_state(exp_state), .state(state), .res_out(res_out)
	);
    
endmodule 