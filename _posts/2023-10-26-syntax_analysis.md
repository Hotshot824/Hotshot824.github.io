---
title: "Compiler | Syntax Analysis Notes (Unfinished)"
author: Benson Hsu
date: 2023-10-26 
category: Jekylls
layout: post
tags: [Compiler]
---

> Compilers course notes from CCU, lecturer Nai-Wei Lin.
> Syntax Analysis(語法分析) 在這個階段會檢查 Lexical Analysis 返回的 Token 是否符合語法規則，並且建立語法樹
{: .block-tip }

以下是這個章節的主要大綱，Bison 不會在這篇介紹如何使用，主要是介紹 Syntax analysis 的概念

-   Introduction to parsers
-   Context-free grammars
-   Push-down automata
-   Top-down parsing
-   Buttom-up parsing
-   Bison -a parser generator

### 4.1 Introduction to parsers

在編譯器模型中 Systax analysis 從 Lexical analysis 獲取由 Token 所組成的字串，我們期望語法分析器能夠以易於理解的方式回報語法錯誤。
概念上語法分析需要建構一個 Parse tree 傳遞給 Compiler 的其餘部分進行進一步處理，但實際上 Parse tree 並不需要明確的建構，
因為檢查與翻譯可以與 Parsing 交錯完成。

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-26-syntax_analysis/1.png?raw=true){:height="75%" width="75%"}


> ##### Last Edit
> 10-26-2023 17:50
{: .block-warning }