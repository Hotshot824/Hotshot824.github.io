---
title: "Paper | A MVVM Modeling Methodology for Information Systems User Interface Design"
author: Benson Hsu
date: 2023-07-19
category: Jekyll
layout: post
tags: [software, web_development, web_framework]
---

> Yuan-Kai Hou, "A MVVM Modeling Methodology for Information Systems User Interface Design", 2019. 
> 侯元凱, MVVM 模式資訊系統使用者介面塑模方法論, 2019. 
{: .block-tip }

> Lab meeting study:  
> 2 Review frontend framework, Design pattern(MVC, ...), UML, *PAC*, 3-5 Method, 6 Conclusion.  
> Section 2. 文獻回顧的部分放到其他筆記中講，這裡主要看作者的研究方法與方式，提出了一個基於 PAC 模式所擴展的 **Enhanced-PAC** 模式，
> 可用來表達 MVVM 模式下的 Frontend Component 的邏輯運作與轉換關係。
{: .block-danger }

### 1.  Introduction

**1.1 Research Background and Motivation**

傳統網頁大部分都是依照 MPA(Multi-Page Application) 模式開發，這裡作者點出幾個傳統網頁的問題:

1.  並沒有規定一定要將 View, Business logic, DB logic, 分開撰寫，只要方法之間能互相通訊、執行即可。
因此在一份專案中能看到多種語法參雜並且**高度耦合(coupling)**，導致程式的維護性降低。
2.  傳統網頁中有以 MDA(Model-driven architecture) 配合 CASE Tool 生成代碼的開發方法，
但對於程式邏輯與訊息傳遞上沒有可供依循的**參考文件(reference document)**，因此在開發過程中難以維護或理解功能對應程式碼的區段。

- **[Model Driven Architecture(MDA)]** 模型驅動開發:  
一種軟設計方法(Software design approach)該方法強調要在軟體開發中的每個步驟均須建構出模型，且最好應表達為電腦可理解的正規模式(Formal Model)。
MDA 將重點放在正向工程(forward engineering)上，從抽象的、人工詳細的建模圖生成代碼。

**1.2 Research Objective**

使用 DSRM(Design Science Research Methodology) 研究方法，以 Angular2 為前端框架開發一個名為 **「便當王系統」**，
並提出**MVVM 模式資訊系統使用者介面塑模方法論(MVVM Modeling Methodology for Information Systems User Interface)**。主要方法有:

1.  使用 MVVM 開發模式，開發前端系統架構。
2.  因為 MDA 開發中只在程式文件中有方法名稱，但並沒有對程式邏輯進行詳細的塑模。因此撰寫可使用於 MVVM 模式的塑模文件，
以提升程式設計師開發與維護時對於功能面的了解。

用 Angular2, PHP, MySQL 進行設計系統。但主要討論的是前端 Angular2 的部分，後端不在研究範圍中。

> 這裡所說的 **「便當王系統」** 請參考:  
> 吳仁和,物件導向系統分析與設計―結合 MDA 與 UML, 5thEdition, 台北市: 智勝文化, February 2017, ch5
{: .block-tip }

### 2. Literature Review

文獻探討章節講述:
1.  **SPA(Single Page Application)** 單一頁面程式:  
詳情可看 Vue, React, Angular2 進行了解，主要取代過往 MPA 需要多個 HTML 進行建置網頁，當跳轉頁面時需要再次發出 Request 取回整個 HTML 造成的問題。
2.  **Software architectural pattern** 軟體開發架構:  
可參考  [Note | Architectural Patterns Compare MVP, MVC, MVVM]
3.  **UML(Unified Modeling Language)** 統一塑模語言:  
是由 OMG(Object Management Group, OMG) 物件管理組織歷經多年的版本演化擴充，提出的物件導向塑模工具。
4.  **PAC(Presentation–abstraction–control)**  表示-抽象-控制模式:  
一種 **Software architectural pattern**，是常見的介面(interface) 結構表達工具，將使用者介面分為多個子介面，每個子介面可視為一個物件。
並有 Net-PAC 等擴展成網狀結構使其能表達 Web-base 的系統。

