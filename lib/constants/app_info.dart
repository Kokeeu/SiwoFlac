import 'package:flutter/foundation.dart';

class AppInfo {
  static const String version = '4.7.1';
  static const String buildNumber = '137';
  static const String fullVersion = '$version+$buildNumber';

  static String get displayVersion => kDebugMode ? 'Internal' : version;

  static const String appName = 'SiwöFlac';
  static const String copyright = '© 2026 SiwöFlac';

  static const String mobileAuthor = 'Kokeeu';
  static const String originalAuthor = 'afkarxyz';

  static const String githubRepo = 'Kokeeu/SiwöFlac';
  static const String githubUrl = 'https://github.com/$githubRepo';
  static const String originalGithubUrl =
      'https://github.com/afkarxyz/SpotiFLAC';
  static const String remoteConfigApiUrl =
      'https://raw.githubusercontent.com/Kokeeu/SiwöFlac/main/config.json';

  static const String kofiUrl = '';
  static const String githubSponsorsUrl = '';
}
