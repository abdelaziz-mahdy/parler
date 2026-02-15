import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateInfo {
  final String latestVersion;
  final String currentVersion;
  final String? downloadUrl;
  final String? releaseNotes;
  final String? htmlUrl;

  UpdateInfo({
    required this.latestVersion,
    required this.currentVersion,
    this.downloadUrl,
    this.releaseNotes,
    this.htmlUrl,
  });

  bool get hasUpdate =>
      _compareVersions(latestVersion, currentVersion) > 0;
}

class UpdateService {
  static const _dismissedVersionKey = 'dismissed_update_version';
  static const _dismissedAtKey = 'dismissed_update_at';
  static const _repoOwner = 'abdelaziz-mahdy';
  static const _repoName = 'french';

  /// Check for updates from GitHub Releases.
  /// Returns null if no update available or if check fails.
  /// Check for updates from GitHub Releases.
  /// Returns null if no update available or if check fails.
  /// Set [force] to true to bypass the snooze (e.g. manual check from settings).
  static Future<UpdateInfo?> checkForUpdate({bool force = false}) async {
    // Skip on web
    if (kIsWeb) return null;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final response = await http.get(
        Uri.parse(
          'https://api.github.com/repos/$_repoOwner/$_repoName/releases/latest',
        ),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final data = json.decode(response.body) as Map<String, dynamic>;
      final tagName = data['tag_name'] as String? ?? '';
      final latestVersion = tagName.replaceFirst('v', '');
      final releaseNotes = data['body'] as String?;
      final htmlUrl = data['html_url'] as String?;

      // Find APK asset
      String? downloadUrl;
      final assets = data['assets'] as List<dynamic>? ?? [];
      for (final asset in assets) {
        final name = asset['name'] as String? ?? '';
        if (name.endsWith('.apk')) {
          downloadUrl = asset['browser_download_url'] as String?;
          break;
        }
      }

      final info = UpdateInfo(
        latestVersion: latestVersion,
        currentVersion: currentVersion,
        downloadUrl: downloadUrl,
        releaseNotes: releaseNotes,
        htmlUrl: htmlUrl,
      );

      if (!info.hasUpdate) return null;

      // Check if user snoozed this version recently (within 24 hours)
      if (!force) {
        final prefs = await SharedPreferences.getInstance();
        final dismissed = prefs.getString(_dismissedVersionKey);
        final dismissedAt = prefs.getInt(_dismissedAtKey);
        if (dismissed == latestVersion && dismissedAt != null) {
          final elapsed = DateTime.now().millisecondsSinceEpoch - dismissedAt;
          if (elapsed < const Duration(hours: 24).inMilliseconds) {
            return null;
          }
        }
      }

      return info;
    } catch (e) {
      debugPrint('Update check failed: $e');
      return null;
    }
  }

  /// Mark a version as dismissed so the dialog won't show again.
  static Future<void> dismissVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dismissedVersionKey, version);
    await prefs.setInt(_dismissedAtKey, DateTime.now().millisecondsSinceEpoch);
  }
}

/// Compare two semantic version strings.
/// Returns positive if a > b, negative if a < b, 0 if equal.
int _compareVersions(String a, String b) {
  final aParts = a.split('.').map(int.tryParse).toList();
  final bParts = b.split('.').map(int.tryParse).toList();

  for (int i = 0; i < 3; i++) {
    final av = (i < aParts.length ? aParts[i] : 0) ?? 0;
    final bv = (i < bParts.length ? bParts[i] : 0) ?? 0;
    if (av != bv) return av - bv;
  }
  return 0;
}
