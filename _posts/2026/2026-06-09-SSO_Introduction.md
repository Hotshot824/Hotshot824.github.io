---
title: "Note | SSO Introduction"
author: Benson Hsu
date: 2026-06-09
category: Jekyll
layout: post
mermaid: true
tags: [software, authentication, oauth, jwt, sso]
---

> 這篇文章會從 SSO（Single Sign-On，單一登入）的基本概念開始介紹，接著說明 JWT 的結構，然後進入 OIDC（OpenID Connect）
{:.block-tip}

> 本文的目標是依照協定堆疊（Protocol Stack）的層次，由上而下逐步說明，讓讀者能夠清楚理解各個技術之間的關係，逐步了解概念到實作的過程
{:.block-warning}

### 1. SSO Introduction

> SSO 的重點是把登入集中到同一個 IdP (Identity Provider)，讓多個應用共用同一組驗證結果，而不是讓每個系統自己各做一套登入流程
{:.block-tip}

[Single Sign-On (SSO)] 的核心不是 **「一次登入就永遠不用登入」**，而是 **「讓多個系統共用同一個身分提供者（Identity Provider, IdP）與同一組登入結果」**。
對使用者來說，這表示少輸入一次密碼；對系統來說，這表示各服務不必各自處理帳密驗證、找回密碼、風險控管與登入狀態同步。

[Single Sign-On (SSO)]: https://en.wikipedia.org/wiki/Single_sign-on

因此 SSO 的主要解決的問題是：
- 使用者在多個產品間切換時，不需要重複登入
- 每個應用程式不必自己保存密碼驗證邏輯
- 登入政策可以集中在 IdP 上做，例如 MFA、裝置信任、封鎖風險帳號

**在這個流程裡面，主要的角色與概念如下：**

| Role | Description |
| :---: | --- |
| IdP (Identity Provider) | 負責驗證使用者身份的服務，例如 Google、Microsoft Entra ID、Auth0、Keycloak 等。 |
| RP (Relying Party) / Backend | 想要使用 IdP 提供的登入結果的應用程式，例如你的網站或應用。 |
| Session | IdP 或應用程式內部保存的登入狀態，用來記錄使用者是否已經登入，以及相關的資訊。 |
| User | 最終使用者，透過 IdP 進行身份驗證，並希望在多個應用程式間無縫切換。 |

實際上依然會使用到傳統的 Cookie、Session 等技術，但 SSO 的重點是把「驗證」這件事交給一個大家都信任的 IdP，
讓應用程式專注在「授權」和「使用者體驗」上，而不是自己處理帳密驗證的細節。

> 因此如果本來就理解傳統的登入流程設計，在理解 SSO 的機制上會更快上手，因為基本的概念並沒有改變

**典型的 SSO 工作流程：**

1. 使用者打開網站 (Backend)，網站發現自己沒有該使用者的登入狀態
2. 網站把使用者導向 IdP 的登入頁面
3. 使用者在 IdP 完成驗證與同意，並且 IdP 建立自己的 session
	-	IdP 的 session 在之後登入其他的 Backend 時會被重用，此時就能直接省略第三步的驗證過程，直接進到第四步
4. IdP 把結果帶回 Backend，通常會帶一個 token 或 code
5. 應用程式建立自己的 session，之後就不用再問 IdP 一次

> 如果把它講得更直白一點，SSO 其實就是 **「把登入這件事外包給一個大家都信任的地方」**。後面的 OIDC 只是把這個外包流程標準化

---

### 2. JWT format

> JWT 真正重要的部分是簽章，因為它決定了這個 token 是不是可信的
{:.block-tip}

[JWT (JSON Web Token)] 是 OIDC 裡最容易被誤解的部分。它看起來像一串亂碼，但本質上只是三段式字串：header、payload、signature。
JWT 本身不是「加密格式」，大多數情況下它只是可驗簽的 JSON 封裝；如果需要保密，才會進到 JWE 的領域。這裡的定義可對照 [RFC 7519]。

[JWT (JSON Web Token)]: https://en.wikipedia.org/wiki/JSON_Web_Token
[RFC 7519]: https://www.rfc-editor.org/rfc/rfc7519

#### 2.1 JWT Structure

> 實際上 JWT 就只是兩個 JSON 物件（header 和 payload）加上一個簽章的一個結構，然後用 Base64url 編碼起來，最後用點號 . 串在一起，
> 這樣就能以 Text 的形式在 HTTP header 或 URL 裡面傳遞
{:.block-tip}

