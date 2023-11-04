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

以下是本章的主要內容

-   Combinational logic
    -   Decision tables
    -   Constraint logic programming
-   UML/OCL
    -   Constraint logic graphs
    -   Constraint logic programming

### 4.1 Combinational Models

Combinational logic 是一種有效組合各種不同輸入條件的方法，並使不同輸入條件的組合來選擇輸出動作變的可能

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
假如有一個 Triangle Java class 如下，Triangle constructor 只要滿足 **{sa + sb > sc, sa + sc > sb, sb + sc > sa}** 就視為合法的 Tringle，否則拋出 Exception。
```java
classTriangle
{
    inta;// lengths of sides
    intb;
    intc;
    public Triangle(intsa, intsb, intsc);
    public String category( );
};
```
以這三個條件我們能獲得以下的 Decision table，在去除不可能發生的條件後，得到最後可能產生的 Input data。

<div style="display: flex; flex-direction: row; align-items: center;">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-28-method_level_function_unit_testing/1.png?raw=true" 
    width="50%" height="50%">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-28-method_level_function_unit_testing/2.png?raw=true" 
    width="50%" height="50%">
</div>

這樣我們就能得到足夠測試 **{sa + sb > sc, sa + sc > sb, sb + sc > sa}** 三個 Boundaries 的測試資料，並測試 Tringle constructor 是否能正確的拋出 Exception。

**Constraint Logic Graph**

可以透過 Constraint logic programming 來產生測資，以下是 Triangle constructor 的 Invalid Constraint logic graph，
會產生三個 Invalid equivalence classes，加上 Valid equivalence classes 就能得到跟上面 Decision table 一樣的測試資料。

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-28-method_level_function_unit_testing/3.png?raw=true){:height="50%" width="50%"}


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

因為在 Triangle constructor 的測試中已經測試過 Valid equivalence classes，所以這裡只要使用 {a = b, a = c, b = c} 這三個條件約束就可以，
並且也可以透過 CLP 來產生測試資料，這樣我們就能測試完所有 category 有可能的路徑。

```java
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

拿上面的程式碼來做比對，實際上這個 Decision table 就是去走過所有在程式中可能發生的路徑。

> 因為篇幅的關係這裡不會介紹 CLP 如何撰寫，考慮在之後另外寫一篇文章說明 CLP 如何使用

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

### 4.3 Object Constraint Language

-   通常只使用 UML 是不足以完全規範一個軟體系統
-   所以還需要 Constraint 來完全規範一個軟體系統
-   Constraint 是對軟體系統的一個或多個值的限制
-   Object Constraint Language(OCL) 是一種基於 Text 的語言，用於描述這些 Constraints

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-28-method_level_function_unit_testing/8.png?raw=true){:height="75%" width="75%"}

上圖展示了一個 Flight 的 Class invariant，如果 type == passenger，那麼 airplane.type 也必須為 passenger，同樣的 cargo 也只能對應 cargo
這意思就如果是客運航班就要對應客機，貨運航班就要對應貨機。

##### 4.3.1 Kinds of Constraints

-   Class invariant(不變式): a constraint that must alwaysbe met by all instances of the class.
-   Precondition of an operation(操作前提): a constraint that must always be true beforethe execution of the operation.
-   Postcondition of an operation(操作後置): a constraint that must always be true afterthe execution of the operation.

例如: 一個校園借書系統，那麼 Class invariant 必須為 Student，因為校外人士不能借閱，
而還書時 Precondition 必須為至少要有那本要還的書，Postcondition 則必須沒有已經還回去的書。

##### 4.3.2 Constraint Context and Self
-   Every OCL expression is bound to a specific context.
    -   The context is often the element (classor method) that the constraint is attached to.
-   The context may be denoted within the expression using the keyword ‘self’.
    -   'self' is implicit in all OCL expressions.
    -   Similar to 'this' in Java.

例如: 以下的 OCL，context Person 宣告了這個 Constraint 是屬於 Person 這個 Class，而 self.age >= 0 則專指這個 Person attribute age >= 0

```
context Person
inv: self.age >= 0
```

##### 4.3.3 Notation

OCL 可以單獨寫在一個文件中，也可以寫在 UML 的 Class diagram 裡面，這些表示方法都是相同的

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-28-method_level_function_unit_testing/8.png?raw=true){:height="75%" width="75%"}

##### 4.3.4 Elements of an OCL Expression

-   In an OCL expression these elements may be used:
    -   basic types: String, Boolean, Integer, Real.
-   classifiers from the UML model and their features
    -   attributes, and class attributes
    -   query operations, and class query operations (i.e., those operations that do not have side effects)
-   associations from the UML model
    -   Including Rolenames at either end of an association

**Basic types**

以下表示了 OCL 的基本型別，可以使用在 OCL 的表達式

```ocl
context Airline
    inv: name.toLower = 'klm'
