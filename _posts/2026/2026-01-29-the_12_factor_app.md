---
title: "Architecture | The 12-Factor App"
author: Benson Hsu
date: 2026-01-29
category: Jekyll
layout: post
tags: [software, design, architecture, cloud native]
---

[Twelve-Factor App methodology]: https://www.heroku.com/blog/heroku-open-sources-twelve-factor-app-definition/

> The Twelve-Factor App 是一套用於構建現代雲端應用程式的最佳實踐方法論，由 Heroku 團隊的聯合創始人 Adam Wiggins 在 2011 年提出，
> 這是開發 SaaS（Software as a Service）的方法論，旨在幫助開發者構建可擴展、可維護和可部署的應用程式。
{: .block-tip }

> 不過畢竟是 2011 年提出的原則了，當時的技術環境與現在已經有很大的差異了，例如當時還沒有 Docker、Kubernetes 等容器化技術，
> 目前很多看來是常識的原則在當時還不是那麼普遍的作法，因此這些原則在當時是非常具有前瞻性的，
> 並且在當前的 Cloud Native 環境中仍然具有很高的指導意義。
{: .block-danger }

> [THE TWELVE-FACTOR APP]

### Basic Principles

-   **使用宣告式（declarative）的設定格式來進行自動化部署與配置，以降低新成員加入專案所需的時間與成本**
    -   過去我喜歡用半成品的 Image 來部署應用程式，透過 Entry Script 來完成初始化，但這樣會有以下問題:
        -   Container 變為半成品，破壞可重現性，有可能在 CI/CD 上影響穩定性
        -   Shell Script 只可以負責初始化與啟動程式，不應該負責環境與配置的管理，這是 .yaml 的工作
    -   環境變數、連線資訊、容器之間的依賴、捲軸掛載、重啟政策、複製數量都應該在 .yaml 中宣告
        -   在正式環境中請使用乾淨的 Image，並且在 .yaml 中宣告所有的設定與依賴
        -   Image 要確保 Immutable，即使是 [GitOps] 的部屬方式，也要確保 Image 的版本是固定的

> [GitOps] 會另外考慮要不要寫一篇文章介紹，但目前中文介紹 GitOps 的相關已經很多了

> [2023 MOPCON Git 和 DevOps：在混亂的流星群開發流程中找到小確幸 高見龍]

[THE TWELVE-FACTOR APP]: https://12factor.net/

[GitOps]: https://docs.gitops.weaveworks.org/docs/intro-weave-gitops/

[2023 MOPCON Git 和 DevOps：在混亂的流星群開發流程中找到小確幸 高見龍]: https://hackmd.io/@mopcon/2023/%2F%40mopcon%2Fr1hRhwdXT

-   **與底層作業系統維持清晰的契約關係，確保在不同執行環境之間具有高度可攜性**
    -   不依賴於特定發行版的工具或特性，確保應用程式能夠在任何符合標準的環境中運行
    -   這裡我們以 Debian 與 Ubuntu 中固定 Timezone 為例:
        -   Ubuntu 或許有 tzdata 但 Debian 沒有，這樣就會降低移植性
        -   比較好的做法是例如 Spring 可以設定 time-zone，這樣 TZ 設定是綁定在應用程式內部的，
        而不是依賴於底層作業系統的工具，這樣就能確保在不同的 Linux 發行版上都能正常運行
-   **適合部署於現代雲端平台，減少對傳統伺服器管理與系統維運的依賴**
    -   應用程式應該設計為無狀態（stateless），並且將任何持久化的資料存儲在外部服務中，例如資料庫或物件存儲
-   **最小化開發環境與生產環境之間的差異，使持續部署 (Continuous Deployment) 得以實現，提升開發敏捷性**
    -   開發環境與生產環境的差異越小，部屬風險就越小，部屬頻率才能提高

> 軟體工程師最常甩鍋的一句話是 "It works on my machine"
{: .block-danger }

*   **能夠在不大幅改動工具鏈、系統架構或開發流程的情況下進行水平擴展(scale up)**
    -   水平擴展意味著能夠通過增加更多的實例來處理增加的負載，而不是依賴於升級單一實例的硬體資源
    -   這需要應用程式設計為無狀態，並且能夠在多個實例之間共享狀態，例如使用外部資料庫或分布式快取

