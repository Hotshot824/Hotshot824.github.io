---
title: "Note | Test Coverage Criteria"
author: Benson Hsu
date: 2023-11-28
category: Jekyll
layout: post
tags: [software, software_qualitiy]
---

> Software testing course notes from CCU, lecturer Nai-Wei Lin.  
> 本關介紹關於 Structural Testing 的 Test Coverage Criteria，分為兩個部分 Control Flow 與 Data Flow 
{: .block-tip }

### 1.1 Control Flow

在 Control Flow 中，Coverage Criteria 通常注意的是 Edge, Node, Condition，透過這些是否被執行到來判斷是否有達到覆蓋的標準

-   Statement coverage (SC)
-   Decision coverage (DC)
-   Condition coverage (CC)
-   Decision/condition coverage (D/CC)
-   Multiple condition coverage (MCC)
-   Path coverage (PC)

上面的這幾個例子都會用以下的圖來講解:

![](/image/2023/11-28-test_coverage_criteria/1.png){:height="50%" width="50%"}

##### Statement coverage (SC)

-   Every statementin the program has been executed at least once.
    -   1 -> 2 -> 3 -> 4 -> 5 -> 2 -> 6

Statement Coverage 又可以被稱為 Node Coverage，基本上就是要求每個 Statement 都要被執行到，
但是 Statement Coverage 並不會要求每個 Decision 都要被執行到，所以有可能會有一些 Decision 沒有被執行到。

##### Decision Coverage (DC)

-   Every statementin the program has been executed at least once, 
and every decisionin the program has taken all possible outcomes at least once.
    -   1 -> 2 -> 3 -> 4 -> 5 -> 2 -> 6
    -   1 -> 2 -> 3 -> 5 -> 2 -> 6

Decision Coverage 又可以被稱為 Edge Coverage，基本上就是要求每個 Edge 都要被執行到，所以 Decision Node 就會有分支產生，
就算 Decision Node 中有多個 Condition，但也只要求 Decision 的 True/False 都要被執行到。

##### Condition Coverage (CC)

-   Every statementin the program has been executed at least once, 
and every conditionin each decision has taken all possible outcomes at least once.

程式中的每個 Condition 都要是少執行到一次 True/False，但不一定要求每個 Decision 都要被執行到。

##### Decision/condition coverage (D/CC)

-   Every statementin the program has been executed at least once, 
every decisionin the program has taken all possible outcomes at least once, 
and every conditionin each decision has taken all possible outcomes at least once.

程式中的每個 Condition 與 Decision 都要是少執行到一次 True/False。

##### Multiple Condition Coverage (MCC)

-   Every **statement** in the program has been executed at least once, 
**all possible combination of condition outcomes** in each decision has been invoked at least once.
-   There are **2<sup>n</sup>** combinations of condition outcomes in a decision with **n** conditions.

程式中的每個 Condition 的可能的組合都要被執行到，所以有 n 個 Condition 就會有 2<sup>n</sup> 種可能的組合。

![](/image/2023/11-28-test_coverage_criteria/2.png){:height="100%" width="100%"}

所以以上面的突來說，如果 Condiction 是 C<sub>A</sub>, C<sub>B</sub>, C<sub>C</sub>:
-   **DC**: 一個 1 與 2 的組合都能滿足標準
-   **CC**: 下標相同數字的組合都能滿足標準，因為 Condiction 都有被執行，例如: 1<sub>1</sub>, 2<sub>1</sub>
-   **DCC**: Combination 2 不可能滿足 DCC，其他下標相同的組合都能滿足 DCC，例如: 1<sub>1</sub>, 2<sub>1</sub>
    -   因為 2, 7 的組合 Decision 都是 True，沒有滿足 Decision 的需求
-   **MCC**: Combination 1 ~ 8 都要被執行，3 個 Condiction 有 2<sup>3</sup> 種可能的組合

##### Path Coverage (PC)

-   Every complete pathin the program has been executed at least once.
-   A loop usually has an infinitenumber of complete paths.

> 通常不會用到 Path Coverage，並且在 PC 的標準下如果有迴圈將會產生無限條路徑

**Test Coverage Criteria Hierarchy**

而覆蓋的範圍從大到小依序為: **PC > MCC > D/CC > CC = DC > SC**

> 使用 D/CC 就能有不錯的覆蓋率，並且不會有太多的測試成本，所以 D/CC 是一個不錯的選擇
{: .block-tip }

