---
layout: post
title: 토닉으로 grpc 연결
categories: [Esc]
tags: [linux, ubuntu, hardware, install]
teaser: "/assets/grpc-http2.jpg"
brief: 하드웨어에 설치 요약...
math: false
---

클라우드가 생긴 이후로 직접 서버를 인스톨할 일이 거의 없어졌습니다. 구형 PC가 남아 돌아도 물리머신을 돌리면 전기도 먹고 팬 소음도 있어서 이걸 24시간 구동하는 일이 없어요. 그런데 가끔 필요할 때가 있습니다. 가끔요. 테스트 머신이 필요할 때인데, 본격 서버에서 해보기에는 부담이 되거나 클라우스에서 무료로 해보기에는 시스템 자원이 너무 척박할 경우 필요해집니다. 그래서 놀고 있는 구형 컴퓨터 한 대를 마련했습니다.

10년 된 데스크톱 컴퓨터인데 클라우드에서 무료로 얻을 수 있는 사양과 비교할 수 없이 좋습니다. 실험용으로 며칠 구동할 게 있어서 이걸 쓰기로 했습니다. 데비안 계열의 우분투만 사용해봐서 이번에도 고민없이 우분투 서버 LTS로 정했습니다.

* <https://ubuntu.com/download/server>

이미지를 다운받아 USB에 심습니다. 윈도우라면 refus, 맥이라면 디스크유틸리티나 etcher 혹은 터미널에서 직접 dd 로 작업하시면 됩니다.

* <https://rufus.ie/ko/>
* <https://etcher.balena.io>


```
* Try or Install Ubuntu Server
  Ubuntu Server with the HWE kernel
  Boot from next volume
  UEFU Firmware Settings
```

이제 USB 를 PC에 꽂고 바이오스 부팅 옵션에서 UEFI 로 부팅하면 우분투 설치 부트로더가 뜹니다. 여기서 첫 번째를 선택해서 우분투 서버 인스톨을 진행합니다.

```
Choose the type of installation

Choose the base for the installation.
( ) Ubuntu Server
(*) Ubuntu Server (minimized)

Additional options
[ ] Search for third-party drivers
```

저는 미니를 선택했습니다. 조금 더 경량입니다. 그렇다고 아주 획기적으로 경량은 아닙니다.

```
Network configuration
Config at least one interface this server can to ...
NAME        TYPE        NOTES
[enp2s0]    eth     -
        ▶ EDIT IPv4
      Manual
        Subnet:     172.16.2.0/24
        Address:    172.16.2.106
        Gateway:    172.16.2.1
        Name servers:   8.8.8.8
        Search domains:
```

네트워크는 수동으로 잡았습니다. 공유기에 물려 있다 하더라도 서버는 DHCP 가 큰 의미가 없습니다. 나중에 모니터를 빼고 터미널을 통해 접근하려면 수동IP 가 속편합니다. 위 설정에서 다만 조심해야 할 것은 서브넷 마스크인데요. 윈도우에서 하듯이 255.255.255.0 으로 마스킹을 하면 안 됩니다. CIDR 표기법으로 넣어야 합니다. 그외 네임서버는 따로 없으니까 구글 꺼로 넣었고, 이 테스트 머신에 도메인 따위를 할당하지 않았기 때문에 Search domains 는 비워둬도 됩니다.

```
Proxy configuration
If this system requires a proxy to connect to the internet ...
Proxy Address:
```

다음은 프록시인데, 없으니까 그냥 비워두고 넘어가도 됩니다.

```
Ubuntu archive mirror configuration
If you use an alternative mirror for Ubuntu, enter its details ...
Mirror adress: http://archive.ubuntu.com/ubuntu/
The mirror location is being tested. \
    Hit: 1 http://archive.ubuntu.com/ubuntu noble InRelease ...
    Get: 2 http://archive.ubuntu.com/ubuntu noble-updates InRelease ...
```

뭐, 우분투 저장소도 추가할 게 없죠. 그냥 엔터입니다.

```
Detail storage configuration
Configure a duided storage layout, or create a custom one:
(*) Use an entire disk
    [WDC_WD10EZEX-OOBN5A...         local disk 931.513G ▼]
    [*]  Set up this disk as en LVM group
         [ ] Encrypt tje LVM group with LUKS
( ) Custom storage layout
```

디스크 암호화 필요없으니 이것도 그냥 기본값으로 하면 되죠. 엔터!

