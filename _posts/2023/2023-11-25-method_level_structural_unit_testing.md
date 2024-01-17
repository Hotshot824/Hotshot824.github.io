---
title: "Testing | Method-Level Structural Unit Testing"
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

![](../assets/image/2023/11-25-method_level_structural_unit_testing/1.png){:height="75%" width="75%"}

**Test Input**

-   測試輸入可以由一條 CFG 的完整路徑中得到
    -   完整路徑: 一條從 Entry 到 Exit 的路徑
-   測試覆蓋標準(Test coverage criterion) 衡量**一組測試輸入**對程式的覆蓋程度

![](../assets/image/2023/11-25-method_level_structural_unit_testing/2.png){:height="75%" width="75%"}

> 假如有一個完整的 CFG 使用 BFS 會找出右邊的路徑，但要注意路徑並不代表一定能找出符合的測試輸入

**Path Predicate Expression**

-   Input vector: 是輸入變數的 Vector 相對應的 Tuple of values  
-   Complete path: 包含一系列的 Decision Node
-   Path predicate expression: 一個 Boolean expression，用來描述一個 Complete path 的 Input vector

簡單來說 Path predicate expression 就是找出能達成這條路徑的一系列 expression:

<div style="display: flex; flex-direction: row; align-items: center;">
    <img src="../assets/image/2023/11-25-method_level_structural_unit_testing/3.png" 
    width="50%" height="50%">
    <img src="../assets/image/2023/11-25-method_level_structural_unit_testing/4.png" 
    width="50%" height="50%">
</div>

**Path Sensitization**

-   Path sensitization 是尋找 Paht predicate expression 的解集的過程
-   可以使用 Constraint Logic Programming(CLP) predicates 來實現 Path sensitization
-   如果一個 Path sensitization 有解就代表這條路徑是可行的

<div style="display: flex; flex-direction: row; align-items: center;">
    <img src="../assets/image/2023/11-25-method_level_structural_unit_testing/5.png" 
    width="50%" height="50%">
    <img src="../assets/image/2023/11-25-method_level_structural_unit_testing/6.png" 
    width="50%" height="50%">
</div>

**Test Coverage Criteria**

-   Statement coverage (SC)
-   Decision coverage (DC)
-   Condition coverage (CC)
-   Decision/condition coverage (D/CC)
-   Multiple condition coverage (MCC)
-   Path coverage (PC)

> 這幾種 Control flow 的 Test coverage criteria 會在另外一篇做介紹，請參考: [Note - Test Coverage Criteria]
{: .block-danger }

---

### 5.2 CFG to CLG

這裡介紹如何將 Control Flow Graph(控制流程圖)傳換成 Constriant Logic Graph(限制邏輯圖)，
如果能將 CFG 轉換成 CLG 就能更容易地透過 Graph algorithm 來找出 Path predicate expression

<div style="display: flex; flex-direction: row; align-items: center;">
    <img src="../assets/image/2023/11-25-method_level_structural_unit_testing/7.png" 
    width="50%" height="50%">
    <img src="../assets/image/2023/11-25-method_level_structural_unit_testing/8.png" 
    width="50%" height="50%">
</div>

---

### 5.3 Data Flow Testing

Data flow testing(資料流程控制)也要使用 Control flow graph(CFG) 來找出 data flow anomalies(資料流異常)，
資料流異常是基於 value 和 Variable 之間的關聯性來檢測的，例如:
-   Variables are used without being initialized.
-   Initialized variables are not used once.

**Definitions and Uses of Variables**

-   **Definition(定義)**:
    -   An occurrence of a variable in the program is a definition of the variable if 
    a value is bound to the variable at that occurrence.
-   **Use(使用)**:
    -   An occurrence of a variable in the program is a use of the variable 
    if the value of the variable is referred at that occurrence.

**Predicate Uses and Computation Uses**

-   **Predicate Uses(謂詞使用)**:
    -   A use of a variable is a predicate use **(p-use)** if the variable is in a predicate
    and its value is used to decide an execution path.
-   **Computation Uses(計算使用)**:
    -   A use of a variable is a computation use **(c-use)** if the value of the variable is
    used to compute a value for defining another variable or as an output value.

> 如果變數 x 被使用在決策就是 p-use，如果變數 x 被使用在計算就是 c-use

**Definition Clear Paths**

-   A path (i, n<sub>1</sub>, n<sub>2</sub>, …, n<sub>m</sub>, j) is a definition-clear path
for a variable x from i to j if n<sub>1</sub> through n<sub>m</sub> do not contain a definition of x.

> 如果路徑中的 n<sub>1</sub> 到 n<sub>m</sub> 都沒有定義過 x 變數，則這條路徑是一條 definition-clear path

**Definition-C-Use Associations**

-   如果有一個 x 變數的 n<sub>d</sub> 存在，並且也有一個 x 變數的 n<sub>c-use</sub>，
並且從 n<sub>d</sub> 到 n<sub>c-use</sub> 存在一條 definition-clear path，
則會產生一個 **definition-c-use association**(定義-計算使用關聯) 
    -   `(n<sub>d</sub>, n<sub>c-use</sub>, x)`

**Definition-P-Use Associations**

