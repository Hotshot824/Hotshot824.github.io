---
title: "Tool | Virtual Machine"
author: Benson Hsu
date: 1970-01-01
category: Jekyll
layout: post
tags: [linux, tool]
---

> Notes How to using virtual machine tool.
{: .block-tip }

### 1. ESXI

##### 1.1 ESXI 5.5 import OVF

> Environment: VMware Player 16, ESXI 5.5
{: .block-warning }

因為 5.5 是非常老舊的版本了，所以在匯入 OVF 檔案時會有很多問題，這裡記錄下如何解決

1.  因為 5.5 不支援 SHA256，改用 SHA1 的方式匯出 OVF 檔案
    -   `ovftool.exe --shaAlgorithm=SHA1 /path/to/the/original/ova_file.ova /path/to/the/new/ova/file-SHA1.ova`
2.  Unspported hardware family 'vmx-18'
    -   `.ovf` 找到 `<VirtualSystemType>vmx-18</VirtualSystemType>` 改成 `<VirtualSystemType>vmx-8</VirtualSystemType>`
3.  檔案 ovf_file.ovf 未通過完整性檢查，可能在傳輸過程中已損毀。
    -   `.mf` 找到 `SHA1(ovf_file.ovf)= 5ba21a516c7b499e22c3463e4bd0596ab5336c4e` 刪除

**No support for the virtual hardware device type '20'**

ESXI 5.5 不支援 NVME Controller，下面整段替換

```
<Item>
<rasd:Address>0</rasd:Address>
<rasd:Description>NVME Controller</rasd:Description>
<rasd:ElementName>nvmeController0</rasd:ElementName>
<rasd:InstanceID>3</rasd:InstanceID>
<rasd:ResourceSubType>vmware.nvme.controller</rasd:ResourceSubType>
<rasd:ResourceType>20</rasd:ResourceType>
</Item>
```

```
<Item>
    <rasd:Address>0</rasd:Address>
    <rasd:Description>SCSI Controller</rasd:Description>
    <rasd:ElementName>scsiController0</rasd:ElementName>
    <rasd:InstanceID>3</rasd:InstanceID>
    <rasd:ResourceSubType>lsilogic</rasd:ResourceSubType>
    <rasd:ResourceType>6</rasd:ResourceType>
</Item>
```

-   invalid configuration for device '0'
    -   找到 `<vmw:Config ovf:required="false" vmw:key="videoRamSizeInKB" vmw:value="262144"/>` 改成 ` <vmw:Config ovf:required="false" vmw:key="videoRamSizeInKB" vmw:value="128000"/>`

> 這樣應該就能成功部屬了，但是詳細會有什麼問題還沒測試過

<hr>

### 2. Virtualbox

##### 2.1 Vboxmanage

```bash
Virtual box指令操作
手動相關指令說明:
 新建一個名為「New VM」的虛擬機器
vboxmanage createvm -name 「New VM」 -register

 設定「New VM」的記憶體是128MB並開啟acpi 設定第一開機碟為dvd 以及新增一個網路介面
vboxmanage modifyvm 「New VM」 -memory 「128MB」 -acpi on -boot1 dvd -nic1 intnet

 建立一個虛擬硬碟名為「newhd.vdi」  大小為 4000MB
vboxmanage createvdi -filename 「newhd.vdi」 -size 4000 -register

 將「New VM」的 hda 設定為「newhd.vdi」虛擬磁碟
vboxmanage modifyvm 「New VM」 -hda 「newhd.vdi」

 將在"/home/file/iso.iso"的ISO映像檔 設定到 名為 dvd的光碟映像檔庫
vboxmanage registerimage dvd /home/file/iso.iso

 設定名為「New VM」的 dvd裝置為 /home/file/iso.iso
vboxmanage modifyvm 「New VM」 -dvd /home/file/iso.iso

 設定「New VM」所使用的 VRDP 的連接Port為 3390
vboxmanage modifyvm 「New VM」 -vrdpport 3390

 啟動 VRDP
VBoxVRDP -startvm 「New VM」

----- List function

 查詢目前vbox上有設定多少個vm
vboxmanage list vms

 查看支援的 OS Type
vboxmanage list ostypes

 查看運行中的 VM
vboxmanage list runningvms

 其它可以list的指令
vboxmanage list hostdvds
vboxmanage list hostinfo
vboxmanage list hddbackends
vboxmanage list systemproperties
vboxmanage list dhcpservers
vboxmanage list hdds
vboxmanage list dvds

 指令啟動vm
vboxmanage startvm "VM name" --type headless (用背景啟動，不加上--type headless參數可能會有錯誤!!)
```

<hr>

##### 2.2 Autostart Virtualbox VMs

How to autostart virtual machine by systemctl. [reference]


1. Create a systemd service file.

`sudo vim /etc/systemd/system/$service-filename`
``` systemctl.service
[Unit]
Description=VBox Virtual Machine %i Service
Requires=systemd-modules-load.service
After=systemd-modules-load.service

[Service]
Restart=always
RestartSec=3
User=%u
Group=vboxusers
ExecStart=/usr/bin/VBoxHeadless -s %i
ExecStop=/usr/bin/VBoxManage controlvm %i savestate

[Install]
WantedBy=multi-user.target
```
- change `%i` to you virtual machine UUID or name.
- `%u` is you virtual machine manager username.

2. reload systemd service file and enable service.
``` bash
sudo systemctl daemon-reload
sudo systemctl enable $service-filename
sudo systemctl start $service-filename
```

3. check virtual machine is runing `vboxmanage list runningvms`

> ##### Last Edit
> 10-01-2023 12:22
{: .block-warning }


[reference]: http://www.ericerfanian.com/automatically-starting-virtualbox-vms-on-archlinux-using-systemd/