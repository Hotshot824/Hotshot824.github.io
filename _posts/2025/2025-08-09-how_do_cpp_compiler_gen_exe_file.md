---
title: "C++ | How C++ Compiler Generates Executable File"
author: Benson Hsu
date: 2025-08-09
category: Jekyll
layout: post
tags: [c++, compiler, executable]
---

> 這篇文章的目的是系統性的整理一下 C++ 編譯器將原始碼轉換成可執行檔的過程，雖然學 CS 的學生大多都應該清楚這個過程，但這裡可以做一個系統性的整理。
{: .block-tip }

### 1.1 Translation Units

在 C++ 中是以 Translation Unit 為單位來進行編譯的，一個 Translation Unit 是由一個原始碼檔案（.cpp）以及它所包含的所有標頭檔案（.h）所組成的。每個 Translation Unit 都會被獨立編譯成目標檔案（.o 或 .obj）。

-   Translation Unit 由 .cpp 檔案及其包含的 .h 檔案組成
-   每個 Translation Unit 獨立編譯成目標檔案
    -   在此期間 Trnaslation Unit 並不知道其他 Trnaslation Unit 的存在
    -   只能透過 .h 來得知其他 Trnaslation Unit 的 Signature

> 總結就是一個 .c/.cpp 檔案及其包含的所有 .h 檔案會被視為一個整體來進行編譯，這個整體就稱為 Translation Unit。
{: .block-tip }

> 而跨檔案的函數呼叫則透過 .h 來進行 Signature 的宣告，讓編譯器知道該函數的存在及其參數與回傳值型別。
{: .block-tip }

![](/image/2025/08-09-how_do_cpp_compiler_gen_exe_file/1.png)

> 上圖展示了一個編譯過程中不同階段的概覽，從原始碼到最終的可執行檔案，每個階段都有其特定的任務與輸出。

---

### 1.2 Preprocessing

Preprocessing 是編譯過程中的第一個階段，主要負責處理原始碼中的預處理指令（以 `#` 開頭的指令），例如 `#include`、`#define`、`#ifdef` 等。Preprocessing 的階段並不會有 Syntax analysis / Semantic analysis，而是單純地將這些指令以 Text Substitution 的方式來處理。

這裡我們觀察一個簡單的 C++ 專案結構：

**add.h**
```cpp
#ifndef ADD_H
#define ADD_H

// object-like macro
#define DEFAULT_VALUE 10

// function-like macro
#define ADD_MACRO(a, b) ((a) + (b))

int add(int a, int b);

#endif // ADD_H
```

**add.cpp**
```cpp
#include "add.h"

int add(int a, int b) {
    return ADD_MACRO(a, b) + DEFAULT_VALUE;
}
```

**main.cpp**
```cpp
#include "add.h"

int main() {
    return add(3, 4);
}
```

使用 `clang++ -E -I. main.cpp -o main.i && clang++ -E -I. add.cpp -o add.i` 可以看到 Preprocessing 後的結果：

**add.i**
```cpp
# 1 "add.cpp"
# 1 "<built-in>" 1
# 1 "<built-in>" 3
# 468 "<built-in>" 3
# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "add.cpp" 2
# 1 "./add.h" 1
# 10 "./add.h"
int add(int a, int b);
# 2 "add.cpp" 2

int add(int a, int b) {
    return ((a) + (b)) + 10;
}
```

-   Macro Expansion：所有的 Macro 都會被展開成對應的內容
    -   原本的 `ADD_MACRO(a, b)` 被展開成 `((a) + (b))`
-   Define Substitution：所有的定義都會被替換成對應的值
    -   原本的 `DEFAULT_VALUE` 被替換成 `10`

**main.i**
```cpp
# 1 "main.cpp"
# 1 "<built-in>" 1
# 1 "<built-in>" 3
# 468 "<built-in>" 3
# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "main.cpp" 2
# 1 "./add.h" 1
# 10 "./add.h"
int add(int a, int b);
# 2 "main.cpp" 2

int main() {
    return add(3, 4);
}
```

-   `# 1 "./add.h" 1` 
    -   表示從 `add.h` 開始包含
-   `# 10 "./add.h"` 
    -   表示目前處理到 `add.h` 的第 10 行

> 這些數字是用來追蹤原始碼位置的，方便在後續的編譯階段中進行錯誤報告與調試，這邊就不多介紹這些數字的 flag 代表什麼意義
{: .block-tip }

---

### 1.3 Compilation, Assembly, and Linking

> 接下來就是 Compilation、Assembly、Linking 三個階段，這三個階段會將 Preprocessing 後的程式碼轉換成最終的可執行檔案。
{: .block-tip }

> 這裡不會詳細去講編譯器的內部運作原理，主要簡單介紹流程，重點放在 .o 之後的連結階段

-   Compilation：將 Preprocessing 後的程式碼轉換成中間表示（IR），並進行優化
-   Assembly：將中間表示轉換成目標機器碼，並產生目標檔案（.o 或 .obj）
-   Linking：將多個目標檔案連結成最終的可執行檔案

**Relocatable Object File (.o/.obj)**

