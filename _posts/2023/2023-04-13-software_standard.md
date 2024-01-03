---
title: "Note | Standard - ISO/IEC"
author: Benson Hsu
date: 2023-04-13
category: Jekyll
layout: post
tags: [software, software_qualitiy, standard]
---

>ISO/IEC 9126 Software engineering — Product quality was an international standard for the evaluation of software quality.
{: .block-tip }

### Intorduction

如果想得到高品質的軟體，就要先能夠對於軟體產品的品質能夠進行完整的描述，因此國際標準組織發布的ISO/IEC就是常被引用的軟體產品品質(Software Product Qualitiy)標準。  
這個標準的目標是去應對一些已知的人類偏見，這些偏見將可能會對軟體開發專案的交付和認知產生不利影響。這些偏見包括在項目開始後更改`優先順序`[1]或沒有任何清楚的`成功`[2]定義。 
所以通過明確說明與確定項目的`優先順序`，將抽象的概念轉化為可衡量的數值或指標。並且輸出數據可以根據`架構X(Schema X)`[3]進行驗證，不需要任何干預。  
目前最新的標準是 [ISO/IEC 25010:2011] 使用兩個模型來描述分別為 `使用品質(Quality in Use)` 與 `產品品質(Product Quality)`。 

1. 優先順序:  
    優先順序指的是軟體開發中各個任務、功能、需求等進行排序，以確定其相對重要性和優先級。
2. 成功:  
    就是對於項目目標的清晰定義和明確衡量標準的確立，以便能夠確定項目是否已經達到預期的成效與目標。
3. 架構X(Schema X):  
    任何特定的數據架構或格式，以驗證輸出數據是否符合標準。

### Product Quality

1. 功能適用性（Functional suitability）
    1.  功能完整性（Functional completeness）: 產品是否完整涵蓋了所有指定目標與任務的程度。
    2.  功能正確性（Functional correctness）: 產品提供具有所需精度或者相符的結果的程度。
    3.  功能適合性（Functional appropriateness）: 產品是否具有適當的功能完成指定工作的程度。
2. 性能效能（Performance efficiency）
    1.  時間行為（Time behavior）: 指一個產品或系統在執行其功能時的反應與吞吐率。
    2.  資源利用率（Resource utilization）: 產品在執行功能時使用的資源數量與類型。
    3.  容量(Capacity): 指產品或系統參數的最大負載或工作量限制。
3. 相容性（Compatibility）
    1.  共存（Co-existence）: 指一個產品在與產品共享環境與資源時，能有效執行其功能的程度，不會對其他產品產生負面影響。
    2.  互相操作性（Interoperability）: 指兩個或多個系統，產品間可以互相交換訊息並使用的程度。
4. 可靠性（Reliability）
    1.  成熟度（Maturity）: 產品在正常運行下滿足可靠性要求的程度。
    2.  可用性（Availability）: 產品在運行下可操作與可訪問性的程度。
    3.  容錯能力（Fault tolerance）: 盡管存在硬體或軟體故障，但軟體系統、產品或組件依然按造預期的運行的程度。
    4.  可恢復性（Recoverability）: 當發生中斷或故障時，軟體或系統能夠直接回覆受影響的數據並重新建立系統所需狀態的程度。
5. 易用性（Usability）
    1.  被識別的適當性（Appropriateness recognizability）: 用戶能夠識別產品或系統是否符合它們需求的程度。
    2.  易學習性（Learnability）: 產品或系統能夠使用戶在緊急情況下學習如何有效的使用他的程度。
    3.  吸引力（Operability）: 產品使用者能容易操作，控制與使用的程度。
    4.  用戶錯誤保護（User error protection）: 產品保護用戶不出錯的程度。
    5.  用戶介面美觀(User Interface aesthetics): 產品提供用戶介面美觀和滿意的程度。
    6.  可訪問性(Accessibility): 產品能使所有使用者都能使用的程度，如聽障、視障等特殊需求等。
