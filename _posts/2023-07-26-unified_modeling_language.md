---
title: "Note | Unified Modeling Language Concepts"
author: Benson Hsu
date: 2023-07-26
category: Jekyll
layout: post
tags: [software, software_development]
---

> Unified Modeling Language(UML) 統一塑模語言。
> 雖然敏捷開發中不再投入過多時間在靜態建模上，但是 UML 還是有其價值，尤其是在大型複雜系統的設計，或在開發團隊需要更深入的技術和設計細節時。 
{: .block-tip }

### 1. Intorduction

UML 是為了大型軟體系統的結構與行為的架構、設計、和實現建立 **通用的可視化建模語言**。它提供了用於傳達設計決策和系統架構的通用語言和符號。
它包括許多類型的圖，例如 Case diagram、Class diagram、Sequence diagram。他也支援一些 Advanced concepts 像是 Stereotypes(型別標記)、
Profiles(設計資料集)、Constraints(約束條件)、Packages(包)，由此可以對軟體系統進行更精確的定製建模。UML 是為了幫助改善溝通、協作和軟體系統的整體品質。

##### 1.1 History

UML 由 OMG(Object Management Group) 負責管理，2005年被 ISO 發布為認可的 ISO 標準，之後該標準定期修訂涵蓋 UML 的最新修訂版。
目前最新的版本是 [UML 2.5.1] 在 2017 年發布。

![](https://www.cybermedian.com/wp-content/uploads/2023/03/01-uml-history.png)

##### 1.2 Why use UML in software development?

1.  Standardization: 用於描述軟體系統的標準可視化語言。使不同的利益相關者更容易交流設計決策與理解系統架構。
2.  Clarity: 通過提供清晰、簡潔的表示來幫助減少軟體系統的歧義，防止軟體開發過程中的誤解和錯誤。
3.  Collaboration: 促進不同利益相關者(如開發人員、架構師和項目經理)的溝通和協作。確保每個人都朝相同的目標努力。
4.  Effciency: 提供軟體系統的可視化表示，可用於儘早識別潛在問題和設計缺陷，從而簡化軟體開發過程。
5.  Reusability: 用於記錄軟件系統和設計模式，可以在未來的項目中重複使用。在軟件開發過程中節省時間和資源。

##### 1.3 Key Object-Oriented Concepts in UML

UML 已經取代了傳統的 Object-oriented (OO) 分析方法。

> An object is made up of data and methods that control it. 
> The data represents the object’s current status. 
> A class is a type of object that has a hierarchy that can be used to mimic real-world systems. 
> The hierarchy is expressed by inheritance, and classes can be linked in a variety of ways depending on the needs.

Object 是我們周圍存在的現實世界實體，UML 能表示像抽象、封裝、繼承和多型這樣的基本原則，能表示物件導向分析和設計中的所有概念。
因為 UML 圖表中僅表示物件導向的概念。在開始學習之前，充分理解物件導向概念非常重要。

### 2. UML Hierarchy

根據 UML 提出的層次結構如下圖，分為**結構圖(Structure diagrams)**與**行為圖(Behavior diagrams)**: 

![](https://www.cybermedian.com/tw/wp-content/uploads/sites/5/2022/02/img_6200f3b2015ff.png)

-   **Structure diagrams**:  
用於描述系統的靜態特徵或結構，由於代表結構，所以它們更廣泛的用於紀錄軟體系統的軟體架構。
如 Component diagrams 代表了如何描述軟體系統被拆分為 Components 並顯示這些 Components 之間的 dependencies。
-   **Behavior diagrams**:  
描述了系統的動態特徵和行為，由於說明系統行為，因此主要用來描述系統的功能。如 Activities diagrams 用來描述系統中組件的業務與逐步操作的活動。
    -   **Interaction diagrams(交互圖)**:    
    Interaction diagrams 是行為圖的 subset，強調被塑模系統中事物之間的控制流程與資料流程(flow of control and data)。
    如 Sequence diagram 顯示對象如何在彼此之間就一系列訊息進行通訊。

##### 2.1 UML Survey* States

> Grady Booch, one of the most important developer of UML, 
> stated that “For 80% of all software only 20% of UML is needed”.

UML 一共有 14 張圖表，但在一個軟體開發中並不是每個 Diagram 都會被使用，下圖表示了使用該 Diagram 的廣泛程度:

![](https://www.cybermedian.com/wp-content/uploads/2022/02/0sf0Ja3sWMCXLLIn.png)

之後會再另外兩篇以[結構圖](Structure diagrams)、[行為圖](Behavior diagrams)分類，再以使用廣泛度來依序介紹。

> ##### Note
> Last edit 07-24-2023 2201,  
> Reference: [Unified Modeling Language (UML) Introduction]
{: .block-warning }

[UML 2.5.1]: https://www.omg.org/spec/UML

[Unified Modeling Language (UML) Introduction]: https://www.cybermedian.com/a-comprehensive-guide-to-understanding-and-implementing-unified-modeling-language-in-software-development/#1_Introduction_to_UML
[A Comprehensive Guide to 14 Types of UML Diagram]: https://www.cybermedian.com/a-comprehensive-guide-to-14-types-of-uml-diagram/

[結構圖]: ./2023-07-28-UML_structure_diagrams.html
[行為圖]: ./2023-07-28-UML_behavior_diagrams.html