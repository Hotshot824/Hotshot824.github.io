---
title: "Paper | Test Case Generation Based on Constraint Logic Graph"
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
-   Integration testing(整合測試)
-   System testing(系統測試)
-   Acceptance testing(驗收測試)

而 Tase case 的產生可以分為兩種方法:
-   **Black-box testing(黑箱測試)**
    -   在測試前先依照規格慘生測試案例，**是本論文使用的方式，透過 UML Class diagram 搭配 OCL 來描述規格**
-   White-box testing(白箱測試)

其中針對單元測試的 Tase case 可以分成兩種情況:
-   Valid test case(符合前置條件的測試案例)
    -   符合程式預期輸入與輸出的測試案例，需要先得知測試前後的系統狀態(system pre-state/post-state)，參數(argument)，回傳值(return value)
-   Invalid test case(不符合前置條件行為測試案例)
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

---

### 2. Related Technology Research

> 2.1 - 2.7 為使用的工具與技術介紹，2.8 介紹了相關的研究，  
> 2.3 Constraint Logic Programming(CLP), 2.6 JUnit, 2.7 GraphViz 介紹請參考原論文
{: .block-warning  }

[2.1 Unified Modeling Language(UML)](./2023-09-07-test_case_generation_based_on_constraint_logic_graph.html#21-unified-modeling-languageuml)  
[2.2 Object constraint language(OCL)](./2023-09-07-test_case_generation_based_on_constraint_logic_graph.html#22-object-constraint-languageocl)  
[2.4 Coverage Criteria](./2023-09-07-test_case_generation_based_on_constraint_logic_graph.html#24-coverage-criteria)  
[2.5 Test quality assessment](./2023-09-07-test_case_generation_based_on_constraint_logic_graph.html#25-test-quality-assessment)  
[2.8 Related research](./2023-09-07-test_case_generation_based_on_constraint_logic_graph.html#28-related-research)  

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

##### 2.4 Coverage Criteria

Coverage Criteria(測試覆蓋標準)是用來衡量測試嚴謹的程度，測試覆蓋標準越嚴謹代表所需開發成本提高但軟體品質也提高:

1.  **Decision coverage(DC, 決策覆蓋)**  
    -   程式的控制流程圖中每一個決策結構點的真與假值都必須執行過，因此每個 Edge(邊界)都會被執行過
2.  Condition coverage(CC, 條件覆蓋)  
    -   一個決策有可能包含一個以上的條件，所有的條件都必須執行過，但不需要特別包含 DC 標準
3.  **Decision condition coverage(DCC, 條件決策覆蓋)**
    -   條件與決策覆蓋都需要滿足，代表所有條件與決策的真與假值都必須執行過一次，但不用包含所有的條件組合
4.  **Multiple condition coverage(MCC, 多重條件覆蓋)**
    -   每個條件的真與假值都必須執行過一次，且每個條件組合都必須執行過一次，如果條件為 n 個，需要執行 2<sup>n</sup> 次

> 粗體是本論文會使用到的測試覆蓋標準

##### 2.5 Test quality assessment

這裡使用 **Mutation testing** 來評估測試案例的品質，Mutation testing 是一種測試案例的品質評估方法，
將待測程式改變幾個 Operation 來測試 Test case 能否找出這些改變。

> 延伸閱讀: [Paper An Analysis and Survey of the Development of Mutation Testing].

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

---

### 3. Constraint Logic Graph Generator

[3.1 OCL Syntactic analysis](./2023-09-07-test_case_generation_based_on_constraint_logic_graph.html#31-ocl-syntactic-analysis)  
[3.2 AST Post-Processor](./2023-09-07-test_case_generation_based_on_constraint_logic_graph.html#32-ast-post-processor)  
[3.3 Constraint Logic Graph Generator Architeture](./2023-09-07-test_case_generation_based_on_constraint_logic_graph.html#33-constraint-logic-graph-generator-architeture)  
[3.4 Definition of Constraint logic graph](./2023-09-07-test_case_generation_based_on_constraint_logic_graph.html#34-definition-of-constraint-logic-graph)  
[3.5 Generation of Constraint logic graph](./2023-09-07-test_case_generation_based_on_constraint_logic_graph.html#35-generation-of-constraint-logic-graph)  

這裡介紹如何將 Method 的 OCL 轉為 CLG，架構圖如下:

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/2.png?raw=true){:height="60%" width="60%"}

> MUT means Method unit testing

主要流程如下: 
1.  使用 DresdenOCL(OCL 分析器)讀取 OCL 的規格
2.  AST 透過 OCL 分析器結果來建立
2.  AST 經過 Post-Processing(AST 重構器)
    -   因為 OCL 可能因為 User 的習慣造成轉換 GLC 的困難，因此需做重構
3.  根據不同的 Coverage Criteria 將 AST 轉換為 CLG
    -   每個限制式產生一個 CLG subgraph，再根據各個 Function 將 CLG subgraph 結合成一個 Complete CLG

一個 Complete CLG 可以分成兩種，符合/不符合 Pre-condition 的 Complete CLG

##### 3.1 OCL Syntactic analysis

OCL 有三種限制式(invariant, pre, post) 這樣每種情境就要建立一個 **Abstract syntax tree(AST)**，
這裡會透過 Dresden OCL 來分析 OCL，其中每一個 Operator 都會產生一個 Subtree。

##### 3.1.1 Structure of Abstract syntax tree

AST 的每一個 Node 都代表一個 OCL 的運算式，以下是作者所設計的 Node:

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/3.png?raw=true){:height="75%" width="75%"}

```java
public ASTNode(Constraint obj) {
    super();
    this.id = node_count++; // Auto-increment id
    this.constraint = obj; // Type provided by DresdenOCL
    parents = new ArrayList<INode>(); // Point to parents
}
```

-   ASTNode 常用函數

-   `public abstract CLGNode toCLG(Criterion criterion);`
    -   產生 CLG 的函數，回傳此 ASTNode 所產生的 CLG 的第一個 CLGNode
-   `public abstract Classifier getType();`
    -   每個 ASTNode 都是運算式，函式回傳此 ASTNode 的回傳型態
-   `public abstract String getState();`
    -   取得此ASTNode 的是在哪個狀態(inv、pre、post)
-   `public abstract ASTNode toDeMorgan();`
    -   根據 De Morgan's law 對此 ASTNode 取反值
-   `public abstract ASTNode toPreProcessing();`
    -   將ASTNode 轉換成適合產生限制邏輯圖且比較簡單的 ASTNode，再根據新的 ASTNode 結構來產生 CLG

<br>

-   **Constraint**: 針對限制式所定義的物件型別，供內部需使用到限制式時使用

```java
public Constraint(Model model, tudresden.ocl20.pivot.pivotmodel.Constraint obj, ASTNode spec) {
    super(obj);
    this.dresden_constraint = obj; // Type provided by DresdenOCL
    this.model = model; // Point to UML model
    this.spec = spec; // Point to AST root node
    this.spec.addPreviousNode(this);
}
```

> 這裡只舉能產生分支的 ASTNode 為例子，全部的 Node 請參考論文
{: .block-warning }

-   **IfExp**: 指向 thenExp 與 elseExp

```java
public IfExp(Constraint obj, ASTNode conditionExp, ASTNode thenExp, ASTNode elseExp) {
    super(obj);
    this.conditionExp = conditionExp;
    this.thenExp = thenExp;
    this.elseExp = elseExp;
    conditionExp.addPreviousNode(this);
    thenExp.addPreviousNode(this);
    elseExp.addPreviousNode(this);
}
```

IfExp 的抽象語法樹如圖，根節點為IfExp
-   conditionExp：ASTNode 第一個子樹，為condition 的運算式
-   thenExp：ASTNode 第二個子樹，為then 的運算式
-   elseExp：ASTNode 第三個子樹，為else 的運算式

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/4.png?raw=true){:height="65%" width="65%"}

-   **OperationCallExp**: 
    -   `this.parameters`: 第二個子樹開始，不限個數的參數
    -   `this.isMethod`: 是否為函數呼叫

```java
public OperationCallExp(
    Constraint obj, 
    ASTNode source, 
    String name, 
    Classifier type, 
    boolean isMethod, 
    Collection<ASTNode> parameters
    ) 
{
    super(obj, source, name, type);
    this.parameters = new ArrayList<ASTNode>(parameters);
    this.isMethod = isMethod;
}
```

-   **IteratorExp**: 迭代器依靠呼叫 IterateExp 來產生迭代的 AST
    -   `global_iterate_id`: 來產生迭代的次數
    -   `addPreviousNode`: 將此次迭代變為下次迭代的 Parent

```java
public IterateExp(Constraint obj, ASTNode source, String name, ASTNode accInitExp, ASTNode bodyExp) {
    super(obj, source, name, accInitExp.getType());
    this.accInitExp = accInitExp; // Initial value of the iterator
    this.bodyExp = bodyExp; // Body of the iterator
    accInitExp.addPreviousNode(this);
    bodyExp.addPreviousNode(this);
    this.iterate_id = global_iterate_id++;
}
```

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
    result = if sideA@pre = sideB@pre then
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

##### 3.2 AST Post-Processor

因為 User 在描寫物件時會有一些口語上的習慣，因此會將 AST 再重構成結構簡單的 AST，他的條件如下:
1.  不符合前置條件的重構，以此產生不符合 Pre-condition 的 CLG
2.  Flat IfExp(扁平化 IfExp)
3.  Flat Logic Operator(扁平化 Logic Operator)
4.  iterate Operator simplify，只能出現
    -   variable = set of variables -> iterate(...)

##### 3.2.1 AST reconstruction

> 以下說明 AST 重構中每個條件的方法
{: .block-warning }

-   **不符合前置條件的重構**  
作者認為如果 Function 本身沒有錯誤但跳出 Expection 時，代表 Function 的 Pre-condition 不符合才會造成 Expection 的發生，
所以就將 Pre-condition 轉換為 **(not, 非前置條件)**，來產生不符合前置條件的 CLG。

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/7.png?raw=true){:height="100%" width="100%"}

> 上圖是一個不符合 Pre-condition 的 Triangle，可以看到所有的條件判斷都是相反的

-   **Flat IfExp**  
如果在不產生分支的運算式底下有 IfExp，則必須將 AST 扁平化，使 IfExp 拉到運算式 1 的上層，例如下面的範例:

```
context Class::method() : return_type
pre:
    exp1 op (if exp2 then exp3 else exp4)
```
> 這個例子可以用三元運算式來理解，`A = (B ? C : D)`，在某些語言中沒有 `?` 就會使用 `if` 取代

扁平化後將 if 拉到最上層，如下:

```
context Class::method() : return_type
pre:
    if exp2
        then exp1 op exp3
        else exp1 op exp4
```

-   **Flat Logic Operator**  
邏輯運算的扁平化主要有兩種狀況: `Binary operation(2元運算)`, `not operation(not運算)`

**Binary operation** 的狀況跟 IfExp 類似，如在不產生分支的 Operator 下有邏輯運算式，就將 IfExp 拉到最上層:

```
context Class::method() : return_type
pre:
    exp1 op (exp2 or exp3)

<!-- Flat -->
context Class::method() : return_type
pre:
    if exp2 or exp3
        then exp1 op true
        else exp1 op true
```

**not operation** 則透過 [De Morgan's laws] 來拆解，下表是針對 Operation 而定義出的 DeOperation:

<div align="center">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/11.png?raw=true" 
    width="55%" height="55%">
</div>

如果有 `exp1 and exp2` 做 not 運算，則會變成 `(not (exp1)) or (not (exp2))`，上表的可靠性可以透過真值表來做驗證:

<div align="center">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/12.png?raw=true" 
    width="62%" height="62%">
</div>

-   **Iterate Operator 的格式簡單化**
由於 iterate 的圖較為複雜，為了讓限制邏輯圖中的限制式簡單化，我們只接受如重構條件 4 的格式。
若使用者提供的物件限制語言中的運算式不符以上的格式，在我們的系統中會強制重構。

> variable = set of variables -> iterate(...)

##### 3.3 Constraint Logic Graph Generator Architeture

##### 3.3.1 不符合前置條件的完整限制邏輯圖

不符合前置條件的限制邏輯圖在 AST Post-prossing 就將前置條件重構，因此不需要在 CLG 產生器架構中做額外動作，
但是一個 Funciton 可能有多個不同的 Execption 跳出，這時就需要寫多個前置條件，這樣就會有兩個獨立的 CLG。

```
context Class::Method(Parameter : Type) 
pre Constraint_Name_1 :
    Constraint_1
pre Constraint_Name_2 :
    Constraint_2
```

> 多個前置條件來實現多個例外描述，並且以限制式的名稱來做為 Exception 的名稱

##### 3.3.2 符合前置條件的完整限制邏輯圖

根據 OCL 設計的三種限制式，把所有前置與後置條件結合 Function 的 CLG 就是該 Function 的所有可能的限制邏輯圖，
而在解析中一個前置條件就是一個限制式，所以這裡需要把所有前置條件與後置條件銜接起來。

CLG 的做法就是找出待測 Function 的 Pre/Post-Condition 的集合。

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/8.png?raw=true){:height="90%" width="90%"}

##### 3.4 Definition of Constraint logic graph

-   限制節點(Constraint Node): 以方框表示
    -   唯一含有限制式的 AST 的 Node，在限制節點中的一定都是布林運算式，並只有以下可能:
        1.  Relational Operator(關係運算式)
        2.  True/False Symbol
        3.  Boolen Operator(布林運算式)
        4.  Not Operator(否運算式)
-   連接節點(Connection Node): 以菱形表示
    -   作為連接用，CLG 中唯一會連接到分支的圖形
-   起始節點(Start Node): 黑色圓形
    -   CLG 的起點，所有 CLG 都需要由此 Node 開始 
-   結束節點(End Node): 黑色圓形帶外框
    -   CLG 的結束點，所有 CLG 都需要由此 Node 結束

##### 3.5 Generation of Constraint logic graph

每一顆 Abstract syntax tree(AST) 都是一個運算式，所以每個運算式都可以透過 Call toCLG(criterion) 來透過走訪產生限制邏輯子圖。
如果這顆樹沒有分支就代表該樹下的所有節點都產生在同一個 CLG 限制節點內，如下圖:

<div align="center">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/9.png?raw=true" 
    width="35%" height="35%">
</div>

在這之後的討論會以三種不同的 Covaerage criteria 與會產生分支的運算式來做討論，下表說明什麼運算式會產生分支:

<div align="center">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/6.png?raw=true" 
    width="53%" height="53%">
</div>

##### 3.5.1 Decision Coverage

**IfExp**

IfExp 與原始定義相同，如果 If 內為 True 就執行 Then 運算式，否則執行 Else 運算式，因為使用 DC 標準所以不會再展開 IfExp，但需要一個 False 的分支。

```
toCLG(Criterion criterion) 
{
    ASTNode astNotNode = new OperationCallExp(node.conditionExp, "not");
    return ifCLG(
        node.conditionExp.toCLG(criterion),
        node.thenExp.toCLG(criterion), 
        astNotNode.toCLG(criterion),
        node.elseExp.toCLG(criterion)
        );
}

ifCLG(
    (CLGNode condNode, CLGNode condEnd),
    (CLGNode thenNode, CLGNode thenEnd),
    (CLGNode notCondNode, CLGNode notCondEnd),
    (CLGNode elseNode, CLGNode elseEnd)):(CLGNode, CLGNode) 
{
    ConnectionNode beginConnecting = new ConnectionNode();
    ConnectionNode endConnecting = new ConnectionNode();

    beginConnecting.connect(condNode);
    beginConnecting.connect(notCondNode);
    condEnd.connect(thenNode);
    notCondEnd.connect(elseNode);
    thenEnd.connect(endConnecting);
    elseEnd.connect(endConnecting);
    return (beginConnecting, endConnecting);
}
```

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/10.png?raw=true){:height="100%" width="100%"}

> 上圖是 IfExp AST & CLG 的轉換對照圖

**IterateExp**

-   因為 CLP 的變數是一個固定值，因此會在變數後面加上 Iterate 的編號
-   左邊的迴圈在條件終止前會不斷迭代
    1.  累加器(IterateAcc) Init
    2.  迴圈計數器(IterateIndex) Init
    3.  迴圈條件判斷
    4.  Collection 取出這次迭代的值
    5.  IterateAcc = IterateBody
    6.  IterateIndex++

> 前綴 # 代表是作者創造的變數，後面的數字是為了區分是第幾個 Iterate 的運算式

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/13.png?raw=true){:height="100%" width="100%"}

> 上圖是 IterateExp AST & CLG 的轉換對照圖

**DC Example of Triangle:**

> DC 只需要展開 Decision 的真假值
{: .block-warning }

以下是一個 Triangle 的前置條件 AST 符合 Pre-Condition CLG 的結果，並且之後的測試覆蓋標準都會以 Triangle 為例:

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/14.png?raw=true){:height="100%" width="100%"}

以下是符合/不符合 Pre-condition 的兩種 CLG:

DC 中不符合 Pre-condition 的 CLG 會將所有的運算式做 DeOperation，並且在 DC 中不會展開 Boolean(or) 運算式，因此只會有一條路徑:

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/15.png?raw=true){:height="100%" width="100%"}

而符合 Pre-condition 的 CLG 中 Boolean(and) 在 DC 標準中也不會展開因此只會有 Pre-condition 的限制式與 Post-condition 的限制式:

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/16.png?raw=true){:height="100%" width="100%"}

Triangle::category 因為只有 Post-condition 故沒有接其他限制邏輯圖:

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/17.png?raw=true){:height="100%" width="100%"}

