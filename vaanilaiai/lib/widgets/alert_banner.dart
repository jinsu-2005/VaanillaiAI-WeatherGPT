import 'package:flutter/material.dart';
import '../models/alert_model.dart';
import '../theme/app_colors.dart';

class AlertBanner extends StatefulWidget {
  final List<DisasterAlertModel> alerts;
  final VoidCallback? onTap;

  const AlertBanner({
    super.key,
    required this.alerts,
    this.onTap,
  });

  @override
  State<AlertBanner> createState() => _AlertBannerState();
}

class _AlertBannerState extends State<AlertBanner> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'red':
        return AppColors.alertRed;
      case 'orange':
        return AppColors.alertOrange;
      case 'yellow':
        return AppColors.alertYellow;
      default:
        return AppColors.alertGreen;
    }
  }

  Color _getSeverityContainer(bool isDark, String severity) {
    switch (severity.toLowerCase()) {
      case 'red':
        return isDark ? AppColors.alertRedContainer : AppColors.alertRedBg;
      case 'orange':
        return isDark ? AppColors.alertOrangeContainer : AppColors.alertOrangeBg;
      case 'yellow':
        return isDark ? AppColors.alertYellowContainer : AppColors.alertYellowBg;
      default:
        return isDark ? AppColors.alertGreenContainer : AppColors.alertGreenBg;
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'red':
        return Icons.warning_amber_rounded;
      case 'orange':
        return Icons.warning_rounded;
      case 'yellow':
        return Icons.info_outline_rounded;
      default:
        return Icons.verified_user_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = AppColors.textPrimaryC(isDark);
    final textSecondary = AppColors.textSecondaryC(isDark);

    final topAlert = widget.alerts.first;
    final sevColor = _getSeverityColor(topAlert.severity);
    final sevContainer = _getSeverityContainer(isDark, topAlert.severity);

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: sevContainer,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: sevColor.withValues(alpha: 0.7), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: sevColor.withValues(alpha: 0.20),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: sevColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getSeverityIcon(topAlert.severity),
                  color: sevColor,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: sevColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          topAlert.severity.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          topAlert.category,
                          style: TextStyle(
                            color: sevColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    topAlert.headline,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    topAlert.description,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.alerts.length > 1) ...[
                    const SizedBox(height: 6),
                    Text(
                      '+${widget.alerts.length - 1} more active alert${widget.alerts.length > 2 ? 's' : ''}',
                      style: TextStyle(
                        color: sevColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