context Passenger
    inv: age >= ((9.6 -3.5)* 3.1).floor implies mature = true
```

**Attributes**

OCL 中有專指 Object 實例的 Attribute，也有專指 Class 的 Attribute
-   Class attribute 會在所有 Object 實例中共享
-   Object attribute 則是每個 Object 實例都有自己的 Attribute

以下是一個例子:

```ocl
-- Object attribute
context Flight
    inv: self.maxNrPassengers<= 1000
-- Class attribute
context Passenger
    inv: age >= Passenger.minAge
```

**The @Pre Keyword**

-   The @pre keyword indicates the value of an attribute at the start of the execution of the operation
-   The keyword must be postfixed to the name of the item concernedsize = size@pre + 1

例如 size = size@pre + 1: 
    -   size@pre 表示在執行這個 Operation 前的 size
    -   size 表示在執行這個 Operation 後的 size

##### 4.3.5 OCL Examples with CLG

假如我們有以下 Java class Triangle，我們分別針對他的 Constructor 和 Method category 以及 Class invariant(Triangle Objects) 來撰寫 OCL

```java
class Triangle
{
    int a; // lengths of sides
    int b;
    int c;
    public Triangle(int sa, int sb, int sc);
    public String category( );
};
```

**Example: Triangle Objects**

一個 Triangle 應該永遠滿足三邊長的條件，所以使用 **Class invariant** 來限制所有 Triangle 的三邊長

```ocl
context Triangle
inv:
    a + b > c and a + c > b and b + c > a
```

**Example: Constructor Triangle**

```ocl
context Triangle::Triangle(intsa, intsb, intsc)
pre IllegealArgException:
    sa + sb > sc and sa + sc > sb and sb + sc > sa
post:
    a = sa and b = sb and c = sc
```

以上的 OCL 表示 Triangle 這個 Constructor Triangle 的 Precondition 和 Postcondition
-   Precondition: 一個 Triangle constructor 的輸入必須滿足 **sa + sb > sc and sa + sc > sb and sb + sc > sa**
-   Postcondition: Triangle constructor 執行後應該滿足 **a = sa and b = sb and c = sc**

**Example: Method category**

以下是一個 Method category 的 OCL，這個 OCL 會檢查 Triangle 的三邊長，並且回傳 Triangle 的類型

```ocl
contextTriangle::category(): String
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

我們依照上面的 Constructor Triangle 和 Method category 來建立 CLG，得到以下兩張圖，就可以以此來生成測試資料

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

依照這個 Table 這樣就能夠產生五條全部路徑的測試案例

> ##### Last Edit
> 10-29-2023 15:56 
{: .block-warning }

[Unified Modeling Language Concepts]: ./2023-07-26-unified_modeling_language.html
[UML Structure Diagrams Introduction 1.1 Class diagram]: ./2023-07-28-UML_structure_diagrams.html#11-class-diagram