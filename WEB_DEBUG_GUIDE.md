# Madame Jam - Web Debugging Guide

## 🚀 Quick Start for Web Debugging

### Method 1: Using VS Code Launch Configurations

1. **Open VS Code** in the project directory
2. **Press F5** or go to Run and Debug panel
3. **Select one of these configurations:**
   - `madamejamapp (web)` - Standard web debugging
   - `madamejamapp (web debug)` - Enhanced web debugging with dev tools
   - `Launch Chrome (standalone)` - Launch Chrome separately

### Method 2: Using Scripts

#### Windows Batch Script
```bash
# Double-click or run in terminal
./start-web-debug.bat
```

#### PowerShell Script
```powershell
# Run in PowerShell
./start-web-debug.ps1
```

### Method 3: Using VS Code Tasks

1. **Press Ctrl+Shift+P** (Command Palette)
2. **Type:** "Tasks: Run Task"
3. **Select:** "Flutter: Run Web Debug"

### Method 4: Manual Terminal Commands

```bash
# Clean and setup
flutter clean
flutter pub get
flutter config --enable-web

# Run web debug server
flutter run -d chrome --web-hostname localhost --web-port 5555 --dart-define-from-file env.json --enable-web-dev-tools
```

## 🌐 Access URLs

- **Main App:** http://localhost:5555
- **Flutter Dev Tools:** Will be shown in terminal output
- **Debug Info:** Available in browser console

## 🛠️ Debugging Features

### Enhanced Error Logging
- Platform detection (Web vs Mobile)
- Comprehensive error capture
- Debug console integration
- Visual debug info panel (localhost only)

### Browser Features
- Chrome DevTools integration
- Network monitoring
- Console debugging
- Breakpoint support
- Hot reload enabled

### VS Code Integration
- Breakpoints in Dart code
- Variable inspection
- Call stack navigation
- Debug console
- Hot reload on save

## 🔧 Troubleshooting

### Common Issues

1. **"Debug session can't connect to browser"**
   - Use port 5555 instead of default
   - Clear Chrome cache and data
   - Try Chrome incognito mode
   - Check Windows firewall settings

2. **Chrome not launching**
   ```bash
   flutter devices  # Check if Chrome is detected
   flutter config --enable-web  # Re-enable web support
   ```

3. **Build errors**
   ```bash
   flutter clean
   flutter pub get
   flutter doctor -v  # Check for issues
   ```

4. **Port conflicts**
   - Change port in launch.json (currently 5555)
   - Or kill processes using the port:
   ```bash
   netstat -ano | findstr :5555
   taskkill /PID <PID_NUMBER> /F
   ```

### Debug Console Commands

In Chrome DevTools Console:
```javascript
// Check Flutter version
window.flutterConfiguration

// Monitor errors
console.log('Monitoring Flutter errors...')

// Check if service worker is registered
navigator.serviceWorker.getRegistrations()
```

## 📱 Platform Differences

### Web Platform Features
- Different navigation behavior
- Web-specific widgets available
- URL-based routing
- Service worker support
- Local storage access

### Debugging Capabilities
- **Mobile:** Native debugging through USB/WiFi
- **Web:** Browser-based debugging with full Chrome DevTools
- **Both:** Dart debugging through VS Code

## 🚨 Known Limitations

1. **Camera access** - Requires HTTPS in production
2. **File system access** - Limited to downloads folder
3. **Native plugins** - Some may not work on web
4. **Performance** - Web debugging can be slower than mobile

## 💡 Best Practices

1. **Use specific launch configurations** instead of generic dart launch
2. **Enable breakpoints** in VS Code for better debugging
3. **Monitor browser console** for JavaScript errors
4. **Use Flutter Dev Tools** for widget inspection
5. **Test on multiple browsers** for compatibility

## 🎯 Next Steps

1. **Start debugging:** Choose a method above and launch
2. **Set breakpoints:** In VS Code, click left margin of code lines
3. **Use Dev Tools:** Press F12 in Chrome for additional debugging
4. **Monitor performance:** Check Flutter timeline and memory usage

---

**Happy Debugging! 🐛✨**