---

### 1.2 Data Flow

Data Flow 中則有 Definition, Use, DU-Path 的概念，以這些是否被執行來判斷是否有達到覆蓋的標準

-   All-defs coverage
-   All-c-uses coverage
-   All-c-uses/some-p-uses coverage
-   All-p-uses coverage
-   All-p-uses/some-c-uses coverage
-   All-uses coverage
-   All-du-paths coverage

下圖是目前拿來做例子的 Control Flow Graph:

<div style="display: flex; flex-direction: row; align-items: center;">
    <img src="/image/2023/11-25-method_level_structural_unit_testing/10.png" 
    width="50%" height="50%">
    <img src="/image/2023/11-25-method_level_structural_unit_testing/11.png" 
    width="50%" height="50%">
</div>

> 上面兩條路徑是剛好覆蓋了全部 Node 的路徑，但是還要檢查是否有覆蓋到全部的 Associations
{: .block-warning }

##### All-Defs Coverage

-   Test cases include a definition-clear path from every definition to some corresponding use (c-use or p-use).

![](/image/2023/11-28-test_coverage_criteria/3.png){:height="50%" width="50%"}

> All-Defs 是相對寬鬆的標準，只要所有的 Definition 都有被執行到就能滿足標準

##### All-C-uses Coverage / All-P-Uses Coverage

-   All-C-uses:
    -   Test cases include a definition-clear path from every definition to all of its corresponding c-uses.
-   All-P-uses:
    -   Test cases include a definition-clear path from every definition to all of its corresponding p-uses.

> 都是要求全部的 C-use/P-use 被執行到

<div style="display: flex; flex-direction: row; align-items: center;">
    <img src="/image/2023/11-28-test_coverage_criteria/4.png" 
    width="50%" height="50%">
    <img src="/image/2023/11-28-test_coverage_criteria/5.png" 
    width="50%" height="50%">
</div>

##### All-C-Uses/Some-P-Uses Coverage / All-P-Uses/Some-C-Uses Coverage

-   All-C-Uses/Some-P-Uses:
    -   Test cases include a definition-clear path from every definition to all of its corresponding c-uses. 
    In addition, if a definition has no c-use, then test cases include a definition-clear path to some p-use.
-   All-P-Uses/Some-C-Uses:
    -   Test cases include a definition-clear path from every definition to all of its corresponding p-uses. 
    In addition, if a definition has no p-use, then test cases include a definition-clear path to some c-use.

> 都是要求全部的 C-use/P-use 被執行到，但是如果該變數沒有 C-use/P-use，則要求被執行另外一種 Use 至少一次

<div style="display: flex; flex-direction: row; align-items: center;">
    <img src="/image/2023/11-28-test_coverage_criteria/6.png" 
    width="50%" height="50%">
    <img src="/image/2023/11-28-test_coverage_criteria/7.png" 
    width="50%" height="50%">
</div>

##### All-Uses Coverage / All-DU-Paths Coverage

-   All-Uses:
    -   Test cases include a definition-clear path from every definition to each of its uses including both c-uses and p-uses.
-   All-DU-Paths:
    -   Test cases include all du-paths for each definition. Therefore, if there are multiple pathsbetween a given definition and a use, 
    they must all be included.

> All-Uses 與 All-DU-Paths 都是要求全部的 C-use/P-use 都被執行到，但是 All-DU-Paths 還要求全部的 DU-Paths 都被執行到，
> 通常只需要 All-Uses 就能滿足需求，All-DU-Paths 相對的測試成本會大很多

<div style="display: flex; flex-direction: row; align-items: center;">
    <img src="/image/2023/11-28-test_coverage_criteria/8.png" 
    width="50%" height="50%">
    <img src="/image/2023/11-28-test_coverage_criteria/9.png" 
    width="50%" height="50%">
</div>

**Test Coverage Criteria Hierarchy**

而覆蓋的範圍從大到小依序為: **All-paths > All-Du-Paths > All-Uses > All-C-Uses/Some-P-Uses = All-P-Uses/Some-C-Uses > All-C-Uses = All-Defs = All-P-Use**

> 使用 All-Uses 就能有不錯的覆蓋率，並且不會有太多的測試成本，所以 All-Uses 是一個不錯的選擇
{: .block-tip }

> ##### Last Edit
> 12-01-2023 16:02 
{: .block-warning }