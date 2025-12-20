---
title: "Computer Organization | Pipelines Hazards"
author: Benson Hsu
date: 2024-11-14
category: Jekyll
layout: post
tags: [computer_organization, pipelines]
---

> 雖然 Pipeline 可以提升指令吞吐量，但在實作上會遇到各種 hazards 問題，必須透過硬體與編譯器的合作來解決這些問題，才能真正發揮 Pipeline 的效能。
{: .block-tip }

> 這篇文章是從 Organization 的角度去思考 Pipeline Hazards，因此著重在硬體層面的解決方法，而從軟體的角度來思考則可以從 Arc

### 1.4 Overview of Hazards

Pipeline processors 在控制指令於 pipeline 上順暢且高效率地執行時，會遇到數種相關問題。這些問題通常統稱為 hazards，主要可分為以下三種類型:

1.  Structural Hazards
    -   不同指令在 Pipeline 的同一 Segment 需要使用相同的硬體資源，導致衝突
    -   此類 hazard 可以透過發生衝突的 Segments 中配置重複的硬體資源來緩解
    -   也可以透過插入 Stalls 或 Re-Ordering 指令來避免衝突
2.  Data Hazards
    -   指令之間存在資料相依性，導致後續指令需要等待前一指令完成才能繼續執行
    -   最簡單的解決方式是在執行序列中插入 Stalls (但會降低效能)
    -   另一種方法是使用 Forwarding (Bypassing)，提前將 ALU 的結果 Forward 給需要的指令，避免等待
    -   在特定情況下可以 Re-Ordering 指令順序以避免 Data Hazards
3.  Control Hazards
    -   Control Hazards 通常由 Branch instructions 引起，因為在 Branch 指令執行期間，處理器無法確定下一條要執行的指令是哪一條
    -   最簡單的解決方式是在 Branch 指令後插入 Stalls，做局部的等待事件直到 Branch 結果確定 (但會降低效能)
    -   另一種方法是使用 Branch Prediction，預測 Branch 的結果並提前載入預測的指令 (但實作上相當困難)
    -   或者 Delay Branch，將 Branch 指令的效果延後到後續的指令執行完畢後再決定 (需要編譯器支援)

接下來我門會針對每一種 Hazard 類型進行詳細說明，並介紹相應的解決方法。

>   在上述的三種 Hazards 中，Data Hazards 是最常見且影響最大的，因為指令之間的資料相依性非常普遍，而有效地解決 Data Hazards 可以顯著提升 Pipeline 的效能。
{: .block-tip }

>   而從編譯器的角度來看實際上可以處裡的只有 Data Hazards 與 Control Hazards，Structural Hazards 通常需要硬體層面的支援來解決。
{: .block-warning }

---

### 1.5 Data Hazards

**Definition:**  
如果我們需要前一條指令的結果，但 Pipeline 中沒有足夠的 Segments 能在目前 Instruction 讀取該結果之前完成計算並寫回 Register，就會發生 Data Hazard。

通常使用以下三種方式來解決 Data Hazards：

1.  Forwarding (Bypassing)
    -   為了處理 Dependency Hazard，可以在 Pipeline 中加入特殊電路，由 wires 與 switches 組成，將所需要的值 Forward 給該值進行計算的 Pipeline Segment。但這會增加硬體與控制電路的複雜度，但此方法有效，時間上遠小於完成 Pipeline 所需的時間。
2.  Code Re-Ordering
    -   由 Compiler 來重新排序 Source code 的 Statements，或者由 Assembler 重新排序 Object code。將一條或多條 Instruction 插入到兩條有 Data Hazard 的 Instruction 之間，讓 Pipeline 有足夠的時間完成前一條 Instruction 的計算並寫回 Register，避免 Data Hazard 的發生。
    -   這需要一個強大的 compiler 或 assembler，其必須具備 pipeline 結構與時序的詳細資訊，才能判斷 data hazard 可能發生的位置。我們將這類軟體稱為 hardware-dependent compiler。
