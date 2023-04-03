# LAB 2 report

**小组成员：**

**PB21111696 闫泽轩	PB21111706 常文正	PB21111708 刘睿博	PB21111742 王以勒	PB21111725 于硕**

## 实验目的与内容

实现一个串行调试单元，与PC端串口进行通信，同时控制CPU的运行，为调试CPU做准备

SDU要实现的功能：

1. 接收PC端的信息
2. 向PC端发送信息
3. 读取CPU的数据通路、寄存器堆、指令存储器和数据存储器
4. 向CPU发送单次或连续的时钟

## 逻辑设计

实验主要分为两大部分DCP和DCP与PC的通信模块RX/TX，RX/TX进行8位的一个字节的数据与串行数据的转换，DCP进行PC发送指令的执行并与CPU进行通信

而DCP整体要支持三大类指令，调试过程中查看CPU相关信息的D I P R，对CPU进行控制的T G H B，以及向CPU加载数据的LD LI

这里我们将D I P R T G B每种指令分别用一个子模块实现，记为DCP_X(X为对应指令），LD LI共同用子模块DCP_L，H功能嵌入G内部实现

整体框图如下：

![image-20230403081012699](.\pic\image-20230403081012699.png)

DCP具体实现状态机如下

```mermaid
graph TD
INIT --> 扫描首字符
扫描首字符 --> L
扫描首字符 --> P
P --> 输出数据通路提示信息
输出数据通路提示信息 --> 打印数据通路
扫描首字符 --> D
D --> 扫描是否有参数
扫描是否有参数 --无参数--> 从上次结束的地址连续输出8个数据/指令
扫描是否有参数 --有参数 --> 从参数地址开始连续输出8个数据/指令
扫描首字符 --> I
I --> 扫描是否有参数
扫描首字符 --> R
R--> 读取寄存器
读取寄存器 --> 输出寄存器编号和数据
输出寄存器编号和数据 --> 读取下一个寄存器
扫描首字符 --> T
T --> 输出一个CPU时钟
输出一个CPU时钟 --> 输出数据通路提示信息
扫描首字符 --> B
B--> 读取断点
读取断点 -- 无断点参数 -->打印断点
读取断点 --有断点参数 --> 查看是否已有该断点
查看是否已有该断点 --无--> 查看是否断点寄存器已满
查看是否已有该断点 --有--> 删除该断点
查看是否断点寄存器已满 --已满-->打印断点
查看是否断点寄存器已满 --未满-->加入断点
加入断点-->打印断点
扫描首字符 --> G
G-->输出连续时钟直到接到'H'或到达断点
输出连续时钟直到接到'H'或到达断点 -->输出数据通路提示信息
L --> 扫描下一个字符
扫描下一个字符 --> LI
扫描下一个字符 --> LD
LI --> we_im=1
LD --> we_dm=1
we_im=1 --> 发送文件
we_dm=1 --> 发送文件
发送文件 --> CPU按字接收直到连续接到回车
CPU按字接收直到连续接到回车 --> 打印FINISH

```



## 部分代码说明

#### DCP整体框架部分

1. 给DCP分为三个状态，INIT、REQ_1ST、WAIT，其中REQ_1ST接收首字符，然后将对应DCP子模块控制信号置为1，DCP主模块进入WAIT等待状态，直到接到子模块发来的finish信号，DCP主模块回到INIT状态再次读取PC端发来的指令

``` verilog
always@(*)
    begin
        if(curr_state == INIT)
            next_state = REQ_1ST;
        else if(curr_state == REQ_1ST)
        begin
            if(ack_rx == 1)
                next_state = WAIT;
            else
                next_state = REQ_1ST;             
        end
        else if(curr_state == WAIT)
        begin
            if(finish) //finish is a signal from child module
                next_state = INIT;
            else
                next_state = WAIT;
        end
        else    
            next_state = curr_state;
    end

always@(posedge clk)
    begin
        if(curr_state == INIT)
        begin
            //do something to initialize
            sel_mode <= INIT;
            req_rx_1ST <= 0;
            type_rx_1ST <= 0;
        end
        else if(curr_state == REQ_1ST)
        begin
            req_rx_1ST <= 1;
            type_rx_1ST <= 0;
            if(ack_rx == 1)
            begin
                if(flag_rx == 0)
                begin
                    case(din_rx[7:0]) //read first character
                        CMD_R: sel_mode <= CMD_R;
                        CMD_D: sel_mode <= CMD_D;
                        CMD_I: sel_mode <= CMD_I;
                        CMD_P: sel_mode <= CMD_P;
                        CMD_T: sel_mode <= CMD_T;
                        CMD_B: sel_mode <= CMD_B;
                        CMD_G: sel_mode <= CMD_G;
                        CMD_L: sel_mode <= CMD_L;
                        default: sel_mode <= FAIL;
                    endcase
                end
                else
                    sel_mode <= FAIL;
            end
            else
                ;
        end
        else if(curr_state == WAIT)
            ;
        else
            ;
    end
```

2. DCP子模块主要有读取CPU数据和向PC发送信息的功能

以DCP_D中读取和发送为例（DCP主模块接到D后进入DCP_D子模块执行后续操作）

1. 这里主要设计DCP_D与SCAN和PRINT模块的交互，DCP_D向SCAN发送req_rx_D请求SCAN模块从PC读取数据，DCP_D接到SCAN的数据后发送ack_rx告知SCAN模块已接收该信息，可以进入下一个状态。
2. D指令只会读取一次PC的参数，并且是按字读取，type_rx可以恒置为1（读字节时为0），而向PC发送信息时既要发送ASCII码（提示信息，按字节发），又要发送数据（32位数据，按字发），因此在不同状态要分别对type_tx_D进行赋值

这里由于DCP_D需要考虑无参数情况（从上次结束的地址开始读取数据），因此要借助寄存器保存结束时读取数据的地址，同时由于要发送8个数据，需要count_DATA寄存器进行计数

``` verilog
always @(posedge clk or negedge rstn) begin
        ...
        
        case (CS)
            ...
            SCAN: begin
                if (~ack_rx) begin
                    req_rx_D <= 1;
                end
                else begin
                    req_rx_D <= 0;
                    if(!flag_rx) 
                    cur_addr <= din_rx;
                    else cur_addr <= last_addr_D;
                end
            end
            ...
            PRINTD: begin
                if (ack_tx) begin
                    req_tx_D <= 0;
                end
                else req_tx_D <= 1;
            end
            ...
 always @(*) begin
        type_tx_D = 1;
        dout_D = 0;
        if (~we) NS = INIT;
        else case(CS)
            INIT: begin
                if(we) NS = SCAN;
            end
            SCAN: begin
                if (~ack_rx) NS = SCAN;

                else NS = PRINT_INF;
            end
            ...
            PRINTD: begin
                type_tx_D = 1;
                dout_D = dout_dm;
                if (~ack_tx) NS = PRINTD;
                else begin
                    if (|count_DATA) begin
                        NS = DATA;
                    end
                    else NS = FINISH;
                end
            end
```









## 仿真结果与分析

DCP子模块仿真示例

DCP_T仿真

由DCP进入DCP_T子模块后，子模块先发送一个clk_cpu脉冲，然后开始打印数据通路，每次先打印提示信息，如图打印"N" "P" "C" "="

然后打印npc的值，通过req_tx_T发送请求，PRINT模块发送完毕后发送ack_tx信号告知DCP子模块信息发送完毕，数据通路打印完毕后输出0d0a（回车换行的ASCII码） 而后将finish信号置为1，子模块任务完成，令主模块从WAIT状态恢复到INIT状态继续读取PC的指令

![QQ截图20230403102406](.\pic\QQ截图20230403102406.png)

![QQ截图20230403102406](.\pic\QQ截图20230403102406.png)

DCP_D仿真

先输出提示字符"D-"，然后输出数据首地址，然后一个状态进行数据读取，一个状态进行数据输出

![QQ截图20230403110735](.\pic\QQ截图20230403110735.png)



## 电路设计与分析

![QQ截图20230403085726](.\pic\QQ截图20230403085726.png)

子模块电路图过于复杂，不做过多展示



![image-20230403090052234](.\pic\image-20230403090052234.png)

WNS为非负数

![image-20230403100834597](.\pic\image-20230403100834597.png)

资源使用情况如上图（包含单周期CPU)

