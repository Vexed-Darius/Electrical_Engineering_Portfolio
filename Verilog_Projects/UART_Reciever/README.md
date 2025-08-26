
# UART Receiver

## Description
Implemented a UART receiver on an FPGA to reliably capture serial data from a microcontroller.

## Objective
Design a Verilog module capable of receiving 8-bit serial data at 9600 baud and displaying it on 7-segment displays.

## Tools & Technology
- Verilog
- Quartus Prime FPGA software
- D10-Lite FPGA board

## Highlights
- Modular design: separate datapath and control units
- Tested with simulation waveforms and hardware implementation
- Learned synchronization and timing considerations for UART communication

## Files
- `UART_RCVR.v` → main Verilog module  
- `UART_RCVR_tb.v` → testbench  
- `UART_RCVR tb output B5.png` → screenshot of simulation
- `UART_RCVR tb output FF.png` → screenshot of simulation  
- `videos/uart_demo.mp4` → demo of hardware

## Simulation
![UART Waveform](simulation_waveform.png)
