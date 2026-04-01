---
title: "Backend | MariaDB Replication Guide I"
author: Benson Hsu
date: 2026-02-19
category: Jekyll
layout: post
tags: [software, database, mariadb, replication]
---

> 這系列教學文章的目標是提供一個完整的 MariaDB Replication 的指南，從基礎概念到實際操作，幫助讀者理解和實現 MariaDB 的 Replication 功能。
{: .block-tip }

> Waht I can not create, I do not understand.
{: .block-warning }

> [mariadb-replication-guide] 該專案提供一系列程式碼範例，希望透過 Step-by-Step 的方式使人理解 MariaDB Replication 的概念和實作細節。

[mariadb-replication-guide]: https://github.com/Hotshot824/mariadb-replication-guide

Database 的水平擴展往往是一個相較於 Stateless Service 更加複雜的問題，DB 是有狀態的，因此在設計上還需要額外考慮資料持久化，
資料一致性，資料同步等等問題。但這部分如果是開發小型專案或者是開發階段，通常會選擇使用單一資料庫的方式來進行開發，
這系列文章的目的是提供一個訓練上的指南，讓初學者可以從 Docker-Compose 來建立多個 MariaDB 的架構。

### Chapter 1: Basic Composition

> 在本教學中我們只會使用 mariadb 的官方映像檔，並且不會透過任何設定以外的方式進入 Container 做設定

首先我們試著建立兩個 Container 的簡單結構，分別是 Master 和 Replica，並且讓他們在同一個 Network 中可以互相連線。
在 [MariaDB image] 的官方映像檔中，主要有以下幾種方式可以調整內部的設定:

1.  SQL init script:
    -   MariaDB 的 image 會在啟動時執行特定位置的 .sql 檔案
2.  Config file:
    -   透過 volume 的方式將本地的 my.cnf 掛載到 Container 中，來調整 MariaDB 的設定
3.  Command:
    -   直接在 docker-compose.yml 中透過 command 的方式來調整 MariaDB 的啟動參數
    -   MariaDB image 的 Entrypoint 支援 mysql 啟動參數的帶入，在 Compose 中編寫的參數會被放到啟動指令中

[MariaDB image]: https://hub.docker.com/_/mariadb

**Chapter_1:**
```yaml
version: '3.8'

services:
  mariadb-master:
    image: mariadb:10.11
    container_name: mariadb-master
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
    ports:
      - "3307:3306"
    volumes:
      - ./master/data:/var/lib/mysql
      - ./master/my.cnf:/etc/mysql/conf.d/my.cnf
    networks:
      - mariadb-net

  mariadb-replica:
    image: mariadb:10.11
    container_name: mariadb-replica
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
    ports:
      - "3308:3306"
    volumes:
      - ./replica/data:/var/lib/mysql
      - ./replica/my.cnf:/etc/mysql/conf.d/my.cnf
    depends_on:
      - mariadb-master
    networks:
      - mariadb-net

networks:
  mariadb-net:
```

實際上 MairaDB 的同步是透過 Binlog 的方式來實現的，因此在 Master 的 my.cnf 中需要開啟 Binlog 的功能。

> ##### Last Edit
> 02-19-2026 17:04
{: .block-warning }