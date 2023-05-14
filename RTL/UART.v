module UART (
    input  wire         Clk  ,
    input  wire         Rst_n,

    output wire         TX   ,
    input  wire         RX   ); 

    wire [7:0] Data;
    wire load_pluse;

    UART_RX u_uart_rx   (
        .Clk            (Clk        ),
        .Rst_n          (Rst_n      ),
        .Clear          (1'b0       ),

        .RX             (RX         ),
        .OutData        (Data       ),
        .LoadPluse      (load_pluse ));

    UART_TX u_uart_tx   (
        .Clk            (Clk        ),
        .Rst_n          (Rst_n      ),
        .Clear          (1'b0       ),
        
        .TX             (TX         ),
        .InData         (Data       ),
        .LoadPluse      (load_pluse ));

endmodule   