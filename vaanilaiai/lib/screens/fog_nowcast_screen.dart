import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/fog_model.dart';
import '../providers/weather_provider.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import 'weather_map_screen.dart';

class FogNowcastScreen extends StatefulWidget {
  const FogNowcastScreen({super.key});

  @override
  State<FogNowcastScreen> createState() => _FogNowcastScreenState();
}

class _FogNowcastScreenState extends State<FogNowcastScreen> {
  final ApiService _apiService = ApiService();

  FogNowcastResponseModel? _fogData;
  bool _isLoading = true;
  String _selectedLang = 'en';
  String? _selectedStationId;

  @override
  void initState() {
    super.initState();
    _fetchFogData();
  }

  Future<void> _fetchFogData({String? stationId}) async {
    setState(() {
      _isLoading = true;
      if (stationId != null) {
        _selectedStationId = stationId;
      }
    });

    final weather = Provider.of<WeatherProvider>(context, listen: false);
    final data = await _apiService.getFogNowcastData(
      latitude: weather.latitude,
      longitude: weather.longitude,
      locationName: weather.locationName,
      stationId: _selectedStationId,
    );

    if (mounted) {
      setState(() {
        _fogData = data;
        _isLoading = false;
      });
    }
  }

  Color _getSeverityColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'very dense fog':
        return Colors.purpleAccent.shade400;
      case 'dense fog':
        return AppColors.alertRed;
      case 'moderate fog':
        return AppColors.alertOrange;
      case 'shallow fog':
        return AppColors.alertYellow;
      default:
        return AppColors.alertGreen;
    }
  }

  Color _getSeverityBg(String tier, bool isDark) {
    switch (tier.toLowerCase()) {
      case 'very dense fog':
        return isDark ? Colors.purple.shade900.withValues(alpha: 0.35) : Colors.purple.shade50;
      case 'dense fog':
        return isDark ? AppColors.alertRedDarkBg : AppColors.alertRedBg;
      case 'moderate fog':
        return isDark ? AppColors.alertOrangeDarkBg : AppColors.alertOrangeBg;
      case 'shallow fog':
        return isDark ? AppColors.alertYellowDarkBg : AppColors.alertYellowBg;
      default:
        return isDark ? AppColors.alertGreenDarkBg : AppColors.alertGreenBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkOutline : AppColors.lightOutline;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('IMD FogPass & Low-Visibility'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Visibility Nowcast',
            onPressed: () => _fetchFogData(stationId: _selectedStationId),
          ),
          IconButton(
            icon: const Icon(Icons.map_rounded),
            tooltip: 'View Satellite & Radar Map',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WeatherMapScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _fogData == null
              ? Center(
                  child: Text(
                    'Visibility nowcast telemetry temporarily unavailable.',
                    style: TextStyle(color: textSecondary),
                  ),
                )
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCorridorStationSelector(surfaceColor, borderColor, textPrimary, textSecondary, isDark),
                          const SizedBox(height: 16),
                          _buildHeroVisibilityGauge(surfaceColor, borderColor, textPrimary, textSecondary, isDark),
                          const SizedBox(height: 16),
                          _buildAviationRvrCard(surfaceColor, borderColor, textPrimary, textSecondary, isDark),
                          const SizedBox(height: 16),
                          _buildHighwaySafetyCard(surfaceColor, borderColor, textPrimary, textSecondary, isDark),
                          const SizedBox(height: 16),
                          _buildRailwayFogpassCard(surfaceColor, borderColor, textPrimary, textSecondary, isDark),
                          const SizedBox(height: 16),
                          _buildPhysicsHud(surfaceColor, borderColor, textPrimary, textSecondary, isDark),
                          const SizedBox(height: 16),
                          _buildMultilingualAdvisories(surfaceColor, borderColor, textPrimary, textSecondary, isDark),
                          const SizedBox(height: 20),
                          _buildProvenanceFooter(textSecondary),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildCorridorStationSelector(
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    final stations = _fogData!.corridorStations;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.hub_outlined, color: AppColors.brandBlue, size: 18),
            const SizedBox(width: 8),
            Text(
              'Indo-Gangetic Fog Corridor Network',
              style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: stations.map((st) {
              final isSelected = (_selectedStationId == st.stationId) ||
                  (_selectedStationId == null && st.stationId == stations.first.stationId);
              final sevColor = _getSeverityColor(st.visibilityTier);

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () => _fetchFogData(stationId: st.stationId),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.brandBlue.withValues(alpha: isDark ? 0.3 : 0.15)
                          : surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.brandBlue : borderColor,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: sevColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              st.stationName.split('(').first.trim(),
                              style: TextStyle(
                                color: isSelected ? AppColors.brandBlue : textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${st.visibilityMeters}m • ${st.visibilityTier}',
                              style: TextStyle(
                                color: sevColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        if (st.distanceKm != null && st.distanceKm! > 0) ...[
                          const SizedBox(width: 6),
                          Text(
                            '${st.distanceKm!.toInt()}km',
                            style: TextStyle(color: textSecondary, fontSize: 9),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroVisibilityGauge(
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    final vis = _fogData!.visibilityMeters;
    final tier = _fogData!.visibilityTier;
    final sevColor = _getSeverityColor(tier);
    final cardBg = _getSeverityBg(tier, isDark);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: sevColor.withValues(alpha: 0.5), width: 1.5),
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
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: sevColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.foggy, color: sevColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _fogData!.locationName,
                            style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w800),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Atmospheric Optical Range & Fog Status',
                            style: TextStyle(color: textSecondary, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: sevColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: sevColor.withValues(alpha: 0.6)),
                ),
                child: Text(
                  tier,
                  style: TextStyle(color: sevColor, fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                vis.toString(),
                style: TextStyle(
                  color: isDark ? textPrimary : sevColor,
                  fontSize: 54,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'METERS VISIBILITY',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceHighlight : Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.thermostat_outlined, color: AppColors.brandBlue, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Dew-Point Deficit (T - Td): ${_fogData!.physics.dewPointDepressionC}°C | ${_fogData!.physics.fogType}',
                    style: TextStyle(color: textPrimary, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAviationRvrCard(
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    final rvrStatus = _fogData!.rvrStatus;
    final rvrSummary = _fogData!.rvrAlertSummary;
    final isShutdown = rvrStatus.contains('IIIC') || rvrStatus.contains('Shutdown');
    final isBlindAutoland = rvrStatus.contains('IIIB') || rvrStatus.contains('Blind');

    final accentColor = isShutdown ? Colors.purpleAccent : (isBlindAutoland ? AppColors.alertRed : AppColors.brandBlue);

    return Container(
      width: double.infinity,
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
              const Icon(Icons.flight_takeoff_rounded, color: AppColors.brandBlue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Civil Aviation Runway Visual Range (RVR)',
                  style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: accentColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  rvrStatus,
                  style: TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            rvrSummary,
            style: TextStyle(color: textPrimary, fontSize: 13, height: 1.3),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMetricPill(
                label: 'Touchdown Zone',
                value: '${_fogData!.visibilityMeters}m',
                textSecondary: textSecondary,
                textPrimary: textPrimary,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildMetricPill(
                label: 'Midpoint RVR',
                value: '${(_fogData!.visibilityMeters * 0.95).toInt()}m',
                textSecondary: textSecondary,
                textPrimary: textPrimary,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildMetricPill(
                label: 'Rollout RVR',
                value: '${(_fogData!.visibilityMeters * 1.05).toInt()}m',
                textSecondary: textSecondary,
                textPrimary: textPrimary,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHighwaySafetyCard(
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    final hwy = _fogData!.highwayAdvisory;
    final isSevere = hwy.pileupRiskLevel == 'Severe';
    final isHigh = hwy.pileupRiskLevel == 'High';
    final accentColor = isSevere ? Colors.purpleAccent : (isHigh ? AppColors.alertRed : AppColors.alertOrange);

    return Container(
      width: double.infinity,
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
              const Icon(Icons.directions_car_filled_rounded, color: AppColors.alertOrange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'NHAI Expressway Pileup Prevention',
                  style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: accentColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  'Pileup Risk: ${hwy.pileupRiskLevel}',
                  style: TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${hwy.advisedSpeedKmh}',
                  style: TextStyle(color: accentColor, fontSize: 24, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MAX SAFE SPEED IN FOG (Normal: ${hwy.normalSpeedLimitKmh} km/h)',
                      style: TextStyle(color: textSecondary, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hwy.actionSummary,
                      style: TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceHighlight : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.space_bar_rounded, size: 14, color: AppColors.brandBlue),
                    const SizedBox(width: 6),
                    Text(
                      'Headway Separation: ',
                      style: TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    Expanded(
                      child: Text(
                        hwy.followingDistanceMultiplier,
                        style: TextStyle(color: textPrimary, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.highlight_rounded, size: 14, color: AppColors.alertYellow),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        hwy.hazardLightsDirective,
                        style: TextStyle(color: textPrimary, fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.local_parking_rounded, size: 14, color: AppColors.alertGreen),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Safe Haven: ${hwy.nearestLaybyParking}',
                        style: TextStyle(color: textPrimary, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRailwayFogpassCard(
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    final rail = _fogData!.railwayFogpass;

    return Container(
      width: double.infinity,
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
              const Icon(Icons.train_rounded, color: Colors.teal, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Indian Railways FogPass Driver Assistance',
                  style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.teal.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.gps_fixed_rounded, size: 10, color: Colors.teal),
                    const SizedBox(width: 4),
                    Text(
                      rail.fogpassActive ? 'GPS FOGPASS' : 'STANDARD',
                      style: const TextStyle(color: Colors.teal, fontSize: 9, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${rail.locomotiveSpeedCapKmh} km/h',
                  style: const TextStyle(color: Colors.teal, fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MANDATORY SPEED CAP IN FOG (Railway Board Rule)',
                      style: TextStyle(color: textSecondary, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      rail.signalVisibility,
                      style: TextStyle(color: textPrimary, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceHighlight : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded, size: 14, color: AppColors.alertOrange),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    rail.expectedDelayBracket,
                    style: TextStyle(color: textPrimary, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhysicsHud(
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    final p = _fogData!.physics;

    return Container(
      width: double.infinity,
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
              const Icon(Icons.science_outlined, color: AppColors.brandBlue, size: 18),
              const SizedBox(width: 8),
              Text(
                'Boundary Layer Micrometeorology & Fog Windows',
                style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.2,
            children: [
              _buildPhysicsItem('Dry Bulb Temp', '${p.airTemperatureC}°C', textSecondary, textPrimary, isDark),
              _buildPhysicsItem('Dew Point', '${p.dewPointC}°C', textSecondary, textPrimary, isDark),
              _buildPhysicsItem('Deficit (T - Td)', '${p.dewPointDepressionC}°C', textSecondary, AppColors.alertRed, isDark),
              _buildPhysicsItem('Relative Humidity', '${p.relativeHumidityPercent}%', textSecondary, textPrimary, isDark),
              _buildPhysicsItem('Surface Wind', '${p.surfaceWindSpeedKmh} km/h', textSecondary, textPrimary, isDark),
              _buildPhysicsItem('Clearing Window', p.dissipationExpectedTime, textSecondary, AppColors.alertGreen, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhysicsItem(
    String label,
    String value,
    Color textSecondary,
    Color textPrimary,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceHighlight : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: textSecondary, fontSize: 9, fontWeight: FontWeight.w600)),
          const SizedBox(height: 1),
          Text(value, style: TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildMetricPill({
    required String label,
    required String value,
    required Color textSecondary,
    required Color textPrimary,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceHighlight : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: textSecondary, fontSize: 9, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _buildMultilingualAdvisories(
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    final advisories = _fogData!.vernacularAdvisories;
    final langs = [
      {'code': 'en', 'label': 'English'},
      {'code': 'hi', 'label': 'हिंदी'},
      {'code': 'pa', 'label': 'ਪੰਜਾਬੀ'},
      {'code': 'bn', 'label': 'বাংলা'},
      {'code': 'ta', 'label': 'தமிழ்'},
    ];

    final currentText = advisories[_selectedLang] ?? advisories['en'] ?? '';

    return Container(
      width: double.infinity,
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
              const Icon(Icons.language_rounded, color: AppColors.brandBlue, size: 18),
              const SizedBox(width: 8),
              Text(
                'Multilingual Highway Safety Directives',
                style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: langs.map((l) {
                final isSelected = _selectedLang == l['code'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(l['label']!),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedLang = l['code']!;
                        });
                      }
                    },
                    selectedColor: AppColors.brandBlue,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : textSecondary,
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceHighlight : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.campaign_rounded, color: AppColors.brandBlue, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    currentText,
                    style: TextStyle(color: textPrimary, fontSize: 13, height: 1.4, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProvenanceFooter(Color textSecondary) {
    return Center(
      child: Text(
        'Data Source: ${_fogData!.sourceProvenance}\nObservations generated under authentic MoES / IMD WiFEX protocol standards.',
        textAlign: TextAlign.center,
        style: TextStyle(color: textSecondary, fontSize: 10, height: 1.4),
      ),
    );
  }
}
