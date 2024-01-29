---
title: "Paper | An Analysis and Survey of the Development of Mutation Testing"
author: Benson Hsu
date: 2023-05-20
category: Jekyll
layout: post
tags: [software, software_qualitiy, mutation_testing]
---

> Yue Jia, Mark Harman, ... (2011), An Analysis and Survey of the Development of Mutation Testing.  
> 用這篇論文熟悉什麼是突變測試(Mutation Testing). 突變測試是用來檢測測試集合能否發現故障的能力，
> 這篇文章全面分析了一系列突變測試的方法、工具、發展和驗證結果，**本文引用眾多且詳細，閱讀時要搭配原文的索引閱讀**。
{: .block-tip }

> Section 2 是突變測試的幾本理論，3 ~ 5 詳細介紹突變技術與應用，6 是總結研究經驗，7 是突變工具的開發工作，8 討論目前的證明，9 則是尚未解決的問題與障礙，10 為總結。
{: .block-danger }

> Section 3 以後是詳細技術介紹，如果只想簡單理解什麼是突變測試讀 1、2、10 即可。

### 1. Intorduction 

突變測試(Mutation Testing)是一種基於故障的測試技術，可以提供一個稱為 `Mutation adequacy score(突變適應性分數)`的測試準則來評估測試集合在檢測故障方面的有效性。  
突變測試使用的故障代表程序員常會犯的錯誤，我們也可以模擬任何 `Test adequacy criteria(測試適當性準則)`。透過簡單的語法變化崁入原始程式中，稱為突變體。這些突變體會執行輸入輸出測試集合，如果一個突變體的結果與原始程式不同就表示檢測到一個故障突變體，亦稱為**killed mutant(殺死突變體)**。

-   Mutation adequacy score：
    -   突變測試的測試準則，是檢測到的突變數量與生成突變體的總數的比例，公式為(檢測到的突變/生成突變數量)。
-   Test adequacy criteria:
    -   一組可用於判斷是否進行了充分測試的規則，也可指導測試數據的選擇，明確的說明如何選擇測試數據。

> Mutation score = (number of killed mutants/total number of mutants killed or surviving) x 100

突變測試的概念可以追溯到 1971, 當時 Lipton 在一篇學生論文中提出了這一概念。Mutation testing 可以應用在軟體測試的單元層、集成層和規範層。已經在許多編程語言中得到應用，是一種**白盒單元測試技術**。同時也可以在設計層次用於測試程式的規範或模型，
如 Mutation Testing已經應用於有限狀態機、Statecharts、Estelle規範、Petri網絡、網絡協議、安全策略和Web服務等領域。

本文作者整理了一系列的突變測試論文，將重要的論文註記於 Table. 1.，及關於增長趨勢的圖表 Fig. 1.。

![](/image/2023/05-20-analysis_mutation_testing/1.png){:height="100%" width="100%"}

![](/image/2023/05-20-analysis_mutation_testing/2.png){:height="100%" width="100%"}

### 2. The theory of mutation testing

##### 2.1 Fundamental Hypotheses

突變測試希望能夠有效的識別足夠的測試數據，用於發現真正的故障。`[96]`但是潛在的故障是巨大的，不可能代表所有的突變體，這是一個針對故障的子集，希望接近模擬所有故障。

這個理論建立於兩個假設 the Competent Programmer Hypothesis(CPH) 和 Coupling Effect(CE)：
-   CPH(合格程序員假設)`[3][66]`：  
假設編程人員是有能力的，他們盡力去更好地開發程序，達到正確可行的結果。因此可能有程式中有錯誤，但只是一些小的語法更改修正的簡單錯誤。
並且在部分論文中也引入了 Program neighborhoods(程序鄰域)的概念`[37]` 
-   CE(耦合效應)`[66]`：  
[66]提出後， Offutt 進行了擴展 Coupling Effect Hypothesis， Mutation Coupling Effect Hypothesis`[174][175]`。
    -   Coupling Effect Hypothesis：測試數據集可以檢測到由簡單錯誤，同時也能隱含地檢測更複雜的錯誤。
    -   Mutation Coupling Effect Hypothesis: 因此複雜突變體與簡單突變體之間也存在著耦合關係。
    
因此傳統 Mutation testing 中僅僅會使用簡單突變體進行測試。