JWT 其實就跟傳統的 Cookie + Session 沒有本質上的差別；同樣是存放在 Frontend Cookie 裡面。
所以如果 JWT 被人完整取走，同樣可以被用來冒充使用者；但如果 JWT 沒有被竊取，
幾乎是無法被偽造的，因為簽章是用 IdP 的私鑰簽的，沒有私鑰就無法產生有效的簽章。

**header.payload.signature**

實際上每一段都是 Base64url 編碼後的內容：

- header：
	-	描述簽章演算法，例如 `RS256`，這樣就知道要用什麼算法來驗證簽章
	-	通常還會有 `typ`，表示這是一個 JWT
- payload：
	-	放 claims，例如 `iss`、`sub`、`aud`、`exp`
	-	這些內容完全是由 IdP 去定義需要有哪些欄位，Backend 只能選擇相信或不相信裡面的資料
		-	主要有幾個標準欄位是 RFC 定義的，稱為 [Registered Claim] 
- signature：用來驗證內容沒有被改過
	-	將前兩段（header 和 payload）用點號串起來，然後用 IdP 的私鑰簽章，產生 signature
	-	Backend 拿到 JWT 後，可以用 IdP 的公開金鑰來驗證簽章，確保內容沒有被竄改過

[Registered Claim]: https://www.rfc-editor.org/rfc/rfc7519#section-4.1

**header**
```json
{
"alg":"RS256",
"typ":"JWT"
}
```
**payload**
```json
{
"iss":"https://idp.example.com",
"sub":"248289761001",
"aud":"Backend-id-123",
"exp":1910000000,
"iat":1909996400
}
```

前面兩個做完 Base64url 後，再加上簽章，就會變成一串像這樣的 JWT 放到 Frontend Cookie 或 HTTP header 裡面：

`eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2lkcC5leGFtcGxlLmNvbSIsInN1YiI6IjI0ODI4OTc2MTAwMSIsImF1ZCI6ImNsaWVudC1pZC0xMjMiLCJleHAiOjE5MTAwMDAwMDAsImlhdCI6MTkwOTk5NjQwMH0.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV`

#### 2.2 Common Claims

- `iss`：這顆 token 是誰發的
- `sub`：這顆 token 指向哪個使用者
- `aud`：這顆 token 是發給誰看的
- `exp`：過期時間
- `iat`：簽發時間
- `nonce`：把登入請求和回應綁在一起，避免 replay

其中最重要的是 `iss + sub` 的組合。`iss` 先把識別範圍限定在同一個 issuer，`sub` 再當作這個 issuer 底下穩定的使用者識別子；`email`、`name`、`preferred_username` 都不適合直接當主鍵。這個判斷可直接對照 [OpenID Connect Core] 的 ID Token 與 subject 定義。

[OpenID Connect Core]: https://openid.net/specs/openid-connect-core-1_0.html#IDToken

#### 2.3 What to Check When Verifying JWTs

> 驗證 JWT 的重點不是「讀一讀裡面的資料」，而是「驗簽章確定這個 token 是可信的」，
然後再去檢查 `iss`、`aud`、`exp`、`nonce` 等欄位來確保這個 token 是合法的、沒有過期的、而且是給自己的
{:.block-tip}

**以下是一個實際驗證 JWT 的流程：**
1. 先驗簽章，確認內容真的是該 IdP 發的
2. 再驗 `iss`、`aud`、`exp`
3. 如果流程有 `nonce`，也要比對 `nonce`
4. 不要只要拿到 payload 就直接相信裡面的資料

> JWT 是整個 SSO 流程中最關鍵的部分，因為它決定了這個 token 是不是可信的；如果 JWT 被竊取了，攻擊者就可以冒充使用者；如果 JWT 沒有被竊取，但驗簽章有一定的難度，那麼就幾乎不可能被偽造

---

### 3. OIDC

> OIDC 是把 OAuth 2.0 的授權流程補上身分，讓系統不只知道「有沒有權限」，也知道「現在登入的人是誰」。
{:.block-tip}

OIDC 是建立在 OAuth 2.0 上的 identity layer。OAuth 2.0 本來主要處理「授權」，也就是你能不能存取資源；OIDC 則是在這個流程上再補上「身份驗證」，
讓 Backend 可以知道使用者到底是誰。OpenID Connect Core 直接把它定義成 OAuth 2.0 上的一層簡單 identity layer。

#### 3.1 SSO 主流協定比較 (SAML vs OAuth 2.0 vs OIDC)

#### 3.1 SSO Main Protocols Comparison

雖然我們常在 SSO 的語境下提到這三者，但它們的設計初衷與應用場景有所不同：

