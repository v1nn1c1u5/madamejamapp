@echo off
echo Starting Madame Jam Web Debug Server...
echo.
echo This will start Flutter web on localhost:5555
echo You can access it at: http://localhost:5555
echo.
echo Press Ctrl+C to stop the server
echo.

REM Clean build cache
echo Cleaning build cache...
flutter clean

REM Get dependencies
echo Getting dependencies...
flutter pub get

REM Enable web if not already enabled
echo Ensuring web support is enabled...
flutter config --enable-web

REM Start web server with debugging enabled
echo Starting web server with debugging...
flutter run -d chrome --web-hostname localhost --web-port 5555 --dart-define-from-file env.json --enable-web-dev-tools

pause
