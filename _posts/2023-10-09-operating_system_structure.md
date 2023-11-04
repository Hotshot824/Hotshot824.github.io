---
title: "OS | Operating System Structure"
author: Benson Hsu
date: 2023-10-09
category: Jekyll
layout: post
tags: [OS]
---

> Operating System: Design and Implementation course notes from CCU, lecturer Shiwu-Lo. 
{: .block-tip }

在這個章節有以下主要大綱

-   OS Service
-   Graphical User Interface & Text-based User Interface
-   System calls
-   OS Structure
-   Profiling/Debugging an OS Kernel

### OS Service

##### 2.1 Purpose of OS

一台作業系統的主要服務是使對於 User 而言 Hardware 變的更好使用，對 Designer 而言能提高系統使用率

**Simple to use**

-   Communications
    -   同一台電腦內部 Process 之間的 Communications(IPC)，例如: copy and paste
    -   跨電腦之間的通訊，例如: Network neighborhood, Network file system(NFS)
-   Error detection
    -   當軟體發生錯誤時，OS 能採取適當的措施「處理」這個錯誤，例如: 使用者光碟機沒有「收合」，提示使用者
    -   提供一般程式的除錯機制，例如: [ptrace], [core dump] ...
    -   OS Kernel 的除錯機制，例如: kgdb, kdb

> [ptrace] 是一種 System call，允許一個 Process 觀察另一個 Process，gdb 的底層就使用 ptrace 實現

-   提供使用者操作介面，例如: Gnome, KDE ...
-   載入應用程式的能力，例如: execve()
    -   多功能的作業系統，最少要能識別「執行檔」的檔案格式
    -   部分嵌入式系統 Kernel 與 User application 編譯在同一個 mage，task 即為這個 mage 中的一個 Function，
    這時候就不需要「執行檔」
-   處理 I/O 的能力，例如: 各種 Driver
-   檔案系統，例如: OS 將 Disk 上的一個 Block 抽象為 File，再將 File 抽象為 Folder，Folder 中可以放入 File

**Increase efficiency**

-   分配各種資源，例如: Memory 僅有 4GB，A 程式需要 3.2GB，B 程式需要 1.4GB，如何分配「有限」的 Memory
    -   Debian 上可以透過 `free -h`，`cat /proc/swaps` 查看 swap 使用狀況
-   統計資源的使用率，例如: 可以使用 [htop] 監視 CPU、DRAM、I/O 等效能，使用率
-   Protection，確保 Process 只能擁有 OS 所分配的資源，Process 各自獨立，不會受到非法的干擾·
-   Security，確保 User Login 後只能存取自己的資源，例如: 存取他人的家目錄

##### 2.2 User interface

**GUI**:
-   GUI 將許多命令以 Icon 的形式表示，並且大部分可以 Drag and drop(拖動)的方式
-   再輸入方式包含:
    -   滑鼠、觸控面板、觸控螢幕、多點觸控的直覺化控制

**CLI**:
-   Text-mode 雖然需要時間學習，但能很準確的下達命令
    -   也可以將命令組合成 Batch program，例如: shell script
-   Text-mode 比 GUI 更穩定
-   可以使用輕量級的 Remote connection，例如: ssh
-   Text-mode 也可以結合指標裝置(例如: 滑鼠)，也可以使用 Library(例如: ncurses) 模擬 GUI 介面(例如: Linux kernel memuconfig)

### System Call

##### 2.3 System call

System call 是 **OS Kernel** 對外開放的 API
-   注意恐龍書將 System call 定義為 OS 對外開放的 API
-   但 OS 涵蓋非常廣泛，因此 System call 應該限定於 Kernel 提供的 API

**Linux system call**

Linux 所有的 System call 可以到這個路徑去尋找 [/arch/x86/entry/syscalls/syscall_64.tbl]，或是到 Linux 的 [syscalls(2) — Linux manual page]，
前四個 System call 為: 1. read, 2. write, 3. open, 4. close

