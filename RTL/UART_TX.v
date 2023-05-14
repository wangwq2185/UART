module UART_TX(
    input  wire         Clk         ,
    input  wire         Rst_n       ,
    input  wire         Clear       ,

    output reg          TX          ,
    input  wire [7:0]   InData      ,
    input  wire         LoadPluse   );
    
    //input Clk 10MHz
    //Baud rate 115200bps 
    //date rate 115.2KHz
    //所以每个Bit位可以在10MHZ下保持大约8.68个CYCLE, 取9个CYCLE，会减小波特率
    //参考Designware的设计，每个bit位都是16个CYCLE，波特率取决于CORE时钟，只能说妙啊

    //状态机定义
    localparam IDLE   = 3'd0;
    localparam START  = 3'd1;
    localparam DATA   = 3'd2;
    localparam PARITY = 3'd3;
    localparam STOP   = 3'd4;

    reg [2:0] cur_state;
    reg [2:0] nxt_state;

    wire start_pluse;
    wire end_pluse;
    reg  [3:0] bit_cnt; 
    reg  package_en;
    reg  [2:0] date_cnt;
    wire date_done;
    wire transmit_pluse;
    wire bit_tran_en;
    wire parity_bit;

    assign bit_end = bit_cnt == 4'hf;
    assign date_done = date_cnt == 3'h7;

    //CNT计数
    always @(posedge Clk or negedge Rst_n) begin
        if(!Rst_n)
            bit_cnt <= 4'b0;
        else if(Clear)
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

    assign start_pluse = LoadPluse;

    //generate package_en
    always @(posedge Clk or negedge Rst_n) begin
        if(!Rst_n)
            package_en <= 1'b0;
        else if(Clear)
            package_en <= 1'b0;
        else if(start_pluse)
            package_en <= 1'b1;
        else if(end_pluse)
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
            IDLE : if(start_pluse)
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
    assign bit_tran_en = cur_state == DATA && bit_end;

    //parity check
    assign parity_bit = ^InData;

    //transmit Data
    always @(posedge Clk or negedge Rst_n) begin
        if(!Rst_n)
            TX <= 1'b1;
        else if(Clear)
            TX <= 1'b1;
		  else if(start_pluse)
				TX <= 1'b0;
		  else if(cur_state == START && nxt_state == DATA)
            TX <= InData[0];
        else if(nxt_state == DATA)
            case(date_cnt)
				3'd0 : if(bit_tran_en)
                    TX <= InData[1];
            3'd1 : if(bit_tran_en)
                    TX <= InData[2];
            3'd2 : if(bit_tran_en)
                    TX <= InData[3];
            3'd3 : if(bit_tran_en)
                    TX <= InData[4];
            3'd4 : if(bit_tran_en)
                    TX <= InData[5];
            3'd5 : if(bit_tran_en)
                    TX <= InData[6];
            3'd6 : if(bit_tran_en)
                    TX <= InData[7];                         
            endcase
        else if(nxt_state == PARITY)
            TX <= parity_bit;
        else if(nxt_state == STOP)
            TX <= 1'b1;
        else if(nxt_state == IDLE)
            TX <= 1'b1;
    end

endmodule

    




      
 



