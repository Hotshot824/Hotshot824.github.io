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

### Noun, Concept definition

[4.1 Task](./2023-10-19-cpu_scheduler.html#41-task)  
[4.2 Scheduler Types](./2023-10-19-cpu_scheduler.html#42-scheduler-types)  
[4.3 Cooperative multitasking - Novell-Netware](./2023-10-19-cpu_scheduler.html#43-cooperative-multitasking---novell-netware)  
[4.4 Preemptable OS](./2023-10-19-cpu_scheduler.html#44-preemptable-os)  
[4.5 Scheduler & Context switch](./2023-10-19-cpu_scheduler.html#45-scheduler--context-switch)  
[4.6 Scheduling Criteria](./2023-10-19-cpu_scheduler.html#46-scheduling-criteria)  

##### 4.1 Task

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
-   OS 可以分成兩大類:
    -   **[Cooperative multitasking]**(Non-preemptive, 協同運作式多工)
    -   **[Preemptable OS]**(Preemptive, 搶占式多任務處理)

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-19-cpu_scheduler/1.png?raw=true){:height="100%" width="100%"}

##### 4.2 Scheduler Types

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-19-cpu_scheduler/2.png?raw=true){:height="100%" width="100%"}

-   **Non-preemptive OS**(△): 就是指只有 Task 自己放棄 CPU 使用權，才會交出 CPU 使用權
    1.  Task 執行結束，這樣當然就交出 CPU 使用權
    2.  Task 發出 Blocking I/O request 因為要等待 I/O 完成，因此也會交出 CPU 使用權
        -   當然也有 Async I/O，Vectored I/O 等方法，這裡先不討論
-   **Preemptive OS**(☐△):
    1.  每個 Task 會有一個 Time slice 執行，例如: 1/1000 Sec，執行結束就要做切換
    2.  從 Wating 等待完畢 I/O 後，返回 Runtable 時要不要馬上切回該 Task 
    3.  新的 Task 也可以給予高優先權，讓他馬上執行
    -   Preemptive OS 又分為:
        -   **Preemptable Kernel**, **Non-preemptable Kernel**

##### 4.3 Cooperative multitasking - Novell-Netware

[Netware]:  
-   Netware 所有的程式都在 ring 0 執行，但是這樣就要確保所有的程式都是由 Novell 來控制，
這樣才能確保所有的程式都是可信任的，沒有惡意程式
-   但是當 CPU 效能變強之後，這樣的設計就不太好，因為所有的程式都要由 Novell 來提供，這不太可能，因此最後由 Windows NT 勝出

##### 4.4 Preemptable OS

**Preemptive OS:**
-   如果一個 Task 執行過久，OS 會主動將 CPU 控制權交給下一個 Task
-   如果要設計 Preemptive OS 必須要有 Hardware support，例如: Timer, Interrupt
    -   Timer: 用來計算 Task 執行的時間
    -   Interrupt: 使 OS 能獲得 CPU 控制權
-   所有版本的 Linux 都是 Preemptive OS

**Preemptive Kernel**

-   Non-preemptive Kernel(throughput):
    -   在 2.6 Kernel 之前，Linux 是 Non-preemptable Kernel
    -   當 Task 執行在 Kernel mode 時，其優先權無限大
        -   Context switch 只會發生在 Task 由 Kernel mode 切換到 User mode 時
-   Preemptive Kernel(latency):
    -   在 2.6 Kernel 之後，Linux 可以設定為 Preemptable Kernel
    -   當 Task 執行在 Kernel mode 時如果沒有任何的 Lock 就可能發生 Context switch

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-19-cpu_scheduler/3.png?raw=true){:height="100%" width="100%"}

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-19-cpu_scheduler/4.png?raw=true){:height="100%" width="100%"}

> 注意如果在 Kernel 中發生 Interrupt，下次 Task A 執行時會直接從 Kernel mode 中繼續執行，
> 因此在 2.6 Kernel 後編譯時可以選擇 Kernel 注重 throughput 還是 latency，
{: .block-tip }

**Form Non-preemprive kernel to Preemprive kernel**

-   在 Non-Preemprive kernel 中，所有進入 Kernel 的 Task 可以假設自己不會被 Preempt，因此存取很多共用資料，不需要使用 Lock
-   在 Preemprive kernel 中，程式設計師需要仔細思考、改寫程式碼，所有存取到共用資料的程式碼都需要使用 Lock-UnLock 來保護
    -   這是一件非常耗費人力的工作

##### 4.5 Scheduler & Context switch

-   **Scheduler** 決定接下來要執行哪一個 Task
    -   使用 C language 撰寫
-   **Context switch** 
    -   負責從一個 Task 切換到另一個 Task
    -   主要切換的是普通 Register
    -   如果 Task 使用到一些特別的 Register，例如: 浮點數運算器(Floating Point Unit, FPU)，則需要額外處理(Lazy)
        -   Lazy: 只有新的 Task 需要使用到 FPU 時，才會切換 FPU 相關的 Register
    -   Context switch 隱含的切換
        -   依照需求切換 Page Table(TLB)
        -   切換 Cache 的內容

##### 4.6 Scheduling Criteria

這裡介紹如何分析一個 Scheduler 的好壞

-   **CPU Utilization**(使用率): CPU 維持在高使用率，Task 之間互相有等待的關係，要如何 Schedule?
-   **Throughput**(吞吐量): 在單位時間內，CPU 可以執行多少 Task
    -   例如: 讓 I/O Task 優先執行
-   **Turnaround time**(往返時間): Task 從開始到結束的時間，與 Scheduler 及程式本身的執行程度相關
-   **Waiting time**(等待時間): Task 在 Ready Queue 中等待的時間，通常高優先權的 Task 會等待較短的時間
    -   只要一個 Task 能執行，但 OS 使其等待就要算入 Waiting time
-   **Response time**(回應時間): Task 從發出 Request 到第一次回應的時間
    -   例如: 程式需要輸出回應到螢幕，好的 Scheduler 可以讓 Progress bar 非常即時的反應

**CPU Utilization**

實際的 CPU 使用率會受到 Task 的高低優先權影響，因此 CPU 使用率會有兩種情況:

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-19-cpu_scheduler/5.png?raw=true){:height="100%" width="100%"}

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-19-cpu_scheduler/6.png?raw=true){:height="100%" width="100%"}

