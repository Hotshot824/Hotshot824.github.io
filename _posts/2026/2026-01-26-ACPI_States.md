---
title: "Note | ACPI States"
author: Benson Hsu
date: 2026-01-26
category: Jekyll
layout: post
tags: [bios, acpi]
---

> [ACPI] 全名為 Advanced Configuration and Power Interface，是一個開放標準，用於管理電腦的電源與硬體配置。
{: .block-tip }

[ACPI]: https://en.wikipedia.org/wiki/Advanced_Configuration_and_Power_Interface

與 BIOS 密切相關的另一個重要標準就是 ACPI，ACPI 定義了一套電源管理與硬體配置的規範，讓作業系統能夠更有效地控制硬體資源與電源使用。
定義 ACPI 的目的是不以 BIOS 為中心，而是讓作業系統能夠直接管理硬體資源與電源狀態，提升系統的靈活性與效能。

> 這裡一定會有疑問，既然 UEFI Runtime Services 已經提供 OS 與韌體服務，為什麼要另外定義 ACPI。

1. 電池與電源管理是一個高度動態與 OS 策略深度綁定的問題
    -   電池管理會隨著時間頻繁變化，並且會影響 OS 的行為
        -   例如: 當電池電量低時，OS 可能會選擇降低效能以延長續航時間
    -   如果把這類功能放在韌體層面，會導致韌體變得過於複雜，並且難以適應不同的 OS 策略
2. 跨 OS 的標準化
    -   韌體僅需要以 ACPI Table 描述硬體能力與電源模型
    -   如何實作則完全交由 OS 實作

如果改由 UEFI Runtime Services 來處理這些電源管理功能，就代表 Linux, Windows 都需要依賴於同一組韌體 API，
如果韌體設計不良或者有 Bug，會導致 OS 幾乎無法繞過這些問題，並且電源管理的策略會被韌體的更新速度綁定。

> ACPI 簡單可以這樣理解，韌體描述事實 (what hardware can do)，OS 決定策略 (what to do)

> 如果沒有 ACPI，OS 就需要為各種硬體平台時做特定的驅動程式，失去硬體抽象化的好處

---

### ACPI States Overview

