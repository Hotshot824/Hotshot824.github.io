---
title: "Note | Arch User Repository"
author: Benson Hsu
date: 2024-06-09
category: Jekylls
layout: post
tags: [Note]
---

> Notes for [Arch User Repository](AUR).
{: .block-tip }

透過這篇文章來介紹 AUR 跟使用方式。

### Introduction

> 因為是非官方維護的軟體，當然在安全性上的風險要使用者自己負責
{: .block-danger }

**[Arch User Repository]**(AUR) 就是 Arch Linux 的第三方軟體庫，這裡的軟體是由社群貢獻者維護的，而不是由 Arch Linux 官方維護的。
一些在其他常用 distribution 上如 Debain 的軟體 Arch 官方不一定有維護，就需要到 AUR 來尋找。

跟 Debian, Ubuntu 不同可以透過 `/etc/apt/sources.list` 來新增 nonfree, universe 這些 Repository，並透過 apt 來管理，
AUR 是 pacman 無法直接管理的，需要以手動的方式來進行安裝，所以會讓一些初學者感到困惑。

![](/image/2024/06-09-arch_user_repository/1.jpg)

從 [AUR Packages] 的網頁可以搜尋到所有在 AUR 上的套件，但是 AUR 其實並不是收錄任何軟體的 Binary 執行檔，
而是名為 PKGBUILD 的腳本文件，PKGBUILD 本身只有如何安裝該軟體的指令腳本而已。

在 PKGBUILD 中軟體的安裝很隨意，可以用任何方式進行，只要能把軟體安裝到系統，除此之外跟 pacman 幾乎沒有差異，
最終也會透過 pacman 來安裝與管理。

#### Advantages & Disadvantages

**Advantages**
-   最大的優點當然是高自由度，從基本的系統程式，到遊戲、Chrome、Vscode 都有人打包
-   安裝中的許多依賴都能依靠 PKGBUILD 內以腳本完成，並且因為是社群驅動的維護因此可以在上面找到最新的版本
-   同時 AUR 比官方的 Repository 大很多，所以 `pacman -Ss package` 找不到時，wiki 上都會註明 `you can install it from the AUR.`

**Disadvantages**
-   缺點也顯而易見，你不知道這個維護者會不會在其中塞入惡意程式
    -   [Malicious Software Packages Found On Arch Linux User Repository]
-   這些風險都要依靠用戶自己發覺。

> 為了方便大部分會使用如 yay, paru 這類的 AUR Helper 來管理 AUR 的套件，但是應該要牢記 AUR 的本質，並且官方的安裝方式依然是以手動的方式進行。
{: .block-warning }

---

### Attention

> 在開始使用 AUR 之前最好先了解一下這個 Package 的相關資訊，這樣可以避免一些不必要的風險。
{: .block-tip }

![](/image/2024/06-09-arch_user_repository/2.jpg)

1.  首先檢查該 Package 是由誰 **Maintaniner**, **Licenses** 是開源或者是官方發行，跟底下的用戶留言。
    -   這裡可以看一下軟體的來源是什麼地方
2.  有的 AUR Package 是需要自行編譯的，如果是一些比較大的 Package 可能會需要很多時間
    -   例如上圖是 visual-studio-code-bin，這是一個 -bin 版本的 Package，可以直接安裝不需要編譯
3.  如果是帶有 -git 的 Package，代表他的來源是從最新的 git 上面拉下來的，這樣的 Package 會是最新的版本比較不穩定，
Package maintainer 可能也沒時間做完整的測試，這樣的 Package 也要小心使用。

---

#### Getting started

1.  首先確定 `base-devel` 已安裝，他包含了一些基本的編譯工具，如: `gcc`, `make`, `autoconf`...
    -   `sudo pacman -S base-devel`
