---
layout: post
title: 러스트 윈도우 개발환경
categories: [Rust]
tags: [rustup, msvc, buildtools, vscode, gcc, make, rustrover]
teaser: "/assets/rust-windows-rustup-init.jpg"
brief: 맥이나 리눅스에서는 간편하게 개발환경을 구축할 수 있는데, 윈도우에서 유독 번거로운 경우가 종종 있습니다. 이번에 윈도우에서 러스트를 컴파일 할 일이 있어서 개발환경을 구축하다가 짜증나서 기록을 남깁니다.
---

맥이나 리눅스에서는 간편하게 개발환경을 구축할 수 있는데, 윈도우에서 유독 번거로운 경우가 종종 있습니다. 이번에 윈도우에서 러스트를 컴파일 할 일이 있어서 개발환경을 구축하다가 짜증나서 기록을 남깁니다.

### 제일 간편한 방법: Standalone installers
* <https://forge.rust-lang.org/infra/other-installation-methods.html#standalone-installers>

위 링크에서 윈도우 버전에 해당하는 인스탈러를 받아서 설치하면 됩니다.
- `aarch64-pc-windows-msvc`
- `i686-pc-windows-gnu`
- `i686-pc-windows-msvc`
- `x86_64-pc-windows-gnu`
- `x86_64-pc-windows-msvc`

이 중에서, 32비트로 컴파일하려면 `i686`을, 64비트로 컴파일 하려면 `x86_64`을 받으면 됩니다. 호환을 위해 msvc 버전으로 하는 게 정신건강에 좋습니다. 아마 대부분 64비트 윈도우를 사용할 것이므로 `x86_64-pc-windows-msvc`를 선택하면 됩니다. 현재 stable (1.82.0) 입니다.

그런데 이렇게 설치하면 `rustup` 을 사용할 수 없습니다. 러스트를 업데이트 못하고 툴체인도 추가할 수 없죠.


### 가장 무난한 방법: rustup-init.exe
홈페이지에서 강추하는 방법으로 32비트/64비트 인스탈러가 있습니다. 64비트 버전을 다운받으면 됩니다(사실, 32비트 버전을 받아서 설치해도 윈도우가 64비트로 깔려 있으면 x86_64 로 설치됩니다). 만약 러스트를 32비트로 컴파일하고 싶으면 나중에 32비트 툴체인을 추가하면 되니까 괜찮습니다.

다운받은 `rustup-init.exe` 파일을 클릭합니다.

```
Rust Visual C++ prerequisites
Rust requires a linker and Windows API libraries but they don't seem to be
available. These components can be acquired through a Visual Studio installer.

1) Quick install via the Visual Studio Community installer
   (free for individuals, academic uses, and open source).
2) Manually install the prerequisites
   (for enterprise and advanced users).
3) Don't install the prerequisites
   (if you're targeting the GNU ABI).
>
```

만약 위와 같은 화면을 만난다면 윈도우용 빌드툴이 없는 겁니다. `1` 을 선택하면 자동으로 `Visual Studio Community installer` 를 내려받고 설치되는데, 용량이 아주 많이 크죠. 사실 빌드 툴만 있어도 충분합니다. 그래서 그냥 창을 닫아버리고 일단 빌드툴부터 설치하도록 하겠습니다.

* <https://visualstudio.microsoft.com/visual-cpp-build-tools/>

현재 Standalone MSVC compiler 2022 버전이 내려받아집니다. 윈도우 11 빌드 툴을 포함하고 있는데 굳이 최신 빌드툴을 내려받을 필요가 없습니다.

* 2017: <https://aka.ms/vs/15/release/vs_buildtools.exe>
* 2019: <https://aka.ms/vs/16/release/vs_buildtools.exe>
* 2022: <https://aka.ms/vs/17/release/vs_buildtools.exe>

저는 윈도우 10에 2017 버전을 설치했는데, 아무 문제없네요. 용량도 4G로 제일 적습니다. 2022 버전은 7G 입니다.

![MSVC compiler](/assets/rust-req-visual-cpp-build-tools.jpg)

`Visual C++ 빌드 도구`를 클릭하면 선택되는 항목은 모두 설치해줍니다. 용량 아낀다고 이런 거 빼버리면 어디서 오류를 만날지 모릅니다(저도 `선택사항` 항목을 빼고 싶은 마음이 큽니다만, Windows SDK 가 빠졌을 때 오류가 났습니다.). 어쨌든 설치가 다 끝나고 나면 다운받은 `rustup-init.exe` 파일을 다시 클릭합니다.

```
Welcome to Rust!
This will download and install the official compiler for the Rust
programming language, and its package manager, Cargo.
Rustup metadata and toolchains will be installed into the Rustup
... ㅇ
You can uninstall at any time with rustup self uninstall and
these changes will be reverted.
Current installation options:

   default host triple: x86_64-pc-windows-msvc
     default toolchain: stable (default)
               profile: default
  modify PATH variable: yes

1) Proceed with standard installation (default - just press enter)
2) Customize installation
3) Cancel installation
>
```

이렇게 뜨게 된다면 러스트 설치 준비가 다 된 겁니다. 이제 `1` 을 선택해서 진행합니다.

