import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../theme/app_colors.dart';

class WeatherHeroCard extends StatefulWidget {
  final WeatherForecastModel forecast;
  final VoidCallback? onLocationTap;

  const WeatherHeroCard({
    super.key,
    required this.forecast,
    this.onLocationTap,
  });

  @override
  State<WeatherHeroCard> createState() => _WeatherHeroCardState();
}

class _WeatherHeroCardState extends State<WeatherHeroCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _enterController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnim = CurvedAnimation(parent: _enterController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _enterController, curve: Curves.easeOut));
    _enterController.forward();
  }

  @override
  void dispose() {
    _enterController.dispose();
    super.dispose();
  }

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
      case 'fog':
        return Icons.foggy;
      case 'drizzle':
      case 'rain_light':
        return Icons.water_drop_outlined;
      case 'rain_moderate':
      case 'rain_heavy':
      case 'showers':
      case 'showers_heavy':
        return Icons.grain_rounded;
      case 'thunderstorm':
      case 'thunderstorm_hail':
        return Icons.thunderstorm_rounded;
      case 'snow':
        return Icons.ac_unit_rounded;
      default:
        return Icons.wb_cloudy_rounded;
    }
  }

  /// Returns a semantically meaningful icon color based on weather condition
  Color _getWeatherIconColor(String iconKey, bool isDay) {
    final key = iconKey.toLowerCase();
    if (key.contains('sunny') || key == 'mostly_sunny') {
      return isDay ? AppColors.weatherSunny : AppColors.weatherRain;
    }
    if (key == 'partly_cloudy') {
      return isDay ? AppColors.weatherSunny.withValues(alpha: 0.8) : AppColors.weatherCloudy;
    }
    if (key.contains('cloudy') || key == 'overcast') {
      return AppColors.weatherCloudy;
    }
    if (key == 'fog') return AppColors.weatherFog;
    if (key.contains('drizzle') || key.contains('rain_light')) {
      return AppColors.weatherRain.withValues(alpha: 0.85);
    }
    if (key.contains('rain') || key.contains('showers')) {
      return AppColors.weatherRain;
    }
    if (key.contains('thunderstorm')) return AppColors.weatherStorm;
    if (key.contains('snow')) return AppColors.weatherSnow;
    return AppColors.brandBlue;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final curr = widget.forecast.current;
    final today =
        widget.forecast.daily.isNotEmpty ? widget.forecast.daily.first : null;

    final cardBg = AppColors.surface(isDark);
    final borderColor = AppColors.border(isDark);
    final textPrimary = AppColors.textPrimaryC(isDark);
    final textSecondary = AppColors.textSecondaryC(isDark);
    final pillBg = isDark
        ? const Color(0xFF1B273A).withValues(alpha: 0.75)
        : AppColors.lightSurfaceHighlight;

    final iconColor = _getWeatherIconColor(curr.conditionIcon, curr.isDay);
    final atmosphericGlow = AppColors.atmosphericGlow(curr.conditionIcon, curr.isDay);

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: cardBg,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      atmosphericGlow.withValues(alpha: 0.16),
                      const Color(0xFF131C2D).withValues(alpha: 0.96),
                      const Color(0xFF0F172A),
                    ]
                  : [
                      atmosphericGlow.withValues(alpha: 0.10),
                      Colors.white,
                      const Color(0xFFF8FAFC),
                    ],
              stops: const [0.0, 0.45, 1.0],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.14)
                  : atmosphericGlow.withValues(alpha: 0.22),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: atmosphericGlow.withValues(alpha: isDark ? 0.16 : 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: widget.onLocationTap,
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              color: AppColors.brandBlue, size: 18),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.forecast.district != null
                                      ? '${widget.forecast.locationName}, ${widget.forecast.district}'
                                      : widget.forecast.locationName,
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.near_me_outlined,
                                        size: 11, color: AppColors.brandBlue),
                                    const SizedBox(width: 3),
                                    Flexible(
                                      child: Text(
                                        'Live • Updated now',
                                        style: TextStyle(
                                            color: textSecondary, fontSize: 11),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down_rounded,
                              color: textSecondary, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Source Provenance Badge with Glowing Beacon
                  Container(
                    constraints: const BoxConstraints(maxWidth: 130),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: pillBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : borderColor,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: AppColors.alertGreen,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.alertGreen.withValues(alpha: 0.6),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            (curr.provenance.modelResolution ?? '2.5km Grid')
                                .replaceAll('High-Resolution Grid', 'Grid'),
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Big Temperature & Weather Icon
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${curr.temperature.round()}°',
                          style: TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                            height: 1.0,
                            letterSpacing: -3.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          curr.conditionText,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Feels like ${curr.feelsLike.round()}°',
                          style: TextStyle(
                            fontSize: 13,
                            color: textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        if (today != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'H: ${today.tempMax.round()}°',
                                style: TextStyle(
                                  color: AppColors.alertOrange,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'L: ${today.tempMin.round()}°',
                                style: TextStyle(
                                  color: AppColors.weatherRain,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Contextual weather icon with gradient bg
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          iconColor.withValues(alpha: 0.18),
                          iconColor.withValues(alpha: 0.04),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getWeatherIcon(curr.conditionIcon),
                      size: 52,
                      color: iconColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 3-Pill Metrics Row
              Row(
                children: [
                  Expanded(
                    child: _buildMetricPill(
                      icon: Icons.water_drop_outlined,
                      iconColor: AppColors.weatherRain,
                      label: 'Humidity',
                      value: '${curr.humidity}%',
                      bgColor: pillBg,
                      borderColor: borderColor,
                      textColor: textPrimary,
                      subTextColor: textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricPill(
                      icon: Icons.air_rounded,
                      iconColor: AppColors.weatherCloudy,
                      label: 'Wind',
                      value: '${curr.windSpeed.round()} km/h',
                      bgColor: pillBg,
                      borderColor: borderColor,
                      textColor: textPrimary,
                      subTextColor: textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricPill(
                      icon: Icons.eco_outlined,
                      iconColor: AppColors.alertGreen,
                      label: 'AQI',
                      value: '${widget.forecast.airQuality?.aqi ?? 28}',
                      valueLabel: widget.forecast.airQuality?.category ?? 'Good',
                      valueLabelColor: AppColors.alertGreen,
                      bgColor: pillBg,
                      borderColor: borderColor,
                      textColor: textPrimary,
                      subTextColor: textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricPill({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    String? valueLabel,
    Color? valueLabelColor,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 13),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (valueLabel != null) ...[
            Text(
              valueLabel,
              style: TextStyle(
                color: valueLabelColor ?? subTextColor,
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ],
      ),
    );
  }
}
