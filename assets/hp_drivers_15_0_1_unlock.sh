#!/bin/bash

# HewlettPackardPrinterDrivers 파일을 내려받습니다.
curl -o ~/Downloads/HewlettPackardPrinterDrivers.dmg https://updates.cdn-apple.com/2021/macos/071-46903-20211101-0BD2764A-901C-41BA-9573-C17B8FDC4D90/HewlettPackardPrinterDrivers.dmg

# 다운받았던 파일을 마운트합니다.
hdiutil attach ~/Downloads/HewlettPackardPrinterDrivers.dmg

# 내부 파일을 로컬에 복사하여 풀어높습니다.
pkgutil --expand /Volumes/HP_PrinterSupportManual/HewlettPackardPrinterDrivers.pkg ~/Downloads/hp-expand

# 이제 마운트한 건 필요없으니 해제합니다.
hdiutil eject /Volumes/HP_PrinterSupportManual

# Distribution 파일은 xml로 되어 있습니다. 내부 함수의 버전 제약을 고칩니다.
# 현재 15.0 으로 버전 제약이 걸린 부분을 그냥 100.0 으로 바꿉니다. sed 를 이용해 텍스트 대치하는 방법입니다.
sed -i '' 's/15.0/100.0/' ~/Downloads/hp-expand/Distribution

# 이제 이걸 다시 인스톨러로 패키징합니다.
pkgutil --flatten ~/Downloads/hp-expand ~/Downloads/HP_Drivers_15.0.1_unlock.pkg

# 풀어놨던 디렉토리는 이제 필요없으니 지웁니다.
rm -R ~/Downloads/hp-expand
