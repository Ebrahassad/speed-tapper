import 'package:flutter/foundation.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class AdsManager {
  AdsManager._();

  static const String gameId = '800363462';

  static const String rewardedId = 'Rewarded_Android';
  static const String interstitialId = 'Interstitial_Android';
  static const String bannerId = 'Banner_Android';

  static bool initialized = false;

  static bool rewardedReady = false;
  static bool interstitialReady = false;

  static Future<void> initialize() async {
    if (initialized) return;

    UnityAds.init(
      gameId: gameId,
      testMode: true,
      onComplete: () {
        initialized = true;

        debugPrint('Unity Ads initialized');

        loadRewarded();
        loadInterstitial();
      },
      onFailed: (error, message) {
        debugPrint(
          'Unity Ads initialization failed: $error - $message',
        );
      },
    );
  }

  static void loadRewarded() {
    if (!initialized) return;

    rewardedReady = false;

    UnityAds.load(
      placementId: rewardedId,
      onComplete: (placementId) {
        rewardedReady = true;
        debugPrint('Rewarded loaded');
      },
      onFailed: (placementId, error, message) {
        rewardedReady = false;

        debugPrint(
          'Rewarded load failed: $error - $message',
        );
      },
    );
  }

  static void loadInterstitial() {
    if (!initialized) return;

    interstitialReady = false;

    UnityAds.load(
      placementId: interstitialId,
      onComplete: (placementId) {
        interstitialReady = true;
        debugPrint('Interstitial loaded');
      },
      onFailed: (placementId, error, message) {
        interstitialReady = false;

        debugPrint(
          'Interstitial load failed: $error - $message',
        );
      },
    );
  }

  static bool get canShowRewarded {
    return initialized && rewardedReady;
  }

  static bool get canShowInterstitial {
    return initialized && interstitialReady;
  }

  static void showRewarded({
    required VoidCallback onReward,
    VoidCallback? onUnavailable,
  }) {
    if (!canShowRewarded) {
      onUnavailable?.call();
      loadRewarded();
      return;
    }

    rewardedReady = false;

    UnityAds.showVideoAd(
      placementId: rewardedId,
      onStart: (placementId) {
        debugPrint('Rewarded started');
      },
      onClick: (placementId) {
        debugPrint('Rewarded clicked');
      },
      onSkipped: (placementId) {
        debugPrint('Rewarded skipped');
        loadRewarded();
      },
      onComplete: (placementId) {
        debugPrint('Rewarded completed');

        onReward();

        loadRewarded();
      },
      onFailed: (placementId, error, message) {
        debugPrint(
          'Rewarded show failed: $error - $message',
        );

        loadRewarded();

        onUnavailable?.call();
      },
    );
  }

  static void showInterstitial({
    VoidCallback? onComplete,
  }) {
    if (!canShowInterstitial) {
      loadInterstitial();
      return;
    }

    interstitialReady = false;

    UnityAds.showVideoAd(
      placementId: interstitialId,
      onStart: (placementId) {
        debugPrint('Interstitial started');
      },
      onClick: (placementId) {
        debugPrint('Interstitial clicked');
      },
      onSkipped: (placementId) {
        debugPrint('Interstitial skipped');
        loadInterstitial();
      },
      onComplete: (placementId) {
        debugPrint('Interstitial completed');

        onComplete?.call();

        loadInterstitial();
      },
      onFailed: (placementId, error, message) {
        debugPrint(
          'Interstitial show failed: $error - $message',
        );

        loadInterstitial();
      },
    );
  }
}
