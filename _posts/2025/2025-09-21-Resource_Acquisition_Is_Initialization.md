---
title: "C++ | Resource Acquisition Is Initialization (RAII)"
author: Benson Hsu
date: 2025-09-21
category: Jekyll
layout: post
tags: [C++, RAII]
---

> 在 C++ 中開發者需要自己設計記憶體資源的管理機制，但是往往無法保證所有資源都被正常釋放，因此導致 Memory Leak。RAII 是一種 Design Pattern，可以確保資源在不需要時自動釋放，避免記憶體洩漏問題。
{: .block-tip }

### 1.1 What is RAII

> [RAII] in cppreference.com

[RAII]: https://en.cppreference.com/w/cpp/language/raii.html

Resource Acquisition Is Initialization 中文是 **資源取得即初始化**，聽起來很抽象，其實本質上是由 C++ 的物件生命週期所衍生出來的設計模式。RAII 的核心概念是將資源的取得和釋放綁定在物件的生命週期中，當物件被建立時，資源被取得；當物件被銷毀時，資源被釋放。

> 直白一點就是一個資源的取得要在 Constructor 裡面完成，而釋放則是在 Destructor 裡面完成
{: .block-warning }

> 在 Stack 上生命週期的管理是自動的，而在 Heap 上生命週期的管理則需要開發者手動管理。RAII 的設計也可以說是將 Heap 上的綁定在 Stack 上，讓資源的管理變得自動化。
{: .block-tip }

```cpp
std::mutex m;
 
void bad() 
{
    m.lock();               // acquire the mutex
    f();                    // if f() throws an exception, the mutex is never released
    if (!everything_ok())
        return;             // early return, the mutex is never released
    m.unlock();             // if bad() reaches this statement, the mutex is released
}
 
void good()
{
    std::lock_guard<std::mutex> lk(m); // RAII class: mutex acquisition is initialization
    f();                               // if f() throws an exception, the mutex is released
    if (!everything_ok())
        return;                        // early return, the mutex is released
}                                      // if good() returns normally, the mutex is released
```

在 bad() 函數中，如果 f() 拋出 Exception 或者提前 return，mutex 永遠不會被釋放，導致死鎖。在接下來的程式中 m 會一直被鎖定，無法再被其他執行緒使用。而 good() 函數中使用了 std::lock_guard 這個 RAII 類別來管理 mutex 的生命週期，確保如果 good() 結束時，std::lock_guard 物件將會進入 Destructor，因此自動釋放 mutex。

---

### 1.2 Stack Unwinding

> When an exception is thrown and control passes from a try block to a handler, the C++ runtime calls destructors for all automatic objects constructed since the beginning of the try block. This process is called [Stack Unwinding].
{: .block-tip }

> [Throwing exceptions] in cppreference.com

[Stack Unwinding]: https://www.ibm.com/docs/en/i/7.4.0?topic=only-stack-unwinding-c

[Throwing exceptions]: https://en.cppreference.com/w/cpp/language/throw.html

這個機制的過程是由於 C++ 嚴格遵守 Object Lifetime 規範以及 Stack Unwinding 機制所導致的。當 Exception 被拋出時，C++ 會自動呼叫所有在 try block 中建立的物件的 Destructor，這個過程稱為 Stack Unwinding。

當一個函數因為以下原因離開 Scope 時：
1.  執行到函數結尾
2.  執行到 return 返回
3.  發生 Exception 被拋出、並開始 Exception Progagation

所有位於 Stack 上的未見都會依照建立的**反向順序**被銷毀，呼叫 Destructor。

> Exception Progagation: 如果 Function 本身沒有處理 Exception，就會沿著 Call Stack 向上傳遞直到被處理

---

### 1.3 Constructor & Destructor

因此 RAII 的實現關鍵在於 Constructor 和 Destructor 的設計。當物件被建立時，Constructor 負責取得資源；當物件被銷毀時，Destructor 負責釋放資源。這樣我們在編寫 C++ 程式時需要注意一些壞習慣，例如在 Constructor 之外取得資源，或者在 Destructor 之外釋放資源，這樣都會破壞 RAII 的原則，導致資源無法被正確管理。

