---
title: "Paper | A Study of the Characteristics of Behaviour Driven Development"
author: Benson Hsu
date: 2023-05-28
category: Jekyll
layout: post
tags: [software, software_qualitiy, software_development]
---

> C. Solis and X. Wang, "A study of the characteristics of behaviour driven development",
> Software Engineering and Advanced Applications (SEAA) 2011 37th EUROMICRO Conference on, pp. 383-387, 2011.  
> 本論文詳細定義了 BDD 相關文獻與工具而確定的 BDD 特徵，為理解和擴展 BDD 工具包或開發新工具提供了基礎。
{: .block-tip }

> Section 2 回顧現有 BDD 研究，3 採用的研究方法，4 介紹了確定的 BDD 概念模型，5 為總結。
{: .block-danger }

### 1. Intorduction 

BDD 最初是由 Dan Northp[3]作為對 TDD 中存在的問題的回應而開發的。

> [3] D. North, Introducing BDD, 2006. Available at: http://dannorth.net/introducing-bdd [Accessed December 13, 2010]. 

[TDD] 的介紹看這裡，Acceptance Test Driven Development (ATDD)(驗收測試驅動開發)[1][2]是 TDD 的一種種類，其中開發過程由代表**利益相關者**需求的驗收測試驅動。
驗收測試的通常是非開發者也能閱讀的文件，也可以是可執行的自動化測試，以確保利益相關者可以閱讀與理解，做為開發中的驗收標準。

- **利益相關者**: 例如項目負責人、用戶、業務代表等。

但許多開發者在使用 TDD 和 ATDD 時會開始困惑，`“程式設計師想知道從哪裡開始，應該測試什麼以內以及不應該測試什麼，一次測試多少，如何命名以測試，以及如何理解測試失敗的原因”[3]`，
TDD 和 ATDD 也存在一些問題，如他們專注的是系統的狀態而不是系統的期望行為，而且測試代碼與實際系統的實現高度耦合[18][20]。並且這些方法中非結構化且無限制的自然語言描述測試案例，
使它們很難被理解[3]。

BDD 被視為上面兩種方法的演進，BDD 的重點是可以自動化的方式定義目標系統行為的 fine-grained specifications(細粒度規範)，
BDD 的主要目標是獲得系統的可執行 specification(規範)[3][20]。因此 BDD 中測試寫得很清楚與易理解，BDD 提供一種特定的共通語言，
有助於**利益相關者**指定其測試。還有各種支持 BDD 的工具如 JBehave [4]、Cucumber [5]和RSpec [6]。

- **Specification**: 在 BDD 中指的是一種以人類可讀的方式表達系統行為期望的描述，用於指導軟件開發和測試。

### 2. RELATED WORK

Carvalho等人[8][9]認為 BDD 是一種**規範技術**，“通過將這些需求的文本描述與自動化測試相連接，自動確認所有功能需求在源代碼中得到適當處理”。
他們主要關注於 BDD 中形成一種簡單共通語言，使用預先標記的集合來描述需求和測試，使需求轉化為可執行的測試案例。

Tavares等人[7]將焦點放在 BDD 作為一種更廣泛的**設計技術**或**方法論**上，強調將驗證和驗收整合到設計階段中，在進入構成功能的每個部份的設計之前，
要先考慮客戶的驗收標準。它們也認為 BDD 很大程度上基於規範任務和測試的自動化，需要適合的工具支持。

Keogh[10]對 BDD 則有更廣泛的觀點，主張 BDD 在**軟體開發生命週期**的重要性，利用 **Lean thinking(精益思想)**的概念如: value stream(價值流), pull(拉動), 
PDCA (Plan-Do-Check-Adapt) cycle(PDCA循環), 來揭示 BDD 的價值，他有力的證明 BDD 比 TDD 對軟體開發過程有更廣泛的影響。

-   Lean thinking: 一種管理和生產力提升的方法論，旨在減少浪費、增加價值和改進流程來實現組織和業務的成功。

Lazăr等人[11]也強調 BDD 在業務領域和軟體開發的交互中的價值，聲稱 BDD 使開發人員與領域專家能使用相同的語言。他們指出 BDD 的兩個核心原則:  
1.  業務和技術人員應該以相同的方式對待同一系統。
2.  任何系統都應對業務具有確定可驗證的價值。

