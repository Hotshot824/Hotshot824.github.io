---
title: "Note | BIOS Introduction"
author: Benson Hsu
date: 2026-01-24
category: Jekyll
layout: post
tags: [bios]
---

> BIOS 全名為 (Basic Input/Output System)，負責在電腦開機時初始化硬體並載入作業系統。
{: .block-tip }

> 難道 OS 會自己飛進 DRAM 自己啟動嗎？當然不會，這時候就需要 BIOS 幫忙囉！
{: .block-warning }

### 1. PC Architecture Overview

> 通常 Computer Introduction 或者 Computer Architecture 會把這部分講的很詳細，
> 這裡還是整理一下簡單複習，算盤本通常會更加強調硬體架構與運作原理。
{: .block-tip }

在開始介紹 BIOS 之前我們應該要先清楚現代電腦的基本架構，以下是一個簡化的 Notebook / Desktop 架構圖：

![](/image/2026/01-24-BIOS_introduction/1.svg)

> 這張圖蠻難得把 BIOS 跟南北橋都畫出來的，現代架構通常會把北橋整合進 CPU 裡面，或不畫出 Flash ROM。

**CPU Level**

1.  CPU (Central Processing Unit)：負責執行程式指令與處理資料，是電腦的核心運算單元。
2.  Register：CPU 內部的高速儲存單元，用於暫存指令與資料。
3.  Cache：位於 CPU 與主記憶體之間的高速緩存，用於加速資料存取。
    -   L1、L2、L3 Cache：即使是 Cache 也有分層，L1 最快但容量最小，L3 最慢但容量最大。

**Memory Hierarchy**

1.  主記憶體 (RAM)：用於暫存正在執行的程式與資料，速度較快但斷電後資料會消失。
2.  次級儲存裝置 (SSD/HDD)：用於長期儲存資料，速度較慢但容量較大且斷電後資料不會消失。
3.  ROM / Flash Memory：用於儲存韌體 (Firmware)，如 BIOS，資料在斷電後仍然保留。
    -   ROM 就真的是 Read-Only Memory，無法寫入資料。
    -   但 BIOS 通常會使用 Flash Memory，可以透過韌體更新來修改 BIOS 內容。

**Bus Architecture / Chipset**

![](/image/2026/01-24-BIOS_introduction/2.png){:height="50%" width="50%"}

1.  數據匯流排 (Data Bus)：用於傳輸資料的通道，連接 CPU、記憶體與周邊裝置。
2.  地址匯流排 (Address Bus)：用於傳輸記憶體地址的通道，CPU 使用地址匯流排來定位記憶體位置。
3.  控制匯流排 (Control Bus)：用於傳輸控制訊號的通道，協調各個元件之間的操作。

**Chipset**

1. 北橋 (Northbridge)：負責連接 CPU、記憶體與高速周邊裝置，如顯示卡。
2. 南橋 (Southbridge)：負責連接較慢的周邊裝置，如硬碟、USB 裝置與音效卡。

現代架構通常把 北橋整合進 CPU 裡面，這很合理因為北橋控制的基本上就是 CPU 相關的高速周邊元件，
而南橋則通常較複雜，會負責更多週邊裝置的管理。

> Bus 定義了系統中資料、位址與控制訊號的傳輸規範與通道，而 Chipset 則是實體硬體，負責解碼、仲裁並實作這些 Bus 間的連接與轉換。 
{: .block-tip }

**I/O Devices**

剩餘的就是各種周邊 I/O 裝置 (Input/Output Devices)，像是鍵盤、滑鼠、顯示器、網路卡、音效卡等等。

---

### 2. BIOS Overview

> BIOS (Basic Input/Output System)

> 現代 PC 通常運行在 OS 環境下執行程式，OS 同時也是一個程式，在 Von Neumann 架構下，
> 程式必須先被載入到記憶體中才能執行，在 OS 載入之前，PC 就是一個沒有作業系統的硬體平台，
> 此時運行的第一個程式就是 BIOS。
{: .block-tip }

因此 BIOS 需要在開機後尚未載入 OS 之前，完成硬體初始化與檢測，其包含以下主要功能：

1.  硬體初始化 (Hardware Initialization)：  
BIOS 在電腦開機時會初始化 CPU、記憶體、顯示卡等硬體元件，確保它們能正常運作。
2.  自檢程序 (Power-On Self Test, POST)：  
BIOS 會執行一系列的自檢程序，檢查硬體是否正常運作，若有問題會發出錯誤訊號或顯示錯誤訊息。
3.  引導程序 (Bootloader)：  
BIOS 會尋找並載入作業系統的引導程式，通常是從硬碟、SSD 或其他可引導裝置中尋找，並將控制權交給作業系統。
4.  硬體設定 (Hardware Configuration)：  
BIOS 提供一個介面讓使用者可以設定硬體參數，如系統時間、啟動順序等。
5.  提供基本 I/O 服務 (Basic I/O Services)：  
BIOS 提供一組基本的輸入/輸出服務，這樣在 OS 載入之前，程式仍然可以透過 BIOS 來存取硬體資源。