> [3] A.T. Acree, T.A. Budd, R.A. DeMillo, R.J. Lipton, and F.G. Sayward, “Mutation Analysis,” Technical Report GIT-ICS-79/08, Georgia Inst. of Technology, 1979.

> [66] R.A. DeMillo, R.J. Lipton, and F.G. Sayward, “Hints on Test Data Selection: Help for the Practicing Programmer,” Computer, vol. 11, no. 4, pp. 34-41, Apr. 1978.

關於 CEH 的有效性已經有很多研究驗證[145], [164], [174], [175]。其中證明了從一階突變體生成的測試及對於 kth oredr 的突變體同樣能有效指出錯誤 (k = 2; ... ; 4)，
能殺死一階突變體的有效數據同樣也能殺死 99% 以上的二、三階突變體。[242], [243], [244], 提出了一個簡單的理論模型 `the q function model`，將程式視為一組有限函數。
將測試集用於一階與二階模型，存活比例分別為 $\frac{1}{n}$ 和 $\frac{1}{n^2}$ n 是階數。[125]中可以找到關於 the boolean logic faults 的耦合效應的正式證明。

> [125] K. Kapoor, “Formal Analysis of Coupling Hypothesis for Logical Faults,” Innovations in Systems and Software Eng., vol. 2, no. 2, pp. 80-87, July 2006.

##### 2.2 The Process of Mutation Analysis

**Fig. 2.** 是突變分析的傳統流程圖，將原始程式進行單一的語法改變，產生有缺陷的程式 P'，稱作 The mutant(突變體)，如 Table. 2. 僅將 `&&` 改變為 `||`。
這種轉換規則稱作 mutation operator(突變運算符)，典型的突變運算符用於替換、插入或刪除運算符來修改變數和表達式。 Table. 3. 是 Fortran 的第一套正式突變運算符，
在 **Mothra mutation system** 上被實現。

![](/image/2023/05-20-analysis_mutation_testing/3.png){:height="100%" width="100%"}

<div style="display: flex; flex-direction: row;">
    <img src="/image/2023/05-20-analysis_mutation_testing/4.png" alt="Image 1" width="50%" height="50%">
    <img src="/image/2023/05-20-analysis_mutation_testing/5.png" alt="Image 2" width="50%" height="50%">
</div>

[123] 使用了一種腳本語言 *Mutation Operator Constraint Script (MOCS)*，提供兩種類型的約束:
1.  Direct Substitution Constraint: 允許用戶選擇特定的轉換規則來執行簡單的變更，如將一種運算符轉換為另一種。
2.  Environmental Condition Constraint: 指定適用於突變的特定環境條件，例如突變操作只在特定的作業系統下生效。

[217] 提出一種轉換語言 *MUDEL*，用於指定突變操作符的描述，可以定義為捕捉某種程式中的語法規則進行修改。更詳細的說明可在 Offutt 等的工作中找到[177]

然後在下一步中，我們要先確保原始程式 p 能通過測試集合 T，以驗證測試集合的正確性。 T 中的每個測試用例運行 p' 與 p 的結果相同則稱為 **survived(存活)**，否則則稱為 **killed(殺死)**。

-   **killed**: 代表能夠找出 p' 的錯誤，因此也代表能找出 p 的錯誤。
-   **survived**: 無法檢測出 p' 的錯誤，代表這個測試用例也無法找出 p 的錯誤。

因此我們會希望一個測試用例能殺死盡可能多的突變體，因為這樣才代表這個測試用例是有效的能檢測出多個錯誤情況。

為了改進 T，測試者可以提供額外的輸入來殺死存活的突變體。但有些突變體是無法被殺死的，他們稱為 **Equivalent Mutants(等效突變體)**，
它們在語法上有所不同但功能等同於原始程式。自動檢測是不可能的[35]，[187]，因 program equivalence 是無法判定的，
因此這是阻礙突變測試應用的障礙之一。

關於突變分析的最終目的就是 Adequacy Score(適應性分數)，即是 Mutation Score(突變分數)，他表示輸入測試集的品質。
突變分析的目標是將分數提高到 1，表示測試集合 T 足以檢測到突變體表示的所有故障。

##### 2.3 The Problems of Mutation Analysis

阻礙突變測試成為實用測試技術的第一個問題是對測試集執行大量突變體的高計算成本。其他問題則與使用突變測試投入的人力成本有關，
如 *Human oracle problem(人類預期問題)*[247]和 *Equivalent mutants(等效突變體問題)*[35]。