## 测试结果与分析

1. 查看数据寄存器、指令寄存器、设置断点以及执行到断点以及查看数据通路

![QQ截图20230403112803](.\pic\QQ截图20230403112803.png)

2. 消除断点、单步调试

![QQ截图20230403113048](.\pic\QQ截图20230403113048.png)

3. 查看寄存器堆，以及查看最终运行结果，实现从大到小排序

![QQ截图20230403113428](.\pic\QQ截图20230403113428.png)

4. LD LI测试

输入文件内容如下

![QQ截图20230403113553](.\pic\QQ截图20230403113553.png)

成功输入数据存储器和指令存储器

![QQ截图20230403113716](.\pic\QQ截图20230403113716.png)

## 总结

实验难点：

1. valid-ready握手协议的实现，花费了较长时间处理PC串口与DCP的通信
2. 内部模块输入输出信号非常多，容易出现误接、漏接，在always组合逻辑块中易出现漏赋值而出现锁存器（最终通过默认赋值解决）以及多驱动问题
3. 状态机状态较多，不易整体设计（最终采取分模块处理）
4. SDU要实现的调试功能较多，代码量较大，也就带来相当的工作量和debug难度

实验收获：

1. 学习了PC端与开发板的通信过程，对握手协议有了深入了解
2. 将DCP拆解成多个子模块实现，体会到了模块封装的优势
3. 本次实验接入信号非常多，锻炼了在繁杂信号和大量代码中发现bug修复bug的能力，对一些常见warnnig也更加从容应对
4. 温习了状态机的设计