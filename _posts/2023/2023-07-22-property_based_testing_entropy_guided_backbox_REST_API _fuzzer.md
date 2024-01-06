---
title: "Paper | BenFuzz: A Property Based Testing and Entropy Guided Blackbox REST API Fuzzer"
author: Benson Hsu
date: 2023-07-22
category: Jekyll
layout: post
tags: [software, software_qualitiy]
---

> Benjamin Chen, "BenFuzz: A Property Based Testing and Entropy Guided Blackbox REST API Fuzzer", 2022. 
> 陳睿瑜, 基於特性測試與資訊熵之黑箱 REST API 模糊測試, 2022. 
{: .block-tip }

### 1. Intorduction 

REST API 為大多數前端後端與伺服器溝通型態，REST API 有著相當大的使用群體但其安全性或品質，
還是需要經由軟體測試，但背後實作的方式各有不同，所以對於 REST API 有蠻多工具可以去做測試。

論文提出以 REST API 回應之訊息熵作為變異參考依據，以及 Schemathesis[17] 中提到的基於特性的測試方法做結合，
檢測出相關的弱點，讓黑箱測試有了具有方向性的變異策略，使其能有更好的測試覆蓋率與弱點偵測，
去找到規格上與實作出的服務內容不符合的點及伺服器對於請求的處理是否能正確處理，得以找到 500 伺服器崩潰或錯誤問題，
論文也提供完整的前後端讓測試者能操作網路頁面就能做測試，達到開箱即用，也將其容器化方便做成 CI/CD 測試的一環。

### 2. Background

**2.1 [REST API]**

REST API（Representational State Transfer Application Programming Interface）是一種基於 HTTP 協定的**設計風格**，
用於設計和開發網路應用程式的接口，支援資源的狀態和操作的表達，促進了不同系統之間的資訊交換和通訊。

**2.2 [OPEN API] and Swagger**

Swagger（現在稱為OpenAPI）是一種用於OpenAPI 是用於描述 API 資訊的文件，包括 API 的端點、參數、輸出入格式、說明、認證等，
本質上它是一個 Json 或 Yaml 文件，而文件內的 Schema 則是由 OpenAPI 定義。它允許開發人員、團隊和企業在設計、
開發和使用 API 時更加方便和有效地進行溝通、理解和測試。

```yaml
openapi: 3.0.0
info:
  version: 1.0.0
  title: Sample API
  description: A sample API to illustrate OpenAPI concepts
paths:
  /list:
    get:
      description: Returns a list of stuff              
      responses:
        '200':
          description: Successful response
```
> 以上 OpenAPI Yaml 描述了一個名為 "Sample API" 的 API，該 API 具有一個 /list 的路徑可使用 get 來獲取回應。

**2.3 Fuzz Testing**

模糊測試 (Fuzz Testing) 是基於產生隨機且非預期的輸入，進而觸發目標程式非預期錯誤的一種自動化軟體測試技術。

模糊測試在多個領域都有相應的實作項目，能夠有效地發現程式異常、邏輯錯誤、開發人員設計的瑕疵及非預期的記憶體錯誤，
進而提高程式可靠度及軟體品質。模糊測試目前分為三大類白箱、灰箱、黑箱，依是否能獲得原始碼來分類。

**2.4 Property Based Testing**

-   基於範例的測試(Example Based Testing)，基於範例的測試通常要人工寫出測試範例，這樣就會有局限性，
因為要人工產生的範例會受限於思考範例的盲區跟上限。
-   基於特性測試(Property Based Testing)，我們可以基於要測試的函式，對其特性或運作邏輯，去做特性測試。以下將舉例加法函式在傳統測試與
特性測試的差異性。

Example，假設測試一個加法函數:  
-   傳統測試:  
給定測資跟解答，才能驗證是否可行，如 1+1=2 為一個測試點。
-   特性測試:  
用交換律 `A+B=B+A`、結合律`(A+B)+C=A+(B+C)`來做到邏輯上的驗證，這些特性是已知的數學性質，
如果函數是正確實現的，它們應該始終成立。測資的部分透過隨機產生，這樣不但測試資料更加多元，
也能減少降低人工產生測試資料的時間成本，從而使得測試資料更具多樣性和覆蓋性。

特性測試包含了三個架構:  
1. **Arbitrary 亂數產生器**  
是一種亂數產生的策略，當我們指定資料型別時，我們可以定義符合這個資料型別的亂數產生方式
2. **Generator 測試產生器**  
測試時依據亂數產生器產生出測試資料的值，這時候我們可以拿到值去帶入函數做測試
3. **Shrinker 誤區識別器**  
當測試結果不符合預期的時候，我們可以透過他找到錯誤的邊界

**2.4.1 [Hypothesis]**

Hypothesis[7] 是基於特性測試在 Python 上實作的函式庫，開發者可以設計自己的特性測試，其中提供了各類型的
**隨機產生器(Strategies)**，如 Int, Float, String，也可以由開發者能加入自己的隨機產生器，
也可以由 **Hypothesis-jsonschema**，將 **jsonschema** 轉換成隨機產生器，通過解析型別與內建的隨機產生器組織再一起。

