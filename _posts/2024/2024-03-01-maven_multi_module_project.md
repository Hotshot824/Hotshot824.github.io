---
title: "Note | Apache Maven Multi-Module Project Guide"
author: Benson Hsu
date: 2024-03-01
category: Jekylls
layout: post
tags: [software]
---

> 在開發 Java 的時候一定會考量的是如何管理專案的結構，尤其是當專案規模大到一定程度的時候，這裡就是因為遇到了陳年舊 Code 把所有程式塞在同一個專案裡面，
> 為了對專案做更好的管理架構，使用 Module 來分割專案是一個不錯的選擇，並且也可以增加代碼的可維護性。
{: .block-tip }

> Reference: [Maven by Example - Chapter 6. A Multi-Module Project], [Guide to Working with Multiple Modules]

其實概念上就是依靠 POM.xml 來管理多個專案，這樣就會有一個頂層的 POM.xml 在此之下會有多個子專案的 POM.xml，這樣就可以透過頂層的 POM.xml 來管理所有的子專案，
Maven 把這樣的機制稱為 Reactor，Maven 會透過 Reactor 來做以下操作:

-   收集所有可用的 Module 來 Build
-   依照 Module 之間的依賴關係跟順序來 Build

### Parent POM

這邊用 Eclipse 來建立一個 Maven Project 把 `POM.xml` 中的 `<packaing>` 設定為 `pom`，這樣就會變成一個 Parent POM，這樣就可以透過這個 POM.xml 來管理所有的子專案。

1.  建立一個 Maven Project 使用 maven-archetype-quickstart 這個 Archetype
2.  把 `POM.xml` 中的 `<packaing>` 設定為 `pom`
    -   設定為 `pom` 之後就會變成一個 Parent POM 其他的檔案都可以刪掉了
    -   POM.xml 的 artifactId 可以命名為 root
3.  Module 的 dependency 可以放在 Parent POM 中，這樣所有的 Module 都可以共用這些 dependency
    -   如果單獨放在 Module 的 POM.xml 中，那麼就代表是只有這個 Module 可以使用這些 dependency
    -   version, groupId 可以在 Parent POM 中設定代表所有的 Module 都共用這些設定

Parent POM:
```xml
<project>
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.example.myapp</groupId>
  <artifactId>root</artifactId>
  <version>0.0.1-SNAPSHOT</version>
  <packaging>pom</packaging>

  <name>root</name>
  <url>http://maven.apache.org</url>

  <properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
  </properties>

  <dependencies>
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>3.8.1</version>
      <scope>test</scope>
    </dependency>
  </dependencies>
</project>
```

Module POM:
```xml
<project>
	<modelVersion>4.0.0</modelVersion>
	<parent>
		<groupId>com.example.my</groupId>
		<artifactId>root</artifactId>
		<version>0.0.1-SNAPSHOT</version>
	</parent>

	<artifactId>application</artifactId>
	<name>application</name>
	<url>http://maven.apache.org</url>

	<properties>
		<project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
	</properties>

	<dependencies>
	</dependencies>
</project>
```

### Module

Module 就是一個獨立的專案，跟一般的 Maven Project 一樣，如果 Module 之間有互相 dependency 的關係，
那就在 POM 加入對該 Module 的 dependency，這樣 Maven 就會依照順序來 Build。

如果 application module 依賴於 data-site 就可以在 application 的 POM.xml 中加入以下的設定:
```xml
<dependency>
    <groupId>com.example.my</groupId>
    <artifactId>data-site</artifactId>
    <version>0.0.1-SNAPSHOT</version>
</dependency>
```

全部設定完後使用 `mvn verify` 就可以驗證整個專案的 Build，Maven 會依照 Module 之間的依賴關係跟順序來 Build jar。
如果想要把所有專案的 jar 都打包成一個大的 jar 可以使用一些 Maven Plugin 來達成，例如 `maven-assembly-plugin`。

```bash
[INFO] ------------------------------------------------------------------------
[INFO] Reactor Summary for root 0.0.1-SNAPSHOT:
[INFO]
[INFO] root ............................................... SUCCESS [  0.921 s]
[INFO] data-site .......................................... SUCCESS [  2.003 s]
[INFO] application ........................................ SUCCESS [  0.732 s]
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  3.793 s
[INFO] Finished at: 2024-03-01T20:31:18+08:00
[INFO] ------------------------------------------------------------------------
```

> mvn verify 成功後就會看到類似上面的訊息，代表整個專案都 Build 成功了

> ##### Last Edit
> 03-01-2024 15:32
{: .block-warning }

[Maven by Example - Chapter 6. A Multi-Module Project]: https://books.sonatype.com/mvnex-book/reference/multimodule.html
[Guide to Working with Multiple Modules]: https://maven.apache.org/guides/mini/guide-multiple-modules.html