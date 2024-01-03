---
title: "Note | UML Structure Diagrams Introduction"
author: Benson Hsu
date: 2023-07-28
category: Jekyll
layout: post
tags: [software, software_development]
---

> 本篇主要介紹 UML 的分類中的結構圖(Structure Diagrams)
{: .block-tip }

### 1. Structure diagrams

[1.1 Class diagram](./2023-07-28-UML_structure_diagrams.html#11-class-diagram)  
[1.2 Component diagram](./2023-07-28-UML_structure_diagrams.html#12-component-diagram)  
[1.3 Deployment diagram](./2023-07-28-UML_structure_diagrams.html#13-deployment-diagram)  
[1.4 Object diagram](./2023-07-28-UML_structure_diagrams.html#14-object-diagram)  
[1.5 Package diagram](./2023-07-28-UML_structure_diagrams.html#15-package-diagram)  
[1.6 Composite structure diagram](./2023-07-28-UML_structure_diagrams.html#16-composite-structure-diagram)  

##### 1.1 [Class Diagram]

Class diagrams(類圖)是使用最廣泛的 UML 圖，他是所有 Object-Oriented Software Systems 的基礎。
透過顯示系統的 Class(類)、Mthods(方法)、Properties(屬性)來描述系統的靜態結構。

從下圖我們可以看出:  
1.  **[Abstract Class]**: 看到 Shape 是一個 Abstract Class 他以斜體顯示。
2.  **[Class diagram relationships]:**
    1.  **Generalization**: 空心箭頭，同時 Shape 也是一個 **[Superclass]**，Circle、Rectangle、
    Polygon 都是由 Shape 所衍生，也就是說 Circle 是一個 Shape，這是一種 generalization(一般化)/inheritance(繼承) 的關係。
    2.  **Association**: Class 間的連線，DialogBox 和 DataController 之間有一個關聯。
    3.  **Aggregation**: 空心菱形箭頭，Shape 和 Window 是一種聚合關係，Shape 可以存在而不依賴 Windows。
    4.  **Composition**: 實心菱形箭頭，Point 是 Circle 是一種組合關係，沒有 Circle 就不能存在 Point。
    5.  **Dependency**: 空心箭頭，Window 依賴於 Event，但 Event 不依賴於 Window。
3.  **Attributes**: Circle 的屬性是 radius、center 後面是他的型別，這是一個 Entity class。
4.  **Methods**: Circle 的方法是 area()、circum()、setCenter()、setRadius()。
    -   **Parameter**: Circle 中的 area(in radius: flot) 代表參數是一個名為 radius 型別為 float 的傳入參數。
    -   **Return**: Circle 中的 area(): double，代表返回一個 double 的值。
5.  Hidden: Rectangle 的 Attributes，Mehtods 是隱藏的，圖中的其他一些 Class 也隱藏了他們的 Attributes，Mehtods。

![](https://www.cybermedian.com/tw/wp-content/uploads/sites/5/2022/02/06hL3wLFgiGvY3tpt.png)

##### 1.2 [Component diagram]

Component diagram(元件圖)描述一個軟體系統時，將軟體系統裡的元素給予模組化(Modularity)，即成為一個元件。將元件與元件間的關係做描述時，
對於軟體系統的運作可以比描述類別關係更加得清楚。

-   Component 通常比 Class 有更高的抽象層級，可能由一個或多個 Class 組成，可能是包、可執行檔案、資料庫等。
每個元件通常封裝特定的功能並公開一個明確定義的介面，**元件與類最大的差別在於元件強調的是介面的溝通**。

下圖是一個 Composite Component，也就是元件中包含著元件=的範例，Composite Commponent 中的主要元素有:
1.  **Component(元件)**: 以一個長方形所顯示，右上角繪製一個 1.x UML 版本的元件圖(非必須)。
2.  **Provided interface(提供接口)**: 以一個圓形顯示，代表為提供給 Client 端所使用的接口。
3.  **Request interface(所需接口)**: 以一個半圓顯示，代表元件所需求的介面。
4.  **Port(端口)**: 以一個正方形表示，以表示元件公開的端口。

![](https://www.cybermedian.com/wp-content/uploads/2023/03/02-component-diagram-overview.png)

-   **Relationship**:
    -   Dependency: 空心箭頭，表示一個元件依賴其他元件或接口才能實現。

![](https://cdn-images.visual-paradigm.com/guide/uml/what-is-component-diagram/15-component-diagram-example-cpp-code-with-versioning.png)

##### 1.3 [Deployment diagram]

Deployment diagram(部屬圖)是顯示運行時處理節點的配置，用於物件導向系統的物理方面進行建模，
通常用於對系統的靜態部署視圖(硬件拓撲)進行建模。

-   拓撲(Topology): 在系統架構中用於描述不同組件或模塊之間的關係和連接方式。
-   與 Component diagram(元見圖)的不同點在於，部屬圖主要用於展示一個系統或軟體是如何被部署在不同的硬體和運行環境中，
他著重於系統的物理組成、硬體資源的配置、節點之間的通訊通道。

下圖是一個部署圖的範例，有這些主要元素:
1.  **Node**: 3D 矩形，代表一個節點，無論是硬體或是軟體。
    -   可以使用 `<<stereotype>>` 來註明節點，以區分節點的類型。
    -   Node 內可以包含另一個 Node。
2.  **Association**: Node 間的連線。
    -   可以使用空心箭頭來代表之間的依賴性。

![](https://cdn-images.visual-paradigm.com/guide/uml/what-is-deployment-diagram/02-deployment-diagram-notations.png)

**TCP/IP Client / Server Example:**

![](https://cdn-images.visual-paradigm.com/guide/uml/what-is-deployment-diagram/05-deployment-diagram-tcpip-example.png)

##### 1.4 [Object diagram]

Object Diagram(物件圖)用於展示系統或軟體在特定時間點內物件實例(Object instance)，還有物件彼此間的關聯。
它也被稱作記憶體的快照(memory snapshot)。

-   Object(物件): 物件是特定 Class 的實例，物件顯示的是**實例**與**屬性**。
-   通常物件圖用於開發的後期階段，用來展示特定時間點內的物件實例與相關的關係，有助於理解系統在特定時間內的狀態，
確保物件間的關係符合設計需求。
-   當 Class diagram 非常複雜時，Object diagram 對於解釋系統的細節部分很有用，
說明 Object diagram 的最佳方式是透過相應的 Class diagram 對照產生的 Object diagram。

下圖說明了一個大學系所的可以有很多其他的延伸系所，將 Class diagram 實例化後的 Object diagram:

![](https://cdn-images.visual-paradigm.com/guide/uml/what-is-object-diagram/02-object-diagram-at-a-glance.png)

一個訂單管理系統的 Class diagram 與其 Object diagram:

![](https://cdn-images.visual-paradigm.com/guide/uml/what-is-object-diagram/03-class-diagram-to-object-diagram.png)

Object diagram 主要的元素有以下這些: 
1.  **Object**: 矩形方框，提供了 `Object Name : Class`，並以下劃線註記。
    -   Anonymous Object: 匿名物件，僅使用 Method 而不建立實例的物件。
2.  **Object attributes**: 與 Class 相似，但 Object attributes 必須分配具體的 Value。
3.  **Links**: Object 之間的關聯，可以使用 Class diagram 相同的箭頭來表示關係。

![](https://cdn-images.visual-paradigm.com/guide/uml/what-is-object-diagram/07-object-diagram-example-company-structure.png)

##### 1.5 [Package diagram]

Package diagram(封裝圖)用於建模高層級系統元素，Package 用於組織包含圖表、文件和其他關鍵的大型系統。

-   **When to use Package diagram?**
    -   Package diagram 可以用來簡化複雜的 Class diagram，可以將 Class 分到 Package 中。
    -   Package 是邏輯上相關的 UML 元素的集合。
    -   Package 被描繪為文件夾，可以在任何 UML 中使用。

一個 Package diagram 具有以下元素，下圖是一個訂單子系統的範例:
1.  Subsystem: 註明了這個子系統的名稱。
2.  **Package**: 一個矩形，右上角帶有選項卡。Package name 位於矩形內或選項卡上。
    1.  Concrete package: 具有實現功能的包，其中有具體的程式碼，可以被執行、編譯或部署。
    2.  Abstract package: 沒有實際的程式碼實現，通常是為了邏輯上的分類，用於組織和分類包。
    3.  Dependency on external package: 不在系統內部直接實現或編寫的依賴包。
3.  **Dependency**: 代表 Package 之間的依賴關係。
    -   Example: 如果一個類想要在一個不同的包中使用一個類，它就必須為該包提供一個依賴。
4.  **Generalization**: 一個包可以包含多個子包，每個子包都可以包含一系列元素。

![](https://cdn-images.visual-paradigm.com/guide/uml/what-is-package-diagram/08-package-diagram-order-subsystem.png)

##### 1.6 [Composite structure diagram]

Composite structure diagram(組合結構圖)是 UML 2.0 中添加的新圖形，其中包含 Class, Port, Package。
組合結構圖的作用與 Class diagram 類似，但是允許更詳細的描述多個 Class 的內部結構並顯示他們之間的交互。

![](https://cdn-images.visual-paradigm.com/guide/uml/what-is-composite-structure-diagram/02-simple-composite-structure-diagram.png)

> ##### Note
> Last edit 08-01-2023 00:13, [Reference]
{: .block-warning }

[Reference]: https://www.cybermedian.com/a-comprehensive-guide-to-understanding-and-implementing-unified-modeling-language-in-software-development/#Sequence_diagrams

[Class Diagram]: https://en.wikipedia.org/wiki/Class_diagram

[Abstract Class]: https://en.wikipedia.org/wiki/Abstract_type
[Superclass]: https://en.wikipedia.org/wiki/Inheritance_(object-oriented_programming)#Subclasses_and_superclasses
[Class diagram relationships]: https://en.wikipedia.org/wiki/Class_diagram#Relationships

[Component diagram]: https://www.visual-paradigm.com/guide/uml-unified-modeling-language/what-is-component-diagram/

[Deployment diagram]: https://www.visual-paradigm.com/guide/uml-unified-modeling-language/what-is-deployment-diagram/

[Object diagram]: https://www.visual-paradigm.com/guide/uml-unified-modeling-language/what-is-object-diagram/

[Package diagram]: https://www.visual-paradigm.com/guide/uml-unified-modeling-language/what-is-package-diagram/

[Composite structure diagram]: https://www.visual-paradigm.com/guide/uml-unified-modeling-language/what-is-composite-structure-diagram/