基於這觀點，他們分析了 BDD 方法並將概念作為 **[Domain model](領域模型)**和 **BDD profile** (BDD 配置文件)來呈現。
-   Domain model: 用於表示系統的概念模型，描述系統中的各個實體與其之間的相互關係。
-   BDD profile : 描述 BDD 概念和規範的結構化文件。通常用於描述系統行為與驗收標準的關鍵字、語法和語意。

### 3. RESEARCH APPROACH

因為論文發表時的 BDD 文獻如第二節所示非常有限，因此作者以包含 TDD 和 Domain Driven Development(DDD) 的文獻回顧後，
以 TDD 作為基準界定 BDD 的具體特徵，因此作者認為的 BDD 具體特徵是那些沒有被做為 TDD 報告的特徵。

作者根據 BDD Wikipediap[13]列出的 40 個 BDD 工具包中選擇。並諮詢了 BDD mailing lists [23]，最後得出七個常用的工具包來分析:  
Cucumber [5,18]、Specflow [14]、RSpec [6,18]、JBehave [4]、MSpec [15]、StoryQ [12]和NBehave [16]。  
Table 1 簡述了分析的七個工具包與其版本。

![](/image/2023/05-28-characteristics_of_BDD/1.png){:height="100%" width="100%"}

文獻回顧和工具包分析將交織再一起進行，回顧研究後確立 BDD *feature sets(特徵集)*，然後逐一分析工具包。當發現一個不在特徵集中的特徵後，會回到文獻中了解他是否可被視為 BDD 特徵，
直到分析完每個工具包。

### 4. THE CHARACTERISTICS OF BDD

作者透過以上的研究方法，確定了六個 BDD 的主要特徵。

##### A. Ubiquitous Language

Ubiquitous Language(通用語言)是 BDD 中的一個重要概念，它的結構基於[Domain model]。它包含了定義系統行為所使用的術語，是產品團隊的所有成員和利益相關者共享的一組明確的詞彙。
在設計和實施階段，開發人員將使用該語言來命名 classes & methods. 一個簡單的範例可見 [What is Ubiquitous Language? Examples?]。  
BDD 本身包含一個預設的簡單 Ubiquitous Language 但與特定領域無關，是為了提供一種統一的方式來描述系統行為，用於結構 User Story(用戶故事)和 Scenario Templates(場景模板)。

-   User Story: 描述系統的功能需求或用戶期望的行為。
-   Scenario Templates: 定義具體的測試場景的模板，描述特定用戶故事的具體情境，行動和預期結果。

作者所分析的工具包都不支援為項目創建特定的通用語言。

##### B. Iterative Decomposition Process 

Iterative Decomposition Process(迭代分解過程)，在收集需求過程中，開發者往往很難找到與客戶溝通的起點，尤其是客戶所需實現的商業價值，Business value(商業價值)往往難以明確與識別。
因此 BDD 中，分析從識別系統的預期行為開始。系統的行為將從它打算產生的 *business outcomes(商業成果)*中得出。商業成果進一步細化為 *feature sets(特徵集合)*，
一個特徵集合將一個商業成果分割成一組抽象的特徵，這些特性指明了為了實現商業成果應該做什麼。

-   假設正在開發一個購物網站，其中一個商業成果就是用戶能下訂單並購買商品，就會包含幾個抽象特徵集如下
    1.  註冊和登錄: 用戶註冊新帳號、登錄現有帳號以及管理個人資料的功能。它是實現訂單和支付的前提。
    2.  訂單和支付: 用戶下訂單並完成支付的流程。它包括選擇適當的付款方式、填寫運送地址和付款信息等。
    3.  瀏覽和搜索: 用戶可以瀏覽網站上的商品列表，並提供搜索功能來快速尋找特定商品。
    4.  購物車管理: 用戶將他們感興趣的商品加入購物車，管理購物車中的商品數量、移除商品或更新數量。
-   每個特徵集和代表一個高層次的抽象，而其中的特徵則是進一部細分的具體功能與行為。
-   考慮到商業成果是 BDD 過程的起點，因此客戶需要明確指定商業成果的優先級，以使開發人員知道應首先開發哪些特徵集。

