---
title: "Note | Architectural Patterns Compare MVP, MVC, MVVM"
author: Benson Hsu
date: 2023-07-18
category: Jekyll
layout: post
tags: [software, software_development]
---

> Design pattern compare for MVP, MVC, MVMM. 
> 這是三種最常用的軟體架構模式，從這篇來了解這三種架構的差異與比較。
{: .block-tip }

這三種 Architectural Patterns 的目的都是為了將 **Business logic(業務邏輯)與 View(視圖)實現代碼分離**，使一個程式能有不同的表現形式。

### Architectural Patterns vs Design Patterns

-   Architectural Patterns 是一種通用可重複使用的解決方案，用於解決特定 context 中的軟體架構中的常見問題。架構模式是處理系統中的主要組件如何協同工作，
訊息(message) 與資料(data) 如何在系統中流動以及其他結構性的考量因素。架構模式使用一些組件類型，每種組件會由更小的模塊所組成。
-   Design Patterns 則是常見問題的推薦解決方案與實踐，關注於如何建構應用程式中的組件。

**Example:** 
1.  MVC 是一種 **Architectural Pattren** 他將程式分為三個主要部分, Model, View, Controller, 這部分之間的資訊交換有嚴格的規則，以實現更好的代碼組織與可維護性。
2.  Observer Pattern(觀察者模式) 是一種 **Design Pattren**，定義了對象之間的一對多依賴關係，以便當一個對象改變狀態時，所有依賴於他的對象都會收到通知。

### Model View Controller(MVC)

MVC 最早來源於一篇論文，該論文對於 Model-View-Controller 三個模塊以其他們之間的通訊都講述了一些設計細節。
> Steve Burbeck, Ph.D., Applications Programming in Smalltalk-80 (TM): How to use Model-View-Controller (MVC), 1979.  

MVC 將程式分為三種組件，Model, Viewm Controller, 三者有各自的用途和職責:  
1.  **Model**:  
`Model = data + business logic` 也就是說 Model 既負責了資料的儲存也負責處理開資料的邏輯，因此處理業務邏輯是 Model 的責任而不是 Controller。所以從資料來看，
還可以分為資料的獲取、儲存、資料結構，因此在設計時 Model 會再次細分為更多 layer 如業務邏輯、網路、存儲等...
2.  **View**:  
View 負責顯示 Model 的資料，並負責最終如何在用戶介面中顯示數據以及終端用戶之間交互。View 是以網格、表格、圖表等等類似可以顯示數據的可視化表現。
3.  **Controller**:  
Controller 負責 Model-View 之間的橋樑，用於控制程式的流程。所以 Controller 負責接收來自用戶的輸入、驗證輸入數據，解析用戶輸入後並交由對應的 Model 去處理。
所以理論上 Controller 是很輕的。

