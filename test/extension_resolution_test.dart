import 'package:flutter_test/flutter_test.dart';
import 'package:neroflac/providers/extension_provider.dart';

Extension _buildExtension({
  required String id,
  String displayName = '',
  bool enabled = true,
  bool hasMetadataProvider = false,
  bool hasDownloadProvider = false,
  List<String> replacesBuiltInProviders = const [],
  Map<String, dynamic> capabilities = const {},
}) {
  return Extension(
    id: id,
    name: id,
    displayName: displayName.isEmpty ? id : displayName,
    version: '1.0.0',
    description: '',
    enabled: enabled,
    status: 'loaded',
    hasMetadataProvider: hasMetadataProvider,
    hasDownloadProvider: hasDownloadProvider,
    capabilities: {
      ...capabilities,
      if (replacesBuiltInProviders.isNotEmpty)
        'replacesBuiltInProviders': replacesBuiltInProviders,
    },
  );
}

ExtensionState _buildState(List<Extension> extensions) {
  return ExtensionState(extensions: extensions);
}

void main() {
  group('resolveEffectiveDownloadService', () {
    test(
      'returns the dedicated extension when both YTMusic replacement and Tidal '
      'dedicated are installed and "tidal" is requested',
      () {
        final ytmusic = _buildExtension(
          id: 'ytmusic-spotiflac',
          displayName: 'YouTube Music',
          hasDownloadProvider: true,
          replacesBuiltInProviders: const ['tidal', 'youtube', 'qobuz', 'deezer'],
        );
        final tidal = _buildExtension(
          id: 'tidal-spotiflac',
          displayName: 'Tidal',
          hasDownloadProvider: true,
        );
        final state = _buildState([ytmusic, tidal]);

        expect(
          resolveEffectiveDownloadService('tidal', state),
          equals('tidal-spotiflac'),
        );
      },
    );

    test(
      'returns the YTMusic replacement when only YTMusic is installed and '
      '"tidal" is requested',
      () {
        final ytmusic = _buildExtension(
          id: 'ytmusic-spotiflac',
          displayName: 'YouTube Music',
          hasDownloadProvider: true,
          replacesBuiltInProviders: const ['tidal', 'youtube'],
        );
        final state = _buildState([ytmusic]);

        expect(
          resolveEffectiveDownloadService('tidal', state),
          equals('ytmusic-spotiflac'),
        );
      },
    );

    test(
      'returns the matching extension by exact id when it matches',
      () {
        final tidal = _buildExtension(
          id: 'tidal-spotiflac',
          displayName: 'Tidal',
          hasDownloadProvider: true,
        );
        final state = _buildState([tidal]);

        expect(
          resolveEffectiveDownloadService('tidal-spotiflac', state),
          equals('tidal-spotiflac'),
        );
      },
    );

    test(
      'falls back to the first enabled download extension when the request '
      'matches nothing',
      () {
        final qobuz = _buildExtension(
          id: 'qobuz-spotiflac',
          displayName: 'Qobuz',
          hasDownloadProvider: true,
        );
        final state = _buildState([qobuz]);

        expect(
          resolveEffectiveDownloadService('spotify', state),
          equals('qobuz-spotiflac'),
        );
      },
    );

    test(
      'treats an extension with replacesBuiltInProviders containing the slug '
      'as NOT dedicated (so YTMusic does not hijack a Tidal request)',
      () {
        final ytmusic = _buildExtension(
          id: 'some-random-extension',
          displayName: 'YouTube Music',
          hasDownloadProvider: true,
          replacesBuiltInProviders: const ['tidal'],
        );
        final tidal = _buildExtension(
          id: 'tidal-real',
          displayName: 'Tidal',
          hasDownloadProvider: true,
        );
        final state = _buildState([ytmusic, tidal]);

        expect(
          resolveEffectiveDownloadService('tidal', state),
          equals('tidal-real'),
        );
      },
    );

    test(
      'returns empty string when no download extensions are enabled',
      () {
        final state = _buildState(const []);
        expect(
          resolveEffectiveDownloadService('tidal', state),
          equals(''),
        );
      },
    );
  });

  group('resolveEffectiveMetadataProvider', () {
    test(
      'returns the dedicated extension when YTMusic replacement and Tidal '
      'dedicated are both installed and "tidal" is requested',
      () {
        final ytmusic = _buildExtension(
          id: 'ytmusic-spotiflac',
          displayName: 'YouTube Music',
          hasMetadataProvider: true,
          replacesBuiltInProviders: const ['tidal'],
        );
        final tidal = _buildExtension(
          id: 'tidal-spotiflac',
          displayName: 'Tidal',
          hasMetadataProvider: true,
        );
        final state = _buildState([ytmusic, tidal]);

        expect(
          resolveEffectiveMetadataProvider('tidal', state),
          equals('tidal-spotiflac'),
        );
      },
    );

    test(
      'still allows the YTMusic replacement when no dedicated extension '
      'is installed',
      () {
        final ytmusic = _buildExtension(
          id: 'ytmusic-spotiflac',
          displayName: 'YouTube Music',
          hasMetadataProvider: true,
          replacesBuiltInProviders: const ['tidal'],
        );
        final state = _buildState([ytmusic]);

        expect(
          resolveEffectiveMetadataProvider('tidal', state),
          equals('ytmusic-spotiflac'),
        );
      },
    );
  });
}