---
title: "OS | Main Memory (Unfinished)"
author: Benson Hsu
date: 2023-12-10
category: Jekyll
layout: post
tags: [OS]
---

> Operating System: Design and Implementation course notes from CCU, lecturer Shiwu-Lo. 
{: .block-tip }

-   Physical configuration of DRAM on PC
    -   `DRAM + BIOS + MMIO`
-   Three main functions of DRAM
-   Segmentation memory management
-   Paging memory management
-   Linux memory layout
-   External fragmentation

##### x86 Start - BIOS Address

> 在一台 PC 剛開機後唯一能讀取的記憶體就是 BIOS(ROM)，必須透過 BIOS 才能完成後續 OS 的內容載入到 DRAM 中
{: .block-tip }

-   x86 在啟動的時候，執行的第一個指令是在 `0xFFFFFFF0` 這個位址
    -   因此主機板上必須使用 Address decoder 將 `0xFFFFFFF0` 對應到 BIOS 的 Entry point
-   BIOS 設定完畢後，會進入 OS 的 Entry point
    -   例如: Linux 的 `start_kernel`

##### BIOS in Memory Usage

BIOS 雖然不需要電力就能保存，但是通常速度會比 DRAM 慢，所以大部分的 BIOS 會把自己複製到 DRAM 中，
並且配置 data, stack, heap section，然後在 DRAM 中執行。

> 為什麼不使用 Flash memory，因為 Flash memory 是 Block device 而 CPU 能讀取的必須是 byte addressable

---

### Memory Layout

> 下圖是如果記憶體只有 256MB 或 512MB 的 Memory Layout，在 32-bit 的 CPU 中，最多只能使用 4G 的定址空間

![](../assets/image/2023/12-10-main_memory/1.png)

-   DRAM 之外的空間就是 MMIO，這部分的空間通常只能透過 Kernel 存取
-   注意到他把 BIOS 映射到最上層的位置，這樣 BIOS 就不會去占用 DRAM 的定址空間

> 延伸閱讀: [System address map initialization in x86/x64 architecture part 1: PCI-based systems]

![](../assets/image/2023/12-10-main_memory/2.png){:height="75%" width="75%"}

-   假如一個 4G 定址空間的機器裝上 4G 的 DRAM，那麼扣除 PCI 的空間後，只會剩下 3.25G 的空間可用
-   最好的解決方式就是邁入 64-bit 的時代，不只解決了 Memory address 的問題，也解決了檔案不能超過 2G 的問題

> 延伸閱讀: [Why does my motherboard see only 3,25 GB out of 4 GB RAM installed in my PC?]

**7.1 BIOS - Memory Map**

使用 `dmesg` 可以看到 Linux 在啟動時的 **[BIOS-e820] Physical Memory** 配置，可以看到幾個區域
-   usable: 可以使用的記憶體
-   reserved: 保留給 BIOS 或是其他的 Device 使用
-   ACPI data/NVS: 配置給 ACPI 或 NVS (Non-Volatile Storage)使用

```bash
[    0.000000] BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009f7ff] usable    # 0.62 MB
[    0.000000] BIOS-e820: [mem 0x000000000009f800-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000ca000-0x00000000000cbfff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000dc000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000bfeeffff] usable    # 3069.94 MB
[    0.000000] BIOS-e820: [mem 0x00000000bfef0000-0x00000000bfefefff] ACPI data
[    0.000000] BIOS-e820: [mem 0x00000000bfeff000-0x00000000bfefffff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000bff00000-0x00000000bfffffff] usable    # 1 MB
[    0.000000] BIOS-e820: [mem 0x00000000f0000000-0x00000000f7ffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fec00000-0x00000000fec0ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fee00000-0x00000000fee00fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fffe0000-0x00000000ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000023fffffff] usable    # 5120 MB
```

實際分配給電腦的記憶體是 8192 MB，而經由 BIOS 分配以後為 8191 MB，可以發現這些 usable 的地址其實是不連續的，
有些地方映射到 DRAM，有些地方映射到 MMIO。CPU 會去透過 Address decoder 將 Physical address 映射到不同裝置的記憶體。

-   DMA 與 DMA32 是保留給 16/32-bit 的 DMA controller 使用
    -   Normal 就是任何能夠使用 64-bit address 的裝置
-   Movable zone 是用來處理 Hotplug 的記憶體，例如: USB Keyboard
-   unavailable ranges 代表該區域的記憶體不可使用
    -   可能因為 BIOS 或是其他的裝置使用了這些記憶體

