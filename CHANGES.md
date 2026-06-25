# CHANGES.md — Historial de cambios y contexto

> **Propósito**: Este documento deja constancia de todo lo realizado en este fork de SpotiFLAC-Mobile → SiwöFlac. Está pensado para que cualquier otro agente de IA (o persona) pueda retomar el trabajo sin perder el contexto. Léelo antes de hacer cualquier cambio.

---

## 1. Identidad del fork

| Campo | Valor |
|---|---|
| **Nombre** | SiwöFlac |
| **Package Dart** | `neroflac` |
| **Package Android (applicationId / namespace)** | `com.kokeeu.neroflac` |
| **App label** | `SiwöFlac` |
| **Autor** | Kokeeu (https://github.com/Kokeeu) |
| **Repo upstream (source fork)** | https://github.com/spotiflacapp/SpotiFLAC-Mobile |
| **Repo destino (este fork)** | https://github.com/Kokeeu/SiwöFlac |
| **Versión inicial** | 4.6.0+135 (basada en SpotiFLAC Mobile v4.6.0) |
| **Flutter SDK** | 3.44.3 (era 3.41.5 upstream, se actualizó porque el pubspec lo requería) |
| **Go SDK** | 1.26.4 (la 1.25.7 upstream también sirve) |
| **JDK** | Temurin 17.0.19.10 (de Eclipse Adoptium) |
| **Android SDK** | Platform 36, Build-Tools 36.0.0 + 36.1.0, NDK 29.0.14206865, CMake 3.22.1 |

---

## 2. Resumen ejecutivo

Este fork es un **rebrand** puro de SpotiFLAC Mobile. No se cambió la lógica de negocio, ni el sistema de extensiones, ni los providers de letras/metadata, ni FFmpeg. Solo se renombró la identidad visible y la URL por defecto del Store de extensiones.

**Commit único inicial**: `4686353 feat: initial fork of SpotiFLAC Mobile as SiwöFlac`

**Por qué force-push**: El repo `Kokeeu/SiwöFlac` ya existía en GitHub con un commit inicial de prueba (`# SiwöFlac` en README). Se sobreescribió con el contenido rebrandeado de SpotiFLAC Mobile usando `git push --force`.

---

## 3. Lista de cambios por archivo

### 3.1 Identidad y branding

| Archivo | Cambio |
|---|---|
| `pubspec.yaml` | `name: spotiflac_android` → `name: neroflac`; descripción actualizada |
| `android/app/build.gradle.kts` | `namespace` y `applicationId` de `com.zarz.spotiflac` → `com.kokeeu.neroflac` |
| `android/app/src/main/AndroidManifest.xml` | `package="com.zarz.spotiflac"` → `package="com.kokeeu.neroflac"`; `android:label="SpotiFLAC Mobile"` → `android:label="SiwöFlac"` |
| `android/app/src/main/kotlin/com/zarz/spotiflac/*.kt` (4 archivos) | Movidos a `com/kokeeu/neroflac/`; `package com.zarz.spotiflac` → `package com.kokeeu.neroflac` en cada uno. Archivos: `DownloadService.kt`, `MainActivity.kt`, `NativeDownloadFinalizer.kt`, `SafDownloadHandler.kt` |
| `lib/constants/app_info.dart` | `appName="SpotiFLAC Mobile"` → `"SiwöFlac"`; `copyright="© 2026 SpotiFLAC"` → `"© 2026 SiwöFlac"`; `mobileAuthor="zarzet"` → `"Kokeeu"`; `githubRepo="zarzet/SpotiFLAC-Mobile"` → `"Kokeeu/SiwöFlac"`; `remoteConfigApiUrl` → apunta al `config.json` del repo SiwöFlac; `kofiUrl` y `githubSponsorsUrl` vacíos (no se monetiza) |
| `lib/models/theme_settings.dart` | `kDefaultSeedColor` de verde Spotify `0xFF1DB954` → violeta `0xFF7C3AED` |
| `lib/app.dart` | Clase `SpotiFLACApp` → `SiwöFlacApp` |
| `lib/main.dart` | Llamada a `SpotiFLACApp(...)` → `SiwöFlacApp(...)` |
| `README.md` | Reescrito completamente; declara explícitamente que es un fork, atribuye al autor original, mantiene el disclaimer legal |
| `apps.json` | Bundle ID, nombre, developer, URL de descarga y de icono actualizados a SiwöFlac |
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
| `.github/ISSUE_TEMPLATE/config.yml` | URL del README apuntando a Kokeeu/SiwöFlac |
| `.github/ISSUE_TEMPLATE/bug_report.yml` | Labels y descripciones actualizadas a "SiwöFlac" |
| `.github/ISSUE_TEMPLATE/download_issue.yml` | Idem |
| `.github/ISSUE_TEMPLATE/extension_feature_request.yml` | Idem; URL del docs guide apuntando al repo SiwöFlac |
| `.github/workflows/release.yml` | Nombres de artefactos APK/IPA cambiados a `SiwöFlac-${VERSION}-*.apk` / `SiwöFlac-${VERSION}-ios-unsigned.ipa`; release name actualizado; URL de download en `apps.json` apunta a Kokeeu/SiwöFlac |

---

## 4. Decisiones de diseño tomadas

### 4.1 Seed color: violeta `#7C3AED`
- **Razón**: "Nero" = negro en italiano. Quería un color semilla que generara un esquema predominantemente oscuro pero con identidad propia. El violeta intenso da un look moderno y elegante en dark mode, sin ser negro plano.
- **Alternativas consideradas**: negro puro (`0xFF000000`) — genera scheme sin color; carbón (`0xFF1A1A1A`) — similar; rojo oscuro (`0xFF7F1D1D`) — coherente con "intenso" pero menos elegante.
- **Cómo cambiarlo**: editar `lib/models/theme_settings.dart` línea 9. También se puede cambiar desde la app en *Settings → Appearance → Theme color*.

### 4.2 URL de extensiones: `spotiflacapp/SpotiFLAC-Extension`
- **Razón**: El usuario pidió apuntar a ese repo específico. Es el repo oficial de extensiones de SpotiFLAC, lo que permite que SiwöFlac use las mismas extensiones que SpotiFLAC Mobile sin forkearlas.
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
# → application-label:'SiwöFlac'
```

---

## 7. Estructura del repo

```
SiwöFlac/
├── lib/                          # Código fuente Dart/Flutter
│   ├── app.dart                  # Widget raíz (SiwöFlacApp)
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
│   │   ├── src/main/AndroidManifest.xml   # package = com.kokeeu.neroflac, label = SiwöFlac
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
│   ├── workflows/release.yml     # Workflow de release (actualizado con branding SiwöFlac)
│   └── ISSUE_TEMPLATE/           # Templates de issues
├── apps.json                     # Manifest de AltStore/SideStore (SiwöFlac)
├── pubspec.yaml                  # Dependencias y metadata del package
├── pubspec.lock                  # Lockfile (regenerado con Dart 3.12.2)
├── .fvmrc                        # Versión Flutter (3.44.3)
├── README.md                     # README personalizado SiwöFlac
├── LICENSE                       # MIT (heredado)
└── CHANGES.md                    # ESTE ARCHIVO
```

---

## 8. Próximos pasos sugeridos

### Corto plazo
1. **Reemplazar íconos**: Crear/proporcionar `icon.png` (1024x1024), `icon_android.png`, `icon_foreground_android.png` con branding SiwöFlac. Ejecutar `dart run flutter_launcher_icons`.
2. **Reemplazar assets de readme**: Banners y screenshots con identidad SiwöFlac.
3. **Probar la app**: Instalar el APK debug en un dispositivo real y verificar:
   - El Store carga las extensiones desde el repo por defecto
   - El tema usa el color violeta
   - El nombre "SiwöFlac" aparece en el launcher
   - Las descargas funcionan (con un proveedor de extensiones)

### Mediano plazo
4. **Configurar secrets de GitHub Actions** en Kokeeu/SiwöFlac si se quiere usar el workflow de release:
   - `KEYSTORE_BASE64`, `KEY_ALIAS`, `KEYSTORE_PASSWORD`, `KEY_PASSWORD` (para firmar APKs)
   - `TELEGRAM_BOT_TOKEN`, `TELEGRAM_CHANNEL_ID` (para notificaciones, opcional)
5. **Setup de keystore propio**: Generar un keystore para SiwöFlac (no usar el de SpotiFLAC) y guardarlo seguro. Crear `android/key.properties` con los datos.
6. **Configurar GitHub Pages / releases**: Crear el primer release v4.6.0 con el APK firmado.

### Largo plazo (características a añadir/quitar)
7. Decidir si se quiere quitar alguna feature del upstream (p.ej. notificaciones, telemetry, kofi, etc.).
8. Personalizar la URL `remoteConfigApiUrl` en `lib/constants/app_info.dart` — actualmente apunta a `https://raw.githubusercontent.com/Kokeeu/SiwöFlac/main/config.json` que NO existe. Crear ese archivo en el repo con la estructura esperada, o dejarlo apuntando a otro lugar.
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
- **Decisión clave del usuario**: Force-push a Kokeeu/SiwöFlac sobreescribiendo el commit inicial; identidad visual violeta; URL de extensiones = spotiflacapp/SpotiFLAC-Extension.

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

---

## 14. Fix: descargas redirigidas silenciosamente a YouTube Music cuando se elige Tidal (sesión 2026-06-23)

### 14.1 Problema

Cuando el usuario tenía instaladas simultáneamente la extensión **YouTube Music** (que declara `replacesBuiltInProviders: ["tidal", "youtube", "qobuz", "deezer"]` en su manifiesto) y una extensión **Tidal dedicada**, las descargas se ejecutaban siempre vía YouTube Music aunque el usuario eligiera Tidal explícitamente en el `DownloadServicePicker`.

El resultado: tracks con metadata correcta de Tidal (Tidal ID poblado) pero descargados como Opus 139-146 kbps en lugar de FLAC, con `Servicio: YTMUSIC-SPOTIFLAC` en el detalle.

### 14.2 Causa raíz

El mecanismo heredado de SpotiFLAC `replacesBuiltInProviders` se diseñó para reemplazar built-ins retirados (Tidal, Qobuz, Deezer, YouTube) cuando no había extensión dedicada. El código aplicaba la sustitución en tres puntos:

- `extension_provider.dart:resolveEffectiveDownloadService` (línea 267) — sustituía "tidal" → extensión YTMusic
- `extension_provider.dart:replacedBuiltInDownloadProviderFor` (línea 1241) — devolvía la extensión sustituta
- `download_queue_provider.dart:_normalizeQueuedService` (línea 3107) — aplicaba la sustitución 3 veces (encolado + descarga)

Cuando además había una extensión dedicada instalada (ej. `tidal-spotiflac`), la sustitución prevalecía sobre ella porque no se comprobaba su existencia.

### 14.3 Solución

Introducir el concepto de **"extensión dedicada"**: una extensión es dedicada para un servicio (slug: `tidal`, `qobuz`, `deezer`, `youtube`) si:
1. Está habilitada y tiene la capacidad correspondiente (download / search / metadata)
2. Su `id` o `displayName` contiene el slug
3. **No** declara ese slug en `replacesBuiltInProviders` (eso la marcaría como sustituta genérica, no dedicada)

Cuando hay una extensión dedicada, se prefiere sobre cualquier sustituta. Esto preserva el comportamiento actual cuando solo hay YTMusic instalada (sigue siendo sustituta de Tidal/YouTube/etc.) y corrige el bug cuando hay dedicada.

### 14.4 Archivos modificados

| Archivo | Cambio |
|---|---|
| `lib/providers/extension_provider.dart` | Helpers `_isDedicatedServiceExtension`, `_dedicatedDownloadExtensionFor`, `_dedicatedMetadataExtensionFor`, `_dedicatedSearchExtensionFor`; rama "dedicated-before-replacement" en `resolveEffectiveDownloadService`, `resolveEffectiveMetadataProvider`, `replacedBuiltInDownloadProviderFor`, `replacedBuiltInSearchProviderFor`, `replacedBuiltInMetadataProviderFor`, `_reconcileDefaultDownloadService`, `_reconcileSearchProvider` |
| `test/extension_resolution_test.dart` | 8 tests nuevos: Tidal dedicada + YTMusic replacement → gana Tidal; solo YTMusic → gana YTMusic (back-compat); match por id exacto; fallback; excludes-sustituta-como-dedicada; sin extensiones → ""; versión metadata |

### 14.5 Tests

```bash
flutter test test/extension_resolution_test.dart
# → 8/8 tests passed
```

`flutter analyze` → No issues found.

### 14.6 Verificación manual en emulador

- Emulador: `Medium_Phone_API_36.1` (x86_64)
- Build: `flutter build apk --debug` (universal con arm64-v8a + armeabi-v7a + x86_64)
- Instalación: `adb install -r app-debug.apk`
- Flujo: importar playlist YTMusic → batch search → Download → picker → elegir Tidal → descarga llega como FLAC con `Servicio: TIDAL-...`

### 14.7 Nota técnica

El primer build falló con `--target-platform android-arm64` porque el emulador es x86_64 (`UnsatisfiedLinkError: libflutter.so is for EM_AARCH64`). Se reconstruyó sin restricción de plataforma para incluir x86_64.

Scripts auxiliares creados para iterar más rápido:
- `C:/Users/jason/start-emulator.bat` — lanza el AVD desacoplado del shell
- `C:/dev/neroflac/local/build-and-install.bat` — `pub get` + `build apk --debug` + `adb install -r`

---

## 17. Rebrand visible: pass creativa con tokens Wiza (sesión 2026-06-23)

### 17.1 Problema detectado

Después de aplicar la Fase 1–3, el rebrand quedaba "estructural" pero el usuario reportó **"casi no cambia nada del original"**. Diagnóstico:

- Solo `repo_tab.dart` usaba `NeroTheme.of(context)` explícitamente; el resto seguía renderizando con `Theme.of(context).colorScheme.surface` que M3 genera casi igual al esquema anterior.
- Plus Jakarta Sans solo aparecía en display (24-64px); en body seguía Inter.
- No había cards con tinte lavanda, ni accents MistViolet visibles.
- El bottom nav sí cambió (pill MistViolet) pero era el único elemento muy notable.

### 17.2 Solución: pass creativa completa

Ejecutada en una sola pasada (decisión del usuario), combinó 3 estrategias:

#### A) Globals — el theme se hizo sentir en TODA la app

- **Default font**: `fontFamily` cambió de `Inter` a `Inter`, pero `TextTheme.titleLarge` y AppBar titles ahora usan **Plus Jakarta Sans weight 500** automáticamente (sin tocar cada screen).
- **Surfaces overrideados** explícitamente en el theme:
  - `scaffoldBackgroundColor = nero.canvas` (blanco) en lugar de M3 surface oscuro
  - `cardTheme.color = nero.canvas` con hairline border `nero.mist`
  - `dialogTheme.backgroundColor = nero.canvas`, sin backdrop blur
  - `bottomSheetTheme.backgroundColor = nero.canvas`, 24px top radius
  - `navigationBarTheme.indicatorColor = nero.mistViolet` (pill)
  - `snackBarTheme.backgroundColor = nero.deepIris` con texto canvas
  - `switchTheme.trackColor` activo = RoyalAmethyst, inactivo = smoke con outline mist
  - `progressIndicatorTheme.color = nero.royalAmethyst`
- **AppBarTheme**: title en `Plus Jakarta Sans 20px weight 500 height 1.0`, color `nero.deepIris`
- **Page transitions**: preservados (`FadeForwardsPageTransitionsBuilder` workaround flutter#152323)

#### B) Tokens extendidos en `NeroTheme`

- **Nuevos colores semánticos**: `lavenderGlow` (#B99AFF), `twilightBeam` (#CF8AFF)
- **Nuevos radius tokens**: `radiusSearch = 16px` (search bars más redondeados)
- **3 gradientes decorativos**:
  - `gradientHeroWash` — vertical MistViolet → canvas (atmosphere lavanda)
  - `gradientLavender` — horizontal LavenderGlow → RoyalAmethyst 10% → transparent
  - `gradientTwilightBeam` — multi-stop TwilightBeam → Rosa → Peach → Lavender (hero glow)

#### C) Migración screen por screen (Inicio + Repositorio + Tutoriales)

**`lib/screens/home_tab.dart`**:
- **SliverAppBar**: hero con `Stack` superpuesto — fondo lavanda (`gradientHeroWash`) que se desvanece al scroll, **pill "SiwöFlac"** decorativo en RoyalAmethyst con punto MistViolet en el top, título en Plus Jakarta Sans scaling 22-40px
- **Search bar**: radius 16px (`radiusSearch`), border `mist` normal / `royalAmethyst` focus, hint en `ash`, prefix icon en `slate`
- **`_buildRecentAccess`**: header con barra vertical RoyalAmethyst 4×16 + título Plus Jakarta Sans 18px, empty state en container Paper con icon circle MistViolet + `NeroButton` ghost variant
- **`_buildEmptySearchResultWidget`**: gradient MistViolet + LavenderGlow en el icon container, título Plus Jakarta Sans 22px, description en slate

**Tutoriales** (visibles al usuario final):
- Título Plus Jakarta Sans weight 500 con line-height 1.0
- "Storage Permission Granted!" card usa el **tag Wiza** style (MistViolet bg, RoyalAmethyst text)
- Splash screen con fondo Deep Iris (todo el splash es el color primario de Wiza)

### 17.3 Resultados visibles en emulador (verificados)

✅ Splash screen: fondo Deep Iris `#26114A` + bird logo  
✅ Tutorial page 1: "SiwöFlac" en Plus Jakarta Sans, "Download music in true FLAC", botón Next Deep Iris  
✅ Tutorial page 2: "Choose Language" con pill "System Default" MistViolet  
✅ Tutorial page 3: "Storage Permission Required" + botón "Grant Permission" Deep Iris filled + icon folder MistViolet circle  
✅ Tutorial page 4: "Enable Notifications" + card "Storage Permission Granted!" en pill MistViolet/RoyalAmethyst  
✅ Bottom nav: indicador MistViolet pill cuando el destino está activo  
✅ AppBar titles: Plus Jakarta Sans cuando se renderizan

### 17.4 Archivos modificados en esta sesión

| Archivo | Cambio |
|---|---|
| `lib/theme/app_theme.dart` | fontFamily display, surfaces overrideadas, AppBarTheme Plus Jakarta Sans |
| `lib/theme/nero_theme_extension.dart` | 3 nuevos colores, radiusSearch, 3 gradientes |
| `lib/screens/home_tab.dart` | hero lavanda + pill decorativa, search bar Wiza, recent access header |
| `lib/widgets/nero/nero_show.dart` | showNeroSheet y showNeroDialog |
| `lib/widgets/nero/nero_button.dart` | (ya existía; consumido por empty state de home_tab) |
| `lib/widgets/empty_state.dart` | (ya existía; consumido) |
| `lib/widgets/error_state.dart` | (ya existía; consumido) |

### 17.5 Lo que queda pendiente (futuro)

- `queue_tab.dart` (7122 líneas) — header typography + filter chips como pills + selection overlay MistViolet
- `settings_tab.dart` + 15 subpantallas — lavender wash header + Plus Jakarta titles
- `about_page.dart` — hero wordmark "SiwöFlac" en Plus Jakarta 32px + DonateLinksCard con shadow
- `album_screen.dart`, `playlist_screen.dart`, `artist_screen.dart` — hero gradient en FlexibleSpaceBar
- Migrar `ElevatedButton`/`TextButton` call sites a `NeroButton`
- Crear `NeroTextField` y reemplazar `TextField` con él
- Auditoría de las 4 pantallas monolíticas

### 17.6 Verificación

```bash
flutter analyze                              → No issues found
flutter test                                 → 31/31 tests passed (sin cambios funcionales)
flutter build apk --debug                    → Built app-debug.apk (universal arm64+x86_64)
adb install -r app-debug.apk                 → Success
adb shell am start ...                        → PID activo, sin crashes
```

El fix original de Tidal/YTMusic (sección 14) sigue activo: `extension_resolution_test.dart` 8/8 passing.

## 15. Rebrand visual: Wiza ("Twilight prospecting observatory") (sesión 2026-06-23)

### 15.1 Resumen

Reescritura completa del sistema visual inspirada en el style reference **Wiza**: light-mode monocromático-violeta, sin glassmorphism, con tipografía dual (Plus Jakarta Sans para display, Inter para body), radius 8px como firma, y una jerarquía de tokens propia. Sustituye la identidad anterior (Material 3 + iOS 26 Liquid Glass + violeta iris + dark-default).

### 15.2 Decisiones

| Aspecto | Antes | Después |
|---|---|---|
| Modo por defecto | Dark | Light |
| Modos disponibles | light, dark, system, AMOLED | light, dark, system |
| Color semilla | `#AF50FF` (violeta iris) | `#26114A` Deep Iris (Wiza) |
| Dynamic color | habilitado por defecto | eliminado |
| AMOLED | opción manual | eliminado |
| Glassmorphism | `GlassSurface` con blur 40-50 | eliminado, reemplazado por superficies planas |
| Font display | Inter (tamaños mixtos) | Plus Jakarta Sans (24-64px, line-height 1.0) |
| Font body | Inter | Inter (sin cambios) |
| Radius scale | 19.2 / 8 / pill (3 tiers) | 8 / 24 / 1440 (cards/buttons/inputs/large/pills) |
| Sombras | sin definir | multi-layer blue-tinted (`#123769`, `#0E3B65`) |
| Tokens de spacing | sin definir | 11 tiers base 8px (`spacing8`–`spacing216`) |

### 15.3 Paleta canónica (Wiza)

| Token | Hex | Uso |
|---|---|---|
| `deepIris` | `#26114A` | Texto principal, headlines, logo, filled buttons |
| `plumVelvet` | `#312749` | Texto secundario |
| `royalAmethyst` | `#3E0079` | Links, focus rings, accent strokes |
| `mistViolet` | `#EDECFF` | Tinted surfaces, hover states, accent tags |
| `canvas` | `#FFFFFF` | Fondo, superficies base |
| `paper` | `#F6F7FA` | Lift sutil, alternancia en tablas |
| `mist` | `#E6E2E3` | Hairline borders |
| `smoke` | `#C1C7CF` | Disabled, skeletons |
| `ash` | `#9491A1` | Helper text, placeholders |
| `slate` | `#615E6E` | Texto secundario, descripciones |
| `charcoal` | `#333333` | Body text, neutral icons |

### 15.4 Archivos nuevos

- `lib/theme/nero_theme_extension.dart` — `NeroTheme extends ThemeExtension<NeroTheme>` con spacing, radius, shadows y paleta semántica
- `lib/widgets/nero/nero_button.dart` — `NeroButton` (filled / ghost / pill)
- `lib/widgets/nero/nero_tag.dart` — `NeroTag` (pill 1440px radius, accent / neutral)
- `lib/widgets/nero/nero_surface.dart` — `NeroSurface` (reemplaza `GlassSurface`; acepta parámetros legacy por compat)
- `lib/widgets/nero/nero_appbar.dart` — `NeroAppBar` + `NeroSliverAppBar`
- `lib/widgets/nero/nero_show.dart` — `showNeroSheet` + `showNeroDialog` (reemplazan las versiones glass)
- `lib/widgets/empty_state.dart` — `EmptyState` compartido
- `lib/widgets/error_state.dart` — `ErrorStateView` compartido

### 15.5 Archivos modificados

- `lib/theme/app_theme.dart` — reescritura completa (Wiza TextTheme, light/dark, sin glass)
- `lib/theme/dynamic_color_wrapper.dart` — simplificado (sin `dynamic_color`, sin AMOLED)
- `lib/models/theme_settings.dart` — `defaultThemeMode = light`, eliminados `useDynamicColor` y `useAmoled`
- `lib/providers/theme_provider.dart` — persistencia ajustada
- `lib/screens/settings/appearance_settings_page.dart` — quitado switch Dynamic Color y AMOLED; añadida card "Brand color" (read-only swatch)
- `lib/widgets/settings_group.dart` — refresh Wiza (icon 20, padding 14/12, hairline dividers, typography scale)
- `lib/widgets/audio_quality_badges.dart` — pills Mist Violet (radius 1440px)
- `pubspec.yaml` — añadido Plus Jakarta Sans, eliminada referencia huérfana a GoogleSansFlex

### 15.6 Archivos eliminados

- `lib/widgets/glass/glass.dart`
- `lib/widgets/glass/glass_appbar.dart`
- `lib/widgets/glass/glass_sliver_appbar.dart`
- `lib/widgets/glass/glass_sheet.dart`
- `assets/fonts/GoogleSansFlex.ttf` (huérfano, no estaba en pubspec)
- 13 constantes de colores "Dope Security" sin uso (`kColorVoid`, `kColorBoneWhite`, `kColorAsh`, `kColorSlate`, `kColorGraphite`, `kColorSmoke`, `kColorIron`, `kColorCinder`, `kColorPlum`, `kColorAubergine`, `kColorStormGray`, `kColorLavenderWash`, `kColorOrchidRadial`, `kColorAmethystBand`)

### 15.7 Migración de call sites (44 archivos)

Las funciones `showGlassModalBottomSheet` → `showNeroSheet`, `showGlassDialog` → `showNeroDialog`, `GlassAppBar` → `NeroAppBar`, `GlassSliverAppBar` → `NeroSliverAppBar`, `GlassSurface` → `NeroSurface` se renombraron globalmente vía script Python. Los imports `package:neroflac/widgets/glass/*` se redirigieron a `package:neroflac/widgets/nero/*`.

`NeroSurface` mantiene parámetros legacy (`blur`, `opacity`, `tint`, `sampleColor`, `showShadow`, etc.) ignorados en runtime para evitar romper call sites que no se han migrado todavía.

### 15.8 Tests y verificación

```bash
flutter analyze                              → No issues found!
flutter test                                 → All 31 tests passed
flutter test test/extension_resolution_test  → 8/8 tests passed (fix de Tidal/YTMusic preservado)
flutter build apk --debug                    → Built app-debug.apk
adb install -r app-debug.apk                 → Success
adb shell am start ...                       → app abre sin crash (PID 9090)
```

### 15.9 Cosas NO tocadas (conscientes)

- Lógica de providers, screens, Go backend, OAuth scheme `spotiflac://`, extensión de archivo `.spotiflac-ext`, bundle iOS, User-Agent `SpotiFLAC-Mobile` (decisiones del fork conservadas)
- Auditoría detallada de las 4 pantallas monolíticas (`queue_tab.dart` 7122 líneas, `track_metadata_screen.dart` 5103, `home_tab.dart` 3652, `artist_screen.dart` 2186) — pendiente para iteraciones futuras
- `TrackTile` widget compartido — pendiente; los tracks siguen renderizados inline en cada screen con su propia variación
- Botones/Inputs en screens — siguen usando los themes globales actualizados (no se han reemplazado manualmente los call sites de `ElevatedButton`/`TextField` con `NeroButton`/`NeroTextField`)

### 15.10 Backup

Backup manual realizado antes del rebrand: `C:/Users/jason/neroflac-backup-{timestamp}/`
Contiene `lib/theme/`, `lib/widgets/`, `lib/models/`, `pubspec.yaml`, `lib/app.dart`. Para rollback manual, copiar de vuelta sobre `C:/dev/neroflac/local/`.

---

## 16. Notas de rollback (rebrand Wiza)

Si el rebrand causa problemas visuales o de UX no anticipados, los pasos para revertir son:

1. **Restaurar archivos del backup**:
   ```bash
   cp -r C:/Users/jason/neroflac-backup-{timestamp}/lib/theme/* C:/dev/neroflac/local/lib/theme/
   cp -r C:/Users/jason/neroflac-backup-{timestamp}/lib/widgets/* C:/dev/neroflac/local/lib/widgets/
   cp -r C:/Users/jason/neroflac-backup-{timestamp}/lib/models/* C:/dev/neroflac/local/lib/models/
   cp C:/Users/jason/neroflac-backup-{timestamp}/pubspec.yaml C:/dev/neroflac/local/pubspec.yaml
   ```

2. **Reinstalar el APK anterior** desde GitHub Releases (`v4.7.0`):
   `https://github.com/Kokeeu/SiwöFlac/releases/tag/v4.7.0`

3. **Si quieres quedarte parcialmente** (mantener fix de Tidal pero no el rebrand):
   - Conserva los cambios de la sección 14 (`extension_provider.dart`)
   - Conserva `lib/widgets/empty_state.dart` y `lib/widgets/error_state.dart` (additive)
   - Revierte todo lo demás

### 16.1 Riesgos materializados durante la ejecución

- **Duplicate imports**: 3 archivos importaban `glass_appbar` y `glass_sliver_appbar` que apuntaban al mismo destino. Resuelto eliminando duplicados.
- **`colorScheme` parameter drift**: los `AudioQualityBadge` y `DolbyAtmosBadge` antiguos requerían `colorScheme`; los nuevos usan `NeroTheme.of(context)` internamente. Los 6 call sites se actualizaron.
- **`SettingsSwitchItem` parameter drift**: la firma original no tenía `enabled` ni `titleTrailing`; se añadieron por compat con los call sites.
- **`showNeroSheet` parameter drift**: se añadieron `useSafeArea`, `showDragHandle`, `backgroundColor`, `constraints`, `padding` para mantener compatibilidad con los 20+ call sites que los usaban.
- **`NeroSliverAppBar` API**: reescrito para mantener la firma original (`child: SliverAppBar`) — los call sites no requieren cambios.

### 16.2 Pendiente para iteraciones futuras

- Reemplazar `ElevatedButton`/`OutlinedButton`/`TextButton`/`FilledButton` con `NeroButton` en las pantallas (consistencia visual aún no aprovechada al 100%)
- Crear `NeroTextField` y reemplazar `TextField`/`TextFormField` con él
- Crear `TrackTile` consolidado (6+ implementaciones inline)
- Crear `LoadingState` (wrapper sobre los skeletons existentes)
- Auditoría visual de `queue_tab.dart`, `track_metadata_screen.dart`, `home_tab.dart`, `artist_screen.dart`
- Considerar tipografía dual en más superficies (headlines de secciones, no solo app bars)

---

## 18. Dark mode pass: fondo y superficies (sesión 2026-06-24)

La primera pasada de dark mode (sección 14) eliminaba el tinte violeta de M3 vía `darkCanvas`/`darkPaper`, pero dejaba varios elementos en blanco/lavanda porque dependían del token `canvas` (que es siempre `#FFFFFF`). Esta sesión cierra esos huecos.

### Cambios

**`lib/theme/nero_theme_extension.dart`**
- `gradientHeroWash` ahora es brightness-aware:
  - Light: `[mistViolet, canvas]` (igual que antes).
  - Dark: `[#2A1F4A, #14121A]` — glow sutil plum → canvas oscuro, manteniendo el lenguaje de marca sin lavar la pantalla.

**`lib/theme/app_theme.dart`**
- `_navigationBarTheme` → `backgroundColor: nero.paper` (era `nero.canvas`).
- `_navigationBarTheme` → icono y label seleccionados ahora usan `nero.carbon` (era `nero.deepIris`). En dark mode `deepIris` era invisible sobre el pill.
- `_bottomSheetTheme` → `backgroundColor` y `modalBackgroundColor` ahora `paper`.
- `_dialogTheme` → `backgroundColor` ahora `paper`.
- `_inputDecorationTheme` → `fillColor` ahora `paper` (afecta a todos los `TextField`/`InputDecoration` global).
- `_outlinedButtonTheme` → `foregroundColor` y `side` usan `scheme.primary` (M3 lo calcula correctamente por brightness).
- Títulos de dialog/bottom sheet → `color: nero.carbon` (era `deepIris`).

**`lib/screens/home_tab.dart`**
- SliverAppBar del home → `backgroundColor: nero.paper` (era `canvas`).
- Título "Home" del FlexibleSpaceBar → `color: nero.carbon` (era `deepIris`).
- Search bar de exploración → `fillColor: nero.paper` (era `canvas`).
- TextStyle inline con `color: nero.deepIris` → `nero.carbon` (3 sitios: títulos de search provider, chips, hint del input).

**`lib/screens/repo_tab.dart`**
- Título "Extension Repo" → `color: nero.carbon` (era `deepIris`).
- Título de cada tarjeta de extensión → `color: nero.carbon`.
- Texto del input de búsqueda → `color: nero.carbon`.
- Label de los chips (`All`, `Metadata`, `Download`, `Settings`) → `color: nero.carbon`.
- Search bar → `fillColor: nero.paper`.

### Filosofía del fix

`canvas` se mantiene siempre blanco por dos razones:
1. Se usa como foreground sobre superficies oscuras (pill `royalAmethyst`, switch thumb, texto sobre botón purple) y debe permanecer claro en ambos modos.
2. El primer color de `gradientHeroWash` en light mode necesita ser un "blanco canónico" para el degradado.

Las superficies que cambian con el modo usan `paper` (que ya era brightness-aware: `isDark ? darkCanvas : paper`).

### Verificación

- Home, Library, Repo, Settings y Appearance revisitados en dark mode.
- Bottom nav: pasa de blanco puro a `#1E1A24` con borde sutil.
- Hero del home: pasa de lavanda→blanco a plum→dark, con título "Home" blanco legible.
- Títulos de extensiones: pasan de deepIris invisible a blanco nítido.
- Light mode sin regresiones: `paper` en light = `#F6F7FA` (neutro cálido) — visualmente consistente con el tono lavanda del hero.

### Pendiente menor

- El chip "All" seleccionado en Repo usa `mistViolet` como fondo, lo que da un pill casi blanco con texto lavanda — contraste pobre en dark mode. Considerar `lavenderGlow` para `indicatorColor` en dark.
- El indicador del `NavigationBar` también usa `mistViolet` con el mismo trade-off — funciona pero podría refinarse.

---

## 19. Dark mode contrast pass (sesión 2026-06-24)

El primer dark mode tenía contraste pobre en dos áreas clave:

1. **Títulos de settings/cards** que heredan de `scheme.primary` → M3 genera un morado oscuro desde el seed `#26114A`, prácticamente invisible sobre `darkPaper`.
2. **Icono y label del `NavigationBar` seleccionado** sobre el pill `mistViolet`: en dark mode el icono era `carbon` (casi blanco), por lo que desaparecía sobre el pill claro.

### Cambios

**`lib/theme/app_theme.dart`**

`dark()` ahora overridea el `ColorScheme` además de las surfaces:

```dart
scheme = scheme.copyWith(
  primary: nero.lavenderGlow,        // era M3-derived dark purple
  onPrimary: nero.deepIris,
  primaryContainer: nero.royalAmethyst,
  onPrimaryContainer: nero.mistViolet,
  secondary: nero.lavenderGlow,
  onSecondary: nero.deepIris,
  surface: nero.darkCanvas,
  surfaceContainerLowest: nero.darkSurfaceLowest,
  surfaceContainerLow: nero.darkPaper,
  surfaceContainer: nero.darkSurface,
  surfaceContainerHigh: nero.darkSurfaceHigh,
  surfaceContainerHighest: nero.darkSurfaceHighest,
  outline: nero.darkOutline,
  outlineVariant: nero.darkOutlineVariant,
  onSurface: nero.darkOnSurface,
  onSurfaceVariant: nero.darkOnSurfaceVariant,
);
```

`_navigationBarTheme`: seleccionado usa `nero.deepIris` (morado oscuro) en lugar de `carbon`. El pill `mistViolet` queda igual, pero el contraste icono-sobre-pill se restaura.

`_chipTheme`: `selectedColor` ahora es brightness-aware:
- Light: `mistViolet` (lavanda claro).
- Dark: `lavenderGlow` (morado medio) — más oscuro que `mistViolet` para que el texto `slate` (gris claro en dark) sea legible.

**`lib/screens/repo_tab.dart`**

El chip inline en `_RepoFilterChip` replica la misma lógica: `selectedColor` = `lavenderGlow` en dark.

### Por qué funciona

- `scheme.primary` en dark mode ahora es `#B99AFF` (lavenderGlow) — un morado brillante que da contraste AA sobre `darkPaper #1E1A24` y sobre `darkSurface #221E26`.
- El icono seleccionado del nav ahora es `deepIris #26114A` (morado oscuro) sobre pill `mistViolet #EDECFF` (lavanda claro) — el mismo contraste que en light mode.
- El chip "All" seleccionado en Repo usa `lavenderGlow` de fondo con texto `slate #B8B5C2` (gris claro en dark) — suficiente contraste.

### Verificación

- Settings page: "Appearance", "Local Library", "Extensions", "Download", etc. → todos visibles en morado claro.
- Appearance page: "Brand color", "App Language", "History View" → visibles.
- Extension Repo: "Spotify Web", "Amazon Music", etc. → blancos; chips "All" / "Metadata" / "Download" → visibles.
- NavigationBar: pill seleccionado con icono morado oscuro y label morado oscuro → alto contraste.
- Light mode sin regresiones: `scheme.primary` queda igual (M3 derivado del seed), `selectedColor` chip usa `mistViolet`, nav usa `deepIris`.

### Pendiente

- Algunos componentes heredados (snackbar, dialog buttons específicos) podrían revisarse si muestran colores que asumen light. No bloqueante.

---

## 20. SettingsItem title contrast fix (sesión 2026-06-24)

Después del fix 19, las titles de la Settings page (`Appearance`, `Local Library`, `Extensions`, etc.) seguían mostrándose en morado oscuro sobre `darkPaper`. Causa: `SettingsItem` y `SettingsSwitchItem` en `lib/widgets/settings_group.dart` usan `color: nero.deepIris` directamente para el texto del título, ignorando el override de `scheme.primary`.

### Cambios

**`lib/widgets/settings_group.dart`**
- `SettingsItem.build` y `SettingsSwitchItem.build` → `color: enabled ? nero.carbon : nero.smoke` (era `nero.deepIris`).
- `carbon` ya es brightness-aware (`#E4E1EE` en dark, `#222222` en light), así que el título queda blanco/claro en dark y negro en light sin tocar `scheme.primary`.

**`lib/widgets/empty_state.dart`**
- Título del empty state → `color: nero.carbon` (era `deepIris`).

**`lib/widgets/nero/nero_button.dart`**
- `NeroButtonVariant.ghost` → foreground y border son dark-aware:
  - Light: `nero.deepIris` (morado oscuro sobre fondo claro).
  - Dark: `nero.lavenderGlow` (morado claro sobre fondo oscuro).

**`lib/screens/repo_tab.dart`**
- Icono del chip filter (`_RepoFilterChip`) → `color: Theme.brightness == dark ? lavenderGlow : deepIris`.

### Por qué este fix importa

El fix 19 (override `scheme.primary = lavenderGlow` en dark) afectaba solo a los textos que usaban `Theme.of(context).colorScheme.primary`. Los widgets que usaban tokens de `NeroTheme` directamente (`deepIris`) seguían con morado oscuro fijo. La regla a futuro: usar `scheme.primary` o un token dark-aware (`carbon`, `darkOnSurface`) para texto, nunca `deepIris` directo en componentes renderizados.

### Verificación

- Settings page: "Appearance", "Local Library", "Extensions", "Download", "Files & Folders", "Metadata", "Lyrics", "Storage & Cache", "App" → todos visibles en blanco/gris claro sobre `darkPaper`.
- Subtítulos (slate) y divisores (darkOutline) consistentes.
- Empty states: título blanco en dark.
- 31/31 tests pasan.

---

## 21. Rename NeroFlac → SiwöFlac (sesión 2026-06-24)

Rebrand del nombre de la app en todos los lugares visibles:

### Cambios

- **`lib/l10n/arb/*.arb`** (19 archivos): `NeroFlac` → `SiwöFlac` en strings de UI (`appName`, mensajes, tutorial, about, storage, notifications, extension URLs, etc.).
- **`lib/l10n/app_localizations_*.dart`** regenerados vía `flutter gen-l10n`.
- **`lib/app.dart`, `lib/main.dart`**: `NeroFlacApp` (clase) → `SiwoFlacApp` (sin diacrítico, Dart no admite `ö` en identifiers — el nombre visible sigue siendo "SiwöFlac").
- **`android/app/src/main/AndroidManifest.xml`**: `android:label="NeroFlac"` → `android:label="SiwöFlac"`.
- **`android/app/src/main/res/drawable/launch_background.xml`**: comentarios actualizados.
- **`pubspec.yaml`**: descripción actualizada.
- **`CHANGES.md`**: 34 referencias históricas actualizadas.

### No tocado (intencional)

- `applicationId` Android: `com.kokeeu.neroflac` — cambiarlo invalida instalaciones existentes.
- OAuth scheme `spotiflac://` — usado por integraciones externas.
- File extension `.spotiflac-ext` — formato de extensiones.
- iOS bundle id / User-Agent header del backend Go.

### Verificación

- APK reconstruido sin errores (build con identificadores ASCII válidos).
- Hero pill muestra `● SiwöFlac` con diacrítico correcto.

---

## 22. Nav bar color consistency (sesión 2026-06-24)

En light mode, el `NavigationBar` mostraba un tinte rosa-lavanda porque `NeroSurface` usaba `scheme.surface` (M3-derived desde `#26114A` = blanco ligeramente violeta), creando una inconsistencia con las cards blancas y el fondo de página.

### Cambios

**`lib/theme/app_theme.dart`** — `light()` factory ahora overridea `scheme.surface` igual que `dark()`:

```dart
scheme = scheme.copyWith(
  surface: nero.canvas,                              // blanco puro
  surfaceContainerLowest: nero.canvas,
  surfaceContainerLow: nero.paper,
  surfaceContainer: nero.paper,
  surfaceContainerHigh: nero.paper,
  surfaceContainerHighest: nero.paper,
  outline: nero.mist,
  outlineVariant: nero.mist,
);
```

Esto elimina el tinte M3-derived para que:
- `NeroSurface` (que usa `scheme.surface`) renderice blanco puro en light, igual que las cards.
- `NavigationBar` herede un fondo consistente con el resto de la superficie.

### Verificación

- Settings page (light): nav bar blanco/gris claro, sin tinte rosa; cards y nav comparten tono.
- Settings page (dark): sin regresiones — sigue oscuro con cards y nav consistentes.
- 31/31 tests pasan.

---

## 23. Nav bar uniform fill (sesión 2026-06-24)

El fix 22 dejó el `NeroSurface` del nav en blanco (`scheme.surface = canvas`) mientras que el `NavigationBar` interior usaba `paper` (`#F6F7FA`), creando dos colores visibles en light mode. El usuario pidió uniformar el relleno manteniendo el borde y el "iris" (shadowLg violeta sobre el borde superior).

### Cambios

**`lib/screens/main_shell.dart`**

1. Import añadido:
```dart
import 'package:neroflac/theme/nero_theme_extension.dart';
```

2. `NeroTheme.of(context)` declarado al inicio del build method:
```dart
Widget build(BuildContext context) {
  final nero = NeroTheme.of(context);
  ...
}
```

3. El `bottomNavigationBar` ahora pasa `color: nero.paper` explícito al `NeroSurface`:
```dart
bottomNavigationBar: NeroSurface(
  color: nero.paper,                              // ← wrapper = NavigationBar bg
  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
  elevation: NeroSurfaceElevation.lg,             // ← shadowLg preserva iris glow
  child: NavigationBar(
    ...
    destinations: destinations,
  ),
),
```

### Por qué funciona

- `paper` en light = `#F6F7FA` (gris cálido)
- `paper` en dark = `darkCanvas` (`#14121A`)
- El `NavigationBar` theme ya tenía `backgroundColor: nero.paper` desde fix 18
- Ahora wrapper y contenido son **idénticos en ambos modos** → relleno uniforme
- `shadowLg` con tinte `#0E3B65` alpha 0x52 sigue proyectando el iris violeta sobre el borde superior
- `Border.all(color: nero.mist)` y `borderRadius` quedan intactos

### Verificación

- Settings page (light): nav uniformemente `#F6F7FA` con iris glow violeta arriba, hairline border, top corners 16px. Iconos y labels correctamente posicionados.
- Settings page (dark): nav uniformemente `darkCanvas`, iris glow visible, sin regresiones.
- 31/31 tests pasan.


---

## 24. Prisma + Liquid Glass redesign (sesión 2026-06-24)

Rediseño total de la estética siguiendo el sistema visual de Prisma (https://prisma.io) con chrome Liquid Glass inspirado en iOS 26. El sistema Wiza anterior (lavanda/violeta con glassmorphism eliminado) se reemplazó por un lenguaje de ingeniero: paleta monocromática con acento teal, tipografía Mona Sans, hairline borders, y chrome frosted glass sobre gradient page bg.

### Decisiones de scope

- **Tema**: light only. Se eliminó dark mode, AMOLED, system mode, y dynamic color (Material You).
- **Brand name**: "SiwöFlac" (mantiene el diacrítico). Sin text pill — la marca visual es el icono Xianyun.
- **Naming tokens**: `NeroTheme` se conserva como class name; solo cambian los valores a Prisma + glass.
- **Glass**: chrome surfaces (AppBar, bottom nav) y cards/pills/inputs usan Liquid Glass con `BackdropFilter` blur 28px. Phase 3 subagents migrarán screens específicas.
- **App icon**: Xianyun Spotify Icon reemplaza el bird asset previo en launcher, splash y Home pill.

### Cambios principales

**`pubspec.yaml`**
- + Mona Sans VF, Mona Sans Mono VF (GitHub SIL OFL 1.1), JetBrains Mono.
- - `dynamic_color: ^1.7.0` (eliminado).
- `flutter_launcher_icons` reconfigurado: `assets/icon/icon.png`, adaptive bg `#0D9488`, foreground + monochrome generados desde script Python.

**`lib/theme/nero_theme_extension.dart`** (reescrito)
- 10 colores Prisma: `prismTeal`, `deepTeal`, `carbonInk`, `graphite`, `slate`, `steel`, `fog`, `mist`, `bone`, `paper`.
- Spacing scale: 4/8/12/16/24/32/40/48/104.
- Radii: `radiusMd 6`, `radiusLg 10`, `radius2xl 16`, `radiusSearch 16`.
- Shadow único: `shadowSubtle` = `rgba(0,0,0,0.04) 0 1px 2px`.
- Gradient: `gradientPageBg` vertical `#0D9488` → `#6BD4C5`.
- Glass tokens: `glassBlur 28`, `glassChrome prismTeal@30%`, `glassCard white@18%`, `glassPill white@25%`, `glassInput white@15%`, borders subtle/highlight.
- Deprecated aliases (`canvas`, `carbon`, `deepIris`, `royalAmethyst`, `mistViolet`, `radiusCards`, `radiusPill`, `shadowSm`, etc.) se mantienen como getters para que las screens compilen durante Phase 3.

**`lib/theme/app_theme.dart`** (reescrito)
- Solo `light()` factory. `dark()` eliminado.
- `scaffoldBackgroundColor: Colors.transparent` — deja ver el gradient bg del `DecoratedBox` wrapping en main_shell.
- `cardTheme` reemplazado por `cardThemeData` (API Flutter 3.44).
- TextTheme reescrito con Prisma type scale: display 64px 900, headline 30px 650, body 16px 400, etc.

**`lib/theme/dynamic_color_wrapper.dart`** — stub no-op. Material You eliminado.

**`lib/widgets/liquid_glass_surface.dart`** (NUEVO)
- `GlassVariant { chrome, card, pill, input }` con tint + blur + radius tuned por contexto.
- Top hairline highlight (1px white@40%) + body subtle border (white@20%) para efecto glass realista.

**`lib/widgets/show_helpers.dart`** (NUEVO)
- Stubs `showNeroDialog` y `showNeroSheet` reemplazando funciones eliminadas de `animation_utils`.

**`lib/widgets/settings_group.dart`** (reescrito)
- `SettingsGroup` ahora envuelve su contenido en `LiquidGlassSurface(card)` — cards glass sobre gradient.

**`lib/widgets/nero/`** (reducido)
- `NeroButton`: solo `filled` y `ghost`. `pill` eliminado. Filled = Prism Teal sólido, ghost = paper + hairline mist.
- `NeroTag`: ahora usa `LiquidGlassSurface(pill)` internamente.
- `NeroSurface`, `NeroAppBar`: stubs que envuelven contenido en LiquidGlassSurface.
- `NeroShow`: eliminado (reemplazado por stubs no-op).

**`lib/screens/main_shell.dart`**
- `Scaffold` envuelto en `DecoratedBox(decoration: BoxDecoration(gradient: nero.gradientPageBg))` — gradient global.
- `bottomNavigationBar` reemplazado por `LiquidGlassSurface(variant: chrome, borderRadius: top 20px, height: 80)`.

**`lib/screens/home_tab.dart`**
- Pill `● SiwöFlac` → `Image.asset('assets/icon/icon.png', 32×32)` con paper bg + radius 10 + shadowSubtle.
- Texto "SpotiFLAC Mobile" → "SiwöFlac" + Image del icono en el hero.

**`lib/screens/settings/appearance_settings_page.dart`**
- `_ThemeModeSelector` neutralizado: solo `ThemeMode.light`, onChanged no-op (Phase 3 rediseña con brand color picker).

**`assets/icon/`** (NUEVO)
- `icon.png` 1080×1080 (icono principal con fondo teal).
- `icon_foreground.png` 432×432 (centro, edge-feathered).
- `icon_monochrome.png` 432×432 silueta blanca para themed icons Android 13+.

**Android assets**
- `mipmap-{mdpi,hdpi,xhdpi,xxhdpi,xxxhdpi}/ic_launcher.png` regenerados vía `flutter_launcher_icons`.
- `drawable-{density}/ic_launcher_foreground.png` y `ic_launcher_monochrome.png` regenerados.
- `mipmap-anydpi-v26/ic_launcher.xml`: adaptive icon con background `#0D9488`.
- `drawable/launch_background.xml` + `drawable-v21/launch_background.xml`: gradient Deep Teal → light teal (ya no negro/lavanda).
- `colors.xml`: `ic_launcher_background` actualizado a `#0D9488`.

### Verificación

- Build APK debug OK, sin errores.
- 31/31 tests pasan (ThemeSettings test actualizado).
- Launcher icon: Xianyun bird con fondo teal visible.
- Splash: gradient Deep Teal con Xianyun centrado.
- Home tab: gradient page bg visible, Xianyun brand mark en pill, search bar glass, bottom nav glass con Prism Teal tint.
- Repo tab: glass cards con contenido visible a través, filter chips glass, version pills glass, "Instalada" badges glass, install buttons Prism Teal sólido. EXACTO a la referencia del usuario.

### Pendiente Phase 3 (subagents paralelos)

Las screens individuales todavía usan tokens deprecated (`mistViolet`, `royalAmethyst`, `radiusPill`, etc.) vía los getters alias. Phase 3 disparará 6 subagents paralelos para migrar:
- **Agent A** — Library (3 screens)
- **Agent B** — Player (3 screens)
- **Agent C** — Queue + Track metadata (2 screens)
- **Agent D** — Repo (2 screens)
- **Agent E** — Settings (15 sub-screens)
- **Agent F** — Onboarding + utilities (5 screens)

Cada agent reemplaza tokens deprecated con Prisma tokens, elimina gradients antiguos, ajusta spacing a la escala 4px.


### 24.1 Gradient + Glass AppBar + Xianyun en todas las screens

Fixes de los 3 issues reportados después del primer redesign:

**Issue 1: Gradient solo se veía en parte de la pantalla**
- `lib/main.dart`: `SystemChrome.setSystemUIOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark)`.
- `lib/screens/main_shell.dart`: `Scaffold(extendBodyBehindAppBar: true)`.
- Status bar transparente con iconos dark sobre teal claro arriba.

**Issue 2: "Pajaro Nero" aún aparecía en Home empty state**
- `lib/screens/home_tab.dart:1667`: `'assets/images/logo-transparent.png'` → `ClipRRect` + `'assets/icon/icon.png'`.
- `lib/screens/home_tab.dart:1627`: `Icons.extension_outlined` (que parecía puzzle/bird) → `'assets/icon/icon.png'` 80×80.
- `lib/widgets/empty_state.dart`: `Icon(icon, color: prismTeal)` → `Image.asset('assets/icon/icon.png')` en glass pill.
- `lib/widgets/error_state.dart`: mismo tratamiento.
- `lib/screens/settings/about_page.dart:306, :311`: ambas refs a `logo-transparent.png`/`logo.png` → `icon.png`.
- `lib/screens/setup_screen.dart:687`: `logo-transparent.png` → `icon.png`.

**Issue 3: Top blanco tapando el gradient**
- `lib/screens/home_tab.dart:1307`: `SliverAppBar.backgroundColor: nero.paper` → `Colors.transparent`.
- `lib/widgets/nero/nero_appbar.dart`: stub `NeroSliverAppBar` simplificado (pass-through). El gradient ahora fluye detrás del AppBar sin paint opaco.

**Cleanup**
- `assets/images/logo.png` → `logo.png.deprecated`.
- `assets/images/logo-transparent.png` → `logo-transparent.png.deprecated`.
- `assets/images/logo.png.bak`, `logo-transparent.png.bak` eliminados.

### Verificación

- Build APK debug OK.
- Home: gradient full-screen, status bar transparente con iconos dark, "Home" title visible sobre teal, Xianyun icon en empty state.
- Bottom nav: glass chrome con tint Prism Teal, seleccionado con icono carbonInk.
- Splash: gradient Deep Teal con Xianyun bird centrado.
