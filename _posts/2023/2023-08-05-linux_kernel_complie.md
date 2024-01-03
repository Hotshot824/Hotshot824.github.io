---
title: "OS | Linux Kernel Compilation"
author: Benson Hsu
date: 2023-08-05
category: Jekyll
layout: post
tags: [OS, linux]
---

> 記錄一下如何編譯與更換 Linux kernel 版本，以用來進行開發測試 Linux kernel module。
{: .block-tip }

**Reference**: [Jserv: Linux 核心模組運作原理], [鳥哥私房菜: Linux 核心編譯與管理]

如果想要開發 Linux kernel module，就可能會碰到要更新 Kernel 的情況，這裡紀錄一下如何進行 Kernel 的編譯與安裝。
##### 1.取得 Source Code

有以下三種方法可以使用:
1.  使用 Distribution 提供的核心原始碼檔案。
2.  取得 [www.kernel.org] 上所提供的核心原始碼。
3.  保留原本設定：利用 Patch 升級核心原始碼。

其中使用 Patch 的話需要將間隔中的每個 patch 都進行 patch，想要由 3.10.85 升級到 3.10.89 的話，
那麼就得要下載 patch-3.10.86, patch-3.10.87, patch-3.10.88, patch-3.10.89 等檔案。

這裡使用 [www.kernel.org] 所提供的原始碼，其中:
-   mainline: 最新的、積極開發的版本，因此有較高的變化與更新頻率。
-   stable: 穩定版本，這些版本會包含 Mainline 的一些修復和改進，但不是全部都會收入。
-   longterm: 長期支持的版本，可以在生產環境內長時間穩定運行。

下載後解壓縮放置，這裡選擇放在 `/usr/src`:
```bash
tar -Jxvf ${linux_kernel} -C /usr/src/
```

##### 2.前處理與配置核心功能

開始配置前先記得刪除檔案中可能有的 Object file(.o) 和 Config，`mrproper` 會清除過去曾經配置的核心配置文件。

```bash
cd /usr/src/${linux_kernel}
make mrproper
make clean
```

詳細配置與說明看 [鳥哥私房菜: Linux 核心編譯與管理]，這裡直接複製原來的 Kernel config，這個 `.config` 就是核心的配置檔案。
也可以使用 `make menuconfig` 來進入文字圖形介面來進行配置，但是我們這裡使用原本的 Kernel config。

```bash
cp /boot/config-${old_linux_kernel} /usr/src/${linux_kernel}
```

##### 3.編譯核心檔案

這裡使用多核心數去進行編譯，因為編譯 Kernel 是一個很長時間的工作，這幾個核心可以同時進行編譯的行為，這樣在編譯時速度會比較快。
最後製作出來的資料是被放置在 `/usr/src/${linux_kernel}` 這個目錄下，之後才會進行安裝。

```bash
make -j ${core_number} clean bzImage modules
```
-   bzImage: 編譯核心
-   modules: 編譯模組

> Tip: 在這一步我遇到幾次編譯錯誤，要回頭去修改 `.config` 等設定。記錄一下最後的解決方法:  
> 主要是一些[系統簽章]檢查需要解決，參考中有正確配置的方法，還有編譯時的依賴項沒有安裝，遇到就安裝就好。

##### 4.實際安裝核心

**4.1 安裝模組與核心**

首先安裝 modules，會放置在 /lib/modules/$(uname -r) 目錄下，直接使用以下指令就好:
```bash
make modules_install
# check modules
ll /lib/modules/ 
```

核心則會放置在 `/boot` 下，並且檔名為 `vmlinuz` 開頭，這裡可以去看 [vmlinuz] 的歷史。這裡鳥哥有講如何配置多個內核模塊，
下面是不進行配置多模塊直接安裝的方法:

```bash
cp arch/x86/boot/bzImage /boot/vmlinuz-${linux_kernel_version}
chmod a+x /boot/vmlinuz-${linux_kernel_version}
# Backup config file
cp .config /boot/config-${linux_kernel_version}
cp System.map /boot/System.map-${linux_kernel_version}
gzip -c Module.symvers > /boot/symvers-${linux_kernel_version}
restorecon -Rv /boot
```

**4.2 編輯開機選單 (grub)**

`grub2-mkconfig` 是用來生成 grub 文件的，因為預設較新版本的 Kernel 會放在最前面作為預設的開機選單項目，
所以這裡應該會看到剛剛安裝的核心放在第一位出現才對，否則等等可能會用舊核心開機。
```bash
# CentOS
grub2-mkconfig -o /boot/grub2/grub.cfg
# Ubuntu
sudo update-grub
# Generating grub configuration file ...
# Found linux image: /boot/vmlinuz-${linux_kernel_version}
# Found initrd image: /boot/initramfs-${linux_kernel_version}
```

最後就是重新開機然後查看 Kernel 是否有成功更新，可以使用 `uname -a` 或 `uname -r`。

> ##### Note
> Last edit 08-05-2023 22:20，如果使用 VM 編譯前多開核心給機器，我是單核心編譯花了大約三小時。
{: .block-warning }


[Jserv: Linux 核心模組運作原理]: https://hackmd.io/@sysprog/linux-kernel-module#Linux-%E6%A0%B8%E5%BF%83%E6%A8%A1%E7%B5%84%E9%81%8B%E4%BD%9C%E5%8E%9F%E7%90%86
[鳥哥私房菜: Linux 核心編譯與管理]: https://linux.vbird.org/linux_basic/centos7/0540kernel.php#config

[www.kernel.org]: https://www.kernel.org
[vmlinuz]: https://en.wikipedia.org/wiki/Vmlinux

[系統簽章]: https://stackoverflow.com/questions/67670169/compiling-kernel-gives-error-no-rule-to-make-target-debian-certs-debian-uefi-ce