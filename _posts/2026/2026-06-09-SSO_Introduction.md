---
title: "Backend | SSO Introduction"
author: Benson Hsu
date: 2026-06-09
category: Jekyll
layout: post
tags: [software, authentication, oauth, jwt, nextauth, sso]
---

> 這篇文章會從 SSO（Single Sign-On，單一登入）的基本概念開始介紹，接著說明 JWT 的結構，然後進入 OIDC（OpenID Connect），最後再解釋 NextAuth 在整個流程中的角色
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
| RP (Relying Party) / Client | 想要使用 IdP 提供的登入結果的應用程式，例如你的網站或應用。 |
| Session | IdP 或應用程式內部保存的登入狀態，用來記錄使用者是否已經登入，以及相關的資訊。 |
| User | 最終使用者，透過 IdP 進行身份驗證，並希望在多個應用程式間無縫切換。 |

實際上依然會使用到傳統的 Cookie、Session 等技術，但 SSO 的重點是把「驗證」這件事交給一個大家都信任的 IdP，
讓應用程式專注在「授權」和「使用者體驗」上，而不是自己處理帳密驗證的細節。

> 因此如果本來就理解傳統的登入流程設計，在理解 SSO 的機制上會更快上手，因為基本的概念並沒有改變

**典型的 SSO 工作流程：**

1. 使用者打開網站 (Client)，網站發現自己沒有該使用者的登入狀態
2. 網站把使用者導向 IdP 的登入頁面
3. 使用者在 IdP 完成驗證與同意，並且 IdP 建立自己的 session
	-	IdP 的 session 在之後登入其他的 Client 時會被重用，此時就能直接省略第三步的驗證過程，直接進到第四步
4. IdP 把結果帶回 Client，通常會帶一個 token 或 code
5. 應用程式建立自己的 session，之後就不用再問 IdP 一次

> 如果把它講得更直白一點，SSO 其實就是 **「把登入這件事外包給一個大家都信任的地方」**。後面的 OIDC 只是把這個外包流程標準化

---

### 2. JWT format

> JWT 的前兩段只是 Base64url 編碼的 JSON 物件，真正重要的部分是簽章，因為它決定了這個 token 是不是可信的
{:.block-tip}

[JWT (JSON Web Token)] 是 OIDC 裡最容易被誤解的部分。它看起來像一串亂碼，但本質上只是三段式字串：header、payload、signature。
JWT 本身不是「加密格式」，大多數情況下它只是可驗簽的 JSON 封裝；如果需要保密，才會進到 JWE 的領域。這裡的定義可對照 [RFC 7519]。

[JWT (JSON Web Token)]: https://en.wikipedia.org/wiki/JSON_Web_Token
[RFC 7519]: https://www.rfc-editor.org/rfc/rfc7519

#### 2.1 JWT Structure

> 實際上 JWT 就只是兩個 JSON 物件（header 和 payload）加上一個簽章的一個結構，然後用 Base64url 編碼起來，最後用點號 . 串在一起，
> 這樣就能以 Text 的形式在 HTTP header 或 URL 裡面傳遞
{:.block-tip}

**header.payload.signature**

實際上每一段都是 Base64url 編碼後的內容：

- header：描述簽章演算法，例如 `RS256`
- payload：放 claims，例如 `iss`、`sub`、`aud`、`exp`
- signature：用來驗證內容沒有被改過

```json
{
"alg":"RS256",
"typ":"JWT"
}
```

```json
{
"iss":"https://idp.example.com",
"sub":"248289761001",
"aud":"client-id-123",
"exp":1910000000,
"iat":1909996400
}
```

#### 2.2 Common Claims

- `iss`：這顆 token 是誰發的
- `sub`：這顆 token 指向哪個使用者
- `aud`：這顆 token 是發給誰看的
- `exp`：過期時間
- `iat`：簽發時間
- `nonce`：把登入請求和回應綁在一起，避免 replay

