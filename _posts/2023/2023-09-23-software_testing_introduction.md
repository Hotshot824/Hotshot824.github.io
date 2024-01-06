---
title: "Testing | Software Testing Introduction"
author: Benson Hsu
date: 2023-09-23
category: Jekyll
layout: post
tags: [software, software_qualitiy]
---

> Software testing course notes from CCU, lecturer Nai-Wei Lin.  
> 軟體測試是確保軟體品質的重要過程，這個過程確保軟體產品符合預期的需求，並確保軟體產品無缺陷，這裡介紹軟測的基礎概論。
{: .block-tip }

### 1.1 What Is Software Testing

測試是確表品質的方法之一，Software quality assurance(軟體品質保證)涉及 **Validation(確效)/Verification(驗證)**軟體
-   **Validation**: 確效客戶的 Requirements 與設計出的 Specification 一致
    -   Do we build the right software?
-   **Verification**: 驗證開發的 Implementation 與設計出的 Specification 一致
    -   Do we build the software right?

而軟體測試主要著重在 Verification 這部分，Validation 是設計端要處理的問題

> 延伸閱讀 [Wiki: Verification and validation]

##### 1.1.1 Software Verification

Verification 也分為 Statically(靜態)與 Dynamically(動態)
-   **Statically**: 靜態驗證並不執行軟體下進行，它包含 review, inspection, walkthrough, analysis 等技術。
    -   靜態驗證主要關注預防缺陷，通常需要有一定的開發經驗的測試人員來進行
-   **Dynamically**: 動態驗證會執行軟體，它包含各種測試技術
    -   動態驗證主要關注找出和修復缺陷，動態測試系統的功能行為，Memory/CPU 使用情況以及系統的整體性能

而在 Software testing 這門課中大部分關注的是 Dynamically 這部分的實作

> 延伸閱讀 [Static Testing vs. Dynamic Testing]

##### 1.1.2 Software testing

要注意的是軟體測試並不能證明軟體是完全正確的，軟體測試僅能從體中找到盡可能多的錯誤。因為軟體測試只是識別軟體中潛在的錯誤，而不是證明軟體是正確的。

**Error, Fault, Failure, and Incident**

-   Error(錯誤): 是人為所犯的錯誤
-   Fault(故障): 是文件或程序中的 **Error** 的結果
-   Failure(失敗): 當 **Fault** 被執行時就會發生 **Failure**，Fault 的執行導致程式無法執行預期的功能或結果
-   Incident(事件): 當 **Failure** 發生時，用戶可能不會馬上發現，一個 **Incident** 提醒用戶 Failure 的發生

> 延伸閱讀 [Software Testing – Bug vs Defect vs Error vs Fault vs Failure]

**Test Case**

Software testing 是執行一組測試案例(Test Case) 的行為，以便能夠找出程式中的 Fault。
-   一組 Test case 包含一個測試輸入列表和一個相應的預期輸出列表
-   每個 Test case 都設計來檢查程序的某種特定功能或行為

<div align="center">
  <img src="../assets/image/2023/09-23-software_testing_introduction/1.png"  
  width="75%" height="75%">
</div>

> 軟體測試的生命週期，代表了各個步驟所產生的錯誤與錯誤追蹤

**Why Do We Need Software Testing**

-   Software prevails in our living environment. Quality of software significantly influences our quality of life.
-   Software faults in critical software systems may cause dramatic damages on our lives and finance.

Carefully made programs have 5 faults per 1000 lines of code (LOC). Windows XP has 45M LOC, so it may have **225000** faults.

---

### 1.2 How Do We Do Software Testing

但是在進行 Testing 前應該要先了解 Testing 到底在測試什麼? Test case 理想的狀況下應該是 Specification ∪ Implementation 的範圍，這樣就能找出所有不合規範的 Fault。

<div style="display: flex; flex-direction: row;">
    <img src="../assets/image/2023/09-23-software_testing_introduction/2.png" 
    width="50%" height="50%">
    <img src="../assets/image/2023/09-23-software_testing_introduction/3.png" 
    width="50%" height="50%">
</div>

