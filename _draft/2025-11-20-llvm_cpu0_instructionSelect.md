---
title: "LLVM | CPU0 Instruction Selection"
author: Benson Hsu
date: 2025-11-17
category: Jekyll
layout: post
tags: [llvm, optimization]
---

> CPU0 是一個 LLVM 教學用的目標架構，主要用來展示 LLVM 從中間表示（IR）到目標機器碼的轉換過程。在這篇文章中，我們將探討 LLVM 如何針對 CPU0 架構進行指令選擇（Instruction Selection），以及相關的優化技術。
{: .block-tip }

> [Tutorial: Creating an LLVM Backend for the Cpu0 Architecture]

[Tutorial: Creating an LLVM Backend for the Cpu0 Architecture]: https://jonathan2251.github.io/lbd/index.html#

### 1.1 Introduction

在 LLVM IR 之前，不管什麼語言都將轉換成 LLVM IR，然後再 LLVM IR 階段會進行與目標無關的最佳化，這些階段的輸入輸出都是 LLVM IR。在進入 Codegen 階段之後，就開始目標相關的最佳化。這個最佳化的過程我們可以簡單分成幾個步驟:

1.  Instruction Selection
    -   LLVM IR 經由 Lowering 轉換成 SelectionDAG
    -   對於 IR 中的每個 Basic Block 都會產生一個 SelectionDAG
2.  Instruction Scheduling
    -   在 2 到 3 的階段 SelectionDAG 會被轉換成 MachineInstr
    -   在此階段 Physical Register 仍未分配
3.  Register Allocation
    -   將 Virtual Register 分配到 Physical Register
4.  Instruction Scheduling (Again)
    -   在 Register Allocation 後，會再次進行 Instruction Scheduling
    -   此處才能根據 Pipeline 的特性來進行 Scheduling
5.  Code Emission
    -   此處將 MachineInstr 轉換 MCInst
    -   最後將 MCInst 轉換成 Assembly Code 或 Machine Code

![](/image/2025/11-20-llvm_cpu0_instructionSelect/1.png)

**CPU0**

CPU0 是一個 32bit 的 RISC 架構，具有簡單的指令集和固定長度的指令格式。詳細的 CPU0 架構規格可以參考 [CPU0 Architecture]。主要有三種指令類型，分別是 R-Type、I-Type 和 J-Type 指令。

-   L-type instructions: Primarily used for memory operations.
-   A-type instructions: Designed for arithmetic operations.
-   J-type instructions: Typically used for altering control flow (e.g., jumps).

[CPU0 Architecture]: https://jonathan2251.github.io/lbd/llvmstructure.html

**LLVM’s Target Description Files: .td**

> [TableGen Overview] 官方的文件介紹了 TableGen 的基本概念

[TableGen Overview]: https://llvm.org/docs/TableGen/

LLVM 使用 TableGen (.td) 文件來描述目標架構的指令集、寄存器和其他相關資訊。這些文件定義了 CPU0 的指令格式、操作數類型以及指令的語義。這些描述檔案通常放在 LLVM 的目標目錄下，在 `llvm-project/llvm/lib/Target` 下，我們可以找到這些不同目標的檔案，如 `RISCV`, `ARM`, `X86` 等等。實際上要在 LLVM 中新增一個目標架構，主要就是撰寫這些 TableGen 檔案。

> ##### Last Edit  
> 11-14-2025 00:42
{: .block-warning }