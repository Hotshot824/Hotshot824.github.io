---
title: "Paper | KLEE: Introducing Symbolic Execution"
author: Benson Hsu
date: 2024-10-17
category: Jekyll
layout: post
tags: [software, software_qualitiy, symbolic_execution]
---

> Cristian Cadar, Daniel Dunbar, and Dawson R. Engler. 2008. KLEE: Unassisted and Automatic Generation of High-Coverage Tests for Complex Systems Programs. In 8th USENIX Symposium on Operating Systems Design and Implementation, OSDI 2008, December 8--10, 2008, San Diego, California, USA, Proceedings, Richard Draves and Robbert van Renesse (Eds.). USENIX Association, 209--224. http://www.usenix.org/events/osdi08/tech/full_papers/cadar/cadar.pdf
{: .block-tip }

> KLEE 是在符號執行 (Symbolic Execution) 領域中的成功案例，這裡介紹 2008 年 KLEE 的原始論文，以此來了解符號執行的基本概念。
{: .block-tip }

### 1. Introduction

**Program Analysis Tools :**

軟體分析工具具體可以分為兩類，Dynamic Analysis 和 Static Analysis，簡單可以理解為：
-   Dynmaic Analysis: 需要具體的執行 Binary code，透過執行過程中的資訊來進行分析
    -   例如：gdb, valgrind
-   Static Analysis: 只需要具體的 Source code，不需要執行 Binary code
    -   例如：pylint, clang-tidy, clang-format

> Symbolic execution 也是靜態分析的一種，透過對變數的符號化來進行分析該變數的可能值

**Why we need Symbolic execution?**

首先 Testing 對於大部分程式開發過程中都是一個 Pain point，並且編寫 Testcase 相較於 Development 來說往往讓人感到 ennui。
並且手動測試往往是不夠的，如果一個 Bug 早就已經知道他是存在的，那就應該不叫做 Bug。

即使手動編寫 Unit Test，也往往無法達到足夠的覆蓋率，到目前也沒有一種良好的規範化的方法來產生 Testcase，
因此我們需要一種 Automation 的方法來產生 Testcase，這就是 Symbolic execution 的目的。

> 並且在 C 中 assert 往往可能在 -o2 -o3 的編譯器優化中被去除，導致這些 assert 在正式的環境中是無效的

**Symbolic Execution Advantages:**

-   對於一個程式覆蓋所有可能的分支路徑
-   檢查可能產生危險操作的分支路徑, e.g. buffer overflow, null pointer dereference
-   自動產生的測試案例
-   不需要實際運行程式

**History of Symbolic Execution:**

![](/image/2024/10-17-KLEE_symbolic_execution/1.png)

Symbolic execution 這個概念最早是由 King 在 1976 年提出，但當時受限於 SMT Solver 還無法實際應用在實際的程式中。
直到 2000 年左右各種 SMT Solver 開始發展，Symbolic execution 才開始有了實際的應用。

KLEE 是在 2008 年發表於 OSDI，但在之後的數十年中，KLEE 是在該領域中的一個成功案例，並且舉辦了自己的 Workshop。

---

### 2. KLEE Example

```c
1 : void expand(char *arg, unsigned char*buffer) { 8
2 : int i, ac; 9
3 : while (*arg) { 4 : if (*arg == ’\\’) { 10*
11*
5 : arg++;
6 : i = ac = 0;
7 : if (*arg >= ’0’ && *arg <= ’7’) {
8 : do {
9 : ac = (ac << 3) + *arg++− ’0’;
10: i++;
11: } while (i<4 && *arg>=’0’ && *arg<=’7’);
12: *buffer++ = ac;
13: } else if (*arg != ’\0’)
14: *buffer++ = *arg++;
15: } else if (*arg == ’[’) { 12*
16: arg++; 13
17: i = *arg++; 14
18: if (*arg++ != ’-’) { 15!
19: *buffer++ = ’[’;
20: arg−= 2;
21: continue;
22: }
23: ac = *arg++;
24: while (i <= ac) *buffer++ = i++;
25: arg++; /* Skip ’]’ */
26: } else
27: *buffer++ = *arg++;
28: }
29: }
30: . . .
31: int main(int argc, char* argv[ ]) { 1
32: int index = 1; 2
33: if (argc > 1 && argv[index][0] ==’-’) { 3*
34: . . . 4
35: } 5
36: . . . 6
37: expand(argv[index++], index); 7
38: . . .
39: }
```
    
> TBC ...
{: .block-warning }

> ##### Last Edit
> 10-26-2024 19:48
{: .block-warning }