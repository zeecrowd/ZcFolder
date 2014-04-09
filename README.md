## ZcFolder application for the Zeecrowd platform

The `master` branch is for the latest version of the ZcFolder application.

## How to build
Requires Qt 5.2 or higher

### Windows

Cf Build directory
```
set NAME=ZcCloud
set CFGNAME=ZcFolder
set RCC= C:\Qt\Qt5.2.0\5.2.0\msvc2010\bin\rcc.exe
set SRC=..\
set OUTPUT=..\Deploy

IF NOT EXIST %OUTPUT%\. md %OUTPUT%

copy %SRC%\%NAME%.cfg %OUTPUT%
%RCC% -threshold 70 -binary -o %OUTPUT%\%NAME%.rcc %SRC%\%NAME%.Debug.generated.qrc
```

### Linux

Soon. In progress.
For more informations check the [Zeecrowd website](http://www.zeecrowd.com/en/page/405/zeecrowd-soon-available-on-linux-android-and-osx-are-next)

### Licensing

ZcFolder is an open source product provided under the GPLv3 license.