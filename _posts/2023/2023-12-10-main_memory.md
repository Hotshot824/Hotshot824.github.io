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


**7.2 Buffer/Cache**

這裡使用 `top` 查看記憶體使用情況
-   OS 會盡力把記憶體用完，例如: 拿來當作 Cache, Buffer 讓 I/O 更快
-   類似 memory cleaner 這樣的軟體，去釋放記憶體反而可能導致 I/O 變慢

```bash
MiB Mem :   7939.9 total,   7495.9 free,    357.6 used,    314.9 buff/cache
MiB Swap:    953.0 total,    953.0 free,      0.0 used.   7582.3 avail Mem
```

**7.3 Program Layout**

這裡說明 Program 在記憶體中的配置，以及他們的用途這部分就不多做介紹了，可以參考下圖

![](../assets/image/2023/12-10-main_memory/3.png){:height="75%" width="75%"}

> 如果想觀察 Kernel 的 code, data, bss section 可以使用 `cat /proc/kallsyms`，但是需要 root 權限

> ##### Last Edit
> 1-17-2024 15:24
{: .block-warning }

[System address map initialization in x86/x64 architecture part 1: PCI-based systems]: https://resources.infosecinstitute.com/topics/hacking/system-address-map-initialization-in-x86x64-architecture-part-1-pci-based-systems/#gref

[Why does my motherboard see only 3,25 GB out of 4 GB RAM installed in my PC?]: https://www.quora.com/Why-does-my-motherboard-see-only-3-25-GB-out-of-4-GB-RAM-installed-in-my-PC

[Bios-e820]: https://en.wikipedia.org/wiki/E820

[Kernel/User page tables isolation]: https://en.wikipedia.org/wiki/Kernel_page-table_isolation
[实模式启动阶段：从bios获取内存信息]: https://zhuanlan.zhihu.com/p/590013141