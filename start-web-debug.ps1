# Madame Jam Web Debug Script
Write-Host "🚀 Starting Madame Jam Web Debug Server..." -ForegroundColor Green
Write-Host ""
Write-Host "This will start Flutter web on localhost:5555" -ForegroundColor Yellow
Write-Host "You can access it at: http://localhost:5555" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Red
Write-Host ""

try {
    # Clean build cache
    Write-Host "🧹 Cleaning build cache..." -ForegroundColor Blue
    flutter clean
    
    # Get dependencies
    Write-Host "📦 Getting dependencies..." -ForegroundColor Blue
    flutter pub get
    
    # Enable web if not already enabled
    Write-Host "🌐 Ensuring web support is enabled..." -ForegroundColor Blue
    flutter config --enable-web
    
    # Check if Chrome is available
    Write-Host "🔍 Checking Chrome availability..." -ForegroundColor Blue
    flutter devices | Select-String "chrome"
    
    # Start web server with debugging enabled
    Write-Host "🚀 Starting web server with debugging..." -ForegroundColor Green
    Write-Host "Debug URL will be available shortly..." -ForegroundColor Yellow
    
    flutter run -d chrome --web-hostname localhost --web-port 5555 --dart-define-from-file env.json --enable-web-dev-tools --verbose
}
catch {
    Write-Host "❌ Error occurred: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Troubleshooting tips:" -ForegroundColor Yellow
    Write-Host "1. Make sure Chrome is installed and accessible" -ForegroundColor White
    Write-Host "2. Check if port 5555 is available" -ForegroundColor White
    Write-Host "3. Verify Flutter web is enabled: flutter config --enable-web" -ForegroundColor White
    Write-Host "4. Try running: flutter doctor -v" -ForegroundColor White
}

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
