# Serial-debug-unit
## 小组成员

PB21111706 常文正

PB21111708 刘睿博

PB21111742 王以勒

PB21111725 于硕

PB21111696 闫泽轩

## CPU算法竞赛班Lab2

SDU：Serial Debug Unit，通过串口对CPU进行调试

控制运行方式：单周期或者支持断点的连续运行

查看运行状态：数据通路状态、寄存器堆和存储器内容

加载存储器：初始化指令存储器和数据存储器

![image](https://user-images.githubusercontent.com/99136908/226158541-9fdbce0b-1d39-4fbf-ae6d-975f1e97737e.png)
RX：Receiver，接收器

DCP：Debug Command Processing，调试命令处理

TX：Transmitter，发送器 

RX：接收器

串行输入数据转换为并行数据输出

rxd：1位串行接收数据

d_rx：8位并行接收数据

vld_rx：接收有效 (valid)

rdy_rx：接收准备好 (ready)

TX：发送器

并行输入数据转换为串行数据输出

d_tx：8位并行发送数据

vld_tx：发送有效

rdy_tx：发送准备好

txd： 1位串行发送数据
