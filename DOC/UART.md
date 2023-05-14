# UART
通用异步收发器(Universal ASynchronous Receiver/Transmitter)，数据在内部做传串并转换。

数据层协议通用，按照物理层或者电器层的不同分为，RS232、RS449、RS423、RS422、RS485

## Baud Rate
通信的收发设备统一的数据接收和传输的速率。单位bps
常见：300、1200、2400、9600、19200、115200bps
## Bit 
一般的数据传输位有5、6、7、8位
## Parity 
一位，可选
## Stop 
一位

## SPEC
|UART.v v0.1        |
|------------------ |
|波特率:随输入时钟而定(每个数据位都是16个Cycle)|    
|数据位:8bit         |
|奇偶检验位:1bit      |
|停止位:1bit         |

## 仿真波形
 ![UART](/DOC/assets/UART.bmp)

## FPGA
### problem
FPGA时钟采用外部晶振时钟50MHz, 实际波特率算下来是3125000bps，上位机在这个区间可供选择的有3686400bps，所以在传输一段时间会有数据出错的问题，符合预期。

### solution
可以用PLL分出更精细的时钟是数据接收更精准。