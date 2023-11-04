---
title: "OS | CPU Scheduler (Unfinished)"
author: Benson Hsu
date: 2023-10-19
category: Jekyll
layout: post
tags: [OS]
---

> Operating System: Design and Implementation course notes from CCU, lecturer Shiwu-Lo. 
{: .block-tip }

本章節會主要介紹 Linux Scheduler，Linux Scheduler 現在的的目標是: 如何從「好變為更好」

-   Noun, Concept definition
-   2.4 Scheduler
-   2.6 O(1) Scheduler
-   2.6 - 5.3 Complete fair scheduler(CFS)

> Linux Kernel 2.4 是一個非常長壽的版本，持續了大約 10 年左右，但即便這樣一個這麼長壽、穩定的 Scheduler，
> Linux Kernel 設計者仍然在考慮如何讓她變得更好。

### 4.1 Noun, Concept definition

##### 4.1.1 Task

-   在 Linux 中，Process 和 Thread 都是 Task
-   Process 之間不會共用任何資源，**尤其是 Memory**
-   Thread 則是幾乎共用所有資源，**尤其是 Memory**
-   Task 的生命週期中分為兩種情況
    -   Using CPU
    -   Waiting，例如: Waiting mutex, I/O ...
-   Task 在使用 CPU 時分為: 執行於 User mode/Kernel mode

> 在 Linux Task 可以執行在 User/Kernel mode，改變模式稱作 Mode change，而 Kernel Thread 專指只有 Kernel mode 的 Task，例如: Device Driver
{: .block-tip }

**Task & Scheduling**

以下是一個 Task 的生命週期，這裡從 Scheduler 角度來看的話主要影響的是兩個部分:
-   Waining(semaphore): 怎麼在 Waiting 時，讓 Task 的使用率最大化
-   **[Cooperative multitasking]**(協同運作式多工), **[Preemptable OS]**(搶占式多任務處理)

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-19-cpu_scheduler/1.png?raw=true){:height="100%" width="100%"}

##### 4.1.2 Scheduler Types

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-19-cpu_scheduler/2.png?raw=true){:height="100%" width="100%"}

-   **Preemptive OS**: 
    -   Task 會有一個 Time slice 執行，例如: 1/1000 Sec，執行結束就要做切換
    -   
-   **Non-preemptive OS**: 就是指只有 Task 自己放棄 CPU 使用權時，才會做 Context Switch
    -   Task 執行結束，這樣當然就交出 CPU 使用權
    -   Task 發出 Blocking I/O request 因為要等待 I/O 完成，因此也會交出 CPU 使用權
        -   當然也有 Async I/O，Vectored I/O 等方法，這裡先不討論

> ##### Last Edit
> 10-18-2023 23:21
{: .block-warning }

[Cooperative multitasking]: https://en.wikipedia.org/wiki/Cooperative_multitasking
[Preemptable OS]: https://en.wikipedia.org/wiki/Preemption_%28computing%29