##### 3.5.2 Decision condition coverage

> DCC 與 DC 的不同在於需要展開有分支的限制邏輯子圖，所有條件與決策的真與假值都必須執行過一次，但不用包含所有的條件組合
{: .block-warning }

**and & or**

-   and 運算式來說 Exp1 and Exp2，兩者為真才為真，因此在 CLG 的角度來看就是兩個節點連在一起
-   or 運算式則是 Exp1 or Exp2，其中之一為真即為真，故從 CLG 的角度來看 Exp1/2 可以視作兩條路徑上的節點，
並且根據 DCC 的定義，至少有一次的 True 與 False，因此會如下圖所示:

<div style="display: flex; justify-content: center;">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/18.png?raw=true" 
    width="35%" height="35%">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/19.png?raw=true" 
    width="35%" height="35%">
</div>

**xor & implies**

-   xor 運算式為 Exp1 xor Exp2，兩者不同才為真，因此在 CLG 的轉換圖如下，其中 not(Exp1) 代表取 Exp1 的反值
-   implies 運算式為 Exp1 implies Exp2，視作 (not exp1) or exp2

<div style="display: flex; justify-content: center;">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/20.png?raw=true" 
    width="35%" height="35%">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/21.png?raw=true" 
    width="35%" height="35%">
</div>