其中最重要的是 `iss + sub` 的組合。`iss` 先把識別範圍限定在同一個 issuer，`sub` 再當作這個 issuer 底下穩定的使用者識別子；`email`、`name`、`preferred_username` 都不適合直接當主鍵。這個判斷可直接對照 [OpenID Connect Core][oidc-core] 的 ID Token 與 subject 定義。{:.block-tip}

#### 2.3 What to Check When Verifying JWTs

1. 先驗簽章，確認內容真的是該 IdP 發的
2. 再驗 `iss`、`aud`、`exp`
3. 如果流程有 `nonce`，也要比對 `nonce`
4. 不要只要拿到 payload 就直接相信裡面的資料

換句話說，JWT 不是拿來「讀一讀就算了」，而是拿來「驗完之後再使用」。

---

### 3. OIDC

> OIDC 的角色是把 OAuth 2.0 的授權流程補上身分語意，讓系統不只知道「有沒有權限」，也知道「現在登入的人是誰」。
{:.block-tip}

OIDC 是建立在 OAuth 2.0 上的 identity layer。OAuth 2.0 本來主要處理「授權」，也就是你能不能存取資源；OIDC 則是在這個流程上再補上「身份驗證」，讓 Client 可以知道使用者到底是誰。OpenID Connect Core 直接把它定義成 OAuth 2.0 上的一層簡單 identity layer。{:.block-tip}

#### 3.1 The Difference Between OIDC and OAuth 2.0

- OAuth 2.0 回答的是「這個 client 能不能拿到資源」
- OIDC 回答的是「這個 user 是不是已經被驗證過」
- OAuth 2.0 的結果通常是 `access_token`
- OIDC 會多出 `id_token`

這也是為什麼 OIDC 的 authentication request 會包含 `scope=openid`。少了 `openid`，流程就只是 OAuth 2.0 授權，不是 OIDC 的身份驗證流程。可對照 [OpenID Connect Core][oidc-core]。

#### 3.2 Authorization Code Flow

對後端來說，OIDC 最常見、也最值得講清楚的就是 Authorization Code Flow。它的優點是 token 不會直接暴露在 user agent 裡面，因此通常是現代 web app 的預設選擇；相較之下，implicit flow 主要是歷史包袱，現在多半不建議新系統再採用。{:.block-warning}

```http
GET /authorize?response_type=code&scope=openid%20email%20profile&client_id=client-id-123&redirect_uri=https%3A%2F%2Fapp.example.com%2Fcallback&state=abc123&nonce=n-0S6_WzA2Mj HTTP/1.1
Host: idp.example.com
```

1. Client 把使用者導向 `/authorize`
2. IdP 驗證使用者，並確認 consent
3. IdP 把 `code` 帶回 callback
4. Client 用 `code` 去 `/token` 換回 `id_token` 和 `access_token`
5. Client 驗證 `id_token` 後，再建立自己的 session

```http
POST /token HTTP/1.1
Host: idp.example.com
Content-Type: application/x-www-form-urlencoded

grant_type=authorization_code&code=SplxlOBeZQQYbYS6WxSbIA&redirect_uri=https%3A%2F%2Fapp.example.com%2Fcallback&client_id=client-id-123&client_secret=secret
```

#### 3.3 Key OIDC Endpoints

- `/.well-known/openid-configuration`：discovery，用來取得端點與支援能力
- `/authorize`：使用者登入入口
- `/token`：用 code 換 token
- `/userinfo`：用 `access_token` 拿更多 user claims
- `jwks_uri`：拿公開金鑰來驗簽 `id_token`

#### 3.4 What the Backend Should Verify

OIDC 規格要求 client 驗證 `iss` 必須和 discovery 回來的 issuer 一致，`aud` 必須包含自己的 client id，`exp` 不能過期，`nonce` 也要對得上。這些不是裝飾，而是避免 token substitution、replay、和錯誤受眾使用的核心防線。{:.block-tip}

