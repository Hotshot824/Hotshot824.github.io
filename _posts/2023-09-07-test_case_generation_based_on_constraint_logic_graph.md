---
title: "Paper | Test Case Generation Based on Constraint Logic Graph (Unfinished)"
author: Benson Hsu
date: 2023-09-07
category: Jekyll
layout: post
tags: [software, software_qualitiy, generate_test_case]
---

> Chiao-Yi Huang, "Test Case Generation Based on Constraint Logic Graph", 2015.
> 本論文描述一種基於限制邏輯圖所進行的限制式案例產生技術的黑箱測試，並將該測試案例產生器實作成一個 Eclipse 的外掛套件。
{: .block-tip }

### 1. Introduction

##### 1.1 Motivation

根據 Standish 團隊的 2015 CHAOS 報告指出目前開發高品質的軟體系統十分困難，確保軟體品質的主要方法即是軟體測試。
這裡指出了幾個測試流程:

-   Unit testing(單元測試)
-   Intergration testing(整合測試)
-   System testing(系統測試)
-   Acceptance testing(驗收測試)

而 Tase case 的產生可以分為兩種方法:
-   **Black-box testing(黑箱測試)**
    -   在測試前先依照規格慘生測試案例，**是本論文使用的方式，透過 UML Class diagram 搭配 OCL 來描述規格**
-   White-box testing(白箱測試)

其中針對單元測試的 Tase case 可以分成兩種情況:
-   Vaild test case(符合前置條件的測試案例)
    -   符合程式預期輸入與輸出的測試案例，需要先得知測試前後的系統狀態(system pre-state/post-state)，參數(argument)，回傳值(return value)
-   Invaild test case(不符合前置條件行為測試案例)
    -   可對程式產生錯誤的測試案例，也就是在 Java 中所發生的例外狀況(exception)。

##### 1.2 Method

限制式測試案例產生(constraint-based test case generation)技術是一種重要的測試案例自動產生技術，
將測試案例產生問題制定為**限制滿足問題([Constraint Satisfaction Problem])**，以此有四個主要問題需要解決:

1.  軟體行為規格的描述
2.  軟體等價行為的分割
3.  軟體測試覆蓋標準的滿足
4.  軟體等價行為所對應的限制滿足問題的敘述

**第一個問題**，本論文將物件限制語言運算式(Object constraint language expression)轉換為限制邏輯圖(CLG)，以 CLG 來表現受測函數的程式行為。

**第二個問題**，本論文定義一個完整的限制邏輯圖路徑就代表一個完整的程式行為，即為一個等價類([Equivalence class])，
透由 CLG，原本是無限組合的析取正規式([DNF])的受測函式程式行為，變成可數的受測函式程式行為，將這些程式行為分割成一個可以被管理的等價類集合，
等價類內的全部測試案例都被當作找錯誤的能力都相同，只要從每個等價類中挑出一組測試案例，即可產生出必要的測試案例。

**第三個問題**，這裡分為兩個部分來討論：
1.  第一為規格覆蓋標準，由選擇的規格覆蓋標準評估規格覆蓋度需要到甚麼程度，我們提供了三種覆蓋標準。
    1. Decision coverage (DC)
    2. Decision condition coverage (DCC)
    3. Multiple condition coverage (MCC)
2.  第二部分則是針對已經產生的限制邏輯圖是否產生足夠數量的可視完整路徑，稱之為限制邏輯圖覆蓋標準。

**第四個問題**，將可實行路徑上的限制式收集，並將這些限制式轉換成限制邏輯程式，
就可以使用限制邏輯語言找解器(Constraint logic programming solver)([ECLiPSeclp]) 求出測試資料(測試資料包含測試輸入與預期輸出與系統狀態)，
最後將測試資料轉換成需要的平台的測試案例，而在本篇論文中可以針對 Java 的平台轉換成 JUnit 測試案例。

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/1.png?raw=true){:height="75%" width="75%"}

> 圖二為依照這四個問題所建構的測試工具整體架構，以下說明各個架構的功能

-   **限制邏輯圖轉換器**:  
    -   描述如何根據我們得到的受測函式的 **物件限制語言(OCL)** 產生他相對應的 **限制邏輯圖(CLG)**
-   **路徑條列器**:  
    -   從 **限制邏輯圖(CLG)** 產生 **可實行路徑(feasible path)** 的方法，一條完整的路徑也不代表這條路徑可以產生測試案例，
    必須能分辨它是否為可實行路徑