-   如果有一個 x 變數的 n<sub>d</sub> 存在，並且也有一個 x 變數的 n<sub>p-use</sub>，
並且從 n<sub>d</sub> 到 n<sub>p-use</sub> 存在一條 definition-clear path，
則會產生兩個 **definition-p-use association**(定義-謂詞使用關聯): 
    -   True:  `(n<sub>d</sub>, (n<sub>p-use</sub>, t), x)`
    -   Flase: `(n<sub>d</sub>, (n<sub>p-use</sub>, f), x)`

**Definition-Use paths**

-   **Definition-Use paths(DU-Path, 定義-使用路徑)**:
    -   如果一條 path (n<sub>1</sub>, n<sub>2</sub>, …, n<sub>m</sub>) 滿足以下條件則他是變數 x 的 DU-Path:
        -   n<sub>1</sub> 是 x 的 definition
        -   n<sub>1</sub> 到 n<sub>m</sub> 是一條 definition-clear simple path(DCSP, 定義-清晰簡單路徑)
        -   n<sub>1</sub> 到 n<sub>m</sub> 是一條 definition-clear loop-free path(DCLFP, 定義-清晰無迴圈路徑)
-   **Definition-clear simple path:** 除了 n<sub>1</sub> 和 n<sub>m</sub> 之外的所有 Node 都是不同的，並且 n<sub>m</sub> 是 x 的 definition
    -   n<sub>m</sub> 必需是一個 c-use
-   **Definition-clear loop-free path:** 所有 Node 都是不同的
    -   n<sub>m</sub> 必需是一個 p-use

![](../assets/image/2023/11-25-method_level_structural_unit_testing/9.png){:height="75%" width="75%"}

上圖中的 (1, 2, 4) 是一條 DCSP，而 (1, 2, 3, 5) 是一條 DCLFP

> (1, 2, 3, 5, 1) 也是一條 DU-Path，因為這是一條 Definition-clear simple path，1 跟 5 都是 x 的 definition

**Test Coverage Criteria**

-   All-defs coverage
-   All-c-uses coverage
-   All-c-uses/some-p-uses coverage
-   All-p-uses coverage
-   All-p-uses/some-c-uses coverage
-   All-uses coverage
-   All-du-paths coverage

> 這些是關於 Data-flow 的覆蓋流程標準同樣在另外一篇做介紹，請參考: [Note - Test Coverage Criteria]
{: .block-danger }

**Example**

下面的例子會說明如何進行 Data-flow testing，假如有一個 Control flow graph 如下:
1.  先找出所有 Variable 的 definition, use:
    -   x: `definition: 1, 6`, `c-use: 3, 6, 7`, `p-use: 2, 4, 5`
    -   a: `definition: 3, 7`, `c-use: 8`, `p-use: none`
2.  找出所有的 Associations，一定是從 definition 到 use:
    -   **x<sub>1</sub>**:
        -   c-use: (1, 3, x), (1, 6, x), **(1, 7, x)**
        -   p-use: (1, (2, t), x), (1, (2, f), x), (1, (4, t), x), (1, (4, f), x), (1, (5, t), x), **(1, (5, f), x)**
    -   **x<sub>6</sub>**:
        -   c-use: (6, 6, x), **(6, 7, x)**
        -   p-use: (6, (5, t), x), (6, (5, f), x)
    -   **a<sub>3</sub>**:
        -   c-use: (3, 8, a)
    -   **a<sub>7</sub>**:
        -   c-use: (7, 8, a)
3.  找出可以符合測試覆蓋標準的 DU-Path:
    -   這裡以 All-Uses Coverage 為例，所以要找出可以覆蓋所有 Use 的 DU-Path

<div style="display: flex; flex-direction: row; align-items: center;">
    <img src="../assets/image/2023/11-25-method_level_structural_unit_testing/10.png" 
    width="50%" height="50%">
    <img src="../assets/image/2023/11-25-method_level_structural_unit_testing/11.png" 
    width="50%" height="50%">
</div>

##### Data flow testing for CLG

可以發現如果從 Control flow grapg 進行 Data flow testing 在找出 DU-Path 會比較麻煩，因為路徑上還要處理 Decsion Node，
所以可以先將 Control flow graph 轉換成 Constriant Logic Graph 再進行 Data flow testing，這樣在找尋路徑的時候就只需要處理是否有走過這個 Node 就好。

-   x: `definition: 1, 9`, `c-use: 4, 9, 10`, `p-use: 2, 3, 5, 6, 7, 8`
-   a: `definition: 4, 10`, `c-use: 11`, `p-use: none`

<div style="display: flex; flex-direction: row; align-items: center;">
    <img src="../assets/image/2023/11-25-method_level_structural_unit_testing/12.png" 
    width="50%" height="50%">
    <img src="../assets/image/2023/11-25-method_level_structural_unit_testing/13.png" 
    width="50%" height="50%">
</div>

這時候如果是 All-Uses Coverage 的話就只需要找出一條有走過所有 Node 的路徑就可以了。

> ##### Last Edit
> 11-25-2023 18:18 
{: .block-warning }

[Note - Test Coverage Criteria]: ./2023-11-28-test_coverage_criteria.html