---
title: "Paper | Test-driven development concepts, taxonomy, and future direction"
author: Benson Hsu
date: 2023-04-21
category: Jekyll
layout: post
tags: [software, software_qualitiy, software_development]
---

> John Estdale & Elli Georgiadou, (2005) Test-driven development concepts, taxonomy, and future direction.  
> 這篇論文可以用來快速了解什麼是 TDD(Test-driven development) 測試驅動開發
{: .block-tip }

### Intorduction

測試驅動開發策略要求在小型、快速的迭代(Small, rapid iterations)中先編寫自動測試，然後再開發功能代碼。這種開發策略作為極限編程(XP, Extreme programming)核心實踐之一而持續受到關注。

1.  XP, Extreme programming 是敏捷軟體開發(Agile software development)的一種方法，強調非常短的迭代進行軟體開發。
2.  小型快速的迭代(Small, rapid iterations)是一種敏捷開發方法論，將軟體開發過程劃分為一系列小模塊，每個模塊都有各自的開發與測試。
    -   例如: 一個團隊開發一個線上商店，可將功能分為各個小的模塊:  
    用戶註冊、商品搜索、購物車管理、訂單處理等等，然後透過迭代週期來完成和測試各個模塊。

##### The test aspect

除了 `High-level` 的測試之外，**TDD**要求編寫單元的自動化測試。
-   在軟體中什麼是確切的單元有一些爭議，即使在 OOP 中 Classes 和 Method 都被建議作為合適的單元。
無論如何 Method 和 Procedure 都是最小的可測試單元組件。
-   開發者需要實現`測試驅動(Test drivers)`與`模擬函數(function stubs)`，可以經由自動化(JUnit, ...)或手動化測試。
    -  Test drivers: 一個可以執行單元測試的程式，已確定代碼是否正確通過測試。  
    -  Function stubs: 一個虛擬的函數，通常只有命名、輸入與輸出參數。
-   因此在**TDD**中開發者需要先寫好單元測試，然後代碼完成後就可以立即執行測試。

##### The driven aspect

**TDD**是一種測試策略，強調測試先行，通過測試來引導軟體開發中的分析、設計、和編寫決策。
-   在 `XP` 中客戶也被視為開發者的一員，提供更清楚的需求，以此來更清楚的撰寫測試，測試就是決定程式應該做什麼的第一步。
-   為了促使測試成為分析和設計的一部分，需要使用重構(refactoring)的作法。
    -   就是不斷改變現有程式碼的結構，但依然要通過測試，使程式碼得到改進。
-   因此**TDD**更多著重的是分析和設計，而不是測試，測試是用來幫助開發者決定程式或程式介面應該是什麼樣子。

##### The development aspect
-   **TDD**旨在協助構建軟件開發，但它不是一種軟件開發方法論或過程模型。相反，它是一種實踐方法，可以與其他方法相結合。
    -   如結合其他開發方式，在 DevOps 中 TDD, BDD 都被強調為測試過程的重要方法，可以參考[1]。
-   同時測試不是為了做出設計決定後就被拋棄的，而是成為開發過程中的一個重要步驟。
    -   如果有一個變化導致測試失敗，當測試還在開發者的腦海中時，開法者可以立刻知道哪裡出錯。缺點就是在開發時必須同時維護測試與生產代碼。

> [1] Pulasthi Perera, ..., (2017) Improve Software Quality through Practicing DevOps, IEEE

