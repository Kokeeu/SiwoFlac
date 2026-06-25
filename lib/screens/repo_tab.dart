import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:neroflac/l10n/l10n.dart';
import 'package:neroflac/widgets/show_helpers.dart';
import 'package:neroflac/providers/store_provider.dart';
import 'package:neroflac/theme/nero_theme_extension.dart';
import 'package:neroflac/widgets/settings_group.dart';
import 'package:neroflac/widgets/animation_utils.dart';
import 'package:neroflac/screens/store/extension_details_screen.dart';
import 'package:neroflac/utils/app_bar_layout.dart';
import 'package:neroflac/utils/nav_bar_inset.dart';

class RepoTab extends ConsumerStatefulWidget {
  const RepoTab({super.key});

  @override
  ConsumerState<RepoTab> createState() => _RepoTabState();
}

class _RepoTabState extends ConsumerState<RepoTab> {
  final _searchController = TextEditingController();
  final _repoUrlController = TextEditingController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    final cacheDir = await getApplicationCacheDirectory();

    if (!mounted) return;

    await ref.read(storeProvider.notifier).initialize(cacheDir.path);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _repoUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storeFilterState = ref.watch(
      storeProvider.select(
        (s) => (s.extensions, s.selectedCategory, s.searchQuery),
      ),
    );
    final extensions = storeFilterState.$1;
    final selectedCategory = storeFilterState.$2;
    final searchQuery = storeFilterState.$3;
    final isLoading = ref.watch(storeProvider.select((s) => s.isLoading));
    final error = ref.watch(storeProvider.select((s) => s.error));
    final downloadingId = ref.watch(
      storeProvider.select((s) => s.downloadingId),
    );
    final hasRegistryUrl = ref.watch(
      storeProvider.select((s) => s.hasRegistryUrl),
    );
    final registryUrl = ref.watch(storeProvider.select((s) => s.registryUrl));
    final filteredExtensions = StoreState(
      extensions: extensions,
      selectedCategory: selectedCategory,
      searchQuery: searchQuery,
    ).filteredExtensions;
    if (_searchController.text != searchQuery) {
      _searchController.value = TextEditingValue(
        text: searchQuery,
        selection: TextSelection.collapsed(offset: searchQuery.length),
      );
    }
    final colorScheme = Theme.of(context).colorScheme;
    final nero = NeroTheme.of(context);
    final topPadding = normalizedHeaderTopPadding(context);
    final bottomInset = context.navBarBottomInset;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(storeProvider.notifier).refresh(forceRefresh: true),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120 + topPadding,
              collapsedHeight: kToolbarHeight,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              actions: [
                if (hasRegistryUrl)
                  IconButton(
                    icon: const Icon(Icons.link),
                    tooltip: context.l10n.storeChangeRepoTooltip,
                    onPressed: () => _showChangeRepoDialog(registryUrl),
                  ),
              ],
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final maxHeight = 120 + topPadding;
                  final minHeight = kToolbarHeight + topPadding;
                  final expandRatio =
                      ((constraints.maxHeight - minHeight) /
                              (maxHeight - minHeight))
                          .clamp(0.0, 1.0);

