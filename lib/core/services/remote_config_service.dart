import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class RemoteConfigService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'app_settings';
  static const String _doc = 'farmvest_config';

  /// Fetch configuration from Firestore and update AppConstants
  static Future<void> initialize() async {
    try {
      debugPrint("Fetching remote config...");
      final docSnapshot = await _firestore
          .collection(_collection)
          .doc(_doc)
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        _updateConstants(data);
        await _checkVersion(data);
      } else {
        debugPrint(
          "Remote config document '$_collection/$_doc' not found. Using defaults.",
        );
      }
    } catch (e) {
      debugPrint("Error fetching remote config: $e");
      // App continues with default constants
    }
  }

  static void _updateConstants(Map<String, dynamic> data) {
    final String? liveUrl = data['live_api_url'];
    final String? stagingUrl = data['staging_api_url'];
    final String? akLiveUrl = data['animalkart_live_url'];
    final String? akStagingUrl = data['animalkart_staging_url'];

    debugPrint("Firebase Config - Live: $liveUrl, Staging: $stagingUrl");

    // Update the base source URLs in AppConstants
    if (liveUrl != null && liveUrl.isNotEmpty) {
      AppConstants.liveUrl = liveUrl;
    }
    if (stagingUrl != null && stagingUrl.isNotEmpty) {
      AppConstants.stagingUrl = stagingUrl;
    }
    if (akLiveUrl != null && akLiveUrl.isNotEmpty) {
      AppConstants.animalKartLiveApiUrl = akLiveUrl;
    }
    if (akStagingUrl != null && akStagingUrl.isNotEmpty) {
      AppConstants.animalKartStagingApiUrl = akStagingUrl;
    }

    // Re-apply the user's selected environment using the new base URLs
    AppConstants.initialize();
  }

  static Future<void> _checkVersion(Map<String, dynamic> data) async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;

      String? latestVersion;
      bool forceUpdate = data['force_update'] ?? false;

      // Skip platform-specific version checks on web
      if (!kIsWeb) {
        if (Platform.isAndroid) {
          latestVersion = data['android_version'];
        } else if (Platform.isIOS) {
          latestVersion = data['ios_version'];
        }
      } else {
        // For web, you can optionally check a web_version field
        latestVersion = data['web_version'];
      }

      if (latestVersion != null) {
        debugPrint(
          "Version Check: Current=$currentVersion, Latest=$latestVersion, Force=$forceUpdate",
        );
        // Compare logic can be enhanced (semver)
        if (currentVersion != latestVersion) {
          debugPrint("New version available.");
          // You can use a provider or global key to show dialog here
          // For now we just log it as per request "maintain app version"
        }
      }
    } catch (e) {
      debugPrint("Error checking version: $e");
    }
  }
}
