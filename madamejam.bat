@echo off

set ADB=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe
set EMULATOR=%LOCALAPPDATA%\Android\Sdk\emulator\emulator.exe

"%ADB%" devices | find "emulator-5554" >nul

if errorlevel 1 (
    echo Iniciando Android Emulator...
    start "" "%EMULATOR%" -avd Pixel_8_Pro

    echo Aguardando dispositivo...
    "%ADB%" wait-for-device
)

start "" cmd /c flutter run -d emulator-5554 --dart-define-from-file=dart_define.json