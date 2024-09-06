---
layout: post
title: MacOS CMake Installation without Homebrew
categories: [Python]
tags: [mac, cmake, homebrew]
teaser: "/assets/cmake-gui-install.jpg"
brief: CMake 는 파이썬 패키지 빌드할 때 가끔 요구하는 경우가 있습니다. 보통은 맥에서 Homebrew 를 통해 설치하는데, 저는 Homebrew 를 사용하지 않기 때문에 직접 설치해봤습니다. 맥용 CMake 를 내려받은 뒤 paths 에 등록해주면 됩니다.
---

파이썬 패키지를 사용하다보면 대개는 파이썬 버전과 해당 머신에 맞게 빌드된 hwl 을 내려받는 선에서 쓸 수 있는데, 아주 가끔은 내부가 C/C++ 로 되어 있는 패키지는 빌드해야 되는 경우가 있습니다. 아주 가끔요.

맥에서는 보통 gcc 대신 clang 을 사용합니다. xcode 가 깔려 있다면 그냥 커맨드라인에 `gcc --version` 을 쳐도 clang 으로 연결되는 걸 알 수 있습니다. 심볼릭이 걸려 있거든요. 어쨌든, 애플 기기 개발이 목적이 아니라면 굳이 xcode 를 설치할 필요가 없죠. 커맨드라인툴만 설치해도 충분합니다. 파이썬 설치 전에 그냥 마음 편하게 맥에 깔아두는 편이 좋습니다. 두루두루 쓸모가 많을 테니까요.

터미널 열고 명령 한 줄이면 설치됩니다. 용량이 크지도 않아요.

```bash
% xcode-select --install
```

![Xcode Command Line Tools Install](/assets/xcode-command-line-tools-install.jpg)

그 다음은 makefile 을 자동으로 만들어주는 CMake 인데요. 파이썬 패키지 빌드할 때 가끔 요구하는 경우가 있습니다. 보통은 맥에서 `Homebrew` 를 통해 설치합니다. 홈브류는 맥에서 일반적으로 많이 사용하는 패키지 관리자인데, 이게 이미 깔려 있다면 터미널에서 간단하게 설치할 수 있습니다.

```bash
% brew install cmake
```

그런데 이 녀석이 제 XCode 를 망가뜨린 적이 있어서, 그 뒤로는 `Homebrew` 를 이용하지 않고 있습니다. 그러다보니 애로사항이 참 많네요. 아무튼, 맥에 CMake 를 직접 설치하려면 홈페이지에 가서 dmg 이미지를 내려받습니다.

* https://cmake.org/download/

아마도 대부분 `macOS 10.13 or later` 의 `cmake-...-macos-universal.dmg` 를 받으면 될 겁니다. 그리고 클릭! 해서 아이콘을 끌고 와 설치합니다. 앱이군요.

![CMake GUI](/assets/cmake-gui.jpg)

굳이 이렇게까지... GUI가... 있을 필요가 없을... 뭐, 어쨌든 좋군요. 그런데 제가 원하는 것은 터미널 명령입니다. 이 상태로 터미널에서 `cmake --version` 을 쳐도 없다고 나옵니다. cmake 실행파일은 `/Applications/CMake.app/Contents/bin` 에 들어있습니다. 터미널에서 사용할 수 있게 경로를 연결해주면 됩니다.

```bash
$ sudo nano /etc/paths
```

혹은 파인더로 숨김파일 보기(`cmd + shift + .`)로 해서 직접 `etc` 디렉토리를 찾아가서 `paths` 파일을 편집기로 열어도 됩니다.

```
/usr/local/bin
/usr/bin
/bin
/usr/sbin
/sbin
/Applications/CMake.app/Contents/bin       <<----- HERE
```

여기에 한 줄 추가합니다. 이제 열려있는 터미널을 모두 닫고 새로 연 다음 cmake 를 호출해봅시다.

```bash
% cmake --version
cmake version 3.30.3
CMake suite maintained and supported by Kitware (kitware.com/cmake).
%
```

잘 나오는군요.

저도 참다 참다 정 불편하면 어쩔 수 없이 `Homebrew` 를 설치하겠지만, 그래도 루비로 만들어진 `Homebrew` 말고 좀 더 깜끔한 패키지 관리자가 있었으면 좋겠습니다. 홈브류로 패키지를 내려받는 건 편하긴 하지만, 홈브류 자체를 사용하기 위해 내부에 깔리는 게 참 많기도 해요.