**Call System call**

-   可以透過 libc([C standard library]) 呼叫 System call
    -   例如: read, write, open, close
-   Linux 的 Man page 中，volume 2 即為 System call 的說明
    -   例如: `man 2 read`，這裡要注意是否有安裝 `sudo apt-get install manpages-dev`
-   少數 System call 並未包含在 Linux 的 libc 內，這時候需要自已寫出來

```c
#define_GNU_SOURCE /* See feature_test_macros(7) */
#include <unistd.h>
#include <sys/syscall.h> /* For SYS_xxx definitions */
long syscall(long number, ...);
```

**gettid() - libc 未實現的 System call**

在 Linux 中:
-   Process 都有一個 pit_t 可以透過 getpid() 獲得
-   POSIX Thread(pthread) 也有 pthread_t 可以透過 pthread_self() 獲得，
-   但是如果我想要 P1 的 thread2 與 P2 的 thread1 通訊，我們就需要一個真實的 Thread ID(TID)，這時候就要透過 System call 來獲得 tid，使用 `syscall(SYS_gettid)`

```c
#define_GNU_SOURCE
#include <unistd.h>
#include <sys/syscall.h>
#include <sys/types.h>
#include <signal.h>
int main(int argc, char *argv[]) {
    pid_t tid;
    /* gettid() returns ths caller's thread ID(TID). 
     There is no glibc wrapper for this system call. */
    tid = syscall(SYS_gettid);
    /* int tgkill(int tgid, int tid, int sig); send a signal to a thread. */
    syscall(SYS_tgkill, getpid(), tid, SIGHUP);
}
```

**Call System Call Method(From assembly language)**

Call System call 的方式如下(Calling convention):

| arch/ABI | syscall# | arg1 | arg2 | arg3 | arg4 | arg5 | arg6 | ret. val. |
| -------- | -------- | ---- | ---- | ---- | ---- | ---- | ---- | --------- |
| arm64 | x8 | x0 | x1 | x2 | x3 | x4 | x5 | x0 |
| x86-64 | rax | rdi | rsi | rdx | r10 | r8 | r9 | rax |

> syscall# System call 編號  
> ret. val. System call return value

Call System call 的組合語言如下:
ARM: svc #0, x86-64: syscall

```assembly
movq $60, %rax; // Call NO.60 System call, exit()
movq $2, %rdi;  // arg1 = 2, means exit(2)
syscall;        // Change to kernel mode, call System call
```

> 延伸閱讀: [The Linux Kernel Module Programming Guide: System call]

##### 2.4 Special cases of system calls

首先要討論 System call overhead 這是為什麼把某些 Module 放在 Kernel 的速度會提升許多的原因

System call 主要的 Overhead 來自於:
1.  CPU 進行 Mode change 的時候，此時 CPU 有同時數個指令在執行，切換時**或許需要 flush 所有執行到一半的指令**
2.  Kernel 需要將 User space 的所有暫存器存在 Kernel stack（每一個 Task，於 Kernel 中有自己的 Stack，注意，不是 User mode stack）
3.  檢查權限，在 System call 之前還要檢查 Task 是否有權限執行該 System call
4.  依照 Kernel 內部的 Calling convention，呼叫實現該 System call 的 Function，例如：sys_read() => do_read()

> 因為這些 Overhead 使得在 User space 執行的程式，速度會比在 Kernel space 執行的程式慢許多

**vDSO**

因此 Linux 的設計者會希望盡可能地降低 Overhead，vDSO(Virtual Dynamic Shared Object) 是可以將 Kernel space 的資訊，直接映射到 User space

-   如果該 System call 並沒有牽涉「安全性」，那就直接把 Kernel space 中的資訊寫入 User space，讓程式可以透過 Function call 的方式取得該資料
-   會時常變動，但又沒有機密性的資訊:
    1.  __vdso_clock_gettime
    2.  __vdso_getcpu
    3.  __vdso_gettimeofday
    4.  __vdso_time