**DCC Example of Triangle:**

以下是一個 Triangle 的前置條件 AST 不符合 Pre-Condition CLG 的結果，因為 DCC 需要展開 Boolean(or) 運算式，因此不符合 Pre-condition 的 CLG 需要展開:

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/7.png?raw=true){:height="100%" width="100%"}

每遇到一次 or 產生一個條件為假其餘為真的路徑，而 AST 共有六個 or 運算式，因此 CLG 會有六條路徑，如下圖:

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/22.png?raw=true){:height="100%" width="100%"}

而在使用 DCC 時產生的符合 Pre-condition 的 CLG，因為前置條件皆為 and 故只有一條明顯路徑:

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/23.png?raw=true){:height="100%" width="100%"}

##### 3.5.3 Multiple condition coverage

> MCC 與 DCC 不同的是，MCC 需要展開所有的條件組合，因此會有 2<sup>n</sup> + 1 條路徑，其中 n 為條件的數量
{: .block-warning }

**or**

-   因此在真值表中可以發現 Exp1 or Exp2 一共會有三種可能讓此運算式為真，因此 CLG 會如下圖:

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/24.png?raw=true){:height="85%" width="85%"}

**DCC Example of Triangle:**

因為這樣產生的 CLG 非常複雜所以這裡就不放上，但這個 CLG 因為有五個同一層級的 or 因此會有 2<sup>5</sup> = 32 + 1 條路徑。