-   **Faults of comission**(錯誤的委任): 實際的軟體開發往往都會有超出規格的部分，可能是需求變更或者是在實現功能時遇到了未預見的挑戰。
-   **Faults of omission**(錯誤的遺漏): 同樣的開發中也有可能會有規格被遺漏的情況，可能是規格上的錯誤、技術挑戰、時間壓力等原因造成。

##### 1.2.1 Test case

**Test Case** 涉及兩個主要問題，如何 Test case generation(產生測試案例)、如何 Test case execution(執行測試案例)

**Test case execution**: 輸入 Input 至 Software 後得到 Expected output 與 Output 進行比對來決定是 Incident/Correct

<div align="center">
  <img src="../assets/image/2023/09-23-software_testing_introduction/4.png"  
  width="50%" height="50%">
</div>

> Excution 目前幾乎都依賴於測試框架來幫助執行，這點之後會再介紹

**Test case generation**: 要確認測試案例有兩種方式
-   *[Black-box testing]*(Function testing): 軟體被視為一個黑盒子，從規格中描述的功能確定測試案例
-   *[White-box testing]*(Stucture testing): 軟體被視為一個白盒子，從實施的程式的結構確定測試案例

**Fuctional Testing vs Structure Testing**
-   Black-box 從 Specification 的角度來設計 Test case 因而較難覆蓋到未被規定的行為(Faults of comission)
-   White-box 從 Implementation 的角度來設計 Test case 因而較難覆蓋到未被實現的行為(Faults of omission)
-   因此兩種方法都不足夠，只有兩種方法都使用才能盡可能的覆蓋 Specification ∪ Implementation

<div style="display: flex; flex-direction: row;">
    <img src="../assets/image/2023/09-23-software_testing_introduction/5.png" 
    width="50%" height="50%">
    <img src="../assets/image/2023/09-23-software_testing_introduction/6.png" 
    width="50%" height="50%">
</div>

> 試想在未學習軟體測試前是怎麼去寫 Testing? 我幾乎都是從結構去出發，已現有的程式去開發測試案例，因為壓根就沒設計完整的規格。

##### 1.2.2 Tracking of incidents

**Incident tracking system**(事件追蹤系統)負責追蹤所有需要修復的 Incidents(事件)，確保所有事件都得到妥善解決

-   需要知道事件的相關人員，應在事件報告後不久得知
    -   這意味著系統應該能夠迅速地通知相關人員有關新的事件，確保所有相關人員都能及時獲得最新的信息，並可以立即開始處理事件
-   不會有事件因為被遺忘而未修復
    -   系統會持續追蹤每一個事件，直到它被修復，防止任何事件被忽視或遺忘
-   不會因單一程序員的一時興起而未修復某個事件
    -   修復事件的決定不應該只取決於一個人的主觀意願，而應該基於對事件的客觀評估和團隊的共識
-   減少因為溝通不良而未修復的事件
    -   這表示系統應該促進良好的溝通，以防止因為溝通問題導致事件未能被修復

##### 1.2.3 Regression testing

**Regression testing**(回歸測試) 重複使用測試案例來測試更改後的軟體，確保之前正常運行的部分沒有被影響造成新的錯誤，既有功能應繼續如常運行。
回歸測試可以在不同的測試階段應用，例如整合測試或系統測試，具體取決於測試案例的細分程度和需求。通常它們被放置在整合測試和系統測試中。

Regression testing 有以下特性，使其在軟體測試中有重要地位:

1.  確保穩定性: 回歸測試確保新的軟體變更不會對現有的功能造成負面影響，確保軟體的整體穩定性和品質
2.  節省時間和成本: 自動化回歸測試可以節省大量的測試時間，特別是對於長期的軟體開發專案或需要頻繁進行版本更新的情況。因為不需要手動執行重複性的測試案例，有助於降低測試成本
3.  快速反饋: 回歸測試可以在每次軟體變更之後迅速運行，提供關於變更對軟體的影響的即時反饋，有助於快速識別並解決問題，從而提高開發效率

Regression testing 也具有一些挑戰: 