| Feature | SAML 2.0 | OAuth 2.0 | OpenID Connect (OIDC) |
| :--- | :--- | :--- | :--- |
| **核心目的** | 身份驗證 (AuthN) & 授權 (AuthZ) | 授權 (AuthZ) | 身份驗證 (AuthN) |
| **主要角色** | 「使用者是誰」與「權限」 | 「Backend 能不能拿到資源」 | 「使用者是不是已被驗證」 |
| **資料格式** | XML (Assertion) | JSON (Access Token) | JSON (ID Token + Access Token) |
| **傳輸協定** | 較重 (SOAP, HTTP POST) | 輕量 (REST / JSON) | 輕量 (REST / JSON) |
| **主流場景** | 企業級應用 (Enterprise/B2B) | API 存取、第三方授權 | 現代 Web/Mobile、社交登入 |
| **關鍵標識** | XML Signature / Encryption | `access_token` | `id_token` + `scope=openid` |

這也是為什麼 OIDC 的 authentication request 必須包含 `scope=openid`。少了 `openid`，流程就只是純粹的 OAuth 2.0 授權，
無法提供標準化的身份資訊（Identity Layer）。可對照 [OpenID Connect Core]。
OAuth 2.0 是一個**授權框架**，只關心 Backend 能不能獲取 IdP 的資源；OIDC 則是在 OAuth 2.0 的基礎上加了一層**身份驗證**，
讓 Backend 不只知道「有沒有權限」，也知道「現在登入的人是誰」，誰在獲取資源。

[OpenID Connect Core]: https://openid.net/specs/openid-connect-core-1_0.html

> 因此在 OIDC 上我們能知道使用者的身份（`id_token` 裡的 `sub`），就一併完成了 Login 的功能，Backend 可以確認登入者是 IdP 所認證的使用者

#### 3.2 Authorization Code Flow

> 最簡單說明 OIDC 的方式就是用 Squence Diagram 把整個流程畫出來，這樣就能清楚看到前端、後端、IdP 之間的互動，以及 token 是在哪裡交換的
{:.block-tip}

對後端來說，OIDC 最常見、也最值得講清楚的就是 Authorization Code Flow。它的優點是 token 不會直接暴露在 user agent 裡面；相較之下，[implicit flow] 主要是歷史包袱，現在多半不建議新系統再採用。

下方介紹的流程就是 OIDC 的 Authorization Code Flow，這個流程的重點是把 token 的交換放在後端的安全通道裡面，避免 token 在前端暴露，增加安全性

> implicit flow 的流程則是直接在前端拿到 token，會少去掉後端交換 token 的步驟，但同時也會讓 token 在前端暴露，增加被竊取的風險，因此現在多半不建議新系統再採用 implicit flow

[implicit flow]: https://openid.net/specs/openid-connect-core-1_0.html#ImplicitFlowAuth

[Authorization Code Flow]: https://openid.net/specs/openid-connect-core-1_0.html#CodeFlowAuth