---

### 4. Equivalence Class CLG Path Generator

[4.1 CLG Paths lister](./2023-09-07-test_case_generation_based_on_constraint_logic_graph.html#41-clg-paths-lister)  
[4.2 Path Post-Processor](./2023-09-07-test_case_generation_based_on_constraint_logic_graph.html#42-path-post-processor)  
[4.3 Constraint Logic Program Coverage Criteria](./2023-09-07-test_case_generation_based_on_constraint_logic_graph.html#43-constraint-logic-program-coverage-criteria)  
[4.4 Triangle Example - Paths and Test Case](./2023-09-07-test_case_generation_based_on_constraint_logic_graph.html#44-triangle-example---paths-and-test-case)  

這裡描述如何將 CLG 中的等價行為做分割，也就是從 CLG 中分割出不同的 Complete Path，產生測試路徑的架構圖如下:

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/28.png?raw=true){:height="85%" width="85%"}

當滿足以下兩個條件的其中一個，路徑條列就會結束:
1.  可實行路徑組滿足覆蓋標準
2.  失敗的路徑次數已經超過可容許錯誤次數

整個 CLG 的路徑條列器工作流程如下:
1.  透過 CLG 覆蓋標準找尋完整路徑
2.  經由 Path Post-Processing 
3.  交給 CLP Generator 然後由 Eclipseclp 求解(測試資料)
4.  收集路徑與測試資料直到條件達成

> 這裡所使用的 CLP Generator 使用 Y.-T. Lan, Automatic Conversion from UML/OCL Specification to CLP Specification, 2015. 所提出的方法

##### 4.1 CLG Paths lister

作者使用 BFS 來對 CLG Traverse

##### 4.1.1 PathFinder Object Implementation

作者實作了一個名為 FeasiblePathFinder Class，他的屬性與參數與方法如下:

```
FeasiblePathFinder(CoverageCriterion criterion, CLGNode graph, Model model)
    CoverageCriterion criterion; //覆蓋標準
    Queue<List<CLGNode>> path_queue; //未完整路徑佇列
    Model model; //UML 類別圖
```

-   `Path getNextPath()`
    -   會從此 CLG 的 StartNode 加入 `path_queue`，在之後的每次迭代把往下的 Node 全部加入 path_queue，如果有多條 path 就複製現有的 `List<CLGNode>` 並把不同的分支加入不同的 `List<CLGNode>`，
    並檢查是否有已經完整的 Path，有則暫停並 Return path
-   `isCompletePath(List<CLGNode> path)`
    -   檢查是否為完整路徑，完整路徑的最後節點必然是 EndNode。

如果已經產生過的 Complete Path ，再次被產生就判斷已經沒有路徑可以產生，因此會回傳 null，這樣就可以避免無限迴圈

##### 4.2 Path Post-Processor

一個完整路徑需要做後處理才能轉換成 CLP，Path Post-Processor 對路徑做三件事:

1.  邊界值尋找器(Boundary value finder)
2.  隱含後置條件的復原器(Implicit post-condition meger)
3.  以靜態單賦值形式(Static Single Assignment Form，SSA Form) 再次給予各個變數名稱

##### 4.2.1 Boundary value finder

透過邊界值理論，對於 Path 中的每個限制式都視做 Domain 的一條邊界，透過呼叫 getBoundaryCombinationVariants() 產生符合的路徑如下:

<div style="display: flex; justify-content: center;">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/29.png?raw=true" 
    width="30%" height="30%">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/30.png?raw=true" 
    width="30%" height="30%">
</div>

> 上圖左為原始邊界，圖右分別為 內部點，兩條封閉邊界上的兩個點，以要遍歷 <, = 可以計算為 1 + n<sup>op</sup> - 1

##### 4.2.2 Implicit Post-Condition Restorer

在 CLG 中如果在 Post-Condition 中沒有特別指定物件的屬性是否有改變，就代表受測函式執行前後的屬性是一樣的，因此在產生測試路徑後可以先判斷 Post-Condtion 是否有定義 Pre-State 的改變，
如果沒有就在完整路徑上補上隱含的 Post-Condtion，如下:

```
<!-- Complete Path -->
self@pre.sideA <> self@pre.sideB
self@pre.sideA = self@pre.sideC
result = “Isosceles”
<!-- Add Post-Processing -->
self.sideA = self.sideA
self.sideB = self.sideB
self.sideC = self.sideC
```

> 下面三個 Post-Processor 產生的限制式會被加入完整路徑中

##### 4.2.3 Static Single-Assignment Processor

因為 CLP 中每個變數都只能有一個值，因此遇到迴圈時就需要另外處理變數名稱，例如以下的例子:

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/31.png?raw=true){:height="100%" width="100%"}

每次迭代就在後面加上數字代表這次迭代的變數，並將其收集就能知道一次迭代上的所有限制式。

##### 4.2.4 Path Object Implementation

以下是 Path Class 的屬性、參數與方法如下:

```
Path(List<CLGNode> nodes, Model model)
    List<CLGNode> nodes;
    int id;
    List<ASTNode> actual_asts;
    Model model;
    Constraint dresden_constraint;
```

-   `List<ASTNode> getASTNodes()`
    -   取得全部限制節點中的抽象語法樹(回傳 actual_asts)
-   `void analysisASTNodes()`
    -   會先呼叫 prepareNewSymbolTable() 來準備變數的符號表，針對#IterateAcc、#IterateIndex、#IterateElement 三個變數做特別處理，
    若這三個變數在 Operator 的左邊則將變數名稱替換成 `OriginalName + Number`
-   `private List<OperationCallExp> getEqualExpsForAttributeConsistency()`
    -   偵測是否有屬性在 Post-Condtion 中有改變，若無則回傳一系列的 `Attribute = Attribute@Pre`
-   `private HashMap<String, Integer> prepareNewSymbolTable()`
    -   準備所有 Variable 的符號表，String 為變數名稱，Integer 為變數的位置，1 是 self, 2 開始是 parameter, 3 是 parameter 的 return value
-   `private Set<Attribute> findUnchangedPropertyForParameter(final HashMap<String, Set<PropertyCallExp>> changedPropertyCallExprs, Parameter parameter)`
    -   偵測是否有屬性在 Post-Condtion 中有改變，若無則回傳一系列的 `Attribute = Attribute@Pre`
-   `public List<Path> getBoundaryCombinationVariants()`
    -   透過呼叫 `calculateVariants()` 取得來源路徑中符合邊界值覆蓋的組合，接著複製相對應數量的路徑並將組合中的 OperationCallExp 取代原本的，並輸出全部組合的 Queue
-   `private List<List<Pair<Integer, String>>> calculateVariants()`
    -   會將 CLG 中的限制節點的 AST Node 中的邊界取出，並以一個固定規則來轉換
    -   例如之前的 A <= B, B <= C，會將 <= 的位置取出，以 <<, <=, =<, == 的組合來取代，並刪除不合理的組合 `==`

##### 4.3 Constraint Logic Program Coverage Criteria

這章節會介紹 Coverage Criteria 的 Interface，要注意這裡談的是為了產生路徑的測試覆蓋標準，在 CLG Coverage Criteria 中作者目前僅有 Edge Coverage，
也就是對所有邊界覆蓋。

##### 4.3.1 Coverage Criteria Interface

-   `void addFeasiblePath (List<CLGNode> path)`
    -   當 Path 已經確定有解，這條 Path 放入 Feasible Path 中
-   `void addInfeasiblePath (List<CLGNode> path)`
    -   當 Path 無解，這條 Path 放入 Infeasible Path 中
-   `void analysisTagetGraph(CLGNode graph)`
    -   在產生完完整的限制邏輯圖之後，我們會使用此函式來幫忙分析這張完整的限制邏輯圖會需要覆蓋那些資訊
-   `boolean meetRequirement()`
    -   此函式是幫忙檢測是否已經將該覆蓋到的地方都已經覆蓋到了
-   `boolean isVisitedFeasiblePath (List<CLGNode> path)`
    -   此函式是幫忙檢測輸入的這條路徑是否已經被標註為可實行路徑
-   `boolean isVisitedInfeasiblePath (List<CLGNode> path)`
    -   此函式是幫忙檢測輸入的這條路徑是否已經被標註為不可實行路徑

##### 4.3.2 Edge Coverage

```
Set<ImmutablePair<CLGNode, CLGNode>> all_branches; //全部的邊(點與點的配對)
Set<ImmutablePair<CLGNode, CLGNode>> visited_branches; //已經走訪過的邊
Set<List<CLGNode>> infeasible_path; //已走訪過不可實行路徑 
Set<List<CLGNode>> feasible_path; //已走訪過可實行路徑
```

透過比較 `all_branches` 與 `visited_branches` 兩個集合內的邊，用來查看是 否全部的邊都已經被走訪過。

> 因為不同測試標準會有不同的 CLG 因此在走訪完全部路徑就代表達成測試覆蓋標準

##### 4.4 Triangle Example - Paths and Test Case

在這裡我只舉用了 Triangle Consturctor 的符合/不符合 Pre-condition 為例子:

##### 4.4.1 Decision coverage testcase

Triangle 在 DC 測試標準下符合 Pre-condition 的測試資料只有一條，如下:

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/16.png?raw=true){:height="100%" width="100%"}

| Path | Parameter | Return value | Post-condition |
| :---: | :---: | :---: | :---: |
| 1 | 1, 1, 1 | void | Triangle(1, 1, 1) |

Triangle 在 DC 測試標準下不符合 Pre-condition 的測試資料會有，但是在 Boundary value finder 上會把 or 做展開，因此會有七條路徑，如下:

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/15.png?raw=true){:height="100%" width="100%"}

