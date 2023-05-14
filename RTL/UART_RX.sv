module UART_RX(
    input  wire         Clk         ,
    input  wire         Rst_n       ,
    input  wire         Clear       ,

    input  wire         RX          ,
    output wire [7:0]   OutData     ,
    output reg          LoadPluse   );
    
    //参考Designware的设计，每个bit位都是16个CYCLE，波特率取决于CORE时钟，只能说妙啊

    //状态机定义
    localparam IDLE   = 3'd0;
    localparam START  = 3'd1;
    localparam DATA   = 3'd2;
    localparam PARITY = 3'd3;
    localparam STOP   = 3'd4;

    reg [2:0] cur_state;
    reg [2:0] nxt_state;

    reg  start_reg;
    wire start_pluse;
    wire end_pluse;
    reg  [3:0] bit_cnt; 
    reg  package_en;
    wire sample_en;
    reg  [2:0] date_cnt;
    wire date_done;
    wire transmit_pluse;
	wire glitch_check;

    reg [1:0][7:0] memory; //[0]:receive [1]:transmit

    assign sample_en = bit_cnt == 4'h7; //sample data in the middle of bit_cnt 
    assign bit_end = bit_cnt == 4'hf;
    assign date_done = date_cnt == 3'h7;

    //CNT计数
    always @(posedge Clk or negedge Rst_n) begin
        if(!Rst_n)
            bit_cnt[3:0] <= 4'b0;
        else if(Clear || glitch_check)
            bit_cnt <= 4'b0;
        else if(package_en)
            bit_cnt <= bit_cnt + 1'b1;
    end

    always @(posedge Clk or negedge Rst_n) begin
        if(!Rst_n)
            date_cnt <= 3'b0;
        else if(Clear)
            date_cnt <= 3'b0;
        else if(cur_state == DATA && bit_end)
            date_cnt <= date_cnt + 1'b1;
    end

    //Start detect
    always @(posedge Clk or negedge Rst_n) begin
        if(!Rst_n)
            start_reg <= 1'b1; 
        else if(Clear)
            start_reg <= 1'b1;
        else if(cur_state == IDLE) //if have a glitch on RX
            start_reg <= RX;
	 end

    assign start_pluse = ~RX & start_reg;
    assign glitch_check = cur_state == IDLE && package_en && sample_en && RX;  

    //generate package_en
    always @(posedge Clk or negedge Rst_n) begin
        if(!Rst_n)
            package_en <= 1'b0;
        else if(Clear)
            package_en <= 1'b0;
        else if(start_pluse)
            package_en <= 1'b1;
        else if(end_pluse || glitch_check)
            package_en <= 1'b0;           
    end 

    //recive state machine
    always @(posedge Clk or negedge Rst_n) begin
        if(!Rst_n)
            cur_state <= IDLE;
        else if(Clear)
            cur_state <= IDLE;
        else
            cur_state <= nxt_state;
    end

    always @(*) begin
        case (cur_state)
            IDLE : if(sample_en && ~RX)
                        nxt_state = START;
                   else
                        nxt_state = IDLE;
            START: if(bit_end)
                        nxt_state = DATA;
                   else
                        nxt_state = START;
            DATA : if(date_done && bit_end)
                        nxt_state = PARITY;
                   else
                        nxt_state = DATA;
            PARITY: if(bit_end)
                        nxt_state = STOP;
                    else
                        nxt_state = PARITY;
            STOP  : if(bit_end)
                        nxt_state = IDLE;
                    else
                        nxt_state = STOP;                     
            default: nxt_state = IDLE;
        endcase
    end
    
    //generate end_pluse
    assign end_pluse = cur_state == STOP && bit_end;

    //generate transmit_pluse
    assign transmit_pluse = cur_state == DATA && bit_cnt == 4'h8 && date_cnt == 3'h7;

    //storage data
    always @(posedge Clk or negedge Rst_n) begin
        if(!Rst_n)
            memory <= 16'b0;
        else if(Clear)
            memory <= 16'b0;
        else if(cur_state == DATA && sample_en)
            memory[0] <={RX, memory[0][7:1]};
        else if(transmit_pluse)
            memory[1] <= memory[0];  
    end

    always @(posedge Clk or negedge Rst_n) begin
        if(!Rst_n)
            LoadPluse <= 1'b0;
        else if(Clear)
            LoadPluse <= 1'b0;
        else
            LoadPluse <= transmit_pluse;
    end

    assign OutData = memory[1];

endmodule

    




      
 



