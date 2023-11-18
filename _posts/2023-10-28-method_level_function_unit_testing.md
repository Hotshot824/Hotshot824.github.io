---
title: "Testing | Method-Level Functional Unit Testing (Unfinished)"
author: Benson Hsu
date: 2023-10-28
category: Jekyll
layout: post
tags: [software, software_qualitiy]
---


> Software testing course notes from CCU, lecturer Nai-Wei Lin.  
> 這章節主要開始介紹從 Method 為單位的 Specification，來對每個 Method 進行獨立的 Unit testing
{: .block-tip }

本章先介紹如何使用組合邏輯來尋找限制式的組合，並使用 Constraint Logic Programming 來產生測試資料，
接著介紹 UML/OCL 系統，使用 OCL 來描述一個 Class/Methods 的限制式，並且透過 Constraint Logic Graph 與 Constraint Logic Programming 來產生測試資料。

-   **Combinational logic**
    -   Decision tables
    -   Constraint logic programming
-   **UML/OCL**
    -   Constraint logic graphs
    -   Constraint logic programming

### 4.1 Combinational Models

-   Many applications must select output actions by evaluating combinationsof input conditions (constraints on input variables).
-   Input variables can also be either parametersof the method, static variables of the class, or instance variables of the object.
-   Combinational logic provides an effective language for these kinds of condition-action relationships.

> 例如一個 Method 有多個參數，而這些參數可能會有不同的組合，這些組合可能會對應到不同的輸出，這時候我們可以使用 Combinational logic 來描述這些組合，並且對應到不同的輸出

##### 4.1.1 Equivalence Class Partitioning Decision Tables

-   A combinational model uses a decision tableto represent the condition-action relationships and partition equivalence classes.
-   A decision table has a condition sectionand an action section.
-   The condition section lists constraints on inputvariables.
-   The action section lists outputto be produced when corresponding constraints are true.

> 以 Decision table 來決定條件的組合，並且對應到輸出

**Example: Class Triangle**
假如有一個 Triangle Java class 如下，Constructor 只要滿足 **{sa + sb > sc, sa + sc > sb, sb + sc > sa}** 就視為合法的 Tringle，否則拋出 Exception。

```java
// Java class Triangle :: Constructor
classTriangle
{
    inta;
    intb;
    intc;
    public Triangle(intsa, intsb, intsc);
};
```

以這三個條件進行 Combianational 能獲得以下的 Decision table，將這些限制式透過 CLP 求解就能得到右圖的測試資料:

<div style="display: flex; flex-direction: row; align-items: center;">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-28-method_level_function_unit_testing/1.png?raw=true" 
    width="50%" height="50%">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-28-method_level_function_unit_testing/2.png?raw=true" 
    width="50%" height="50%">
</div>

**Example: Method category**

-   The method category() returns the category of a Triangle object based on the lengths of its three sides: "Equilateral", "Isosceles", or "Scalene".
-   A Triangle object is an "Equilateral" triangle if it satisfies the following threeconstraints: {a = b, a = c, b = c}.
-   A Triangle object is an "Isosceles" triangle if it satisfies one and only one of the following three constraints: {a = b, a = c, b = c}.
-   Otherwise, It is a "Scalene" triangle.

關於 category 我們也可以透過 Decision table 來產生測試資料，以下是 category 的 Decision table

<div style="display: flex; flex-direction: row; align-items: center;">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-28-method_level_function_unit_testing/4.png?raw=true" 
    width="50%" height="50%">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-28-method_level_function_unit_testing/5.png?raw=true" 
    width="50%" height="50%">
</div>

```java
// Java class Triangle :: category()
public String category( )
{
    if (a == b && b == c)
        return "Equilateral";
    else if (a == b || a == c || b == c)
        return "Isosceles";
    else
        return "Scalene";
}
```

拿上面的程式碼來做比對，實際上這個 Decision table 就是去走過所有在 `Category` 中可能發生的路徑。

---

### 4.2 Unified Modeling Language

-   Unified Modeling Language(UML) 是一種用於可視化、規範、建構和文件化軟體系統工程的圖形化語言
-   UML 提供一種標準化的方式來編寫系統的藍圖，包括概念性的事務，如業務流程和系統功能，以及具體的事務，如程式描述、Database 架構和可重用的軟體元件

##### 4.2.1 UML Diagrams

在 Software testing 這門課中主要會用到的是 Class diagram、Sequence diagram、State machine diagram

-   UML 2 defines thirteenbasic diagram types, divided into two general sets:
-   Structural Modeling Diagrams: Structure diagrams define the staticarchitecture of a model. They are used to model the 'things' that make up a model.
-   Behavioral Modeling Diagrams: Behavior diagrams capture the varieties of dynamicinteraction and instantaneous state within a model as it executes over time.

> 在之前我有更詳細的關於 UML 的介紹，詳細可見 [Unified Modeling Language Concepts]

##### 4.2.2 Class Diagrams

-   Class Diagram 描述了一個 Class 有哪些 Attributes 和 Methods，而不是詳細的實作細節
-   Class Diagram 在說明 Class 或 Interface 之間的關係時最為有用
-   Association(關聯)和 Generalization(泛化)分別表示連接和繼承

> 關於類圖可以看之前的筆記，有更詳細的描述 [UML Structure Diagrams Introduction 1.1 Class diagram]

<div style="display: flex; flex-direction: row; align-items: center;">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-28-method_level_function_unit_testing/6.png?raw=true" 
    width="50%" height="50%">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-28-method_level_function_unit_testing/7.png?raw=true" 
    width="50%" height="50%">
</div>

