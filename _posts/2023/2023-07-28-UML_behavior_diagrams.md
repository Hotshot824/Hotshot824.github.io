---
title: "Note | UML Behavior Diagrams Introduction (Unfinished)"
author: Benson Hsu
date: 2023-07-28
category: Jekyll
layout: post
tags: [software, software_development]
---

> 本篇主要介紹 UML 的分類中的行為圖(Behavior Diagrams)，與其子集交互圖(Interaction diagrams)。以此為分賴再依照廣泛使用程度介紹。
{: .block-tip }

### 1. Behavior diagrams

[1.1 Activity diagram](./2023-07-28-UML_behavior_diagrams.html#11-activity-diagram)  
[1.2 Use case diagram](./2023-07-28-UML_behavior_diagrams.html#12-use-case-diagram)  
[1.3 State diagram](./2023-07-28-UML_behavior_diagrams.html#13-state-diagram)  

##### 1.1 [Activity diagram]

Activity diagram(活動圖)是 UML 中第二被廣泛使用的圖形，用於描述系統的動態方面，活動圖本質上是流程圖的進階版本，
它對從一個活動到另一個活動的流程進行建模。

-   **When to Use Activity diagram**
    1.  通過檢查業務工作流程(Business workflows)來確定候選用例(Use case)。
    2.  確定 Use Case 的前置與後置條件(Context)。
    3.  對於 Use Case 之間/內部的 Workflows 建模。
    4.  對於 Object 的複雜操作流程進行建模。
    5.  使用不同層級的活動圖對複雜的活動建模。

下圖分別解釋一個基本的活動圖，與一個訂單流程的範例:

-   **Pre/Post-condition**: 
    -   Black circle: 代表該 Workflow 的開始(init node)。
    -   Encircled black circle: 代表該 Workflow 的結束(final node)。
-   **Stadia**: 代表動作(actions)。
-   **Diamonds**: 代表決策(decisions)。
-   **Bars**: 代表並行(Concurrent)活動的開始(split) 或結束(join)。

<div style="display: flex; flex-direction: row;">
    <img src="https://www.cybermedian.com/wp-content/uploads/2022/02/0uvpguBHR-p5IuZLU.png" 
    alt="Image 1" width="55%" height="55%">
    <img src="https://www.cybermedian.com/wp-content/uploads/2022/02/0ECkc43G4v2ffwlu0.png" 
    alt="Image 2" width="45%" height="45%">
</div>

##### 1.2 [Use case diagram]

Use case diagram(用例圖)是第四使用廣泛度的圖形，表示 Actor 與系統交互的最簡表示形式，展現了 Actor 和與他相關的 Use case 之間的關係。
下圖是一個基本的 Use case diagram，Use case diagram 主要由以下元素所組成:

-   **Actor**: 與系統進行互動的各種參與者，可以是**使用者**或**外部實體**。
-   **Use case**: 系統如何反應外界請求的描述，描述了一個特定的操作或任務。
-   **Associate**: 以虛線連接 Actor 與 Use case，表示 Actor 與 Use case之間的互動。
    -   include: 包含關係，使用該用例時一定會執行的相關用例。
    -   extend: 擴展關係，使用該用例時不一定會執行的相關用例。
-   **Boundary**: 以一個方框定義 System boundary，並在最上方寫出系統名稱。

![](https://www.cybermedian.com/wp-content/uploads/2022/02/0RfARWrqsX6NzluKt.png)

下面是一個汽車銷售系統的 Use case diagram，可以發現即使是一個汽車銷售系統的用例也不超過十個:  

![](https://www.cybermedian.com/wp-content/uploads/2022/02/0KqbT4ZvRjHaf0pF8.png)

##### 1.3 [State diagram]

State diagram (狀態圖)與用例圖並列第四廣泛使用，顯示實體的不同狀態，狀態圖還可以顯示實體如何通過從一種狀態更改為另一種狀態來響應各種事件。

-   **When to use State diagram?**
    -   用於描述系統的狀態轉換，系統在不同時間點處於不同的狀態，以及在特定條件下如何從一個狀態轉換為另一個。
    -   用於建模具有多種狀態的實體，實體如何根據事件改變狀態，如物件的生命週期、狀態機、事件驅動的系統等。

下圖用來說明狀態圖的符號:

1.  **Initial Pseudo State/Final State**: 黑色圓點，開始/結束節點。
2.  **State**: 圓角矩形，內部標有狀態名稱，是一個實體所處的一個具體狀態。
3.  **Transition**: 以剪頭指向下一個狀態，在上方可以標明指定觸發轉換的條件或事件。

![](https://www.cybermedian.com/wp-content/uploads/2022/02/04agZfvKlcs7cdx0H.png)

下圖是一個具有 Substate(子狀態)的加熱器狀態圖，有子狀態的情況也可稱作 Nested state(嵌套狀態)/Compound state(複合狀態)。
Substate 可以有自己的進入狀態、結束狀態、以及在子狀態之間的 Transition。

![](https://www.cybermedian.com/tw/wp-content/uploads/sites/5/2022/02/0zB4XFSSIHh3mYRV.png)

-   **History States**:  
除非有特別說明，不然進入一個子狀態都是以初始狀態重新開始。有註明 History state 就代表進入子狀態是以之前活動的最後一個子狀態開始。

![](https://www.cybermedian.com/tw/wp-content/uploads/sites/5/2022/02/0-otCYx4pB3g5r02b.png)

> 延伸閱讀 [UML 2 Tutorial - State Machine Diagram]

### 2. Interaction diagrams

[2.1 Sequence diagram](./#21-sequence-diagram)  
[2.2 Communication diagram](./#22-communication-diagram)  

##### 2.1 [Sequence diagram]

Sequence diagram(時序圖)是第三被廣泛使用的圖形，描述物件在時間序列中的交叉作用。序列圖會描繪在此情境下有關的物件，
以及此物件和其他物件交換訊息的順序。

下圖解釋了一個酒店預約的時序圖，從一個窗口(window) 開始啟動。

一個時序圖應該要注意的點有這些:
-   **Object/Actors**: 方框，物件/參與者。
    -   Lifeline: 垂直線，代表一個物件的開始與結束。
    -   Activation bar: 發送和接收訊息的開始與結束。
-   **Messages**: 水平箭頭，上方寫有被調用的 Mehtod 與 Parameter、Return。
    -   Self Message: 呼叫同一個物件的方法，例如一些 Private method。
    -   Solid arrowheads: 實心箭頭，代表同步(Synchronous)訊息，發送方必須等待訊息完成。
    -   Open arrowheads: 空心箭頭，代表異步(Asynchronous)訊息，發送方無須等待訊息完成。
    -   Dashed lines: 代表回覆，可以是實心(同步)/空心(異步)箭頭上方帶有回覆的 Method。
    -   Lost/Find: 使用一個圓點作為結束/開始，收件人未知/已知，發見人已知/未知。
    -   Creat: 指向一個物件創造一條生命線。
    -   Delete: 終止一條生命線。
-   **Combined Fragment(組合片段)**:  大方框，用來標記複雜互動。
    -   opt: 相當於 if 當條件為 true 就執行，false 不執行。
    -   alt: 相當於 if else，條件為 true 執行否則執行 else。
    -   loop: 條件為 true 就重複執行，可以使用 loop(n) 指明執行次數。
    -   ref：參考其他的 Squence diagram，用於簡化圖表。
    -   par: 併行(parallel)執行的片段。

![](https://www.cybermedian.com/wp-content/uploads/2022/02/0F7xxOXmkZbMB3Xza.png)

##### 2.2 [Communication diagram]

Communication diagram(通訊圖)與 Seqence diagram 一樣是顯示對象如何傳輸信息，他們在語意上是等價的，也就是呈現相同的資訊。
Communication diagram / Seqence diagram 之間可以**互相轉換**，最主要的差別是通訊圖以空間進行排列元素，序列圖以時間排列元素。
如何在兩種圖型之間轉換的範例:

![](https://www.cybermedian.com/wp-content/uploads/2022/02/0qtALckhbhBawZ6yt.png)

下圖是一個酒店預約系統的通訊圖，它的主要元素有:

1.  Object: 方框，代表物件或實體。
2.  Links: Object 之間的連線，代表通訊通道。
3.  Message: 實心/空心箭頭，各自代表同步/異步通訊，方向代表送出端與接收端，並且訊息帶有編號。

![](https://cdn-images.visual-paradigm.com/guide/uml/what-is-communication-diagram/03-communication-diagram-example-hotel-reservation.png)

> ##### Note
> Last edit 07-30-2023 13:42, [Reference]
{: .block-warning }

[Reference]: https://www.cybermedian.com/a-comprehensive-guide-to-understanding-and-implementing-unified-modeling-language-in-software-development/#Sequence_diagrams

[Activity diagram]: https://en.wikipedia.org/wiki/Activity_diagram

[Use case diagram]: https://en.wikipedia.org/wiki/Use_case_diagram

[State diagram]: https://en.wikipedia.org/wiki/UML_state_machine
[UML 2 Tutorial - State Machine Diagram]: https://sparxsystems.com/resources/tutorials/uml2/state-diagram.html

[Sequence diagram]: https://en.wikipedia.org/wiki/Sequence_diagram

[Communication diagram]: https://en.wikipedia.org/wiki/Communication_diagram