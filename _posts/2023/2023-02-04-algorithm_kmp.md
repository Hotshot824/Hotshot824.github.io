---
title: "Leetcode | Algorithm - KMP"
author: Benson Hsu
date: 2023-02-04
category: Jekyll
layout: post
tags: [algorithm, string]
---

> Notes:
> KMP (Knuth Morris Pratt). [reference] here.
{: .block-tip }

### Introduction

字串尋找演算法 (KMP), 可在一個字串中尋找另一個字串的出現位子, 使用這個算法的平均時間複雜度是 O(n+m),
其中 n 為字串的長度, m 為模式串的長度.

#### Brute Force

我們先看看暴力解如何去解，假設有兩個字串:
1. text: "aabaabaaf"
2. pattern: "aabaaf"

最值觀的寫法就是從 text 開始做 for loop, 接下來逐字匹配 text, 如果 pattern 找到匹配失敗的 text 才往前移動 1 直到能將 pattern 匹配完或者 traverse text 結束.
在這種寫法下時間複雜度為 O(m*n), 因為至少每個 text 的 element 都要經過一次 pattern 的匹配過程. 也可以想像成一個滑動的窗口, 窗口的大小為 pattern size.

[28. Find the Index of the First Occurrence in a String] 中的暴力解法.
```go
func strStr(haystack string, needle string) int {
	var result int = -1
	if len(haystack) < len(needle) {
		return result
	}
	for i := 0; i < len(haystack); i++ {
		if checkStr(haystack, needle, i) {
			result = i
			return result
		}
	}
	return result
}

func checkStr(haystack, needle string, index int) bool {
	for i := 0; i <= len(needle); i++ {
		if i == len(needle) {
			return true
		}
		if index >= len(haystack) {
			return false
		}
		if haystack[index] == needle[i] {
			index++
		} else {
			return false
		}
	}
	return false
}
```

### KMP Algorithm

[Diagram reference]

因此我們可以將暴力解用圖解來展開：  
![](https://writings.sh/assets/images/posts/algorithm-string-searching-kmp/naive-expanded.png){:height="60%" width="60%"} 

那我們就能想像如何減少不必要的搜尋, 首先如下兩張圖: 
如果右移後的 overlap 都無法比對, 下次比對時我們都可以先跳過這些 overlap.  

![](https://writings.sh/assets/images/posts/algorithm-string-searching-kmp/explan-kmp-01.png){:height="60%" width="60%"}

但是看下面這個例子, 這次比對到的目標中含有符合的子串. 因此我們就有必要進一步的比對,  

![](https://writings.sh/assets/images/posts/algorithm-string-searching-kmp/explan-kmp-03.png){:height="60%" width="60%"}
![](https://writings.sh/assets/images/posts/algorithm-string-searching-kmp/explan-kmp-05.png){:height="60%" width="60%"}

那這段 overlap 要如何找出來? 假設已經比對成功的部分是 p', 他是 p 的一個子串, 
那重疊部分就是 p' tail 和右移 p' 的head. 因此我們可以說


![](https://writings.sh/assets/images/posts/algorithm-string-searching-kmp/explan-kmp-06.png){:height="60%" width="60%"}

結合以上的兩種方式, 我們可以看到這個算法最終的樣子: 

![](https://writings.sh/assets/images/posts/algorithm-string-searching-kmp/explan-kmp-09.png){:height="60%" width="60%"}

> ##### Last Edit
> 04-02-2023 19:28
{: .block-warning }

[reference]: https://www.bilibili.com/video/BV1PD4y1o7nd/?vd_source=534430193309f41034d31f469a3f029f
[28. Find the Index of the First Occurrence in a String]: https://github.com/Hotshot824/Leetcode/blob/main/Medium/28.Find_Index_of_First_Occurrence_String.md
[diagram reference]: https://writings.sh/post/algorithm-string-searching-kmp
[diagram 1]: https://writings.sh/assets/images/posts/algorithm-string-searching-kmp/naive-expanded.png