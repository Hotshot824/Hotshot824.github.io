---
title: "Pattern | Fluent Interface"
author: Benson Hsu
date: 2025-03-21
category: Jekyll
layout: post
tags: [software, design pattern]
---

> [Fluent Interface] 通常是為了提升程式碼的可讀性而設計的一種 API 設計風格，Fluent Interface 的核心思想是讓程式碼看起來像自然語言一樣流暢，
> 可以讓開發者更容易理解程式碼的意圖，並且減少程式碼的冗長性。
{: .block-tip }

[Fluent Interface]: https://en.wikipedia.org/wiki/Fluent_interface

> 如果有一個物件或資料型別，並且該物件有多個方法需要被呼叫，這時使用 Fluent Interface 就可以讓程式碼看起來更簡潔，並且更容易理解。

### 1. Overview

這裡我們以 Javascript 的 **fetch** API 為例，fetch 就是一個典型的 Fluent Interface 的例子，fetch API 允許我們使用鏈式呼叫的方式來處理 HTTP 請求，讓程式碼看起來更流暢。

```javascript
fetch('https://example.com/data')
  .then(response => {
    if (!response.ok) {
      throw new Error('Network response was not ok');
    }
    return response.json();
  }
  .then(data => {
    console.log(data);
  })
  .catch(error => {
    console.error('Fetch error:', error);
  });
```

我們可以很容易的理解上面的程式碼執行以下步驟:
1.  呼叫 fetch 方法對 `https://example.com/data` 發出 HTTP 請求
2.  當請求完成後，檢查回應是否成功，如果不成功則丟出錯誤
    -   否則 `return response.json()` 會將回應的 JSON 內容解析成 JavaScript 物件後傳遞給下一個 then 方法
3.  在下一個 then 方法中，我們可以直接使用解析後的資料來進行後續的處理，例如印出資料
4.  如果在任何一個步驟中發生錯誤，catch 方法會捕捉到錯誤，並且印出錯誤訊息

這是一個典型的 Fluent Interface 的例子，透過鏈式呼叫的方式讓程式碼看起來更流暢，並且更容易理解每個步驟的意圖。
如果不使用 Fluent Interface 的話，程式碼可能會成以下的樣子:

```javascript
async function fetchData() {
  try {
    const response = await fetch('https://example.com/data');

    if (!response.ok) {
      throw new Error('Network response was not ok');
    }

    const data = await response.json();
    console.log(data);

  } catch (error) {
    console.error('Fetch error:', error);
  }
}
```

在這個案例裡資料的轉換只有 3 個步驟，但如果有更多步驟的話，程式碼就會變得更冗長，
並且不容易理解每個步驟的意圖，這時候使用 Fluent Interface 就可以讓程式碼看起來更簡潔，並且更容易理解。

**Other Examples**

在編譯器的測試案例中我們很常需要建立運算式，那麼運算式的建立可能會變成這樣，需要寫四次 Expression 的建構子，
並且每次都要將前一個運算式傳入下一個運算式的建構子中，這樣就會變得非常冗長，並且不容易理解每個步驟的意圖。

```Java
// i = i + 1 * 2 - 3 / 4

// Fluent Interface not used
Expression i = Expression(i);
Expression temp1 = Expression.add(i, 1);
Expression temp2 = Expression.mul(temp1, 2);
Expression temp3 = Expression.sub(temp2, 3);
Expression temp4 = Expression.div(temp3, 4);
i.assign(temp4);

// Fluent Interface used
$(i).assign($(i).add(1).mul(2).sub(3)).div(4);
```

> 如果使用 Fluent Interface 的話，就只需要一行就能表示該運算式的建立，
> 並且很快就能閱讀出該資料最終的型態，這樣就大大提升了程式碼的可讀性。

---

### 2. How to Implement Fluent Interface

實作一個 Fluent Interface 的方法其實很簡單，主要就是讓每個方法都回傳 this，這樣就可以讓方法之間進行鏈式呼叫，
假如我們有一筆資料結構並包含多筆元素，我們可以透過 Fluent Interface 的方式來建立該資料結構，以下是一個簡單的例子:

```Java
public class DataStructure {
    private String name;
    private int size;
    private boolean isValid;

    public static DataStructure create() {
        DataStructure ds = new DataStructure();
        ds.elements = Collections.emptyList();
        ds.name = "";
        ds.size = 0;
        ds.isValid = false;
        return ds;
    }

    public DataStructure name(String name) {
        this.name = name;
        return this;
    }

    public DataStructure size(int size) {
        this.size = size;
        return this;
    }

    public DataStructure valid(boolean isValid) {
        this.isValid = isValid;
        return this;
    }
}
```

這樣使用上我們只需要這樣就能建立一個 DataStructure 的物件，並且設定該物件的屬性:

```java
DataStructure ds = DataStructure.create()
    .name("MyData")
    .size(10)
    .valid(true);
```

```java
DataStructure ds = DataStructure.create()
    .name("MyData")
    .size(10);
```

這種方式讓我們可以在一行程式碼中就能建立一個 DataStructure 的物件，並且設定該物件的屬性，這樣就大大提升了程式碼的可讀性，
並且在 `Create` 方法中我們也可以設定一些預設值。

---

### 2. Fluent Interface Problems

Fluent Interface 同樣也可能造成一些問題，我們可以整理為以下幾點:

1.  Errors cannot be captured at compile time.
    -   強型別語言中可以透過參數來強制要求某些屬性必須被設定，這樣在**編譯階段 (Compile Time)**就能捕捉到錯誤
        -   使用 Fluent API，通常會允許某些欄位不被設定，這樣就會導致在**執行階段 (Run Time)**才會捕捉到錯誤
2.  Debugging and error reporting
    -   Debugging 讓我們在設置 Breakpoint 的時候只能停在某一行，這樣無法判斷是哪一個方法導致錯誤
    ```java
    java.nio.ByteBuffer.allocate(10).rewind().limit(100);
    ```
    -   解決方式是拆成多行，這樣就能夠在每一行設置 Breakpoint
    ```java
    java.nio.ByteBuffer
    .allocate(10)
    .rewind()
    .limit(100);
    ```
3.  Logging
    -   例如多個階段的資料處裡，我們有可能要在中間紀錄一些 Log，這樣還是得拆成多行在中途停下紀錄
4.  Subclasses
    -   如果 A 繼承 B，B 也要使用 Fluent Interface 的話，B 必續 Override A 的 Fluent Interface 的方法，
    否則將會回傳 A 的物件，這樣就會導致程式碼變得冗長，並且不容易維護
    -   解決方式是使用 Generics，讓 A 的 Fluent Interface 的方法回傳 A 的子類別，這樣就能夠避免這個問題

> 最後我們總結一下，使用 Fluent API 通常是為了提升程式碼的可讀性，尤其在超過 3 個以上的方法連續調用的情況下，
> Fluent API 確實能夠讓程式碼看起來更簡潔，並且更容易理解每個步驟的意圖，但同時也要注意 Fluent API 可能會帶來的一些問題。
> 在使用 Fluent API 的時候，我們需要權衡程式碼的可讀性和可維護性來決定是否使用。
{: .block-warning }

> ##### Last Edit
> 03-21-2026 23:52
{: .block-warning }