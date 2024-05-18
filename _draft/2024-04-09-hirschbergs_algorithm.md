---
title: "Algorithm | Hirschberg's Algorithm"
author: Benson Hsu
date: 2024-04-09
category: Jekylls
layout: post
tags: [Algorithm]
---

> Notes: Hirschberg's Algorithm, [A Linear Space Algorithm for Computing Maximal Common Subsequences]. 
{: .block-tip }

Hirschberg's Algorithm 是一種用來解決 Needleman-Wunsch Algorithm 的空間複雜度的演算法，原本的空間複雜度為 O(m*n)。
在論文的發表時間(1975)，記憶體是一個很昂貴的資源，所以 Hirschberg's Algorithm 的提出是一個很大的突破。

這個問題如果想要實際寫程式的話，可以參考 LeetCode [72. Edit Distance]。

### Introduction

##### Edit distance

Edit distance 是針對兩個 String 之間的差異度的量化測量，可以用來判斷兩個字串之間的相似度，在 DNA 或 Unix 的 diff 等等應用上都有很大的用途。

> [Levenshtein distance] 是指將一個字串變成另一個字串所需要的最少操作次數，操作包括 Insert, Delete, Replace。

$$
lev(a, b) =
\left\{
\begin{aligned}
& |a|, && \text{if } |b| = 0 \\
& |b|, && \text{if } |a| = 0 \\
& lev (tail(a), tail(b)), && \text{if } head(a) = head(b) \\
& 1 + min \left\{
    \begin{aligned}
        & lev(tail(a), b) \\
        & lev(a, tail(b)) \\
        & lev(tail(a), tail(b))
    \end{aligned}
    \right. && \text{otherwise}
\end{aligned}
\right.
$$

-   "Benson", "Ben" 這兩個字串的 Edit distance 為 3
    -   要把 "Benson" 變成 "Ben" 需要做 3 次 Delete 操作
    -   要把 "Ben" 變成 "Benson" 需要做 3 次 Insert 操作

這邊會介紹 Needleman-Wunsch Algorithm 和 Hirschberg's Algorithm 這兩個演算法，用來計算兩個字串之間的 Edit distance。

---

### Needleman-Wunsch Algorithm

> Needleman-Wunsch Algorithm, [A general method applicable to the search for similarities in the amino acid sequence of two proteins].
{: .block-tip }

Needleman-Wunsch Algorithm 是生物資訊中用來比對蛋白質或 DNA 序列的演算法，最早於 1970 年提出。是很標準的 Dynamic Programming 演算法，用來計算兩個序列之間的最佳對齊。

-   Time Complexity O(mn), Space Complexity O(mn)

假如我們有兩個字串 `Benson` 和 `Ben`

##### Step 1: Create a DP Table

跟大部分的 DP 演算法一樣，我們需要先建立一個 DP Table，用來存放每個子問題的解，大小為 `(m+1) * (n+1)`。

##### Step 2: Choose a scoring system

假如兩個字串要做 Align 的話，每個位置只有三種可能的情況 match, mismatch, gap，在 Needleman-Wunsch Algorithm 中有很多種評分標準，
這裡使用 min 來作為評分方法的話，可以設計以下的 Scoring System:

-   Match: 0
-   Mismatch: 1
-   Gap: 1

##### Step 3: Initialize the DP Table

現在我們依照 Gap 的評分標準，初始化 DP Table 的第一列和第一行。

![](/image/2024/04-09-hirschbergs_algorithm/1.jpg)

##### Step 4: Fill in the DP Table

-   *Dynamic programming recursive formula:*

$$
dp(i, j) =
\left\{
\begin{aligned}
& dp(i-1, j-1), && \text{if } x(i) = y(j) \\
& min \left\{
    \begin{aligned}
        dp(i-1, j-1) + 1 \\
        dp(i-1, j) + 1 \\
        dp(i, j-1) + 1
    \end{aligned}
    \right., && \text{otherwise}
\end{aligned}
\right.
$$

-   依照上面的 *Recursive Formula* 依序歷遍整個 DP Table，注意是以 Row-Major 的方式填入 DP Table
    -   如果 `x(i) = y(j)`，則 `dp(i, j)` 直接取左上角的值
    -   否則取 `Left`, `Top`, `Left-Top` + 1 的最小值

![](/image/2024/04-09-hirschbergs_algorithm/2.jpg)

##### Step 5: Traceback

最後我們可以從右下角的位置開始往左上角回溯，因為之前使用的 Scoring System，這裡我們使用 Min trace back:
-   `⇦` 代表左側的字串要塞入一個 Gap
-   `⇧` 代表上方的字串要塞入一個 Gap
-   `⇖` 代表這兩個字元是 Match

![](/image/2024/04-09-hirschbergs_algorithm/3.jpg)

最後的 Alignment 結果如下，Benson 和 Ben 之間的 Edit distance 為 3:

```
Benson
Ben---
```

> 但是在 DNA 比對中往往資料量很大，所以 Needleman-Wunsch Algorithm 的空間複雜度是 O(mn)，這樣的空間複雜度在當時的記憶體是一個很大的負擔。
{: .block-warning }

---

### Hirschberg's Algorithm

Hirschberg's Algorithm 可以在 **Space Complexity O(min(m, n))** 的情況下，計算出 Needleman-Wunsch Algorithm 的結果，
並且保持 **Time Complexity O(mn)**，並且 Hirschberg's Algorithm 是一個 Divide and Conquer 的演算法。

##### Divide and Conquer

首先要能做到 Divide and Conquer，我們需要確定一個 Base Case 被拆分後還是可以滿足原本的問題。

-   假如有兩個字串 "

> ##### Last Edit
> 04-21-2024 19:32
{: .block-warning }

[A Linear Space Algorithm for Computing Maximal Common Subsequences]: https://dl.acm.org/doi/10.1145/360825.360861
[A general method applicable to the search for similarities in the amino acid sequence of two proteins]: https://www.sciencedirect.com/science/article/abs/pii/0022283670900574?via%3Dihub

[Levenshtein distance]: https://en.wikipedia.org/wiki/Levenshtein_distance

[72. Edit Distance]: https://leetcode.com/problems/edit-distance