-   不會變動，但也沒有機密性的資訊:
    1.  第一次呼叫時，真的產生 System call，libc 記錄下該 Function 的值
    2.  第二次呼叫時，由 libc 直接回傳，例如：getpid()

**/proc/pid/maps**
```
/*...*/
7ffe6b98e000-7ffe6b9af000 rw-p 00000000 00:00 0          	[stack]
7ffe6b9fa000-7ffe6b9fd000 r--p 00000000 00:00 0      		[vvar]
7ffe6b9fd000-7ffe6b9ff000 r-xp 00000000 00:00 0        	    [vdso]
ffffffffff600000-ffffffffff601000 r-xp 00000000 00:00 0	    [vsyscall]
```
這裡每行都由以下內容組成: address、perms、offset、dev、inode、pathname

-   vsyscall: 功能等同於 vdso，但是較為古老，並有安全性問題(No support ASLR)
-   vdso: 存放可呼叫的 vDSO Function，例如: clock_gettime()
-   vvar: 存放 Kernel space mapping 到 User space 的資料，例如: clock_gettime() 的 cur_time

> 延伸閱讀: [Understanding Linux /proc/pid/maps]，[ASLR]

**If not using vDSO**

下圖左是沒有 vDSO clock_gettime() 想要取得時間的流程，要去呼叫 timekeeping_update() 更新 cur_time，因此需要 Mode change 進入 Kernel mode。
而圖右就將這個資料結構直接映射到 User space，clock_gettime() 呼叫 timekeeping_update() 一樣會去更新 cur_time，但直接去讀 vDSO 中的資料，這樣的話速度就跟 Function call 一樣快了。

<div style="display: flex; flex-direction: row;">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-09-operating_system_structure/1.png?raw=true" 
    width="50%" height="50%">
    <img src="https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-09-operating_system_structure/2.png?raw=true" 
    width="50%" height="50%">
</div>

**vDSO Problem**

-   資料存放在 vvar 不一定就是 User 要的資料格式，例如:
    -   vvar 中放的是從開機到現在經過多少個 Machine cycles，但是 gettimeofday() 的回傳值是自 1970/1/1 至今經過多少秒，所以這裡是有座資料轉換的
    -   vDSO 內部的程式碼會做適當的資料轉換

### OS Structure

##### 2.5 Monolithic system

-   許多著名的 OS 都是 Monolithic system，例如: Linux, FreeBSD, Solaris
-   目前這些作業系統都支援動態載入 Kernel module 的功能
    -   Linux 的 lsmod 可以列出目前已經載入到 Kernel 的 module

這裡列出 Linux Kernel 中與 File system 相關的 module
```bash
$ lsmod | grep fs
autofs4                45056  2
btrfs                1294336  2
xor                    24576  1 btrfs
raid6_pq              114688  1 btrfs
libcrc32c              16384  1 btrfs
```

##### 2.6 In Linux Object

Linux 雖然是使用 C 撰寫的，但是在 Kernel 中充滿了 Object-oriented(OO) 的概念，**[Object-oriented analysis and design]**(OOAD)物件導向分析與設計

下面是一個 Linux Kernel 中常見的 OO 概念，並且使用 container_of 來取得這個 Linked list 的起始 address(Linked list head)
```c
struct parport_driver {
    const char *name;   /*property*/
    void (*attach) (struct parport *);  /*method*/
    void (*detach) (struct parport *);  /*method*/
    struct list_head list;  /*inherit list_head*/
};
struct list_head {
    struct list_head *next, *prev;
};
#define list_entry(ptr, type, member)
        container_of(ptr, type, member)
```

**container_of**