> 可以透過軟體的方式對 Lock-Unlock 做最佳化，例如: Intel vtune, kernelshark 之類的視覺化工具

**Response time**

假如系統中有 10 個 Task，這 10 個 Task 連接到 10 個 User，如果要讓執行感覺流暢的話，有以下做法:

1.  單向互動:
    -   假如 Task 是播放影片，那就安排適當的 Buffer，解碼後的影片放入 Buffer 供 User task 拿取
    -   只要 Buffer 夠大，即使每 10 秒才輪到一次執行，使用者也不會覺得 Lag
2.  雙向互動:
    -   假如 Task 是語音通話，必須在 150ms 中輪到執行一次，否則會覺得通話品質不好
    -   那每個 Task 一回合只能執行 15ms

---

### Scheduler Concepts

##### 4.7 Simple Scheduler

-   **FCFS(Fisrt Come First Serve)**
    -   依照 Task 的抵達順序，依照順序執行
-   **SJF(Shortest Job First)**
    -   依照 Task 的執行時間，執行時間短的 Task 優先執行
-   **RR(Round Robin)**
    -   在一群 Task 中輪流執行，每一個 Task 最多執行 X 個 Time slice

> 在 Linux 中可以看到上面三種方法的影子

**FCFS**

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-19-cpu_scheduler/7.png?raw=true){:height="100%" width="100%"}

-   Wating time: P1 = 0, P2 = 100, P3 = 150
-   Average waiting time: (0 + 100 + 150) / 3 = 83.3
-   如果先抵達的 Task 執行時間很長，Average waiting time 就會變得比較長

**SJF**

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-19-cpu_scheduler/8.png?raw=true){:height="100%" width="100%"}

-   在 P1 執行中，P2、P3 抵達，放入 Ready Queue，然後依照執行時間排序
-   Wating time: P1 = 0, P2 = 110, P3 = 100
-   Average waiting time: (0 + 110 + 100) / 3 = 70

