import 'dart:async';
import 'package:neroflac/models/track.dart';
import 'package:neroflac/services/platform_bridge.dart';
import 'package:neroflac/services/youtube_playlist_extractor.dart';
import 'package:neroflac/utils/logger.dart';

final _log = AppLogger('BatchSearchService');

/// One result of a batch search: the original extracted song and the best
/// match found on the chosen provider (or `null` if nothing matched).
class MatchedSong {
  final ExtractedSong extracted;
  final Track? matched;
  final MatchConfidence confidence;

  const MatchedSong({
    required this.extracted,
    required this.matched,
    required this.confidence,
  });

  bool get isMatched => matched != null;
}

enum MatchConfidence { exact, approximate, none }

class BatchSearchService {
  /// How many parallel search requests to run.
  final int concurrency;

  BatchSearchService({this.concurrency = 3});

  /// Searches [songs] on [providerId] (e.g. "tidal", "apple-music") and
  /// streams results as they come in.
  ///
  /// `onProgress(done, total)` is called after each result is ready.
  Stream<MatchedSong> searchAll({
    required List<ExtractedSong> songs,
    required String providerId,
    void Function(int done, int total)? onProgress,
  }) async* {
    if (songs.isEmpty) return;

    final queue = List<ExtractedSong>.from(songs);
    final inFlight = <Future<MatchedSong>>[];
    var done = 0;

    // Simple worker pool: spin up to `concurrency` futures at a time.
    while (queue.isNotEmpty || inFlight.isNotEmpty) {
      while (inFlight.length < concurrency && queue.isNotEmpty) {
        final song = queue.removeAt(0);
        inFlight.add(_searchOne(song, providerId));
      }
      if (inFlight.isEmpty) break;
      final completed = await Future.any(
        inFlight.map((f) => f.then((r) => _Tagged(r, inFlight.indexOf(f)))),
      );
      inFlight.removeAt(completed.tag);
      done++;
      onProgress?.call(done, songs.length);
      yield completed.result;
    }
  }

  Future<MatchedSong> _searchOne(ExtractedSong song, String providerId) async {
    try {
      final query = song.searchQuery;
      final results = await PlatformBridge.customSearchWithExtension(
        providerId,
        query,
        options: const {'filter': 'track'},
      );

      if (results.isEmpty) {
        return MatchedSong(
          extracted: song,
          matched: null,
          confidence: MatchConfidence.none,
        );
      }

      // Parse all results, score them, pick the best.
      final scored = <(Track, double)>[];
      for (final data in results) {
        final track = _parseTrack(data, providerId);
        if (track.id.isEmpty) continue;
        final score = _score(track, song);
        scored.add((track, score));
      }
      if (scored.isEmpty) {
        return MatchedSong(
          extracted: song,
          matched: null,
          confidence: MatchConfidence.none,
        );
      }
      scored.sort((a, b) => b.$2.compareTo(a.$2));
      final best = scored.first;
      final confidence = best.$2 >= 0.7
          ? MatchConfidence.exact
          : MatchConfidence.approximate;

      return MatchedSong(
        extracted: song,
        matched: best.$1,
        confidence: confidence,
      );
    } catch (e, st) {
      _log.e('Search failed for "$song": $e', e, st);
      return MatchedSong(
        extracted: song,
        matched: null,
        confidence: MatchConfidence.none,
      );
    }
  }

  /// Lightweight track parser — replicates `_parseSearchTrack` from
  /// TrackProvider without the stateful overhead.
  Track _parseTrack(Map<String, dynamic> data, String providerId) {
    final durationMs = _extractDurationMs(data);
    return Track(
      id: (data['id'] ?? '').toString(),
      name: (data['name'] ?? '').toString(),
      artistName: (data['artists'] ?? data['artist'] ?? '').toString(),
      albumName: (data['album_name'] ?? data['album'] ?? '').toString(),
      artistId: (data['artist_id'] ?? data['artistId'])?.toString(),
      albumId: data['album_id']?.toString(),
      coverUrl: (data['cover_url'] ?? data['images'])?.toString(),
      isrc: data['isrc']?.toString(),
      duration: (durationMs / 1000).round(),
      trackNumber: data['track_number'] as int?,
      releaseDate: data['release_date']?.toString(),
      totalTracks: data['total_tracks'] as int?,
      source: providerId,
    );
  }

  int _extractDurationMs(Map<String, dynamic> data) {
    final ms = data['duration_ms'];
    if (ms is num) return ms.toInt();
    if (ms is String) return int.tryParse(ms) ?? 0;
    final s = data['duration'];
    if (s is num) return (s * 1000).toInt();
    if (s is String) return (double.tryParse(s) ?? 0) ~/ 1 * 1000;
    return 0;
  }

  /// Returns a score in 0..1 representing how well [track] matches [extracted].
  /// Weights: title (0.6) + artist (0.4).
  double _score(Track track, ExtractedSong extracted) {
    final t = _normalize(track.name);
    final a = _normalize(track.artistName);
    final titleScore = _similarity(t, _normalize(extracted.title));
    final artistScore = extracted.artist.isEmpty
        ? 0.5
        : _similarity(a, _normalize(extracted.artist));
    return titleScore * 0.6 + artistScore * 0.4;
  }

  String _normalize(String s) {
    return s
        .toLowerCase()
        .replaceAll(RegExp(r'\([^)]*\)'), ' ') // strip "(Official Video)"
        .replaceAll(RegExp(r'\[[^]]*\]'), ' ') // strip "[Lyrics]"
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Jaccard similarity over word tokens (fast and forgiving enough for
  /// music titles like "Song" vs "Song - Remastered").
  double _similarity(String a, String b) {
    if (a.isEmpty && b.isEmpty) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;
    final wa = a.split(' ').toSet();
    final wb = b.split(' ').toSet();
    final intersect = wa.intersection(wb).length;
    final union = wa.union(wb).length;
    return union == 0 ? 0.0 : intersect / union;
  }
}

class _Tagged {
  final MatchedSong result;
  final int tag;
  const _Tagged(this.result, this.tag);
}
