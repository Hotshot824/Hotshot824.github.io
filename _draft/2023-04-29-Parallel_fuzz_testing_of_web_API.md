---
title: "Study | A Study on Parallel Fuzz Testing of Web API using Multiple Fuzzing Tools"
author: Benson Hsu
date: 2023-04-29
category: Jekyll
layout: post
tags: [software, software_qualitiy, fuzz_testing]
---

> Study note to:  
> Pang-Ni Chien, (2022) A Study on Parallel Fuzz Testing of Web API using Multiple Fuzzing Tools, NTUT  
> 2023-0505 Lab Meeting, 閱讀論文已了解 Web API 如何使用模糊測試(Fuzz Testing) 與相關研究
{: .block-tip }

模糊測試是近年常用的測試技術，其核心概念是產生大量隨機的數據輸入程式以監控軟體是否有設計漏洞或引發錯誤的特定輸入值。在 Web 開發上可以使用 OpenAPI 規範描述的 Web API 文件來產生測試案例。
本研究分析三個不同的 Web API 模糊測試工具，以併行的方式執行三種測試工具。

### Intorduction



> ##### Note
> Last edit 29-04-2023 19:44
{: .block-danger }