特徵隨後可以通過 User Story(用戶故事)來實現，提供了特徵的上下文。用戶故事是以用戶為導向的，描述用戶與系統之間的互動，其中應該澄清三個問題:
1.  用戶在用戶故事中的角色是什麼? 這有助於明確指定使用者的身份和角色。
2.  用戶希望有哪些特性? 這描述了用戶對系統功能的期望和需求。
3.  如果系統提供了該特性，用戶可以獲得什麼好處? 這闡述了系統功能對用戶帶來的價值和利益。
在不同的情境下，一個用戶故事可能有多個版本，這些具體的實例就被稱作 Scenario(場景)。這些情境與結果通常由客戶提供，BDD 中場景被用作驗收標準，
用於驗證系統是否按造用戶故事的要求正確運作。

這種分解過程應該是 iterative(迭代)的，也就意味著對於每個不同的層級進行初步的分析即可，再隨著開發逐步詳細每個層級的細節，這樣就能使團隊有一個高層級的視圖再開始工作，
這樣可以使團隊更快的開始進行實現工作，同時保留靈活度與可調整性。

-   同樣以購物網站為例
    1.  初步分析：首先進行初步分析，識別出購物網站的高層級特徵集，如商品展示、購物車、付款和訂單管理等。
    2.  迭代分解：接下來可以選擇一個特徵集，如商品展示進行分解。識別出更具體的特徵，如分類展示、搜索功能、評論和評分等。
    3.  細化特徵：在這個特徵集中可以進一步細化特徵。如搜索，可以定義更具體的需求，如關鍵字、過濾器和排序等。

雖然作者所分析的工具包(2011)當下都不支援迭代分解，但現在已經有一些工具包支援迭代分解中的需求分析與設計。

##### C. Plain Text Description with User Story and Scenario Templates

Plain Text Description with User Story and Scenario Templates(純文本描述的用戶故事與場景模板)，  
BDD 用簡單的通用語言與模板描述 features, user stories, scenarios, 如 User stories 以下用 Dan North 的模板來說明[3]:

```
[StoryTitle] (One line describing the story)
As a [Role], 
I want a [Feature], 
So that I can get [Benefit]
```

*StoryTitle* 與 *Role* 描述給定角色下用戶執行的活動，*Feature* 則能確保開發人員知道應該實現哪些特徵與系統行為，為什麼要有這個功能以及該與誰討論與分析該功能。
也能清楚的說明 *Feature* 能帶給用戶什麼 *Benefit*，為什麼需要這些 *Feature*.

Scenario 的撰寫模板則如下:

```Gherkin
Scenario 1: [Scenario Title]
Given [Context]
And [Some more contexts]….
When [Event]
Then [Outcome]
And [Some more outcomes]….

Scenario2: [Scenario Title] ….
```

場景描述了當系統在特定狀態下發生事件時應該如何行動，場景的結果是改變系統狀態或輸出的動作。對於上面兩種模板中括號中的描述應該使用專案中定義的 *Ubiquitous Language* 來撰寫。
此外要將它們直接映射進專案中，也意味著 Class 的命名和方法也應該使用 Ubiquitous Language 來撰寫。

作者分析的四個工作包使用的模板都與[3]的略有不同，但都定義了 User story 中的 role, feature, benefit。

在當下已經有 BDD 穩定且廣泛應用的通用語言模板格式，詳情可以見 [Gherkin]，被 [Cucumber] 所支援。

##### D. Automated Acceptance Testing with Mapping Rules

Automated Acceptance Testing with Mapping Rules (使用映射規則的自動化驗收測試)，BDD 繼承了 ATDD 的自動化驗收的特點。
在 BDD 中驗收測試是一個可執行的規範，驗證對象之間的 interactions (交互)或 behavior(行為)，而不只是狀態[3][20]。

- **Automated Acceptance testing**: 使用自動化測試工具來執行對系統行為的驗證，這些測試通常是從 User story, Scenario 中產生的。

開發者將從一個迭代分解的過程中生成的 Scenario(場景)開始，場景將被轉化為測試驗證實現。場景的每一個步驟是一個表示場景中的抽象元素，這些元素包括:  
contexts, events, actions。**例如在 User story 或 context C 的特定情況下，當 event X 發生，系統地回答應該是 Z。**每個步驟都被映射到一個測試方法。
每個步驟都將遵循 TDD 的流程即 “red, green, refactoring” 以使其通過。

