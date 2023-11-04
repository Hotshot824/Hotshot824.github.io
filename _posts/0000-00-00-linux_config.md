---
title: "Tool | Linux Config"
author: Benson Hsu
date: 0000-01-01
category: Jekyll
layout: post
tags: [linux, tool]
---

> Notes Linux config

### Change username

> 要改使用者名稱通常很麻煩，這個是一個我覺得比較好的做法，多了 Link 至少讓沒改到的地方能連結到新的 home  
> [How To Change Username On Ubuntu, Debian, Linux Mint Or Fedora](https://www.linuxuprising.com/2019/04/how-to-change-username-on-ubuntu-debian.html)

1.  Create a temporary user
    -   `sudo adduser tempuser`
    -   `sudo usermod -aG sudo tempuser`

2.  Login with tempuser
    -   `sudo usermod -l ${newusername} -d /home/${newusername} -m ${oldusername}`
    -   `sudo groupmod -n ${newusername} ${oldusername}`

3.  Create a symbolic link
    -   `sudo ln -s /home/${newusername} /home/${oldusername}`

4.  Login new username and delete temporary user
    -   `sudo userdel -r tempuser`

### Firewall

##### ufw (Uncomplicated Firewall)

```bash
# 如果要允許連線指定 port 可以輸入指令:
sudo ufw allow <port-number>
sudo ufw deny <port-number>

# 只允許特定 IP 才能連線的話，可以輸入以下指令:
sudo ufw allow from <IP> to any port <port-number>
sudo ufw deny from <IP> to any port <port-number>

# 只允許子網路可以連線到，可以輸入以下指令:
sudo ufw allow from <IP-with-mask> to any port <port-number>
sudo ufw deny from <IP-with-mask> to any port <port-number>
sudo ufw allow from 159.66.109.0/24 to any port 22

# 刪除已經建立的規則:
sudo ufw status numbered
# 知道指定編號可以輸入以下指令來刪除規則:
sudo ufw delete <rule-number>
```

<hr>

### Network config

##### ubuntu wifi config

`$ sudo vim /etc/netplan/50-cloud-init.yaml`

```yaml
# This file is generated from information provided by the datasource.  Changes
# to it will not persist across an instance reboot.  To disable cloud-init's
# network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    ethernets:
        eth0:
            dhcp4: true
            optional: true
    version: 2
    wifis:
        wl0:
            optional: true
            access-points:
                "SSID-NAME-HERE":
                    password: "PASSWORD-HERE"
            dhcp4: true
```

<hr>

##### debian static ip config

`sudo vim /etc/network/interface`

```
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug ens160
iface ens160 inet static
    address ${address}
    netmask ${netmask}
    gateway ${gateway}

# This an autoconfigured IPv6 interface
iface ens160 inet6 auto
```

`sudo systemctl restart networking.service`

<hr>

##### fix Wifi Mt7601u driver

How to fix wireless adapter Mt7601u not working, Can run correctly on kernel 5.15. 
[Reference](https://askubuntu.com/questions/1189490/ralink-technology-wireless-adapter-mt7601u-mercury-mw150uh-usb-not-working)

```bash
git clone https://github.com/jeremyb31/mt7601u.git
sudo dkms add ./mt7601u
sudo dkms install mt7601u/1.0
```

<hr>

##### [ZeroTier Route Config]
Install ZeroTier and add route to between vLan and Physical Lan

```bash
curl -s https://install.zerotier.com | sudo bash

sudo zerotier-cli join $NETWORK_ID
```
Add to zerotier network, and Authorize it at https://my.zerotier.com/network/$NETWORK_ID.  

*Configure the ZeroTier managed route:*

At my.zerotier.com/network/$NETWORK_ID -> Settings -> Managed Routes,  
adds another route to every device joined to the ZeroTier network.

|  Destination | (Via) |
| ---- | ---- |
| $PHY_SUB | $ZT_ADDR |
| 192.168.100.0/23 | 172.27.0.1 |

-   **Edit** `/etc/sysctl.conf` to uncomment net.ipv4.ip_forward. This enables forwarding at boot.

```bash
sudo sysctl -w net.ipv4.ip_forward=1
# Add you network interface to shell variables.
PHY_IFACE=eth0; ZT_IFACE=zt7nnig26
```

-   **Add** ip forwarding rules in iptables.

```bash
sudo iptables -t nat -A POSTROUTING -o $PHY_IFACE -j MASQUERADE
sudo iptables -A FORWARD -i $PHY_IFACE -o $ZT_IFACE -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i $ZT_IFACE -o $PHY_IFACE -j ACCEPT
# Save iptables rules for next boot.
sudo apt install iptables-persistent
sudo bash -c iptables-save > /etc/iptables/rules.v4
```

-   Last using `sudo iptables -L -v` to check iptables rules.

[ZeroTier Route Config]: https://zerotier.atlassian.net/wiki/spaces/SD/pages/224395274/Route+between+ZeroTier+and+Physical+Networks

### Other

##### ulimit

-   ulimit 可以用來限制 shell 執行程式所需的資源
    -   `ulimit [options] [limit]`
    -   [ulimit Man Page](https://ss64.com/bash/ulimit.html)

> ##### Last Edit
> 30-09-2023 ulimit.
{: .block-warning }