注意以下四點新手常犯的錯誤：

**1.**  在 Class attribute 直接取得資源
    -   盡量在 Constructor 裡面取得資源，保持 Code Style 一致性

```cpp
class Bad {
    FILE* file = fopen("data.txt", "r"); // bad: resource acquisition outside
}
```

**2.**  使用 raw pointer 管理資源
    -   使用 smart pointer 來管理動態記憶體，避免記憶體洩漏
    -   raw pointer 並無法表達 ownership 的概念，因此指向的資源有可能無法被正確釋放

```cpp
class Bad {
    int* p = new int(42);
};

class Good {
    std::unique_ptr<int> p = std::make_unique<int>(42);
};
```

**3.**  在 Destructor 裡面手動寫大量 Cleanup Code
    -   A well-designed destructor should usually be empty.
    -   將 Cleanup Code 包裝在專門的 RAII 類別中，讓 Destructor 只負責呼叫這些類別的 Destructor
    -   降低維護成本，否則 Destructor 會變得非常複雜

```cpp
class Bad {
    FILE* f;
    int* buf;
    Mutex* m;
public:
    ~Bad() {
        if (f) fclose(f);
        if (buf) delete[] buf;
        if (m) m->unlock();
    }
};

class Good {
    std::ifstream file;
    std::vector<int> buf;
    std::lock_guard<std::mutex> lock;
};
```

**4.**  重複包裝 RAII 類別
    -   避免不必要的包裝，直接使用標準庫提供的 RAII 類別
    -   延後或者提前釋放由 Smart Pointer 來負責管理

```cpp
class Bad {
    std::vector<int>* v;
public:
    Bad() { v = new std::vector<int>(); }
    ~Bad() { delete v; }
};

class Good {
    std::vector<int> v;
};

class Good {
    // Use smart pointer because dynamic lifetime is needed.
    std::unique_ptr<std::vector<int>> v;
};
```

---

### 1.4 Smart Pointer

Smart Pointer 是 C++11 正式被標準化引入語言核心的，在此之前期待 new / delete 的管理方式非常容易出錯。
在下面的範例中，任何 do_something() 內部發生的 Exception 都會導致 delete ptr 永遠不會被呼叫，造成 Memory Leak。

```cpp
ResourceType* ptr = new ResourceType(); // acquire resource

ptr->do_something();

delete ptr; // release resource
```

**std::unique_ptr** 是一種 Smart Pointer，當 unique_ptr 被銷毀時會自動去將指向的資源釋放掉，避免記憶體洩漏問題。而現代 C++ 更推薦使用 **std::make_unique** 來建立 unique_ptr，這樣可以避免在 new 過程中發生 Exception 時導致的資源洩漏問題。

> std::make_unique 是 C++14 引入的 std::unique_ptr 的 factor method，推薦使用它來建立 unique_ptr

```cpp
void function() {
    std::unique_ptr<MyObject> ptr{new MyObject()};
    ptr->do_something();
}

void function() {
    auto ptr = std::make_unique<MyObject>();
    ptr->do_something();
}
```

要注意的是 smart pointer 應該要存在於 Stack 上才能確保，當它離開 Scope 時會自動呼叫 Destructor 釋放資源。如果 smart pointer 本身存在於 Heap 上，那就失去了 RAII 的意義。這樣的話使用的是 unique_ptr 來管理另一個 unique_ptr，反而增加了複雜度。

```cpp
void bad() {
    // bad: unique_ptr itself is allocated on the heap
    auto ptr = new std::unique_ptr<MyObject>(new MyObject());
    ptr->get()->do_something();
}
```

### 1.5 Common Smart Pointer Types

接下來接紹 C++ 中常見的 smart pointer 類型:

**1.5.1 std::unique_ptr\<T\>**

