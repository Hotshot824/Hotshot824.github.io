---
title: "Testing | System Testing"
author: Benson Hsu
date: 2023-12-20
category: Jekyll
layout: post
tags: [software, software_qualitiy]
---

> Software testing course notes from CCU, lecturer Nai-Wei Lin.  
> 前面講的部分都是如何去產生測試案例，這裡會介紹 Mutation Testing，這是一種可以評估測試案例的方法
{: .block-tip }

System Testing 通常是在 Integration Testing 之後，並且是內部測試的最後一個階段，因此此時通常會在一個完整的系統(包含軟體與硬體)上進行，
用來評估系統是否符合其需求規格。

系統測試通常是屬於黑箱測試的範疇，因此不需要對程式碼或邏輯的內部設計有所了解。

### System Testing

[8.2 Performance Testing](#82-performance-testing)  
[8.3 Load Testing](#83-load-testing)  
[8.4 Stress Testing](#84-stress-testing)

##### 8.1 System Testing

-   系統測試所使用的輸入資料是所有已經成功完成集成測試的整合軟體組件。
-   這是 User acceptance testing(使用者驗收測試)前的最後一個階段，也就是最後的內部測試階段。

在這個階段測試可以採用一種接近破壞性的測試方式，這代表測試不僅僅侷限於驗證系統是否符合需求規格，也會去驗證系統是否能夠承受極端的使用情境，還是否能符合預期。

-   因此在這個階段測試軟體/硬體在要求規格中所定義的邊界，甚至超出邊界的情況

**Types of System Testing**

-   性能測試(Performance testing)
-   負載測試(Load testing)
-   壓力測試(Stress testing)
-   可用性測試(Usability testing)
-   安全測試(Security testing)

---

##### 8.2 Performance Testing

-   性能測試的目標不是發現錯誤，而是消除性能瓶頸並為未來的回歸測試建立基準
-   進行性能測試代表需要一個可以謹慎控制的測量與分析的過程
-   理想情況下是正在測試的軟體已經足夠穩定，使這個過程可以專注於性能問題

以下會介紹性能測試的重要步驟

**Set of Expectations**

-   一套清晰定義的預期結果對於有意義的性能測試至關重要，如果測試者根本不知道在性能方面要達到什麼目標，
那麼在測試過程中所採取的任何行動都是毫無意義的
-   例如: 對於一個網路應用程式，至少要知道兩件事
    1.  在一個給定的時間內，系統應該能夠處理多少個同時連線的使用者
    2.  系統應該能夠在多少時間內回應使用者的請求

**Looking for Bottlenecks**

-   一旦已經了解想到達到的目標，就可以開始不斷增加系統的負載來開始測試，同時尋找系統中的瓶頸
-   例如: 以之前的網路程式為例
    -   這些瓶頸可以存在於多個層面上，為了找到這些瓶頸，可以使用各種工具來監控系統的狀態

這是一些工具的例子:
-   *Application level:* Developer 可以使用一些分析工具來找出程式碼中的低效之處
-   *Database level:* 使用特定於資料庫的分析器與查詢優化
-   *Operating system level:* System Engineer 可以使用如 top, vmstat, iostat(on Unix) 或者 PerfMon(on Windows) 之類的工具來監控硬體資源，
CPU, memory, swap space, disk I/O, network I/O 等等...
-   *Network level:* Network Engineer 可以使用如 tcpdump, Wireshark, iptraf 之類的封包嗅探器，網路協議分析器如 ethereal，
以及各種工具如 netstat, MRTG, ntop, mii-tool 等等...

**Performance Tuning**

-   當 Load testing 的結果顯示系統效能沒有達到預期目標時，就是進行調整的時候了，假設從 Application/Nework level 開始
    -   這時就要確保程式碼中沒有低效之處
    -   確保程式碼中沒有不必要的 DB Query，並且 DB 在特定的 OS/Hardware 上的配置下是最佳化的

**JUnitPerf**
-   實踐 TDD(Test-Driven Development) 的開發者會發現，像是 Mike Clark 所寫的 JUnitPerf 這樣的工具在 JUnit 中是非常有用的，
他可以通過增加 Load testing 和增加計時測試功能來增強現有的單元測試代碼
-   一旦重構某個特定函數或方法後，就可以使用 JUnitPerf 來確保其性能沒有受到影響，Mike Clark 稱其為 **Continuous Performance Testing**(持續性能測試)

> 延伸閱讀: [JUnitPerf]

當然有可能即使 Application level 的程式碼已經是最佳化的，但是系統的瓶頸還是存在於其他層面，因此系統的性能還是沒有達到預期目標，
那麼在前面討論過的所有 Level 上都還有許多調整工作可以進行

-   這裡列出一些可能的方法，這些方法都不局限於軟體的 Source code
    -   Use Web cache mechanisms, such as the one provided by Squid.
    -   Publish highly-requested Web pages statically, so that they don't hit the database.
    -   Scale the Web server farm horizontally via load balancing.
    -   Scale the database servers horizontally and split them into read/write servers and read-only servers, 
    then load balance the read-only servers.
    -   Scale the Web and database servers vertically, by adding more hardware resources (CPU, RAM, disks).
    -   Increase the available network bandwidth.

**One Variable at a Time**

> 這裡就跟機器學習中的 Hyperparameter tuning 一樣，以列舉的方式來找出最佳的參數，並且一次只會調整一個參數
{: .block-warning }

-   進行性能測試時，有時更像是一種藝術而不是科學，因為有太多的變數需要考慮，而且這些變數之間的關係也很複雜
    -   每次調整效能時，必須警慎的一次修改一個變數，並再次測量數據

**Staging Environment**

-   通常會有一個獨立的環境，用來進行性能測試，這個環境通常稱為 Staging Environment
-   這個環境或許不能複製 Production Environment 的所有特性與效能，但是至少要能夠模擬 Production Environment 的行為
    -   在這個預期之下系統的預期性能可以相應的進行縮放

> 現在測試的環境通常都是在雲端上，因此可以很容易的進行縮放

**Baseline**

在運行時要尊從「Run load test -> Measure performance -> Tune System」 的循環重複進行，直到被測試的系統達到預期的效能為止。
-   並且要在系統中建立一個 Baseline，這個 Baseline 代表系統在預期的負載下所能達到的效能
-   這是為了在 Regression Testing(回歸測試)中，可以透過這個 Baseline 來衡量系統的效能表現

**Benchmarks**

另一種方式是建立一個 Benchmark，這個 Benchmark 代表系統在預期的負載下所能達到的效能，並且這個 Benchmark 會被用來衡量系統的效能表現
-   這就很像手機每次發表新的型號時，都會使用 AnTuTu Benchmark 來衡量其效能表現一樣
-   各家廠商可能會去針對這個 Benchmark 進行優化，好拿到更好的成績

---

##### 8.3 Load Testing

在測試相關的文章中，Load testing 通常被定義: 「通過向被測系統提供他所能夠操作的最大任務來進行系統練習的過程」

Load testing 有時也被稱作 Volume testing(容量測試)或者 Longevity/Endurance testing (耐久性/持久性測試)

**Example of Volume Testing**

-   通過編輯一個非常大的文件來測試一個文字編輯器
-   通過向打印機發送一個非常大的文件來測試一個打印機
-   對於一個 Mail Server，通過向其發送大量的郵件來測試容量
-   這裡有一個特別的測試是 Zero-volume testing，這是一種測試，用來測試系統被提供空任務時的行為

**Example of Longevity/Endurance testing**

-   通過長時間內讓 Clien 對 Server 進行循環發送請求來測試一個 Client-Server 系統

> 延伸閱讀: [Volume testing]

**Goals of Load Testing**

Load testing 的目標如下
-   檢查再粗略的測試中不會被發現的錯誤，例如: Memory management bugs, Memory leaks, Buffer overflows, etc.
-   確保系統能滿足性能測試中建立的 Performance baseline
-   這些都是通過指定的最大負載下對程式運行回歸測試來完成的

**Performance vs. Load Testing**

-   Performance testing 通常使用負載測試技術和工具來進行測量與建立 Baseline, 或使用 Benchmark 來進行測量
-   Load testing 是在一個預定地負載下對系統進行測試，通常是系統在仍然能正常運作下可以承受的最大負載

> 注意 Load testing 並不是通過壓倒性的負載來破壞系統，而是試圖讓系統能像一台嚴密潤滑的機器一樣運作

**Large Datasets**

-   在 Load testing 中**「大型的資料集是非常重要的」**
-   因為很多重要的錯誤只有在處理非常大的實體時才會出現:
    -   LDAP/NIS/Active Directory 中成千上萬的使用者，成千上萬的 mailboxes，Database 中的 multi-gigabyte tables，File 上的超深層文件/目錄等等...

---

##### 8.4 Stress Testing

Stress testing(壓力測試)是試圖通過壓倒系統資源或從系統中奪走資源來破壞被測系統(也被稱為負面測試 Negative testin)。

-   這種測試的目的是確保系統能夠在壓力下能夠 Graceful Failure(優雅的失敗)並恢復，這種被稱為 Recoverability(可恢復性)的能力。
-   在 Performance testing 中，系統的負載是在可控的情況下，但壓力測試則需要引入混亂與不可控性

**Example of Stress Testing**

-   將一次可以連線的最大用戶數量翻倍
-   隨便拔除 Server 中的網路線，例如透過 SNMP 來控制
-   斷開 Database 的連線，然後重新啟動
-   系統運行中拔掉硬碟，然後重新插入新的硬碟重組 RAID
-   在伺服器上運行其他會強佔消耗資源的 Process

**Goals of Stress Testing**

-   Stress testing 不僅僅是為了破壞系統而破壞他，而是讓測試人員觀察系統對失敗的反應
    -   是否有保存狀態，還是直接崩潰
    -   是中斷狀態後恢復，還是優雅的失敗
    -   重啟後，他能從最後一個狀態恢復嗎
    -   是否有向用戶提供有用的 Log 訊息，還是顯示難以理解的 Hex dump
    -   因為意外的失敗，系統的安全性是否受到威脅

> ##### Last Edit
> 1-2-2024 05:23 
{: .block-warning }

[JUnitPerf]: https://github.com/clarkware/junitperf

[Volume testing]: https://testsigma.com/blog/volume-testing/