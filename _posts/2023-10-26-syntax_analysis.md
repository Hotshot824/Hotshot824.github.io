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

本章會先介紹 Parser 在 Compiler 中的作用，然後介紹 Context free grammar。

##### 4.1.1 The Role of the Parser

在編譯器模型中 Systax analysis 從 Lexical analysis 獲取由 Token 所組成的字串，概念上語法分析需要建構一個 Parse tree 傳遞給 Compiler 的其餘部分進行進一步處理，
但實際上不一定要真的用一個 Data structure 來建構 Parse tree，而是在 Parsing 的過程中進行 Semantic analysis，並將資訊傳遞給 Compiler 的其餘部分。

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-26-syntax_analysis/1.png?raw=true){:height="75%" width="75%"}

> 不真正建構一個 Parse tree 通常是為了節省記憶體，但缺點就是他使 Debug 變得困難，因為無法查看 Parse tree

### 4.2 Context-free grammars

Context-free grammars 可以系統的描述程式語言構造，例如使用 stmt 描述 statements，expr 描述 expressions，那麼:

-   production: `stmt -> if (expr) stmt else stmt`

我們就能透過其他 production 來描述 stmt, expr 會是什麼，還可以是什麼?

##### 4.2.1 The Formal Definition of a Context-free Grammar

-   A set of terminals: basic symbols from which sentences are formed
    -   例如: `if`, `else`, `(`, `)`, `id`
-   A set of nonterminals: syntactic categories denoting sets of sentences
    -   任何非 terminal 都可以是一個 nonterminal，例如: `stmt`, `expr`
-   A set of productions: rules specifying how the terminals and nonterminals can be combined to form sentences
    -   例如: `stmt -> if (expr) stmt else stmt`
-   The start symbol: a distinguished nonterminal denoting the language
    -   通常是最上層的 Production

**Example:**
-   Terminals: `id` `+` `-` `*` `/` `(` `)`
-   Nonterminals: `expr` `op`
-   Productions:  

```
expr -> expr op expr  
expr -> '(' expr ')'  
expr -> '-' expr  
expr -> id  
op -> '+' | '-' | '*' | '/'  
The start symbol: expr  
```

##### 4.2.2 Notation Conventions

通常為了避免陳述 `these are the terminals, these are thenonterminals` 會使用一些約定來規範符號:

-   Terminals:
    -   小寫字母，例如: `a` `b` `c`
    -   運算符號，標點符號，例如: `+` `-` `,` `(` `)`
    -   數字，例如: `0` `1` `2`
    -   粗體字符串，例如: **if** **else** **then**
    -   小寫希臘字母，例如: α β γ
-   Non-Terminals:
    -   大寫字母，例如: `A` `B` `C`
        -   在討論構造時，例如 expression、terms、factors，使用: `E` `T` `F`
    -   通常使用 S 來表示 Start symbol
    -   斜體字符串，例如: *expr* *stmt*
-   具有相同標題的 Production 可以使用 `|` 來分隔，例如: `A -> a`、`A -> b`、`A -> c` 可以寫成 `A -> a | b | c`
-   除非特殊說明，第一個 Production 會是 Start symbol

##### 4.2.3 Parse Trees and Derivations

-   推導(derivation) 步驟是將一個 Production 的替換過程寫出，例如 E => - E
-   一系列的推導步驟可以將 E => -E => -(E) => -(id)
-   如果使用 =><sup>*</sup> 表示在零步或多步中推導，=><sup>+</sup> 表示在一步或多步中推導
    -   例如上面的步驟可以簡化為 E =><sup>*</sup> -(id)

**Context free grammar**

-   Context free grammar(CFG) 定義的語言 L(G)，是由 CFG G 所定義的語言
-   一個 Terminal 字串 ω 在 L(G) 中，並且當 S =><sup>+</sup> ω，那我們稱 ω 是 G 的一個句子(sentence)
-   如果 S =><sup>*</sup> α，而 α 可以包含 Non-terminal，那麼 α 是 G 的一個句型(sentence form)
-   如果 L(G1) = L(G2)，那麼 G1 和 G2 是等價的(equivalent)

**Left & Right-most Derivations**

每個 Derivation step 都需要兩個步驟:
-   選擇替換哪個 Terminal
-   替換後選擇一個以此 Terninal 作為開頭的 Production

這樣就可以有 Left & Right 兩種推導方式:
1.  Left-most derivation: 每次都選擇最左邊的 Terminal 來替換
    -   例如 `E` =><sub>lm</sub> `-E` =><sub>lm</sub> `-(E)` =><sub>lm</sub> `-(E+E)` =><sub>lm</sub> `-(id+E)` =><sub>lm</sub> `-(id+id)`