-   Unuque Owner 獨佔擁有權的指標，只能有一個 unique_ptr 指向同一個資源
-   不可以被複製 (copy)，只能被移動 (move)
-   預設首選的 smart pointer 類型

```cpp
std::unique_ptr<Foo> p1 = std::make_unique<Foo>();
std::unique_ptr<Foo> p2 = std::move(p1); // ownership transfer
```

**1.5.2 std::shared_ptr\<T\>**

-   Shared Ownership 將共享擁有權的指標，可以有多個 shared_ptr 指向同一個資源
-   使用 reference counting 來追蹤有多少個 shared_ptr 指向同一個資源
-   當最後一個 shared_ptr 被銷毀時，資源才會被釋放

```cpp
std::shared_ptr<Foo> p1 = std::make_shared<Foo>();
std::shared_ptr<Foo> p2 = p1; // shared ownership
```

> 有額外的效能開銷 atomic reference count，並且使用上要注意循環參考 (circular reference) 問題
{: .block-warning }

如果 A 指向 B，B 也指向 A，這樣兩個物件都無法被釋放，導致記憶體洩漏。可以使用 std::weak_ptr 來解決這個問題。在下面的範例中，A 持有 B 的 shared_ptr，而 B 持有 A 的 shared_ptr，這樣就會導致循環參考問題。

即使 a, b 都被銷毀，但是 A, B 依然持有對方的 shared_ptr，導致記憶體無法被釋放。同時 A, B 存在於 Heap 上，無法利用 Stack Unwinding 來自動釋放資源。

```cpp
auto a = std::make_shared<A>(); 
auto b = std::make_shared<B>(); 
a->b = b; // make A hold B
b->a = a; // make B hold A (causes circular reference)
```

![](/image/2025/09-21-Resource_Acquisition_Is_Initialization/1.png)

**1.5.3 std::weak_ptr\<T\>**

-   需要解決 **std::shared_ptr** 的循環參考問題，因此引入了 weak_ptr
-   weak_ptr 不擁有資源的所有權，不會影響 reference count

```cpp
struct A {
    std::shared_ptr<B> b;
};

struct B {
    std::weak_ptr<A> a; // use weak_ptr to break circular reference
};
```

-   需要透過 lock() 方法轉換成 shared_ptr 才能擁有資源的存取權
    -   因為 weak_ptr 不擁有資源的所有權，資源可能已經被釋放

```cpp
std::weak_ptr<Foo> wp = ...;
if (auto sp = wp.lock()) { // try to get a shared_ptr
    sp->do_something();
} else {
    // resource has been released
}
```

最後總結一下三種常見的 smart pointer 類型及其適用場景：

| Smart Pointer Type      | Ownership Model       | Use Case                                      |
|------------------------|-----------------------|-----------------------------------------------|
| std::unique_ptr<T>     | Unique Ownership      | Default choice for exclusive ownership         |
| std::shared_ptr<T>     | Shared Ownership      | When multiple owners are needed                     |
| std::weak_ptr<T>       | Non-owning Reference  | To break circular references in shared ownership scenarios |

---

**C-Style Array with Smart Pointer**

要注意在 C++ 中對於 Array 的最佳實踐是使用 container class (e.g., std::vector) 來管理動態陣列，而不是使用 raw pointer 或 smart pointer 來管理 C-Style Array。

例如 C API 固定為 T** 才不得已使用 smart pointer 來管理 C-Style Array：

```c
std::unique_ptr<T[]> data = std::make_unique<T[]>(rows * cols);
std::unique_ptr<T*[]> rows_ptr = std::make_unique<T*[]>(rows);
for (size_t i = 0; i < rows; ++i) {
    rows_ptr[i] = data.get() + i * cols;
}
c_api_function(rows_ptr.get());
```

這樣至少確保 data 和 rows_ptr 都會在離開 Scope 時自動釋放，避免記憶體洩漏問題。

> ##### Last Edit
> 11-12-2025 01:50
{: .block-warning }