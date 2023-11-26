---
title: "Testing | Method-Level Structural Unit Testing (Unfinished)"
author: Benson Hsu
date: 2023-11-25
category: Jekyll
layout: post
tags: [software, software_qualitiy]
---

> Software testing course notes from CCU, lecturer Nai-Wei Lin.  
> 這章節主要開始介紹從 Method 為單位的 Unit testing，以 White-box 的角度來切入
{: .block-tip }

白箱測試 (White-box testing) 是透過實作的程式碼來進行測試，所以這章節會介紹如何從程式碼的角度來進行測試，而不是從 Specification 的角度來進行測試

**Structural Testing(White-Box Testing)** 

-   In structural testing, the software is viewed as a white box.
-   **Test inputs** are derived from the **implementation** of the software.
-   **Expected outputs** are still derived from the **specification** of the software.
-   Structural testing techniques include **control flow testing** and **data flow testing**.
    -   Control flow: 透過 flowchart 來確認路徑，並且進行測試
    -   Data flow: 透過 data 的細微變化，來進行測試
    -   通常 Data flow 能比 Control flow 更細緻的進行測試，但是也更難進行測試

### 5.1 Control Flow Testing

-   Control flow testing(控制流程測試)使用程式的控制結構來制定程式的 Test cases
-   Test cases 的設計是基於在充分覆蓋程式的整個控制結構上
-   Control flow graph(CFG, 控制流程圖)可以用來描述程式的控制結構

**Control flow graph**

-   一個程式的 Control flow graph, G = (N, E)，包含一組節點 N 和一組邊 E
-   每個 Node 都代表一組程式的 Statement，有五種不同的 Node
    -   **Entry**: 程式的進入點
    -   **Exit**: 程式的結束點
    -   **Statement**: 程式的一般陳述句，不會創建新的分支，如: letExpr
    -   **Decision**: 包含一個條件陳述，由該條件創建 2 個或以上的分支，如: ifExpr, switchExpr
    -   **Merge**: 分支的合併點
-   如果 Control 可以從 N<sub>1</sub> 到 N<sub>2</sub>，則存在一條從 N<sub>1</sub> 到 N<sub>2</sub> 的 Edge

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-11-25-method_level_structural_unit_testing/1.png?raw=true){:height="75%" width="75%"}

**Test Input**

-   測試輸入可以由一條 CFG 的完整路徑中得到
    -   完整路徑: 一條從 Entry 到 Exit 的路徑
-   測試覆蓋標準(Test coverage criterion) 衡量**一組測試輸入**對程式的覆蓋程度

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-11-25-method_level_structural_unit_testing/2.png?raw=true){:height="75%" width="75%"}

> 假如有一個完整的 CFG 使用 BFS 會找出右邊的路徑，但要注意路徑並不代表一定能找出符合的測試輸入

**Path Predicate Expression**

-   Input vector: 是輸入變數的 Vector 相對應的 Tuple of values  
-   Complete path: 包含一系列的 Decision Node
-   Path predicate expression: 一個 Boolean expression，用來描述一個 Complete path 的 Input vector

簡單來說 Path predicate expression 就是找出能達成這條路徑的一系列 expression:

<div style="display: flex; flex-direction: row; align-items: center;">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-11-25-method_level_structural_unit_testing/3.png?raw=true" 
    width="50%" height="50%">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-11-25-method_level_structural_unit_testing/4.png?raw=true" 
    width="50%" height="50%">
</div>

**Path Sensitization**

-   Path sensitization 是尋找 Paht predicate expression 的解集的過程
-   可以使用 Constraint Logic Programming(CLP) predicates 來實現 Path sensitization
-   如果一個 Path sensitization 有解就代表這條路徑是可行的

<div style="display: flex; flex-direction: row; align-items: center;">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-11-25-method_level_structural_unit_testing/5.png?raw=true" 
    width="50%" height="50%">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-11-25-method_level_structural_unit_testing/6.png?raw=true" 
    width="50%" height="50%">
</div>

### 5.2 Test Coverage Criteria

-   Statement coverage (SC)
-   Decision coverage (DC)
-   Condition coverage (CC)
-   Decision/condition coverage (D/CC)
-   Multiple condition coverage (MCC)
-   Path coverage (PC)

> ##### Last Edit
> 11-25-2023 13:34 
{: .block-warning }