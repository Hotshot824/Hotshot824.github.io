---
title: "Backend | Database Scale Out"
author: Benson Hsu
date: 2026-03-31
category: Jekyll
layout: post
tags: [software, database]
---

> 後端處理中心的 Database Scale Out 是一個重要的議題，相較於 Web Application 無狀態的水平擴展，
> Database 的水平擴展會困難的多，Database 需要維持 ACID 的特性。
{: .block-tip }

### 1. Overview

> [CAP Theorem] (Consistency, Availability, Partition Tolerance)
{: .block-tip }

既然在多個節點上使用 Database 也就是分散式儲存，對於分散式儲存的設計來說核心原則就是 [CAP Theorem]，也就是說在分散式系統中，無法同時滿足一致性 (Consistency)、可用性 (Availability) 和分區容錯性 (Partition Tolerance)，只能選擇其中的兩個特性來優先考慮。

[CAP Theorem]: https://en.wikipedia.org/wiki/CAP_theorem

[ACID] 是 Database 在關聯式資料庫中維持資料一致性和可靠性的四個基本特性，分別是:

1.  Atomicity (原子性): 交易中的所有操作要麼全部完成，要麼全部不完成
    -   如果交易中的任何一個操作失敗，整個交易都會被回滾，資料庫將保持不變
    -   交易沒有中間狀態，要麼完全成功，要麼完全失敗
2.  Consistency (一致性): 交易必須使資料庫從一個一致的狀態轉換到另一個一致的狀態
    -   當前一個交易完成後，資料庫應該處於一致的狀態，下一個交易開始前，資料庫也應該處於一致的狀態
3.  Isolation (隔離性): 交易的執行不應該受到其他交易的干擾
    -   交易應該像是獨立執行的一樣，即使多個交易同時執行，也不應該互相干擾
4.  Durability (持久性): 一旦交易完成，對資料庫的修改應該是永久性的，即使系統崩潰也不會丟失

如果要把 Database 分散到多個節點上，要維持上面所說的特性非常困難，尤其是在分散式系統中，
網路延遲、節點失效、資料同步等問題都會對 ACID 的維持造成挑戰。

Database 遵從 [ACID] 代表優先考慮資料庫的一致性而非可用性，當然也可以遵從 [BASE]，優先考慮可用性，資料只保證最終會達到一致性，
因此可能會有不一致的狀態存在，但這樣就不適合用在需要強一致性的場景，例如金融交易系統。

> [BASE] (Basically Available, Soft state, Eventual consistency) 強調系統的可用性和彈性，而不是強一致性

[BASE]: https://en.wikipedia.org/wiki/Eventual_consistency

[ACID]: https://en.wikipedia.org/wiki/ACID

> 我們可以說 BASE 是選擇 CAP 中的 AP 模式，而 ACID 是選擇 CP 模式
{: .block-warning }

---

### 2. Master-Slave Replication

> 從資料庫的行為來看，可以分為讀取和寫入兩種操作，Master-Slave 就是針對這兩種需求的明確分工
{: .block-tip }

Master-Slave Replication 是一種常見的資料庫擴展策略，其中 Master 節點負責處理所有的寫入操作，
而 Slave 節點則負責處理讀取操作。在常見的 CRUD 操作中，讀取操作通常比寫入操作更頻繁，
因此這種架構可以有效地分散讀取負載，提高系統的整體性能。

![](/image/2026/03-31-database_scale_out/1.jpg)

> 當 Master 故障或不可用時，Slave 節點可以被提升為新的 Master 節點，以確保系統的可用性

**Advantages:**
-   架構相對來說簡單，是比較容易實現的 Database Scale Out 策略
-   所有節點的資料都是相同的，不需要修改資料模型

**Disadvantages:**
-   寫入依然受限於 Master 節點的性能，無法真正實現寫入的水平擴展
-   Slave 節點的資料是從 Master 節點複製過來因此可能會是 Replication Lag 的狀態

**Use Cases:**
-   適用於讀取操作遠多於寫入操作的場景
-   例如: 不需要即時性的查詢，統計報表、歷史資料查詢等

在 MariaDB 通常使用 Binlog 來實現 Master-Slave Replication，Master 節點會將所有的寫入操作記錄在 Binlog 中，Slave 節點則會定期從 Master 節點拉取 Binlog 並執行其中的操作，以保持資料的一致性。

---

### 2.1 Master-Master Replication

> 既然 Master-Slave 的架構中寫入依然受限於 Master 節點的性能，那麼我們可以考慮讓多個 Master 節點同時處理寫入操作，這就是 Master-Master Replication
{: .block-tip }

雖然概念上多個 Master 好像就能解決寫入的瓶頸問題，但實際上 Master-Master Replication 的實現非常複雜，
多個 Writer 之間的資料同步和衝突解決是一個非常大的挑戰，尤其是在高併發的場景下，資料衝突的機率會大大增加。

-   多個 Master 節點之間的資料一致性非常困難，通常會違背 ACID 的特性或是為了同步而提高寫入的延遲
-   越多的 Master 節點，只會導致延遲越高，資料衝突的機率越大

在 Master-Slave 保持同步只要保持 Slave 從 Master 拉取 Binlog 就可以了，但在 Master-Master 的架構中有可能產生資料衝突，
例如兩個 Master 節點同時寫入相同的資料，這就需要一個機制來解決衝突，這是一大挑戰。如果處理得不好有可能效能比單一 Master 節點還差。

![](/image/2026/03-31-database_scale_out/2.jpg)

> 加入越多的 Master 節點，資料衝突的機率就會越大，延遲也會越高

對於 Master-Master Replication 或者 Master-Slave Replication 的架構來說，都會有以下的缺點:
-   在 Copy 還沒完成之前如果節點故障了，有可能喪失資料
-   有越多 Replication 節點，要複製的資料就越多，延遲也會越高
-   如果 Master 節點的寫入量非常大，Slave 節點可能會無法跟上 Master 的寫入速度，導致 Replication Lag 的問題
    -   在現代資料庫通常已支援 Multi-Threaded 並行複製來減少 Replication Lag 的問題，但在高併發的場景下仍然可能會有延遲
    -   Slave 也可能為了處理資料同步的問題導致當下無法提供太多的讀取服務

> 雖然透過增加 Replication 節點可以提升系統的可用性與讀取能力，但這並不代表系統可以無限制地擴展，增加過多的 Replication 節點可能會導致系統的性能下降

> ##### Last Edit
> 03-31-2026 17:04
{: .block-warning }