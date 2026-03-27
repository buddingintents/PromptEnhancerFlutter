import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

const bool _isFlutterTest = bool.fromEnvironment('FLUTTER_TEST');

class AppBannerAdSlot extends StatefulWidget {
  const AppBannerAdSlot({super.key, required this.adUnitId});

  final String adUnitId;

  @override
  State<AppBannerAdSlot> createState() => _AppBannerAdSlotState();
}

class _AppBannerAdSlotState extends State<AppBannerAdSlot> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  @override
  void didUpdateWidget(covariant AppBannerAdSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.adUnitId != widget.adUnitId) {
      _disposeBanner();
      _loadBanner();
    }
  }

  @override
  void dispose() {
    _disposeBanner();
    super.dispose();
  }

  void _loadBanner() {
    if (!_supportsMobileAds || widget.adUnitId.trim().isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
      _isLoaded = false;
      _errorMessage = null;
    });

    final bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }

          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
            _isLoading = false;
            _errorMessage = null;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint(
            'AdMob banner failed to load for ${widget.adUnitId}: '
            '[${error.code}] ${error.message}',
          );

          if (!mounted) {
            return;
          }

          setState(() {
            _bannerAd = null;
            _isLoaded = false;
            _isLoading = false;
            _errorMessage = 'Ad unavailable right now';
          });
        },
      ),
    );

    bannerAd.load();
  }

  void _disposeBanner() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isLoaded = false;
    _isLoading = false;
    _errorMessage = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bannerAd = _bannerAd;
    final bannerHeight = _isLoaded && bannerAd != null
        ? bannerAd.size.height.toDouble()
        : 64.0;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: SizedBox(
                height: bannerHeight,
                child: _isLoaded && bannerAd != null
                    ? Center(
                        child: SizedBox(
                          width: bannerAd.size.width.toDouble(),
                          height: bannerAd.size.height.toDouble(),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: AdWidget(ad: bannerAd),
                          ),
                        ),
                      )
                    : _BannerPlaceholder(
                        isLoading: _isLoading,
                        message: _errorMessage,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get _supportsMobileAds {
    if (_isFlutterTest || kIsWeb) {
      return false;
    }

    final platform = defaultTargetPlatform;
    return platform == TargetPlatform.android || platform == TargetPlatform.iOS;
  }
}

class _BannerPlaceholder extends StatelessWidget {
  const _BannerPlaceholder({required this.isLoading, required this.message});

  final bool isLoading;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
          )
        else
          Icon(
            Icons.campaign_outlined,
            size: 18,
            color: theme.colorScheme.primary,
          ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            message ?? 'Loading ad...',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge,
          ),
        ),
      ],
    );
  }
}