---

### I. Codebase

> One codebase tracked in revision control, many deploys
{: .block-tip }

> 一個代碼庫被版本控制系統追蹤，並且可以部署到多個環境中

![](https://12factor.net/images/codebase-deploys.png)

有點類似於 [GitOps] 的概念，所有的部署都來自同一個版本控制系統中的單一代碼庫，這樣可以確保部署的一致性和可追溯性。
保持單一來源將程式碼集中在 Git 中，無論部屬多少實例，都來自同一個代碼庫，這樣可以確保所有的實例都運行相同的程式碼版本，並且可以輕鬆地追蹤和回滾變更。

> 即使有可能版本有所不同，例如在不同機器上部署不同版本的應用程式，但這些版本仍然來自同一個代碼庫，並且可以通過 Git 的分支或標籤來管理和追蹤。
{: .block-danger }

---

### II. Dependencies

> Explicitly declare and isolate dependencies
{: .block-tip }

> 顯式宣告並且隔離依賴

所有的依賴都應該明確宣告並且隔離，這樣可以確保應用程式在任何環境中都能夠正確運行，而不會受到底層系統環境的影響。
不過我不太相信 2026 年的當下還有程式開發者會不依賴賴於套件管理工具來管理依賴，這樣會導致開發環境與生產環境之間的差異，增加部署的風險。

例如 Java Maven 中的 pom.xml 就是一個明確宣告依賴的例子，這樣不論是在開發環境還是生產環境中，只要使用相同的 pom.xml，就能確保依賴的一致性。
或者 Python 的 requirements.txt、Go 的 go.mod，這些工具都明確宣告了依賴。

> 在這裡額外有強調隔離性(isolation)，但通常 container 之間都是相互隔離的，所以除非特別設計通常 container 之內不會有汙染問題。
> 例如一個 pod 只跑一個 python 程式，使用 venv 感覺有點在砸自己的腳

> 避免使用 curl 或者 ImageMagick 這樣或許系統中存在的工具，如果要用就應該確實的打包在 Image 中
{: .block-danger }

---

### III. Config

> Store config in the environment
{: .block-tip }

> 將配置存儲在環境變數中

很簡單的原則，將配置存儲在環境變數中，而不是硬編碼在程式碼中，這樣可以確保應用程式在不同環境中具有高度的可配置性和靈活性。
一個很簡單的判斷原則是: 如果 codebase 是開源的，但不會洩漏任何敏感資訊，就代表設定正確從程式碼中抽離。

例如某個程式需要使用 Public Key 來連接特定資源，該資源應該在 Runtime 中注入，由部屬工具來管理，
例如 Github Actions 的 Secrets，或者 Kubernetes 的 Secret，這樣就能確保敏感資訊不會洩漏在程式碼庫中。

> 不同環境可能有不同的 env 設定，每個環境就獨立一組 env 設定，這樣就能確保在不同環境中應用程式的行為可以根據需要進行調整，而不需要修改程式碼
{: .block-danger }

---

### IV. Backing Services

> Treat backing services as attached resources
{: .block-tip }

> 將後端服務視為附加資源

![](https://12factor.net/images/attached-resources.png)

後端服務是指在應用程式運行中，所有透過網路存取的外部資源，例如:
-   Database (MySQL, PostgreSQL, MongoDB)
-   Message Queue (RabbitMQ, Kafka)
-   Caching Service (Redis, Memcached)
-   Mail Service (SendGrid, {Amazon SES})
-   External APIs ([AWS S3], [Google Cloud Storage])

[Amazon SES]: https://aws.amazon.com/ses/
[AWS S3]: https://aws.amazon.com/s3/
[Google Cloud Storage]: https://cloud.google.com/storage

程式碼不應該區分是本地提供的服務還是第三方服務，對這些服務都透過 URL 或者其他定位方式來存取，
一個最直接的例子是將本地的 MySQL 服務換為 AWS RDS，但不需要修改程式碼，只需要修改配置中的 URL 即可，
這樣就能確保應用程式的靈活性和可擴展性。

> 這樣每個服務只依賴於接口、只關心自己內部的實現，不依賴於外部資源的實現方式

> 每一個獨立的服務都應該被視為一個獨立的資源，並且可以通過配置來切換不同的服務提供者，這樣就能確保應用程式在不同環境中具有高度的可配置性和靈活性。
{: .block-danger }

---

### V. Build, release, run

> Strictly separate build and run stages
{: .block-tip }

> 嚴格區分構建和運行階段

![](https://12factor.net/images/release.png)

在 Twelve-Factor App 中，Build、Release 和 Run 是三個獨立的階段，每個階段都有明確的職責和流程，
這樣可以確保應用程式的部署過程具有高度的可控性和可靠性。

-   Build Stage: 在這個階段，應用程式的原始碼被轉換為一個可執行的 Image 或者 Executable
    -   Maven, Gradle 等構建工具會在這個階段負責編譯程式碼、打包依賴、生成可執行的 Artifact
-   Release Stage: 在這個階段，構建好的 Image 或者 Executable 發送到對應的 Registry
    -   Docker Hub、AWS ECR、Google Container Registry
-   Run Stage: 在這個階段，構建好的 Image 或者 Executable 被部署到對應的環境中運行
    -   Kubernetes、AWS ECS、Google Cloud Run

這三個階段要嚴格的分離，例如在 RunTime 中程式碼已經是不可修改的狀態，不允許在 RunTime 中自行修改 Source Code 或 Compiled Code，
這樣就違反了 Build 和 Run 的分離原則。

> 每個 Release 都應該有其唯一的 ID，這樣就能確保每次部署都是 Rollbackable 
{: .block-danger }

---

### VI. Processes

> Execute the app as one or more stateless processes
{: .block-tip }

> 將應用程式作為一個或多個無狀態的進程來執行

程式應該是無狀態的，這樣就能確保應用程式在不同實例之間具有高度的可擴展性和可靠性。
所有資料應該透過 [IV. Backing Services] 中定義的外部服務來存儲，這樣就能確保應用程式的狀態不會依賴於特定的實例，
並且可以在需要時輕鬆地擴展或縮減實例的數量。

[IV. Backing Services]: ./2026-01-29-the_12_factor_app#iv-backing-services

> 無狀態的應用程式可以更容易地實現水平擴展，因為每個實例都不依賴於其他實例的狀態

> 這裡要特別提到即使是 Session 也要存放在外部服務中，例如 Redis，這樣就能確保在多實例的環境中，
> 使用者的 Session 可以在不同實例之間共享，提升使用者體驗。而不是放於 `/tmp` 或者 Memory
{: .block-danger }

---

### VII. Port binding

> Export services via port binding
{: .block-tip }

> 透過端口綁定來導出服務

應用程式應該要自包含 Port Binding 的能力，這樣就能確保應用程式在不同環境中具有高度的可移植性和靈活性。
最好的反例就是 Apache HTTP Server，這種傳統的 Web Server 需要在配置文件中指定 Port Binding 的方式，
因此要修改 Port Binding 的方式就需要修改 Apache HTTP Server 的配置，這樣就降低了應用程式的靈活性。

> 傳統 Http server 需要自己去特定配置檔案目錄中修改 Port Binding 位置，不方便也容易造成複雜度上升

以 Spring Boot 為例，現在主流的方式不再是 Tomcat 然後再部署 Spring Boot，而是在 Spring Boot 中內嵌入 Tomcat，
這樣 Spring Boot 本身就具有 Port Binding 的能力，無論在哪個環境中都能夠直接運行，而不需要依賴 Web Server。

> 現代後端框架目前基本都已經內建 Port Binding 的能力了，畢竟 12-Factor App 的原則已經提出了十多年了，這個原則也已經成為現代後端框架的標準設計模式了。
{: .block-danger }

---

### VIII. Concurrency

> Scale out via the process model
{: .block-tip }

> 通過進程模型來實現水平擴展

![](https://12factor.net/images/process-types.png)

水平擴展已經是現代雲端應用程式的基本需求了，由於應用程式是無狀態的，因此水平擴展可以通過增加更多的實例來實現。
目前水平擴展也有其層級，例如以下:
1.  Infrastructure Level: 例如增加更多的 VM 來運行應用程式
    -   AWS EC2
2.  Orchestration Level: 例如使用 Kubernetes 來管理和擴展 Pod 的數量
    -   Kubernetes Horizontal Pod Autoscaler
3.  Application Level: 例如在應用程式內部使用多線程或者非同步的方式來處理更多的請求
    -   通常在 Microservice 的架構下，應用程式內部的水平擴展已經不是主要的擴展方式

> IaaS (Infrastructure as a Service) 的架構下程式開發者依然要自己負責 HPA 這個層級的擴展

> PaaS (Platform as a Service) 的架構下程式開發者不需要自己負責 HPA 這個層級的擴展

> 在 Twelve-Factor App 提出的時間 2011，Docker、Kubernetes 等容器化技術還沒有出現，因此當時的水平擴展主要是通過增加更多的進程來實現的，
> 不過在當前的雲原生環境中，水平擴展更多是通過增加更多的容器實例來實現的，但這個原則仍然適用，因為每個容器實例本質上也是一個獨立的進程。
{: .block-danger }

---

### IX. Disposability

> Maximize robustness with fast startup and graceful shutdown
{: .block-tip }

> 通過快速啟動和優雅關閉來最大化應用程式的健壯性

實際上大多數程式開發者能控制的是 Graceful Shutdown 的部分，因為快速啟動通常是由底層的框架或者容器來控制的，
例如 Spring Boot 的啟動時間通常是由 JVM 與 Tomcat 的啟動時間來決定的，開發者能做的優化空間有限。
但是 Graceful Shutdown 是完全由開發者來控制的，這裡的原則是當應用程式接收到終止信號時，應該能夠優雅地關閉，例如:
-   在接收到 SIGTERM 信號時，目前正在處裡的請求是否要完成?
-   如果是交易類的應用程式，應該要確保交易的 Atomicity
-   是否要在關閉前釋放資源，例如資料庫連線等 ...

> [Crash-only software] 的設計理念，應用程式應該能夠在崩潰後快速重啟，並且能夠自動恢復到正常狀態，這樣就能確保應用程式的高可用性和可靠性

> Docker 在關閉容器時會先發送 SIGTERM 信號給容器內的應用程式，讓它有機會進行優雅關閉，如果應用程式沒有在指定的時間內完成關閉，Docker 才會強制終止容器，這樣就能確保應用程式在關閉時能夠有機會釋放資源並且完成正在處理的請求

[Crash-only software]: https://en.wikipedia.org/wiki/Crash-only_software

> 除此之外當然也要應對 Sudden Death 的情況，例如當容器被強制終止時，應用程式應該能夠在下次啟動時自動恢復到正常狀態，而不會因為之前的非正常關閉而導致資料損壞或者其他問題
{: .block-danger }

---

### X. Dev/prod parity

> Keep development, staging, and production as similar as possible
{: .block-tip }

> 保持開發、測試和生產環境盡可能相似

開發環境、測試環境和生產環境之間的差異越小，部署的風險就越小，這樣就能確保應用程式在生產環境中能夠正常運行，而不會因為環境差異而導致問題。
例如在開發環境中使用 Docker Compose 來模擬生產環境中的 Kubernetes 部署，
這樣就能確保在開發環境中測試的配置和依賴與生產環境中的一致，從而降低部署的風險。

-   Time gap: 開發者要多久才能將代碼使用在生產環境中?
-   Personnel gap: 開發者和運維人員之間的溝通和協作是否順暢，是否分離了開發和運維的職責
-   Tools gap: 開發環境和生產環境使用的工具和技術是否一致，例如使用相同的容器化技術、相同的配置管理工具等
    -   開發時使用 SQLite，正式上線卻使用 MySQL 就是一個 Tools gap 的例子

|   |  Traditional app |  Twelve-Factor App  |
|---|---|---|
| Time between deploys | Weeks | Hours |
| Code author vs code deployer | Different people | Same people |
| Dev vs production environment | Divergent | As similar as possible |

> 上述的三個 gap 都會增加部署的風險，因為開發環境和生產環境之間的差異越大，就越有可能在部署時遇到問題，
> 例如配置錯誤、依賴不一致等，從而導致應用程式在生產環境中無法正常運行

例如程式可以使用抽象層來支援不同後端服務，但還是要盡量保持與生產環境中使用的服務一致，例如以下的表格:

| Type | Language | Library | Adapter |
| Database | Ruby/Rails | ActiveRecord | MySQL, PostgreSQL, SQLite |
| Queue | Python/Django | Celery | Redis, RabbitMQ, Beanstalkd |
| Cache | Ruby/Rails | ActiveSupport::Cache | Memory, Filesystem, Memcached |

> 其中尤其是 Backing Services 的差異會導致部署的風險增加，例如在開發環境中使用本地的 MySQL 服務，
> 而在生產環境中使用 AWS RDS，這樣就會導致配置和依賴的差異，從而增加部署的風險。
{: .block-danger }

---

### XI. Logs

> Treat logs as event streams
{: .block-tip }

> 將日誌視為事件流

Microservice 的架構下，Log 應該有同一管理的方式，例如 ELK, Graylog, Cloudwatch 等等。
開發時期可以透過 console 來查看時間排序下的 log，上到環境則應該透過集中服務來收集、聚合和分析 log。

這裡 Log 應該透過結構化的方式進行儲存 (例如 JSON)，這樣就能確保 log 的可讀性和可分析性，並且可以更容易地進行搜尋和過濾。
但在 stdout 中依然可以保持文字格式的輸出，這樣可以即時查看 log 的內容。

> 傳統作法會是每個服務自己控制 log 的輸出位置，例如寫在本地的檔案系統中，這樣就會導致 log 分散在不同的實例中，難以集中管理和分析

> 12-Factor App 的原則是將 log 視為事件流，應該將 log 輸出到專用服務，這樣就能確保 log 的集中管理和分析，並且可以更容易地追蹤和調試應用程式的行為。
{: .block-danger }

---

### XII. Admin processes

> Run admin/management tasks as one-off processes
{: .block-tip }

> 將維護/管理任務作為一次性進程來運行

即使是管理任務也應該遵循前面提到的原則，例如使用相同的代碼庫、相同的配置、相同的依賴等，這樣就能確保管理任務在不同環境中具有高度的一致性和可靠性。
例如在 Kubernetes 中，可以使用 Job 來運行一次性的管理任務，這樣就能確保管理任務的執行環境與應用程式的運行環境一致，從而降低管理任務的風險。

這些一次性任務應該要有例如 Shell Script 的工具來啟動，並且在 Script 中確保使用與應用程式相同的配置和依賴，例如:
-   Django: `python manage.py migrate`
    -   該指令將 Python 中的模型配置與資料庫中的結構進行同步，確保資料庫的 Schema 與 Django 的模型定義保持一致，這是一個典型的管理任務
-   Spring Boot: `java -jar app.jar --spring.profiles.active=prod`
    -   該指令將 Spring Boot 應用程式啟動，並且指定使用 prod 的配置，這樣就能確保管理任務在與應用程式相同的環境中運行

> 這些一次性任務應該也要跟 Release 同樣發布，這樣就能確保管理任務的版本與應用程式的版本一致，從而降低管理任務的風險。

> 例如每次部署後都需要初始化資料庫，那麼初始化的腳本應該也要跟應用程式的 Release 一起發布，
> 這樣就能在每次部屬後自動執行初始化腳本，確保資料庫的狀態與應用程式的版本保持一致，從而降低部署的風險。
{: .block-danger }

> 以上就是 12-Factor App 的十二個原則，這些原則幫助開發者構建可擴展、可維護和可部署的應用程式。
> 所以如果未來要開發一個 Cloud Native 的應用程式，建議一定要遵循這些原則，這樣就能確保應用程式在不同環境中具有高度的可移植性和可靠性。
> ##### Last Edit
> 01-29-2026 00:32
{: .block-warning }