**Preemptive SJF**

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-19-cpu_scheduler/9.png?raw=true){:height="100%" width="100%"}

-   只要有工作進入 Ready Queue，或有工作結束就要決定執行的 Task
-   Wating time: P1 = 60, P2 = 10, P3 = 0
-   Average waiting time: (60 + 10 + 0) / 3 = 23.3

> 直觀上會覺得 Preemptive SJF 是比較好的演算法，但注意 Preemptive SJF 有 Context switch overhead

-   如果只是寫 SJF 通常指 Non-preemptive SJF
-   Preemptive SJF 又稱作 SRTF(Shortest Remaining Time First)
-   在 Average waiting time 方面，SJF & SRTF 分別是 Preemptable scheduling & Non-preemptable scheduling 的最佳演算法

**Estimate Execution Time**

前面提到的 Scheduler 都是假設 Task 的執行時間是已知的，但實際上 Task 的執行時間是不知道的，因此需要估計 Task 的執行時間

-   一個 Task 的生命週期分為兩種情況
    -   Using CPU, Waiting
-   依照 Task 以前使用 CPU 使用時間的多寡，來預測這次使用 CPU 時間的多寡，例如以下公式
    -   t<sub>n</sub>: 上一次的 CPU time
    -   𝜏<sub>x</sub>: 預測的第 x 次的 CPU time
    -   Linux Kernel 2.4 使用以下的方法，並且 𝛼 取 1/2 因為可以避免浮點數運算
        -   t<sub>n+1</sub> = 𝛼 * t<sub>n</sub> + (1 - 𝛼) * 𝜏<sub>n</sub>
        -   𝛼 是一個權重因子界於 0 ~ 1 之間
            -   越靠近 1，表示越重視過去的 CPU time
            -   越靠近 0，表示越重視預測的 CPU time

**Round Robin**

如果使用 RR 那麼 Time slice 要設定為多少?
-   太長: 會讓 Task 等待的時間變長
-   太短: 會讓 Context switch overhead 變大
-   通常 Time slice 會設定為一個 Task 可以在 Time slice 內執行完畢，變成 Waiting 狀態
    -   也就是在 Time slice 中成功把 I/O request 發出去

> 目前 Linux 的設定為使用者需要多少的 Time slice，可以動態的調整 Time slice 的大小
{: .block-warning }

### Linux Scheduler

-   Linux 共有 140 個優先權等級
    -   0 ~ 99: Real-time priority
        -   通常是一些需要 Real-time 的 Task，例如: 影片播放，聲音播放
    -   100 ~ 139: Normal priority
        -   對使用者而言是 -20 ~ +19，預設值為 0，稱作 Nice value
-   Nice value 是由 User 指定，Linux 當作參考用以計算 Dynamic priority，Dynamic priority 會因以下因素影響:
    -   該 Task 是 I/O bound 還是 CPU bound
    -   考慮 Core 的特性
    -   考慮 Multi-thread 的特性

> 使用者在啟動 Task 時可以指定 Nice value，或在 Task 執行時使用 renice 指令來調整 Nice value

##### 4.8 Linux 2.4 Scheduler

1.  在 2.4 Scheduler 中如何對 I/O 進行優化
2.  思考在 2.4 在 Multi-processor 的環境下欠缺什麼?

-   Non-preemptible kernel
    -   Set p->need_resched if schedule() should be invoked at the 'next opportunity'(kernel -> user mode).
    -   所以一個正在 Kernel 中運行的 Task 要進行 Context switch 時就會將 need_resched 設為 1
-   Round-Robin
    -   task_struct->counter: number of clock ticks left to run in this scheduling slice, decremented by a timer.
    -   這是一個 Task 執行的 counter，每個 time tick 就 -1，用完了就不能在這個回合內使用 CPU

**2.4 Scheduler - SMP:**

當有 CPU 進入 Idle 時，2.4 Scheduler 會從 Ready Queue 中 Search & Estimate，找出最佳的 Task 來執行
-   Search: 會依照這個 Task 對這個 CPU 有多適合

<div style="display: flex; justify-content: center;">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-19-cpu_scheduler/10.png?raw=true" 
    width="50%" height="50%">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-19-cpu_scheduler/11.png?raw=true" 
    width="50%" height="50%">
