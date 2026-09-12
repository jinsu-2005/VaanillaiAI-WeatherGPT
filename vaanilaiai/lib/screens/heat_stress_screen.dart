import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../theme/app_colors.dart';
import '../utils/heat_stress_calculator.dart';
import '../widgets/data_source_indicator.dart';

class HeatStressScreen extends StatelessWidget {
  const HeatStressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final forecast = weatherProvider.forecast;

    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkOutline : AppColors.lightOutline;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    if (forecast == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Heat Stress & Wet-Bulb'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.whatshot_rounded, size: 48, color: AppColors.alertOrange),
                const SizedBox(height: 16),
                const Text(
                  'Thermal Data Unavailable',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Could not retrieve ambient telemetry for ${weatherProvider.locationName}.',
                  style: TextStyle(color: textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => weatherProvider.fetchWeather(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final curr = forecast.current;
    final heatData = HeatStressCalculator.calculate(
      temperatureC: curr.temperature,
      humidityPercent: curr.humidity,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Heat Stress & Wet-Bulb'),
      ),
      body: RefreshIndicator(
        onRefresh: () => weatherProvider.fetchWeather(),
        color: AppColors.brandBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Provenance Indicator
              DataSourceIndicator(
                lastUpdated: forecast.lastFetchedAt,
                dataSource: forecast.dataSource,
                onRefresh: () => weatherProvider.fetchWeather(),
              ),
              const SizedBox(height: 14),

              // Main Heat Stress Banner Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: heatData.color.withValues(alpha: 0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: heatData.color.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: heatData.color.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.whatshot_rounded, color: heatData.color, size: 22),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'THERMAL STRESS LEVEL',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: heatData.color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            heatData.categoryName.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Metrics Dual Gauges
                    Row(
                      children: [
                        // Heat Index
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E283D) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'HEAT INDEX',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '${heatData.heatIndex.round()}',
                                      style: TextStyle(
                                        fontSize: 34,
                                        fontWeight: FontWeight.w800,
                                        color: heatData.color,
                                      ),
                                    ),
                                    Text('°C', style: TextStyle(fontSize: 16, color: textSecondary)),
                                  ],
                                ),
                                Text(
                                  'Ambient: ${curr.temperature.round()}°C • Feels like: ${curr.feelsLike.round()}°C',
                                  style: TextStyle(fontSize: 10.5, color: textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Wet-Bulb Temperature
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E283D) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'WET-BULB TEMP',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      heatData.wetBulbTemperature.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 34,
                                        fontWeight: FontWeight.w800,
                                        color: textPrimary,
                                      ),
                                    ),
                                    Text('°C', style: TextStyle(fontSize: 16, color: textSecondary)),
                                  ],
                                ),
                                Text(
                                  'Rel. Humidity: ${curr.humidity}%',
                                  style: TextStyle(fontSize: 10.5, color: textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Advisory text
                    Text(
                      heatData.advisory,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Farm & Outdoor Labor Safety Directive Card
              Container(
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
                      children: [
                        const Icon(Icons.engineering_rounded, color: AppColors.brandBlue, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'FIELD & LABOR SAFETY DIRECTIVES',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Work-Rest Cycle
                    _buildGuidanceTile(
                      icon: Icons.timer_outlined,
                      title: 'Work / Rest Interval',
                      detail: heatData.workRestGuidance,
                      isDark: isDark,
                      borderColor: borderColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 10),

                    // Hydration
                    _buildGuidanceTile(
                      icon: Icons.local_drink_outlined,
                      title: 'Hourly Hydration Target',
                      detail: heatData.hydrationGuidance,
                      isDark: isDark,
                      borderColor: borderColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Hourly Heat Stress Forecast
              if (forecast.hourly.isNotEmpty) ...[
                _buildHourlyHeatTimeline(
                  hourly: forecast.hourly,
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  isDark: isDark,
                ),
                const SizedBox(height: 18),
              ],

              // Heat Illness Guide
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HEAT ILLNESS FIRST-AID PROTOCOL',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Heat Exhaustion',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFFF9100),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '• Heavy sweating & dizziness\n• Cold, clammy skin\n• Muscle cramps\n→ Move to shade, loosen clothes, sip cool water.',
                                style: TextStyle(fontSize: 11, height: 1.4, color: textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Heat Stroke (Critical)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFFF1744),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '• Hot, red, dry skin (no sweat)\n• Rapid pulse & confusion\n• Temp > 39.5°C\n→ Call 108 / 112 immediately. Sponge with cold water.',
                                style: TextStyle(fontSize: 11, height: 1.4, color: textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuidanceTile({
    required IconData icon,
    required String title,
    required String detail,
    required bool isDark,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF192338) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.brandBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: TextStyle(fontSize: 12.5, height: 1.3, fontWeight: FontWeight.w600, color: textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyHeatTimeline({
    required List hourly,
    required Color surfaceColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
  }) {
    final slice = hourly.take(24).toList();

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
                'HOURLY HEAT STRESS OUTLOOK (24H)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: textSecondary,
                ),
              ),
              Text(
                'Heat Index • Risk',
                style: TextStyle(fontSize: 11, color: textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 105,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: slice.length,
              itemBuilder: (context, index) {
                final h = slice[index];
                final heat = HeatStressCalculator.calculate(
                  temperatureC: h.temperature,
                  humidityPercent: h.humidity,
                );

                String hourLabel;
                try {
                  final dt = DateTime.parse(h.time);
                  hourLabel = DateFormat('h a').format(dt);
                } catch (_) {
                  hourLabel = h.time;
                }

                return Container(
                  width: 74,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E283D) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: heat.category != HeatStressCategory.low
                          ? heat.color.withValues(alpha: 0.6)
                          : borderColor,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        hourLabel,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textSecondary),
                      ),
                      Text(
                        '${heat.heatIndex.round()}°C',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: heat.color,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: heat.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          heat.categoryName,
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: heat.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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