6. 安全性（Security）
    1.  保密性(Confidentiality): 確保產品能確保資料只能被授權的人員訪問的程度。
    2.  完整性(Integrity): 產品、系統資訊在處理的過程中不被未經授權就修改，保持完整與正確的程度。
    3.  抵抗賴性(Non-repudistion): 確保產品在能證明已經發生的事件，以便未來行為不能被當事人抵賴的情況。
    4.  可追溯性(Accountability): 確保系統能追蹤與記錄所有活動與事件，以便追蹤與追責。
    5.  真實性(Authenticity): 確保資訊、系統、用戶的真實性與可信性，避免假冒、詐欺、冒用等問題的程度。
7. 可維護性（Maintainability）
    1.  模塊性(Modularity): 產品或系統由離散組件所完成，當組件產生更改對其他組件產生最小影響的程度。
    2.  可重複性(Reusability): 產品中的元件(類別、函數等)可被多次使用降低開發時間的程度。
    3.  可分析性(Analyzability): 產品可被容易的分析，發現潛在的問題或缺陷的程度。
    4.  可修改性(Modifiability): 產品可以容易地進行修改，並且這些修改可以不影響系統的其他部分。
    5.  可測試性(Testability): 產品可以容易地進行測試，以確保它的正確性和穩定性。
8. 可移植性（Portability）
    1.  適應性(Adapatability): 產品是否能適應不斷發展的硬體；軟體或使用環境的程度。
    2.  易安裝性(Installability): 產品能否在不同環境下安裝與配置並進行運行的程度。
    3.  可替換性(Replaceability): 在相同環境中用戶能找到其他相同目的的指定軟體的程度。

### Quality in Use
1. 效果（Effectiveness） 用戶實現特定目標的準確性和完整性。
2. 效率（Efficiency） 相對於用戶實現目標的準確性和完整性，所耗費的資源。
3. 滿意度（Satisfaction）
    1.  實用性（Usefulness）: 指用戶對實現實用目標的實現與使用結果和使用後果的滿意度。
    2.  信任性（Trust）: 用戶或其他相關者對於產品或系統按預期行為的信任程度。
    3.  愉悅性（Pleasure）: 指用戶從滿足個人需求中獲得的愉悅程度。
    4.  舒適性（Comfort）: 使用者在使用過程中，對於其身體上的舒適感受的滿意程度。
4. 無風險性（Freedom from Risk）
    1.  減輕經濟風險(Economic Risk Mitigation): 產品或系統在預期使用環境中減輕財務狀況、有效運營、商業財產、聲譽或其他資源的潛在風險的程度。
    2.  降低健康和安全風險(Health and Safety Risk Mitigation): 產品或系統在預期使用環境中降低對人體的潛在風險的程度。
    3.  降低環境風險（Environmental Risk Mitigation）: 產品或系統在其預期使用環境中減輕與環境相關的潛在風險的程度。
5. 涵構覆蓋（Context coverage）
    1.  涵構完整性（Context Completeness）: 在所有指定的使用環境中，產品或系統可以有效、高效、無風險和滿意地使用的程度。
    2.  靈活性（Flexibility）: 產品或系統在需求中最初指定的範圍以外的環境中可以有效、高效、無風險和滿意地使用的程度。

##### Advanced 

[John Estdale(2018), Applying the ISO/IEC 25010 Quality Models to Software Product, IEEE] 這篇論文則對標準中的各項特性做了說明與更進一步的探討，閱讀筆記 [Note Link]

> ##### NOTE
> Last edit 04-17-2023 12:32  
{: .block-warning }

[ISO/IEC 25010:2011]: https://www.iso.org/standard/35733.html
[John Estdale(2018), Applying the ISO/IEC 25010 Quality Models to Software Product, IEEE]: https://link.springer.com/chapter/10.1007/978-3-319-97925-0_42
[Note Link]: https://hotshot824.github.io/jekyll/2023-04-18-applying_isoiec25010.html