</div>

**2.4 Scheduler - Run-Queue:**

在 2.4 中所有人都是使用同一個 Run-Queue:
1.  Use spin_lock_irq() to lock "runqueue_lock"
    -   因為 2.4 Scheduler 僅有一個 Run-Queue，要在運算時 Lock 然後運算完 Unlock，自然會造成效能瓶頸
2.  Check if a task is "runnable"
    -   in TASK_RUNNING state
    -   in TASK_INTERRUPTIBLE state and a signal is pending
3.  Examine the "goodness" of each process
    -   檢查所有 Task 的 Goodness，並且選出最好的 Task
4.  Context switch

**2.4 Scheduler - Goodness:**

-   "goodness": identifying the best candidate among all processes in the runqueue list.
-   "goodness" = 0: the entity has exhausted its quantum.
-   0 < "goodness" < 1000: the entity is a conventional process/thread that has not exhausted its quantum; a higher value denotes a higher level of goodness.

```
if (p->mm == prev->mm)
return p->counter + p->priority + 1;
else
return p->counter + p->priority;
```

A small bonus is given to the task p if it shares the address space with the previous task.

Examine the processor field of the processes and gives a consistent bonus (that is PROC_CHANGE_PENALTY, usually 15) 
to the process that was last executed on the ‘this_cpu’ CPU.

例如: 一個 Multi-thread 程式的 Task，如果有一個 Thread 執行在一個 CPU 上，那麼其他的 Thread 就會有一個加分，讓他們可以在同一個 CPU 上執行。
同樣的如果一個 Process 最後是在這 this_cpu 上運行，那麼他在這顆 CPU 上計算分數時也會有獎勵加分。

> 2.4 Scheduler 的問題是 Scheduler 要對所有的 Task 計算 goodness，每次都要重算。但其實大多數時間每次計算出的 goodness 都是差不多的，
> 真的有需要每次都重算嗎?
{: .block-danger }

##### 4.8 Linux 2.4 Scheduler - Improve I/O performance

Defintion:
-   I/O-bound processes: spends much of its time submitting and waiting on I/O requests 
-   Processor-bound processes: spend much of their time executing code

Linux 傾向於支援 I/O-bound processes，這樣會提供好的 Process response time，但是怎麼對 Process 進行分類?

-   將 **Run time** 分為無數個 **epoch**
-   當沒有 task 可以執行時就換到下一個 epoch
    -   此時可能有些 task 的 **time slice** 還沒用完，但這些 task 正在 waiting
    -   2.4 Scheduler 假設所有的 waiting 就是在 **waiting I/O**
-   進入下一個 epoch 的時候，補充所有 task 的 time slice
    -   如果是 I/O-bound task，因為在上一個 epoch 在 waiting I/O，還有一些 time slice 沒用完，
    因此補充後這些 task 會有較多的 time slice
-   在 Linux 2.4 中，time slice 就是 dynamic priority
    -   因此 I/O-bound task 會有較高的 dynamic priority

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-19-cpu_scheduler/9.png?raw=true){:height="100%" width="100%"}

從上面的圖來看:
-   Epoch1: CPU bound 都已經用完 time slice，此時剩下 I/O bound slice，必須進入下一個 epoch 否則會進入 idle
-   Epoch2: 使用 timeSlice<sub>new</sub> = timeSlice<sub>old</sub> / 2 + baseTimeSlicep[nice] 的公式來補充 time slice
-   依照這樣的運算 Epoch2 的 I/O bound task 一定會比 CPU bound 有更高的 Priority

> 注意 Kernel 中不會使用 FPU，因此不會有 float point

**Cauclate time Slice**

timeSlice<sub>new</sub> = timeSlice<sub>old</sub> / 2 + baseTimeSlicep[nice]

為什麼要除以 2，假如有一個惡意的程式如下:

```c
int main() {
    sleep(65535);
    while(1)
        ;
}
```

每次拿到 CPU time 就去 sleep，因此在 sleep 中會被視為一個 I/O bound task，因此拿到很高的 time slice，
這樣醒來時就是一個 CPU bound task 同時也有很高的 time slice，可以搶佔 CPU 造成其他的 I/O bound task 也無法獲取 CPU time。

