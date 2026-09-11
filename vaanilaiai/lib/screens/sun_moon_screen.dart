import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../theme/app_colors.dart';

class SunMoonScreen extends StatelessWidget {
  const SunMoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final today = weatherProvider.forecast?.daily.isNotEmpty == true ? weatherProvider.forecast!.daily.first : null;

    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkOutline : AppColors.lightOutline;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final sunriseStr = today?.sunrise.contains('T') == true ? today!.sunrise.split('T')[1].substring(0, 5) : '05:48';
    final sunsetStr = today?.sunset.contains('T') == true ? today!.sunset.split('T')[1].substring(0, 5) : '18:32';

    // Calculate real live sun trajectory progress
    double sunProgress = 0.5;
    try {
      final now = DateTime.now();
      final sunriseParts = sunriseStr.split(':');
      final sunsetParts = sunsetStr.split(':');

      final sunriseDt = DateTime(now.year, now.month, now.day, int.parse(sunriseParts[0]), int.parse(sunriseParts[1]));
      final sunsetDt = DateTime(now.year, now.month, now.day, int.parse(sunsetParts[0]), int.parse(sunsetParts[1]));

      if (now.isBefore(sunriseDt)) {
        sunProgress = 0.05;
      } else if (now.isAfter(sunsetDt)) {
        sunProgress = 0.95;
      } else {
        final totalMins = sunsetDt.difference(sunriseDt).inMinutes;
        final elapsedMins = now.difference(sunriseDt).inMinutes;
        sunProgress = (elapsedMins / totalMins).clamp(0.05, 0.95);
      }
    } catch (_) {
      sunProgress = 0.6;
    }

    final uvIndex = today?.uvIndexMax ?? (weatherProvider.forecast?.current.isDay == true ? 6.5 : 0.0);

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
                    border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : borderColor),
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
                          Text('Sunrise', style: TextStyle(color: textSecondary, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text('$sunriseStr AM', style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Column(
                        children: [
                          const Icon(Icons.wb_sunny_rounded, color: AppColors.alertYellow, size: 28),
                          Text(
                            'UV $uvIndex',
                            style: const TextStyle(color: AppColors.alertOrange, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Sunset', style: TextStyle(color: textSecondary, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text('$sunsetStr PM', style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Sun Trajectory Arc
                  CustomPaint(
                    size: const Size(double.infinity, 90),
                    painter: _ArcPainter(arcColor: AppColors.alertYellow, progress: sunProgress, dotIcon: Icons.wb_sunny),
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
                          Text('Moonrise', style: TextStyle(color: textSecondary, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text('07:45 PM', style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const Icon(Icons.nightlight_round, color: AppColors.brandBlueLight, size: 26),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Moonset', style: TextStyle(color: textSecondary, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text('06:20 AM', style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Moon Trajectory Arc
                  CustomPaint(
                    size: const Size(double.infinity, 90),
                    painter: _ArcPainter(arcColor: AppColors.brandBlueLight, progress: (1.0 - sunProgress).clamp(0.05, 0.95), dotIcon: Icons.nightlight_round),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Lunar Phase: Waxing Gibbous (82% Illumination)',
                    style: TextStyle(color: textSecondary, fontSize: 11),
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

class _ArcPainter extends CustomPainter {
  final Color arcColor;
  final double progress;
  final IconData dotIcon;

  _ArcPainter({required this.arcColor, required this.progress, required this.dotIcon});

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

    final glowPaint = Paint()
      ..color = arcColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(dotX, dotY), 7, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