**Mapping rules**(映射規則)則提供了一個場景到 Test code(測試代碼)或 Specification code (規範代碼)的標準映射。作者所研究的工具中映射規則有不同的變化:
-   JBehave: 一個 User story 是一個包喊一組 Scenario 的文件，文件的名稱被映射到 Class 的命名，每個 Scenario 的步驟都被映射到一個 Test Method(測試方法)。
通常測試方法的名稱與 User story 文本相同。包含測試方法的 Class 則不須與場景相同。詳情可見 [JBehave Writing Textual Stories]。
-   Cucumber: Cucumber使用正則表達式進行映射，映射方法可見 [Cucumber Expressions]。

##### E. Readable Behaviour Oriented Specification Code

Readable Behaviour Oriented Specification Code (可讀的行為導向的規範代碼)，BDD 建議代碼應該是系統文檔的一部份，與敏捷的價值觀一致。
代碼應該是可讀的，規範應該是代碼的一部分。因此 Method name 應該指出 Method 應該執行的操作，Class, Method name 都應該以句子形式撰寫。

Mapping rules 有助於生成*可讀的行為導向的代碼*，它確保 Class, Method name 與 User story 和 Scenario 的標題相同。
目前大部分的 BDD 工具都支持將 Scenario 中的規範轉為代碼的方法。

##### F. Behaviour Driven at Different Phases

Behaviour Driven at Different Phases(不同階段的行為驅動)，這裡討論了行為驅動在軟體開發中的不同階段。
1.  計畫階段:
    -   定義商業成果，描述系統應該實現的期望行為。例如: 用戶能夠完成購物並順利支付訂單。
2.  分析階段:
    -   商業成果被分解為一組特性，這些特性捕捉目標系統的行為。例如: 用戶註冊，商品管理，訂單處理等等..
    -   這些特性將會被轉化為 User stoies。
3.  實施階段:
    -   Automated Acceptance testing 中 Testing Clases 是根據 Scenario 所產生的。
    -   因此 Class name 指明了該 Class 該做什麼或行為是什麼，這使開發者能考慮它們開發中的組件的行為，以及與之交戶的其他對象的角色與責任。

在作者研究的當下還沒有針對定義*商業成果*也就是計畫階段的支持，大部分的工具包都專注於 User stoies, Scenario 的撰寫與測試自動化。

*Table 2 總結了作者分析的七個工具的對於這些特徵的支持情況*

![](/image/2023/05-28-characteristics_of_BDD/2.png){:height="100%" width="100%"}

*Fig 1 是一個以 UML class diagram 來呈現的六個特徵之間的概念與關係模型*

![](/image/2023/05-28-characteristics_of_BDD/3.png){:height="100%" width="100%"}

### V. CONCLUSIONS

BDD 是多種方法的結合，如 ubiquitous language, TDD, automated acceptance testing。作者通過文獻回顧與工具包的分析來確認了六個 BDD 的主要特徵。
並透過逐一分析研究表明了這些特徵之間的互相關聯。並提出了一個 BDD 的概念模型 Fig. 1.。

而對於新的研究方向則指出， 2011 的當下工具包都主要關注於軟體開發的實踐階段，對於分析的支持有限，而計劃階段則根本沒有，這是一個可擴展的研究方向。
而另一項則是可以擴展 BDD 的映射規則，2011 現有的工具包都關注於 User story, Scenario 映射到代碼，此外 *feature sets(特徵集)* 也可以被映射到命名空間中，
在此之下再加入場景的測試[10]。

> [10] E. Keogh, BDD: A Lean Toolkit. In Processings of Lean Software & Systems Conference, Atlanta, 2010. 

> ##### NOTE
> Last edit 06-18-2023 22:56
{: .block-warning }

[TDD]: /jekyll/2023-04-21-TDD_concepts.html
[Domain model]: https://en.wikipedia.org/wiki/Domain_model

[What is Ubiquitous Language? Examples?]: https://tigosoftware.com/what-ubiquitous-language-examples
[Gherkin]: https://cucumber.io/docs/gherkin/reference/
[Cucumber]: https://cucumber.io/

[JBehave Writing Textual Stories]: https://jbehave.org/reference/stable/developing-stories.html
[Cucumber Expressions]: https://github.com/cucumber/cucumber-expressions#readme