**Main disadvantages of 2.4 Scheduler**

-   計算 goodness 太耗費時間，就算某個 Task goodness 一直沒變，每次還是要重新計算
-   所有 CPU 共用同一個 Run queue，這個 Run queue 會變成系統的效能瓶頸，因為每次都要 Lock & Unlock
-   Wating 不一定是 I/O，例如: sleep()
    -   在 2.4 Scheduler 中只針對 I/O 做提高優先權
    -   例如 waiting child process 也是一種 waiting，也可以被考慮在內

##### 4.9 Linux 2.6 Scheduler

-   O(1) Scheduler
-   CFS(Complete Fair Scheduler)

**2.6 Scheduler Architecture**

2.6 Scheduler 首先在架構的改善就是使每一顆 CPU 有自己的 Run queue
-   即使這樣 CPU 要去 Run queue 拿資料時也要做 Lock & Unlock
-   因為是 Lock 自己的 Run queue，因此 Lock & Unlock 通常都會成功，不會有競爭的情況發生

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-19-cpu_scheduler/13.png?raw=true){:height="100%" width="100%"}

當自己有自己的 Run queue 後要考慮的就是 Load balancing(負載平衡)
-   系統去檢查 Run queue 是否 Loading 過重，如果是就會將 Task 搬移到另一個 Run queue
-   因此才需要 Lock & Unlock，是為了避免 CPU 在搬移 Task 時出現錯誤
    -   Put: 當 CPU 覺得自己的 loading 太重，將 task 塞給另一顆 CPU
    -   Pull: 覺得自己的 loading 太輕，從別的 CPU 拉 task 過來
-   如何評估 Loading 輕重
    -   比較簡單的方式，查看每個 CPU 的 Task 數量跟 runnable task 數量

每一顆 CPU 上都會有一個 thread 來觀察是否要做 Load balancing，這個 thread 稱作 Balance thread

> 但假如 A, B 兩顆 CPU 同時要搬移 Task 要給予對方，同時鎖定對方的 Run queue，就會造成互相等待，造成 Deadlock，這部分後面會說明
{: .block-warning }

**CPU Affinity**

-   由於每一顆 CPU 都有自己的 Run queue，通常除非 Loading unbalance，否則不會去觸發 Task migration
    -   因此 2.6 Scheduler 可以更有效的使用 Cache

**Fully Preemptible Kernel**

2.6 Kernel 之後，Linux 中每一個 Task 執行於 Kernel mode 時會有一個變數 `preempt_count`，用於記錄該 Task 是否可以被 Preempt
-   每當 Lock 一個 Resource 時，`preempt_count++`
-   每當 Unlock 一個 Resource 時，`preempt_count--`
-   如果 `preempt_count == 0`，Kernel 可以做 Context switch
    -   Kernel 要做 Context switch 通常是因為 interrupt，例如: 一個高優先權的 task 正在等這個 interrupt
    -   每次 `preempt_count` 從 1 變為 0，Kernel 都會檢查一下是否要 Context switch
-   如果 Kernel 直接執行 schedule()，無論 `preempt_count` 是多少，都會做 Context switch

> schedule() 是在 Linux kernel 中的重要函數，會直接進行 scheduler 調度，並且切換到下一個 Task 執行

> 延伸閱讀: [Linux kernel: schedule() function]

##### O(1) & CFS scheduler

-   2.5 ~ 2.6.22: **O(1) Scheduler**
    -   Time complexity: O(1)
    -   Using Run queue(an active Q and an expired Q) to realize the ready queue
-   2.6.23 ~ : **CFS Scheduler**
    -   Time complexity: O(log N)
    -   the ready queue is implemented as a red-black tree


> ##### Last Edit
> 10-18-2023 23:21
{: .block-warning }

[Cooperative multitasking]: https://en.wikipedia.org/wiki/Cooperative_multitasking
[Preemptable OS]: https://en.wikipedia.org/wiki/Preemption_%28computing%29

[Netware]: https://en.wikipedia.org/wiki/NetWare

[Linux kernel: schedule() function]: https://stackoverflow.com/questions/20679228/linux-kernel-schedule-function