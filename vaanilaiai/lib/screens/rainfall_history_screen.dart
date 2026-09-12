import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../providers/weather_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/data_source_indicator.dart';

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

    final forecast = weatherProvider.forecast;
    final daily = forecast?.daily ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Precipitation & Rain History'),
      ),
      body: weatherProvider.isLoading && forecast == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.brandBlue),
            )
          : (forecast == null || daily.isEmpty)
              ? _buildUnavailableState(context, weatherProvider)
              : RefreshIndicator(
                  onRefresh: () => weatherProvider.fetchWeather(),
                  color: AppColors.brandBlue,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Data provenance badge
                        Align(
                          alignment: Alignment.centerLeft,
                          child: DataSourceIndicator(
                            lastUpdated: forecast.lastFetchedAt,
                            dataSource: forecast.dataSource,
                            onRefresh: () => weatherProvider.fetchWeather(),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Precipitation Outlook Card
                        _buildOutlookCard(
                          context: context,
                          daily: daily,
                          locationName: weatherProvider.locationName,
                          surfaceColor: surfaceColor,
                          borderColor: borderColor,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 20),

                        // Daily Precipitation Breakdown
                        _buildDailyBreakdown(
                          daily: daily,
                          surfaceColor: surfaceColor,
                          borderColor: borderColor,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildUnavailableState(BuildContext context, WeatherProvider weather) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161E31) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.darkOutline : AppColors.lightOutline,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.brandBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.water_drop_outlined,
                  size: 40,
                  color: AppColors.brandBlue,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Precipitation Forecast Unavailable',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Precipitation data for ${weather.locationName} could not be retrieved. Check network connectivity or refresh.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => weather.fetchWeather(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Refresh Forecast'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.brandBlue,
                  side: const BorderSide(color: AppColors.brandBlue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutlookCard({
    required BuildContext context,
    required List<DailyForecastModel> daily,
    required String locationName,
    required Color surfaceColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
  }) {
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

    final tomorrowProb = daily.length > 1 ? '${daily[1].precipitationProbabilityMax}%' : '--';
    final dayAfterProb = daily.length > 2 ? '${daily[2].precipitationProbabilityMax}%' : '--';

    return Container(
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
          Text(
            'Accumulated Forecasted Rainfall for $locationName',
            style: TextStyle(color: textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 24),

          // Weekly Bar Chart
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
                        TextSpan(text: '$tomorrowProb ', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
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
                        TextSpan(text: '$dayAfterProb ', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
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
    );
  }

  Widget _buildDailyBreakdown({
    required List<DailyForecastModel> daily,
    required Color surfaceColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
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
                'DAILY PRECIPITATION BREAKDOWN',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: textSecondary,
                ),
              ),
              Text(
                'Prob • Volume',
                style: TextStyle(
                  fontSize: 11,
                  color: textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daily.length > 7 ? 7 : daily.length,
            separatorBuilder: (_, __) => Divider(color: borderColor.withValues(alpha: 0.5), height: 16),
            itemBuilder: (context, index) {
              final d = daily[index];
              String dayName;
              String dateFormatted;
              try {
                final dt = DateTime.parse(d.date);
                final now = DateTime.now();
                if (index == 0 && dt.day == now.day) {
                  dayName = 'Today';
                } else if (index == 1) {
                  dayName = 'Tomorrow';
                } else {
                  dayName = DateFormat('EEEE').format(dt);
                }
                dateFormatted = DateFormat('MMM d').format(dt);
              } catch (_) {
                dayName = 'Day ${index + 1}';
                dateFormatted = d.date;
              }

              final hasRain = d.precipitationSum > 0.1;

              return Row(
                children: [
                  // Icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: hasRain
                          ? AppColors.brandBlue.withValues(alpha: 0.15)
                          : (isDark ? const Color(0xFF222B45) : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      hasRain ? Icons.water_drop_rounded : Icons.wb_sunny_rounded,
                      color: hasRain ? AppColors.brandBlue : Colors.amber,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Day & Condition
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$dayName • $dateFormatted',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          d.conditionText.isNotEmpty ? d.conditionText : (hasRain ? 'Rain expected' : 'Dry conditions'),
                          style: TextStyle(
                            fontSize: 11,
                            color: textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Probability and sum
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.umbrella_rounded,
                            size: 13,
                            color: d.precipitationProbabilityMax > 50
                                ? AppColors.brandBlue
                                : textSecondary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${d.precipitationProbabilityMax}%',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: d.precipitationProbabilityMax > 50
                                  ? AppColors.brandBlue
                                  : textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${d.precipitationSum.toStringAsFixed(1)} mm',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: hasRain ? AppColors.brandBlueLight : textSecondary,
                        ),
                      ),
                    ],
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
