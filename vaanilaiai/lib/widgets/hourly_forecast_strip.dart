import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../theme/app_colors.dart';

class HourlyForecastStrip extends StatelessWidget {
  final List<HourlyForecastModel> hourly;

  const HourlyForecastStrip({super.key, required this.hourly});

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

  Color _getWeatherIconColor(String iconKey, bool isDay) {
    final key = iconKey.toLowerCase();
    if (key.contains('sunny') || key == 'mostly_sunny') {
      return isDay ? AppColors.weatherSunny : AppColors.brandBlueLight;
    }
    if (key == 'partly_cloudy') {
      return isDay ? AppColors.weatherSunny.withValues(alpha: 0.8) : AppColors.weatherCloudy;
    }
    if (key.contains('cloudy') || key == 'overcast') return AppColors.weatherCloudy;
    if (key.contains('drizzle') || key.contains('rain_light')) {
      return AppColors.weatherRain.withValues(alpha: 0.8);
    }
    if (key.contains('rain') || key.contains('showers')) return AppColors.weatherRain;
    if (key.contains('thunderstorm')) return AppColors.weatherStorm;
    return AppColors.weatherCloudy;
  }

  String _formatTime(String timeStr) {
    try {
      final dt = DateTime.parse(timeStr);
      final hour = dt.hour;
      final period = hour >= 12 ? 'PM' : 'AM';
      final formattedHour = hour % 12 == 0 ? 12 : hour % 12;
      return '$formattedHour $period';
    } catch (_) {
      return timeStr.contains('T') ? timeStr.split('T')[1] : timeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppColors.surface(isDark);
    final borderColor = AppColors.border(isDark);
    final textPrimary = AppColors.textPrimaryC(isDark);
    final textSecondary = AppColors.textSecondaryC(isDark);
    final itemBg = AppColors.surfaceHL(isDark);

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
              Icon(Icons.schedule_rounded,
                  color: AppColors.brandBlue, size: 16),
              const SizedBox(width: 6),
              Text(
                'Hourly Forecast',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '48-hour',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 116,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: hourly.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = hourly[index];
                final isNow = index == 0;
                final iconColor =
                    _getWeatherIconColor(item.conditionIcon, item.isDay);
                final precipProb = item.precipitationProbability;
                final hasPrecip = precipProb >= 20;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 64,
                  padding:
                      const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
                  decoration: BoxDecoration(
                    color: isNow
                        ? AppColors.brandBlue.withValues(alpha: isDark ? 0.20 : 0.12)
                        : itemBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isNow ? AppColors.brandBlue : borderColor,
                      width: isNow ? 1.5 : 0.8,
                    ),
                    boxShadow: isNow
                        ? [
                            BoxShadow(
                              color: AppColors.brandBlue.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        isNow ? 'Now' : _formatTime(item.time),
                        style: TextStyle(
                          color: isNow ? AppColors.brandBlue : textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Icon(
                        _getWeatherIcon(item.conditionIcon),
                        color: iconColor,
                        size: 22,
                      ),
                      Text(
                        '${item.temperature.round()}°',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      // Rain probability pill
                      if (hasPrecip)
                        Text(
                          '$precipProb%',
                          style: TextStyle(
                            color: AppColors.weatherRain,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      else
                        const SizedBox(height: 12),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
