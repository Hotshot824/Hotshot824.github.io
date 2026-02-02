---
title: "Note | I2C Introduction"
author: Benson Hsu
date: 2026-01-17
category: Jekyll
layout: post
tags: [i2c, embedded]
---

> I2C 全名為 (Inter-Integrated Circuit)，是一種串列通訊匯流排，由 Philips 在 1980 年代開發，用於主機板、嵌入式系統用於連接低速周邊裝置而發展。
{: .block-tip }

> Reference: [成大資工 I2C: Inter-Integrated Circuit], [Getting Started with STM32 - I2C Example]

[成大資工 I2C: Inter-Integrated Circuit]: https://wiki.csie.ncku.edu.tw/embedded/I2C?revision=5e42ddc4b3a26836bde79930f3b4e6fe69d14cc0

[Getting Started with STM32 - I2C Example]: https://www.digikey.tw/zh/maker/projects/getting-started-with-stm32-i2c-example/ba8c2bfef2024654b5dd10012425fa23

### 1. I2C Introduction

首先要記住 I2C 是一種同步串列通訊協定，在嵌入式系統常見的通訊協定有 SPI、UART、I2C 三種，
在使用場景上通常會有以下分類：

1.  I<sup>2</sup>C：適合連接多個低速裝置，使用兩條線 (SDA、SCL)，支援多主多從架構，適合短距離通訊。
    -   低速周邊裝置：多個溫度感測器、RTC、EEPROM
    -   可以只要用兩條線就能連接多個裝置，節省 GPIO 腳位
2.  SPI：適合高速通訊，使用四條線 (MOSI、MISO、SCLK、SS)，支援全雙工通訊，適合較長距離通訊。
    -   高速周邊裝置：高速感測器如: 觸控、螢幕、SD Card ...
    -   全雙工並且高速，實作簡單，Protocol 需要自訂封包格式
3.  UART：適合點對點通訊，使用兩條線 (TX、RX)，不需要時鐘訊號，適合長距離通訊。
    -   點對點裝置：Debug Console、Bootloader 傳輸韌體
    -   非同步通訊，適合長距離通訊，但需要額外的協定來確保資料完整性 (Error bit ...)

> I2C 的應用場景通常是連接多個低速週邊裝置，並且只要使用兩條線就能達成通訊，節省 GPIO 腳位。
{: .block-tip }

> 同步代表通訊雙方會共享一個時鐘訊號 (SCL)，以確保資料傳輸的同步性。不用像 UART 需要確認雙方的傳輸速率 (Baud Rate) 是否一致。
{: .block-warning }

**I2C Bus**