[Phase 1: Authorization Request (Front-channel)](./2026-06-09-SSO_Introduction.html#phase-1-authorization-request-front-channel)  
[Phase 2: Authentication & Consent](./2026-06-09-SSO_Introduction.html#phase-2-authentication--consent)  
[Phase 3: Authorization Response (Front-channel)](./2026-06-09-SSO_Introduction.html#phase-3-authorization-response-front-channel)  
[Phase 4: Token Exchange (Back-channel)](./2026-06-09-SSO_Introduction.html#phase-4-token-exchange-back-channel)  
[Phase 5: Session Establishment](./2026-06-09-SSO_Introduction.html#phase-5-session-establishment)  

```mermaid
%%{init: {'themeVariables': { 'fontSize': '16px' }}}%%

sequenceDiagram
    autonumber
    participant User as User
    participant Frontend as Frontend
    participant Backend as Backend
    participant IdP as Identity Provider

    rect rgb(240, 248, 255)
    Note over User, Backend: Phase 1: Authorization Request (Front-channel)
    User->>Frontend: Visit Client Frontend website
    Frontend->>Backend: Request protected resource (or click login)
    Backend->>Frontend: 302 Redirect to IdP
    Note right of Backend: With Backend_id, scope=openid,<br/>redirect_uri, state, nonce
    Frontend->>IdP: GET /authorize?params...
    end

    rect rgb(255, 250, 240)
    Note over User, IdP: Phase 2: Authentication & Consent
    IdP->>User: Display login page
    User->>IdP: Enter credentials for authentication
    IdP->>User: Display consent screen
    User->>IdP: Approve authorization
    end

    rect rgb(240, 255, 240)
    Note over Frontend, IdP: Phase 3: Authorization Response (Front-channel)
    IdP->>Frontend: 302 Redirect to Backend Callback
    Note left of IdP: With Authorization Code
    Frontend->>Backend: GET /callback?code=...&state=...
    end

    rect rgb(255, 240, 245)
    Note over Backend, IdP: Phase 4: Token Exchange (Back-channel)
    Backend->>IdP: POST /token (Using code + Backend_secret)
    Note right of Backend: Secure back-channel communication
    IdP->>Backend: Return ID Token & Access Token
    end

    rect rgb(245, 245, 245)
    Note over Frontend, Backend: Phase 5: Session Establishment
    Backend->>Backend: Verify ID Token (Signature & Claims)
    Backend->>Frontend: Establish Session / Set Secure Cookie
    Frontend->>User: Login successful, access protected page
    end
```

##### Phase 1: Authorization Request (Front-channel)
1.	首先 User 造訪 Frontend
2.	Frontend 發現沒有登入狀態
3.	於是 Backend 回應一個 302 Redirect
4.	把 User 導向 IdP 的 `/authorize` 端點

通常在這個階段會看到一個類似下面的 HTTP 請求，這是 Backend 把 User 導向 IdP 的 `/authorize` 端點，並且帶上必要的參數：

```http
GET /authorize?response_type=code&scope=openid%20email%20profile&Backend_id=Backend-id-123&redirect_uri=https%3A%2F%2Fapp.example.com%2Fcallback&state=abc123&nonce=n-0S6_WzA2Mj HTTP/1.1
Host: idp.example.com
```

類似上面這段 Http 將使用者導向 IdP 的 `/authorize` 端點，並且帶上必要的參數，例如 `response_type=code`、`scope=openid`、`Backend_id`、`redirect_uri`、`state` 說明 Backend 的身份、回調 URL、以及防止 CSRF 的 state 和 nonce

##### Phase 2: Authentication & Consent

> 這一步其實就是我們常見的跳轉到 Google、Facebook 等社交登入頁面，輸入帳號密碼，然後同意授權的流程
{:.block-tip}

使用者抵達 IdP 後，IdP 會先檢查使用者是否已經登入。若未登入，則引導使用者完成身份驗證（如輸入帳密、MFA 等）。驗證通過後，IdP 會詢問使用者是否同意授權該應用程式存取指定的資訊（如 email, profile），這就是所謂的「同意頁面」

> 同樣的我同意第三方應用程式存取我的基本資訊，但不代表我同意他們可以存取我的所有資料，例如 Drive、Photos 等，這就是 OAuth 2.0 的授權範圍（scope）概念

##### Phase 3: Authorization Response (Front-channel)

當使用者同意授權後，IdP 會透過瀏覽器（Front-channel）發送一個 302 Redirect，將使用者導回 Backend 原先指定的 `redirect_uri`。
此時 URL 中會包含一個臨時的 `code` (Authorization Code) 以及原先的 `state`。
Backend 收到後必須立即比對 `state` 是否與發起請求時一致，以防止 CSRF 攻擊。

> 這個 Code 可以讓 Backend 在後端安全地向 IdP 換取真正的 Token，而不會直接暴露在前端，這是 Authorization Code Flow 的核心安全設計
{:.block-warning}

##### Phase 4: Token Exchange (Back-channel)

這是 OIDC 最安全的步驟之一。Backend 取得 `code` 後，會直接從後端（Back-channel）向 IdP 的 `/token` 端點發送 POST 請求，
用授權碼換取真正的 Token。由於這是伺服器對伺服器的通訊，`Backend_secret` 可以安全地包含在請求中而不被瀏覽器看見。

```http
POST /token HTTP/1.1
Host: idp.example.com
Content-Type: application/x-www-form-urlencoded

grant_type=authorization_code&code=SplxlOBeZQQYbYS6WxSbIA&redirect_uri=https%3A%2F%2Fapp.example.com%2Fcallback&Backend_id=Backend-id-123&Backend_secret=secret
```

上面是一個 Client Backend 向 IdP 換取 Token 的範例請求，IdP 驗證這個請求無誤後會回傳 `id_token` (JWT) 與 `access_token`，
給予 Backend 用來確認使用者身份與存取資源的權限。這個過程完全在後端進行，增加了安全性，因為 token 不會暴露在前端。

##### Phase 5: Session Establishment

最後，Backend 會解析並驗證 `id_token` 的內容與簽章。確認使用者身份後，Backend 會在自己的系統中建立登入狀態（Session），
通常是發送一個加密且具備 `HttpOnly` 屬性的 Cookie 給瀏覽器。至此，使用者成功登入並可以存取受保護資源。

目前通常不會建議把 JWT 直接放在前端 Cookie 裡面，因為這樣會增加被竊取的風險；通常還是會存放在後端的 Session 裡面，
前端只拿到一個 session cookie，這樣如果想要竊取 JWT 就必須同時攻擊到 Backend 的 session 管理，難度會大幅增加；

> 如果直接把 JWT 放在前端，就算是 HttpOnly Cookie 也可能被竊取（例如 XSS 攻擊），因為 JWT 本身就是一個可被直接使用的 token，
攻擊者可以直接使用 JWT 來冒充使用者
{:.block-warning}

> 這部分涉及很多 Cookie 上的安全因素，最主要的因素還是 Session ID 相較於 JWT 來說殺傷力較小，有興趣的可以去另外查閱這部分的內容

[HttpOnly]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Set-Cookie#httponly

---

#### 3.3 Key OIDC Endpoints

> 在 OIDC 官方標準規範 [OIDC Connect core]、[OIDC-Discovery]中定義了幾個重要的端點，或許實作上會有些差異，但基本上這些端點是 OIDC 流程中不可或缺的部分
{:.block-tip}

[OIDC Connect core]: https://openid.net/specs/openid-connect-core-1_0.html
[OIDC-Discovery]: https://openid.net/specs/openid-connect-discovery-1_0.html

最重要的是 `.well-known/openid-configuration` 這個 discovery 端點，所有的 OIDC 實作都必須提供這個端點，
讓 Backend 可以自動發現 IdP 的相關資訊，例如 issuer、authorization endpoint、token endpoint、userinfo endpoint、jwks_uri 等等。
其餘端點可能會有路徑上的差異，但基本上都會有類似的功能。

- **`/.well-known/openid-configuration` (Discovery)**
	-	這是 OIDC 的進入點（遵循 [RFC 8414]），IdP 會在這個路徑提供一個 JSON 檔案，列出所有支援的端點
	-	這讓 Backend 只需要知道 Issuer 的 URL 就能自動完成大部分設定。
- **`/authorize` (Authorization Endpoint)**
	-	Backend 將 User 導向此處並帶上 `client_id`、`response_type=code`、`scope` 等參數
	-	它的任務是完成身分驗證（AuthN）並取得使用者的授權，通常 Client 跳轉就是到這個端點
- **`/token` (Token Endpoint)**
	-	屬於 Back-channel 的通訊端點。Backend 在取得 `code` 後，會在此端點使用 `client_secret` 進行身分驗證，
	並換取 `id_token`（身分資訊）、`access_token`（資源存取權限）及可能的 `refresh_token`
- **`/userinfo` (UserInfo Endpoint)**
	-	這是一個受保護的資源端點。當 Backend 拿到 `access_token` 後，可以向此端點請求更多關於使用者的詳細資料（如完整的 profile 或自定義 claims），
	這些資料可能因為體積太大而沒有直接放在 `id_token` 中。
- **`jwks_uri` (JWKS Endpoint)**
	-	回傳 **JSON Web Key Set**。這是一組公開金鑰，Backend 用它來驗證 `id_token` 的簽章。
	由於 IdP 可能會定期輪替（Rotate）金鑰，Backend 通常會快取這些金鑰並在簽章驗證失敗時重新抓取

[RFC 8414]: https://www.rfc-editor.org/rfc/rfc8414

#### 3.4 What the Backend Should Verify

> 後端在驗證 OIDC 流程中收到的 `id_token` 時，必須嚴格按照 OIDC 的規定來驗證內容，這些驗證不是裝飾，而是確保安全性的核心防線
{:.block-tip}

OIDC 規格要求 Backend 驗證 `iss` 必須和 discovery 回來的 issuer 一致，`aud` 必須包含自己的 Backend id，
`exp` 不能過期，`nonce` 也要對得上。這些不是裝飾，而是避免 token substitution、replay、和錯誤受眾使用的核心防線。

最實際的做法是：

1. 用 library 讀 discovery document
2. 用 JWKS 驗證 `id_token`
3. 檢查 `iss`、`aud`、`exp`、`nonce`
4. 驗證通過後，只把你真正需要的 user identity 存進自己系統的 session

> 這樣我們就能了解 OIDC 的整個流程，從前端的授權請求，到 IdP 的驗證與同意，再到後端的 token 交換與 session 建立，
每一步都有其安全考量與驗證要求，確保整個 SSO 流程的安全性與可靠性，後續會再寫一篇文章說明 NextAuth 的實作細節，
這些 Library 都是幫我們把這些驗證流程包裝起來，但理解底層的機制還是很重要的
{:.block-warning}

> ##### Last Edit
> 06-09-2026 23:44
{: .block-warning }


