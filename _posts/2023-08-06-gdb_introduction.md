---
title: "Note | GNU Debugger Quick Notes"
author: Benson Hsu
date: 2023-08-06
category: Jekyll
layout: post
tags: [software, tool]
---

> 記錄如何使用 GDB 進行開發與除錯，以前都是用直覺、測試的方式來進行除錯，也很少用 debug mode 不是一件好事也很沒效率，
> 藉此建立 Debug 的好習慣。「實際上在我職涯中 95% 的 Bug 都能透過 debug mode 解掉」－PTT鄉民
{: .block-tip }

-   **Reference**: 
    -   [GDB: The GNU Project Debugger], [GDB User Manual]
    -   [jasonblog: 通過 GDB 學習 C 語言]
    -   [Jserv: 你所不知道的 C 語言: 開發工具和規格標準]

### 1. GNU Debugger(GDB) Introduction

GDB 是 GUN 系統下的標準除錯工具，使我們能查看程式在運行中內部發生了什麼，或是崩潰時正在做什麼。
此外 GDB 經過移攜需求的調修與重新編譯，現在許多的 UNIX Like 系統上都可以使用 GDB。

GDB 最主要的四項功能有:
-   Start your program, specifying anything that might affect its behavior.
-   Make your program stop on specified conditions.
-   Examine what has happened, when your program has stopped.
-   Change things in your program, so you can experiment with correcting the effects of one bug and go on to learn about another.

GDB 目前所能支援的語言:
-   Ada
-   Assembly
-   C
-   C++
-   D
-   Fortran
-   Go
-   Objective-C
-   OpenCL
-   Modula-2
-   Pascal
-   Rust

### 2. Using GDB to development