##### Software development methodologies
在軟體開發過程或方法論定義了建立軟體的基本任務(base task)的順序(order)、控制(control)、評估(evaluation)。在這些方法論中的複雜度與控制範圍從非正式的到高度結構化不等
-   方法論分為兩大類: Prescriptive(規定型), Agile(敏捷型)
-   具體可分為: [Waterfall(瀑布式)], [Spiral(螺旋式)], [Incremental(增量式)], [Evolutionary(演進式)]
-   但在開發中通常是組合使用這些方法，例如:  
    -   一個組織可能使用增量式開發模型，逐步建構項目的累積片段。而在每個增量中開發者可以應用瀑布或線性方法進行開發。那麼根據增量的大小我們就能將整個方案標記成不同的方法論。  
    假設方程式 $\sum_{i=1}^{N} I_i$ 代表整個專案，$I_i$則是每次的增量，我們可以去預想如果$N$大於一定量則是一個增量項目，若$N\leq2$則使用瀑布項目。如果每個增量需要修改大量重複的軟體部份，我們就可以說具有迭代性，例如：  
    如果$C_i$是$\sum_{i=1}^{N} I_i$的項目$P$中的每次增量被影響的代碼部分，並且項目$P$有迭代性則$C_i \cap C_{i+1} \neq \emptyset$
    -   Prescriptive(規定型)通常會希望有一份正式的文件，如規範文件來記錄增量的需求。
    -   Agile(敏捷型)則文件通常是非正式的，如白板圖或一套不完整的UML圖，並且生成是快速的。

建設任務的順序對一個項目來說至關重要，傳統的順序是：  
-   Requirements elicitation(需求徵詢), Analysis(分析), Design(設計), Code(編碼), Test(測試), Integration(集成), Deployment(部署), Maintenance(維護)
在開發過程中我們能發現在Design, Code, Test階段都有不同種類的測試，如：單元測試, 整合測試, 回歸測試

### TDD’s historical context

-   Test-driven development(測試驅動開發)是與敏捷模型的興起一起出現的，都起源於20世紀50年代的迭代，增量，進化的過程模型。
-   將測試移動到編碼的前方並不是什麼新鮮事，在1980's的 [Cleanroom] 軟體工程方法就已經包含了使用 [Formal methods] 對早期設計元素進行驗證。
-   在1998 XP(極限編程)後開始推崇先寫測試在寫程式，但在那之前就可能有非正式的測試先行的方法。

> [2] K. Beck, Extreme Programming Explained: Embrace Change, Addison-Wesley, 1999.

> “learned test-first programming as a kid while reading a book on programming. It said that you program by taking the input tape ... and typing in the output tape you expect. Then you program until you get the output tape you expect.” - Kent Beck [2]

-   **TDD**就是將這種做法做到極端，總是先寫測試再編程，增量式、迭代式和演進式過程模型的發展對它的出現至關重要。
    -   將測試分解成更小、更簡單、更具體的單元測試，這樣做的好處是能夠更快地找到問題，更容易進行測試和調試。
    -   永遠不使 Code 退化，不允許代碼質量下降或出現新的錯誤。這可以通過不斷地運行測試來實現。

> XP takes the known best practices and “turns the knobs all the way up to ten.” - Kent Beck [2]

**TDD developed within the context of iterative, incremental, and evolutionary models.**  

-   **Iterative** 涉及重複一組開發任務，通常是在逐漸擴展的需求集上進行。
-   **Incremental** 則產生一系列的版本，每一個增量都提供更多的功能。
-   **Evolutionary** 方法涉及`自適應`和`輕量級迭代`開發。
    - Adaptive(自適應): 強調利用過去迭代的反饋來改進軟體。
    - Lightweight(輕量級): 減少過度的規範和流程，利用反饋進行改進，在最短時間內交付可用的版本。
    - Spiral Model(螺旋模型): 結合原型(prototyping)和迭代(iterative)的循環，並加入風險驅動和錨點里程碑。  

> that to implement XP, developers must apply all of the incumbent practices—leaving some out weakens the model and can cause it to fail. - Kent Beck [2]

-   **TDD**要求將設計決策延遲(design decisions be delayed)和靈活(flexible)以影響軟體設計
    -   設計決策延遲: 在這之前先編寫測試用力，這些測試用力會指導開發者在編寫代碼之前考慮好應該如何設計代碼才能使其滿足需求。這樣開發者可以通過通過測試用例更好的理解問題和需求。
    -   靈活: 在設計過程中，保持靈活性以便能夠適應可能出現的變化。這意味著編寫足夠通用的測試用例，以便代碼可以更容易地進行修改，而不會破壞之前的測試。

