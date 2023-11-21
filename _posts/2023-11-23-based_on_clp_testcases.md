---
title: "Testing | Based on CLP Testcases"
author: Benson Hsu
date: 2023-11-23
category: Jekyll
layout: post
tags: [software, software_qualitiy]
---

> Software testing course notes from CCU, lecturer Nai-Wei Lin.  
> 簡單記錄下 OCL 與 CLP 的對應關係，以及如何使用 CLP 產生測試案例。
{: .block-tip }

### 1. Constraint Logic Programming Specification

**Constraint Logic Programming Predicates**

以下是一個產生測試案例的 CLP Predicate 規範，分別應對 Constructor 與 Method 的測試案例:

-   `testConstructor(ArgPre, Obj, Arg, Exc):-`
    -   ArgPre: the arguments before the constructor call
    -   Obj: the object created after the constructor call
    -   Arg: the arguments after the constructor call
    -   Exc: the exception thrown after the constructor call

-   `testMethod(ObjPre, ArgPre, ObjPost, ArgPost, Ret, Exc):-`
    -   ObjPre: object before invocation
    -   ArgPre: arguments before invocation
    -   ObjPost: object after invocation
    -   ArgPre: arguments after invocation
    -   Ret: value returned after successful invocation
    -   Exc: exception thrown after failed invocation

**Example:**

以下是一個 Triangle Constructor 的 OCL:
```ocl
contextTriangle :: Triangle(int sa, int sb, int sc)
pre IllegealArgException:
    sa + sb > sc and sa + sc > sb and sb + sc > sa
post:
    a = sa and b = sb and c = sc
```

以此建立 OCL 後將會得到以下四條路徑，並收集路徑上的限制式(Constraint)來編寫 CLP:

<div style="display: flex; flex-direction: row; align-items: center;">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-28-method_level_function_unit_testing/10.png?raw=true" 
    width="50%" height="50%">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-28-method_level_function_unit_testing/3.png?raw=true" 
    width="50%" height="50%">
</div>

Valid 的 CLP 將會是以下的形式:
```prolog
% Include constraint solving library
:- lib(ic).
testTriangle1([Sa,Sb,Sc], [A,B,C], [Sa,Sb,Sc], []):-
% Domains of variables
    [Sa, Sb, Sc, A, B, C] :: 1 .. 32767,
% Constraints on variables
    Sa + Sb #> Sc, Sa + Sc #> Sb, Sb + Sc #> Sa,
    A #= Sa, B #= Sb, C #= Sc,
% Solving constraints
    labeling([Sa, Sb, Sc, A, B, C]).
```

Invalid 的 CLP 將會是以下的形式，將 Precondition 的限制式改為不符合的形式:
```prolog
% Include constraint solving library
:- lib(ic).
testTriangle2([Sa,Sb,Sc], [], [Sa,Sb,Sc], [exception]):-
% Domains of variables
    [Sa, Sb, Sc] :: 1 .. 32767,
% Constraints on variables
    Sa + Sb #> Sc, Sa + Sc #> Sb, Sb + Sc #=< Sa,
% Solving constraints
    labeling([Sa, Sb, Sc]).
```

> ##### Last Edit
> 11-23-2023 15:56 
{: .block-warning }