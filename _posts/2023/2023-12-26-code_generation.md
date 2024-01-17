---
title: "Compiler | Code Generation (Unfinished)"
author: Benson Hsu
date: 2023-12-26
category: Jekylls
layout: post
tags: [Compiler]
---

> Compilers course notes from CCU, lecturer Nai-Wei Lin.  
{: .block-tip }

-   **The target machine**
-   **Instruction selection and register allocation**
-   **Basic blocks and flow graphs**
-   A simple code generator
-   Peephole optimization
-   Instruction selector generator
-   **Graph-coloring register allocator**

### The target machine

假設這是一台 Byte-addressable 的機器，每個指令由 4 個 bytes 組成，並且有 n 個 registers，這代表機器的最小尋址單位是 1 byte。

-   Two address instructions(雙地址指令)
    -   opsource, destination
-   Six addressing modes(六種尋址模式)
```
absolute        M           M                       1
register        R           R                       0
indexed         c(R)        c+content(R)            1
ind register    *R          content(R)              0
ind indexed     *c(R)       content(c+content(R))   1
iteral          #c          c                       1
```
上面的表格中，第一欄是尋址模式，第二欄是對應的表示方式，第三欄是對應的實際 bit 大小，最後一欄是對應的位址計算方式會需要幾個 word。

-   M: 使用到記憶體位置需要 1 個 word
-   c: 使用到常數需要 1 個 word

**Example**

```
MOV R0, M       /* 2 words */
MOV 4 (R0), M   /* 3 words */
MOV *R0, M      /* 2 words */
MOV *4 (R0), M  /* 3 words */
MOV #1, R0      /* 2 words */
```

##### 6.1 Instruction Costs

-   一個指令的成本等於 1 加上尋址模式的成本
-   這個成本會跟指令的長度成正比
-   因此最小化指令長度也可以減少指令的執行時間

> 這裡很直覺的，如果一個指令的長度越小，那麼執行的時間也會越短，因為每個指令都需要一個 clock cycle 來執行，所以指令長度越小，執行的時間也會越短。

**Example**

假如有一個 a := b + c 的原始碼，這裡有不同種類的指令可以選擇:

![](../assets/image/2023/12-26-code_generation/1.png){:height="100%" width="100%"}

1.  搬移到 Reg 再運算，成本是 2 + 2 + 2 = 6
2.  直接以記憶體地址運算，成本是 3 + 3 = 6
3.  在某些情況下，如果 Reg 中已經存在 a, b, c 那麼成本是 1 + 1 = 2
4.  如果 Reg 中存在 b, c，成本是 1 + 2 = 3

### Graph Coloring

我們可以了解到 Register 的分配對於程式的效能有很大影響，但是這個問題是一個 NP-Complete 的問題，這裡有一些 approximation 的方法可以解決這個問題。

##### 7.1 Graph Coloring

1.  首先掃描一次程式碼，並且選擇好要使用的指令，此時可以任意分配 Symbolic register
2.  第二遍掃描時，使用 Graph coloring algorithm 來分配 Physical register 給 Symbolic register
    -   在第二遍掃描分配時有可能會發生衝突，此時就需要進行 Spilling
    -   Spilling: 決定那些 Register 需要被 spill，並且將 spill 的資料存到 Memory 中(類似 virtual memory 的 swap)

**Interference Graph**

-   在每個 Basic block 中，都會去建立一個 interference graph
-   圖中的每個 Node 代表一個 symbolic register
-   如果一個 Node 在另一個 Node 被定義的時候仍然活躍，那麼這兩個 Node 之間會連接一條邊

**K-colorable Graph**

-   一個圖如果每個 Node 都可以被賦予 K 個顏色，並且相鄰的 Node 顏色都不相同，那麼這個圖就是 K-colorable
-   這裡的 Color 就是 Physical register
-   想要確認一個圖是否是 K-colorable，是 NP-Complete 的問題
    -   這裡會用 Greedy algorithm 來解決這個問題

**A Graph Coloring Algorithm**

1.  如果一個 Node 及其邊的 Neighbor 數量小於 K，那麼就移除這個 Node
2.  重複上面的步驟直到所有的 Node 都被移除或者是留下的 Node 邊的數量大於 K
3.  如果有 Node 無法移除，那麼就需要進行 Spilled 的動作
    -   刪除最多邊的 Node，之後重複上面的步驟，直到最後所有的 Node 都被移除
4.  現在開始依照被移除的逆序來分配 Color 給 Node
5.  每個 Node 都要分配鄰居沒有使用過的 Color
    -   被 Spilled 的 Node 可以使用任何 Color

**Example:**

![](../assets/image/2023/12-26-code_generation/2.png){:height="100%" width="100%"}

![](../assets/image/2023/12-26-code_generation/3.png){:height="100%" width="100%"}



> ##### Last Edit
> 1-4-2021 01:26
{: .block-warning }