![](/image/2026/01-24-BIOS_introduction/3.png)

> BIOS/UEFI 的主要任務是在系統開機時初始化硬體、建立啟動環境，並將控制權交給 bootloader，由 bootloader 載入並啟動作業系統。

BIOS 的執行階段是沒有 DRAM 可以使用的，此時 PC 上的唯一可用記憶體是 CPU 內部的 Register 與 Cache，
指令與資料都必須從 Flash ROM 中讀取，因此 BIOS 程式碼通常會被設計得非常精簡，以確保能在有限的資源下順利執行。

這與我們所認知的 C 執行環境有很大差異，因此幾乎沒有或者非常少的 Stack 可以使用，不使用 Heap，
這階段叫做 Cache-as-RAM (CAR)，BIOS 會把 CPU Cache 當作暫時的記憶體來使用。

直到 BIOS 初始化完畢並啟動 DRAM 後，才會切換到正常的記憶體環境，此時才會有完整的 Stack 與 Heap 可用。

> 這裡會依照 BIOS 的實作不同而有所差異，但大致上都是這樣的流程。
{: .block-tip }

BIOS 作為 PC 架構中的關鍵韌體，扮演著硬體與作業系統之間的橋樑。在 PC 開機的最初階段，
BIOS 必須在極度受限的環境下完成硬體初始化與自檢程序，為作業系統的載入建立起必要的執行環境。

> 這樣就大致說明了 BIOS 的基本概念與功能，接下來有興趣再進一步探討 BIOS 的工作流程與技術細節。
{: .block-warning }

---

### 3. UEFI Stages Overview

> UEFI (Unified Extensible Firmware Interface) 是較於 Legacy BIOS 更加現代化的韌體介面。
{: .block-tip }

