# SiwöFlac v4.7.0

## 🎵 Importar listas de YouTube Music

Pega una URL de YouTube Music y descarga todas las canciones en lote usando cualquier extensión habilitada como proveedor de búsqueda (Spotify Web, etc.).

### Flujo

1. Toca el icono `+` (playlist_add) en la barra de búsqueda del inicio
2. Pega la URL de YouTube Music
3. Selecciona el proveedor de búsqueda
4. Toca "Buscar coincidencias"
5. Revisa los resultados (✅ exactas, ⚠️ aproximadas, ❌ sin coincidencia)
6. Toca "Descargar" → elige calidad y servicio
7. Las canciones se añaden a la cola para descarga

### Características

- Extracción automática: usa la extensión de YouTube Music si está instalada, fallback con `youtube_explode_dart`
- Búsqueda concurrente (3 workers en paralelo) para velocidad
- Score de coincidencia (Jaccard) para clasificar resultados
- Selector de calidad/servicio (LOSSLESS, HI_RES, etc.) antes de encolar
- Interfaz completamente en español

### Requisitos

- Tener al menos una extensión con búsqueda personalizada habilitada (Spotify Web, etc.)
- Opcional: extensión de YouTube Music para extracción fiable

---

## 🔧 Otros cambios

- Bump de versión a `4.7.0+136`
- APKs firmados con certificado de release
- Rediseño Prisma + Liquid Glass (gradient teal + glass chrome surfaces)

## 📦 Instalación

Descarga el APK que coincida con tu dispositivo:

- **`SiwöFlac-4.7.0-arm64.apk`** — la mayoría de dispositivos modernos
- **`SiwöFlac-4.7.0-universal.apk`** — universal, todas las arquitecturas

---

**SiwöFlac** — Download music in true lossless FLAC from extension-provided sources.