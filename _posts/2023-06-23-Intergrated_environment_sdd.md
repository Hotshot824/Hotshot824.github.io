---
title: "Paper | An Integrated Environment for Specification Driven Development (Unfinished)"
author: Benson Hsu
date: 2023-06-23
category: Jekyll
layout: post
tags: [software, software_qualitiy, software_development]
---
 
> CHANG CHUNG-YEN, "An Integrated Environment for Specification Driven Development", 2022.  
> 張崇彥, 一個支援規格驅動開發的整合環境, 2022.  
> 透過本論文了解一個整合 Junit, XML Model, Testing case, 的規格驅動開發環境架構。
{: .block-tip }

本論文結合黑箱測試案例自動產生及測試驅動開發流程，提出規格驅動開發流程。在 Eclipse 上結合 XML 模型工具 Papyrus、OCL 處理器、
黑箱測試案例產生工具 CBTCG、JUnit，開發一個支援規格驅動開發的整合環境 CBSDD。  
這個整合環境以專案的形式，完整支援軟體規格的制定，根據軟體規格自動產生測試案例，並透過自動執行測試案例，來驅動程式的實作與重構。

### 1. Intorduction

##### 1.1 Motivation

TDD 先編寫測試案例來進行規範，從未能夠通過測試案例的*紅燈狀態*開始進行程式開發，直到程式能夠通過測試的驗證達到*綠燈狀態*，
再經由*重構*。這些 TDD 所提倡的優點可見 [TDD Concepts].

其中公認的優點為：
-   程式上開發與實施所得到的功能間都存在差距，TDD 由小而快的迭代不斷將實施的功能回饋給開發者而縮小了差距。
-   強調自動的單元化測試，自動測試提供可靠的系統，增強測試品質並且降低測試成本。
-   TDD 創建了一個完整的回歸測試平台。運行這些自動化測試案例，可以輕鬆確定更改是否破壞了系統中的任何內容。

即使測試驅動開發帶來諸多好處，但 TDD 在開發設計上的層面依然有可以改進的地方。因此提出了 BDD、SDD、APDD 等方法來讓使用者可以建立可執行的規範來進行測試。

過去團隊開發 Test Case Generation System[2] 使使用者能以規格文件來得到 Testing case 但當時需要使用者透過一個**文件選擇器**來選擇對應的輸入文件，
這樣的方式繁瑣且 Specification file, Output file 的關聯性也不明確。

> [2] C.-L. Wang and N.-W. Lin, ", “Supporting Java Array Data Typein ConstraintBased Test Case Generation for Black-Box Method-Level Unit Testing," in
International Computer Symposium , 2018. 

因此本論文提出一種透過 Eclipse 插件建立的 SDD 整合環境，來提升使用者的操作體驗。

##### 1.2 Method

本專案設計了一個基於 Eclipse 的整合環境, 並設計出一套專案架構來管理規格文件與產生測試案例, 對於架構的詳情見論文 P3 這裡不詳細敘述，並且開發了兩個 *Wizard* 來幫助使用者建立專案。

- *Wizard*: In Eclipse, a wizard is commonly used for the creation of new elements, imports or exports.

![](../assets/image/2023-06-23-Intergrated_environment_sdd/1.png){:height="30%" width="30%"}
> fig 3. 規格驅動開發專案檔案目錄

在規格文件(Specification file)上需要 User 提供一個描述類別圖與精簡狀態圖的 UML 和 OCL file，使用 Eclipse 的 Papyrus 來繪製類別圖與精簡狀態圖，
並使用一個**基於 Xtext 所製作的 OCL 編輯器**來編輯 OCL。Testing Case 是經由團隊開發的 OCL 語法經由 Antlr 來產生，所以才需要製作一個 OCL 編輯器來進行高亮、語法檢查等功能，
讓使用者能確保語法正確並可以讓 OCL 分析器來進行分析。

![](../assets/image/2023-06-23-Intergrated_environment_sdd/2.png){:height="75%" width="75%"}
> fig 17. 規格驅動開發整合環境，其中 CBTCG 是團隊所開發的測試案例產生器。

> ##### NOTE
> Last edit 07-18-2023 12:32  
> 我目前對 Eclipse 與相關環境開發研究到這裡就好，更有興趣的是 OCL 所產生的測試案例，這篇日後再回來讀。
{: .block-warning }

[TDD Concepts]: https://hotshot824.github.io/jekyll/2023-04-21-tdd_concepts.html