```
Storage configuration
FILE SYSTEM SUMMARY
MOUNT POINT     SIZE             TYPE              DEVICE TYPE
[/              100.000G         new ext4          new LVM local volum          ▶]
[/boot            2.000G         new ext4          new partition of local disk  ▶]
[/boot/efi        1.049G         new fat32         new partition of local disk  ▶]


AVAILABLE DEVICES           TYPE                SIZE
   DEVICE
[ ubuntu-vg (new)           LVM volume group    928.457G ▶]
        free space                              828.457G ▶]
[ SAMSUNG_HD322GJ...            local disk      298.091G ▶]
[ Create software RAID (md) ▶]
[ Create volume group (LVM) ▶]

USED DEVICES
  DEVICE                    TYPE                 SIZE
[ubuntu-vg (new)            LVM volume group     928.457G ▶]
 ubuntu-lv  new, ... ext4, mounted at /          100.000G ▶]

[ SanDisk_Ultra...          local disk            14.909G ▶]
  partition 1 existing, ... vfat, in use

[ WDC_WD10EZEX-OOBN5A...        local disk       931.513G ▶]
  partition 1 new, ... mounted at /boot/efi        1.049G ▶
  partition 2 new, ... ext4, mounted at /boot      2.000G ▶
  partition 3 new, ... ubuntu-vg                 928.460G ▶
```

현재 컴퓨터에는 웹스턴 하드와 삼성 하드가 물려 있습니다. 하드디스크 파티션은 잘 봐야 합니다. 하드가 털털 남는데도 WD 하드가 ubuntu-vg에 100G 만 할당되었습니다. 아무 생각 없이 엔터치면 설치 다 됐을 때 당황하게 됩니다. 도대체 왜 이렇게 해놨는지 모르겠지만, 아래처럼 디스크의 남는 부분 전체를 사용하도록 고쳐야 합니다.

```
Format and/or mount SAMSUNG_HD
Formatting and mounting a disk directly is unusual...
Format:  [ ext4     ▼]
 mount:  [ /srv     ▼]

Editing logical volume ubuntu-lv of ubuntu-vg
               Name:   [ ubuntu-lv       ]
Size (max 928.257G):   [ 928.257G        ]
         Format:   [ ext4      ▼]
          mount:   [ /         ▼]
```

삼성하드는 포멧해서 전체 공간을 `/srv` 에 마운트 하고, WD 는 왼쪽에 max 라고 써진 용량을 모두 사용하게 바꿨습니다. 이제 고쳐진 하드디스크 설정을 확인해 보겠습니다.

```
Storage configuration
FILE SYSTEM SUMMARY
MOUNT POINT     SIZE        TYPE          DEVICE TYPE
[/              928.457G    new ext4      new LVM local volum          ▶]
[/boot            2.000G    new ext4      new partition of local disk  ▶]
[/boot/efi        1.049G    new fat32     new partition of local disk  ▶]
[/srv           298.091G    new ext4      logical disk                 ▶]
```

잘 됐습니다. 다음을 누르면 진짜 할 꺼냐고 묻습니다.

```
Confirm destructive action
Selecting Continue below will begin the installation process and
result in the loss od data on the disks selected to be formatted.
You will not be able to return to rhis or a previous screen once the
installation has started.
Are you sure you want to continue?
      [  No     ]
    * [ Continue    ]
```

해야죠. 안 하면 스토리지 설정으로 되돌아갑니다.

```
Profile configuration
Enter the username and password you will use to log in to the system.
            Your name: [ kiro       ]
     Your server name: [ asrock     ]
      Pick a username: [ kiro       ]
    Choose a password: [ **********     ]
Confirm your password: [ **********     ]
```

유저 이름과 비번 그리고 서버 이름을 정합니다.

```
Upgrade to Ubuntu Pro
Upgrade this machine to Ubuntu Pro for security updates on ....
    [ About Ubuntu Pro          ▼]
    ( ) Enable Ubuntu Pro
    (*) Skip for now
        You can always enable Ubuntu Pro later....
```

다음은 프로로 업그레이드 할 거냐고 묻습니다. 안하죠.


```
SSH configuration
You can choose to install the OpenSSH server package to enable...
[*] Install OpenSSH server
    Allow pass authentication over SSH
[ Import SSH key ▶ ]
AUTHORIZED KEYS
    No authorized key
```

다음은 OpenSSH 설치 여부입니다. 외부에서 터미널로 접근해야 하니까 설치해야죠. 다음

```
Featured server snaps
These are popular snaps in server environments. select or...
[ ] microk8s            canonical   ...
[ ] nextcloud           nextcloud   ...
[ ] wekan               xet7        ...
[ ] canonical-livepatch canonical   ...
...
```

미니니까 추가적으로 설치할 거 없어요. 안 할겁니다.

```
Installing system
    subiquity/load_cloud_config/extract_autoinstall:
    subiquity/Early/apply_autoinstall_config:
    ...
```

이제 줄줄 나오면서 인스톨됩니다. 다 되면 USB 빼고 엔터 치라고 나옵니다. 그리고 재부팅

