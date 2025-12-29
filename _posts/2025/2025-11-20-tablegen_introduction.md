---
title: "LLVM | TableGen Introduction"
author: Benson Hsu
date: 2025-11-20
category: Jekyll
layout: post
tags: [llvm, tablegen]
---

> TableGen 是一個 DSL (Domain-Specific Language)，廣泛用於 LLVM 的編譯器開發中。
{: .block-tip }

-   TableGen 使用類似於 C++ 的語法，描述資料、資料結構
-   用於自動化產生減少重複性高的程式碼
    -   例如：Register definitions、Instruction definitions、Intrinsic definitions...
-   TableGen 檔案通常以 .td 為副檔名

目前 llvm-project 中包含的 tablegen 有四種：
-   `llvm-tblgen`
    -   在 LLVM Codegen 中用於描述 Target
-   `lldb-tblgen`
-   `clang-tblgen`
-   `mlir-tblgen`
    -   用於描述 MLIR Dialects

TableGen 通常輸出 .inc 後綴的 C++ 檔案。並且 TableGen 本身也是前後端分離的結構設計。

> 後端不同 Target 盡管有不同 Register, Instruction 等定義，但演算法上大同小異
{: .block-tip }

### 1.1 TableGen Language Basics

> TableGen 的型別類似於 C++，但並不完全相同
{: .block-warning }

**class**

class 是用於定義資料結構的 fields，也可以進行 Inheritance，Override。
透過 def 來實例化 class，let 用於設定 field 的值。

```
class Stuff {
    string Name;
    int Quantity;
    string Description;
}

def water_bottle : Stuff {
    let Name = "Water Bottle";
    let Quantity = 1;
    let Description = "A bottle of water.";
}
```

例如 CPU0 Target 的 Register，透過 `llvm-tblgen Cpu0Other.td -I ${LLVM_SRC_DIR}/llvm/include -print-enums -class=Register` 可以把 CPU0 中所有的 Register 都列印出來。

```bash
# LLVM_SRC_DIR point to the root of llvm-project
$ llvm-tblgen Cpu0Other.td -I ${LLVM_SRC_DIR}/llvm/include -print-enums -class=Register
A0, A1, AT, EPC, FP, GP, LR, PC, S0, S1, SP, SW, T0, T1, T9, V0, V1, ZERO, 
```

**let ... in**

> let ... in 用於在區塊中定義變數，並且只在該區塊內有效
{: .block-tip }

```
// Without let ... in
def R0 : Cpu0GPRReg<0, "r0"> { let Namespace = "Cpu0"; }
def R1 : Cpu0GPRReg<1, "r1"> { let Namespace = "Cpu0"; }
def R2 : Cpu0GPRReg<2, "r2"> { let Namespace = "Cpu0"; }

// With let ... in
let Namespace = "Cpu0" in {
  def R0 : Cpu0GPRReg<0, "r0">;
  def R1 : Cpu0GPRReg<1, "r1">;
  def R2 : Cpu0GPRReg<2, "r2">;
}
```

如果不使用 let ... in，必須在每個 def 中重複設定 Namespace，
使用 let ... in 可以讓程式碼更簡潔。

**types**

TableGen 支援以下 Primitive Types：
-   bit
    -   Single bit value (0 or 1)
    -   bit truebit = 1;
-   bits<N>
    -   N-bit wide value
    -   bits<8> byteValue = 0xFF;
    -   bits<16> Enc = 16; // Enc = 0x0010
-   int
    -   Integer value
-   string
    -   String value
-   code
    -   Code fragment
    -   let ParserMethod = [{...}];
-   dag
    -   Directed Acyclic Graph
    -   Used for pattern matching in instruction selection
    -   dag (add R1, R2)

Composite Types：
-   list<type>
    -   List of elements of specified type
    -   list<int> RegList = [1, 2, 3, 4];

>  更多 TableGen Language Basics 可以參考官方文件: [1.4 Types]

[1.4 Types]: https://llvm.org/docs/TableGen/ProgRef.html#types

**multiclass with defm**

> multiclass 可以用來定義一組相關的 class，並且可以透過 defm 來實例化多個物件
{: .block-tip }

> [1.6.5 multiclass — define multiple records]

[1.6.5 multiclass — define multiple records]: https://llvm.org/docs/TableGen/ProgRef.html#multiclass-define-multiple-records

例如同時要定義 rr, ri 兩種 format 的 instruction，可以使用 multiclass 來定義共用的部分。

