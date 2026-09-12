import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

/// A compact, transparent indicator showing data freshness and origin.
class DataSourceIndicator extends StatelessWidget {
  final DateTime? lastUpdated;
  final String dataSource;
  final VoidCallback? onRefresh;

  const DataSourceIndicator({
    super.key,
    this.lastUpdated,
    this.dataSource = 'live',
    this.onRefresh,
  });

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return DateFormat('d MMM, h:mm a').format(dt);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeStr = lastUpdated != null ? _formatTimeAgo(lastUpdated!) : 'Recently';

    Color badgeColor;
    String badgeLabel;
    IconData badgeIcon;

    switch (dataSource.toLowerCase()) {
      case 'cached':
        badgeColor = AppColors.brandBlueLight;
        badgeLabel = 'Cached • $timeStr';
        badgeIcon = Icons.offline_pin_outlined;
        break;
      case 'stale':
        badgeColor = AppColors.alertOrange;
        badgeLabel = 'Saved data • $timeStr';
        badgeIcon = Icons.history_rounded;
        break;
      case 'estimated':
        badgeColor = AppColors.alertYellow;
        badgeLabel = 'Model estimate';
        badgeIcon = Icons.analytics_outlined;
        break;
      case 'unavailable':
        badgeColor = AppColors.alertRed;
        badgeLabel = 'Unavailable';
        badgeIcon = Icons.cloud_off_rounded;
        break;
      case 'live':
      default:
        badgeColor = AppColors.alertGreen;
        badgeLabel = 'Updated $timeStr';
        badgeIcon = Icons.check_circle_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badgeColor.withValues(alpha: isDark ? 0.35 : 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 13, color: badgeColor),
          const SizedBox(width: 5),
          Text(
            badgeLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
          if (dataSource == 'stale' && onRefresh != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRefresh,
              child: Text(
                'Retry',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: badgeColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
