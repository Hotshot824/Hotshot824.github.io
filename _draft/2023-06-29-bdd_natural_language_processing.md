---
title: "Study | Assisted Behavior Driven Development Using Natural Language Processing"
author: Benson Hsu
date: 2023-06-23
category: Jekyll
layout: post
tags: [software, software_qualitiy, SDD]
---

> Study note to:  
> Mathias Soeken, Robert Wille & Rolf Drechsler, "Assisted Behavior Driven Development Using Natural Language Processing", 2012.

##### Abstract

在過去 BDD 中使用行為驅動開發，這是一種敏捷開發方式，使用自然語言來撰寫對於軟體開發的描述，在所有成員之間。
第一步就是將名稱以映射方式到真實的程式碼中，這通常都是用手動的方式。詳情可見 [Characteristics of BDD]。

然而這種使用規格書來撰寫的方式，往往需要建立一種結構來描述程式。在本篇論文中，我們使用一種自然語言處理技術，
來使自然語言可以用來描述開發行為，完成程式碼所需的存根，這就是 BDD 自動化的第一步。

### Introduction

歷史上 softwart testing 有一個經典的 post-processing(前處理)在瀑布式開發模型中。在程式碼開發完成後，
由 test enginerrs 撰寫測試程式。然而在 (agile software enginerrs)敏捷開發中，測試程式將會提早在開發點之前完成。
測試程式就是最終系統的一部分，測試程式會持續在開發中，直到所有測試程式完成(accepted) 即代表開發成功。



> ##### NOTE
> Last edit 29-06-2023 21:13
{: .block-warning }

[Characteristics of BDD]: https://hotshot824.github.io/jekyll/2023-05-28-characteristics_of_bdd.html