1.  初期自動化成本: 為了實現自動化回歸測試，需要將測試案例轉化為自動化程式，會造成相當大的工作量和成本
2.  維護成本高: 維護回歸測試套件需要時間和資源。當軟體變更頻繁時，測試套件更新會產生相當的維護成本
3.  執行時間: 如果回歸測試的測試案例變得過多，可能需要較長的時間才能完全執行，可能會對開發流程產生延遲，需要仔細計劃和管理回歸測試的執行時間

> 延伸閱讀 [【D13】測試類型介紹:回歸測試]

##### 1.2.4 Levels of testing

**Levels of testing**(測試的各個階段)主要包括以下幾個:

1.  **Unit Test**(單元測試): 這是最基本的測試階段，主要針對最小單元進行測試，確保每個獨立的部分都能正常運作
2.  **Integration Testing**(整合測試): 此階段針對跨物件或模組進行測試，以確保各個模組之間的交互作用能夠正常運作
3.  **System Testing**(系統測試):系統測試是一種風險測試，目的是確定整個系統是否滿足特定的功能性和非功能性需求，測試環境需盡可能和正式上線的環境一致
4.  **Acceptance Testing**(驗收測試): 也被稱為 UAT(使用者接受度測試)，這是最後一個測試階段，會模擬真實使用者情境來驗證軟體是否符合使用者的需求和期望

每一個階段都有其特定的目標和重點，且需要根據具體情況來選擇最適合的策略和方法2。

<div align="center">
  <img src="../assets/image/2023/09-23-software_testing_introduction/7.png"  
  width="75%" height="75%">
</div>

> 延伸閱讀 [【D11】 實例簡述:測試四階段與測試方法]

---

### 1.3 Costs of Software Quality

軟體測試的成本可以分為兩種，Control Costs(控制成本)，Failure of Control Costs(失敗控制成本)

-   **Control Costs**:
    -   Prevention costs(預防成本): 包括投資於品質基礎設施和品質活動的費用，這些投資並未針對特定的項目或系統，而是對整個組織通用
    -   Appraisal costs(評估成本): 包括為特定項目或系統執行的活動的費用，目的是為了檢測軟體錯誤
-   **Failure of Control Costs**:
    -   Internal failure costs(內部失敗成本): 包括修正設計審查、軟體測試和驗收測試中檢測到的錯誤的成本，在軟體安裝到客戶端之前完成
    -   External failure costs(外部失敗成本): 包括修正客戶或維護團隊在軟體系統安裝後檢測到的所有失敗的成本

<div align="center">
  <img src="../assets/image/2023/09-23-software_testing_introduction/8.png"  
  width="75%" height="75%">
</div>

> 應該保持在 Optimal software quality level 這個標準之上，Control costs 減少不會讓軟體品質的總成本下降

-   **Test coverage criteria**(測試覆蓋率標準)，這是一種衡量軟體測試深度的指標，用於確定已經測試了軟體的哪些部分，以及還有哪些部分尚未進行測試，它可以幫助我們確定何時可以停止軟體測試
-   軟體品質成本影響軟體品質水平，投入確保軟體品質的資源會直接影響軟體的最終品質
    -   例如: 如果我們投入更多的資源進行測試，那麼可能會發現更多的錯誤，從而提高軟體的質量
-   根據可用的軟體品質資源來確定何時停止軟體測試，
    -   例如: 如果我們的資源有限，那麼我們可能需要在達到一定的測試覆蓋率後就停止測試

> ##### NOTE
> 本篇只是講述軟體測試的概論，後續會再討論各個章節的細節  
> Last edit 09-24-2023 15:50
{: .block-warning }

[Wiki: Verification and validation]: https://en.wikipedia.org/wiki/Verification_and_validation

[Static Testing vs. Dynamic Testing]: https://www.javatpoint.com/static-testing-vs-dynamic-testing

[Software Testing – Bug vs Defect vs Error vs Fault vs Failure]: https://www.geeksforgeeks.org/software-testing-bug-vs-defect-vs-error-vs-fault-vs-failure/

[Black-box testing]: https://en.wikipedia.org/wiki/Black-box_testing
[White-box testing]: https://en.wikipedia.org/wiki/White-box_testing

[【D11】 實例簡述:測試四階段與測試方法]: https://ithelp.ithome.com.tw/articles/10324641
[【D13】測試類型介紹:回歸測試]: https://ithelp.ithome.com.tw/articles/10326252