一個自動化的測試將給予開發者勇氣重構程式碼，也給了他們需要的訊息，使他們能在改變程式碼後迅實現修改，而實現開發人員對代碼的**集體所有權(Collective ownership)**。
-   集體所有權(Collective ownership): 所有的開發人員都有對代碼的共同責任和掌控權，因為**TDD**自動化單元測試可以使開發者迅速檢查是否有破壞其他開發者的工作。

### Automated testing

Software tools 已經成為現代軟體開發的重要因素。Compilers, Debuggers, IDE, Modeling, Computer-aided software engineering tool, 這些工具提高了開發者的生產力。
-   **TDD**假定存在自動化的單元測試框架，這樣的框架提供了`測試驅動(test driver)`, `存根(stub)`, `子系統的接口(interfaces to other subsystem)`的測試組合。
    -   Erich Gamma 和 Kent Beck 開發了 JUnit, 一個 Java 的自動化單元測試框架，JUnit 在很大程度上促進了 TDD 和 XP 的廣泛普及。類似 JUnit 的框架也已實現於多種不同的程式語言中，創建了一系列的框架，被稱為 xUnit。

**xUnit**  

一般來說 xUnit 允許開發者撰寫一系列自動化單元測試，從初始化(Initialization), 執行(Execution)並對測試代碼進行斷言(Assertion)。
-   各個測試都是獨立的，所以測試順序並不重要。xUnit 測試是用與被測試代碼相同的語言編寫的，
-   同時測試也可以作為文檔(docs)，開發者通過閱讀測試程式碼來了解被測試程式碼的行為和功能。
-   JUnit 也提供了一個可移植的 GUI，已經被集成到流行的開發環境中，如 Eclipse。
    -   JUnit 中一些工具簡化了 [Mock object(模擬對象)]、[Stub(存根)] 的創建，這些可以取代真實的協作對象，因此開發人員就能專門測試一個特定的對象。
    -   同時也可以使用其他工具如 Cactus, Derby 和 JUint 一起實現涉及 [J2EE] 組件或 Database 的自動化測試。

支持 TDD 的工具不斷增加顯示出了 TDD 受到的支持，並且使開發人員能輕鬆開發單元測試並通過自動化執行大型測試套件，以此迅速獲得有關系統狀態的結果。

##### Early testing in academia

大學的計算機科學和軟體工程課程可以作為一個指標，來評估軟體實踐的廣泛接受程度。有時學界會領先於實踐，有時則會跟隨，而軟體工程，迭代開發和 TDD 則是後者的模式。
這些軟體工程課程往往落後於業界的普遍實踐，因此往往是實際軟體開發使用了新的開發過程模型，再由學者研究、最終成為課程的一部分。
-   1991 ACM 課程指南中迭代開發和驗證只分配了不到八小時的講座與實驗時間。而在 2001 年則分配到了更少的時間僅有五小時。
-   在文章撰寫的當下 2005 TDD 並還沒有被學界廣泛接受。

##### Recent context (2005)

XP 是當時最著名的敏捷方法，經常與其他敏捷方法(例如: Scrum) 結合使用，XP 提出使用 TDD 作為開發高品質軟體的一個組成部分。
TDD 的潛在使用者常常對於編寫和維護測試單元感到擔憂， Beck 承認自動化單元測試並不是對所有事情都必要的，
但是他也堅稱 XP 無法在沒有 TDD 的情況下運作，因為它是作為將整個流程黏合在一起的黏合劑。

- 盡管 XP 的流行但並不代表使用時會採用它的所有實踐，或者他們不連貫的使用這些實踐。
    -   ThoughtWorks 的一個專案中，J. Rasmusson 是一個早期的 XP 使用者，但約有 1/3 的代碼是使用 TDD 開發。[3]
    -   在這個專案中，開發者在 37,000 行代碼中有 16000 行是用於自動化單元測試，許多測試都是在測試優先和測試最後的迭代中寫的。[3]
    -   因此口頭證據表明，即便只採用 XP 的部分實踐，TDD也通常會包含在內。

