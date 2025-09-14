---
title: "Algorithm | Big Number Multiplication"
author: Benson Hsu
date: 2025-09-13
category: Jekyll
layout: post
tags: [algorithm, leetcode]
---

#### Algorithm | 大數乘法

> 在演算法題目中，「大數乘法（Big Number Multiplication）」一直是經典卻讓人頭痛的練習題。
雖然數學上的乘法概念人人熟悉，但一旦限制不能用內建的大數類別（像 Java 的 BigInteger 或 Go 的 math/big），就只能乖乖用字串模擬直式乘法。
{: .block-tip }

> 尤其是 LLM 可以使用之後，更沒耐心去寫這種繁瑣的程式碼了，趕快複習一下。

實作的題目可以找 [Hackerrank. Extra Long Factorials], [43. Multiply Strings] 來練習。

[Hackerrank. Extra Long Factorials]: https://www.hackerrank.com/challenges/extra-long-factorials/problem?isFullScreen=true
[43. Multiply Strings]: https://leetcode.com/problems/multiply-strings/description/

#### Why Care About Big Number Multiplication

程式語言內建型別有位元上限，面試或競賽題常要求你在不使用內建大數的情況下處理超大整數。
最基本的做法就是使用直式乘法搬到字串或陣列上來做：用低位對低位、進位處理，最後組合結果。

> 對於大數乘法有更多的演算法（Karatsuba, Toom-Cook, FFT-based），但這些通常超出面試範圍，且實作複雜。
{: .block-warning }

> [【算法】大数乘法问题及其高效算法](https://blog.csdn.net/u010983881/article/details/77503519)

#### Problem Statement

輸入兩個非負整數的字串 num1 和 num2，回傳它們相乘的結果字串。
不允許使用直接把字串轉成大數、或使用語言提供的大數類別。

限制要點：
- 輸入大小可能超過原生整數範圍
- 要處理零與前導零情況（"0" × 任意 = "0"）

#### Basic Idea

- 把每個字元轉成整數，從低位（字串尾）開始模擬逐位相乘。
- 兩位數相乘的結果加到對應的結果陣列位置，再處理進位。
- 最後把結果陣列轉回字串並去除前導零。

時間複雜度：O(m * n)，m 和 n 分別為兩個輸入字串長度。  
空間複雜度：O(m + n)（用來存放結果的陣列）。

#### Algorithm Steps

```
        23958233
  ×         5830
  ———————————————
        00000000 ( =      23,958,233 × 0) # 1. Multiplying by 0
       71874699  ( =      23,958,233 × 3) # 2. Multiplying by 3
     191665864   ( =      23,958,233 × 8) # 3. Multiplying by 8
  + 119791165    ( =      23,958,233 × 5) # 4. Multiplying by 5
  ———————————————
    139676498390 ( = 139,676,498,390        ) # Final result maximum M + N digits
```

我們以直立式乘法為例，可以看到被拆成以下階段：

1. 準備乘數與被乘數
2. 逐次乘以被乘數的每一位，並將結果依位數對齊
    -   被乘數有 N 位數，就會產生 N 次計算
3. 將所有部分和相加得到最終結果
    -   最後的值會有最多 M + N 位數（需要使用另一個陣列來存放）

**Algorithm:**

1. 若其中一個字串為 "0"，直接回傳 "0"。
2. 建立長度為 m + n 的整數陣列 result，初始化為 0。
3. 反向遍歷 num1，對每個位 i：
   - 反向遍歷 num2，對每個位 j：
     - product = (num1[i] - '0') * (num2[j] - '0')
     - sum = product + result[i + j + 1]（+ 可能的進位）
     - result[i + j + 1] = sum % 10
     - result[i + j] += sum / 10
4. 把 result 陣列轉成字串，跳過開頭的零，並回傳。

這裡 i + j + 1 與 i + j 的索引對應到「從高位到低位」排列的陣列格局。

#### Pitfalls and Tips

- 索引錯誤（i + j、i + j + 1）是常見 bug 根源。
- 千萬不要把字元直接當數字相加（記得減 '0'）。
- 處理前導零：例如 "000123" × "045" 的結果需正確處理。
- 大量的字串拼接會影響效能，使用陣列或 StringBuilder（Java）更好。

#### Implementation in Python

````python
def multiply(num1: str, num2: str) -> str:
    if num1 == "0" or num2 == "0":
        return "0"
    m, n = len(num1), len(num2)
    res = [0] * (m + n)
    for i in range(m - 1, -1, -1):
        a = ord(num1[i]) - ord('0')
        for j in range(n - 1, -1, -1):
            b = ord(num2[j]) - ord('0')
            prod = a * b
            sum_ = prod + res[i + j + 1]
            res[i + j + 1] = sum_ % 10
            res[i + j] += sum_ // 10
    # skip leading zeros
    idx = 0
    while idx < len(res) and res[idx] == 0:
        idx += 1
    return ''.join(str(d) for d in res[idx:]) if idx < len(res) else "0"
````

> ##### Last Edit
> 09-14-2025 01:50
{: .block-warning }