                  return FlexibleSpaceBar(
                    expandedTitleScale: 1.0,
                    titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
                    title: Text(
                      context.l10n.storeTitle,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 24 + (16 * expandRatio),
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                        color: nero.carbonInk,
                      ),
                    ),
                  );
                },
              ),
            ),

            if (!hasRegistryUrl)
              SliverFillRemaining(
                child: _buildSetupRepoState(colorScheme, error),
              )
            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _searchController,
                    builder: (context, value, _) {
                      return TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: context.l10n.storeSearch,
                          hintStyle: TextStyle(color: nero.fog),
                          prefixIcon: Icon(Icons.search, color: nero.slate),
                          suffixIcon: value.text.isNotEmpty
                              ? IconButton(
                                  tooltip: context.l10n.dialogClear,
                                  icon: const Icon(Icons.clear),
                                  color: nero.slate,
                                  onPressed: () {
                                    _searchController.clear();
                                    ref
                                        .read(storeProvider.notifier)
                                        .setSearchQuery('');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: nero.mist),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: nero.mist),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: nero.prismTeal,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: nero.paper,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                        ),
                        style: TextStyle(
                          color: nero.carbonInk,
                          fontFamily: 'Inter',
                          fontSize: 14,
                        ),
                        onChanged: (value) {
                          ref
                              .read(storeProvider.notifier)
                              .setSearchQuery(value);
                        },
                        onTapOutside: (_) {
                          FocusScope.of(context).unfocus();
                        },
                      );
                    },
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      _CategoryChip(
                        label: context.l10n.storeFilterAll,
                        icon: Icons.apps,
                        isSelected: selectedCategory == null,
                        onTap: () =>
                            ref.read(storeProvider.notifier).setCategory(null),
                      ),
                      const SizedBox(width: 8),
                      _CategoryChip(
                        label: context.l10n.storeFilterMetadata,
                        icon: Icons.label_outline,
                        isSelected: selectedCategory == StoreCategory.metadata,
                        onTap: () => ref
                            .read(storeProvider.notifier)
                            .setCategory(StoreCategory.metadata),
                      ),
                      const SizedBox(width: 8),
                      _CategoryChip(
                        label: context.l10n.storeFilterDownload,
                        icon: Icons.download_outlined,
                        isSelected: selectedCategory == StoreCategory.download,
                        onTap: () => ref
                            .read(storeProvider.notifier)
                            .setCategory(StoreCategory.download),
                      ),
                      const SizedBox(width: 8),
                      _CategoryChip(
                        label: context.l10n.storeFilterUtility,
                        icon: Icons.build_outlined,
                        isSelected: selectedCategory == StoreCategory.utility,
                        onTap: () => ref
                            .read(storeProvider.notifier)
                            .setCategory(StoreCategory.utility),
                      ),
                      const SizedBox(width: 8),
                      _CategoryChip(
                        label: context.l10n.storeFilterLyrics,
                        icon: Icons.lyrics_outlined,
                        isSelected: selectedCategory == StoreCategory.lyrics,
                        onTap: () => ref
                            .read(storeProvider.notifier)
                            .setCategory(StoreCategory.lyrics),
                      ),
                      const SizedBox(width: 8),
                      _CategoryChip(
                        label: context.l10n.storeFilterIntegration,
                        icon: Icons.link,
                        isSelected:
                            selectedCategory == StoreCategory.integration,
                        onTap: () => ref
                            .read(storeProvider.notifier)
                            .setCategory(StoreCategory.integration),
                      ),
                    ],
                  ),
                ),
              ),

              if (isLoading && extensions.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: TrackListSkeleton(itemCount: 6),
                  ),
                )
              else if (error != null && extensions.isEmpty)
                SliverFillRemaining(child: _buildErrorState(error, colorScheme))
              else if (filteredExtensions.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyState(
                    hasFilters:
                        searchQuery.isNotEmpty || selectedCategory != null,
                    colorScheme: colorScheme,
                  ),
                )
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Text(
                      context.l10n.storeExtensionsCount(
                        filteredExtensions.length,
                      ),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: nero.slate,
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: SettingsGroup(
                    children: filteredExtensions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final ext = entry.value;
                      return _ExtensionItem(
                        extension: ext,
                        showDivider: index < filteredExtensions.length - 1,
                        isDownloading: downloadingId == ext.id,
                        onInstall: () => _installExtension(ext),
                        onUpdate: () => _updateExtension(ext),
                        onTap: () => _showExtensionDetails(ext),
                      );
                    }).toList(),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ],
            SliverToBoxAdapter(child: SizedBox(height: bottomInset)),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupRepoState(ColorScheme colorScheme, String? error) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.extension_outlined,
              size: 72,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.storeAddRepoTitle,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _repoUrlController,
              decoration: InputDecoration(
                hintText: context.l10n.storeRepoUrlHint,
                labelText: context.l10n.storeRepoUrlLabel,
                prefixIcon: const Icon(Icons.link),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide(color: colorScheme.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide(color: colorScheme.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              keyboardType: TextInputType.url,
              autocorrect: false,
              onSubmitted: (_) => _submitRepoUrl(),
            ),
            if (error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 20,
                      color: colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        error,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _submitRepoUrl,
                icon: const Icon(Icons.add),
                label: Text(context.l10n.storeAddRepoButton),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitRepoUrl() {
    final url = _repoUrlController.text.trim();
    if (url.isEmpty) return;
    ref.read(storeProvider.notifier).setRegistryUrl(url);
  }

  void _showChangeRepoDialog(String currentUrl) {
    final changeUrlController = TextEditingController(text: currentUrl);
    showNeroDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.storeRepoDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.storeRepoDialogCurrent,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              currentUrl,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'JetBrains Mono',
                fontSize: 11,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: changeUrlController,
              decoration: InputDecoration(
                hintText: context.l10n.storeRepoUrlHint,
                labelText: context.l10n.storeNewRepoUrlLabel,
                prefixIcon: const Icon(Icons.link),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              keyboardType: TextInputType.url,
              autocorrect: false,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(storeProvider.notifier).removeRegistryUrl();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(context.l10n.dialogRemove),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () {
              final newUrl = changeUrlController.text.trim();
              Navigator.of(context).pop();
              if (newUrl.isNotEmpty) {
                ref.read(storeProvider.notifier).setRegistryUrl(newUrl);
              }
            },
            child: Text(context.l10n.dialogSave),
          ),
        ],
      ),
    ).then((_) => changeUrlController.dispose());
  }

  Widget _buildErrorState(String error, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              context.l10n.storeLoadError,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () =>
                  ref.read(storeProvider.notifier).refresh(forceRefresh: true),
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.dialogRetry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required bool hasFilters,
    required ColorScheme colorScheme,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasFilters ? Icons.search_off : Icons.extension_off,
            size: 64,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters
                ? context.l10n.storeEmptyNoResults
                : context.l10n.storeEmptyNoExtensions,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (hasFilters) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                _searchController.clear();
                ref.read(storeProvider.notifier).clearSearch();
              },
              child: Text(context.l10n.storeClearFilters),
            ),
          ],
        ],
      ),
    );
  }

  void _showExtensionDetails(StoreExtension ext) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ExtensionDetailsScreen(extension: ext),
      ),
    );
  }

  Future<void> _installExtension(StoreExtension ext) async {
    final tempDir = await getTemporaryDirectory();
    final appDir = await getApplicationDocumentsDirectory();
    final extensionsDir = '${appDir.path}/extensions';

    final success = await ref
        .read(storeProvider.notifier)
        .installExtension(ext.id, tempDir.path, extensionsDir);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '${ext.displayName} installed. Enable it in Settings > Extensions'
                : 'Failed to install ${ext.displayName}',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _updateExtension(StoreExtension ext) async {
    final tempDir = await getTemporaryDirectory();

    final success = await ref
        .read(storeProvider.notifier)
        .updateExtension(ext.id, tempDir.path);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '${ext.displayName} updated to v${ext.version}'
                : 'Failed to update ${ext.displayName}',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final nero = NeroTheme.of(context);
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).brightness == Brightness.dark
              ? nero.prismTeal
              : nero.carbonInk),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: nero.carbonInk,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      backgroundColor: nero.paper,
      selectedColor: Theme.of(context).brightness == Brightness.dark
          ? nero.prismTeal
          : nero.mist,
      side: BorderSide(color: nero.mist, width: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class _ExtensionItem extends StatelessWidget {
  final StoreExtension extension;
  final bool showDivider;
  final bool isDownloading;
  final VoidCallback onInstall;
  final VoidCallback onUpdate;
  final VoidCallback? onTap;

  const _ExtensionItem({
    required this.extension,
    required this.showDivider,
    required this.isDownloading,
    required this.onInstall,
    required this.onUpdate,
    this.onTap,
  });

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case StoreCategory.metadata:
        return Icons.label_outline;
      case StoreCategory.download:
        return Icons.download_outlined;
      case StoreCategory.utility:
        return Icons.build_outlined;
      case StoreCategory.lyrics:
        return Icons.lyrics_outlined;
      case StoreCategory.integration:
        return Icons.link;
      default:
        return Icons.extension;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final nero = NeroTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: extension.isInstalled
                        ? nero.mist
                        : nero.paper,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: nero.mist, width: 1),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child:
                      extension.iconUrl != null && extension.iconUrl!.isNotEmpty
                      ? Image.network(
                          extension.iconUrl!,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            _getCategoryIcon(extension.category),
                            color: extension.isInstalled
                                ? nero.prismTeal
                                : nero.slate,
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: nero.prismTeal,
                                ),
                              ),
                            );
                          },
                        )
                      : Icon(
                          _getCategoryIcon(extension.category),
                          color: extension.isInstalled
                              ? nero.prismTeal
                              : nero.slate,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              extension.displayName,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: nero.carbonInk,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: nero.paper,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'v${extension.version}',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: nero.slate,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (extension.requiresNewerApp) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 12,
                                color: colorScheme.onErrorContainer,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                context.l10n.storeRequiresVersion(
                                  extension.minAppVersion ?? '',
                                ),
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: colorScheme.onErrorContainer,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 4),
                        Text(
                          extension.description,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: nero.slate,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (isDownloading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (extension.hasUpdate)
                  FilledButton.tonal(
                    onPressed: onUpdate,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: const Size(0, 36),
                    ),
                    child: Text(context.l10n.storeUpdate),
                  )
                else if (extension.isInstalled)
                  OutlinedButton(
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: const Size(0, 36),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, size: 16, color: colorScheme.outline),
                        const SizedBox(width: 4),
                        Text(
                          context.l10n.storeInstalled,
                          style: TextStyle(color: colorScheme.outline),
                        ),
                      ],
                    ),
                  )
                else
                  FilledButton(
                    onPressed: onInstall,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: const Size(0, 36),
                    ),
                    child: Text(context.l10n.storeInstall),
                  ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: 76,
            endIndent: 16,
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
      ],
    );
  }
}
