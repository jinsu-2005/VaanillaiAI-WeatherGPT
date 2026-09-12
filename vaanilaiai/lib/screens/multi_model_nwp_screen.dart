import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../models/multi_model_nwp_model.dart';
import '../providers/weather_provider.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class MultiModelNwpScreen extends StatefulWidget {
  const MultiModelNwpScreen({super.key});

  @override
  State<MultiModelNwpScreen> createState() => _MultiModelNwpScreenState();
}

class _MultiModelNwpScreenState extends State<MultiModelNwpScreen> {
  final ApiService _apiService = ApiService();
  MultiModelComparisonModel? _comparison;
  bool _isLoading = false;
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchNwpData());
  }

  Future<void> _fetchNwpData() async {
    final weather = Provider.of<WeatherProvider>(context, listen: false);
    setState(() => _isLoading = true);

    try {
      final res = await _apiService.getMultiModelComparison(
        latitude: weather.latitude,
        longitude: weather.longitude,
        locationName: weather.locationName,
        days: 5,
      );
      if (mounted) {
        setState(() {
          _comparison = res;
          _isLoading = false;
          _selectedDayIndex = 0;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _comparison = MultiModelComparisonModel.unavailable(weather.locationName);
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            const Text(
              'NWP Multi-Model Ensemble',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            Text(
              'ECMWF IFS • NOAA GFS • DWD ICON',
              style: TextStyle(fontSize: 11, color: textTertiary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Model Runs',
            onPressed: _isLoading ? null : _fetchNwpData,
          ),
        ],
      ),
      body: _isLoading && _comparison == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitPulse(color: accentBlue, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Ingesting ECMWF, GFS, & ICON runs...',
                    style: TextStyle(color: textSecondary, fontSize: 13),
                  ),
                ],
              ),
            )
          : _comparison == null || _comparison!.dataUnavailable
              ? _buildUnavailableState(surfaceColor, borderColor, textPrimary, textSecondary, accentBlue)
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1080),
                    child: RefreshIndicator(
                      onRefresh: _fetchNwpData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildConsensusBanner(_comparison!, surfaceColor, borderColor, textPrimary, textSecondary, accentBlue, isDark),
                            const SizedBox(height: 18),
                            _buildDaySelector(_comparison!, surfaceColor, borderColor, textPrimary, textSecondary, accentBlue),
                            const SizedBox(height: 18),
                            if (_comparison!.dailyComparisons.isNotEmpty)
                              _buildSelectedDayMatrix(
                                _comparison!.dailyComparisons[_selectedDayIndex.clamp(0, _comparison!.dailyComparisons.length - 1)],
                                surfaceColor,
                                borderColor,
                                textPrimary,
                                textSecondary,
                                textTertiary,
                                accentBlue,
                                isDark,
                              ),
                            const SizedBox(height: 18),
                            _buildModelMetadataSection(_comparison!.modelMetadata, surfaceColor, borderColor, textPrimary, textSecondary, textTertiary, isDark),
                            const SizedBox(height: 18),
                            _buildProvenanceFooter(_comparison!.provenance, textTertiary),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildUnavailableState(
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color accentBlue,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.alertOrange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cloud_off_rounded, color: AppColors.alertOrange, size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                'NWP Multi-Model Comparison Unavailable',
                style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Unable to reach Open-Meteo multi-model ensemble server. High-resolution NWP matrices require active internet.',
                style: TextStyle(color: textSecondary, fontSize: 13, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchNwpData,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry Comparison'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConsensusBanner(
    MultiModelComparisonModel comp,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color accentBlue,
    bool isDark,
  ) {
    Color confidenceColor;
    IconData confidenceIcon;
    if (comp.overallConfidence == 'High') {
      confidenceColor = AppColors.alertGreen;
      confidenceIcon = Icons.verified_rounded;
    } else if (comp.overallConfidence == 'Low') {
      confidenceColor = AppColors.alertRed;
      confidenceIcon = Icons.warning_amber_rounded;
    } else {
      confidenceColor = AppColors.alertOrange;
      confidenceIcon = Icons.info_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF162136), const Color(0xFF1B2842)]
              : [const Color(0xFFF1F7FE), const Color(0xFFE8F2FD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.grain_rounded, color: accentBlue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        comp.locationName,
                        style: TextStyle(color: textPrimary, fontSize: 17, fontWeight: FontWeight.w800),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: confidenceColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: confidenceColor.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(confidenceIcon, size: 13, color: confidenceColor),
                    const SizedBox(width: 4),
                    Text(
                      '${comp.overallConfidence} Consensus',
                      style: TextStyle(color: confidenceColor, fontSize: 11.5, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comp.overallSummary,
            style: TextStyle(color: textSecondary, fontSize: 13, height: 1.45),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildBadge('3 Global Models', Icons.layers_rounded, accentBlue, isDark),
              const SizedBox(width: 8),
              _buildBadge('${comp.daysCount}-Day Comparison', Icons.calendar_today_rounded, AppColors.alertGreen, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector(
    MultiModelComparisonModel comp,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color accentBlue,
  ) {
    return SizedBox(
      height: 64,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: comp.dailyComparisons.length,
        itemBuilder: (ctx, i) {
          final day = comp.dailyComparisons[i];
          final isSelected = i == _selectedDayIndex;

          return GestureDetector(
            onTap: () => setState(() => _selectedDayIndex = i),
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected ? accentBlue : surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? accentBlue : borderColor,
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    i == 0 ? 'Today' : day.dayName.substring(0, 3),
                    style: TextStyle(
                      color: isSelected ? Colors.white : textPrimary,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.water_drop_rounded,
                          size: 11,
                          color: isSelected ? Colors.white.withValues(alpha: 0.9) : AppColors.weatherRain,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${day.consensusRainMeanMm}mm',
                          style: TextStyle(
                            color: isSelected ? Colors.white : textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedDayMatrix(
    DailyNwpComparisonModel day,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color textTertiary,
    Color accentBlue,
    bool isDark,
  ) {
    Color confColor = day.confidence == 'High'
        ? AppColors.alertGreen
        : (day.confidence == 'Low' ? AppColors.alertRed : AppColors.alertOrange);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with Date and Daily Confidence
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${day.dayName} (${day.date})',
              style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: confColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${day.confidence} Agreement',
                style: TextStyle(color: confColor, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Three Side-by-Side Model Cards
        Row(
          children: [
            Expanded(
              child: _buildModelTile(
                day.models['ecmwf_ifs025'],
                'ECMWF IFS',
                'Europe',
                surfaceColor,
                borderColor,
                textPrimary,
                textSecondary,
                textTertiary,
                accentBlue,
                isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildModelTile(
                day.models['gfs_seamless'],
                'NOAA GFS',
                'USA',
                surfaceColor,
                borderColor,
                textPrimary,
                textSecondary,
                textTertiary,
                accentBlue,
                isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildModelTile(
                day.models['icon_seamless'],
                'DWD ICON',
                'Germany',
                surfaceColor,
                borderColor,
                textPrimary,
                textSecondary,
                textTertiary,
                accentBlue,
                isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Consensus & Spread Bar Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Precipitation Spread Across Models',
                    style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Spread: ${day.rainSpreadMm} mm',
                    style: TextStyle(color: confColor, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Spread visual bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  height: 12,
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: (day.consensusRainMinMm * 10).clamp(1, 100).toInt(),
                        child: Container(color: AppColors.weatherRain.withValues(alpha: 0.4)),
                      ),
                      Expanded(
                        flex: (day.rainSpreadMm * 10).clamp(1, 100).toInt(),
                        child: Container(color: confColor),
                      ),
                      Expanded(
                        flex: 10,
                        child: Container(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Min: ${day.consensusRainMinMm}mm', style: TextStyle(color: textTertiary, fontSize: 11)),
                  Text('Ensemble Mean: ${day.consensusRainMeanMm}mm',
                      style: TextStyle(color: textPrimary, fontSize: 11.5, fontWeight: FontWeight.w700)),
                  Text('Max: ${day.consensusRainMaxMm}mm', style: TextStyle(color: textTertiary, fontSize: 11)),
                ],
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Consensus Temperature Range:', style: TextStyle(color: textSecondary, fontSize: 12)),
                  Text(
                    '${day.consensusTempMin.toStringAsFixed(1)}°C — ${day.consensusTempMax.toStringAsFixed(1)}°C',
                    style: TextStyle(color: textPrimary, fontSize: 12.5, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Meteorological Divergence Note
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: confColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: confColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.psychology_rounded, color: confColor, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meteorological Divergence Insight',
                      style: TextStyle(color: confColor, fontSize: 12.5, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      day.divergenceNote,
                      style: TextStyle(color: textPrimary, fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModelTile(
    NwpModelOutputModel? model,
    String name,
    String country,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color textTertiary,
    Color accentBlue,
    bool isDark,
  ) {
    if (model == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
        child: Text('N/A', style: TextStyle(color: textTertiary)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                country,
                style: TextStyle(color: accentBlue, fontSize: 9.5, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.water_drop_rounded, size: 14, color: AppColors.weatherRain),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${model.precipitationMm} mm',
                  style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.thermostat_rounded, size: 14, color: AppColors.alertOrange),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${model.temperatureMax.toStringAsFixed(0)}° / ${model.temperatureMin.toStringAsFixed(0)}°',
                  style: TextStyle(color: textSecondary, fontSize: 11.5, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${model.resolutionKm.toInt()}km res',
            style: TextStyle(color: textTertiary, fontSize: 9.5),
          ),
        ],
      ),
    );
  }

  Widget _buildModelMetadataSection(
    List<NwpModelMetadataModel> metadataList,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color textTertiary,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book_rounded, size: 18, color: AppColors.brandBlue),
              const SizedBox(width: 8),
              Text(
                'NWP Operational Models Guide',
                style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Numerical Weather Prediction (NWP) uses supercomputers to solve fluid dynamic equations of the atmosphere. Different meteorological agencies implement distinct physical parameterizations:',
            style: TextStyle(color: textSecondary, fontSize: 12, height: 1.45),
          ),
          const SizedBox(height: 12),
          ...metadataList.map((m) => _buildModelMetaItem(m, textPrimary, textSecondary, textTertiary)),
        ],
      ),
    );
  }

  Widget _buildModelMetaItem(
    NwpModelMetadataModel m,
    Color textPrimary,
    Color textSecondary,
    Color textTertiary,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                m.fullName,
                style: TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: AppColors.brandBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  m.resolution,
                  style: const TextStyle(color: AppColors.brandBlue, fontSize: 9.5, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            '${m.agency} • ${m.country}',
            style: TextStyle(color: textTertiary, fontSize: 10.5),
          ),
          const SizedBox(height: 2),
          Text(
            m.primaryStrength,
            style: TextStyle(color: textSecondary, fontSize: 11, height: 1.3),
          ),
        ],
      ),
    );
  }

  Widget _buildProvenanceFooter(String provenance, Color textTertiary) {
    return Center(
      child: Text(
        'Data Source: $provenance\nOperational model runs updated every 6 to 12 hours.',
        style: TextStyle(color: textTertiary, fontSize: 10.5, height: 1.4),
        textAlign: TextAlign.center,
      ),
    );
  }
}
