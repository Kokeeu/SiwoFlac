import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:neroflac/constants/app_info.dart';
import 'package:neroflac/utils/logger.dart';

final _log = AppLogger('AppRemoteConfig');

class AppRemoteConfig {
  final RemoteAnnouncement? announcement;

  const AppRemoteConfig({this.announcement});

  factory AppRemoteConfig.fromJson(Map<String, dynamic> json) {
    final announcementJson = json['announcement'];

    return AppRemoteConfig(
      announcement: announcementJson is Map
          ? RemoteAnnouncement.fromJson(
              Map<String, dynamic>.from(announcementJson),
            )
          : null,
    );
  }
}

class RemoteConfigSnapshot {
  final AppRemoteConfig config;
  final String rawJson;
  final bool changed;

  const RemoteConfigSnapshot({
    required this.config,
    required this.rawJson,
    required this.changed,
  });
}

class RemoteAnnouncement {
  final String id;
  final bool enabled;
  final String title;
  final String message;
  final bool ctaEnabled;
  final String? ctaLabel;
  final String? ctaUrl;
  final bool dismissible;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final String? minVersion;
  final String? maxVersion;
  final String priority;

  const RemoteAnnouncement({
    required this.id,
    required this.enabled,
    required this.title,
    required this.message,
    this.ctaEnabled = false,
    this.ctaLabel,
    this.ctaUrl,
    this.dismissible = true,
    this.startsAt,
    this.endsAt,
    this.minVersion,
    this.maxVersion,
    this.priority = 'normal',
  });

  factory RemoteAnnouncement.fromJson(Map<String, dynamic> json) {
    return RemoteAnnouncement(
      id: _readString(json['id']),
      enabled: json['enabled'] as bool? ?? true,
      title: _readString(json['title']),
      message: _readString(json['message']),
      ctaEnabled: _readBool(json['cta_enabled'] ?? json['ctaEnabled']),
      ctaLabel: _readNullableString(json['cta_label'] ?? json['ctaLabel']),
      ctaUrl: _readNullableString(json['cta_url'] ?? json['ctaUrl']),
      dismissible: json['dismissible'] as bool? ?? true,
      startsAt: _readDate(json['starts_at'] ?? json['startsAt']),
      endsAt: _readDate(json['ends_at'] ?? json['endsAt']),
      minVersion: _readNullableString(
        json['min_version'] ?? json['minVersion'],
      ),
      maxVersion: _readNullableString(
        json['max_version'] ?? json['maxVersion'],
      ),
      priority: _readString(json['priority']).isEmpty
          ? 'normal'
          : _readString(json['priority']),
    );
  }

  bool get hasCta =>
      ctaEnabled &&
      ctaLabel != null &&
      ctaLabel!.isNotEmpty &&
      ctaUrl != null &&
      ctaUrl!.isNotEmpty;

  bool isActive({DateTime? now, String currentVersion = AppInfo.version}) {
    if (!enabled || id.isEmpty || title.isEmpty || message.isEmpty) {
      return false;
    }

    final referenceTime = now ?? DateTime.now();
    if (startsAt != null && referenceTime.isBefore(startsAt!)) {
      return false;
    }
    if (endsAt != null && referenceTime.isAfter(endsAt!)) {
      return false;
    }
    if (minVersion != null &&
        minVersion!.isNotEmpty &&
        _compareVersions(currentVersion, minVersion!) < 0) {
      return false;
    }
    if (maxVersion != null &&
        maxVersion!.isNotEmpty &&
        _compareVersions(currentVersion, maxVersion!) > 0) {
      return false;
    }

    return true;
  }
}

class AppRemoteConfigService {
  static const _cachedConfigJsonKey = 'app_remote_config_cached_json';
  static const _cachedConfigFetchedAtKey =
      'app_remote_config_cached_fetched_at';
  static const _dismissedAnnouncementIdsKey =
      'app_remote_config_dismissed_announcement_ids';

  final http.Client _client;
  final String endpoint;

  AppRemoteConfigService({
    http.Client? client,
    this.endpoint = AppInfo.remoteConfigApiUrl,
  }) : _client = client ?? http.Client();