| Path | Parameter | Execption |
| :---: | :---: | :---: |
| 1 | -10, -10, -10 | void |

> 7條 Paths minumum solutions 都相同，這裡不全部列出

##### 4.4.2 Decision condition coverage testcase

Triangle 在 DCC 下不符合 Pre-condition 的測試

---

### 5. Test Case Generator

##### 5.2 Performance of Coverage Criteria

由於 Coverage Criteria 會產生不同的 CLG，產生路徑的時間與涵蓋到的內容也不一樣，我們將範例資訊顯示在下表，
Class info 分別代表: Class Num, Association Num, Function Num, Can be excption function Num:

-   IntegerRange: iterate 測試
-   RecursionExample: fibonacci, factorial
-   Triangle, Date: 表現複雜的分支測試
-   Laboratory: 關聯多個類別的物件

| Example | Class info | AST Node | Iteration |
| :---: | :---: | :---: | :---: |
| IntegerRange | 1/0/2/0 | 38 | Yes |
| RecursionExample | 1/0/2/2 | 49 | No |
| Triangle | 1/0/2/1 | 213 | No |
| Date | 1/0/8/1 | 816 | No |
| Laboratory | 3/3/8/1 | 124 | No |

然後分別展示三種 Coverage Criteria 的產生結果，主要分別討論符合/不符合 Pre-condition 的產生結果:

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/25.png?raw=true){:height="100%" width="100%"}

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/26.png?raw=true){:height="100%" width="100%"}

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-09-07-test_case_generation_based_on_constraint_logic_graph/27.png?raw=true){:height="100%" width="100%"}