3.  Stalls
    -   最簡單的解決方式是在發生 Data Hazard 的地方插入 NOP 指令，讓 Pipeline 有足夠的時間完成前一條 Instruction 的計算並寫回 Register，避免 Data Hazard 的發生。但這會降低 Pipeline 的效能。
    -   這種方法是最後手段，只有 Compiler 無法處理或者 Hardware/Software 不支援 Forwarding 時才會使用。

Example:

```riscv
0 sub     x2,  x1,  x3    // Register x2 set by sub
1 and     x12, x2,  x5    // 1st operand(z2) set by sub
2 or      x13, x6,  x2    // 2nd operand(x2) set by sub
3 add     x14, x2,  x2    // 1st(x2) & 2nd(x2) set by sub
4 sd      x15, 100(x2)    // Index(x2) set by sub
```

![](/image/2024/11-13-computer_organization_pipeline_hazards/1.png)

-   以上的問題出在 sub 指令在 CC 5 才會將 x2 的結果寫回 x2，如果未使用任何解決方法則所有要使用 x2 的指令都必須在 CC 6 之後才能執行
-   這裡的解決方式是使用 Forwarding，將 ALU 的結果直接 Forward 給需要的指令，避免等待寫回 Register 的時間，這樣 and, or, add 三個使用 x2 的指令就可以在 CC 6, 7, 8 執行，而不需要等待到 CC 5 之後才能執行

![](/image/2024/11-13-computer_organization_pipeline_hazards/2.png)

---

### 1.6 Structural Hazards

**Definition:**
在某一個 Pipeline Segment 中，如果有兩條或以上的指令同時需要使用同一個硬體資源，就會發生 Structural Hazard。

這裡我們使用相同的程式碼來說明 Structural Hazard 的問題：
-   在 0 sub x2, x1, x3 指令的 CC 5 時間需要將結果寫回 Register
-   在 3 add x14, x2, x2 指令的 CC 5 時間也需要從 Register 讀取 x2 的值

也就是說在 CC 5 的時間點，write back 與 read 兩個動作同時需要使用 Register
x2 這個硬體資源，導致 Structural Hazard 的發生。在某一個 clock cycle 中，Register 可能產生不同的值，這種不一致是不可以被接受的。

1.  修改 Register File 的設計，例如在 clock cycle 的前半段進行讀取，後半段進行寫入，這樣就可以避免 read 與 write 同時發生的問題。但這會增加 Register File 的複雜度與成本。
    -   硬體設計者有時會在 write 與 read 之間插入相對於 clock cycle 很短的延遲，以確保 write 完成後 read 才會發生
2.  另一種 Hazard 可能發生在 Branch Instructions 的執行期間，例如只有一個 ALU 但必須同時進行 BTA (Branch Target Address) 計算與條件判斷。這必須要至少有兩個 adder 才有辦法解決這個問題。( 新增硬體資源 )
3.  同樣的如果 instruct 與 data 共用同一個 memory，可能會發生 Instruction Fetch 與 Data Memory Access 同時需要使用 memory 的情況。
    -   第一種方法是跟 1 的解決方式類似，在同一個 clock cycle 中分開進行 read 與 write，讓 read 與 write 可以在一個 clock cycle 中分別完成。
    -   第二種方法是使用兩個 High speed Cache，一個用於 instruction，一個用於 data，兩者都存取同一個 Memory。

> 第三種作法就是 I-Cache 與 D-Cache 分開設計，這樣就可以避免 Instruction Fetch 與 Data Memory Access 同時需要使用同一個 memory 的問題。
{: .block-tip }

> 現代計算機的處理方式大多是後者，CPU 使用兩種 [Cache] 來分別處理 Instruction 與 Data，這樣可以大幅提升記憶體存取的效率，並且避免 Structural Hazards 的發生。
{: .block-warning }

[Cache]: https://en.wikipedia.org/wiki/CPU_cache

---

### 1.7 Control Hazards