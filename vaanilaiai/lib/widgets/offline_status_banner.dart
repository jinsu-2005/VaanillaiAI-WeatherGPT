import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/network_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/weather_provider.dart';
import '../theme/app_colors.dart';

/// An animated banner that notifies citizens when the app is in offline mode
/// or has successfully reconnected to the internet.
class OfflineStatusBanner extends StatelessWidget {
  const OfflineStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final networkProvider = Provider.of<NetworkProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isOffline = networkProvider.isOffline;
    final showBackOnline = networkProvider.showBackOnlineBanner;

    if (!isOffline && !showBackOnline) {
      return const SizedBox.shrink();
    }

    final isReconnected = !isOffline && showBackOnline;
    final bannerColor = isReconnected ? AppColors.alertGreen : AppColors.alertOrange;
    final bannerBg = isReconnected
        ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5))
        : (isDark ? const Color(0xFF7C2D12) : const Color(0xFFFFEDD5));
    final textColor = isReconnected
        ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46))
        : (isDark ? const Color(0xFFFDBA74) : const Color(0xFF9A3412));

    final icon = isReconnected ? Icons.check_circle_rounded : Icons.wifi_off_rounded;
    final message = isReconnected
        ? localeProvider.t('back_online')
        : localeProvider.t('offline_notice');

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: bannerBg,
          border: Border(
            bottom: BorderSide(
              color: bannerColor.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        child: Row(
          children: [
            Icon(icon, size: 16, color: bannerColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isOffline) ...[
              const SizedBox(width: 8),
              InkWell(
                onTap: () async {
                  await networkProvider.checkConnectivity();
                  if (networkProvider.isOnline) {
                    await weatherProvider.fetchWeather(forceRefresh: true);
                  }
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: bannerColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: bannerColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded, size: 12, color: textColor),
                      const SizedBox(width: 4),
                      Text(
                        'Retry',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