-   Human oracle problem: 是指每個測試用例需要人類來驗證測試結果的問題，花費時間來檢查結果是否符合預期。
-   Equivalent mutants: 由於不可判定性，往往需要額外的人力投入。

現有的突變測試進展，雖然還未完全解決這些問題，但突變測試的過程已經可以自動化，並且運行時可以實現合理的擴展性。

### 3. Cost Reduction Techniques

傳統的 Mothra 中所有的突變體都要被考慮在內，為了使 Mutation testing 成為實用的測試技術，許多成本降低技術被提出，[191]的調查中分為三類: “do fewer”, “do faster”, “do smarter”.

在本文中將技術整理為兩類，並在 3.1 與 3.2 各自介紹:
1.  reduction of the generated mutants: 減少生成的突變體對應 “do fewer”
2.  reduction of the execution cost: 減少運算成本對應 “do faster”, “do smarter”

Fig. 3. 是已發表關於降低成本的想法的時間發展與情況  
作者整理的當下 **Selective Mutation(選擇性突變)**, **Weak Mutation(弱突變)**是最廣泛使用的成本降低技術，見論文 Fig. 4.

![](/image/2023/05-20-analysis_mutation_testing/6.png){:height="100%" width="100%"}

##### 3.1 Mutant Reduction Techniques

再不嚴重影響測試效果的情況下減少產生的突變體數量是一個熱門的研究問題。對於一組給定的突變體 M 和測試數據集 T，$MS_T(M)$ 表示 T 應用於 M 的突變分數。
突變體減少可以定義為在 M 中找到一個子集 M' 而 $MS_T(M) = MS_T(M')$。

##### 3.1.1 Mutant Sampling

突變體抽樣是一種簡單的方法，從整個集合中隨機選擇一小部分突變體，最早由[2][34]提出。首先像傳統的突變測試一樣生成可能的突變體，然後從這些突變體中隨機選擇 x% 進行分析，
其餘的則丟棄。  
在[159][248]中這種方法進行了驗證，從 10% 到 40% 之間，結果顯示 10% 與全選相比效果僅下較 16%，表明 x > 10 時，抽樣是有效的，在 [64][131] 中也得到了驗證。

除了固定抽樣率，[207]提出一種基於 **the Bayesian sequential probability ratio test(SPRT)(貝葉斯序列概率比檢驗)** 的抽樣方法，突變體是隨機選擇直到達到統計學上的合適樣本量為止，
這種方法比固定抽樣更敏感，因為他們是基於可用的測試集自我調整的。

> [207] M. Sahinoglu and E.H. Spafford, “A Bayes Sequential Statistical Procedure for Approving Software Products,” Proc. IFIP Conf. Approving Software Products, pp. 43-56, Sept. 1990.

##### 3.1.2 Mutant Clustering

突變體聚類最早在[116]提出，使用 clustering algorithms(聚類演算法)選擇一個突變體子集。先生成突變體，然後應用聚類演算法，根据可殺死的測試案例將一階突變體分類到不同的聚類中。
同一集群中的每個突變體都保證被一組類似的測試用例殺死，然後在每個集群中選擇少量的突變體用於測試，其餘的丟棄。

[116]中使用兩種聚類算法 K-means 和 Agglomerative clustering，並將結果與隨機和貪婪選擇策略做比較，結果表明聚類能選擇更少突變體並保持突變分數。後續發展可在[120]中找到，
使用了一個 domain reduction technique(領域縮減技術) 來避免執行所有的突變體。

##### <span style="color:red;">3.1.3 Selective Mutation</span>

**選擇性突變**透過減少應用的突變運算符來實現減少突變體數量。試圖找到一小部分突變運算符來產生可能突變體中的子集，而不會對測試效果產生重大損失。
最早可見於[156]提出的 “constrained mutation”，[190]隨後擴展了這個想法，稱為選擇性突變。

突變運算符生成的突變體數量各不相同，如在 Mothra 中，ASR 和 SVR 兩個運算符生成了約 30 ~ 40% 的突變體[131]。[156]建議省略這些產生大部分突變的運算子 ASR、SVR。
之後 Offutt[190] 將其擴展至四個和六個，在他們的研究中:
-   2-selective mutation: 99.99 的平均突變分數，減少 24% 的突變體。
-   4-selective mutation: 99.84 的平均突變分數，減少 41% 的突變體。
-   6-selective mutation: 88.71 的平均突變分數，減少 60% 的突變體。

