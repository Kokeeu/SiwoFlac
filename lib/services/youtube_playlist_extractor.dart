import 'dart:async';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:neroflac/services/platform_bridge.dart';
import 'package:neroflac/utils/logger.dart';

final _log = AppLogger('YTPlaylistExtractor');

/// One song extracted from a YouTube Music playlist.
class ExtractedSong {
  final String artist;
  final String title;

  /// 0-based index in the playlist (for ordering and feedback).
  final int index;

  const ExtractedSong({
    required this.artist,
    required this.title,
    required this.index,
  });

  /// Human-readable search query (artist + title).
  String get searchQuery => '$artist - $title';

  @override
  String toString() => '$searchQuery (#${index + 1})';
}

class YouTubePlaylistExtractor {
  /// Recognised URL patterns. We accept:
  ///   * music.youtube.com/playlist?list=...
  ///   * music.youtube.com/browse/VLPL...   (an "old-style" YT Music URL)
  ///   * youtu.be/`<id>` (single video — not a playlist, will return `[]`)
  static final RegExp _playlistPattern = RegExp(
    r'^https?://(?:music\.)?youtube\.com/playlist\?list=([A-Za-z0-9_-]+)',
    caseSensitive: false,
  );
  static final RegExp _browsePattern = RegExp(
    r'^https?://music\.youtube\.com/browse/(?:VL)?(PL[A-Za-z0-9_-]+)',
    caseSensitive: false,
  );

  /// Returns true if the [url] looks like a YouTube / YT Music playlist.
  static bool isPlaylistUrl(String url) {
    return _playlistPattern.hasMatch(url) || _browsePattern.hasMatch(url);
  }

  /// Extracts the playlist id from a YouTube Music URL, or null if not matched.
  static String? extractPlaylistId(String url) {
    final playlistMatch = _playlistPattern.firstMatch(url);
    if (playlistMatch != null) return playlistMatch.group(1);
    final browseMatch = _browsePattern.firstMatch(url);
    if (browseMatch != null) return 'VL${browseMatch.group(1)}';
    return null;
  }

  /// Extracts the song list from a YouTube / YT Music playlist URL.
  ///
  /// Strategy:
  ///   1. Try the existing extension system via `PlatformBridge.handleURLWithExtension`.
  ///      If the YouTube Music extension is installed, it will fetch the playlist
  ///      and return tracks with artist/title metadata.
  ///   2. Fall back to `youtube_explode_dart` to scrape the playlist page directly.
  ///      For each video, we prefer the structured `musicData` (artist + song name)
  ///      and fall back to title parsing.
  ///
  /// Throws if the URL is invalid or the playlist can't be fetched.
  Future<List<ExtractedSong>> extract(String url) async {
    if (!isPlaylistUrl(url)) {
      throw const FormatException('URL is not a recognised YouTube Music playlist');
    }
    _log.i('Extracting playlist: $url');

    // Strategy 1: extension system.
    try {
      final songs = await _extractViaExtension(url);
      if (songs.isNotEmpty) {
        _log.i('Extension returned ${songs.length} songs');
        return songs;
      }
    } catch (e) {
      _log.w('Extension extraction failed: $e');
    }

    // Strategy 2: youtube_explode_dart fallback.
    return _extractViaYoutubeExplode(url);
  }

  Future<List<ExtractedSong>> _extractViaExtension(String url) async {
    final result = await PlatformBridge.handleURLWithExtension(url);
    if (result == null) return const [];
    // The handler returns a map like:
    //   { 'type': 'playlist', 'name': '...', 'description': '...',
    //     'tracks': [{'name': '...', 'artists': '...', 'duration': ..., ...}] }
    final type = (result['type'] ?? '').toString();
    if (type != 'playlist' && type != 'album') {
      _log.w('Extension returned non-playlist type: $type');
      return const [];
    }
    final rawTracks = result['tracks'];
    if (rawTracks is! List) return const [];

    final songs = <ExtractedSong>[];
    for (var i = 0; i < rawTracks.length; i++) {
      final t = rawTracks[i];
      if (t is! Map) continue;
      final name = (t['name'] ?? '').toString().trim();
      if (name.isEmpty) continue;
      final artists = (t['artists'] ?? t['artist'] ?? '').toString().trim();
      songs.add(ExtractedSong(artist: artists, title: name, index: i));
    }
    return songs;
  }

  Future<List<ExtractedSong>> _extractViaYoutubeExplode(String url) async {
    final id = extractPlaylistId(url)!;
    _log.i('Falling back to youtube_explode_dart for $id');

    final yt = YoutubeExplode();
    try {
      final playlist = await yt.playlists.get(id);
      _log.i('Got playlist "${playlist.title}" (${playlist.videoCount ?? '?'} videos)');

      final songs = <ExtractedSong>[];
      var index = 0;
      await for (final video in yt.playlists.getVideos(id)) {
        if (video.musicData.isNotEmpty) {
          for (final md in video.musicData) {
            final artist = (md.artist ?? '').trim();
            final song = (md.song ?? '').trim();
            if (song.isNotEmpty) {
              songs.add(ExtractedSong(
                artist: artist,
                title: song,
                index: index++,
              ));
            }
          }
        } else {
          final parsed = _parseTitle(video.title, video.author);
          songs.add(ExtractedSong(
            artist: parsed.$1,
            title: parsed.$2,
            index: index++,
          ));
        }
      }
      _log.i('Extracted ${songs.length} songs');
      return songs;
    } catch (e, st) {
      _log.e('Failed to extract playlist', e, st);
      rethrow;
    } finally {
      yt.close();
    }
  }

  /// Tries to split a YouTube video title into (artist, title).
  (String, String) _parseTitle(String videoTitle, String channelAuthor) {
    final title = videoTitle.trim();
    final author = channelAuthor.trim();

    for (final sep in const [' - ', ' – ', ' — ', ' | ', ' • ']) {
      if (title.contains(sep)) {
        final parts = title.split(sep);
        if (parts.length >= 2) {
          final first = parts[0].trim();
          final second = parts.sublist(1).join(sep).trim();
          if (first.isNotEmpty && second.isNotEmpty) {
            return (first, second);
          }
        }
      }
    }
    return (author, title);
  }
}

