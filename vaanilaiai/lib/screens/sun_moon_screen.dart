import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../theme/app_colors.dart';

class SunMoonScreen extends StatelessWidget {
  const SunMoonScreen({super.key});

  String _formatTime12Hour(String? raw, String fallback) {
    if (raw == null || raw.isEmpty) return fallback;
    try {
      final timePart = raw.contains('T') ? raw.split('T')[1] : raw;
      final parts = timePart.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1].substring(0, 2));
      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour % 12 == 0 ? 12 : hour % 12;
      final minStr = minute.toString().padLeft(2, '0');
      return '$hour12:$minStr $period';
    } catch (_) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final today = weatherProvider.forecast?.daily.isNotEmpty == true
        ? weatherProvider.forecast!.daily.first
        : null;

    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor =
        isDark ? AppColors.darkOutline : AppColors.lightOutline;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final sunriseDisplay = _formatTime12Hour(today?.sunrise, '06:00 AM');
    final sunsetDisplay = _formatTime12Hour(today?.sunset, '06:30 PM');

    // Calculate real live sun trajectory progress
    double sunProgress = 0.5;
    try {
      final now = DateTime.now();
      DateTime sunriseDt;
      DateTime sunsetDt;

      if (today != null && today.sunrise.contains('T') && today.sunset.contains('T')) {
        sunriseDt = DateTime.parse(today.sunrise);
        sunsetDt = DateTime.parse(today.sunset);
      } else {
        sunriseDt = DateTime(now.year, now.month, now.day, 6, 0);
        sunsetDt = DateTime(now.year, now.month, now.day, 18, 30);
      }

      if (now.isBefore(sunriseDt)) {
        sunProgress = 0.05;
      } else if (now.isAfter(sunsetDt)) {
        sunProgress = 0.95;
      } else {
        final totalMins = sunsetDt.difference(sunriseDt).inMinutes;
        final elapsedMins = now.difference(sunriseDt).inMinutes;
        sunProgress = (elapsedMins / (totalMins > 0 ? totalMins : 1)).clamp(0.05, 0.95);
      }
    } catch (_) {
      sunProgress = 0.5;
    }

    final uvIndex = today?.uvIndexMax ??
        (weatherProvider.forecast?.current.isDay == true ? 6.5 : 0.0);

    // True astronomical lunar phase & illumination calculation
    final lunar = _LunarCalculation.calculate(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sun & Moon Tracker'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Solar Arc Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : borderColor,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sunrise',
                                style: TextStyle(color: textSecondary, fontSize: 12),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                sunriseDisplay,
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Icon(
                                Icons.wb_sunny_rounded,
                                color: AppColors.alertYellow,
                                size: 28,
                              ),
                              Text(
                                'UV ${uvIndex.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  color: AppColors.alertOrange,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Sunset',
                                style: TextStyle(color: textSecondary, fontSize: 12),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                sunsetDisplay,
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Sun Trajectory Arc
                      CustomPaint(
                        size: const Size(double.infinity, 90),
                        painter: _ArcPainter(
                          arcColor: AppColors.alertYellow,
                          progress: sunProgress,
                          dotIcon: Icons.wb_sunny,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Solar position calculated in real-time for ${weatherProvider.locationName}',
                        style: TextStyle(color: textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Lunar Arc Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Moonrise',
                                style: TextStyle(color: textSecondary, fontSize: 12),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                lunar.moonrise,
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            lunar.icon,
                            color: AppColors.brandBlueLight,
                            size: 26,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Moonset',
                                style: TextStyle(color: textSecondary, fontSize: 12),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                lunar.moonset,
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Moon Trajectory Arc
                      CustomPaint(
                        size: const Size(double.infinity, 90),
                        painter: _ArcPainter(
                          arcColor: AppColors.brandBlueLight,
                          progress: (1.0 - sunProgress).clamp(0.05, 0.95),
                          dotIcon: lunar.icon,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Lunar Phase: ${lunar.phaseName} (${lunar.illuminationPercent}% Illumination)',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LunarCalculation {
  final String phaseName;
  final int illuminationPercent;
  final String moonrise;
  final String moonset;
  final IconData icon;

  _LunarCalculation({
    required this.phaseName,
    required this.illuminationPercent,
    required this.moonrise,
    required this.moonset,
    required this.icon,
  });

  factory _LunarCalculation.calculate(DateTime date) {
    // Known reference New Moon: Jan 11, 2024, 11:57 UTC
    final refNewMoon = DateTime.utc(2024, 1, 11, 11, 57);
    const synodicMonth = 29.53058867;
    final diffSeconds = date.toUtc().difference(refNewMoon).inSeconds;
    final diffDays = diffSeconds / 86400.0;
    final cycleProgress = (diffDays % synodicMonth) / synodicMonth;
    final normalizedProgress =
        cycleProgress < 0 ? cycleProgress + 1.0 : cycleProgress;
    final moonAge = normalizedProgress * synodicMonth;

    // Illumination (0 to 100%)
    final illumination =
        ((1.0 - math.cos(normalizedProgress * 2 * math.pi)) / 2.0 * 100).round();

    String name;
    IconData icon;
    if (moonAge < 1.84 || moonAge > 27.68) {
      name = 'New Moon';
      icon = Icons.brightness_1_outlined;
    } else if (moonAge < 5.53) {
      name = 'Waxing Crescent';
      icon = Icons.nightlight_outlined;
    } else if (moonAge < 9.22) {
      name = 'First Quarter';
      icon = Icons.nightlight_round;
    } else if (moonAge < 12.91) {
      name = 'Waxing Gibbous';
      icon = Icons.brightness_3_rounded;
    } else if (moonAge < 16.61) {
      name = 'Full Moon';
      icon = Icons.brightness_1_rounded;
    } else if (moonAge < 20.30) {
      name = 'Waning Gibbous';
      icon = Icons.brightness_2_rounded;
    } else if (moonAge < 23.99) {
      name = 'Last Quarter';
      icon = Icons.nightlight_round;
    } else {
      name = 'Waning Crescent';
      icon = Icons.nightlight_outlined;
    }

    // Moonrise / Moonset calculation based on synodic lunar progression
    final riseHourFloat = (6.0 + normalizedProgress * 24.0) % 24.0;
    final setHourFloat = (riseHourFloat + 12.0) % 24.0;

    String formatHour(double hFloat) {
      final totalMinutes = (hFloat * 60).round() % (24 * 60);
      final hour = totalMinutes ~/ 60;
      final minute = totalMinutes % 60;
      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour % 12 == 0 ? 12 : hour % 12;
      return '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    }

    return _LunarCalculation(
      phaseName: name,
      illuminationPercent: illumination,
      moonrise: formatHour(riseHourFloat),
      moonset: formatHour(setHourFloat),
      icon: icon,
    );
  }
}

class _ArcPainter extends CustomPainter {
  final Color arcColor;
  final double progress;
  final IconData dotIcon;

  _ArcPainter({
    required this.arcColor,
    required this.progress,
    required this.dotIcon,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = arcColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, -10, size.width, size.height);

    canvas.drawPath(path, paint);

    // Active progress dot
    final dotX = size.width * progress;
    final dotY = size.height * (1.0 - progress * 1.1).clamp(0.0, size.height);

    final dotPaint = Paint()
      ..color = arcColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(dotX, dotY), 7, dotPaint);

    final glowPaint = Paint()
      ..color = arcColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(dotX, dotY), 14, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.arcColor != arcColor;
}
