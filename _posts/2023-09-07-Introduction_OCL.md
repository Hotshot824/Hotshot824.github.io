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

-   通常只使用 UML 是不足以完全規範一個軟體系統
-   所以還需要 Constraint 來完全規範一個軟體系統
-   Constraint 是對軟體系統的一個或多個值的限制
-   Object Constraint Language(OCL) 是一種基於 Text 的語言，用於描述這些 Constraints

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-28-method_level_function_unit_testing/8.png?raw=true){:height="75%" width="75%"}

上圖展示了一個 Flight 的 Class invariant，如果 type == passenger，那麼 airplane.type 也必須為 passenger，同樣的 cargo 也只能對應 cargo
這意思就如果是客運航班就要對應客機，貨運航班就要對應貨機。

### 2. Basic Object Constraint Language

##### 2.2.1 Kinds of Constraints

因 UML 類別圖中無法包含一些細節資訊，若以自然語言描述，常造成開發者與使用者間認知差異，所以使用物件限制語言嚴謹的描述 UML 類別圖中有關系統規格的所有資訊，為 UML 標準的擴充機制。
物件限制語言使用三種限制式(constraint)來描述類別的行為:

1.  Class invariant(類別恆定條件): a constraint that must alwaysbe met by all instances of the class.
    -   針對一個類別而言，此類別的任何物件在整個生命週期皆須滿足自身定義的恆定條件
2.  Method pre-condition(函式前置條件): a constraint that must always be true beforethe execution of the operation.
    -   針對一個函式而言，在此函式被呼叫之前須滿足前置條件，才能確保動作正確
3.  Method post-condition(函式後置條件): a constraint that must always be true afterthe execution of the operation.
    -   針對一個函式而言，若在此函式被呼叫之前滿足前置條件，則此函式在被呼叫後，一定滿足後置條件
4.  Other constraints(其他限制式) 在 OCL2 之後還有其他的限制式加入如:
    -   Derive, Init, Let, Def, Package


> 例如: 一個校園借書系統，那麼 Class invariant 必須為 Student，因為校外人士不能借閱，
> 而還書時 Pre-condition 必須為至少要有那本要還的書，Post-condition 則必須沒有已經還回去的書。
{: .block-tip }

##### 2.2.2 Constraint Context and Self

-   Every OCL expression is bound to a specific context.
    -   The context is often the element (classor method) that the constraint is attached to.
-   The context may be denoted within the expression using the keyword ‘self’.
    -   'self' is implicit in all OCL expressions.
    -   Similar to 'this' in Java.

> 例如: 以下的 OCL，context Person 宣告了這個 Constraint 是屬於 Person 這個 Class，而 self 則專指這個 Person 的 attribute
{: .block-tip }

```
context Person
inv: self.age >= 0
```

##### 2.2.3 Notation

OCL 可以單獨寫在一個文件中，也可以寫在 UML 的 Class diagram 裡面，這些表示方法都是相同的

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-28-method_level_function_unit_testing/9.png?raw=true){:height="75%" width="75%"}

##### 2.2.4 Elements of an OCL Expression

-   In an OCL expression these elements may be used:
    -   basic types: String, Boolean, Integer, Real.
-   classifiers from the UML model and their features
    -   attributes, and class attributes
    -   query operations, and class query operations (i.e., those operations that do not have side effects)
-   associations from the UML model
    -   Including Rolenames at either end of an association

> OCL 同樣有型別的概念，並且可以使用 UML 的 Class diagram 中的 Attribute，Operation，Association 等等

**Basic types**

以下表示了 OCL 的基本型別，可以使用在 OCL 的表達式

```ocl
context Airline
    inv: name.toLower = 'klm'
context Passenger
    inv: age >= ((9.6 -3.5)* 3.1).floor implies mature = true
```

> 這裡表現出了 name.toLower 必須為 String，而 age 則為 float，mature 則為 boolean

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

> 這裡的 maxNrPassengers 為專指 Flight Object 的 Attribute，而 age 則為所有 Passenger Class 的 Attribute

