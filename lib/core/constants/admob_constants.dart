import 'package:flutter/foundation.dart';
import 'package:prompt_enhancer/core/constants/app_routes.dart';

abstract final class AdMobConstants {
  static const String appId = 'ca-app-pub-2020561089374332~2107591146';

  static const Map<String, String> bannerUnitIdsByRoute = {
    AppRoutes.home: 'ca-app-pub-2020561089374332/4940670447',
    AppRoutes.history: 'ca-app-pub-2020561089374332/4525737474',
    AppRoutes.trending: 'ca-app-pub-2020561089374332/1899574132',
    AppRoutes.metrics: 'ca-app-pub-2020561089374332/9586492466',
    AppRoutes.settings: 'ca-app-pub-2020561089374332/1125548515',
  };

  static String bannerUnitIdFor(String route) {
    final configuredUnitId = bannerUnitIdsByRoute[route] ?? '';
    if (!kDebugMode) {
      return configuredUnitId;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'ca-app-pub-3940256099942544/9214589741',
      TargetPlatform.iOS => 'ca-app-pub-3940256099942544/2435281174',
      _ => configuredUnitId,
    };
  }
}