-   **限制邏輯程式產生器**:  
    -   我們需要的資料不僅是受測函式相關資料，還需要產生執行此受測函式時相對應的執行前與執行後的環境，
    我們根據 UML 的關聯中對於物件的限制找到適合的系統狀態，並且每個物件都會滿足自身定義的恆定條件。
    -   而在待測函式的路線中，可能會呼叫其他的函式，為了讓函式呼叫能正常的運作並且符合應有的限制式，我們還會在測試案例中補上其他函式的模擬。
-   **測試資料解析器**
    -   得到測試資料後，由於測試資料只是純文字，透過此解析器得到測試資料的詳細資訊。
-   **測試腳本產生器**
    -   這裡的測試資料是與平台無關的，需要透過測試腳本產生器使測試資料實體化成為測試案例，這裡使用 JUnit。

### 2. Related Technology Research

2.1 - 2.7 為使用的工具與技術介紹，2.8 介紹了相關的研究。

##### 2.1 Unified Modeling Language(UML)

關於 [UML] 這裡有介紹，這裡不再贅述。

##### 2.2 Object constraint language(OCL)

OCL 可以更嚴謹的描述 UML 中有關系統規格的所有資訊，是 UML 的擴展。OCL 使用三種限制式(Constraint)描述類別行為:

1.  **Class invariant**
    -   此類別在整個生命週期中都應該滿足的條件
2.  **Method pre-condition**
    -   Method 執行前應該滿足的條件
3.  **Method post-condition**
    -   Method 執行後應該滿足的條件

##### 2.5 Test quality assessment

這裡使用 **Mutation testing** 來評估測試案例的品質，Mutation testing 是一種測試案例的品質評估方法，
將待測程式改變幾個 Operation 來測試 Test case 能否找出這些改變。

> 延伸閱讀: [Paper An Analysis and Survey of the Development of Mutation Testing].

> 2.3 Constraint Logic Programming(CLP), 2.4 Coverage Criteria, 2.6 JUnit, 2.7 GraphViz 介紹請參考原論文
{: .block-warning  }

##### 2.8 Related research

##### 2.8.1 Test Case Generation Based on UML/OCL

在 [17] 他們擴大了HOL 為基底的測試框架，[HOL-TestGen] [20]，可以支援 UML/OCL 的規格。他們其中一個主要的貢獻，
是擴充以規格為基底的測試案例產生器推向物件導向的規格。

> [17] A . D. Brucker, P. K. Matthias, L. Delphine, W. Burkhart, "A Specification-Based Test Case Generation Method for UML/OCL," 
> Models in Software Engineering, vol. 6627, pp. 334-348, 2011.

> [20] A . D. Brucker, W.Burkhart, "Interactive Testing with HOL-TestGen," 
> in Proceedings of the 5th International Conference on Formal Approaches to Software Testing, 2006.

在 [18]中，他們展示了TOTEM(Testing Object-orienTed systEms with the unified Modeling language)，一個實用的測試方法。測試需求從早期的開發文件中取得，
如用例圖(use case diagram)、用例說明(use case description)、與每個用例與類別相關的交互關係圖(interaction diagram)，
他們在活動圖(activity diagram)中捕捉在用例之間的連續關係，因此允許用例序列的規格被測試。

> [18] L . Briand, L. Yvan, "A UML-Based Approach to System Testing," in Proceedings of the 4th International Conference on The Unified Modeling Language,
> Modeling Languages, Concepts, and Tools, 2001.

在 [19]中提出屬性為基底的測試(property-based testing)，結合了軟體模型(UML) 與限制屬性(OCL) 來討論，他們斷定了系統元件的兩種不同的屬性，
例如無狀態與狀態相關，可以產生完整屬性為基底的測試套件，產生的測試套件可以表達成 QuickCheck[21] 的形式。

> [19] M . A. Francisco, M. C. Laura, "Automatic Generation of Test Models and Properties form UML Models with OCL Constraints," 
> in Proceedings of the ACM 12th Workshop on OCL and Textual Modeling, 2012.

##### 2.8.2 Test Case Generation Based on Constraint

[22] 是將基於限制式的研究用在測試上的先驅，他們提出了透過基於限制式測試，自動產生測試輸入用在基於錯誤的測試(fault-based testing)。

> [22] R . A. DeMillo and A. J. Offutt, "Constraint-Based Automatic Test Data Generation," IEEE Transcations on Software Engineering, vol. 17, no. 9, 
> pp. 900-910, 1991.

