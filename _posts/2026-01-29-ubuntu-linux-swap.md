---
layout: post
title: 리눅스 스왑 조정
categories: [Esc]
tags: [linux, ubuntu, ram, memory, swap]
teaser: "/assets/linux-ubuntu-mini.jpg"
brief: 있습니다.
math: false
---

우분투 리눅스를 하드웨어에 설치하면 기본적으로 스왑이 잡혀 있는데 클라우드는 스왑이 없습니다.

스왑은 부족한 램을 보충해 줄 수 있는 수단은 아니고, 메모리 넘칠 때 충격을 좀 완충해줄 수 있는 정도의 역할만 합니다.
스왑이 많이 차는 게 보이면 스왑을 늘릴 게 아니라 물리 메모리를 증설하는 것이 좋습니다.
어쨌든, 램 8G 에 스왑 4G, 램 16G 면 스왑 8G 를 설정하고 있는데, 램이 이보다 많아도 스왑을 8G 이상은 잡지 않고 있습니다.
굳이 스왑은 완충 역할만 하기 때문에 그 이상 잡을 이유가 없는 것 같아서요.

```bash
# 루트에 스왑 8G 파일 생성
$ sudo fallocate -l 8G /swap.img

# 보안권한 설정
$ sudo chmod 600 /swap.img

# 스왑 파일 포멧
$ sudo mkswap /swap.img

# 스왑 활성화
$ sudo swapon /swap.img

# 스왑 동작 확인
sudo swapon --show
```

다음은 재부팅 되더라도 스왑이 적용되도록 fstab 을 조정해줘야 합니다.

```bash
# fstab 편집(vi 대신 nano 로 하는 게 편하죠)
$ sudo nano /etc/fstab

# 사이사이의 반칸은 띄어쓰기가 아니라 tab 입니다.
# 순서: <FileSystem> <MountPoint> <Type> <Options> <Dump> <Pass>
/swap.img    none    swap    sw    0    0
```

1. 마운트 포인트: None - 일반 디스크처럼 접근할 일이 없기 때문입니다.
2. 타입: swap - 스왑 포멧입니다. 일반 디스크라면 ext4 겠죠.
3. 옵션: sw - 이건 스왑 전용 옵션인데, 부팅 시 `swapon -a` 로 스왑을 활성화 해줍니다.


다음은 스왑 가중치 조절입니다.
최신 커널에서는 0~200 사이의 값인데, 기본값은 60 으로 잡혀 있습니다.
값이 높을수록 더 적극적으로 스왑을 활용합니다.

하드디스크라면 60 그대로 두어도 되는데, SSD 라면 20~30 으로 하는 게 낫습니다.
이렇게 하면 램이 거의 다 찰 때까지 스왑을 활용하지 않게 되고 SSD의 쓰기 수명을 조금이라도 아낄 수 있습니다.

저는 SSD 에서 보통 30을 줍니다.

```bash
# 아래처럼 끝에 주입하지 않고, vi 나 nano 로 파일을 열어서 집어넣어도 됩니다.
$ echo "vm.swappiness = 30" | sudo tee -a /etc/sysctl.conf

# 로딩해서 즉시 반영되게
$ sudo sysctl -p

# 결과 확인: 30 이 출력됩니다.
$ cat /proc/sys/vm/swappiness
```

스왑을 제거하려면

```bash
# 1. 스왑해제
$ sudo swapoff /swap.img

# 2. 스왑파일 삭제
sudo rm -r /swap.img

# 3. 부팅 시 스왑을 활성화했던 /etc/fstab 에서 제거
```

결론: 엄청 쉽다.





