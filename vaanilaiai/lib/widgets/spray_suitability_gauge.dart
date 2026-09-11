import 'package:flutter/material.dart';
import '../models/advisory_model.dart';
import '../theme/app_colors.dart';

class SpraySuitabilityGauge extends StatelessWidget {
  final AgricultureAdvisoryModel advisory;

  const SpraySuitabilityGauge({super.key, required this.advisory});

  Color _getStatusColor(String suitability) {
    switch (suitability.toLowerCase()) {
      case 'favorable':
        return AppColors.alertGreen;
      case 'risky':
        return AppColors.alertOrange;
      default:
        return AppColors.alertRed;
    }
  }

  IconData _getStatusIcon(String suitability) {
    switch (suitability.toLowerCase()) {
      case 'favorable':
        return Icons.check_circle_rounded;
      case 'risky':
        return Icons.warning_amber_rounded;
      default:
        return Icons.cancel_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = AppColors.surface(isDark);
    final borderColor = AppColors.border(isDark);
    final textPrimary = AppColors.textPrimaryC(isDark);
    final textSecondary = AppColors.textSecondaryC(isDark);
    final statusColor = _getStatusColor(advisory.sprayingSuitability);
    final accentBlue = isDark ? AppColors.brandBlueLight : AppColors.brandBlue;
    final pillBg = isDark ? AppColors.darkSurfaceHighlight : AppColors.brandBlueContainer;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getStatusIcon(advisory.sprayingSuitability),
                  color: statusColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pesticide Spraying Window',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    advisory.sprayingSuitability.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            advisory.sprayingReason,
            style: TextStyle(
              color: textPrimary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          if (advisory.suitableSprayingHours.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'Best Spraying Hours Today',
              style: TextStyle(
                color: accentBlue,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: advisory.suitableSprayingHours.map((hour) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: pillBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: accentBlue.withValues(alpha: 0.35), width: 1),
                  ),
                  child: Text(
                    hour,
                    style: TextStyle(
                      color: accentBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