```bash
[    0.014535] Zone ranges:
[    0.014536]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.014539]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
[    0.014541]   Normal   [mem 0x0000000100000000-0x000000023fffffff]
[    0.014543]   Device   empty
[    0.014545] Movable zone start for each node
[    0.014548] Early memory node ranges
[    0.014548]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.014550]   node   0: [mem 0x0000000000100000-0x00000000bfeeffff]
[    0.014553]   node   0: [mem 0x00000000bff00000-0x00000000bfffffff]
[    0.014554]   node   0: [mem 0x0000000100000000-0x000000023fffffff]
[    0.014558] Initmem setup node 0 [mem 0x0000000000001000-0x000000023fffffff]
[    0.014577] On node 0, zone DMA: 1 pages in unavailable ranges
[    0.014636] On node 0, zone DMA: 97 pages in unavailable ranges
[    0.027855] On node 0, zone DMA32: 16 pages in unavailable ranges
...
[    0.102320] Kernel/User page tables isolation: enabled
```

> [Kernel/User page tables isolation] 是用來避免 SPECTRE 之類的攻擊，讓 Kernel 有自己的 Page table，缺點是會降低 System call 的效能
{: .block-warning }

> 延伸閱讀: [实模式启动阶段：从bios获取内存信息]

`cat /proc/iomem` 可以看到 Physical address 的配置

-   與之前的 `dmesg` 顯示的內容相同
-   並且 kernel 會配置自己的 code, rodata, data, bss section

```bash
00001000-0009f7ff : System RAM      # 0.62 MB
00100000-bfeeffff : System RAM      # 3069.94 MB
bff00000-bfffffff : System RAM      # 1 MB
100000000-23fffffff : System RAM    # 5120 MB
8f400000-90201b41 : Kernel code
90400000-90cd5fff : Kernel rodata
90e00000-91046d3f : Kernel data
916fe000-927fffff : Kernel bss
```

---

### DRAM Main Functions