[23] 提出了第一個從C 程式轉換成靜態單賦值形式(static single assignment form)，使所有變數都只會被賦予最多一次的值，
接著可以透過這個方法有系統地取得控制流程圖中每一條不同執行路徑的限制式，進行符號執行(symbolic execution)。最後，
透過限制找解器(constraint solvers) 自動的產生所有可實行路徑的測試輸入。

> [23] A . Gotlieb, B. Botella and M. Rueher, "Automatic Test Data Generation Using Constraint Solving Techniques," 
> in Proceedings of the 1998 ACM Symposium on Software Testing and Analysis, 1998.

[24] 使用符號執行來收集在Ada 程式中不同路徑的限制式。他使用限制邏輯程式(constraint logic programming) 來自動的產生針對所有可實行路徑的測試輸入。

> [24] C . Meudec, "ATGen : Automatic Test Data Generation Constraint Logic Programming and Symbolic Execution," 
> Journal of Software Testing, Verification and Reliability, vol. 11, no. 2, pp. 81-96, May, 2011.

[25] 提出了可以從VDM的規格中自動產生測試案例，他們將待測程式的 VDM 規格中的符號轉換成一階邏輯演算(first-order logiccalculus) 的析取範式(disjunctive normal form)。
每一個合取(conjunctive) 的演算都是等價類(equivalence class)，而他們也有考慮關於產生一系列函式呼叫時要讓整個程式處在一個適當的系統環境中做測試。

> [25] J . Dick and A. Faivre, "Automating The Generation and Sequencing of Test Cases from Model-Based Specifications," 
> in Proceedings of the 1st International Symposium on Formal Methods Eurpoe, 1993.

### 3. Constraint Logic Graph Generator

這裡介紹如何將 Method 的 OCL 轉為 CLG，架構圖如下:

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/2.png?raw=true){:height="60%" width="60%"}

主要流程如下: 
1.  使用 DresdenOCL Parse OCL 轉為抽象語法樹(AST)
2.  AST 經過 Preprocessing(AST 重構器)
3.  依照不同的 Coverage criteria 來產生測試案例

##### 3.1 OCL Syntactic analysis

OCL 有三種限制式(invariant, pre, post) 這樣每種情境就要建立一個 **Abstract syntax tree(AST)**，
這裡會透過 Dresden OCL 來分析 OCL，其中每一個 Operator 都會產生一個 Subtree。

##### 3.1.1 Structure of Abstract syntax tree

AST 的每一個 Node 都代表一個 OCL 的運算式，以下是作者所設計的 Node:

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/3.png?raw=true){:height="100%" width="100%"}

IfExp 的抽象語法樹如圖，根節點為IfExp
-   conditionExp：ASTNode 第一個子樹，為condition 的運算式
-   thenExp：ASTNode 第二個子樹，為then 的運算式
-   elseExp：ASTNode 第三個子樹，為else 的運算式

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/4.png?raw=true){:height="50%" width="50%"}

> 這裡只舉 IfExp 為例子，全部的 Node 請參考論文

##### 3.1.2 Example Triangle

以下是一個 Triangle 的例子，這裡有三個限制式(pre, post, post)要傳換成 AST:

```ocl
package tcgen
context Triangle::Triangle(sa : Integer, sb : Integer, sc : Integer): OclVoid
pre EdgeErrorException:
sa + sb > sc and sb + sc > sa and sa + sc > sb and sa > 0 and sb > 0 and sc > 0
post:
    sideA = sa and sideB = sb and sideC = sc

context Triangle::category() : String
post:
    result =if sideA@pre = sideB@pre then
        if sideB@pre = sideC@pre then
            'Equilateral'
        else 'Isosceles'
        endif
    else if sideA@pre = sideC@pre then
            'Isosceles'
        else if sideB@pre=sideC@pre then
                'Isosceles'
            else 'Scalene'
            endif
        endif
    endif
```

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/5.png?raw=true){:height="75%" width="75%"}

> 上圖是 Triangle 的 Post 被轉化為 AST 的結果，其他的轉換可以參考論文

> ##### NOTE
> Last edit 11-2-2023 16:36  
{: .block-warning }

[Constraint Satisfaction Problem]: ./2022-11-08-ai_csp.html
[Equivalence class]: https://en.wikipedia.org/wiki/Equivalence_class
[DNF]: https://en.wikipedia.org/wiki/Disjunctive_normal_form
[ECLiPSeclp]: http://eclipseclp.org/
[UML]: 2023-07-26-unified_modeling_language.html

[Paper An Analysis and Survey of the Development of Mutation Testing]: 2023-05-20-analysis_mutation_testing.html
[HOL-TestGen]: https://brucker.ch/projects/hol-testgen/