[2.1 Debuging Program](./2023-08-06-gdb_introduction.html#21-debuging-program)  
[2.2 Setting Breakpoints](./2023-08-06-gdb_introduction.html#22-setting-breakpoints)  
[2.3 Check status](./2023-08-06-gdb_introduction.html#23-check-status)    

>「一旦你已經習慣於在 REPL 環境下進行探索性的編程，必須進行「編寫-編譯-運行」這樣循環實在有點令人生厭。」—[jasonblog: 通過 GDB 學習 C 語言]

REPL(Read-Eval-Print Loop) 環境可以讓我們方便的了解當下在做什麼，如果透過類似 REPL 的方式來進行對需要編譯後運行的程式進行開發、
追蹤代碼、除錯都非常有幫助。

**2.1 Debuging Program**

使用 GDB 就需要 debugging information 給 GDB 使用，這裡 gcc 要帶入參數 `-g`，[gcc Option for Debugging]，
然後就可以啟動 gdb 進行 debug，之後輸入 `run` 指令就可以運行程式。如果程式需要帶入參數的話，
就直接在 run 後面加入參數就好。

> -g  
> Produce debugging information in the operating system’s native format (stabs, COFF, XCOFF, or DWARF). 
> GDB can work with this debugging information.

```bash
gcc -g main.c -o main
gdb main
# Reading symbols from main...
(gdb) run
# Program output.
(gdb) run ${argv}
# Program output.
```

如果想對已經運行中的程式進行 Debug 就要使用 `attach`，並且要知道該 Process pid，
但注意對運行中的程式進行 Debug 有可能干擾正在運行的程式，有更多的細節可以查看 [Debugging an Already-running Process]。

```bash
ps -ef | grep ${program_name}
gbd ${pid}
```

##### 2.2 Setting Breakpoints

使用 `info breakpoints` 可以查看已經設置的中斷點，與中斷點的 Type, Address, What。中斷點有多種形式，
這裡主要講幾種常用的中斷點，更多內容可以看 [Setting Breakpoints]:

**Breakpoint and Continue** 使用 `break` 或 `b` 設置，可以設置在目標的行數或是函數名稱，
當然如果遇到斷點後想要繼續程式，使用 `continue` 就可以了:
```bash
# set breakpoint at line 23
(gdb) break main.c:23
# set breakpoint at function main
(gdb) break main
```

**Breakpoint with condition**

也可以設定當條件出現時才會中斷，例如懷疑是程式中出現非期望的值，就可以在這裡設置斷點觀察。並且也可以透過 `condition` 修改斷點的條件。
```bash
(gdb) break test.c:23 if b==0
# if this break point number is 1, change condition.
(gdb) condition 1 b==1
```

**Breakpoint with rule**

依照規則來設定斷點，例如函數名稱，檔案，等等...
```bash
# break all function
(gdb) rbreak . 
# break all prefix is printNum* function
(gdb) rbreak printNum*
# break all function in test.c
(gdb) rbreak test.c:.
# break all function in test and prefix is print
(gdb) rbreak test.c:^print
```

**Skip breakpoints multiple times**

我們也可以設置跳過某的斷點幾次，例如一個函數前 10 次都沒出現問題要跳過前 30 次的中段，之後可以透過 info breakpoints 看到設置。
```bash
(gbd) ignore 1 30
```

**Watchpoint**

觀察點是設置當某個變數或類型產生變化時進行觀察，有 `wathc`, `rwatch`, `awatch`，

```bash
# break if a changes
(gbd) watch a
# break when a is read
(gbd) rwatch a
# break when a is write
(gbd) awatch a
```

**Clean and disable/enable breakpoint**

Disable/Enable
```bash
# disable all point
(gbd) disable
(gbd) disable ${break_num}
# enable all point
(gbd) enable
(gbd) enable ${break_num}
(gbd) enable delete ${break_num}
```
Clear/Delete
```bash
# clean all point
clear
clear ${function_name}
clear ${file_name}:${function_name}
clear ${line}
clear ${file_name}:${line}
# delete all point
delete
delete ${break_num}
```

##### 2.3 Check status

在 GDB 中有多種查看變數、記憶體區塊、記憶體內容的方法，這裡我們可以使用 print 印出變數的內容。
```bash
(gdb) print 1 + 1
# $1 = 2
# $1 is a temp variable, only live in this debug session.
```

例如如果有以下程式，然後去設置中斷點觀察變數。
```c
int main()
{
    int x = 10;
    return 0;
}
```
```bash
(gdb) break main
(gdb) run
(gdb) print x
# $1 = 0
(gdb) next
(gdb) print x
# $2 = 10
(gdb) set x = 20
(gdb) print x
# $3 = 20
```

查看變數在記憶體的地址，區塊大小，記憶體內容，在 GDB 中一個數字的低位元在前高位元在後，所以要從左往右讀，
x 是從一個位置開始讀取 Memory，4b 代表 4 byte。
```bash
(gdb) print &x
# $4 = (int *) 0x7fffffffe37c
(gdb) print sizeof(x)
# $5 = 4
(gdb) print sizeof(double)
# $6 = 8 
```

查看記憶體的內容，格式為 `x/[n][f][u] addr`，其中 n 為顯示的單元數，f 是要顯示的格式，u 是單元長度。
```bash
(gdb) x/4xb &x
# 0x7fffffffe37c: 0x6f    0x00    0x00    0x00
(gdb) set x = 0x12345678
(gdb) x/4xb &x
# 0x7fffffffe37c: 0x78    0x56    0x34    0x12
(gdb) x/4tb &x
# 0x7fffffffe37c: 01111000        01010110        00110100        00010010
```

可以用 `ptype` 來檢查給定變數或類型的詳細類型定義。
```bash
(gdb) ptype x
# type = int
(gdb) ptype &x
# type = int *
(gdb) ptype main
# type = int (void)
```

> ##### Note
> 以上大概就是常會用到的主要指令，還有更多細節可以看 GDB 手冊，[GDB User Manual]。
{: .block-warning }

[GDB: The GNU Project Debugger]: https://www.sourceware.org/gdb/
[GDB User Manual]: https://sourceware.org/gdb/current/onlinedocs/gdb.html/
[Jserv: 你所不知道的 C 語言: 開發工具和規格標準]: https://hackmd.io/@sysprog/c-standards#GDB
[jasonblog: 通過 GDB 學習 C 語言]: https://jasonblog.github.io/note/gdb/tongguo_gdb_xue_xi_c_yu_yan.html
[GDB 入門]: https://zhuanlan.zhihu.com/p/74897601

[gcc Option for Debugging]: https://gcc.gnu.org/onlinedocs/gcc/Debugging-Options.html
[Debugging an Already-running Process]:https://sourceware.org/gdb/onlinedocs/gdb/Attach.html
[Setting Breakpoints]: https://sourceware.org/gdb/onlinedocs/gdb/Set-Breaks.html#Set-Breaks