# 无人值守安装Ubuntu

## 实验流程
1. 手动安装Ubuntu后得到"自动配置描述文件"
在Ubuntu官网下载镜像文件
![下载镜像文件](./screenshots/downloadfile.png)
创建新的系统
![create1](./screenshots/createNewSystem.png)
![create2](./screenshots/createNewSystem2.png)
![create3](./screenshots/createNewSystem3.png)
选择镜像盘
![choose](./screenshots/chooseIso.png)
![choose2](./screenshots/chooseIso.png)
网卡设置
![network](./screenshots/networkSettings.png)
有人值守安装
![有人值守](./screenshots/installWithManWatching.png)
![有人值守2](./screenshots/installWithManWatching2.png)
![有人值守3](./screenshots/installWithManWatching3.png)
![有人值守4](./screenshots/installWithManWatching4.png)

2. 制作包含user-data与meta-data的ISO镜像文件，代码如下：
'''
#user-data
#cloud-config
autoinstall:
  apt:
    geoip: true
    preserve_sources_list: false
    primary:
    - arches: [amd64, i386]
      uri: http://cn.archive.ubuntu.com/ubuntu
    - arches: [default]
      uri: http://ports.ubuntu.com/ubuntu-ports
  identity: {hostname: ub-clone-qlr, password: 123456,
    realname: qlr, username: yennefer}
  keyboard: {layout: us, toggle: null, variant: ''}
  timezone: Asia/Shanghai
  locale: en_US.UTF-8
  network:
    ethernets:
      enp0s3: {dhcp4: true}
      enp0s8: {dhcp4: true}
    version: 2
  ssh:
    allow-pw: true
    authorized-keys: []
    install-server: true
  storage:
    config:
    - {ptable: gpt, path: /dev/sda, wipe: superblock,
      preserve: false, name: '', grub_device: true, type: disk, id: disk-sda}
    - {device: disk-sda, size: 1MB, flag: bios_grub, number: 1, preserve: false,
      grub_device: false, type: partition, id: partition-0}
    - {device: disk-sda, size: 1GB, wipe: superblock, flag: '', number: 2,
      preserve: false, grub_device: false, type: partition, id: partition-1}
    - {fstype: ext4, volume: partition-1, preserve: false, type: format, id: format-0}
    - {device: disk-sda, size: -1, wipe: superblock, flag: '', number: 3,
      preserve: false, grub_device: false, type: partition, id: partition-2}
    - name: ubuntu-vg
      devices: [partition-2]
      preserve: false
      type: lvm_volgroup
      id: lvm_volgroup-0
    - {name: ubuntu-lv, volgroup: lvm_volgroup-0, size: -1, preserve: false,
      type: lvm_partition, id: lvm_partition-0}
    - {fstype: ext4, volume: lvm_partition-0, preserve: false, type: format, id: format-1}
    - {device: format-1, path: /, type: mount, id: mount-1}
    - {device: format-0, path: /boot, type: mount, id: mount-0}
  version: 1
#meta-data is empty
'''
在安装好的系统命令行中执行指令
'''
mkdir loopdir

mount -o loop ubuntu-16.04.1-server-amd64.iso loopdir

mkdir cd
 
rsync -av loopdir/ cd

umount loopdir

cd cd/

vim isolinux/txt.cfg
'''
将
'''
label autoinstall
  menu label ^Auto Install Ubuntu Server
  kernel /install/vmlinuz
  append  file=/cdrom/preseed/ubuntu-server-autoinstall.seed debian-installer/locale=en_US console-setup/layoutcode=us keyboard-configuration/layoutcode=us console-setup/ask_detect=false localechooser/translation/warn-light=true localechooser/translation/warn-severe=true initrd=/install/initrd.gz root=/dev/ram rw quiet
'''
添加至文件中后强制退出
3. 移除起初的虚拟机

4. 于SATA下按序挂载镜像安装文件与focal-init.iso

5. 启动虚拟机，待出现"Continue with autoinstall? (yes|no)"时输入"yes"开始进行无人值守安装。