> Association 表示兩個 Class 之間有所關聯，例如: Course 和 Student 之間有一個關聯，關聯可以是多對多的關係  
> Generalization 表示的是兩個 Class 之間有繼承關係，例如: Animal 和 Dog 之間有一個繼承關係

---

### 4.3 Basic Object Constraint Language

關於 OCL 的基礎語法可以參考之前的筆記 [Object Constraint Language Concepts]，這裡就不再贅述。

---

##### 4.3.5 OCL to CLG Example

這裡介紹如何將 OCL 抽象化成 CLG，之後就能透過 CLG 的路徑來產生測試資料

**Constructor**

-   Valid:
    -   Class invariant before invocation
    -   Pre-Conditions
    -   Post-Conditions
    -   Default Post-Conditions
-   Invalid:
    -   Class invariant before invocation
    -   Negation of Pre-Conditions

因此一個 Function 的 Valid 輸入將會是符合 Pre/Post-Conditions 的 CLG 路徑，經由 CLP 產生的測試資料，
反過來說當一個 Function 的 Pre-Conditions 不合法時將會產生 Invalid 的測試資料。

<div style="display: flex; flex-direction: row; align-items: center;">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-28-method_level_function_unit_testing/10.png?raw=true" 
    width="50%" height="50%">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-28-method_level_function_unit_testing/3.png?raw=true" 
    width="50%" height="50%">
</div>

Negation 使用 De Morgan's law 來轉換規則後得到 Pre-Conditions 的 Negation，這樣就有四條不同的路徑與下表相同:

| Varients | sa+sb>sc | sa+sc>sb | sb+sc>sa | (sa, sb, sc) |
| -------- | -------- | -------- | -------- | ----------- |
| 1 | T | T | T | (1, 1, 1) |
| 2 | T | T | F | (2, 1, 1) |
| 3 | T | F | T | (1, 2, 1) |
| 4 | F | T | T | (1, 1, 2) |

> 這裡去除了 Can't Happen 的條件，在這個例子中 Desicion table 應該會有 2<sup>3</sup> 種可能

##### 4.3.5 OCL Examples with CLG

以之前的 Triangle 為例來撰寫 OCL 將會有: 
-   Class invariant(Triangle Objects): 一個 Triangle 應該永遠滿足三邊長的條件，所以使用 **Class invariant** 來限制所有 Triangle 的三邊長
-   Constructor: OCL 表示 Triangle 這個 Constructor 的 Precondition 和 Postcondition
    -   **Pre**: 一個 Triangle constructor 的輸入必須滿足 **sa + sb > sc and sa + sc > sb and sb + sc > sa**
    -   **Post**: Triangle constructor 執行後應該滿足 **a = sa and b = sb and c = sc**
-   Method category: 
    -   **Post**: 檢查 Triangle 的三邊長，並且回傳 Triangle 的類型

```ocl
context Triangle
inv:
    a + b > c and a + c > b and b + c > a

context Triangle::Triangle(intsa, intsb, intsc)
pre IllegealArgException:
    sa + sb > sc and sa + sc > sb and sb + sc > sa
post:
    a = sa and b = sb and c = sc
    
context Triangle::category(): String
post: result=
if a@pre = b@pre then
    ifa@pre = c@pre then 'Equilateral'
    else 'Isosceles' 
    endif
else
    if a@pre = c@pre then 'Isosceles'
    else
        if b@pre = c@pre then'Isosceles'
        else 'Scalene' 
        endif
    endif
endif
```

**Constraint Logic Graph**

我們依照上面的 Constructor 和 Category 來建立 CLG，得到以下兩張圖，就可以以此來生成測試資料

<div style="display: flex; flex-direction: row; align-items: center;">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-28-method_level_function_unit_testing/10.png?raw=true" 
    width="50%" height="50%">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-28-method_level_function_unit_testing/11.png?raw=true" 
    width="50%" height="50%">
</div>

例如我們想測試 category，能發現在 CLG 上一共有 5 條不同的路徑，我們把第一條路徑的條件放入 CLP 中求解，就能得到測試第一條路徑的測試資料。

<div style="display: flex; flex-direction: row; align-items: center;">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-28-method_level_function_unit_testing/12.png?raw=true" 
    width="50%" height="50%">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-28-method_level_function_unit_testing/13.png?raw=true" 
    width="50%" height="50%">
</div>

| Constraint, Pre a@+b@>c@, a@+c@>b@, b@+c@>a@ | Input | Output |
| ---------- | ----- | ------ |
| a@=b@, a@=c@, result='Equilateral' | 1, 1, 1 | Equilateral |
| a@=b@, a@!=c@, result='Isosceles' | 2, 2, 1 | Isosceles |
| a@!=b@, a@=c@, result='Isosceles' | 2, 1, 2 | Isosceles |
| a@!=b@, a@!=c@, b@=c@, result='Isosceles' | 1, 2, 2 | Isosceles |
| a@!=b@, a@!=c@, b@!=c@, result='Scalene' | 2, 3, 4 | Scalene |
| Post a = a@, b = b@, c = c@ |

依照這個 Table 去跑限制式這樣就能夠產生五條全部路徑的測試案例，例如第一條路徑的 CLP 如下:

> ##### Last Edit
> 10-29-2023 15:56 
{: .block-warning }

[Unified Modeling Language Concepts]: ./2023-07-26-unified_modeling_language.html
[UML Structure Diagrams Introduction 1.1 Class diagram]: ./2023-07-28-UML_structure_diagrams.html#11-class-diagram

[Object Constraint Language Concepts]: ./2023-09-07-Introduction_OCL.html