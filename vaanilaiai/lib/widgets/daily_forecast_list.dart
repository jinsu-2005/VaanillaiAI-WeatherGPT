import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import '../theme/app_colors.dart';

class DailyForecastList extends StatelessWidget {
  final List<DailyForecastModel> daily;

  const DailyForecastList({super.key, required this.daily});

  IconData _getWeatherIcon(String iconKey) {
    switch (iconKey.toLowerCase()) {
      case 'sunny':
      case 'mostly_sunny':
        return Icons.wb_sunny_rounded;
      case 'partly_cloudy':
        return Icons.cloud_queue_rounded;
      case 'cloudy':
      case 'overcast':
        return Icons.cloud_rounded;
      case 'rain_light':
      case 'rain_moderate':
      case 'drizzle':
        return Icons.water_drop_outlined;
      case 'rain_heavy':
      case 'showers':
        return Icons.grain_rounded;
      case 'thunderstorm':
        return Icons.thunderstorm_rounded;
      default:
        return Icons.wb_cloudy_rounded;
    }
  }

  Color _getWeatherIconColor(String iconKey) {
    final key = iconKey.toLowerCase();
    if (key.contains('sunny') || key == 'mostly_sunny') {
      return AppColors.weatherSunny;
    }
    if (key == 'partly_cloudy') return AppColors.weatherSunny.withValues(alpha: 0.75);
    if (key.contains('cloudy') || key == 'overcast') return AppColors.weatherCloudy;
    if (key.contains('drizzle') || key.contains('rain_light')) {
      return AppColors.weatherRain.withValues(alpha: 0.8);
    }
    if (key.contains('rain') || key.contains('showers')) return AppColors.weatherRain;
    if (key.contains('thunderstorm')) return AppColors.weatherStorm;
    return AppColors.weatherCloudy;
  }

  String _formatDay(String dateStr, int index) {
    if (index == 0) return 'Today';
    if (index == 1) return 'Tomorrow';
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('EEE d').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppColors.surface(isDark);
    final borderColor = AppColors.border(isDark);
    final textPrimary = AppColors.textPrimaryC(isDark);
    final textSecondary = AppColors.textSecondaryC(isDark);

    // Compute global min/max for relative range bar
    double globalMin = daily.fold(99.0, (p, d) => d.tempMin < p ? d.tempMin : p);
    double globalMax = daily.fold(-99.0, (p, d) => d.tempMax > p ? d.tempMax : p);
    final tempRange = (globalMax - globalMin).clamp(1.0, 999.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.12) : borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month_rounded,
                  color: AppColors.brandBlue, size: 16),
              const SizedBox(width: 6),
              Text(
                '7-Day Forecast',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                'IMD • NWP',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daily.length,
            separatorBuilder: (context, index) =>
                Divider(color: borderColor.withValues(alpha: 0.6), height: 16, thickness: 0.8),
            itemBuilder: (context, index) {
              final day = daily[index];
              final iconColor = _getWeatherIconColor(day.conditionIcon);
              final startFraction =
                  (day.tempMin - globalMin) / tempRange;
              final widthFraction =
                  (day.tempMax - day.tempMin) / tempRange;

              return Row(
                children: [
                  // Day label
                  SizedBox(
                    width: 68,
                    child: Text(
                      _formatDay(day.date, index),
                      style: TextStyle(
                        color: index == 0 ? textPrimary : textSecondary,
                        fontSize: 13,
                        fontWeight: index == 0
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  // Weather icon
                  Icon(
                    _getWeatherIcon(day.conditionIcon),
                    color: iconColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  // Min temp
                  SizedBox(
                    width: 26,
                    child: Text(
                      '${day.tempMin.round()}°',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Temperature range bar
                  Expanded(
                    child: LayoutBuilder(builder: (context, constraints) {
                      final totalWidth = constraints.maxWidth;
                      return Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          // Track
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: borderColor.withValues(alpha: isDark ? 0.6 : 0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          // Fill with multi-color weather gradient
                          Padding(
                            padding: EdgeInsets.only(
                                left: (totalWidth * startFraction).clamp(0.0, totalWidth - 10)),
                            child: Container(
                              height: 6,
                              width: (totalWidth * widthFraction).clamp(
                                  10.0, totalWidth),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF38BDF8),
                                    Color(0xFFF59E0B),
                                    Color(0xFFEF4444),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  const SizedBox(width: 8),
                  // Max temp
                  SizedBox(
                    width: 26,
                    child: Text(
                      '${day.tempMax.round()}°',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
