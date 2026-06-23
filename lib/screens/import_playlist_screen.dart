import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neroflac/l10n/l10n.dart';
import 'package:neroflac/providers/download_queue_provider.dart';
import 'package:neroflac/providers/extension_provider.dart';
import 'package:neroflac/providers/settings_provider.dart';
import 'package:neroflac/services/batch_search_service.dart';
import 'package:neroflac/services/youtube_playlist_extractor.dart';
import 'package:neroflac/utils/logger.dart';
import 'package:neroflac/widgets/download_service_picker.dart';
import 'package:neroflac/widgets/glass/glass_appbar.dart';
import 'package:neroflac/widgets/glass/glass_sheet.dart';

final _log = AppLogger('ImportPlaylistScreen');

/// YouTube Music playlist import: paste URL → pick provider → bulk search →
/// review matches → download in one go.
class ImportPlaylistScreen extends ConsumerStatefulWidget {
  const ImportPlaylistScreen({super.key});

  @override
  ConsumerState<ImportPlaylistScreen> createState() =>
      _ImportPlaylistScreenState();
}

class _ImportPlaylistScreenState
    extends ConsumerState<ImportPlaylistScreen> {
  final _urlController = TextEditingController();
  final _extractor = YouTubePlaylistExtractor();
  final _searcher = BatchSearchService();

  _Phase _phase = _Phase.idle;
  String? _extractorError;
  String? _selectedProvider;
  int _progress = 0;
  int _total = 0;
  final List<MatchedSong> _results = [];

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final clip = await Clipboard.getData('text/plain');
    final text = clip?.text?.trim() ?? '';
    if (text.isNotEmpty) {
      _urlController.text = text;
      setState(() {});
    }
  }

  Future<void> _startImport() async {
    final l10n = context.l10n;
    final url = _urlController.text.trim();

    if (url.isEmpty) {
      showGlassDialog<void>(
        context: context,
        builder: (_) => _SimpleMessageDialog(
          title: l10n.importPlaylistErrorEmpty,
        ),
      );
      return;
    }
    if (!YouTubePlaylistExtractor.isPlaylistUrl(url)) {
      showGlassDialog<void>(
        context: context,
        builder: (_) => _SimpleMessageDialog(
          title: l10n.importPlaylistErrorNotPlaylist,
        ),
      );
      return;
    }
    if (_selectedProvider == null) {
      showGlassDialog<void>(
        context: context,
        builder: (_) => _SimpleMessageDialog(
          title: l10n.importPlaylistErrorNoProvider,
        ),
      );
      return;
    }

    final extensions = ref.read(extensionProvider).extensions;
    final hasYoutubeExtension = extensions.any(
      (e) => e.enabled && _extensionHandlesYoutube(e),
    );

    if (!hasYoutubeExtension) {
      final confirmed = await _showMissingExtensionDialog();
      if (confirmed == true && mounted) {
        Navigator.of(context).pop();
      }
      return;
    }

    setState(() {
      _extractorError = null;
      _phase = _Phase.extracting;
      _results.clear();
      _progress = 0;
      _total = 0;
    });

    try {
      final songs = await _extractor.extract(url);
      if (!mounted) return;
      if (songs.isEmpty) {
        setState(() {
          _phase = _Phase.idle;
          _extractorError = l10n.importPlaylistNoResults;
        });
        return;
      }
      setState(() {
        _phase = _Phase.searching;
        _total = songs.length;
        _progress = 0;
      });
      await for (final m in _searcher.searchAll(
        songs: songs,
        providerId: _selectedProvider!,
        onProgress: (d, t) {
          if (!mounted) return;
          setState(() {
            _progress = d;
          });
        },
      )) {
        if (!mounted) return;
        setState(() => _results.add(m));
      }
      if (!mounted) return;
      setState(() => _phase = _Phase.ready);
    } catch (e, st) {
      _log.e('Import failed', e, st);
      if (!mounted) return;
      setState(() {
        _phase = _Phase.idle;
        _extractorError = e.toString();
      });
    }
  }

  /// Returns true if [ext] can handle YouTube Music URLs.
  ///
  /// The check is intentionally lenient: we look for any hint of YouTube in
  /// the extension's id, name, display name, or URL patterns. If the user
  /// installed something called "YouTube Music", we trust them.
  bool _extensionHandlesYoutube(Extension ext) {
    final id = ext.id.toLowerCase();
    final name = ext.name.toLowerCase();
    final display = ext.displayName.toLowerCase();
    final haystack = '$id $name $display';
    if (haystack.contains('youtube') || haystack.contains('ytmusic')) {
      return true;
    }
    final handler = ext.urlHandler;
    if (handler == null || !handler.enabled) return false;
    return handler.patterns.any(
      (String p) {
        final lp = p.toLowerCase();
        return lp.contains('youtube') ||
            lp.contains('youtu.be') ||
            lp.contains('ytmusic');
      },
    );
  }

  Future<bool?> _showMissingExtensionDialog() {
    final l10n = context.l10n;
    return showGlassDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => PopScope(
        canPop: true,
        child: AlertDialog(
          title: Text(l10n.importPlaylistNoExtensionTitle),
          content: Text(l10n.importPlaylistNoExtensionBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.importPlaylistClose),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.importPlaylistInstallExtension),
            ),
          ],
        ),
      ),
    );
  }

  void _downloadAll() {
    final l10n = context.l10n;
    final matched = _results.where((m) => m.isMatched).toList();
    if (matched.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.importPlaylistNoneQueued)),
      );
      return;
    }

    final firstMatched = matched.first.matched!;
    final playlistName = _urlController.text.trim();

    DownloadServicePicker.show(
      context,
      trackName: playlistName,
      artistName:
          '${matched.length} ${l10n.importPlaylistTracksLabel}',
      coverUrl: firstMatched.coverUrl,
      recommendedService: _selectedProvider,
      onSelect: (quality, service) {
        _queueAll(quality, service, playlistName);
      },
    );
  }

  void _queueAll(String quality, String service, String playlistName) {
    final l10n = context.l10n;
    final queue = ref.read(downloadQueueProvider.notifier);
    var added = 0;
    for (final m in _results) {
      final t = m.matched;
      if (t == null) continue;
      queue.addToQueue(
        t,
        service,
        qualityOverride: quality,
        playlistName: playlistName,
      );
      added++;
    }
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          added == 0
              ? l10n.importPlaylistNoneQueued
              : l10n.importPlaylistQueued(added),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final extensions = ref.watch(extensionProvider).extensions;
    final searchExtensions = extensions
        .where((e) => e.enabled && e.hasCustomSearch)
        .toList();

    if (_selectedProvider == null && searchExtensions.isNotEmpty) {
      _selectedProvider =
          ref.read(settingsProvider).searchProvider ?? searchExtensions.first.id;
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: GlassAppBar(
        child: AppBar(
          title: Text(l10n.importPlaylistTitle),
          actions: [
            if (_phase == _Phase.ready)
              TextButton(
                onPressed:
                    _results.any((m) => m.isMatched) ? _downloadAll : null,
                child: Text(l10n.importPlaylistDownload),
              ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          _buildUrlField(theme, l10n),
          const SizedBox(height: 16),
          if (searchExtensions.isEmpty)
            _buildError(
              theme,
              l10n.importPlaylistErrorNoSearchExtensions,
            )
          else
            _buildProviderDropdown(theme, l10n, searchExtensions),
          if (_extractorError != null) _buildError(theme, _extractorError!),
          const SizedBox(height: 16),
          _buildActionButton(theme, l10n),
          if (_phase == _Phase.extracting)
            _buildStatus(theme, l10n.importPlaylistFetching),
          if (_phase == _Phase.searching)
            _buildStatus(
              theme,
              l10n.importPlaylistSearching(_progress, _total),
            ),
          if (_phase == _Phase.ready) ..._buildResults(theme, l10n),
        ],
      ),
    );
  }

  Widget _buildUrlField(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: l10n.importPlaylistUrlLabel,
              hintText: l10n.importPlaylistUrlHint,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          onPressed: _pasteFromClipboard,
          icon: const Icon(Icons.content_paste_rounded),
          tooltip: l10n.importPlaylistPaste,
        ),
      ],
    );
  }

  Widget _buildProviderDropdown(
    ThemeData theme,
    AppLocalizations l10n,
    List<Extension> extensions,
  ) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedProvider,
      decoration: InputDecoration(
        labelText: l10n.importPlaylistProviderLabel,
        border: const OutlineInputBorder(),
      ),
      items: [
        for (final ext in extensions)
          DropdownMenuItem(
            value: ext.id,
            child: Text(ext.displayName),
          ),
      ],
      onChanged: _phase == _Phase.idle
          ? (v) => setState(() => _selectedProvider = v)
          : null,
    );
  }

  Widget _buildActionButton(ThemeData theme, AppLocalizations l10n) {
    final isBusy =
        _phase == _Phase.extracting || _phase == _Phase.searching;
    final label = _phase == _Phase.ready
        ? l10n.importPlaylistRescan
        : l10n.importPlaylistFindMatches;
    return FilledButton.icon(
      onPressed: isBusy ? null : _startImport,
      icon: isBusy
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.search_rounded),
      label: Text(label),
    );
  }

  Widget _buildStatus(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildError(ThemeData theme, String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: theme.textTheme.bodySmall),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildResults(ThemeData theme, AppLocalizations l10n) {
    final matched = _results.where((m) => m.isMatched).length;
    final exact = _results.where((m) => m.confidence == MatchConfidence.exact).length;
    final approx = _results.where((m) => m.confidence == MatchConfidence.approximate).length;
    final none = _results.where((m) => !m.isMatched).length;

    return [
      const SizedBox(height: 24),
      Text(
        l10n.importPlaylistResultsSummary(matched, _results.length),
        style: theme.textTheme.titleMedium,
      ),
      Text(
        l10n.importPlaylistResultsBreakdown(exact, approx, none),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 12),
      for (final m in _results) _buildResultTile(theme, m),
    ];
  }

  Widget _buildResultTile(ThemeData theme, MatchedSong m) {
    final t = m.matched;
    final color = switch (m.confidence) {
      MatchConfidence.exact => Colors.green,
      MatchConfidence.approximate => Colors.orange,
      MatchConfidence.none => theme.colorScheme.error,
    };
    final icon = switch (m.confidence) {
      MatchConfidence.exact => Icons.check_circle_rounded,
      MatchConfidence.approximate => Icons.warning_amber_rounded,
      MatchConfidence.none => Icons.cancel_rounded,
    };
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          t?.name ?? m.extracted.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          t?.artistName.isNotEmpty == true
              ? '${t!.artistName} • ${m.extracted.searchQuery}'
              : m.extracted.searchQuery,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: m.isMatched
            ? const Icon(Icons.download_for_offline_outlined, size: 20)
            : null,
      ),
    );
  }
}

enum _Phase { idle, extracting, searching, ready }

class _SimpleMessageDialog extends StatelessWidget {
  final String title;
  const _SimpleMessageDialog({required this.title});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    );
  }
}