2.  Right-most derivation: 每次都選擇最右邊的 Terminal 來替換
    -   例如 `E` =><sub>rm</sub> `-E` =><sub>rm</sub> `-(E)` =><sub>lm</sub> `-(E+E)` =><sub>lm</sub> `-(E+id)` =><sub>lm</sub> `-(id+id)`

**Exercise 4.2.1:**
-   Consider the following grammar:  
S -> SS+ | SS* | a  
and the string aa+a*

(a), Giver a leftmost derivation for the string.  
(b), Giver a rightmost derivation for the string.  
```
(a) S =>lm SS* => SS+S* => aS+S* => aa+S* => aa+a*
(b) S =>rm SS* => Sa* => SS+a* => Sa+a* => aa+a*
``` 

##### 4.2.4 Parse Trees and Derivations

-   Parse Tree 是推導的圖形表示，顯示了從 Start symbol 到衍生 Sentence 的過程，這種方式過濾了選擇 Terminal 進行重寫的順序
-   因此不管是 Left/Right-most 都應該推導出相同的 Parse tree

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-26-syntax_analysis/2.png?raw=true){:height="75%" width="75%"}

##### 4.2.5 Ambiguous Grammar

如果一個 Grammar 可以對同一個 Sentence 產生不同的 Parse tree 那就是 Ambiguous

<div style="display: flex; flex-direction: row; align-items: center;">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-26-syntax_analysis/3.png?raw=true" 
    width="50%" height="50%">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-26-syntax_analysis/4.png?raw=true" 
    width="50%" height="50%">
</div>

**Resolving Ambiguity**

大部分的 Syntax analysis 都希望 Grammar 不是 Ambiguous，可以透過以下來消除

-   Use **disambiguiting rules** to throw away undesirable parse trees
-   Rewrite grammarsby incorporating disambiguiting rules into grammars

**Example**
-   The dangling-else grammar

```
stmt -> if expr then stmt
    | if expr then stmt else stmt
    | other
```

如果用以上的 Grammar 來分析:  
-   if E<sub>1</sub> then if E<sub>2</sub> then S<sub>1</sub> else S<sub>2</sub>

我們無法確定 else 是對應哪個 then，因此會產生兩個 Parse tree

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-26-syntax_analysis/5.png?raw=true){:height="75%" width="75%"}

這樣就產生了兩個 Parse tree，因為在語法規則中沒有說明清楚 else 要對應哪個 if，所以可以透過以下方式來消除

Disambiguiting rules:
-   Rule: match each else with the closest previous unmatched then
-   Remove undesired state transitions in the pushdown automaton

```
stmt -> m_stmt | unm_stmt
m_stmt -> if expr then m_stmt else m_stmt
    | other
unm_stmt -> if expr then stmt | if expr then m_stmt else unm_stmt
```

透過這種方式，我們強制一個 then 和 else 之間只能是一個 m_stmt，這樣就可以消除 Ambiguous

### 4.3 Writing a Grammar

##### 4.3.1 Lexical Versus Syntactic Analysis

-   由 RE 描述的每種語言也可以由 CFG 描述，例如 `(a|b)*abb` 也可以用 CFG 來描述:

```
A0 -> aA0 | bA0 | aA1
A1 -> bA2
A2 -> bA3
A3 -> ε
```
-   那為什麼不在 Lexical analysis 使用 CFG?
    -   首先 Lexical analysis 不需要與 CFG 一樣強大的表示法
    -   RE 比 CFG 更簡潔更容易理解
    -   RE 建構的 Lexical analysis 比 CFG 建構的 Lexical analysis 更有效率
    -   這樣提供了將前端模塊化為兩個易於管理的部分的方法

**Nonregular Constructs**
-   REs can denote only a fixed number of repetitions or an unspecified number of repetitions of onegiven construct: an, a*
-   A nonregular construct:
    -   L = {a<sup>n</sup>b<sup>n</sup>\| n ≥ 0}
    -   這個語言包含相同數量的 a 和 b，RE 沒辦法描述固定數量的 a 和 b

**Non-Context-Free Constructs**
-   CFGs can denote only a fixed number of repetitions or an unspecified number of repetitions of oneor twogiven constructs
-   Some non-context-free constructs:
    -   L1 = {wcw \| w is in (a\|b)*}
    -   L2 = {a<sup>n</sup>b<sup>m</sup>c<sup>n</sup>d<sup>m</sup> \| n ≥ 1 and m ≥ 1}
    -   L3 = {a<sup>n</sup>b<sup>n</sup>c<sup>n</sup> \| n ≥ 0}

CFG 只能處理一個重複的結構，這也涉及到 CFG 的 Automata，但是可以描述以下語言:

-   L1 = {<sup>n</sup>c<sup>n</sup> \| n ≥ 0}
-   L2 = {a<sup>n</sup>b<sup>m</sup>c<sup>m</sup>d<sup>n</sup> \| n ≥ 0, m ≥ 0}