**The @Pre Keyword**

-   The @pre keyword indicates the value of an attribute at the start of the execution of the operation
-   The keyword must be postfixed to the name of the item concernedsize = size@pre + 1

例如 `size = size@pre + 1`: 
-   size@pre 表示在執行這個 Operation 前的 size
-   size 表示在執行這個 Operation 後的 size

Example: 例如一個 Triangle 的完整 OCL 可能會類似以下，其中包含了:
-   **Class invariant**: 三角形的三邊長必須符合三角不等式
-   **Constructor(int sa, int sb, int sc)**: Triangle 的建構式
    -   Pre-condition: 輸入值必須符合三角不等式
    -   Post-condition: 建構後的 a, b, c 應該等於輸入的 sa, sb, sc
-   **Method: category()**: 用來判斷三角形的類型
    -   Post-condition: 回傳值應該為 Equilateral, Isosceles, Scalene

```ocl
context Triangle
inv:
    a + b > c and a + c > b and b + c > a

context Triangle::Triangle(int sa, int sb, int sc)
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

---

### 3. Collection in OCL

OCL 中有已經定義好的關於 Collection 的操作，語法上使用: `collection -> operation` 來表示對 Collection 的操作

##### 3.1 Four Subtypes of Collection

這裡有四種型態的 Collection 可以宣告:
-   **Set**:
    -   arrivingFlights(from the context Airport)
    -   Non ordered, unique elements
-   **OrderedSet**:
    -   passengers(from the context Flight)
    -   Ordered, unique elements
-   **Bag**:
    -   arrivingFlights.duration (from the context Airport)
    -   Non ordered, non unique elements
-   **Sequence**:
    -   passengers.age (from the context Flight)
    -   Ordered, non unique elements

**Basic Collection Operations**

-   **Boolean**
    -   isEmpty(): 如果 Collection 為空則回傳 True
    -   notEmpty(): 如果 Collection 不為空則回傳 True
    -   includes(object): 如果 Collection 中包含 object 則回傳 True
    -   excludes(object): 如果 Collection 中不包含 object 則回傳 True
    -   includesAll(Collection): 如果 Collection 中包含所有 Collection 中的元素則回傳 True
    -   excludesAll(Collection): 如果 Collection 中不包含所有 Collection 中的元素則回傳 True

-   **Integer**
    -   size(): 回傳 Collection 的大小
    -   count(object): 回傳 Collection 中符合條件的元素個數
    -   sum(): 回傳 Collection 中所有元素的總和

-   **Coolection**
    -   including(object): 回傳一個新的 Collection，包含了 object
    -   excluding(object): 回傳一個新的 Collection，移除了 object
    -   union(Collection): 回傳一個新的 Collection，包含了原本的 Collection 和另一個 Collection
    -   intersection(Collection): 回傳一個新的 Collection，包含了原本的 Collection 和另一個 Collection 的交集
    -   -(Collection): 回傳一個新的 Collection，從一個 Collection 中移除另一個 Collection 的元素
    -   symmetricDifference(Collection): 回傳一個新的 Collection，包含了原本的 Collection 和另一個 Collection 的差集

-   **Operations for Ordered Collection**
    -   first(): 回傳第一個元素
    -   last(): 回傳最後一個元素
    -   at(index): 回傳 index 的元素
    -   indexOf(object): 回傳 object 在 Collection 中的 index
    -   insertAt(index, object): 將 object 插入到 index 的位置
    -   append(object): 將 object 插入到最後一個位置
    -   prepend(object): 將 object 插入到第一個位置
    -   subSequence(lower, upper): 返回一個包含從較低 index 到較高 index 的元素的新 Sequence
    -   subOrderedSet(lower, upper): 返回一個包含從較低 index 到較高 index 的元素的新 OrderedSet

**Loop Collection Operations**


> ##### NOTE
> Last edit 11-20-2023 00:11  
{: .block-warning }