2.  最佳化 `/etc/makepkg.conf` 的設定，這裡可以設定一些編譯的參數來加速，詳細可以參考 [makepkg#Tips and tricks]

**/etc/makepkg.conf**
1.  `MAKEFLAGS` 設定編譯的核心數量，使用全部的核心數量:
    -   `MAKEFLAGS="-j$(nproc)"`
2.  `PKGEXT` 可以設定 Compression 的方式，預設是 `.pkg.tar.xz`:
    -   `PKGEXT='.pkg.tar'` 這樣就不會壓縮，`.tar` 是單純的打包
    -   `PKGEXT='.pkg.tar.lz4'` 這樣就會使用 `.lz4` 算法來進行壓縮

**/etc/pacman.d/mirrorlist**
1.  去 [Mirrorlist] 中找到一個比較快的 Server，這樣可以加速下載的速度 

最後記得更新一下 `sudo pacman -Syy`。

---

### Manual Installation

整個手動安裝過程可以分為 4 個步驟:
1.  Clone the AUR Package git repository.
2.  Follow the instructions of the PKGBUILD file.
3.  Install additional dependencies via pacman.
4.  Build and install the package.

這些過程其實都可以透過 AUR Helper 來完成，但是這裡要介紹的是手動的方式，以 `visual-studio-code-bin` 這個 Package 來做為範例。
1.  進到 visual-studio-code-bin 的 [AUR Packages] 頁面，點選 `Git Clone URL` 來 Clone 下來
2.  使用 git clone 到本地
    ```bash
    git clone https://aur.archlinux.org/visual-studio-code-bin.git
    ```
3.  進到 visual-studio-code-bin 的目錄，查看 PKGBUILD 的內容
    ```bash
    cd visual-studio-code-bin
    vim PKGBUILD
    ```
4.  使用 `makepkg -si` 來安裝，pacman 會自動安裝相依的套件，並打包成 `.pkg.tar.xz`
    -   `.pkg.tar.xz` 是 Arch Linux 的 Package 標準格式
5.  上面的步驟會在打包完成後自動安裝，手動安裝使用 `sudo pacman -U $PACKAGE_NAME` 來安裝

> 如果想查詢哪些 Package 是由 AUR 安裝的，可以使用 `pacman -Qm` 來查詢

#### BKGBUILD

> 在進入 PKGBUILD 的時候可以看到他的安裝寫法，這裡可以檢查一下他的安全性，看看是否有一些奇怪的指令或來源
{: .block-warning }

![](/image/2024/06-09-arch_user_repository/3.jpg)

這裡看到它 x86 的來源是 `https://update.code.visualstudio.com/${pkgver}/linux-x64/stable` 這是 Visual Studio Code 的官方更新來源，
所以至少它的來源是安全的。

---

### AUR Helper

這裡介紹常見的 AUR Helper: yay，yay 是由 Golang 寫的，把常見的操作都包裝成了一個指令就可以完成。yay 曾經缺乏維護導致被棄用，但是現在已經有人接手維護。
另外 AUR Helper 還有 `paru`, `trizen` 等等...

AUR Helper 同樣的也不屬於 Arch Linux 的一部分，所以也需要從 AUR 上面安裝。之前的軼事說明了一件事，AUR Helper 也是由社群維護的，
需要依賴於社群的力量來維護並不斷發展，所以使用稍舊的版本可能短期內沒有問題，但隨著版本的更新可能會導致他停止工作。

> yay 的官方 Github [yay's Github]

1.  官方的安裝步驟如下:
    ```bash
    pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    ```
2.  yay 的使用上跟 pacman 很類似，例如以下:
    ```bash
    # Search Package
    yay package
    # Install Package
    yay -S package
    # Remove Package
    yay -R package
    # Update Package
    yay -Syy
    yay -Syu 
    ```

yay 在安裝時對於 dependencies 會自動安裝，並且優先去 Arch Linux 的官方 Repository 找，如果找不到才會去 AUR 上面找，
並且在安裝過程中會詢問使用者是否要查看 PKGBUILD 的內容，這樣可以避免一些不必要的風險。

> yay 會把 Cache 存放在 `~/.cache/yay`，如果想要清除 Cache 可以使用 `yay -Sc` 來清除

> 透過 yay 安裝的 AUR Package 也可以透過 `pacman -Qm` 來查詢

> ##### Last Edit
> 06-12-2024 09:07
{: .block-warning }

[Arch User Repository]: https://wiki.archlinux.org/title/Arch_User_Repository
[AUR Packages]: https://aur.archlinux.org/packages
[Malicious Software Packages Found On Arch Linux User Repository]: https://thehackernews.com/2018/07/arch-linux-aur-malware.html?m=1

[makepkg#Tips and tricks]: https://wiki.archlinux.org/title/Makepkg#Tips_and_tricks
[Mirrorlist]: https://archlinux.org/mirrorlist/

[yay's Github]: https://github.com/Jguer/yay