[7.2 Buffer/Cache](#72-buffercache)  
[7.3 Program Layout](#73-program-layout)  
[7.4 Memory Segmentation](#74-memory-segmentation)  
[7.5 Memory Paging](#76-memory-paging)  
[7.6 Fragmentation Problem](#75-fragmentation-problem)  

這裡先介紹 DRAM 的特性:
-   DRAM 的特性是只要 CPU 開始工作，DRAM 就會全速運轉
    -   即使 DRAM 有多個插槽，OS 會把他們視為一體
-   DIMM (Dual In-line Memory Module)
    -   通常插滿記憶體代表容量變大，頻寬變大，但 OS 無法獨立控制每個記憶體
-   NUMA (Non-Uniform Memory Access)
    -   有多個 CPU 的情況下，每個 CPU 都有自己的 DRAM，但是 CPU 之間可以透過 QPI 互相存取
    -   這種情況下 OS 可以獨立控制每個 CPU 的 DRAM，例如: 雙路的 Server 的架構
-   記憶體無論如何都要耗電
    -   DRAM 不管是讀取或寫入或儲存都需要耗電，所以 OS 會把 DRAM 全部用完
    -   如果某一個區段沒有真正的用途，那還是要耗電保存這部分 garbage
-   **記憶體的主要用途**
    -   執行程式的時候使用
    -   充當 Cache Memory 的角色，主要是當作 HDD, SSD 的 Cache
    -   充當 Buffer 的角色，再與周邊 Device 溝通時，需要保留一塊 Memory 讓裝置可以存取，例如: DMA


##### 7.2 Buffer/Cache

這裡使用 `top` 查看記憶體使用情況
-   OS 會盡力把記憶體用完，例如: 拿來當作 Cache, Buffer 讓 I/O 更快
-   類似 memory cleaner 這樣的軟體，去釋放記憶體反而可能導致 I/O 變慢

```bash
MiB Mem :   7939.9 total,   7495.9 free,    357.6 used,    314.9 buff/cache
MiB Swap:    953.0 total,    953.0 free,      0.0 used.   7582.3 avail Mem
```

##### 7.3 Program Layout

這裡說明 Program 在記憶體中的配置，以及他們的用途這部分就不多做介紹了，可以參考下圖。OS 在這裡的任務就是將執行檔從儲存裝置中載入到 Memory 中，配置好執行的環境。

![](../assets/image/2023/12-10-main_memory/3.png){:height="75%" width="75%"}

> 如果想觀察 Kernel 的 code, data, bss section 可以使用 `cat /proc/kallsyms`，但是需要 root 權限

##### 7.4 Memory Segmentation

記憶體的區段機制([Memory Segmentation])是很直覺以程式的區段作為管理的單度，每個 seg. 都對應到程式的一個邏輯上的 seg.(text, data, bss, heap, stack)，
通常 seg. 是不可以被拆分，要拆分的話需要硬體支援，有固定的拆分大小。

> 例如: x86 的 ds. fs. gs. 三個 data 的 segmentation，其中 fs. gs. 是額外的 data seg.

![](../assets/image/2023/12-10-main_memory/4.png){:height="75%" width="75%"}

同一個程式的 seg. 可以在 Physical memory 中不連續，這樣可以更有效率的使用記憶體，但是這樣就有可能產生 Fragmentation Problem(碎片化問題)。

**Management of Segmentation**

既然是基於 Segmentation 的管理機制，那麼他所使用的定址方式就會是基於 Base + Offset 的方式(相對定址)。
-   例如這樣的指令: reg<sub>target</sub> = reg<sub>base</sub> + offset
    -   這個 reg<sub>base</sub> 是 OS 能夠管理的
-   例如設計三個 Register 可以分別指向 code, data, stack 的開始位置，這樣就能分開存放這三個 seg.

> 在這種機制下 Context switch 的時候除了切換 general register 以外，還需要切換 base reg. file

這種 base reg. file 的設計同時還要引入 limit(長度)用來限制存取的範圍，如果存取錯誤的記憶體就會觸發 Segmentation Fault。
以 ARM Cortex-M 為例，[MPU_RBAR] 是用來設定 base address，MPU_RASR 是用來設定 limit。

> MPU: [Memory Protection Unit]

> Memory Segmentation 的機制並不太適合在動態的環境下，要新增程式或減少程式，容易造成碎片化問題，但在靜態的環境下，例如: 嵌入式系統，就很適合使用這種機制
{: .block-warning }

##### 7.5 Memory Paging

> Memory Paging 是目前主流的記憶體管理機制，相較於 Memory Segmentation，他的管理單位是 Page，而不是 Seg.
{: .block-tip }

-   Page 是固定大小的記憶體區塊，通常是 4KB
-   OS 指定每個 Page 的用途，例如: code, data, stack, heap
    -   不一定是連續分配的 Page

**[Page Table]**

為了確保程式在執行時不會忽鄉干擾，OS 要能很輕鬆的切換正在執行的程式，所以硬體上會支援 Mapping Table 的機制

-   假如系統最多有 48 個 Page，那麼這個 Table 就起碼要有 48 個 entry
-   要能針對每個 Page 設定不同的權限，例如: stack(rw-), code(r--), data(rw-)
    -   即使 stack, data 是相同權限，但是 OS 會給他們不同的功能，例如: stack 可以隨程式增加大小

> 下圖是一個程式從 CPU 使用 Virtual address 到 Physical address 的過程，其中 OS 會透過 Mapping Table 來做轉換，
> 實際上這樣的轉換是在 CPU 中完成的，是已經設計好的硬體線路

![](../assets/image/2023/12-10-main_memory/5.png){:height="100%" width="100%"}

可以看到表格中會有 Vir. address, Phy. address 的對應，與屬性權限等等，如果 Context switch 的時候，OS 只需要切換這個 Page Table 就可以了。

-   同時 OS 會知道這個 Page 是什麼類型，例如: stack 假如碰觸到邊界，OS 就會去增加 stack 的大小。
-   在虛擬記憶體上，OS 會把這些資訊記錄在 Task Control Block(TCB) 中，使用 RBtree 來管理

> Linux Kernel 中使用 mm_struct 來描述 Task 的 Virtual Memory Layout

-   相較於 Segmentation，Paging 的優點是:
    -   在記憶體分配上 Paging 比較有彈性，只要有足夠的 Page 就可以
    -   在 Hardware 上並沒有 Segmentation 的概念，是由 OS 來實現的
    -   每一個 Page 的大小是固定的，分配演算法會比較好實現
-   缺點:
    -   Page 的數量遠超過 Segmentation，所以 Page Table 會很大，可能會造成硬體 Mapping 上的效能負擔
    -   如果使用 Assembly 寫程式，Paging 的程式碼會比較難寫，難懂

##### 7.6 Fragmentation Problem

> 只要會造成 Memory 動態分配的情況，就必然會有 Fragmentation Problem，這是一個無法避免的問題
{: .block-tip }

-   **[External Fragmentation](外部碎片)**: 如果一塊記憶體中的 Free space 足夠，但無法滿足程式的需求，這些 Free space 就是 External Fragmentation
-   **[Internal Fragmentation](內部碎片)**: 因為配置演算法，本來只需要 X size 的記憶體，但是分配了 X + Y size 的記憶體，其中 Y size 就是 Internal Fragmentation
    -   例如: OS 分配空間時覺得剩下的空間太小了，乾脆把整個空間都分配給程式，那就是 Internal Fragmentation

這裡有一些解決 External Fragmentation 的方法，例如:
-   Memory Compaction(記憶體壓縮): 搬移記憶體使 Free space 變成連續的，但是成本很高
-   更好的分配演算法: Best Fit, Worst Fit, First Fit

**Fragmentation in Paging/Segmentation**

-   在 Pagging 的情況下，由於每個 Page 的大小一致，並且透過 Mapping 的方式使用 Page，所以不會有 External Fragmentation
    -   但因為程式所需要的記憶體大小不會剛好是 Page 的大小，所以會有 Internal Fragmentation

### Memory Paging Hardware

> 這裡會介紹 Mapping Table 的基本形式，即是 TLB(Translation Lookaside Buffer)，如果 TLB 不夠大要怎麼處理
{: .block-tip }

##### 7.7 MMU and MPU

-   MPU(Memory protection unit): 可以設定某段記憶體的權限，例如: code(r--), data(rw-)
-   MMU(Memory management unit): 除了 MPU 的功能以外，還可以透過 MMU 使 OS 更有效的分配記憶體的使用

**MMU management unit**

-   以 Segment 為最小管理單位
    -   較早期的電腦會以 Segment 為最小管理單位
    -   在 Protect 上會比較直觀
    -   因為 Segment 的特性，所以對於記憶體管理的幫助不大
-   以 Page 為最小管理單位
    -   在 Protect 上會比較複雜，因為每個程式都會有很多 Page
    -   但在管理上因為 Page 固定大小，因此可以更有效率的管理記憶體
    -   因為 Page 很多，所以需要很多的 Mapping entries，例如: 4GB 的記憶體就要 1M 個 entries(4GB / 4KB)，這會成為硬體的負擔

**MMU Architecture**

實際上 MMU 會建立在 CPU 內部，下面是一個簡單的架構表示 CPU 中 MMU, Address decoder, DRAM 之間的關係:

![](../assets/image/2023/12-10-main_memory/6.png){:height="100%" width="100%"}

-   L1 Cache 與 MMU 誰在前誰在後，取決於 CPU 的設計
    -   要注意的是 L1 Cache 如果在 MMU 前面 Context switch 的時候，就要把 L1 Cache 清空

**MMU Function**

> 這裡介紹下 MMU 應該會是什麼樣子，這下面舉的是抽象簡化的例子

假如有以下編碼 reg<sub>target</sub> = reg<sub>base</sub> + offset
-   Segment 機制下:
    -   reg<sub>base</sub> 可能是 base<sub>code</sub> 這樣的管理方式，代表是 code seg. + offset
-   Paging 機制下:
    -   reg<sub>base</sub> 代表的是 Page Number，所以是 Page Number + offset
    -   例如: 一個 32 bit 的系統，Page number 會是 20 bit，offset 會是 12 bit，因此 offset 最多只能是 4KB，因此不需要 limit 的設計

##### 7.8 TLB

其實 TLB([Translation Lookaside Buffer]) 就是一個在 CPU 中的高速 Buffer(SRAM)，把 MMU 的 Page Table 存放在 TLB 中，利用這種方式可以加速地址轉換的速度。

![](../assets/image/2023/12-10-main_memory/7.png){:height="100%" width="100%"}

-   p(page number): 在 Logical address 中的 Page number
-   f(frame number): 實際上在 Physical address 中的 Page number
-   d(displacement, offset): 在 Page 中的 offset

> ##### Last Edit
> 1-17-2024 15:24
{: .block-warning }

[System address map initialization in x86/x64 architecture part 1: PCI-based systems]: https://resources.infosecinstitute.com/topics/hacking/system-address-map-initialization-in-x86x64-architecture-part-1-pci-based-systems/#gref

[Why does my motherboard see only 3,25 GB out of 4 GB RAM installed in my PC?]: https://www.quora.com/Why-does-my-motherboard-see-only-3-25-GB-out-of-4-GB-RAM-installed-in-my-PC

[Bios-e820]: https://en.wikipedia.org/wiki/E820

[Kernel/User page tables isolation]: https://en.wikipedia.org/wiki/Kernel_page-table_isolation
[实模式启动阶段：从bios获取内存信息]: https://zhuanlan.zhihu.com/p/590013141

[Memory Segmentation]: https://en.wikipedia.org/wiki/Memory_segmentation

[External Fragmentation]: https://en.wikipedia.org/wiki/Fragmentation_(computing)#External_fragmentation
[Internal Fragmentation]: https://en.wikipedia.org/wiki/Fragmentation_(computing)#Internal_fragmentation

[MPU_RBAR]: https://www.keil.com/pack/doc/CMSIS/Core/html/group__mpu8__functions.html#gafe39c2f98058bcac7e7e0501e64e7a9d
[Memory Protection Unit]: https://en.wikipedia.org/wiki/Memory_protection_unit

[Page Table]: https://en.wikipedia.org/wiki/Page_table

[Translation Lookaside Buffer]: https://en.wikipedia.org/wiki/Translation_lookaside_buffer