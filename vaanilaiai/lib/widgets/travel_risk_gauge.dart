import 'package:flutter/material.dart';
import '../models/advisory_model.dart';
import '../theme/app_colors.dart';

class TravelRiskGauge extends StatelessWidget {
  final TravelAdvisoryModel advisory;

  const TravelRiskGauge({super.key, required this.advisory});

  Color _getRiskColor(int score) {
    if (score < 30) return AppColors.alertGreen;
    if (score < 60) return AppColors.alertOrange;
    return AppColors.alertRed;
  }

  @override
  Widget build(BuildContext context) {
    final riskColor = _getRiskColor(advisory.travelRiskScore);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.directions_car_rounded, color: AppColors.aiCyan, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Travel Safety Index',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: riskColor, width: 1),
                ),
                child: Text(
                  advisory.overallSuitability.toUpperCase(),
                  style: TextStyle(
                    color: riskColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '${advisory.travelRiskScore}',
                style: TextStyle(
                  color: riskColor,
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
              const Text(
                ' / 100 Risk Score',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.remove_red_eye_outlined, 'Visibility', advisory.visibilityCondition),
          const SizedBox(height: 6),
          _buildDetailRow(Icons.alt_route_rounded, 'Road Surface', advisory.roadSafetyCondition),
          const SizedBox(height: 6),
          _buildDetailRow(Icons.air_rounded, 'Wind Conditions', advisory.windHazardLevel),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textTertiary, size: 14),
        const SizedBox(width: 6),
        Text(
          '$title: ',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
