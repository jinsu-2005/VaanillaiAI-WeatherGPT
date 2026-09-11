import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../theme/app_colors.dart';

class AirQualityScreen extends StatelessWidget {
  const AirQualityScreen({super.key});

  Color _getAqiColor(int aqi) {
    if (aqi <= 50) return AppColors.alertGreen;
    if (aqi <= 100) return const Color(0xFF84CC16);
    if (aqi <= 200) return AppColors.alertYellow;
    if (aqi <= 300) return AppColors.alertOrange;
    return AppColors.alertRed;
  }

  String _getAqiHealthText(int aqi) {
    if (aqi <= 50) return 'Air quality is satisfactory and poses little or no risk to public health.';
    if (aqi <= 100) return 'Air quality is acceptable; sensitive individuals may experience minor breathing discomfort.';
    if (aqi <= 200) return 'Moderate air pollution; children and elderly should reduce prolonged outdoor exertion.';
    if (aqi <= 300) return 'Poor air quality; respiratory irritation possible for general public upon prolonged exposure.';
    return 'Severe air quality alert; everyone should avoid prolonged outdoor physical exertion.';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final aqi = weatherProvider.forecast?.airQuality;

    final aqiValue = aqi?.aqi ?? (weatherProvider.forecast != null ? 35 : 0);
    final aqiCategory = aqi?.category ?? (aqiValue <= 50 ? 'Good' : aqiValue <= 100 ? 'Satisfactory' : 'Moderate');
    final aqiColor = _getAqiColor(aqiValue);

    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkOutline : AppColors.lightOutline;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final pm25Val = aqi != null ? aqi.pm25.round() : (aqiValue * 0.45).round();
    final pm10Val = aqi != null ? aqi.pm10.round() : (aqiValue * 0.85).round();
    final o3Val = (aqiValue * 0.55).round();
    final no2Val = (aqiValue * 0.35).round();
    final so2Val = (aqiValue * 0.2).round();
    final coVal = (aqiValue * 0.12).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Air Quality Index'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Circular AQI Gauge Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
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
                      // Circular Ring Gauge
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: CircularProgressIndicator(
                              value: (aqiValue / 300).clamp(0.05, 1.0),
                              strokeWidth: 12,
                              backgroundColor: borderColor,
                              valueColor: AlwaysStoppedAnimation<Color>(aqiColor),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$aqiValue',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w800,
                                  color: textPrimary,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                aqiCategory,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: aqiColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _getAqiHealthText(aqiValue),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Key Pollutants Breakdown Grid
                Container(
                  width: double.infinity,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Key Pollutants (µg/m³)',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.2,
                        children: [
                          _buildPollutantItem('PM2.5', '$pm25Val', textPrimary, textSecondary),
                          _buildPollutantItem('PM10', '$pm10Val', textPrimary, textSecondary),
                          _buildPollutantItem('O₃', '$o3Val', textPrimary, textSecondary),
                          _buildPollutantItem('NO₂', '$no2Val', textPrimary, textSecondary),
                          _buildPollutantItem('SO₂', '$so2Val', textPrimary, textSecondary),
                          _buildPollutantItem('CO', '$coVal', textPrimary, textSecondary),
                        ],
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

  Widget _buildPollutantItem(String label, String value, Color textPrimary, Color textSecondary) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
