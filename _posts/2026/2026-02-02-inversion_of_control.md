---
title: "Pattern | Inversion of Control"
author: Benson Hsu
date: 2026-02-02
category: Jekyll
layout: post
tags: [software, design pattern]
---

> [Inversion of Control] (IoC) 具體來說是一種 Design Principle，而不是 Design Pattern，IoC 的核心思想是將對象的控制權從傳統的流程控制轉移到外部容器或框架，
> 這樣可以實現更好的模組化、可測試性和靈活性。而 Design Pattern 是更具體的實現 IoC 的方式，例如 Dependency Injection 就是一種實現 IoC 的 Design Pattern。
{: .block-tip }

> 這篇文章偏向概念性的說明 IoC 的核心思想，以及如何透過一些簡單的範例來實現 IoC
{: .block-warning }

> 不過如果沒有真的實踐過，其實對於 IoC 的理解可能會流於表面，會覺得 IoC 就是把控制權交給框架或容器，而沒辦法理解這樣做的好處

[Inversion of Control]: https://en.wikipedia.org/wiki/Inversion_of_control

### 1. Overview

首先我們先理解字面意思上「Inversion of Control」的意思，這個反轉的意思其實是基於傳統的程式設計模式，
其控制權發生了「Inversion」，也就是說傳統的程式設計模式中，對象的控制權通常是由程式碼本身來掌握的，而在 IoC 中，這個控制權被反轉了，
由外部的容器或框架來掌握，而不是呼叫者自己來控制。

> 這種說法依然是比較抽象的，想要理解用具體案例來說明會更清楚
{: .block-danger }

#### 1.1 Example

如果有一個 `Class A` 他需要透過 `Class B` 來印出訊息，傳統的做法會是 `Class A` 直接 new 一個 `Class B` 的實例，
然後呼叫 `Class B` 的方法來印出訊息，如下所示：

```java
public class ClassA {
    private ClassB classB;

    public ClassA() {
        this.classB = new ClassB();
    }

    public void printMessage() {
        classB.printMessage();
    }
}

public class ClassB {
    public void printMessage() {
        System.out.println("Hello, World!");
    }
}
```

上面的程式碼問題在於 `Class A` 與 `Class B` 之間是強耦合的，如果未來需要更換 `Class B` 的實現，
我們需要進入 `Class A` 的程式碼來修改，那如果再整個系統中有多處使用 `Class B` 的地方，那麼修改的成本就會非常高，
這就是傳統的程式設計模式中控制權沒有反轉的問題，`Class A` 擁有 `Class B` 的實例，並且直接控制 `Class B` 的行為。

> 同時有可能 A, B 是循環耦合的關係，例如 B 需要取得 A 的某些資訊來完成他的工作，這樣就會如**下圖左** A, B 是循環依賴的，
> 當未來需要更換 A 或 B 的實現時，變成兩邊的修改都要進行，並且在測試時需要同時 mock A 和 B
{: .block-danger }

> 如果有 100 個類別需要使用 Class B 的功能，難道我要修改 100 個類別的硬編碼來更換 Class B 的實現嗎？
{: .block-danger }

<div style="display: flex; flex-direction: row; align-items: center;">
    <img src="/image/2026/02-02-inversion_of_control/1.jpg"
    width="50%" height="50%">
    <img src="/image/2026/02-02-inversion_of_control/2.jpg"
    width="50%" height="50%">
</div>

於是聰明的你立刻想到了，有沒有可能由第三方的容器來管理 A 和 B 的實例，這樣就能打破 A 和 B 之間的循環依賴，
讓 A 和 B 都不直接擁有對方的實例，而是由容器來管理並提供給 A 和 B，這樣就實現了控制權的反轉，如**上圖右**所示。

但是這樣其實還是無法看出 IoC 的好處，因為我們只是把 A, B 的實例管理交給了容器，
A 還是需要知道 B 的存在，並且直接呼叫 B 的方法來印出訊息，這樣的設計依然是強耦合的，A 和 B 之間的依賴關係沒有被解決。
**如果要修改 A 或 B 的實現，仍然需要修改 A 的程式碼，這樣就沒有真正實現 IoC 的好處。**

#### 1.2 Abstraction Layer

> 加入抽象層是實現 IoC 的必要條件，這樣才能使 A 與 B 真正的解耦合
{: .block-danger }

此時我們需要加入一個抽象層，讓 A 和 B 之間不是直接依賴對方的實現，而是依賴對方的抽象介面，如**下圖**所示：

![](/image/2026/02-02-inversion_of_control/3.jpg){:height="80%" width="80%"}

這樣 A 與 B 的實作之間完全是解耦合的，A 只依賴 B 的抽象介面，而 B 也只依賴 A 的抽象介面，
底層實作只要滿足抽象介面的定義就可以了，這樣我們就可以隨時替換 A 或 B 的實現，這個替換可以是第三方的程式碼或者設定檔來決定使用哪一種實現。
這樣如果有 100 個類別需要使用不同的 B 實現，我們只需要改變設定檔就能一次改變所有實際類別。

