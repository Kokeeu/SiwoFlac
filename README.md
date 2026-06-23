<div align="center">

# NeroFlac

**Mobile music utility built with Flutter and Go.**  
High-quality audio management for your personal library.  
Open source, no ads, no subscription.

> Fork personalizado de [SpotiFLAC Mobile](https://github.com/zarzet/SpotiFLAC-Mobile) por [Kokeeu](https://github.com/Kokeeu).

</div>

---

## Sobre este fork

NeroFlac es un fork no oficial de **SpotiFLAC Mobile** (mantenido originalmente por [@zarzet](https://github.com/zarzet)). Todo el crédito por el diseño, la arquitectura y la implementación original va al equipo de SpotiFLAC. Este fork solo cambia:

- Identidad de la app (nombre, package, label, ícono, color seed)
- Repositorio por defecto de extensiones
- Metadatos del autor (`Kokeeu` en lugar de `zarzet`)

**El código fuente, la lógica de descarga, el sistema de extensiones, los providers de letras y la integración con FFmpeg permanecen intactos y son功劳 del proyecto original.**

## Diferencias con upstream

| | SpotiFLAC Mobile | NeroFlac |
|---|---|---|
| App name | SpotiFLAC Mobile | NeroFlac |
| Package | `com.zarz.spotiflac` | `com.kokeeu.neroflac` |
| Author | zarzet | Kokeeu |
| Default extension repo | api.zarz.moe | `spotiflacapp/SpotiFLAC-Extension` |
| Seed color | Spotify green (`#1DB954`) | Violet (`#7C3AED`) |
| Flutter version | 3.41.5 | 3.44.3 |

## Instalación

### Android
1. Descarga el APK desde la página de [Releases](https://github.com/Kokeeu/NeroFlac/releases)
2. Habilita "Instalar apps de orígenes desconocidos" en Ajustes
3. Instala el APK
4. Abre NeroFlac y concede permisos de almacenamiento cuando se soliciten

### Compilar desde el código fuente

Requisitos: **Flutter 3.44.3** (FVM recomendado), **Go 1.25+**, **Android SDK 36**, **NDK 29.0.14206865**, **Java 17**.

```bash
# Clonar
git clone https://github.com/Kokeeu/NeroFlac.git
cd NeroFlac

# Setup Flutter via FVM
fvm install && fvm use

# Backend Go -> AAR
cd go_backend
gomobile bind -target=android -androidapi 24 -o ../android/app/libs/gobackend.aar .
cd ..

# Dependencias y código generado
flutter pub get
dart run build_runner build

# Compilar APK debug
flutter build apk --debug
```

## Características (heredadas de SpotiFLAC)

- **Descarga en FLAC lossless** desde múltiples fuentes vía extensiones
- **Sistema de extensiones descentralizado** — la comunidad mantiene sus propios repositorios de extensiones
- **Metadata + letras** de Apple Music, LRCLib, Musixmatch, NetEase, Paxsenix, QQ Music, etc.
- **Múltiples calidades** (FLAC, MP3, etc.) y conversión con FFmpeg integrado
- **Dynamic color** + tema Material 3 Expressive + modo AMOLED
- **Multilenguaje** (vía Crowdin)

## Créditos

- **Autor original de SpotiFLAC Mobile**: [@zarzet](https://github.com/zarzet)  
- **SpotiFLAC Desktop original**: [@afkarxyz](https://github.com/afkarxyz)  
- **Este fork**: [@Kokeeu](https://github.com/Kokeeu)

### APIs externas utilizadas

| | | | | |
|---|---|---|---|---|
| [MusicDL](https://www.musicdl.me) | [LRCLib](https://lrclib.net) | [Paxsenix](https://lyrics.paxsenix.org) | [Cobalt](https://cobalt.tools) | [Song.link](https://song.link) |
| [IDHS](https://github.com/sjdonado/idonthavespotify) | | | | |

## Disclaimer

Este repositorio y su contenido se proporcionan estrictamente con fines educativos y de investigación. El software se proporciona "tal cual", sin garantía de ningún tipo, expresa o implícita, según se establece en la [Licencia MIT](LICENSE).

- **No** se aloja, almacena, refleja ni distribuye contenido con derechos de autor en este repositorio.
- Los usuarios deben asegurarse de que el uso que hagan de este software esté debidamente autorizado y cumpla con todas las leyes, regulaciones y términos de servicio de terceros aplicables.
- Si eres titular de derechos de autor o representante autorizado y crees que este repositorio infringe tus derechos, contacta al mantenedor con detalles suficientes (incluidas las URL pertinentes y prueba de propiedad). El asunto será investigado de inmediato y se tomarán las medidas apropiadas.

---

<div align="center">

**[Original repo](https://github.com/zarzet/SpotiFLAC-Mobile)** · **[Releases](https://github.com/Kokeeu/NeroFlac/releases)** · **[Reportar bug](../../issues)**

</div>
