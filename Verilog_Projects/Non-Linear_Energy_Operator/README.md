# Non-Linear Energy Operator (NEO) Module

## Description
Implemented a Non-Linear Energy Operator (NEO) in Verilog to process input signals from MATLAB on an FPGA. This operator is commonly used for detecting energy changes in non-linear or non-stationary signals like ECG signals.

## Objective
To design a Verilog module that calculates the NEO for input signals, enabling real-time energy detection and analysis on FPGA hardware.

## Tools & Technology
- MATLAB
- Verilog
- Quartus Prime FPGA software
- DE1-SoC FPGA board

## Highlights
- Modular Verilog design with parameterizable input width  
- Tested using simulation waveforms and hardware implementation  
- Gained experience with signal processing algorithms on FPGA  

## Files
- `NEO.v` → main Verilog module  
- `NEO_tbx.v` → testbench for simulation
- `FINAL_PROJECT_IMP` → MATLAB module for generation noisy gaussian pulses
- `FINAL_PROJECT_OUTPUT` → MATLAB module for plotting inputs/outputs
- `ECG_NEO.png` → screenshot of simulation results  