就跟預料的一樣所花費時間 DC > DCC > MCC
-   Date 是花費時間最長的範例，因為 Date 中有更多的 if, or 運算式
-   Laboratory 是花費時間第二長的範例，因為 Laboratory 中有許多關聯物件，導致需要一併產生才能完成

同時在 DCC, MCC 中會產生許多條不可實行路徑，例如以下的例子:

```
context Date::Date(y : Integer, m : Integer, d : Integer)
    pre DateErrorException:
    if (y.mod(400) = 0) or (y.mod(4) = 0 and y.mod(100) <> 0)
        then d <= 29
```

DCC 會產生一條左為真，右為假的例子: `y.mod(400) = 0, y.mod(4) <> 0, y.mod(100) <> 0` 沒有數字能夠符合這三個條件，因此這條路徑是不可實行的

```
context Date::Date(y : Integer, m : Integer, d : Integer)
    pre DateErrorException:
    if ((m = 1) or (m = 3) or (m = 5) or (m = 7) or (m = 8) or (m = 10) or (m = 12))
        then d <= 31
```

MCC 為了產生所有的組合，會有 m=1, m=3 這樣的例子出現

##### 5.3 Quality of Coverage Criteria

使用 [PIT] 來驗證三種 Coverage Criteria 下產生的 Test Case 的品質，DC 在各方面都表現得較差，而 DCC, MCC 雖然 MCC 可以產生更多的測試案例，
但兩者的突變分數幾乎一樣，因此一般情況下使用 DCC 即可做到 MCC 差不多程度的覆蓋度。

