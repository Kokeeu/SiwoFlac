@echo off
REM Build + install del APK debug de NeroFlac en el emulador conectado.
setlocal

set "PROJECT_DIR=C:\dev\neroflac\local"
set "FLUTTER=C:\Users\jason\fvm\versions\3.44.3\bin\flutter.bat"
set "ADB=C:\Users\jason\AppData\Local\Android\Sdk\platform-tools\adb.exe"
set "APK=%PROJECT_DIR%\build\app\outputs\flutter-apk\app-arm64-v8a-debug.apk"

echo === Verificando devices adb ===
"%ADB%" devices
if errorlevel 1 goto :err

echo.
echo === flutter pub get ===
cd /d "%PROJECT_DIR%"
"%FLUTTER%" pub get
if errorlevel 1 goto :err

echo.
echo === flutter build apk --debug ===
"%FLUTTER%" build apk --debug --target-platform android-arm64
if errorlevel 1 goto :err

if not exist "%APK%" (
  echo [ERROR] No se encontro el APK: %APK%
  goto :err
)

echo.
echo === adb install -r ===
"%ADB%" install -r "%APK%"
if errorlevel 1 goto :err

echo.
echo === Listo. APK instalado en: %APK%
goto :eof

:err
echo [ERROR] Fallo en algun paso.
exit /b 1

endlocal