> Reference: [UEFI Specification](https://uefi.org/specifications)

Leagcy BIOS 的執行環境都是在 16-bit 下運行，因此即使 CPU 支援 64-bit 還是必須額外實作 16-bit 的執行環境來支援 BIOS，
因此廠商開始想改變這個狀況。16-bit 的 Memory Addressing 極限就是 1MB，這就大大限制了 BIOS 可以做的事情。
並且對開發者來說 Legacy BIOS 的開發多以 Assembly 為主，開發難度較高且不易維護。

當然 UEFI 作為現代化的韌體介面，當然要劃分多個 Phase 來處理不同的任務，以下是 UEFI 的主要階段：

![](/image/2026/01-24-BIOS_introduction/4.png)

**SEC (Security Phase)：**  
-   主要功能:
    -   UEFI 的第一個階段，在 Power 或者 Reset 後執行
    -   這個階段的主要任務驗證 Firmware 的完整性與安全性，確保韌體未被篡改
    -   建立最小的執行環境，初始化 CPU 基本狀態
    -   傳遞控制權到下一個階段 PEI
-   執行環境:
    -   在這個階段必須建立一塊臨時的記憶體區域 (Temporary RAM)
        -   通常使用 CAR (Cache-as-RAM) 或者 SRAM
    -   此時的執行代碼位於 ROM 中，並且只能使用非常有限的資源
    -   CPU 從 Reset Vector (0xFFFFFFF0) 開始執行，這是 CPU 啟動後的預設位置

> SEC 階段最初是用 Assembly 編寫的，CPU 在剛啟用時只能運行 Real Mode
{: .block-tip }

**PEI (Pre-EFI Initialization Phase)：**
-   主要功能:
    -   DRAM 初始化，這樣才能在 DEX 階段使用 DRAM
        -   通常 DRAM init 會由 Vendor 提供的程式碼來完成
    -   CPU 初始化，將記憶體控制器 (Memory Controller) 設定好
        -   重新指向 Stack，設定 Exception
    -   Chipset 初始化，設定南北橋等晶片
    -   DXE 會被解壓縮搬移到 DRAM 中
    -   透過 Hand-off Block (HOB) 傳遞系統資訊到 DXE 階段
-   執行環境:
    -   在這個階段之後都是用 C 作為主要編寫語言
    -   在這個階段還是沒有 DRAM 可用，因此必須繼續使用 CAR

> 這些 Init 基本上都是由 PEI Module (PEIM) 來完成，PEI Code 負責管理

> PEI 最主要的目的是初始化 DRAM，這樣後續的階段才能使用記憶體支援
{: .block-tip }

> [The design for the Pre-EFI Initialization (PEI) phase of a PI Architecture-compliant boot is as an essentially miniature version of the DXE phase of the PI Architecture and addresses many of the same issues.]

[The design for the Pre-EFI Initialization (PEI) phase of a PI Architecture-compliant boot is as an essentially miniature version of the DXE phase of the PI Architecture and addresses many of the same issues.]: https://uefi.org/specs/PI/1.8/V1_Overview.html#pre-efi-initialization-pei-phase

> 可以說 PEI 是為了進入 DXE 階段的一個不得已而為之的妥協，其目標是為了準備好 DXE 階段的執行環境

**DXE (Driver Execution Environment Phase)：**
-   主要功能:
    -   DXE 階段才真正的初始化大部分的硬體元件
    -   載入並執行各種驅動程式 (Driver) 來支援不同的硬體
        -   GPU、NIC、SATA/NVMe Controller、USB Controller ...
    -   建立 UEFI Boot Services 與 Runtime Services
        -   提供一組標準化的服務介面給後續的 Bootloader 與 OS 使用
    -   建立 ACPI Table、SMBIOS Table 等系統資訊

> [Boot Services] 提供在 OS 載入前使用的服務，而 [Runtime Services] 則是在 OS 載入後仍然可用的服務

[Boot Services]: https://uefi.org/specs/UEFI/2.9_A/07_Services_Boot_Services.html

[Runtime Services]: https://uefi.org/specs/UEFI/2.9_A/08_Services_Runtime_Services.html

-   執行環境:
    -   在這個階段已經可以使用 DRAM，因此可以使用完整的 C 執行環境
    -   可以使用 Stack 與 Heap，並且可以使用標準的 C 函式庫

> DXE 可以說是 BIOS 的主戰場，在這個階段可以進行大量的硬體初始化與設定
{: .block-tip }

**BDS (Boot Device Selection Phase)：**
-   主要功能:
    -   根據 Boot Order 選擇開機裝置
    -   嘗試從選定的裝置載入 Bootloader (GRUB、Windows Boot Manager ...)
        -   可載入的 EFI 並不限於 OS Bootloader，也可以是其他的 EFI 應用程式
        -   UEFI Shell, Firmware Update Utility, Diagnostics Tool ...
    -   這個階段就提供使用者 Boot Menu 來選擇開機裝置
-   執行環境:
    -   繼續使用 DXE 階段建立的執行環境

> BDS 是使用者與 UEFI 互動的主要階段，包括 BIOS Setup 介面、Boot Menu 都在這裡處理
{: .block-tip }

**TSL (Transient System Load Phase)：**
-   主要功能:
    -   Bootloader 已經被 BDS 載入並執行
    -   將控制權交給 Bootloader，但在這個階段 UEFI Boot Services 仍然可用
    -   為 OS 準備好啟動環境

在這個階段 Bootloader 可以透過 UEFI 提供的 Boot Services 來存取硬體資源，
並建立 OS 所需的啟動環境，例如 Memory Map、ACPI Table 等。

> 此階段的關鍵是當 ExitBootServices() 被呼叫後，至此進入 Runtime Phase，由作業系統接管系統控制權。

> 在這個階段是 Bootloader 執行期間、ExitBootServices 之前的過渡階段，其實就是 BIOS 與 OS kernel 的交接點。
{: .block-tip }

**RT (Runtime Phase)：**
-   主要功能:
    -   OS 已經被載入並執行，在這個階段 UEFI Boot Services 不再可用
    -   但 UEFI Runtime Services 仍然可用，提供一些系統資訊與服務給 OS 使用
        -   UEFI Variable Services: 某些廠商的特殊功能變數 (RGB LED Control ...)
        -   RTC (Real-Time Clock) Read/Write
-   執行環境:
    -   由 OS 接管系統控制權，UEFI 僅提供 Runtime Services

> 在 ExitBootServices() 被呼叫後 BIOS 在 DRAM 中的區塊會被釋放，僅保留 Runtime Services 所需的部分

> RT 階段基本上就是 OS 執行期間，UEFI 僅提供有限的 Runtime Services 給 OS 使用
{: .block-tip }

**AL (After Life Phase)：**
-   主要功能:
    -   處理 OS 的關機或重啟請求
    -   S3 / S4 / S5 等電源狀態管理
    -   在這個階段 UEFI 會協助 OS 進行系統關機或重啟
-   執行環境:
    -   由 OS 控制系統電源狀態

> AL 階段主要是處理系統關機或重啟的相關工作，只負責 Reset 或 Power Off，為下一次開機做準備
{: .block-tip }

---

> 以上說明了一個 BIOS 在 PC 中的主要腳色與 UEFI 的各個階段功能概述，後續要研究的話可以從各個階段的細節開始著手，
> 了解每個階段的工作流程與技術細節。
{: .block-warning }

> ##### Last Edit
> 01-24-2026 18:36
{: .block-warning }