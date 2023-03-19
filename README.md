# Serial-debug-unit
CPU算法竞赛班Lab2
SDU：Serial Debug Unit，通过串口对CPU进行调试
控制运行方式：单周期或者支持断点的连续运行
查看运行状态：数据通路状态、寄存器堆和存储器内容
加载存储器：初始化指令存储器和数据存储器
![image](https://user-images.githubusercontent.com/99136908/226158464-fd0752e0-048d-48d8-923b-1622a9e7a027.png)
![image](https://user-images.githubusercontent.com/99136908/226158480-99481135-2525-4908-8918-1bf99b2ab8b4.png)
RX：Receiver，接收器
DCP：Debug Command Processing，调试命令处理
TX：Transmitter，发送器 
![image](https://user-images.githubusercontent.com/99136908/226158474-d585f4c7-73c4-4173-a4a4-44e4a631f9a0.png)
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
![image](https://user-images.githubusercontent.com/99136908/226158488-d67d2723-f0f0-434d-b622-d473e05d5efe.png)
