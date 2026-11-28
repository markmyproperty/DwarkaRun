import 'dart:convert';
import 'dart:io' show HttpClient, Platform;

import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Finds out whether the store has a newer version than the one running, and
/// sends the player there. Any failure (offline, not installed from a store,
/// store not reachable) counts as "up to date", so the game stays playable.
abstract class UpdateChecker {
  /// True when a newer version is live in the store and the player must update.
  Future<bool> updateRequired();

  /// Starts the update: Play's full-screen updater on Android, the App Store
  /// page on iOS.
  Future<void> startUpdate();

  /// The checker for the platform the game is running on. Checks are off in
  /// debug and profile builds and on the web.
  static UpdateChecker forPlatform() {
    if (kIsWeb || !kReleaseMode) return const NoUpdateChecker();
    if (Platform.isAndroid) return PlayUpdateChecker();
    if (Platform.isIOS) return AppStoreUpdateChecker();
    return const NoUpdateChecker();
  }
}

/// Never asks for an update.
class NoUpdateChecker implements UpdateChecker {
  const NoUpdateChecker();

  @override
  Future<bool> updateRequired() async => false;

  @override
  Future<void> startUpdate() async {}
}

/// Google Play In-App Updates, immediate flow. Works only for installs that
/// came from Google Play (including its testing tracks).
class PlayUpdateChecker implements UpdateChecker {
  @override
  Future<bool> updateRequired() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      switch (info.updateAvailability) {
        case UpdateAvailability.updateAvailable:
        case UpdateAvailability.developerTriggeredUpdateInProgress:
          return true;
        default:
          return false;
      }
    } catch (e) {
      debugPrint('Play update check failed: $e');
      return false;
    }
  }

  @override
  Future<void> startUpdate() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.immediateUpdateAllowed ||
          info.updateAvailability == UpdateAvailability.developerTriggeredUpdateInProgress) {
        // On success Play installs the update and restarts the game.
        final result = await InAppUpdate.performImmediateUpdate();
        if (result == AppUpdateResult.success) return;
      }
    } catch (e) {
      debugPrint('Play immediate update failed: $e');
    }
    // Fall back to the store page.
    final id = (await PackageInfo.fromPlatform()).packageName;
    final market = Uri.parse('market://details?id=$id');
    if (!await _open(market)) {
      await _open(Uri.parse('https://play.google.com/store/apps/details?id=$id'));
    }
  }
}

/// Compares the running version with the version Apple's public lookup
/// service reports for this bundle id.
class AppStoreUpdateChecker implements UpdateChecker {
  Uri? _storePage;

  @override
  Future<bool> updateRequired() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final store = await _lookup(info.packageName);
      if (store == null) return false;
      _storePage = store.page;
      return isNewerVersion(store.version, info.version);
    } catch (e) {
      debugPrint('App Store update check failed: $e');
      return false;
    }
  }

  @override
  Future<void> startUpdate() async {
    var page = _storePage;
    if (page == null) {
      final info = await PackageInfo.fromPlatform();
      page = (await _lookup(info.packageName))?.page;
    }
    if (page != null) await _open(page);
  }

  static Future<({String version, Uri page})?> _lookup(String bundleId) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      // The timestamp avoids a cached answer from before a release.
      final uri = Uri.https('itunes.apple.com', '/lookup', {
        'bundleId': bundleId,
        't': '${DateTime.now().millisecondsSinceEpoch}',
      });
      final req = await client.getUrl(uri);
      final res = await req.close().timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;
      final body = await res.transform(utf8.decoder).join();
      return parseLookup(body);
    } finally {
      client.close(force: true);
    }
  }
}

/// Reads the version and store page from an iTunes lookup response.
@visibleForTesting
({String version, Uri page})? parseLookup(String body) {
  final json = jsonDecode(body);
  if (json is! Map || json['resultCount'] == 0) return null;
  final results = json['results'];
  if (results is! List || results.isEmpty) return null;
  final first = results.first;
  if (first is! Map) return null;
  final version = first['version'];
  final url = first['trackViewUrl'];
  if (version is! String || url is! String) return null;
  return (version: version, page: Uri.parse(url));
}

/// Whether [store] (like "1.2.0") is a higher version than [running].
/// Missing parts count as 0 and anything after a '+' or '-' is ignored.
bool isNewerVersion(String store, String running) {
  List<int> parts(String v) =>
      v.split(RegExp('[+-]')).first.split('.').map((p) => int.tryParse(p.trim()) ?? 0).toList();
  final a = parts(store), b = parts(running);
  for (var i = 0; i < 3; i++) {
    final x = i < a.length ? a[i] : 0;
    final y = i < b.length ? b[i] : 0;
    if (x != y) return x > y;
  }
  return false;
}

Future<bool> _open(Uri uri) async {
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}