### 4.4 Top-down Parsing

> 這裡不會詳細介紹 Top-down Parsing，因為 Top-down 要處理的問題比較多
{: .block-warning }

-   Top-down Parsing 是從上層的 Root 開始，使用 Leftmost derivation 建構一顆到 Leaf 的 Parse tree

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-26-syntax_analysis/10.png?raw=true){:height="75%" width="75%"}

**Predictive Parsing**

-   A top-down parsing without backtracking
    –   there is only one alternative production to choose at each derivation step

```
stmt -> if expr then stmt else stmt
    |  while expr do stmt
    |  begin stmt_list end
```

##### 4.4.2 FIRST and FOLLOW Sets

**First set**

-   The first setof a string α is the set of terminals that begin the strings derived from α. If α =>* ε, then ε is also in the first set of ε.

-   如果 X 是一個 Terminal，那麼 FIRST(X) = {X}
-   如果 X 是一個 Nonterminal，並且存在 X -> ε，那麼 FIRST(X) = {ε}
-   如果 X 是一個 Nonterminal，並且存在 X -> Y<sub>1</sub> Y<sub>2</sub> ... Y<sub>n</sub>
    1.  首先加入 FIRST(Y<sub>i</sub>) 如果 Y<sub>i</sub> 存在 ε，那就加入 FIRST(Y<sub>i</sub>) - {ε}
    2.  然後 i + 1 重複以上步驟直到 Y<sub>i</sub> 不存在 ε

> 簡單來說 FIRST 就是找出一個 Nonterminal 所有可能的開頭 Terminal

Example:
```
E  -> TE'
E' -> +TE' | ε
T  -> FT'
T' -> *FT' | ε
F  -> (E) | id

FIRST(E)  = { ( , id }
FIRST(E’) = { +, ε }
FIRST(T)  = { ( , id }
FIRST(T’) = { *, ε }
FIRST(F)  = { ( , id }
```

**Follow set**

-   The follow setof a nonterminal A is the set of terminals that can appear immediately to the right of Ain some sentential form, 
namely, S =>* αA**a**β, a is in the follow set of A.

-   如果對 Start symbol 尋找 FOLLOW(S) 要先加入 { $ }
-   如果存在 Production A -> αB
    -   FOLLOW(B) 包含 FOLLOW(A)
-   如果存在 Production A -> αBβ
    -   FOLLOW(B) 包含 FIRST(β) - {ε}
-   如果存在 Production A -> αBβ，並且 FIRST(β) 包含 ε
    -   FOLLOW(B) 包含 { FIRST(β) - {ε} } U FOLLOW(A)

> 簡單來說 FOLLOW 就是找出一個 Nonterminal 所有可能的結尾 Terminal

Example, Using previous grammar:
```
FOLLOW(E)  = { $ } U FIRST( ')' )
           = { $, ) }
FOLLOW(E') = FOLLOW(E)
           = {  $, ) }
FOLLOW(T)  = { FIRST(E') – ε } U FOLLOW(E') U FOLLOW(E)
           = { +, $, ) }
FOLLOW(T') = FOLLOW(T)
           = { +, $ , ) }
FOLLOW(F)  = { FIRST(T') –  ε } U FOLLOW(T') U FOLLOW(T)
           = { *, +, $, ) }
```

### 4.5 Bottom-up Parsing

-   Bottom Up Parsing 是從底層的 Leaf 開始，使用 Rightmost derivation 建構一顆到 Root 的 Parse tree

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-26-syntax_analysis/6.png?raw=true){:height="75%" width="75%"}

**Handles**

-   A handle β of a right-sentential form γ consists of
    -   a production A -> β
    -   a position of γ where β can be replaced by A to produce the previous right-sentential form in a rightmost derivation of γ

> 非正式的講 handle 就是和某個 Production 能匹配的 Substring，對他化簡就代表反向的 Rightmost derivation

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-26-syntax_analysis/7.png?raw=true){:height="75%" width="75%"}

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-26-syntax_analysis/8.png?raw=true){:height="75%" width="75%"}

-   The string ω to the right of the handle contains only terminals
-   Ais the bottommost leftmostinterior node with all its children in the tree

如果有 S =><sup>*</sup> αAω => aβω，那麼緊跟在 a 之後的 Production A -> β 就是 aβω 的一個 Handle，要注意 ω 一定只包含 Terminals，
如果 grammmr 是 Non-amibiguous，那麼 aβω 只會有一個 rightmost derivation，否則可能會有多個。

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-26-syntax_analysis/9.png?raw=true){:height="75%" width="75%"}

**Handle pruning:** 就是一個 Parse tree 識別 Handles 並將他們替換為 Nonterminal，到最後的過程

##### 4.5.3 Shift-Reduce Parsing



> ##### Last Edit
> 11-06-2023 17:12
{: .block-warning }