最實際的做法是：

1. 用 library 讀 discovery document
2. 用 JWKS 驗 `id_token`
3. 檢查 `iss`、`aud`、`exp`、`nonce`
4. 驗證通過後，只把你真正需要的 user identity 存進自己系統的 session

---

### 4. NextAuth

> NextAuth 是把 OIDC 接進 Next.js 的實作層，不是把協定知識拿掉；先懂流程，再讓它幫你省掉重複的程式碼。
{:.block-tip}

NextAuth 的價值是把 OIDC / OAuth 的細節包成 Next.js 好用的 auth 層。它幫你處理 redirect、callback、session 與 token 存取，但它不是把所有安全責任都吃掉；你還是要知道 provider 怎麼設定、callback 裡面有哪些資料可以用，以及 session 最後會長什麼樣子。{:.block-tip}

#### 4.1 How It Usually Connects to OIDC

如果 provider 本身是 OIDC 相容的，NextAuth 通常會先讀 `wellKnown` 的 discovery document，再依 provider 回傳的端點與能力完成授權流程，而不是手動拼 `/authorize`、`/token` 和 `/userinfo`。這個用法可對照 [NextAuth OAuth providers] [nextauth-oauth-providers] 與 [NextAuth Callbacks] [nextauth-callbacks] 的說明。

```js
import NextAuth from "next-auth"

export const authOptions = {
	providers: [
		{
			id: "my-oidc",
			name: "My OIDC",
			type: "oauth",
			wellKnown: "https://idp.example.com/.well-known/openid-configuration",
			clientId: process.env.OIDC_CLIENT_ID,
			clientSecret: process.env.OIDC_CLIENT_SECRET,
			authorization: {
				params: {
					scope: "openid email profile",
				},
			},
			idToken: true,
			checks: ["pkce", "state"],
		},
	],
	callbacks: {
		async jwt({ token, account }) {
			if (account) {
				token.accessToken = account.access_token
			}
			return token
		},
		async session({ session, token }) {
			session.accessToken = token.accessToken
			return session
		},
	},
}

export default NextAuth(authOptions)
```

#### 4.2 Why Callbacks Matter

NextAuth 最實用的地方，不只是「幫你登入」，而是它允許你在 `jwt()` 和 `session()` 之間傳遞你真的需要的資料。官方文件的建議很直接：如果你要把 access token 或 user id 帶到前端，就先放進 JWT，再從 session callback 轉出去。{:.block-tip}

- `jwt()`：登入時建立 token，之後每次 session 更新也會走
- `session()`：決定前端最後拿到哪些欄位
- `signIn()`：可以做允許名單、封鎖名單、網域限制
- `redirect()`：控制登入後跳轉的位置

#### 4.3 How to Think About NextAuth in Practice

我會把 NextAuth 視為「把 OIDC 接進 Next.js 的 adapter」，而不是「取代 OIDC 知識的魔法盒」。如果你不清楚 `id_token`、`access_token`、`wellKnown`、`pkce` 和 `session` 的差別，NextAuth 只是讓錯誤更晚爆出來而已。真正穩定的方式是：先把 OIDC 流程想清楚，再用 NextAuth 去實作。

[oidc-core]: https://openid.net/specs/openid-connect-core-1_0.html
[oidc-discovery]: https://openid.net/specs/openid-connect-discovery-1_0.html
[oauth2-rfc]: https://datatracker.ietf.org/doc/html/rfc6749
[rfc7519]: https://www.rfc-editor.org/rfc/rfc7519
[nextauth-providers]: https://next-auth.js.org/providers
[nextauth-oauth-providers]: https://next-auth.js.org/configuration/providers/oauth
[nextauth-callbacks]: https://next-auth.js.org/configuration/callbacks
[nextauth-example]: https://next-auth.js.org/getting-started/example

> ##### Last Edit
> 06-09-2026 23:44
{: .block-warning }