  Future<AppRemoteConfig?> fetchConfig({String? locale}) async {
    final snapshot = await fetchConfigSnapshot(locale: locale);
    return snapshot?.config;
  }

  Future<RemoteConfigSnapshot?> readCachedConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString(_cachedConfigJsonKey);
    if (cachedJson == null || cachedJson.isEmpty) {
      return null;
    }

    return _parseSnapshot(cachedJson, changed: false);
  }

  Future<RemoteConfigSnapshot?> fetchConfigSnapshot({String? locale}) async {
    try {
      final uri = Uri.parse(endpoint).replace(
        queryParameters: {
          'platform': Platform.isAndroid ? 'android' : Platform.operatingSystem,
          'version': AppInfo.version,
          'build': AppInfo.buildNumber,
          if (locale != null && locale.isNotEmpty) 'locale': locale,
        },
      );

      final response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        _log.w('Remote config API returned ${response.statusCode}');
        return null;
      }

      final snapshot = _parseSnapshot(response.body);
      if (snapshot == null) return null;

      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cachedConfigJsonKey);
      if (cachedJson != snapshot.rawJson) {
        await prefs.setString(_cachedConfigJsonKey, snapshot.rawJson);
        await prefs.setString(
          _cachedConfigFetchedAtKey,
          DateTime.now().toIso8601String(),
        );
        return RemoteConfigSnapshot(
          config: snapshot.config,
          rawJson: snapshot.rawJson,
          changed: true,
        );
      }

      return snapshot;
    } catch (e) {
      _log.w('Remote config fetch failed: $e');
      return null;
    }
  }

  Future<RemoteAnnouncement?> fetchActiveAnnouncement({String? locale}) async {
    final snapshot =
        await fetchConfigSnapshot(locale: locale) ?? await readCachedConfig();
    final announcement = snapshot?.config.announcement;
    if (announcement == null || !announcement.isActive()) {
      return null;
    }

    final prefs = await SharedPreferences.getInstance();
    final dismissedIds =
        prefs.getStringList(_dismissedAnnouncementIdsKey) ?? const <String>[];
    if (dismissedIds.contains(announcement.id)) {
      return null;
    }

    return announcement;
  }

  Future<void> markAnnouncementDismissed(String id) async {
    if (id.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final dismissedIds =
        prefs.getStringList(_dismissedAnnouncementIdsKey) ?? const <String>[];
    if (dismissedIds.contains(id)) return;

    await prefs.setStringList(_dismissedAnnouncementIdsKey, [
      ...dismissedIds,
      id,
    ]);
  }

  RemoteConfigSnapshot? _parseSnapshot(String body, {bool changed = false}) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map) {
        _log.w('Remote config API returned non-object JSON');
        return null;
      }

      final normalizedJson = jsonEncode(decoded);
      return RemoteConfigSnapshot(
        config: AppRemoteConfig.fromJson(Map<String, dynamic>.from(decoded)),
        rawJson: normalizedJson,
        changed: changed,
      );
    } catch (e) {
      _log.w('Remote config JSON parse failed: $e');
      return null;
    }
  }
}

String _readString(Object? value) {
  return value is String ? value.trim() : '';
}

String? _readNullableString(Object? value) {
  final text = _readString(value);
  return text.isEmpty ? null : text;
}

bool _readBool(Object? value) {
  if (value is bool) return value;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }
  return false;
}

DateTime? _readDate(Object? value) {
  final text = _readString(value);
  return text.isEmpty ? null : DateTime.tryParse(text);
}

int _compareVersions(String left, String right) {
  final leftParts = _versionParts(left);
  final rightParts = _versionParts(right);

  for (var index = 0; index < 3; index++) {
    if (leftParts[index] > rightParts[index]) return 1;
    if (leftParts[index] < rightParts[index]) return -1;
  }

  return 0;
}

List<int> _versionParts(String version) {
  final base = version.split('-').first;
  final parts = base
      .split('.')
      .map((part) => int.tryParse(part) ?? 0)
      .toList(growable: true);
  while (parts.length < 3) {
    parts.add(0);
  }
  return parts.take(3).toList(growable: false);
}
