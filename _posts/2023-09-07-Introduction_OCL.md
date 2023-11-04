---
title: "Note | Object Constraint Language Concepts (Unfinished)"
author: Benson Hsu
date: 2023-09-07
category: Jekyll
layout: post
tags: [software, tool]
---

> Object Constraint Language(OCL) 物件限制語言。
{: .block-tip }

### 1. Introduction

因 UML 類別圖中無法包含一些細節資訊，若以自然語言描述，常造成開發者與使用者間認知差異，所以使用物件限制語言嚴謹的描述 UML 類別圖中有關系統規格的所有資訊，為 UML 標準的擴充機制。
物件限制語言使用三種限制式(constraint)來描述類別的行為:

1.  類別恆定條件(Class invariant)
    針對一個類別而言，此類別的任何物件在整個生命週期皆須滿足自身定義的恆定條件。
2.  函式前置條件(Method pre-condition)
    針對一個函式而言，在此函式被呼叫之前須滿足前置條件，才能確保動作正確。
3.  函式後置條件(Method post-condition)
    針對一個函式而言，若在此函式被呼叫之前滿足前置條件，則此函式在被呼叫後，一定滿足後置條件。

### 2. Characteristic

物件限制語言由 IBM 於 1997 年開發，他扮演以下角色:

> ##### NOTE
> Last edit 09-07-2023 09:25  
{: .block-warning }