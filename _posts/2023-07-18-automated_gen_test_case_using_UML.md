---
title: "Paper | Automated-generating test case using UML statechart diagrams (Unfinished)"
author: Benson Hsu
date: 2023-07-18
category: Jekyll
layout: post
tags: [software, software_qualitiy, generate_test_case, UML]
---

> Supaporn Kansomkeat, Wanchai Rivepiboon, "Automated-generating test case using UML statechart diagrams",
> SAICSIT '03: Proceedings of the 2003 annual research conference of the South African institute of computer scientists and information 
> technologists on Enablement through technology, September 2003, Pages 296–300.
> 本篇論文提出一種測試用例產生器基於 UML 狀態圖自動產生 Testing Case 的方法。
{: .block-tip }

1.  作者將 UML 轉為一個中間圖，稱作 TFG(Testing Flow Graph)，TFG 會明確識別 UML 狀態圖的流程，並針對測試的目的來進行增強。
2.  從 TGF 中使用**測試標準(Testing Criteria)**來生成測試用例，包括覆蓋了 UML 圖中的狀態(State) 與轉換(Transition)。
3.  最後使用**突變分析(Mutation Analysis)**來評估生成測試用例的錯誤揭示能力。

### 1. Introduction

**Specification-based testing(基於規格的測試)**

是從規格中獲取的信息來幫助測試和開發軟體。測試活動包含:
1.  設計測試用例(Testing Case)，這些測試用例是一系列的輸入。
2.  執行測試用例和檢查執行結果
測試在開發過程的早期進行，開發人員通常會在規格中找到不一致和模糊之處，進而改進規格，然後再進行程式編寫。

**Unified Modeling Language, UML(統一建模語言)**

> BOOCH, G., RUMBAUGH, J., AND JACOBSON, I. 1998. The Unified Modeling Language User Guide. Object Technology Series. Addison Weysley Longman, Inc

是一種可視覺化建模語言，包含九種圖形。目前有許多研究專注於從 UML 規格中生成測試用例，詳細可見論文中 Reference，本論文提出一種從 UML 狀態圖中自動生成的測試用例。

> ##### NOTE
> Last edit 07-19-2023 23:02
{: .block-warning }