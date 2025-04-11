---
layout: post
title: 구형 HP 프린터 - 맥 세쿼이아 설치
categories: [Life]
tags: [macbook, mac, hp, printer, sequoia]
teaser: "/assets/hp-printer-distribution.jpg"
brief: 맥 세쿼이아에서 구형 HP 프린터가 설치되지 않네요. 인스톨러에서 거부하는 것이니 그 조건제약을 풀어리고 설치하는 방법이 있습니다. 애플이 뭔가를 테스트 하고서 상위 버전의 제약을 걸어놓은 게 아닌 것 같습니다. HP 에서는 구형 기기 드라이버를 새로 내놓을 생각이 없나 봅니다.
math: false
---

애플 실리콘 맥 세쿼이아에서 HP 프린터 설치하려고 하니 지원하지 않는다고 하더군요. 근래 생산된 HP 프린터는 문제가 없겠지만 예전에 생산된 모델은 에어프린트로 유도하는 분위기입니다. 그런데 그보다도 오래된 프린터라면 직접 드라이버를 깔아야 합니다.

* <https://support.apple.com/en-us/106385>

구형 HP 프린터는 이거 깔면 다 잡을 수 있는데 이게 맥OS 12 이상에서는 호환되지 않는다고 합니다. 애플이 HP 에서 드라이버를 받아 조금 수정해서 배포하는 것인데 모하비 이후로 수정을 안 하고 있는 것 같습니다. 그렇다고 멀쩡히 잘 동작하는 프린터를 버릴 수는 없잖아요. 찾아보니 해결한 분이 있더군요. 정말 훌륭한 분입니다.

* <https://discussions.apple.com/thread/255806096?sortBy=rank>
* <https://forums.macrumors.com/threads/monterrey-and-hp-printers.2319676/?post=30525559#post-30525559>

해당 해결책의 주요 요지는 인스톨러에서 거부하는 것이니, 그 제약 조건을 풀어버리는 것입니다. 애플이 뭔가를 테스트 하고서 상위 버전의 제약을 걸어놓은 게 아니라 처음 배포했던 당시 예측 정도인 것 같습니다. HP 에서는 애플 실리콘용으로 드라이버를 내놓을 생각이 없나 봅니다. 어려운 일도 아닌데 안 해주는 건 새 제품을 구매하라는 뜻입니다. 하드웨어를 판매하는 회사는 보통 그렇습니다.

> `HewlettPackardPrinterDrivers.dmg`

이 파일을 대상으로 다음 과정을 처리해 보겠습니다.

1. dmg 마운트 해서 내부 풀어내고 언마운트
2. Distribution 파일(xml)에 `15.0` 버전 제약이 걸린 부분을 없애기
3. 다시 설치 파일로 패키징하여 설치!


## 빠른 해결
완성 파일은 용량이 커서 배포하기 힘들기 때문에 스크립트 파일 만들었습니다. 별 거 없고 위 링크 설명에 나온대로입니다.

* 다운: <https://kiroshin.github.io/assets/hp_drivers_15_0_1_unlock.sh>
* 터미널에서 다운로드 폴더로 이동한 뒤 `sh hp_drivers_15_0_1_unlock.sh` 치세요.

```shell
k@MBP ~ % cd Downloads
k@MBP Downloads % sh hp_drivers_15_0_1_unlock.sh
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  557M  100  557M    0     0  56.7M      0  0:00:09  0:00:09 --:--:-- 57.1M
Checksumming Driver Descriptor Map (DDM : 0)…
     Driver Descriptor Map (DDM : 0): verified   CRC32 $222DB4F8
Checksumming  (Apple_Free : 1)…
                    (Apple_Free : 1): verified   CRC32 $00000000
Checksumming Apple (Apple_partition_map : 2)…
     Apple (Apple_partition_map : 2): verified   CRC32 $935FFDA4
Checksumming disk image (Apple_HFS : 3)…
...............................................................................
          disk image (Apple_HFS : 3): verified   CRC32 $DEAA3D38
Checksumming  (Apple_Free : 4)…
                    (Apple_Free : 4): verified   CRC32 $00000000
verified   CRC32 $55426676
/dev/disk4              Apple_partition_scheme
/dev/disk4s1            Apple_partition_map
/dev/disk4s2            Apple_HFS                       /Volumes/HP_PrinterSupportManual
"disk4" ejected.
k@MBP Downloads %
```


## 직접 해보기
애플 홈페이지에서 dmg 파일을 다운받습니다. 그뒤 터미널에서 진행하면 됩니다.

```shell
# 다운로드 디렉토리로 이동합니다.
~ % cd Downloads

# 다운받았던 파일을 마운트합니다.
k@MBP Downloads % hdiutil attach HewlettPackardPrinterDrivers.dmg
expected   CRC32 $55426676
/dev/disk4              Apple_partition_scheme
/dev/disk4s1            Apple_partition_map
/dev/disk4s2            Apple_HFS                       /Volumes/HP_PrinterSupportManual

# 내부 파일을 로컬에 복사하여 풀어높습니다.
k@MBP Downloads % pkgutil --expand /Volumes/HP_PrinterSupportManual/HewlettPackardPrinterDrivers.pkg ~/Downloads/hp-expand

# 이제 마운트한 건 필요없으니 해제합니다.
k@MBP Downloads % hdiutil eject /Volumes/HP_PrinterSupportManual
"disk4" ejected.

# Distribution 파일은 xml로 되어 있습니다. 내부 함수의 버전 제약을 고칩니다.
# 현재 15.0 으로 버전 제약이 걸린 부분을 그냥 100.0 으로 바꿉니다. sed 를 이용해 텍스트 대치하는 방법입니다.
k@MBP Downloads % sed -i '' 's/15.0/100.0/' ~/Downloads/hp-expand/Distribution

# 이제 이걸 다시 인스톨러로 패키징합니다.
k@MBP Downloads % pkgutil --flatten ~/Downloads/hp-expand ~/Downloads/HP_Drivers_15.0.1_unlock.pkg

# 풀어놨던 디렉토리는 이제 필요없으니 지웁니다.
k@MBP Downloads % rm -R ~/Downloads/hp-expand
```

위 과정은 Keka 로 풀어서 Distribution 파일을 직접 수정해도 괜찮습니다. 이럴 때는 텍스트 대치를 안하고 그냥 지워버려도 됩니다.

```xml
<script>
function InstallationCheck(prefix) {
<!-- 지워버려
    if (system.compareVersions(system.version.ProductVersion, '15.0') &gt; 0) {
        my.result.message = system.localizedStringWithFormat('ERROR_25CBFE41C7', '15.0');
        my.result.type = 'Fatal';
        return false;
    }
 -->
    return true;
}
</script>
```


## 설치제약 없어진 인스톨러
이렇게 새로 만들어진 pkg 파일을 클릭하여 설치합니다.

인텔용이기 때문에 `Rosetta 2` 를 먼저 설치해야 한다고 뜹니다. 만약 로제타가 이미 설치되어 있다면 이 메시지는 나오지 않습니다. 로제타는 애플실리콘 기반 맥에서 인텔용 바이너리를 실행하기 위한 아주 얇은 레이어입니다. 이거 설치한다고 따로 로제타 앱이 뜨는 건 아니라서 로제타 위에서 실행된지도 모릅니다. 저처럼 시스템을 건드는 것에 극히 예민한 사용자라 할지라도 괜찮습니다.

이렇게 설치가 되고 나면 설정의 프린터 추가에서 정상적으로 구형 HP 프린터가 잡히고, 출력도 아주 잘 됩니다.

![installed](/assets/hp_printer_installed.jpg)
