# CHANGES.md — Historial de cambios y contexto

> **Propósito**: Este documento deja constancia de todo lo realizado en este fork de SpotiFLAC-Mobile → NeroFlac. Está pensado para que cualquier otro agente de IA (o persona) pueda retomar el trabajo sin perder el contexto. Léelo antes de hacer cualquier cambio.

---

## 1. Identidad del fork

| Campo | Valor |
|---|---|
| **Nombre** | NeroFlac |
| **Package Dart** | `neroflac` |
| **Package Android (applicationId / namespace)** | `com.kokeeu.neroflac` |
| **App label** | `NeroFlac` |
| **Autor** | Kokeeu (https://github.com/Kokeeu) |
| **Repo upstream (source fork)** | https://github.com/spotiflacapp/SpotiFLAC-Mobile |
| **Repo destino (este fork)** | https://github.com/Kokeeu/NeroFlac |
| **Versión inicial** | 4.6.0+135 (basada en SpotiFLAC Mobile v4.6.0) |
| **Flutter SDK** | 3.44.3 (era 3.41.5 upstream, se actualizó porque el pubspec lo requería) |
| **Go SDK** | 1.26.4 (la 1.25.7 upstream también sirve) |
| **JDK** | Temurin 17.0.19.10 (de Eclipse Adoptium) |
| **Android SDK** | Platform 36, Build-Tools 36.0.0 + 36.1.0, NDK 29.0.14206865, CMake 3.22.1 |

---

## 2. Resumen ejecutivo

Este fork es un **rebrand** puro de SpotiFLAC Mobile. No se cambió la lógica de negocio, ni el sistema de extensiones, ni los providers de letras/metadata, ni FFmpeg. Solo se renombró la identidad visible y la URL por defecto del Store de extensiones.

**Commit único inicial**: `4686353 feat: initial fork of SpotiFLAC Mobile as NeroFlac`

**Por qué force-push**: El repo `Kokeeu/NeroFlac` ya existía en GitHub con un commit inicial de prueba (`# NeroFlac` en README). Se sobreescribió con el contenido rebrandeado de SpotiFLAC Mobile usando `git push --force`.

---

## 3. Lista de cambios por archivo

### 3.1 Identidad y branding

| Archivo | Cambio |
|---|---|
| `pubspec.yaml` | `name: spotiflac_android` → `name: neroflac`; descripción actualizada |
| `android/app/build.gradle.kts` | `namespace` y `applicationId` de `com.zarz.spotiflac` → `com.kokeeu.neroflac` |
| `android/app/src/main/AndroidManifest.xml` | `package="com.zarz.spotiflac"` → `package="com.kokeeu.neroflac"`; `android:label="SpotiFLAC Mobile"` → `android:label="NeroFlac"` |
| `android/app/src/main/kotlin/com/zarz/spotiflac/*.kt` (4 archivos) | Movidos a `com/kokeeu/neroflac/`; `package com.zarz.spotiflac` → `package com.kokeeu.neroflac` en cada uno. Archivos: `DownloadService.kt`, `MainActivity.kt`, `NativeDownloadFinalizer.kt`, `SafDownloadHandler.kt` |
| `lib/constants/app_info.dart` | `appName="SpotiFLAC Mobile"` → `"NeroFlac"`; `copyright="© 2026 SpotiFLAC"` → `"© 2026 NeroFlac"`; `mobileAuthor="zarzet"` → `"Kokeeu"`; `githubRepo="zarzet/SpotiFLAC-Mobile"` → `"Kokeeu/NeroFlac"`; `remoteConfigApiUrl` → apunta al `config.json` del repo NeroFlac; `kofiUrl` y `githubSponsorsUrl` vacíos (no se monetiza) |
| `lib/models/theme_settings.dart` | `kDefaultSeedColor` de verde Spotify `0xFF1DB954` → violeta `0xFF7C3AED` |
| `lib/app.dart` | Clase `SpotiFLACApp` → `NeroFlacApp` |
| `lib/main.dart` | Llamada a `SpotiFLACApp(...)` → `NeroFlacApp(...)` |
| `README.md` | Reescrito completamente; declara explícitamente que es un fork, atribuye al autor original, mantiene el disclaimer legal |
| `apps.json` | Bundle ID, nombre, developer, URL de descarga y de icono actualizados a NeroFlac |
| `.fvmrc` | `"flutter": "3.41.5"` → `"flutter": "3.44.3"` |

### 3.2 Sistema de extensiones

| Archivo | Cambio |
|---|---|
| `lib/providers/store_provider.dart` | Añadido default `defaultRegistryUrl = 'https://github.com/spotiflacapp/SpotiFLAC-Extension'`. Se persiste en SharedPreferences automáticamente la primera vez. Si el usuario lo cambia después, su elección prevalece. |

### 3.3 Renombrado masivo de imports (86 archivos)

Todos los `import 'package:spotiflac_android/...'` → `import 'package:neroflac/...'` en `lib/` y `test/`. Archivos afectados (todos los .dart, no listados individualmente por brevedad — son todos los de lib/ y test/).

### 3.4 CI / GitHub

| Archivo | Cambio |
|---|---|
| `.github/ISSUE_TEMPLATE/config.yml` | URL del README apuntando a Kokeeu/NeroFlac |
| `.github/ISSUE_TEMPLATE/bug_report.yml` | Labels y descripciones actualizadas a "NeroFlac" |
| `.github/ISSUE_TEMPLATE/download_issue.yml` | Idem |
| `.github/ISSUE_TEMPLATE/extension_feature_request.yml` | Idem; URL del docs guide apuntando al repo NeroFlac |
| `.github/workflows/release.yml` | Nombres de artefactos APK/IPA cambiados a `NeroFlac-${VERSION}-*.apk` / `NeroFlac-${VERSION}-ios-unsigned.ipa`; release name actualizado; URL de download en `apps.json` apunta a Kokeeu/NeroFlac |

---

## 4. Decisiones de diseño tomadas

### 4.1 Seed color: violeta `#7C3AED`
- **Razón**: "Nero" = negro en italiano. Quería un color semilla que generara un esquema predominantemente oscuro pero con identidad propia. El violeta intenso da un look moderno y elegante en dark mode, sin ser negro plano.
- **Alternativas consideradas**: negro puro (`0xFF000000`) — genera scheme sin color; carbón (`0xFF1A1A1A`) — similar; rojo oscuro (`0xFF7F1D1D`) — coherente con "intenso" pero menos elegante.
- **Cómo cambiarlo**: editar `lib/models/theme_settings.dart` línea 9. También se puede cambiar desde la app en *Settings → Appearance → Theme color*.

### 4.2 URL de extensiones: `spotiflacapp/SpotiFLAC-Extension`
- **Razón**: El usuario pidió apuntar a ese repo específico. Es el repo oficial de extensiones de SpotiFLAC, lo que permite que NeroFlac use las mismas extensiones que SpotiFLAC Mobile sin forkearlas.
- **Importante**: La URL es la del repo GitHub (`https://github.com/.../SpotiFLAC-Extension`), NO la URL `.git` ni la URL de un `registry.json` específico. El Store internamente resuelve el `registry.json` desde `raw.githubusercontent.com`.

### 4.3 Flutter 3.44.3 (en lugar de 3.41.5)
- **Razón**: Con Flutter 3.41.5 (Dart 3.11.3), `flutter pub get` fallaba porque `sqflite 2.4.3` y `riverpod_generator 4.0.4-dev.1` requieren Dart 3.12+. Se hizo `flutter upgrade` que actualizó a 3.44.3 (Dart 3.12.2).
- **Impacto**: Mínimo — solo cambia la versión del SDK, no la API del proyecto. El `.fvmrc` ya refleja esto.

### 4.4 package Go sin renombrar
- **Decisión**: NO se cambió `module github.com/zarz/spotiflac_android/go_backend` en `go_backend/go.mod`.
- **Razón**: El path del módulo Go no afecta la compilación de la app Android. Renombrarlo podría romper tests o imports internos de Go. La identidad de la app viene del `applicationId` Android, no del module path de Go.
- **Si quieres renombrarlo igualmente**: editar `go_backend/go.mod` y buscar/reemplazar en archivos `.go` si hay imports internos.

### 4.5 No se regeneraron los íconos
- **Razón**: El usuario no proporcionó un diseño propio. Los íconos actuales siguen siendo los de SpotiFLAC Mobile (`icon.png`, `icon_android.png`, `icon_foreground_android.png`).
- **Próximo paso**: Reemplazar estos PNG y ejecutar `dart run flutter_launcher_icons` para regenerar las variantes por densidad en `android/app/src/main/res/`.

### 4.6 No se regeneraron los assets de readme
- **Razón**: Los banners (`assets/readme/banner-readme-*.png`) y screenshots (`1.jpg` a `4.jpg`) son del upstream. Reemplazarlos requiere assets de diseño que el usuario no proporcionó.

### 4.7 Strings de `MethodChannel` y notification channels NO renombrados
- **Decisión**: Los strings como `"com.zarz.spotiflac/backend"` (MethodChannel) y las constantes `ACTION_*` del DownloadService NO se renombraron.
- **Razón**: Son nombres lógicos internos, no afectan compilación ni branding visible. Cambiarlos requiere coordinarlos entre Kotlin (`MainActivity.kt`, `DownloadService.kt`) y Dart (`lib/services/platform_bridge.dart`). Por seguridad y para evitar romper comunicación, se dejaron como están.
- **Si decides cambiarlos**: hay que editar AMBOS lados de forma sincronizada (Kotlin + Dart).

---

## 5. Toolchain instalado (Windows)

Para reconstruir el entorno desde cero en otro equipo:

| Herramienta | Cómo se instaló |
|---|---|
| Git 2.54.0 | `winget install --id=Git.Git -e --silent` |
| Java 17 (Temurin) | `winget install --id=EclipseAdoptium.Temurin.17.JDK -e --silent` |
| Go 1.26.4 | `winget install --id=GoLang.Go -e --silent` |
| Dart SDK 3.12.2 | `winget install --id=Google.DartSDK -e --silent` |
| FVM 4.1.1 | `dart pub global activate fvm` |
| Flutter 3.44.3 | `fvm install 3.44.3` |
| Android cmdline-tools | Descarga manual de https://dl.google.com/android/repository/commandlinetools-win-13114758_latest.zip; extracción a `$ANDROID_HOME/cmdline-tools/latest/` |
| Android NDK 29.0.14206865 | `sdkmanager "ndk;29.0.14206865"` |
| Android Build-Tools 36.0.0 | `sdkmanager "build-tools;36.0.0"` |
| Android Platform 36 | `sdkmanager "platforms;android-36"` |
| Android CMake 3.22.1 | `sdkmanager "cmake;3.22.1"` |
| gomobile + gobind | `go install golang.org/x/mobile/cmd/gomobile@latest` y `go install golang.org/x/mobile/cmd/gobind@latest` |

### Variables de entorno permanentes (user-level)
```powershell
[Environment]::SetEnvironmentVariable('JAVA_HOME', 'C:\Program Files\Eclipse Adoptium\jdk-17.0.19.10-hotspot', 'User')
[Environment]::SetEnvironmentVariable('ANDROID_HOME', 'C:\Users\jason\AppData\Local\Android\Sdk', 'User')
[Environment]::SetEnvironmentVariable('Path', 'C:\Program Files\Eclipse Adoptium\jdk-17.0.19.10-hotspot\bin;' + $current, 'User')
[Environment]::SetEnvironmentVariable('Path', $current + ';C:\Program Files\Go\bin;C:\Users\jason\AppData\Local\Pub\Cache\bin;C:\Users\jason\AppData\Local\Android\Sdk\cmdline-tools\latest\bin;C:\Users\jason\AppData\Local\Android\Sdk\platform-tools', 'User')
```

---

## 6. Procedimiento de build verificado

Este procedimiento se ejecutó con éxito y se generó el APK debug (147 MB arm64).

```bash
# 1. Setup FVM
fvm install
fvm use

# 2. Backend Go → AAR (necesario solo si modificas go_backend/)
cd go_backend
mkdir -p ../android/app/libs
gomobile bind -target=android -androidapi 24 -o ../android/app/libs/gobackend.aar .
cd ..

# 3. Dependencias Dart
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# 4. Análisis
flutter analyze   # → No issues found

# 5. Build APK debug
flutter build apk --debug
# → Salida: build/app/outputs/flutter-apk/app-{arm64-v8a,armeabi-v7a,universal}-debug.apk
```

Verificación post-build:
```bash
# El APK resultante tiene la identidad correcta
aapt dump badging build/app/outputs/flutter-apk/app-debug.apk | grep -E "package:|application-label:"
# → package: name='com.kokeeu.neroflac' ...
# → application-label:'NeroFlac'
```

---

## 7. Estructura del repo

```
NeroFlac/
├── lib/                          # Código fuente Dart/Flutter
│   ├── app.dart                  # Widget raíz (NeroFlacApp)
│   ├── main.dart                 # Entry point
│   ├── constants/                # Constantes (app_info.dart con branding)
│   ├── l10n/                     # Localización (Crowdin, no modificar a mano)
│   ├── models/                   # Data models
│   ├── providers/                # Riverpod providers (store_provider tiene el default de extensiones)
│   ├── screens/                  # UI (settings, search, downloads, store, etc.)
│   ├── services/                 # Lógica de negocio (platform_bridge, downloads, etc.)
│   ├── theme/                    # Theming (dynamic_color_wrapper, app_theme)
│   ├── utils/                    # Utilidades
│   ├── widgets/                  # Widgets reutilizables
│   └── ...
├── android/                      # Proyecto Android
│   ├── app/
│   │   ├── build.gradle.kts      # namespace y applicationId = com.kokeeu.neroflac
│   │   ├── src/main/AndroidManifest.xml   # package = com.kokeeu.neroflac, label = NeroFlac
│   │   ├── src/main/kotlin/com/kokeeu/neroflac/   # 4 archivos Kotlin movidos aquí
│   │   └── libs/gobackend.aar    # AAR generado por gomobile (regenerar si tocas Go)
│   └── ...
├── ios/                          # Proyecto iOS (no modificado, no objetivo de este fork)
├── go_backend/                   # Backend Go (compilado a nativo via gomobile)
│   ├── go.mod                    # module github.com/zarz/spotiflac_android/go_backend (NO renombrado)
│   ├── extension_*.go            # Sistema de extensiones
│   ├── lyrics_*.go               # Providers de letras
│   ├── metadata*.go              # Metadata de audio
│   ├── deezer.go, songlink.go, idhs.go   # APIs externas
│   └── ...
├── assets/                       # Imágenes, fuentes
│   ├── readme/                   # Banners y screenshots (aún del upstream)
│   ├── images/                   # Logo
│   └── fonts/                    # Google Sans Flex
├── test/                         # Tests
├── .github/                      # CI/CD y templates
│   ├── workflows/release.yml     # Workflow de release (actualizado con branding NeroFlac)
│   └── ISSUE_TEMPLATE/           # Templates de issues
├── apps.json                     # Manifest de AltStore/SideStore (NeroFlac)
├── pubspec.yaml                  # Dependencias y metadata del package
├── pubspec.lock                  # Lockfile (regenerado con Dart 3.12.2)
├── .fvmrc                        # Versión Flutter (3.44.3)
├── README.md                     # README personalizado NeroFlac
├── LICENSE                       # MIT (heredado)
└── CHANGES.md                    # ESTE ARCHIVO
```

---

## 8. Próximos pasos sugeridos

### Corto plazo
1. **Reemplazar íconos**: Crear/proporcionar `icon.png` (1024x1024), `icon_android.png`, `icon_foreground_android.png` con branding NeroFlac. Ejecutar `dart run flutter_launcher_icons`.
2. **Reemplazar assets de readme**: Banners y screenshots con identidad NeroFlac.
3. **Probar la app**: Instalar el APK debug en un dispositivo real y verificar:
   - El Store carga las extensiones desde el repo por defecto
   - El tema usa el color violeta
   - El nombre "NeroFlac" aparece en el launcher
   - Las descargas funcionan (con un proveedor de extensiones)

### Mediano plazo
4. **Configurar secrets de GitHub Actions** en Kokeeu/NeroFlac si se quiere usar el workflow de release:
   - `KEYSTORE_BASE64`, `KEY_ALIAS`, `KEYSTORE_PASSWORD`, `KEY_PASSWORD` (para firmar APKs)
   - `TELEGRAM_BOT_TOKEN`, `TELEGRAM_CHANNEL_ID` (para notificaciones, opcional)
5. **Setup de keystore propio**: Generar un keystore para NeroFlac (no usar el de SpotiFLAC) y guardarlo seguro. Crear `android/key.properties` con los datos.
6. **Configurar GitHub Pages / releases**: Crear el primer release v4.6.0 con el APK firmado.

### Largo plazo (características a añadir/quitar)
7. Decidir si se quiere quitar alguna feature del upstream (p.ej. notificaciones, telemetry, kofi, etc.).
8. Personalizar la URL `remoteConfigApiUrl` en `lib/constants/app_info.dart` — actualmente apunta a `https://raw.githubusercontent.com/Kokeeu/NeroFlac/main/config.json` que NO existe. Crear ese archivo en el repo con la estructura esperada, o dejarlo apuntando a otro lugar.
9. (Opcional) Renombrar `module github.com/zarz/spotiflac_android/go_backend` → `github.com/kokeeu/neroflac/go_backend` y propagar los cambios en `go_backend/*.go`.

---

## 9. Convenciones y reglas para el próximo agente

1. **No tocar** `lib/l10n/*.dart` (archivos generados). Para cambiar strings, editar `lib/l10n/arb/app_en.arb` y correr `flutter gen-l10n`.
2. **No commitear** archivos generados: `.g.dart`, `.freezed.dart`, `.dart_tool/`, `build/`. Ya están en `.gitignore` o deberían estarlo.
3. **Si tocas `go_backend/`**: regenerar el AAR con `gomobile bind -target=android -androidapi 24 -o ../android/app/libs/gobackend.aar .` antes de build.
4. **Antes de cada push**: ejecutar `flutter analyze` y verificar 0 issues.
5. **Si cambias el package Dart o el applicationId**: hay que mover los archivos Kotlin también (`com/zarz/spotiflac/` → `com/kokeeu/neroflac/` en este caso) y renombrar todos los imports Dart (`package:spotiflac_android/` → `package:neroflac/` en este caso). El comando `find` + `sed` con `package:OLD/` → `package:NEW/` funciona bien.
6. **El repo `upstream` está configurado** para traer cambios futuros del repo original. Para sincronizar: `git fetch upstream && git rebase upstream/main` (resolver conflictos manualmente si los hay en archivos rebrandeados).

---

## 10. Información de la sesión de IA

- **AI utilizada**: MiniMax-M3 (modelo de código)
- **Tareas completadas**: 16 (ver todo list original si está disponible)
- **Tiempo estimado**: ~1.5 horas de sesión interactiva
- **Modo final**: build (con permisos de edición)
- **Decisión clave del usuario**: Force-push a Kokeeu/NeroFlac sobreescribiendo el commit inicial; identidad visual violeta; URL de extensiones = spotiflacapp/SpotiFLAC-Extension.

---

## 11. Feature: Importar listas de YouTube Music (sesión 2026-06-23)

### 11.1 Resumen

Añadido importador de playlists de YouTube Music con búsqueda por lote. El usuario pega una URL de YouTube Music, el extractor obtiene los nombres de las canciones, y se buscan en paralelo en un proveedor de búsqueda habilitado (Spotify Web, etc.) para descarga en lote.

### 11.2 Flujo

1. Usuario toca el icono `playlist_add_rounded` en la search bar del home tab
2. Pega URL de YouTube Music (o usa el botón Pegar)
3. Selecciona el proveedor de búsqueda
4. Toca "Buscar coincidencias"
5. Extractor intenta primero la extensión de YouTube Music vía `PlatformBridge.handleURLWithExtension`
6. Si no hay extensión o falla, fallback con `youtube_explode_dart` (parsing de la playlist page)
7. Búsqueda concurrente (3 workers en paralelo) usando `PlatformBridge.customSearchWithExtension`
8. Score Jaccard (title 0.6 + artist 0.4) para clasificar cada resultado: exact / approximate / none
9. Lista de resultados con iconos ✅/⚠️/❌
10. Toca "Descargar" → abre `DownloadServicePicker` para elegir calidad + servicio
11. Se encolan todas las canciones coincidentes con `addToQueue(qualityOverride, playlistName)`

### 11.3 Archivos nuevos

| Archivo | Descripción |
|---|---|
| `lib/services/youtube_playlist_extractor.dart` | Extractor con dos estrategias: extension → youtube_explode_dart fallback |
| `lib/services/batch_search_service.dart` | Búsqueda concurrente con scoring Jaccard |
| `lib/screens/import_playlist_screen.dart` | UI completa: 4 fases (idle/extracting/searching/ready), diálogos de error, picker de calidad |

### 11.4 Archivos modificados

| Archivo | Cambio |
|---|---|
| `pubspec.yaml` | Añadido `youtube_explode_dart: ^3.1.0` |
| `lib/screens/home_tab.dart` | Botón `playlist_add_rounded` en suffixIcon de la search bar; tooltip l10n |
| `lib/l10n/arb/app_en.arb` | 25 claves nuevas (`importPlaylist*`) |
| `lib/l10n/arb/app_es.arb` | 25 claves nuevas en español |
| `lib/l10n/app_localizations*.dart` | Regenerados (18 idiomas) |

### 11.5 Decisiones

- **Detección de extensión YouTube Music**: leniente (busca "youtube"/"ytmusic" en id, name, displayName o urlHandler.patterns)
- **Diálogo de extensión faltante**: dismisible (`barrierDismissible: true` + `PopScope`)
- **Bug fix en dialogs**: usa `dialogContext` del builder en vez del contexto externo para `Navigator.pop()` (antes los botones no respondían porque pop estaba cerrando el import screen, no el dialog)
- **Score Jaccard** sobre tokens en vez de Levenshtein (más rápido y robusto a prefijos/sufijos)
- **Fallback youtube_explode_dart** es poco fiable (YouTube bloquea IPs de datacenter); la extensión de YouTube Music es el método primario

### 11.6 UX añadidos

- Diálogo de validación en español para: URL vacía, URL no válida, sin proveedor, sin extensiones con búsqueda
- Diálogo "Se requiere la extensión de YouTube Music" con botón "Abrir Tienda" si no hay extensión instalada
- Mensaje "no se encontraron canciones" si el extractor devuelve 0 (URL privada/bloqueada/vacía)
- Snackbar final con conteo: "N pistas en cola para descargar" o "No hay coincidencias para descargar"
- "Re-search" como label del botón cuando ya hay resultados

---

## 12. Backup a Google Drive (DEFERRED — 2026-06-23)

Investigado pero NO implementado. Documentado para retomar en una sesión futura.

### 12.1 Lo que se investigó

- `pubspec.yaml` NO tiene `google_sign_in`, `googleapis`, ni `googleapis_auth`
- En el pub cache local SÍ están disponibles: `googleapis-14.0.0` (58 MB, incluye `drive/v3.dart`) y `googleapis_auth-2.0.0`
- El `app_state_database` y `library_database` ya almacenan `filePath` por canción, así que sabemos qué archivos respaldar
- El modo de almacenamiento `'saf'` ya usa `Intent.ACTION_OPEN_DOCUMENT_TREE` (visto en `MainActivity.kt:2278`), que ya SOPORTA Google Drive porque es un `DocumentsProvider` registrado en Android
- El usuario ya tiene la extensión "YouTube Music" instalada (visible con badge "Instalada" en Repositorio)

### 12.2 Opciones evaluadas

- **Opción A — Usar el modo SAF actual (0 código nuevo)**: El usuario ya puede elegir una carpeta de Google Drive como destino en Ajustes → Archivos → SAF. Las canciones se descargan DIRECTO a Drive sin OAuth, sin SDK adicional, sin dependencias nuevas. Funciona en iOS vía Files → iCloud Drive.
- **Opción B — Subir archivos locales a Drive vía API**: Requiere `google_sign_in: ^6.x` + `extension_google_sign_in_as_googleapis_auth: ^2.x` + credenciales OAuth de Google Cloud Project. ~3-5 días de trabajo, +1 MB de deps, mantenimiento de tokens.
- **Opción C — Híbrido (SAF + worker de respaldo automático)**: Igual de complejo que B pero con un worker periódico que suba archivos nuevos.

### 12.3 Recomendación

Empezar con A (ya funciona, no requiere código). Solo implementar B/C si el usuario reporta que quiere respaldo automático de archivos ya descargados localmente.

### 12.4 Para retomar más adelante

1. Confirmar con el usuario qué opción quiere (A/B/C)
2. Si B/C: crear Google Cloud Project, configurar OAuth consent screen, obtener Client ID
3. Añadir dependencias al `pubspec.yaml`
4. Implementar `lib/services/google_drive_backup_service.dart`
5. Nueva pantalla en `lib/screens/settings/google_drive_backup_page.dart`
6. Nuevas claves l10n en los 18 idiomas
7. Testing con cuentas reales de Google Drive (cuota 15 GB gratis)
8. Documentar en CHANGES.md al terminar

---

## 13. Sesión de release (2026-06-23)

Configuración de firma de release para generar APKs firmados publicables en GitHub Releases.

### 13.2 Publicación

- `gh` CLI instalado vía winget
- Release `v4.7.0` publicada en GitHub con los APKs `app-arm64-v8a-release.apk`, `app-armeabi-v7a-release.apk`, `app-x86_64-release.apk`
- `apps.json` actualizado con la URL del release

