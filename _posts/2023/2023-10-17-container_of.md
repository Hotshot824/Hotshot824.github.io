---
title: "Note | Linux Kernel Macro container_of & offsetof"
author: Benson Hsu
date: 2023-10-17
category: Jekyll
layout: post
tags: [OS]
---

> container_of 這個 Macro 在 Linux kernel 會經常被用到，因此先理解 container_of 絕對非常重要
{: .block-tip }

### container_of

container_of 的定義在 [<include/linux/container_of.h>]，並且需要使用 Marco offsetof，container_of 可以透過一個 struct 中的某個成員來獲得該 struct 的起始位置，
這樣的做法會在 Linux kernel 中被頻繁的使用到。

例如 Linux kernel 中的 [<lib/rbtree.c>], [<include/linux/list.h>]，在 list.h 中 container_of 被用來找尋 list_last_entry, list_first_entry，
而在 rbtree.c 中則可以用來找尋父節點。

```c
/**
 * container_of - cast a member of a structure out to the containing structure
 * @ptr:        the pointer to the member.
 * @type:       the type of the container struct this is embedded in.
 * @member:     the name of the member within the struct.
 * */
#define container_of(ptr, type, member) ({              \
const typeof( ((type *)0)->member ) *__mptr = (ptr);    \
(type *)( (char *)__mptr - offsetof(type,member) );})
```

1.  `typeof( ((type *)0 -> member) )`: 先宣告一個 `(type *)0` (struct 的 Null 指標)，然後指向 struct 中的該 member，然後透過 `typeof()` 獲得 member 的 type
2.  `const typeof( ((type *)0)->member ) *__mptr = (ptr)`: 宣告該 member type 的 pointer `*__mptr` 就能指向 `ptr` 所指向的位置
3.  `(char *)__mptr` 將 __mptr 轉換為 char*，因為 char* 長度為 1 byte，這樣才能正確做之後運算
4.  `offsetof(type,member)` 會返回從 struct 起始位置到 member 的偏移量(byte)
5.  `(type *)( (char *)__mptr - offsetof(type,member) )` 最後將 __mptr - offset = struct 的起始位置，然後轉回 type*

下圖是如何透過 Offset 找到 Struct 起始位址的說明:

![](../assets/image/2023/10-17-container_of/1.jpg){:height="75%" width="75%"}

> 延伸閱讀: [Rationale behind the container_of macro in linux/list.h], [What is the purpose of __mptr in latest container_of macro?]
{: .block-warning }

延伸閱讀解釋了為什麼要另外去宣告 __mptr，我也好奇如果已經拿到 ptr 為什麼還要特別去使用 (type *)0 -> member，這樣的方式來獲取 member type，如果將其改為以下程式碼，
一樣可以進行使用:
1.  Type 的檢查，這樣可以增加安全性，確保 ptr 真的與 member 型別相同
2.  Kernel 使用的 C standard 有可能對這種寫法跳出 Warning

```c
#define container_of(ptr, type, member) ({                      \
     (type *)( (char *)ptr - offsetof(type,member) );})
```

> ##### Last Edit
> 10-18-2023 23:55
{: .block-warning }

[<include/linux/container_of.h>]: https://github.com/torvalds/linux/blob/master/include/linux/container_of.h
[<lib/rbtree.c>]: https://github.com/torvalds/linux/blob/master/lib/rbtree.c
[<include/linux/list.h>]: https://github.com/torvalds/linux/blob/master/include/linux/list.h

[Rationale behind the container_of macro in linux/list.h]: https://stackoverflow.com/questions/6083734/rationale-behind-the-container-of-macro-in-linux-list-h
[What is the purpose of __mptr in latest container_of macro?]: https://stackoverflow.com/questions/72074089/what-is-the-purpose-of-mptr-in-latest-container-of-macro