> [3] J. Rasmusson, “Introducing XP into Greenfield Projects: Lessons Learned,” IEEE Software, May/June, 2003, pp. 21-28

> “If I could only recommend one coding practice to software developers, those who use XP or otherwise, it would be to write unit tests.” - J. Rasmusson [3]

在當時流行的 IDE Eclipse 中，JUnit, XP 這樣的流行結合也可以意味著 TDD 被廣泛採用的一部分證明。

### Evaluative TDD research

在論文當下(2005)大部分文章都是關於應用 TDD 所寫，對於 TDD 的效果與好處的研究相對較少。
-   關於 TDD 的研究大致可依背景分為業界與學術的研究:
    -   業界研究往往更注意實際應用與實用性，並著重於現有實踐進行評估與改進。
    -   學界則更注重基礎理論與科學方法，著重於深入研究問題背後的原因與機制。

##### TDD in industry

NCSU(North Carolina State University) 的研究者在四家不同公司進行了三項關於 TDD 的實證研究[8][9][10]，參與者是一些相對小的團退。這些研究以`缺陷密度(Defect density)`作為衡量品質的指標。
-   使用 TDD 進行開發的控制組比對照組多通過 18% - 50% 的外部測試用例。
-   同時使用 TDD 開發的除錯(debugging) 時間花費更少。

![](/image/2023/04-21-tdd_concepts/1.png){:height="100%" width="100%"}
> Table 1 summarizes these studies and labels each experiment as either a case study or a controlled experiment.

> [8] B. George and L. Williams, “A Structured Experiment of Test-Driven Development,” Information and Software Technology, vol. 46, no. 5, 2004, pp. 337-342.  
> [9] E.M. Maximilien and L. Williams, “Assessing Test-Driven Development at IBM,” Proc. 25th Int’l Conf. Software Eng. (ICSE 03), IEEE CS Press, 2003, pp. 564-569.  
> [10] L. Williams, E.M. Maximilien, and M. Vouk, “Test-Driven Development as a Defect-Reduction Practice,” Proc. 14th Int’l Symp. Software Reliability Eng. (ISSRE 03), IEEE Press, 2003, pp. 34-45.  

##### TDD in academia

盡管在學術環境中很多 TDD 相關的研究都是軼事，但在 Table 2. 列出的五個研究則有具體的實證結果。
-   除了 [11] 其他都聚焦於 TDD 的早期缺陷檢測能力。
-   [11] [12] 報告了軟體品質與程式開發者生產力的明顯改善。
-   [13] 報告撰寫的測試數量與生產力之間的相關性。
-   [14] [15] 則報告了缺陷密度和生產力方面並沒有明顯改善

以上報告都相對較小，並且沒有或很少有具有 TDD 經驗的開發者參與。

![](/image/2023/04-21-tdd_concepts/2.png){:height="100%" width="100%"}

### Factors in software practice adoption

多種因素影響是否採用軟體實踐其中包含:  
`Motivation for change(改變的動機)`, `Economics(經濟)`, `Availability of tools(工具的可用性)`, `Training and instructional materials(訓練和培訓工具)`,
`A sound theoretical basis(紮實的基礎理論)`, `Empirical and anecdotal evidence of success(成功的經驗和軼事)`, `Time(時間)`, `The practice by highly regarded individuals or groups.(權威個人或團體的做法)`
-   Motivation for change: 軟體開發實務上有明確的改變動機，開發涉及人員、流程、技術和工具等複雜的組合，TDD 為一種嘗試改進並看似有效的方法。
-   Availability of tools: TDD 的工具支持很強，並且正在不斷改進，像 JUnit, MockObjects, Cactus, 這樣的工具已經成熟並廣泛可用。
-   Economic: 經濟模型上也指出了 XP 和 TDD 在軟體開發上的潛力，但需要進一步研究 TDD 和 XP 帶來的優缺點，如:
    -   TDD 在配合代碼使用時需要研究它在速度上是否會慢於傳統開發，與對缺陷密度(defect density)的影響。