但是在幾個特定案例下，都無法達到 100% 的覆蓋度，因為透過 CLP 找解時會優先找出最簡的解(最小值)，因此例如: parm < 10 突變為 parm <= 10 時，
就無法找出其中錯誤。

---

### 6. Conclusion and Future Work

作者實作出了可以輔助測試驅動開發的系統，基於限制邏輯圖的測試案例產生器，透過規格文件產生黑箱函式測試案例。

OCL 僅能支援部分 String 與部分 Collection 與完整的 Integer 型態。

並在撰寫時需要明確寫出使用到的物件皆為前置狀態(意指obj@pre)，避免我們誤判成後置條件有被更動。

另外就是如何判斷無效的測試路徑，如 5.2 所述的無效路徑將浪費大量的時間，因為這裡無效的判斷方式是以 CLP 的求解與超時來決定，
如果有多個無解路徑將必然消耗固定的等待時間。

> ##### NOTE
> Last edit 11-15-2023 12:55  
{: .block-warning }

[Constraint Satisfaction Problem]: ./2022-11-08-ai_csp.html
[Equivalence class]: https://en.wikipedia.org/wiki/Equivalence_class
[DNF]: https://en.wikipedia.org/wiki/Disjunctive_normal_form
[ECLiPSeclp]: http://eclipseclp.org/
[UML]: 2023-07-26-unified_modeling_language.html

[Paper An Analysis and Survey of the Development of Mutation Testing]: 2023-05-20-analysis_mutation_testing.html
[HOL-TestGen]: https://brucker.ch/projects/hol-testgen/

[De Morgan's laws]: https://en.wikipedia.org/wiki/De_Morgan%27s_laws

[PIT]: https://pitest.org/