> [190] A.J. Offutt, G. Rothermel, and C. Zapf, “An Experimental Evaluation of Selective Mutation,” Proc. 15th Int’l Conf. Software Eng., pp. 100-107, May 1993.

[248][252]則基於測試效果的選擇，被稱為 **constraint mutation(約束性突變)**，僅採用兩個操作符進行突變 ABS、RAR 因為殺死 ABS 需要 input domain(輸入域)的不同部分測試用例，
而殺死 RAR 需要檢查 mutated predicate(突變謂詞)的測試用例。結果表明可以將突變體數量減少 80%，而僅對突變分數減少 5%。

> [252] W.E. Wong and A.P. Mathur, “Reducing the Cost of Mutation Testing: An Empirical Study,” J. Systems and Software, vol. 31, no. 3, pp. 185-196, Dec. 1995.

[182] Offutt等人以此進一步擴展了它們的 6-selective mutation，將 Mothra 運算符分為三類：statements, operands, expressions 之後依次省略每一類的運算符，
最後發現來自 operands, expressions 兩類的 ABS, UOI, LCR, AOR, ROR 這些關鍵的運算符取得了 99.5 的變異分數。

基於之前的經驗，Barbosa 等人[19]定義了一個選擇足夠操作符的指南，它們將這個指南應用於 Proteum 的 77 個 C mutation operators [6]，得到一組 10 個選定的突變操作符，
其平均突變分數為 99.6% 並且減少了 65.02% 的突變體。 並與 Offutt 和 Wong 做比較得到最高的突變分數。

> [19] E.F. Barbosa, J.C. Maldonado, and A.M.R. Vincenzi, “Toward the Determination of Sufficient Mutant Operators for C,” Software Testing, 
Verification, and Reliability, vol. 11, no. 2, pp. 113-136, May 2001.

而最新研究是 Namin 和 Anderws 進行[168][169][170]，將選擇性突變問題定義為統計問題，使用線性統計從 109 個 C mutation operators 中識別出 28 個操作符的子集，
目前他們減少了 92% 的突變體，是論文(2011)當下最高的減少率。

##### 3.1.4 Higher Order Mutation

高階突變由 Jia 和 Harman (2008)提出[122]，基本動機是尋找那些罕見但有價值的高階突變，**first order mutants (FOMs)** 和 **higher order mutants (HOMs)**，
HOMs 是通過多次應用突變操作符來生成的。

使用了 subsuming HOMs 的概念，一個 subsuming HOMs 比建構她的 FOMs 更難被殺死。因此使用單一的 HOM 來取代 FOM 以減少突變體的數量。
除此之外他們還使用了 strongly subsuming HOM(SSHOM) 的概念，他只被能夠殺死構成他的 FOM 的測試用例的交集的子集才能夠殺死他。

Polo等人[199]部分證明了這個想法，他們提出了不同的算法將一階段組合成二階突變。應用二階突變可以減少 50% 的測試工作量，而測試效果幾乎沒有損失。
Langdon等人[136][137]應用 *multi-object genetic programming(多目標遺傳編程方法)* 生成高階突變體，
他們發現了比任何一階突變體更難殺死的 *realistic higher order mutants(現實高階突變體)*。

-   multi-object genetic programming(MOGP):  
一種進化計算技術，結合 Genetic Programming(遺傳編程)，Multi-Objective Optimization(多目標優化)的概念與方法。 
-   realistic higher order mutants:  
這些高階突變體可以更好地模擬真實世界中的軟件錯誤，並提供更有挑戰性和現實性的測試用例。

##### 3.2 Execution Cost Reduction Techniques

本節介紹三種優化執行過程的技術類型

##### 3.2.1 Strong, Weak, and Firm Mutation

根據分析突變體在執行過程中是否被殺死的方式，突變測試技術可分為三種類型:  
**Strong(強突變)**、**Weak(弱突變)**和 **Frim(穩固突變)**

強突變通常被稱為傳統的突變測試。最初由DeMillo等人提出[66]。對於給定的程序 p，如果突變體 m 與原始程序 p 的輸出不同，則認為突變體 m 被殺死。

> ##### NOTE
> Last edit 05-26-2023 20:52  
> 本篇論文先閱讀完基本的突變測試，之後再來補齊
{: .block-warning }