在這個階段程式碼已經是 Assembly code 轉換成的機器碼了，但還不是最終的可執行檔案，因為這些目標檔案中可能還包含未定義的符號（例如函數呼叫），這些符號需要在 Linking 階段被解析。

我們用 `clang++ -S -O0 --target=riscv64 main.cpp -o main.s && clang++ -c --target=riscv64 add.cpp -o add.o` 來觀察 asmembly code 的內容：

**main.s**
```riscv
    .text
    ...
main:
    ...
    li   a0, 3      // first argument
    li   a1, 4      // second argument    
    call _Z3addii   // call add(int, int)
    ...
    ret
```

**add.s**
```riscv
    .text
    ...
_Z3addii:
    ...
	lw	a0, -20(s0)         // load first argument
	lw	a1, -24(s0)         // load second argument
addw	a0, a0, a1          // perform addition
	addiw	a0, a0, 10      // add DEFAULT_VALUE
    ...
    ret
```

這裡可以看到 `main.s` 與 `add.s` 中的函數呼叫與定義，參數傳遞會透過 ABI 規範來進行，而 `call _Z3addii` 則是呼叫 `add(int, int)` 函數。

> ABI（Application Binary Interface）定義了 ISA（Instruction Set Architecture）之上的函數呼叫約定、資料型別大小與對齊方式等規範，確保不同編譯器產生的程式碼能夠互相呼叫與操作資料。
{: .block-tip }

這裡繼續觀察 `main.o` 使用 `clang -target riscv64-linux-gnu -c main.s -o main.o` 轉換為 obj 檔案。然後使用 `llvm-objdump -d main.o` 來觀察目標檔案的內容：

```md
main.o: file format elf64-littleriscv

Disassembly of section .text:

0000000000000000 <main>:
      ...
       e: 450d          li      a0, 0x3
      10: 4591          li      a1, 0x4
      12: 00000097      auipc   ra, 0x0
      16: 000080e7      jalr    ra <main+0x12>
      ...
```

在相對地址 e ~ 16 可以看到與 asmembly code 相對應的機器碼，而 _Z3addii 則是未定義的符號，所以使用 `00000097 auipc ra, 0x0` 與 `000080e7 jalr ra <main+0x12>` 來進行跳轉。

> 在這裡 main 中還沒有 add 的實際地址，所以會使用相對地址來進行跳轉，這個地址會在 Linking 階段被解析。
{: .block-tip }

> 實際的地址要在 ELF relocation table 中進行解析，這個表格會告訴 Linker 如何將未定義的符號替換成實際的地址。
{: .block-tip }

**Executable File (.exe/.out)**

最後一步我們把 `main.o` 與 `add.o` 連結成最終的可執行檔案，使用 `clang++ -target riscv64-linux-gnu main.o add.o -o main.out` 來進行連結。然後使用 `llvm-objdump -d main.out` 來觀察最終的可執行檔案內容：

```md
0000000000011194 <main>:
   11194: 1101          addi    sp, sp, -0x20
   11196: ec06          sd      ra, 0x18(sp)
   11198: e822          sd      s0, 0x10(sp)
   1119a: 1000          addi    s0, sp, 0x20
   1119c: 4501          li      a0, 0x0
   1119e: fea42623      sw      a0, -0x14(s0)
   111a2: 450d          li      a0, 0x3
   111a4: 4591          li      a1, 0x4
   111a6: 00c000ef      jal     0x111b2 <_Z3addii>
   111aa: 60e2          ld      ra, 0x18(sp)
   111ac: 6442          ld      s0, 0x10(sp)
   111ae: 6105          addi    sp, sp, 0x20
   111b0: 8082          ret

00000000000111b2 <_Z3addii>:
   111b2: 1101          addi    sp, sp, -0x20
   111b4: ec06          sd      ra, 0x18(sp)
   111b6: e822          sd      s0, 0x10(sp)
   111b8: 1000          addi    s0, sp, 0x20
   111ba: fea42623      sw      a0, -0x14(s0)
   111be: feb42423      sw      a1, -0x18(s0)
   111c2: fec42503      lw      a0, -0x14(s0)
   111c6: fe842583      lw      a1, -0x18(s0)
   111ca: 9d2d          addw    a0, a0, a1
   111cc: 2529          addiw   a0, a0, 0xa
   111ce: 60e2          ld      ra, 0x18(sp)
   111d0: 6442          ld      s0, 0x10(sp)
   111d2: 6105          addi    sp, sp, 0x20
   111d4: 8082          ret
```

-   在最終的可執行檔案中，`main` 與 `_Z3addii` 都有了實際的地址
-   `jal 0x111b2 <_Z3addii>` 現在指向了 `_Z3addii` 的實際地址 `0x111b2`

> 不要把這個地址誤會成記憶體中的絕對地址，這只是 ELF 檔案中的一個偏移量，實際載入到記憶體中的地址會根據作業系統的載入機制有所不同。
{: .block-warning }

以上就說明了 C++ 編譯器將原始碼轉換成可執行檔案的整個過程，從 Preprocessing、Compilation、Assembly 到 Linking，每個階段都有其特定的任務與輸出，最終產生的可執行檔案可以在目標平台上運行。

> ##### Last Edit
> 10-02-2025 01:50
{: .block-warning }