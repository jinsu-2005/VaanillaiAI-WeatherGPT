import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../theme/app_colors.dart';

class RainfallHistoryScreen extends StatelessWidget {
  const RainfallHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weatherProvider = Provider.of<WeatherProvider>(context);

    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkOutline : AppColors.lightOutline;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final daily = weatherProvider.forecast?.daily ?? [];
    double totalRain = 0;
    double maxRain = 5.0;

    for (final d in daily) {
      totalRain += d.precipitationSum;
      if (d.precipitationSum > maxRain) {
        maxRain = d.precipitationSum;
      }
    }

    final barGroups = <BarChartGroupData>[];
    final dayLabels = <String>[];

    for (int i = 0; i < daily.length && i < 7; i++) {
      final d = daily[i];
      try {
        final dt = DateTime.parse(d.date);
        dayLabels.add(DateFormat('E').format(dt));
      } catch (_) {
        dayLabels.add('D$i');
      }

      final rainVal = d.precipitationSum;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: rainVal > 0.2 ? rainVal : 0.4,
              color: rainVal > 0.2 ? AppColors.brandBlue : borderColor,
              width: 14,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    // Real Rain Probabilities
    final tomorrowProb = daily.length > 1 ? daily[1].precipitationProbabilityMax : 20;
    final dayAfterProb = daily.length > 2 ? daily[2].precipitationProbabilityMax : 15;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Precipitation & Rain History'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Precipitation Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Precipitation Outlook',
                        style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceHighlight : AppColors.lightSurfaceHighlight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor),
                        ),
                        child: Text('7-Day Window', style: TextStyle(color: textSecondary, fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        totalRain.toStringAsFixed(1),
                        style: TextStyle(fontSize: 42, fontWeight: FontWeight.w800, color: textPrimary, height: 1.0),
                      ),
                      const SizedBox(width: 4),
                      Text('mm', style: TextStyle(color: textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Text('Accumulated Forecasted Rainfall for ${weatherProvider.locationName}', style: TextStyle(color: textSecondary, fontSize: 12)),

                  const SizedBox(height: 24),

                  // Weekly Bar Chart with live values
                  if (barGroups.isNotEmpty) ...[
                    SizedBox(
                      height: 150,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: (maxRain * 1.25).clamp(5.0, 100.0),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (val, meta) {
                                  final idx = val.toInt();
                                  if (idx >= 0 && idx < dayLabels.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(dayLabels[idx], style: TextStyle(color: textSecondary, fontSize: 11)),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: barGroups,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  Divider(color: borderColor),
                  const SizedBox(height: 10),

                  // Rain Probability row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Rain Probability', style: TextStyle(color: textSecondary, fontSize: 12)),
                          const SizedBox(height: 2),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(text: '$tomorrowProb% ', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                                TextSpan(text: 'Tomorrow', style: TextStyle(color: textSecondary, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Upcoming Outlook', style: TextStyle(color: textSecondary, fontSize: 12)),
                          const SizedBox(height: 2),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(text: '$dayAfterProb% ', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                                TextSpan(text: 'Day After', style: TextStyle(color: textSecondary, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
