---
layout: post
title: Homebrew 와 Xcode
categories: [Life]
tags: [homebrew, xcode, command]
teaser: "/assets/homebrew-install.jpg"
brief: 홈브루 설치 시 Xcode Command Line Tool 설치를 요구합니다. Xcode 가 이미 깔려 있어는데 설치한다고 합니다. 거부하면 진행되지 않으니까 일단 설치하고 난 뒤에 되돌려놓으면 됩니다.
math: false
---

사실 저는 Homebrew 를 좋아하지 않습니다. 애플에서 운영하는 게 아니기 때문입니다. MS의 WinGet 처럼 OS 제조사에서 운영해야 한다고 생각합니다. 리눅스만 하더라도 apt 나 yum, rpm 처럼 출신 족보가 명확한 패키지 관리자가 있습니다. 러스트의 crates.io 나 파이썬의 pip 처럼 이런 건 퍼스트에서 운영해야 잘 굴러갑니다. 홈브루는 애플과 전혀 관계없이 운영됩니다. 그러면 애플과 잘 협조라도 하든가요. 몇 가지 툴들을 설치했다 지웠다 하는 게 불편해서 저도 사용하긴 하는데 짜증나는 구석이 있습니다.

1. Xcode 가 있는데도 커맨드라인툴을 내려받습니다. 절차를 Skip 할 수도 없습니다.
2. 홈브루 경로를 .zprofile 에 자동으로 넣어주지 않습니다. 이게 뭐라고 수동으로 하라는 건지 모르겠네요.
3. 패키지가 거의 최근 버전으로만 유지합니다. 과거의 특정 버전을 내려받는 게 일부 보존 처리된 걸 제외하면 불가능합니다.
4. 패지키를 설치하면 실행파일만 있으면 되는데 너무 쓸데없는 것까지 때려박습니다.


## 관리자 계정에 설치
보통 개발계정은 관라지 계정을 사용합니다. 터미널에 sudo 를 종종 입력해야 하는데, 일반계정이면 이게 불편하거든요. 그래서 홈부르 홈페이지는 이를 기준으로 안내합니다.

```shell
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

이건 애플 실리콘에서는 `/opt/homebrew`에, 인텔맥에서는 `/usr/local` 설치됩니다.

설치하는 과정에서 Xcode Command Line Tool 을 요구합니다. Xcode 가 이미 설치되어 있는데 커맨드라인툴을 설치한다고 하네요. 이거 설치 안하면 진행이 안 되니까 일단 설치합니다. 설치 스크립트에서 검사를 어떻게 하는 건지 정말 어처구니가 없네요. 아마 대부분 홈브루를 사용하는 분들이 Xcode 까지 필요하지 않은 개발자일 것 같은데, 그래서 검사를 대충 하는 걸까요? 커맨드라인 툴을 곱게 설치만 하는 게 아니라 원래 Xcode.app 으로 지정되어 있던 경로를 CommandLineTools 로 바꿔버립니다.

```shell
$ sudo xcode-select --switch /Library/Developer/CommandLineTools/
$ sudo xcode-select -s /Applications/Xcode.app/Contents/Developer/
```

만약 Xcode 가 설치되어 있다면 경로를 Xcode.app 으로 바꿔놓고 `CommandLineTools` 디렉토리는 통으로 지워버려도 됩니다.

터미널에서 홈브루가 설치되면 마지막 로그에 사용자가 스스로 알아서 `.zprofile` 에 넣으라고 안내가 나옵니다. 그대로 복사 붙여넣기 하면 `zprofile` 에 업데이트 됩니다.


## 홈브루 삭제할 때
언인스톨 스크립트로 제공합니다. 이렇게 제거하고 나서 설치 디렉토리 (`/opt/homebrew`)를 통을 지워버리면 됩니다.

```shell
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
```


## 유저 계정에 설치
만약 유저의 홈 디렉토리에 `~/.homebrew` 를 만들어서 거기에 설치하고 싶다면 다음처럼 하면 됩니다.

```shell
$ xcode-select --install
$ cd $HOME
$ mkdir .homebrew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C .homebrew
$ echo 'export PATH="$HOME/.homebrew/bin:$PATH"' >> .zprofile
```

커맨드라인 툴을 설치해주고(Xcode 가 있다면 생략), 사용자 홈 디렉토리에 `.homebrew` 로 숨김폴더를 만들고, 최신 홈브루를 내려받아 풀어놓습니다. 그 후 `.zprofile`에 홈브루 경로를 등록해주는 거죠. 삭제할 때는 `~/.homebrew`를 통으로 지워버리고 `~/.zprofile` 을 편집기로 열어서 추가해준 홈브루 경로도 지우면 됩니다.