> 這份筆記主要目標僅在描述 ACPI 定義的各種電源狀態，並不會深入探討 ACPI Table 的結構等內容。有興趣可以參考 [ACPI Specification](https://uefi.org/specifications)。
{: .block-danger }

ACPI 所定義的 States 包含以下幾種:
-   Global System Power States (G-States G0 - G3)
-   System Sleeping States (S-States S0 - S5)
-   Device Power States (D-States D0 - D3)
-   Processor Power States (C-States C0 - Cn)
-   Throttling States (T-States)

![](/image/2026/01-26-ACPI_States/1.png){:height="75%" width="75%"}

#### Global System Power States (G-States)

> G-States 定義了整個系統的電源狀態，從完全開啟到完全關閉。
{: .block-tip }

1.  G0 (Working)：系統完全開啟並運作中。
2.  G1 (Sleeping)：系統處於睡眠狀態，包含 S1 - S4 狀態。
3.  G2 (Soft Off)：系統關閉，但仍有部分電源供應給某些元件 (如 Wake-on-LAN)。
    -   電腦插著電源但卻關機的狀態
4.  G3 (Mechanical Off)：系統完全關閉，沒有任何電源供應。

> G-States 是最高層級的電源狀態，決定了系統整體的電源管理策略。G-State 所解決的是這台機器目前處於什麼狀態，
> 因此在 G 的層級上，我們不清楚 RAM 或 CPU 的細節，只清楚系統是什麼狀態。

#### System Sleeping States (S-States)

> S-States 通常是最常被提及的 ACPI 狀態，定義了系統的睡眠深度。
{: .block-tip }

1.  S0 (Working)：系統完全開啟並運作中。
2.  S1 (Sleep)：CPU 停止執行，但 CPU 與 RAM 依然供電
3.  S2 (Deeper Sleep)：CPU 停止供電，Cache 保存至 RAM
    -   S1 更常被使用在短暫待機狀態，而 S2 則較少見，因為它在節能效果與恢復速度之間的平衡較差
4.  S3 (Suspend to RAM)：大部分元件關閉，僅 RAM 保持供電，以便快速恢復。
    -   常用的睡眠狀態，能在低功耗與快速恢復之間取得平衡
    -   此階段風扇等周邊元件也會關閉，只保留 RAM 讓系統狀態得以保存
5.  S4 (Hibernate)：系統狀態保存到硬碟，然後完全關閉電源
    -   既然 RAM 都不供電了，系統狀態就必須保存到非揮發性儲存裝置
    -   很直接能想到回復時間會比 S3 長，因為需要從硬碟讀取系統狀態
6.  S5 (Soft Off)：系統完全關閉，但可以透過特定事件喚醒。

> S-State 處理的是 OS 實作層級的睡眠狀態，OS 並無法直接操作 G-State 這種 G1 = Sleeping 的模糊概念。

#### Processor Power States (C-States)

![](/image/2026/01-26-ACPI_States/2.png){:height="75%" width="75%"}

C-States 描述的是 CPU 在 IDLE 狀態下的不同省電模式，因此 C-States 主要描述的是 CPU 層級的電源管理。
因此 C-States 基本上只會在 G0/S0 狀態下被使用，因為在此之外 IDLE 狀態就沒有意義了。

1.  C0 (Active)：CPU 完全運作中，執行指令。
2.  C1 (Halt)：CPU 停止執行指令，但幾乎可以瞬間恢復。
    -   在某些處理器中，額外支援 C1E (Enhanced Halt) 狀態，進一步降低功耗
    -   實作上通常包含 Pipeline Stall、Clock Gating
    -   但電壓保持不變 Vcore 維持，Cache、TLB、Register 都保持供電
    -   在此階段任何 Interrupt、[IPI]、Timer Event 都能讓 CPU 立即恢復 C0 狀態
    -   可想而知這樣的省電效果有限，但恢復速度非常快
3.  C2 (Stop-Clock)：CPU 停止時鐘訊號，降低更多功耗。
    -   此階段更多的 Clock Domain 被關閉
    -   Cache 還是保留，但 [PLL] 可能會停止
    -   很多平台不會實作 C2 狀態，被折疊進 C1 / C3
3.  C3 (Sleep)：CPU 會停止對 Register 與 Cache 的供電，進一步降低功耗。
    -   此階段 CPU 內部大部分的電路都會關閉
    -   Cache 的資料要保持 coherence，直接 Write Back 到 RAM
    -   TLB 內容也會被清除
    -   只有 Uncore 部分保持供電，例如 Memory Controller
    -   這個階段的喚醒需要較長時間，因為需要重新載入 Cache 與 TLB
        -   Interrupt -> Power Rail Restore -> Clock Restart -> Cache/TLB Rebuild -> Resume

更深的 C-States (C4, C5, ...) 則會進一步關閉更多的 CPU 元件，這部分通常是廠商自定義的，並不在 ACPI 規範中明確定義。

> [IPI] (Inter-processor interrupt) 讓一個處理器核心能夠向另一個核心發送中斷請求。

> [PLL] (Phase-locked loop) 是一種電子電路，用於生成穩定的時鐘訊號，確保處理器和其他元件能夠同步運作。

[IPI]: https://en.wikipedia.org/wiki/Inter-processor_interrupt
[PLL]: https://en.wikipedia.org/wiki/Phase-locked_loop

#### Device Power States (D-States)

> D-States 定義了個別裝置的電源狀態，通常裝置不一定有所有的 D-States。
{: .block-tip }

這裡的裝置可以是任何硬體元件，例如: NIC, GPU, Sound Card ...

1.  D0 (Fully On)：裝置完全開啟並運作中。
2.  D1 (Low Power)：裝置進入低功耗狀態。
3.  D2 (Standby)：裝置進入軟體關閉狀態，但仍可快速恢復。
4.  D3 (Off)：裝置完全斷電。

#### Throttling States (T-States)

> T-State 全稱 Processor Throttling States，定義了 CPU 在高負載或高溫時的降頻狀態。
{: .block-tip }

T-State 主要透過調整單位時間內 CPU 的 Clock On / Clock Off 比例來達到降頻效果，以降低功耗與熱量產生。
例如一段時間內只允許一半的 Clock cycle 真正被送入 Pipeline 執行指令，其餘時間強制 IDLE 來達到降頻效果。

T-State 的存在原因是:
1.  反映速度快，相較於 P-State 不需要調整電壓或 PLL，在極短時間內限制 CPU 效能
2.  平台強制控制，例如 EC / Firmware 監控到過熱時，能夠快速降低 CPU 熱量產生，即使 OS 不配合

> 以上就是所有 ACPI 定義的主要電源狀態，這些狀態讓作業系統能夠更靈活地管理硬體資源與電源使用，
> 提升系統的效能與續航能力。
{: .block-warning }

---

> ##### Last Edit
> 01-24-2026 18:36
{: .block-warning }