---
title: "Compiler | Intermediate Code Generation (Unfinished)"
author: Benson Hsu
date: 2023-12-16
category: Jekylls
layout: post
tags: [Compiler]
---

> Compilers course notes from CCU, lecturer Nai-Wei Lin.  
> Intermediate Code Generation 這個階段主要是將 Syntax Tree 轉換成 Intermediate Code，這個階段的目的是為了讓後面的 Code Optimization 更容易進行。
{: .block-tip }

-   Intermediate Language
-   Declarations
-   Expressions
-   Statements

### Intermediate Language

中間語言並不一定是某種語言，也可以是一種 IR (Intermediate Representation, 中間表示)，是為了好處理後續的優化或代碼生成而產生的一種語言。

-   Syntax Tree
-   Postfix Notation
    -   a b c - * b c - * + :=
    -   stack machine
-   Three-Address Code
    -   a = b + c

> 這裡會以一種直接把 Asbtact Syntax Tree 轉換成 MIPS(Targer Language) 的方式來做說明，實際上會需要 IR 來先做平台無關的優化，再轉換成 MIPS。

這裡就不介紹 MIPS 相關的語法、特性等等，而是直接以範例來說明後續的轉換過程。

### Declarations

### Expressions

### Statements

> ##### Last Edit
> 因為後續的部分都是以範例來說明，而且在系統上並不是很清楚，所以打算在之後再補上。  
> 1-4-2021 01:26
{: .block-warning }