> 這樣的優點是如果我們在某個特定環境，例如測試環境，我們要將 A 獨立單元測試時，對於 B 的依賴就不需要真正的 B 實現，
> 而是可以使用一個 Mock 的 B 來滿足 A 對 B 的依賴，而不需要依賴 B 的實際行為。
{: .block-warning }

---

### 2. Implementation

> 實際上 IoC 的實現方式有很多種，最常見的就是 Dependency Injection (DI)，還有 Service Locator 等等，不同的實現方式有不同的優缺點，
> 不過最重要的是要理解 IoC 的核心思想，而不是被具體的實現方式所限制，因為 IoC 的核心思想是將控制權反轉，而不是具體的實現方式。
{: .block-tip }

> 能講的實現方法太多，可以另外寫一篇文章來介紹不同的實現方式，這裡只會著重在 DI 的實現方式

在理解 DI 的實現方法之前我們要先了解 A 如何獲得 B 的實例，實際上在 Spring 中，這個賦予通常是一次性的，
因此 A 並不會動態的獲得 B 的實例，而是由 Spring 在啟動時就將 B 的實例注入到 A 中。

在寫程式上我們能透過以下幾種方式來實現 A 獲得 B 的實例:

1.  **Constructor Injection:** 
    -   透過建構子來注入 B 的實例到 A 中
2.  **Field Injection:** 
    -   直接將 B 的實例注入到 A 的欄位中
3.  **Setter Injection:** 
    -   透過 setter 方法來注入 B 的實例到 A 中
4.  **Method Injection:**
    -   透過方法參數來注入 B 的實例到 A 中
5.  **ObjectProvider Injection:**
    -   透過第三方的程式碼來獲得 B 的實例，但 A 會依賴 ObjectProvider 來獲得 B 的實例
    -   這種方式很接近 [Service Locator ]的實現方式，因為 A 需要依賴 ObjectProvider 來獲得 B 的實例
        -   這種方法由於 A 需要依賴 ObjectProvider 來獲得 B 的實例，實際在上不一定是更好的設計
6.  **Lookup Method Injection:**
    -   可以使用 [CGLIB] 來實現動態代理，讓 A 在呼叫 B 的方法時，實際上是呼叫一個代理物件，這個代理物件會在呼叫時動態的獲得 B 的實例
        -   這種方式通常自己手動寫起來會比較麻煩，會透過框架來實現，例如 Spring 就提供了這樣的功能

> [CGLIB] 是一個 Java lib，可以用來動態生成 Java 類別，這樣就可以在運行時動態的創建類別，並且可以在類別中定義方法，這樣就可以實現動態代理的功能。

[CGLIB]: https://github.com/cglib/cglib?tab=readme-ov-file

> 總之無論透過哪種方式，實際上還是會需要執行一個代碼將 B 賦予 A，差別只是由框架提供或者我們可以自己寫一個簡單的程式碼來實現這個賦予的過程
{: .block-warning }

[Service Locator]: https://en.wikipedia.org/wiki/Service_locator_pattern

#### 2.1 Dependency Injection

**Constructor Injection**

一個最簡單的實現方式就是透過建構子來注入 B 的實例到 A 中，如下所示:

```java
public class ClassC {
    public void main(String[] args) {
        ClassB classB = new ClassB();
        ClassA classA = new ClassA(classB);
        classA.printMessage();
    }
}
```

> 這是手動實現 DI 的方式，雖然很簡單，但這也完成了 IoC 的核心定義，Class B 與 Class A 都是由 Class C 的 main 方法控制的。

實際上我們也可以透過 Reflection 來實現 DI 的方式，透過例如 `@Autowired` 這樣的註解來告訴框架需要注入的類別，
然後由框架來透過 Reflection 來實現 DI 的過程，這樣我們就可以寫一個程式來自動化的實現 DI 的過程，而不需要手動寫一個程式碼來實現這個過程。

當然這樣的方法就不可能是數行程式碼就能實現的了，通常會需要一個完整的框架來實現這樣的功能，
例如 Spring 就提供了這樣的功能，讓我們可以透過註解來實現 DI 的過程。

**Field Injection**

```java
public class ClassA {
    @Autowired
    public ClassB classB;

    public void printMessage() {
        classB.printMessage();
    }
}

public Class ClassC {
    public void main(String[] args) {
        ClassA classA = new ClassA();
        classA.classB = new ClassB();
        classA.printMessage();
    }
}
```

Field Injection 的方式是直接將 B 的實例注入到 A 的欄位中，這樣就不需要透過建構子來注入了，這裡為了模擬自己實作而使用 `public` 欄位來直接注入，
實際上在 Spring 中是透過 Reflection 來實現，會繞過 Java 的存取控制來注入私有欄位的，因此可以保持欄位為 `private` 或者 `protected`。