```bat
C:\Windows\system32>rustc --version
rustc 1.82.0 (f6e511eec 2024-10-15)
```

커맨드라인에서 버전 정보가 뜨면 잘 설치된 것입니다. 혹시 32비트로 컴파일할 일이 있으면 툴체인을 추가해줘야 합니다.

```bat
C:\Windows\system32>rustup toolchain install stable-i686-pc-windows-msvc
info: syncing channel updates for 'stable-i686-pc-windows-msvc'
info: latest update on 2024-10-17, rust version 1.82.0 (f6e511eec 2024-10-15)
info: downloading component 'cargo'
info: downloading component 'clippy'
...
info: installing component 'rustfmt'

  stable-i686-pc-windows-msvc installed - rustc 1.82.0 (f6e511eec 2024-10-15)

info: checking for self-update

C:\Windows\system32>rustup toolchain list
stable-i686-pc-windows-msvc
stable-x86_64-pc-windows-msvc (default)

C:\Windows\system32>
```

이렇게 윈도우에 러스트가 설치됐고, 32비트/64비트 툴체인도 다 설치됐네요. 물론 default 값은 바꿀 수도 있습니다.

```bat
C:\Windows\system32>rustup default stable-i686-pc-windows-msvc
info: using existing install for 'stable-i686-pc-windows-msvc'
info: default toolchain set to 'stable-i686-pc-windows-msvc'

  stable-i686-pc-windows-msvc unchanged - rustc 1.82.0 (f6e511eec 2024-10-15)

C:\Windows\system32>rustup toolchain list
stable-i686-pc-windows-msvc (default)
stable-x86_64-pc-windows-msvc
```

그런데 굳이 32비트를 기본값으로 할 일이 없겠죠?


## 한 김에 gcc 도 설치해 봅시다.
범용 C의 경우 gcc를 선호합니다. gcc 는 어디든 쓰니까 설치해보죠.

* MinGW: <https://www.mingw-w64.org/downloads/>

여기 가보면, 종류나 선택사항이 참 많습니다. 이전에는 MSVCRT 를 사용했다고 하는데 윈10부터는 UCRT를 쓴다고 하네요. 제가 윈도우에서 개발할 일이 없어서 이 관계가 어찌 되는지는 잘 모르겠습니다. 아주 예전에는 윈도우 C컴파일러가 표준과 거리가 한참 멀었죠. 어찌됐건 이 많은 배포판 중에서 저는 제일 깔끔한 `WinLibs`를 선택했습니다. gcc는 한 번 설치하면 업데이트 할 일이 거의 없습니다만, 항상 최신으로 관리한다면 `MSYS2` 를 선택하세요.

* WinLibs: <https://winlibs.com>

```
- UCRT runtime GCC 14.2.0 (with POSIX threads) Win32 / Win64
- MSVCRT runtime GCC 14.2.0 (with POSIX threads) Win32 / Win64
```

이 중에서 UCRT 64비트 zip 을 내려받고 압축을 풀면 `mingw64` 폴더가 보입니다. 저는 C 루트로 옮겼습니다. 그 다음 할 일은 path 를 등록해주는 일입니다.

> 제어판 -> 고급시스템설정 -> 고급탭 -> 환경변수

여기까지 오면 사용자변수에 등록할건지 시스템변수에 등록할건지 결정해야 하는데, 뭘 해도 상관없지만 그래도 컴파일러니까 시스템변수에 넣어줍니다.

![MinGW Lib Path](/assets/mingw-lib-windows-path.jpg)

```
스크롤 내려서 path 선택 -> 편집 :: 여기서 새로만들기 -> "c:\mingw64\bin" -> 확인
```

이렇게 했으면 커맨드라인에서 확인해봅니다.

```bat
C:\Windows\system32>gcc --version
gcc (MinGW-W64 x86_64-ucrt-posix-seh, built by Brecht Sanders, r2) 14.2.0
Copyright (C) 2024 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

C:\Windows\system32>
```

됐습니다. 그런데 `C:\mingw64\bin` 에 가보면 `mingw32-make.exe` 파일이 있어요. 음.. 이대로 두면 불편하니까 `make.exe` 라는 이름으로 하드링크 합니다(그냥 복사해도 상관없습니다).

```bat
C:\mingw64\bin>mklink /h "make.exe" "mingw32-make.exe"
하드 링크 작성: make.exe <<===>> mingw32-make.exe

C:\mingw64\bin>make --version
GNU Make 4.4.1
Built for x86_64-w64-mingw32
Copyright (C) 1988-2023 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

C:\mingw64\bin>
```

![MinGW Make Copy](/assets/mingw-make-copy.jpg)

다 끝났습니다.


## 그럼 IDE 는?
러스트를 시작하기에는 [VSCode](https://code.visualstudio.com) 가 좋습니다. 익스텐션은 3가지입니다.

- C/C++: microsoft.com
- CodeLLDB : Vadim Chugunov
- rust-analyzer: rust-lang.org

그리고 [RustRover](https://www.jetbrains.com/rust/) 가 있는데 정말 좋습니다. 최고네요!