> Shuen-Jen Tsai, Modeling the User Interfaces:A Component-based Interface Research for Integrating the Net-PAC Model and UML, 2002.

### 3. Research Method

**3.1 Design Science Research Methodology**

這裡使用該研究方法論步驟來進行論文之研究，其內容為下:

![](../assets/image/2023/07-19-MVVM_modeling_methodology_user_interface/1.png){:height="75%" width="75%"}
> Peffers, K., Tuunanen, T., Rothenberger, M. A., and Chatterjee, S., A Design Science Research Methodology for Information Systems Research

**3.2 Research Method and Step**

Angula2 是已經強制以 MVVM 進行開發，而對於程式邏輯未有明確的塑模文件規範。作者使用 UML 的溝通突來建構一份符合 Angular2 框架的系統分析與設計的開發文件。

1.  確認問題與動機:  
透過文獻研究來了解當前傳統網頁所存在的問題，以及 MDA 系統開發方法下對於程式邏輯的描述文件不足。
2.  定義解決方法的目標:
    1.  解決研究背景中傳統網頁(非 SPA、MVVM)的程式無法將使用者介面、程式邏輯、資料庫邏輯等語法分開撰寫，與不易分割進行分工的問題。
    2.  MDA 系統開發方法為 PSM 轉換為傳統網頁程式碼的開發方式，未涉及程式邏輯的塑模與轉換，**本研究將以 UML 對其程式邏輯塑模，並產出一份可與 MVVM 模式對應之 UML 文件**。
3.  設計與發展:  
    1.  由於 Angular2 已經強制使用 MVVM 進行開發，因此這裡會以*生產率(Productivity)、可攜性(Portability)、互通性(Interoperability)、耦合力(Coupling)*作為此系統開發框架的績效指標。
    2.  在 MDA 中進行塑模的部分則使用 **Enhanced-PAC 建構溝通圖塑模系統的程式邏輯**，與資訊傳遞，並以*維護與文件(Maintenance and Documentation )*做為此塑模方法論的衡量指標。 
4.  展示:  
**「便當王系統」**中有一個**新增項目活動圖**做為來源，分別找出 Model、View、ViewModel，以及對這三個部分以資料詞彙做更詳細的說明，並建立出代表系統介面結構的 **Enhanced-PAC 模型**，
再以 Enhanced-PAC 模型, View model 資料詞彙作為來源，建構 UML 溝通圖(Communication Diagram)，這樣**「便當王系統」**就能透過 UML 來使用 Angular2 框架進行開發。
5.  評估:  
    1.  使用 Angular2 完成 SPA 的「便當王系統」後就能使用*生產率(Productivity)、可攜性(Portability)、互通性(Interoperability)、耦合力(Coupling)*作為系統評估此四項指標的問題，
    2.  *維護與文件(Maintenance and Documentation)*則以 **Enhanced-PAC 模型**與溝通圖的塑模方法論來評估。

### 6. Conclusion

作者提出一個新的 Enhanced-PAC pattern 用於表達 MVVM 架構下 Forntend Model，並以此 Model 進行開發與評估，
是否達到以 Enhanced-PAC 使開發者可以依循的參考文件。

> ##### NOTE
> 剩下的部分為論文的 Section 4-5. 為 Enhanced-PAC 建立方法，與使用 Enhanced-PAC 建立 Communication Diagram 與程式碼對應。並使用作者提出的指標來進行評估。
> Section 6. 為結論與未來發展。  
> Last edit 07-19-2023 19:07
{: .block-warning }

[Model Driven Architecture(MDA)]: https://en.wikipedia.org/wiki/Model-driven_architecture
[Note | Architectural Patterns Compare MVP, MVC, MVVM]: ./2023-07-18-software_arch_pattern.html