其餘方法如 Setter Injection 是透過 setter 方法來注入 B 的實例到 A 中，Method Injection 是透過方法參數來注入 B 的實例到 A 中，這兩種方式的實現方式與 Constructor Injection 類似，只是注入的方式不同而已，實際上在 Spring 中這兩種方式也是被支持的。

#### 2.2 Spring Implementation

> [Using @Autowired] 是 Spring 中最常見的實現 DI 的方式
{: .block-tip }

[Using @Autowired]: https://docs.spring.io/spring-framework/reference/core/beans/annotation-config/autowired.html

Spring 是依照你的 Class 寫法來決定使用哪一種注入方式，有以下規則:

1.  Class 只有一個 Constructor，並且 Constructor 的參數都是 Spring 管理的 Bean
    -   Spring 就會使用 Constructor Injection 的方式來注入 Bean。
2.  Class 有多個建構子，而且都有 Bean 作為參數，那麼需要使用 `@Autowired` 來指定使用哪一個建構子來注入 Bean。
3.  只有欄位有 `@Autowired` 註解，那麼 Spring 就會使用 Field Injection 的方式來注入 Bean。
4.  如果有 Method 有 `@Autowired` 註解，那麼 Spring 就會使用 Method Injection 的方式來注入 Bean。
    -   當 Method 是 setter 方法的時候，就稱為 Setter Injection

雖然有這麼多種注入方式，**但 Spring 官方推薦的是使用 Constructor Injection 的方式來實現 DI**，
也就是只有一個 Constructor，並且 Constructor 的參數都是 Spring 管理的 Bean，
這樣的方式是顯式的，盡量減少 `@Autowired` 的使用，這樣就能讓程式碼更清晰，並且更容易測試。

> Since you can mix constructor-based and setter-based DI, it is a good rule of thumb to use constructors for mandatory dependencies and setter methods or configuration methods for optional dependencies.

> 一個良好的經驗法則是，對於「必要（mandatory）」的依賴，應使用建構子注入；對於「可選（optional）」的依賴，則使用 setter 方法或設定方法來注入。

> [Dependency Injection]

[Dependency Injection]: https://docs.spring.io/spring-framework/reference/core/beans/dependencies/factory-collaborators.html

這裡給一個範例，假設我們有 `stripe` 與 `paypal` 兩個支付系統的實現，透過 `PaymentService` 這個抽象介面來定義支付服務:

```java
public interface PaymentService {
    void pay(int amount);
}

@Service
@Profile("stripe")
public class StripePaymentService implements PaymentService {

    @Override
    public void pay(int amount) {
        System.out.println("Stripe paid: " + amount);
    }
}

@Service
@Profile("paypal")
public class PaypalPaymentService implements PaymentService {

    @Override
    public void pay(int amount) {
        System.out.println("Paypal paid: " + amount);
    }
}

@Service
public class OrderService {

    private final PaymentService paymentService;

    public OrderService(PaymentService paymentService) {
        this.paymentService = paymentService;
    }

    public void createOrder() {
        paymentService.pay(100);
    }
}
```

```yml
spring:
  profiles:
    active: stripe
```

或者透過啟動參數 `-Dspring.profiles.active=paypal` 來切換使用 `paypal` 的實現，
這樣就能夠在不修改程式碼的情況下切換支付系統的實現了。

### 3. Conclusion

最後我們總結一下 IoC 到底帶來開發上那些好處，主要有以下幾點:

1. **降低耦合度:**
    -   A 和 B 之間的依賴關係被解決了，這樣就能夠降低 A 和 B 之間的耦合度
    -   在實作時我們可以關注於 A 和 B 的行為，而不需要關注 A 和 B 之間的依賴關係
2. **提高可測試性:**
    -   我們不必為了測試而特別去建構 B 的實例，更容易區分測試環境的使用與生產環境的使用
    -   可以專門為測試環境提供一個 Mock 的 B 的實現，這樣就能夠更容易的測試 A 的行為
3. **生命週期管理:**
    -   將物件統一交由容器來管理，這樣就能夠統一管理物件的生命週期
    -   在 Spring 中，Bean 的生命週期是由 Spring 來管理的，這樣就能夠統一管理 Bean 的創建、銷毀等過程
        -   例如物件銷毀的時候需要釋放資源，這樣就能夠統一管理資源的釋放過程

> 以上說明了 IoC 的核心思想，以及如何透過 DI 的方式來實現 IoC，但其實要實現 Dependency Injection 的方式還有很多可以說明，
> 之後會考慮要不要說 Spring Boot 如何具體實現 DI，會涉及到 Spring 的 BeanFactory、ApplicationContext、BeanDefinition，
> 以及三層 Cache 如何去解決 Bean 的循環依賴問題，這些都是實現 DI 的細節，會在之後考慮要不要寫一篇文章來說明。
{: .block-warning }

> ##### Last Edit
> 02-03-2026 18:32
{: .block-warning }