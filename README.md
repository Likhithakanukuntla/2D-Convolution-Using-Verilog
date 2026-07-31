# 2D Convolution Using Verilog

## Overview

This project implements a **2D convolution** in **Verilog HDL** for processing **256×256 grayscale images**. The input image is stored in **Block RAM (BRAM)** from a text file, and convolution is performed using **three BRAM-based line buffers** with a sliding window architecture to minimize memory usage.

The design supports different convolution kernels such as **Edge Detection**, **Blur**, and **3D Shadow Look** filters and was verified using **Xilinx Vivado**.

## Features

- 256 × 256 grayscale image processing
- BRAM-based image storage
- Three line-buffer (BRAM) architecture
- Sliding window convolution
- Supports multiple 3×3 kernels
- Verified using Xilinx Vivado

## Tools Used

- Verilog HDL
- Xilinx Vivado

## Author

**Likhitha Kanukuntla**  
M.Tech – VLSI and Nanoelectronics, IIT Guwahati