```
def ops;
def GPR;
def Imm;
class inst <int opc, string asmstr, dag operandlist>;

multiclass ri_inst <int opc, string asmstr> {
  def _rr : inst<opc, !strconcat(asmstr, " $dst, $src1, $src2"),
                   (ops GPR:$dst, GPR:$src1, GPR:$src2)>;
  def _ri : inst<opc, !strconcat(asmstr, " $dst, $src1, $src2"),
                   (ops GPR:$dst, GPR:$src1, Imm:$src2)>;
}

// Define records for each instruction in the RR and RI formats.
defm ADD : ri_inst<0b111, "add">;
defm SUB : ri_inst<0b101, "sub">;
defm MUL : ri_inst<0b100, "mul">;
```

如果不使用 multiclass，必須分別定義 rr 與 ri 兩種 format 的 instruction，
然後重複 def 相同的部分。

```
def ops;
def GPR;
def Imm;
class inst <int opc, string asmstr, dag operandlist>;

class rrinst <int opc, string asmstr>
  : inst<opc, !strconcat(asmstr, " $dst, $src1, $src2"),
           (ops GPR:$dst, GPR:$src1, GPR:$src2)>;

class riinst <int opc, string asmstr>
  : inst<opc, !strconcat(asmstr, " $dst, $src1, $src2"),
           (ops GPR:$dst, GPR:$src1, Imm:$src2)>;

// Define records for each instruction in the RR and RI formats.
def ADD_rr : rrinst<0b111, "add">;
def ADD_ri : riinst<0b111, "add">;
def SUB_rr : rrinst<0b101, "sub">;
def SUB_ri : riinst<0b101, "sub">;
def MUL_rr : rrinst<0b100, "mul">;
def MUL_ri : riinst<0b100, "mul">;
```

---

### 1.2 bang (!) operator

> Bang Operator 都是在編譯期執行的，在最終的 .inc 中不會看到相關的程式碼
{: .block-tip }

Bang Operator 是 TableGen 中提供的 **編譯期運算 (Compile-time operation)**，
因為 TableGen 是在編譯期執行的，所以無法使用一般程式語言的運算符號。
可以用來進行條件判斷、數值計算、字串處理與 list 操作等。

```
BangOperator ::=  one of
                  !add         !and         !cast         !con         !dag
                  !div         !empty       !eq           !exists      !filter
                  !find        !foldl       !foreach      !ge          !getdagarg
                  !getdagname  !getdagop    !getdagopname !gt          !head
                  !if          !initialized !instances    !interleave  !isa
                  !le          !listconcat  !listflatten  !listremove  !listsplat
                  !logtwo      !lt          !match        !mul         !ne
                  !not         !or          !range        !repr        !setdagarg
                  !setdagname  !setdagop    !setdagopname !shl         !size
                  !sra         !srl         !strconcat    !sub         !subst
                  !substr      !tail        !tolower      !toupper     !xor
```

> 完整的 Bang Operator 列表可以參考官方文件: [1.3.3 Bang operators], [1.10 Appendix A: Bang Operators]

[1.3.3 Bang operators]: https://llvm.org/docs/TableGen/ProgRef.html#bang-operators

[1.10 Appendix A: Bang Operators]: https://llvm.org/docs/TableGen/ProgRef.html#appendix-a-bang-operators

### 1.3 TableGen File Structure

> 同樣的 TableGen 通常是由多個 .td 檔案組成，一般來說會有一個主要入口將其他檔案 include 進來
{: .block-tip }

在 TableGen 中，可以使用 `include` 指令來包含其他 TableGen 檔案，但只需要在主要檔案入口 include，
其他檔案中不需要重複 include。LLVM 中對於 target-independent interfaces 的定義在 `llvm/include/llvm/` 目錄下。在定義 backend 時會使用這些 interfaces 來實作 target-specific 的內容。

```bash
~/llvm/test/llvm/include/llvm/Target$ ls
CGPassBuilderOption.h  GenericOpcodes.td  TargetCallingConv.td     TargetIntrinsicInfo.h  TargetLoweringObjectFile.h  TargetOptions.h       TargetSchedule.td      Target.td
CodeGenCWrappers.h     GlobalISel         TargetInstrPredicate.td  TargetItinerary.td     TargetMachine.h             TargetPfmCounters.td  TargetSelectionDAG.td
~/llvm/test/llvm/include/llvm/Target$ 
```

> ##### Last Edit
> 更多詳細的 TableGen 後端開發可以參考這份投影片 [How to write a TableGen backend]，與官方文件，
> 到目前為止應該足夠去閱讀 CPU0 Target 的 TableGen 檔案了
> 11-20-2025 23:42
{: .block-warning }

[How to write a TableGen backend]: https://llvm.org/devmtg/2021-11/slides/2021-how-to-write-a-tablegen-backend.pdf