```c
/**
 * container_of - cast a member of a structure out to the containing structure
 * @ptr:        the pointer to the member.
 * @type:       the type of the container struct this is embedded in.
 * @member:     the name of the member within the struct.
 * */
#define container_of(ptr, type, member) ({              \
const typeof( ((type *)0)->member ) *__mptr = (ptr);    \
(type *)( (char *)__mptr - offsetof(type,member) );})
```

container_of 主要是透過成員來獲取該 struct 的起始位置，詳細可以看 [Linux Kernel Macro container_of] 跟延伸閱讀

> 延伸閱讀: [Linux 核心原始程式碼巨集: container_of]

> Linux kernel 雖然是使用 C 語言寫的，但在裡面充斥著 OO 的概念，當然有部分要跟底層溝通所有沒有完全 OO

##### 2.7 Layered approach

Layered approach 在 OS 的缺點是，並不一定能切出 Layer，跟 Network 不太一樣

-   將系統分成 N 層
-   第 N 層可以使用第 N-1 層的功能，不可以使用 N+1 層的功能

![](https://github.com/Hotshot824/Hotshot824.github.io/blob/master/_image/2023-10-09-operating_system_structure/3.png?raw=true){:height="100%" width="100%"}

> 例如 I/O memagement 需要 Buffer 因此需要 Memory management，Memory management 有時也需要將 Memory 寫到 Disk，因此需要 I/O management，這樣就很難分層

##### 2.8 Hardware Abstraction Layer

常見的 Andriod OS 與 Windows 架構如下:

<div style="display: flex; flex-direction: row; align-items: center;">
    <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/a/af/Android-System-Architecture.svg/2525px-Android-System-Architecture.svg.png" 
    width="50%" height="50%">
    <img src="http://www.tamos.net/ieee/nt.gif" 
    width="50%" height="50%">
</div>

<br>

**Andriod:**
-   可以看到 Libraries 被放置在中間層，是因為為了能給各家廠商商業化，而最上方是 Apach License 就是隨意給人更改的部分，
可以看到 **[Hardware Abstraction Layer]**(HAL) 被放置在中間層，照常理來說應該放在 Hardware 與 Software 之間，放在這裡或許是想要把 Kernel 有替換的的彈性。

**Windows:**
-   Windows 的 HAL 就被放置在 Kernel 與 Hardware 之間，抽象層的目標是，例如: 希望 Kernel 中沒有 Assembly，不要太跟 Device 相關。
-   Kernel 之上包含著 Virtual Memory Manager(把硬體相關的部分抽出，另外一個目錄)

> ##### Last Edit
> 10-10-2023 23:21
{: .block-warning }

[ptrace]: https://en.wikipedia.org/wiki/Ptrace
[core dump]: https://en.m.wikipedia.org/wiki/Core_dump
[htop]: https://en.m.wikipedia.org/wiki/Htop

[/arch/x86/entry/syscalls/syscall_64.tbl]: https://github.com/torvalds/linux/blob/master/arch/x86/entry/syscalls/syscall_64.tbl
[syscalls(2) — Linux manual page]: https://man7.org/linux/man-pages/man2/syscalls.2.html

[C standard library]: https://en.wikipedia.org/wiki/C_standard_library
[The Linux Kernel Module Programming Guide: System call]: https://sysprog21.github.io/lkmpg/#system-calls

[Understanding Linux /proc/pid/maps]: https://stackoverflow.com/questions/1401359/understanding-linux-proc-pid-maps-or-proc-self-maps
[ASLR]: https://en.wikipedia.org/wiki/Address_space_layout_randomization

[Object-oriented analysis and design]: https://en.wikipedia.org/wiki/Object-oriented_analysis_and_design
[Linux 核心原始程式碼巨集: container_of]: https://hackmd.io/@sysprog/linux-macro-containerof

[Linux Kernel Macro container_of]: ./2023-10-17-container_of.html

[Hardware Abstraction Layer]: https://en.wikipedia.org/wiki/Hardware_abstraction