```
Ubuntu 24.04.3 LTS asrock tty1

[   59.670179] cloud-init[1095]: Cloud-init v.25.1.4-0ubuntu...
ci-info: no authorized SSH keys fingerprints found for user kiro.
<14>JAN  0  02:07:24 cloud-init: ##################################
<14>JAN  0  02:07:24 cloud-init: ---BEGIN SSH HOST KEY FINGERPRINTS---
<14>JAN  0  02:07:24 cloud-init: 256 SHA256:69ygjkhgkjhgkjgkjhgliughliuh
<14>JAN  0  02:07:24 cloud-init: 256 SHA256:lklsdafhqaloiefkjasdkasdfetg
<14>JAN  0  02:07:24 cloud-init: 3072 SHA256:oiqwdasaksdkjfvasdkjfaksdaf
<14>JAN  0  02:07:24 cloud-init: ---END SSH HOST KEY FINGERPRINTS---
<14>JAN  0  02:07:24 cloud-init: ##################################
---BEGIN SSH HOST KEY KEYS---
asdlkfjalfasdnkfalfsdjfcaljfadsjflakjsdhflkajsdhflkashdflkafjkadhsflka
afasdfasdfasdfasgrtyuhswergsdf5g4sgsdfgafqwe54fqwefqawfqfasdafsatyytrj
---END SSH HOST KEY KEYS---
[  57.775332] Cloud-init[1095]: Cloud-init v25.1.4-0ubuntu... finished

asrock login:
```

다 됐습니다. 아까 SSH KEY 를 Import 하지 않았기 때문인데, 비번으로 로그인 할 겁니다. 이제 터미널로 접근할 수 있습니다. 터미널로 처음 접근하면 .ssh 디렉토리에 known_hosts 를 등록하고 로그인 됩니다.

```
ED25519 key fingerprint is SHA256:lNkfvJ6BK/VTGHDO6anSKKgmw0mlQgsSSg0SkOF9UoM.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes

Welcome to Ubuntu 24.04.3 LTS (GNU/Linux 6.8.0-90-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

This system has been minimized by removing packages and content that are
not required on a system that users do not log into.

To restore this content, you can run the 'unminimize' command.
kiro@asrock:~$
```

여기까지 정말 금방 끝납니다. 내부를 살펴보겠습니다.

```
kiro@asrock:~$ ls -al
total 32
drwxr-x--- 4 kiro kiro 4096 Jan  8 02:09 .
drwxr-xr-x 3 root   root   4096 Jan  8 02:06 ..
-rw------- 1 kiro kiro   18 Jan  8 02:09 .bash_history
-rw-r--r-- 1 kiro kiro  220 Mar 31  2024 .bash_logout
-rw-r--r-- 1 kiro kiro 3771 Mar 31  2024 .bashrc
drwx------ 2 kiro kiro 4096 Jan  8 02:08 .cache
-rw-r--r-- 1 kiro kiro  807 Mar 31  2024 .profile
drwx------ 2 kiro kiro 4096 Jan  8 02:07 .ssh
-rw-r--r-- 1 kiro kiro    0 Jan  8 02:09 .sudo_as_admin_successful
```
홈 디렉토리는 별다른 게 없습니다. 관리자군요. 그래야겠죠.

```
kiro@asrock:~$ df -h
Filesystem                         Size  Used Avail Use% Mounted on
tmpfs                              762M  932K  761M   1% /run
efivarfs                           128K   75K   49K  61% /sys/firmware/efi/efivars
/dev/mapper/ubuntu--vg-ubuntu--lv  913G  6.2G  861G   1% /
tmpfs                              3.8G     0  3.8G   0% /dev/shm
tmpfs                              5.0M     0  5.0M   0% /run/lock
/dev/sdb                           293G   28K  278G   1% /srv
/dev/sda2                          2.0G  100M  1.7G   6% /boot
/dev/sda1                          1.1G  6.2M  1.1G   1% /boot/efi
tmpfs                              762M   12K  762M   1% /run/user/1000
```
디스크도 정상적으로 마운트됐습니다. WD의 파티션 공간 913G 를 사용할 수 있고, 삼성 하드 293G 전체가 /srv 에 물려 있습니다.

```
kiro@asrock:~$ free -h
               total        used        free      shared  buff/cache   available
Mem:           7.4Gi       394Mi       7.0Gi       1.1Mi       311Mi       7.1Gi
Swap:          4.0Gi          0B       4.0Gi
kiro@asrock:~$

kiro@asrock:~$ cat /etc/fstab
/dev/disk/by-id/dm-uuid-LVM    /          ext4  defaults  0  1
/dev/disk/by-uuid/1a7fbc71-    /srv       ext4  defaults  0  1
/dev/disk/by-uuid/30f2fbe1-    /boot      ext4  defaults  0  1
/dev/disk/by-uuid/7239-9CDC    /boot/efi  vfat  defaults  0  1
/swap.img                      none       swap  sw        0  0

kiro@asrock:~$ ls -l /swap.img
-rw-------   1 root root 4294967296 Jan  9 00:13 swap.img
```

초기 메모리 사용량이 394Mb 밖에 안 되네요. 좋습니다. 특이한 것은 물리 메모리가 8기가인데, 여기에 스왑이 자동으로 4Gb 할당되어 있다는 점입니다. 램이 적어서 인스톨 한 뒤 따로 스왑을 잡으려고 했는데 알아서 해주니 편합니다. fstab 에도 정상적으로 등록되어 있네요. (주석이나 UUID는 편집해서 붙여넣기 했음).

결론: 우분투 리눅스 서버 설치는 엄청 쉽고 간단합니다. 다만 하드디스크 설정은 Edit 필수입니다.
