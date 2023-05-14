`timescale 1ns/1ps
module TB_TOP();

logic Clk;
logic Rst_n;
logic TX;
logic RX;


initial begin
     Clk = 1'b0; 
     forever begin
        #5 Clk = ~Clk;  //10ns //10MHz
     end
end

initial begin
    Rst_n = 1'b0;
    #10  Rst_n = 1'b1;
end

initial begin
    TX = 1'b1;
    #95 TX = 1'b0;
    #160 TX = 1'b1;
    #160 TX = 1'b0;
    #160 TX = 1'b1;
    #160 TX = 1'b0;
    #160 TX = 1'b1;
    #160 TX = 1'b0;
    #160 TX = 1'b1;
    #160 TX = 1'b0;
	 #160 TX = 1'b0;
    #160 TX = 1'b1;
	 #5000 $finish();
end

UART DUT(Clk, Rst_n, 1'b0, RX, TX);

endmodule