![](https://wiki.csie.ncku.edu.tw/embedded/i2c_structure.gif)

I2C 主要由 SDA (Serial Data Line) 與 SCL (Serial Clock Line) 兩條線組成，SDA 負責傳輸資料，SCL 負責提供時鐘訊號。
由於要連接多個裝置，因此會有定址空間，I2C 裝置會有一個唯一的 7-bit 或 10-bit 位址，用於識別不同的裝置。

> 定址空間要去除保留位址 (Reserved Address)，例如 7-bit 位址中，0x00 與 0x7F 是保留位址，不能用於裝置定址。因此最多只能支援 2<sup>7</sup> - 2<sup>4</sup> = 112 個裝置。
{: .block-danger }

I2C 是主從式 (Master-Slave) 通訊協定，主裝置 (Master) 負責產生時鐘訊號並控制通訊流程，從裝置 (Slave) 回應主裝置的請求。
因此所有的主動發起通訊的裝置都必須是主裝置，而從裝置只能被動回應。

I2C 的 I/O 通常是 Open-Drain (或 Open-Collector)，這表示裝置只能將線路拉低 (Low)，而無法主動拉高 (High)。 因此需要外部的上拉電阻 (Pull-up Resistor) 將線路拉高，確保線路在閒置狀態下為高電位。

> I2C 通常使用 5v 或 3.3v 的電壓等級，具體取決於所使用的 microcontroller 與周邊裝置的規格。

---

### 2. I2C Transmission

I2C 的資料傳輸包含四個部分: 啟動條件 (Start Condition)、位址傳輸 (Address Transmission)、資料傳輸 (Data Transmission)、
停止條件 (Stop Condition)。注意 I2C 是傳輸協議，不是資料協議，因此資料的封包格式需要自行定義。每次傳送與接收都需要事先定義好資料格式。

> 傳輸與接收的的處理需要事先定義好資料格式 (Data Frame)，I2C 本身並沒有定義資料的封包格式。
{: .block-tip }

1.  I2C 在 Idle 狀態下，SDA 與 SCL 都為高電位。
2.  啟動條件 (Start Condition)：主裝置將 SDA 從高電位拉低，同時 SCL 維持高電位，表示開始一個新的傳輸。
3.  位址傳輸 (Address Transmission)：主裝置傳送從裝置的位址 (7-bit 或 10-bit)，並附加一個讀/寫位 (R/W bit)，表示是要讀取還是寫入資料。從裝置收到位址後，會回應一個確認位 (ACK bit)。
4.  資料傳輸 (Data Transmission)：主裝置與從裝置根據 R/W bit 進行資料傳輸。每次傳送一個位元組 (8 bits)，傳送後從裝置會回應一個確認位 (ACK bit)。可以連續傳送多個位元組。
5.  停止條件 (Stop Condition)：主裝置將 SDA 從低電位拉高，同時 SCL 維持高電位，表示結束傳輸。

下圖是 TMP102 溫度感測器的 I2C 通訊範例，包含讀取溫度資料的流程:
![](/image/2026/01-17-I2C_introduction/1.jpg)

SCL 會在每次位元傳輸前產生一個時鐘週期，確保資料的同步性。只有 SCL 為低電位時，SDA 的狀態才可以改變，SCL 為高電位時，SDA 的狀態必須保持穩定。
I2C 的資料讀取在 SCL 上升沿 Low -> High 時進行取樣。

> 唯一可以在 SCL 為高電位時改變 SDA 狀態的情況是啟動條件與停止條件，這兩個條件用來標示傳輸的開始與結束。
> 這樣在設計上可以區分資料傳輸與控制訊號，確保通訊的正確性。
{: .block-danger }

**ACK/NACK**

在每次位元組傳輸後，接收端需要回應一個確認位 (ACK bit) 或非確認位 (NACK bit)。
ACK 表示資料已正確接收，NACK 表示資料接收失敗或不需要更多資料。

在資料傳輸後 SCL 下一個週期中，接收端可以透過 SDA 線回應 ACK 或 NACK:
1.  ACK: 接收端將 SDA 拉低，表示資料已正確接收。
2.  NACK: 接收端將 SDA 維持高電位，表示資料接收失敗或不需要更多資料。

在這之後的 SCL 週期則會繼續進行下一個 Byte 的傳輸或結束傳輸。

通常 Embedded System 在寫這類 Tramsmission Code 時，都是使用 FSM (Finite State Machine) 的方式來實作 Communication Protocol。例如 UART 通常 4 個 State: IDLE、START、DATA、STOP。I2C 則依照傳輸設計的不同，State 數量會更多。例如: IDLE、START、ADDRESS、ACK、DATA、ACK/NACK、STOP 等等。

> 例如多個 8051 沒有 I2C IP，需要透過 GPIO 模擬 I2C 通訊協定來讀取多個 I2C 溫度感測器的資料，
> 而不同 I2C 裝置上都需要設計好 FSM 來處理 I2C 傳輸流程。
{: .block-tip }

> 這裡簡單紀錄 I2C 通訊協定的基本概念與傳輸流程，至少在面試上能回答 I2C 是什麼、有什麼應用場景、基本傳輸流程。
> 詳細的 I2C 細節可以繼續看成大資工的 I2C 教學文章。
{: .block-warning }

> ##### Last Edit
> 01-17-2026 18:36
{: .block-warning }

[How to write a TableGen backend]: https://llvm.org/devmtg/2021-11/slides/2021-how-to-write-a-tablegen-backend.pdf