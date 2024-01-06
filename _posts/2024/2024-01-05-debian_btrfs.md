---
title: "Note | Debian install on Btrfs (Unfinished)"
author: Benson Hsu
date: 2024-01-05
category: Jekylls
layout: post
tags: [OS]
---

> Notes debian to install on Btrfs
{: .block-tip }

想在 debian 上安裝 Btrfs，有很多種方式，這裡紀錄一下怎麼從頭開始安裝 debian，並且使用 Btrfs 作為主要的檔案系統。

### 1. Install Debian

在安裝 Debian 的時候要進入 Advanced options，並且選擇 Expert install，這樣才能夠在安裝的時候選擇 Btrfs 作為檔案系統。
接著就跟標準的安裝方式一樣。

-   在這個過程中如果不確定的選項就直接按 Enter 就好，這樣就會使用預設的選項

<div style="display: flex; flex-direction: row; align-items: center;">
    <img src="../assets/image/2024/01-05-debian_btrfs/1.png"
    width="50%" height="50%">
    <img src="../assets/image/2024/01-05-debian_btrfs/2.png"
    width="50%" height="50%">
</div>

<br>

> 直到 Partition disks 的時候，才是這次要做的重點
{: .block-warning }

**Partition disks**

這邊要選擇 Manual，這樣才能夠自己選擇要安裝的檔案系統，並且自己分割硬碟。

-   Manual
    -   gpt: 使用 UEFI 的啟動方式
    -   msdos: 傳統的 BIOS 啟動方式

> ##### Last Edit
> 01-05-2024 16:32
{: .block-warning }