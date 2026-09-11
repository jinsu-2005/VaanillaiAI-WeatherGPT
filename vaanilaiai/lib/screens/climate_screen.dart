import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/climate_provider.dart';
import '../providers/weather_provider.dart';
import '../providers/locale_provider.dart';
import '../theme/app_colors.dart';

class ClimateScreen extends StatefulWidget {
  const ClimateScreen({super.key});

  @override
  State<ClimateScreen> createState() => _ClimateScreenState();
}

class _ClimateScreenState extends State<ClimateScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final weather = Provider.of<WeatherProvider>(context, listen: false);
      Provider.of<ClimateProvider>(context, listen: false).fetchClimateData(
        latitude: weather.latitude,
        longitude: weather.longitude,
        locationName: weather.locationName,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final climateProvider = Provider.of<ClimateProvider>(context);
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    final surfaceColor = AppColors.surface(isDark);
    final borderColor = AppColors.border(isDark);
    final textPrimary = AppColors.textPrimaryC(isDark);
    final textSecondary = AppColors.textSecondaryC(isDark);
    final textTertiary = AppColors.textTertiaryC(isDark);
    final accentBlue = isDark ? AppColors.brandBlueLight : AppColors.brandBlue;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localeProvider.t('climate'),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            Text(
              'Historical Trends & Climate Intelligence',
              style: TextStyle(fontSize: 11, color: textTertiary),
            ),
          ],
        ),
      ),
      body: climateProvider.isLoading && climateProvider.comparison == null
          ? Center(child: SpinKitPulse(color: accentBlue, size: 50))
          : climateProvider.comparison != null
              ? Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1080),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location & Year Selector Card
                      Container(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  weatherProvider.locationName,
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: accentBlue.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: accentBlue.withValues(alpha: 0.4),
                                        width: 1),
                                  ),
                                  child: Text(
                                    '${climateProvider.year1} vs ${climateProvider.year2}',
                                    style: TextStyle(
                                      color: accentBlue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              climateProvider.comparison!.climateSummary,
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Anomaly Comparison Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildAnomalyCard(
                              label: 'Rainfall Change',
                              value:
                                  '${climateProvider.comparison!.rainfallDifferenceMm > 0 ? "+" : ""}${climateProvider.comparison!.rainfallDifferenceMm.toStringAsFixed(1)} mm',
                              sub:
                                  '(${climateProvider.comparison!.rainfallChangePercent > 0 ? "+" : ""}${climateProvider.comparison!.rainfallChangePercent.toStringAsFixed(1)}%)',
                              valueColor: climateProvider.comparison!.rainfallDifferenceMm >= 0
                                  ? accentBlue
                                  : AppColors.alertOrange,
                              surfaceColor: surfaceColor,
                              borderColor: borderColor,
                              textSecondary: textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildAnomalyCard(
                              label: 'Mean Temp Diff',
                              value:
                                  '${climateProvider.comparison!.temperatureDifferenceC > 0 ? "+" : ""}${climateProvider.comparison!.temperatureDifferenceC.toStringAsFixed(2)} °C',
                              sub: 'Year-on-year anomaly',
                              valueColor: climateProvider.comparison!.temperatureDifferenceC > 0
                                  ? AppColors.alertOrange
                                  : accentBlue,
                              surfaceColor: surfaceColor,
                              borderColor: borderColor,
                              textSecondary: textSecondary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Monthly Rainfall Bar Chart
                      Container(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Monthly Rainfall Distribution',
                                  style: TextStyle(
                                      color: textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700),
                                ),
                                Row(
                                  children: [
                                    _buildLegend(AppColors.brandBlueDark,
                                        '${climateProvider.year1}', textSecondary),
                                    const SizedBox(width: 12),
                                    _buildLegend(accentBlue,
                                        '${climateProvider.year2}', textSecondary),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 180,
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: 300,
                                  barTouchData: BarTouchData(enabled: true),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (val, meta) {
                                          const months = [
                                            'J', 'F', 'M', 'A', 'M', 'J',
                                            'J', 'A', 'S', 'O', 'N', 'D'
                                          ];
                                          final idx = val.toInt();
                                          if (idx >= 0 && idx < months.length) {
                                            return Text(months[idx],
                                                style: TextStyle(
                                                    color: textTertiary,
                                                    fontSize: 10));
                                          }
                                          return const SizedBox.shrink();
                                        },
                                      ),
                                    ),
                                    leftTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false)),
                                    topTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    getDrawingHorizontalLine: (val) => FlLine(
                                      color: borderColor,
                                      strokeWidth: 0.8,
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  barGroups: List.generate(12, (i) {
                                    final y1 = (i <
                                            climateProvider.comparison!.year1Stats
                                                .monthlyStats.length)
                                        ? climateProvider.comparison!.year1Stats
                                            .monthlyStats[i].totalRainfallMm
                                        : 0.0;
                                    final y2 = (i <
                                            climateProvider.comparison!.year2Stats
                                                .monthlyStats.length)
                                        ? climateProvider.comparison!.year2Stats
                                            .monthlyStats[i].totalRainfallMm
                                        : 0.0;
                                    return BarChartGroupData(
                                      x: i,
                                      barRods: [
                                        BarChartRodData(
                                            toY: y1,
                                            color: AppColors.brandBlueDark,
                                            width: 6,
                                            borderRadius:
                                                BorderRadius.circular(3)),
                                        BarChartRodData(
                                            toY: y2,
                                            color: accentBlue,
                                            width: 6,
                                            borderRadius:
                                                BorderRadius.circular(3)),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (climateProvider.trends != null) ...[
                        const SizedBox(height: 16),
                        Container(
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
                                  const Icon(Icons.trending_up_rounded,
                                      color: AppColors.alertOrange, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Long-Term Climate Warming Trend',
                                    style: TextStyle(
                                        color: textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                climateProvider.trends!.trendDescription,
                                style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 13,
                                    height: 1.45),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.alertOrange.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: AppColors.alertOrange.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  'Warming Rate: +${climateProvider.trends!.warmingTrendCPerDecade.toStringAsFixed(2)} °C per decade',
                                  style: const TextStyle(
                                      color: AppColors.alertOrange,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            )
          : Center(
                  child: Text(
                    'No climate data available.',
                    style: TextStyle(color: textSecondary),
                  ),
                ),
    );
  }

  Widget _buildAnomalyCard({
    required String label,
    required String value,
    required String sub,
    required Color valueColor,
    required Color surfaceColor,
    required Color borderColor,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: valueColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          Text(sub,
              style: TextStyle(
                  color: valueColor.withValues(alpha: 0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label, Color textSecondary) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(color: textSecondary, fontSize: 11)),
      ],
    );
  }
}