![](https://miro.medium.com/v2/resize:fit:828/format:webp/1*VZnCAfqEcho3_WyYQsglpw.png){:height="55%" width="55%"}
> MVC Diagram, Reference to [here].

#### MVC and its variants

其實我們能發現最初版本的 MVC View 還是依賴於 Model，實際上降低了 View 的可用性，那變種的 MVC 就將 View 與 Model 完全分開，那就可以提高 View 的可重複性，
因此就有以下這種 MVC:

![](https://upload.wikimedia.org/wikipedia/commons/thumb/9/9d/MVC-basic.svg/900px-MVC-basic.svg.png?20170211044359){:height="55%" width="55%"}
> MVC variant Diagram.

View 與 Model 就不要進行通訊了，所有的通訊都基於 Controller，Model 將結果告訴 Controller，再由 Controller 更新 View。這種變種最早是由 Apple.Inc 所提出，
很多 Web 框架也是基於這種變種 MVC 所設計，如 SpringMVC。  
另外在設計時 Controller 去跟 Model 發出請求時通常會比較耗時，因此一般都是非同步(async) 通知 Controller。

### Model View Presenter(MVP)

MVP 最早的解說來自於，是針對 MVC 再改良出的 Pattern:  
> Mike Potel, MVP: Model-View-Presenter The Taligent Programming Model for C++ and Java, 1996.

![](/image/2023/07-19-software_arch_pattern/1.png){:height="75%" width="75%"}

可以看出最早的 MVP 其實與我們現在所看到的 MVP 不太一樣，該 MVP 是從**數據管理**與**用戶介面**兩個方向的問題出發，將 Smalltalk 的 MVC 在分解而成，
多了幾個中間組件: 

1. **Interactor**: 定義 View 的交互事件，也就是將使用者的輸入轉為適當的操作。
2. **Commands**: 定義對 Model 數據的操作如，儲存或更新資料庫、呼叫 API、進行演算法運算等。
3. **Selections**: 定義為從 Model 中篩選資料，並準備好相關的查詢或過濾條件。

![](https://miro.medium.com/v2/resize:fit:828/format:webp/1*8O8B9FM1Skh9ZbCIgqYsJg.png){:height="75%" width="75%"}
> MVP Diagram, Reference to [here].

因此我們從上圖來看，如果去忽略中間組件，會發現與 MVC variant 幾乎一樣，在論文中就提到。
**Presenter 其實就是 Controller，只是為了與 MVC 區分開才稱作 Presenter**。在這個 MVP 中三個組件各自的職責:

1.  Model: 儲存數據(與資料庫溝通、請求網路資源等)，負責處理業務邏輯。
2.  View: 顯示資料，將使用者的輸入傳給 Presenter。
3.  Persenter: 從 Model 中獲取資料，並決定 View 中顯示什麼。

可以發現其實與 MVC variant 中的依賴是一樣的，只是 MVP 之間要透過介面(interface) 來實現，Model, View, Persenter 各自有各自的 interface，
針對 interface coding，自然就會去 decoupling，提高可重複性，以及容易進行單元測試。

### Model-View-ViewModel(MVVM)

MVVM 最早由 John Gossman 在他的 Blog 上所發表:
> John Gossman, Introduction to Model/View/ViewModel pattern for building WPF apps, 2005.

![](https://miro.medium.com/v2/resize:fit:828/format:webp/1*1QYLvhV-dPcRHDMBumxd2A.png){:height="75%" width="75%"}

**View-Model**

就如字面所述`View-Model = Model of View`，也可以看作是 `Abstraction of the View`，簡單來說在 MVVM 中 View 不負責維護數據，
View 負責與 View-Model 同步數據，View-Model 也用於管理 View 的狀態和操作模型的方法與命令，
因此 View-Model 中封裝了 View 的**屬性(Property)**與**命令(Command)**。

因此在 MVVM 中最重要的一個特性就是數據綁定(data binding)，通過綁定使兩者之間**鬆耦合(Loose coupling)**，這樣就不用在 View-Model 中去寫 Update，
這裡綁定有兩種類型:

1.  單向綁定(View-Model -> View): 當 View-Model 發生變化後，View 才會更新。
2.  雙向綁定(View-Model <-> View): 當 View-Mode, View 中任何一方發生變化，另一方都會更新。

一般情況下，只需在 View 中顯示但無須編輯的數據使用單向綁定，反之。同時 View-Model 封裝的是 View 的**屬性**與**命令**，
因此綁定也分為 Property Binding, Command Binding。

要實現綁定通常使用 [Publish–subscribe pattern]，這部分通常各大框架中都有自己的實現，Vue、React 中都實現了數據綁定。

> ##### Conclusion
> MVP, MVVM 都是為了實現 View 與 Business logic 的分離問題，只是兩者使用不同的實現。MVP 透過 interface 實現，缺點就是要編寫大量的 interface，
> 而 MVVM 則透過 Bind，但就要依賴框架工具來開發。
> <br>
> Last edit 07-21-2023 11:33
{: .block-warning }

[Reference]: https://juejin.cn/post/6901200799242649607
[here]: https://medium.com/learn-record/mvc-mvp-mvvm%E6%9E%B6%E6%A7%8B%E6%AF%94%E8%BC%83-62b5657d2e21
[Publish–subscribe pattern]: https://en.wikipedia.org/wiki/Publish%E2%80%93subscribe_pattern