-   A sound theoretical basis & Empirical and anecdotal evidence of success: 研究表明，學術開發需要 5 - 15 年時間才能在商業實踐中取得成功，反之亦然。TDD 可以改善開發教育。

1.  TDD 的普及面臨許多挑戰，首先開發者要有良好的紀律，因為 TDD 需要開發者遵從他的流程與步驟，因此需要使開發者充分理解 TDD 的好處，才能使開發者嘗試使用。  
2.  TDD 也被廣泛的誤解，很多人錯誤的認為 TDD 只關注測試，而不是設計。TDD 不僅僅是關注測試，它同時也要求開發人員在編寫程式碼之前，必須先清楚地設計出程式的架構和功能。在這個過程中，開發者必須思考如何編寫最小程式碼，減少重複代碼，設計清晰的介面等，要求開發者在設計和開發過程中相互交替地進行，從而可以促進高品質、易於維護和可擴展的程式碼產生。
3.  TDD 並不適用於所有開發場景，開發者和管理者必須決定何時用 TDD 何時不用。

##### Understanding TDD’S effects

在 2005 論文發表時，TDD 對於品質的影響都將焦點放在缺陷密度(defect density) 上，應該有其他方式評估軟體品質。
未來的研究應該考慮在課程和程式設計師成熟度不同的情況下，TDD的有效性。還可以研究 TDD 與先設計後測試的方法、迭代方式進行的測試最後方法的效果差異。
也需要研究 TDD 與其他實踐結合的效果，如配對編程(Pair programming), 代碼檢查(Code inspection) 結合的效果，並且研究 TDD 是否可以納入大學教育中，
以提高學生的設計和測試能力。

-   XP-EF, 一個持續進行評估 XP 專案案例研究的框架[16]
-   配對編程(Pair programming): 兩名程式開發人員共同在同一臺電腦上工作，一人負責寫代碼，另一人負責檢查。
-   代碼檢查(Code inspection): 軟體開發中對於原代碼進行審查以檢查其品質和可靠性。

> 16. L. Williams, L. Layman, and W. Krebs, Extreme Programming Evaluation Framework for Object-Oriented Languages, v. 1.4, tech. report TR-2004-18, North Carolina State Univ., 2004.

##### Even if Xp fades in popularity

即使未來 XP 逐漸失去流行，但是 TDD 可能仍然持續存在。如果TDD進入學術領域，學生們可以帶著更好的紀律和更好的軟體設計和測試技能進入軟體開發組織，
從而提高軟體工程社區可靠地生產、重用和維護高品質軟體的能力。

> ##### NOTE
> 這篇論文很好的介紹了 **TDD** 的概念與歷史、工具、在 2005 年時的未來展望，同時結尾的論述也非常準確，2023 年的今天 XP 已經不再像 2002 那樣流行，
> 但是 TDD 仍然是重要的開發方式，並也發展了後續的 BDD 等。  
> <br>
> Last edit 04-29-2023 18:24
{: .block-warning }

[Cleanroom]: https://en.wikipedia.org/wiki/Cleanroom_software_engineering
[Formal methods]: https://en.wikipedia.org/wiki/Formal_methods

[Waterfall(瀑布式)]: https://en.wikipedia.org/wiki/Waterfall_model
[Spiral(螺旋式)]: https://en.wikipedia.org/wiki/Spiral_model
[Incremental(增量式)]: https://en.wikipedia.org/wiki/Incremental_build_model
[Evolutionary(演進式)]: https://en.wikipedia.org/wiki/Iterative_and_incremental_development

[Mock object(模擬對象)]: https://en.wikipedia.org/wiki/Mock_object#Mocks,_fakes,_and_stubs
[Stub(存根)]: https://en.wikipedia.org/wiki/Test_stub
[J2EE]: https://en.wikipedia.org/wiki/Jakarta_EE