> [7] DRMacIver. “Hypothesis”. URL: https://github.com/HypothesisWorks/hypothesis

**2.5 [Entropy](資訊熵)**

Entropy(資訊熵)，是用來計算資訊量的一個方法，可以根據其計算判斷出其資訊量或亂度的一個量衡，使開發者便於以其作為依據，
去判別一段文字或是位元組所代表的資訊量。

$Entropy (H(X)) = - \sum_{x} P(x) \log_{b} P(x)$

如果有一個系統 S 內存在多個事件 S={E1,...,En}，每個事件的機率分布 P={p1, ..., pn}，則每個事件本身的資訊本體為:  
$I_{e} = -\log_{2}{p_{i}}$ (對數以2為底，單位是 bit)

如英語有 26 個字母，假如每個字母在文章中出現次數平均的話，每個字母的訊息量為:  
$I_{e}=-\log_{2}{1 \over 26}=4.7$

以日文五十音平假名為相對範例，假設每個平假名在文章中出現的機率相等，每個平假名日語文字可攜帶的資訊量為:  
$I_{e}=-\log_{2}{1 \over 50}=5.64$

每個平假名所能攜帶的資訊量比英文字母更大，因為它有更多的字符選擇。這也意味著相比於英文字母，
使用平假名需要更多的 bit 來表示，因為它的字符集更無序。

### 3. Methodology and Implementation

**3.2 Entropy**

這裡作者提出一個假設:  
**「當經過 API 處理後的資訊熵提升代表其背後處理運算是更加複雜的，所以說資訊熵在此假設下與實際覆蓋度是有正相關的。」**
因此作者可以以此指標來進行評估當前變異的策略，以此提高程式的覆蓋度，讓模糊測器可以測試到更深成的程式邏輯，
進而提高找到弱點的所在或是觸發錯誤。

**3.3 Property Based Testing**

作者挑選了 表.3 的四條準則，因為這四條可以通過最少的運算去檢核出來，在不犧牲模糊測試效率的情況下去實作。

利用 Hypothesis 這個 Python 編寫的函式庫，在本篇論文中作為變異（Mutation）及模糊測試的主要架構，通過實時變更函式庫的設定值，
讓其依照資訊熵的變化調整參數或是去更新其種子。使用 表.3 的規範方式作為特性測試之邏輯條件，進而調整變異方式及偵測 API 的弱點。

![](../assets/image/2023/07-22-property_based_testing_entropy_guided_backbox_REST_API_fuzzer/1.png){:height="100%" width="100%"}

**3.4 Parallel Request Sending**

這裡作者使用 Async 進行發送請求與處理回應，來增加同一時間段內發送測試請求的效率與進行的測試數量。
使用 Python Library [Aiohttp]，是基於 Async 發送請求機制的 Library。

每個請求的生成機制為:  
1.  使用 Hypothesis 測試產生器所產生出的測試實例，URL 要通過 yarl 進行 hex 編碼後符合 RFC3986[12]。
2.  若該 API 需要 Token 授權，將其放入 OpenAPI 所指定的授權位置以及其授權格式(bearer、JWT 或其他)。
3.  依照 OpenAPI 所定義的請求格式送出測試請求，透過 Async 方式接受回應與計算熵(Entropy)與後續的調整變異。

**3.5 - 3.7 Technology**

- 3.5, 3.6 主要講述作者建立一個前後端系統可用來進行對目標的測試, 可以在前端上傳 OpenAPI 規格與相關授權 Token 後進行測試。  
- 3.7 則是 Docker image 建立實作，這裡不再贅述。

### 4. Results Evaluation

<!-- 預留標題，日後若要詳細補充可用 -->
<!-- **4.1 RQ1 Analysis of the Relationship Between Coverage and Information Entropy** -->

後續作者以 RQ1 - RQ3，分別去驗證 Entropy(資訊熵)與 Coverage(覆蓋率)之間的關係，常用服務的 API 測試，
以及非自行架設的 API 進行測試，詳細步驟可以見論文 Section 4。

**Other Section**

Section 5 為相關研究, 6 為結論, 7 為未來發展這裡不再說明。

> ##### NOTE
> 這篇論文主要是針對使用 REST API 服務的框架進行測試，以找出框架中不符合 REST API 規範的回應，或會對伺服器產生 500 Status 的錯誤，
> 其中關於 Property Based Testing, Fuzz Testing 的部分可以作為參考。
> Last edit 07-27 14:07
{: .block-tip }

[REST API]: https://en.wikipedia.org/wiki/Representational_state_transfer
[OPEN API]: https://en.wikipedia.org/wiki/OpenAPI_Specification
[Hypothesis]: https://hypothesis.readthedocs.io/en/latest/index.html
[Entropy]: https://en.wikipedia.org/wiki/Entropy_(information_theory)
[Aiohttp]: https://docs.aiohttp.org/en/stable/