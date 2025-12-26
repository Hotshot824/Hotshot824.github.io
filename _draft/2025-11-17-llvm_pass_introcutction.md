---
title: "LLVM | IR Level Optimization Introduction"
author: Benson Hsu
date: 2025-11-17
category: Jekyll
layout: post
tags: [llvm, optimization]
---

> 介紹 LLVM IR 層級的 Optimization，在這個階段的輸出都還是 LLVM IR，同時與機器無關，因此這些優化可以跨平台使用。
{: .block-tip }

首先在這個階段最重要的資料結構是 CFG（Control Flow Graph）與 