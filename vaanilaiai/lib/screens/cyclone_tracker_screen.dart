import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cyclone_model.dart';
import '../providers/weather_provider.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class CycloneTrackerScreen extends StatefulWidget {
  final String? initialSystemId;

  const CycloneTrackerScreen({super.key, this.initialSystemId});

  @override
  State<CycloneTrackerScreen> createState() => _CycloneTrackerScreenState();
}

class _CycloneTrackerScreenState extends State<CycloneTrackerScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _errorMessage;
  CycloneTrackerResponseModel? _data;
  String? _selectedSystemId;
  String _selectedLanguage = 'en';

  final Map<String, String> _languageNames = {
    'en': 'English',
    'ta': 'தமிழ்',
    'hi': 'हिंदी',
    'bn': 'বাংলা',
    'or': 'ଓଡ଼ିଆ',
  };

  @override
  void initState() {
    super.initState();
    _selectedSystemId = widget.initialSystemId;
    _fetchTelemetry();
  }

  Future<void> _fetchTelemetry({String? systemId}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final weather = Provider.of<WeatherProvider>(context, listen: false);
      final res = await _apiService.getCycloneTrackerData(
        latitude: weather.latitude,
        longitude: weather.longitude,
        systemId: systemId ?? _selectedSystemId,
      );

      if (mounted) {
        setState(() {
          _data = res;
          _selectedSystemId = res.selectedSystem.systemId;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Color _parseHexColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return AppColors.alertRed;
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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('IMD Cyclone Tracker', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
              'RSMC New Delhi • North Indian Ocean',
              style: TextStyle(fontSize: 11, color: AppColors.brandBlue),
            ),
          ],
        ),
        actions: [
          if (_data?.isOfflineCached ?? false)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.alertOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.alertOrange.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.offline_bolt_rounded, size: 14, color: AppColors.alertOrange),
                      SizedBox(width: 4),
                      Text(
                        'OFFLINE',
                        style: TextStyle(
                          color: AppColors.alertOrange,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Cyclone Telemetry',
            onPressed: () => _fetchTelemetry(systemId: _selectedSystemId),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'IMD RSMC Information',
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Ingesting IMD RSMC Cyclone Track & Surge Telemetry...',
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            )
          : _errorMessage != null && _data == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.alertRed, size: 48),
                        const SizedBox(height: 12),
                        Text('Failed to load cyclone intelligence',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary)),
                        const SizedBox(height: 6),
                        Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: textSecondary)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry'),
                          onPressed: () => _fetchTelemetry(),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildContent(context, isDark, surfaceColor, borderColor, textPrimary, textSecondary),
    );
  }

  Widget _buildContent(
    BuildContext context,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final system = _data!.selectedSystem;
    final stageColor = _parseHexColor(system.stageColorHex);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // System Switcher Chips
              _buildSystemSelector(isDark, borderColor, textPrimary, textSecondary),
              const SizedBox(height: 16),

              // Hero Intensity & Dvorak T-Number Card
              _buildHeroIntensityCard(system, stageColor, isDark, surfaceColor, borderColor, textPrimary, textSecondary),
              const SizedBox(height: 16),

              // Landfall Proximity & Vector HUD
              _buildLandfallProximityHud(system, isDark, surfaceColor, borderColor, textPrimary, textSecondary),
              const SizedBox(height: 16),

              // Coastal Storm Surge Inundation Card
              _buildStormSurgeCard(system, isDark, surfaceColor, borderColor, textPrimary, textSecondary),
              const SizedBox(height: 16),

              // Gale Wind Radii Cones HUD
              _buildGaleWindRadiiHud(system, isDark, surfaceColor, borderColor, textPrimary, textSecondary),
              const SizedBox(height: 16),

              // 72-Hour Sequential Track Forecast
              _buildTrackForecastTimeline(system, isDark, surfaceColor, borderColor, textPrimary, textSecondary),
              const SizedBox(height: 16),

              // NDMA Evacuation Directives & Port Signals
              _buildEvacuationDirectivesCard(system, isDark, surfaceColor, borderColor, textPrimary, textSecondary),
              const SizedBox(height: 16),

              // Multilingual Vernacular Emergency Bulletins
              _buildVernacularBulletinCard(system, isDark, surfaceColor, borderColor, textPrimary, textSecondary),
              const SizedBox(height: 20),

              // RSMC Provenance Footer
              _buildProvenanceFooter(isDark, textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSystemSelector(
    bool isDark,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    if (_data == null || _data!.availableSystems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.cyclone_rounded, size: 16, color: AppColors.brandBlue),
            const SizedBox(width: 6),
            Text(
              'Select Monitored Storm / Reference Scenario:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _data!.availableSystems.map((s) {
              final isSelected = s.systemId == _selectedSystemId;
              final stormColor = _parseHexColor(s.stageColorHex);

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text('${s.name} (${s.basin})'),
                  selected: isSelected,
                  selectedColor: stormColor.withValues(alpha: 0.2),
                  backgroundColor: isDark ? AppColors.darkSurfaceHighlight : AppColors.lightSurfaceHighlight,
                  side: BorderSide(
                    color: isSelected ? stormColor : borderColor,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? (isDark ? Colors.white : stormColor) : textPrimary,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedSystemId = s.systemId;
                      });
                      _fetchTelemetry(systemId: s.systemId);
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroIntensityCard(
    CycloneSystemModel system,
    Color stageColor,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final dvorak = system.dvorak;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: stageColor.withValues(alpha: 0.4), width: 1.5),
        gradient: LinearGradient(
          colors: [
            stageColor.withValues(alpha: isDark ? 0.25 : 0.12),
            surfaceColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: stageColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.cyclone_rounded, size: 36, color: stageColor),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CYCLONE ${system.name}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        'Basin: ${system.basin}',
                        style: TextStyle(fontSize: 12, color: textSecondary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: stageColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  system.warningStage,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Dvorak Dial & Intensity Badge
          Row(
            children: [
              // Circular Dvorak T-Number Dial
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.black26 : Colors.white70,
                  border: Border.all(color: stageColor, width: 3),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'T${dvorak.tNumber.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: stageColor,
                        ),
                      ),
                      Text(
                        'CI ${dvorak.ciNumber.toStringAsFixed(1)}',
                        style: TextStyle(fontSize: 10, color: textSecondary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: stageColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        dvorak.intensityStage,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: stageColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Position: ${system.currentLatitude.toStringAsFixed(1)}°N, ${system.currentLongitude.toStringAsFixed(1)}°E',
                      style: TextStyle(fontSize: 12, color: textPrimary, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Vector: ${system.movementDirection} @ ${system.movementSpeedKmh.toStringAsFixed(0)} km/h',
                      style: TextStyle(fontSize: 11, color: textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // 4-Column Physics Telemetry Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  'Central Deficit (ΔP)',
                  '${dvorak.pressureDeficitHpa.toStringAsFixed(1)} hPa',
                  Icons.compress_rounded,
                  Colors.deepOrange,
                  textPrimary,
                  textSecondary,
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  'Central Press (Pc)',
                  '${dvorak.centralPressureHpa.toStringAsFixed(0)} hPa',
                  Icons.speed_rounded,
                  Colors.blueGrey,
                  textPrimary,
                  textSecondary,
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  'Max Sustained',
                  '${dvorak.maxSustainedWindKmh.toStringAsFixed(0)} km/h',
                  Icons.air_rounded,
                  Colors.blue,
                  textPrimary,
                  textSecondary,
                  subtitle: '${dvorak.maxSustainedWindKt.toStringAsFixed(0)} kt',
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  'Peak Gusts',
                  '${dvorak.gustSpeedKmh.toStringAsFixed(0)} km/h',
                  Icons.storm_rounded,
                  AppColors.alertRed,
                  textPrimary,
                  textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(
    String label,
    String value,
    IconData icon,
    Color iconColor,
    Color textPrimary,
    Color textSecondary, {
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 10, color: textSecondary, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textPrimary),
        ),
        if (subtitle != null) ...[
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: textSecondary),
          ),
        ],
      ],
    );
  }

  Widget _buildLandfallProximityHud(
    CycloneSystemModel system,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.near_me_rounded, color: AppColors.brandBlue, size: 18),
              const SizedBox(width: 8),
              Text(
                'Landfall Trajectory & Geodetic Proximity',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary),
              ),
              const Spacer(),
              if (system.distanceToUserKm != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.brandBlue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${system.distanceToUserKm!.toStringAsFixed(0)} km to you',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.brandBlue),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Projected Landfall Location',
                  system.projectedLandfallLocation,
                  Icons.place_rounded,
                  AppColors.alertOrange,
                  textPrimary,
                  textSecondary,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Expected Landfall Time',
                  system.projectedLandfallTime,
                  Icons.access_time_filled_rounded,
                  Colors.teal,
                  textPrimary,
                  textSecondary,
                  badge: system.landfallEtaHours != null
                      ? 'ETA: ~${system.landfallEtaHours!.toStringAsFixed(1)}h'
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon,
    Color iconColor,
    Color textPrimary,
    Color textSecondary, {
    String? badge,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary)),
        if (badge != null) ...[
          const SizedBox(height: 3),
          Text(badge, style: const TextStyle(fontSize: 11, color: AppColors.brandBlue, fontWeight: FontWeight.bold)),
        ],
      ],
    );
  }

  Widget _buildStormSurgeCard(
    CycloneSystemModel system,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    if (system.stormSurgeForecasts.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.cyan.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tsunami_rounded, color: Colors.cyan, size: 20),
              SizedBox(width: 8),
              Text(
                'Coastal Storm Surge & Inundation Projections',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Coupled INCOIS-IITD Hydrodynamic Model (Astronomical Tide + Wind Setup)',
            style: TextStyle(fontSize: 11, color: textSecondary),
          ),
          const SizedBox(height: 12),
          ...system.stormSurgeForecasts.map((surge) {
            Color riskColor = Colors.orange;
            if (surge.surgeRiskTier.toLowerCase().contains('catastrophic') ||
                surge.surgeRiskTier.toLowerCase().contains('high')) {
              riskColor = AppColors.alertRed;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceHighlight : AppColors.lightSurfaceHighlight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        surge.coastalDistrict,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textPrimary),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: riskColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${surge.surgeRiskTier} Surge Risk',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: riskColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSurgeStat(
                          'Astronomical Tide',
                          '${surge.astronomicalTideM.toStringAsFixed(1)} m',
                          Colors.blueGrey,
                          textPrimary,
                          textSecondary,
                        ),
                      ),
                      Expanded(
                        child: _buildSurgeStat(
                          'Peak Storm Surge',
                          '+${surge.peakSurgeM.toStringAsFixed(1)} m',
                          Colors.cyan,
                          textPrimary,
                          textSecondary,
                        ),
                      ),
                      Expanded(
                        child: _buildSurgeStat(
                          'Total Water Level',
                          '${surge.totalWaterLevelM.toStringAsFixed(1)} m',
                          riskColor,
                          textPrimary,
                          textSecondary,
                        ),
                      ),
                      Expanded(
                        child: _buildSurgeStat(
                          'Inland Inundation',
                          '${surge.inlandInundationKm.toStringAsFixed(1)} km',
                          Colors.deepPurpleAccent,
                          textPrimary,
                          textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    surge.surgeWarningNote,
                    style: TextStyle(fontSize: 11, color: textSecondary, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSurgeStat(
    String label,
    String value,
    Color valueColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }

  Widget _buildGaleWindRadiiHud(
    CycloneSystemModel system,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final gale = system.galeRadii;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.radar_rounded, color: Colors.indigoAccent, size: 18),
              const SizedBox(width: 8),
              Text('Gale Wind Radii Quadrant Extents (km)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Destructive wind swath radii across NE, SE, SW, NW quadrants',
            style: TextStyle(fontSize: 11, color: textSecondary),
          ),
          const SizedBox(height: 12),
          _buildQuadrantRow(
            '64 kt (118 km/h) Hurricane Force',
            gale.radius64ktNeKm,
            gale.radius64ktSeKm,
            gale.radius64ktSwKm,
            gale.radius64ktNwKm,
            AppColors.alertRed,
            isDark,
          ),
          const SizedBox(height: 8),
          _buildQuadrantRow(
            '50 kt (92 km/h) Storm Force',
            gale.radius50ktNeKm,
            gale.radius50ktSeKm,
            gale.radius50ktSwKm,
            gale.radius50ktNwKm,
            AppColors.alertOrange,
            isDark,
          ),
          const SizedBox(height: 8),
          _buildQuadrantRow(
            '34 kt (62 km/h) Gale Force',
            gale.radius34ktNeKm,
            gale.radius34ktSeKm,
            gale.radius34ktSwKm,
            gale.radius34ktNwKm,
            Colors.amber,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildQuadrantRow(
    String speedLabel,
    double ne,
    double se,
    double sw,
    double nw,
    Color badgeColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceHighlight : AppColors.lightSurfaceHighlight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              speedLabel,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
            ),
          ),
          const Spacer(),
          Text('NE: ${ne.toStringAsFixed(0)}k | SE: ${se.toStringAsFixed(0)}k | SW: ${sw.toStringAsFixed(0)}k | NW: ${nw.toStringAsFixed(0)}k',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTrackForecastTimeline(
    CycloneSystemModel system,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    if (system.trackPoints.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timeline_rounded, color: AppColors.brandBlue, size: 18),
              const SizedBox(width: 8),
              Text(
                '72-Hour Sequential Track & Intensity Forecast',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: system.trackPoints.map((tp) {
                final isCurrent = tp.status.toLowerCase() == 'current';
                final isPast = tp.status.toLowerCase() == 'past';

                Color statusColor = AppColors.brandBlue;
                if (isCurrent) statusColor = AppColors.alertRed;
                if (isPast) statusColor = Colors.grey;

                return Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? statusColor.withValues(alpha: isDark ? 0.2 : 0.1)
                        : (isDark ? AppColors.darkSurfaceHighlight : AppColors.lightSurfaceHighlight),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCurrent ? statusColor : borderColor,
                      width: isCurrent ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            tp.forecastHour == 0 ? 'NOW' : '${tp.forecastHour > 0 ? "+" : ""}${tp.forecastHour}h',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: statusColor,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tp.stageCode,
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: statusColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${tp.latitude.toStringAsFixed(1)}°N, ${tp.longitude.toStringAsFixed(1)}°E',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${tp.maxWindKmh.toStringAsFixed(0)} km/h',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textPrimary),
                      ),
                      Text(
                        '${tp.centralPressureHpa.toStringAsFixed(0)} hPa',
                        style: TextStyle(fontSize: 10, color: textSecondary),
                      ),
                      if (tp.coneOfUncertaintyKm > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          '±${tp.coneOfUncertaintyKm.toStringAsFixed(0)} km cone',
                          style: TextStyle(fontSize: 9, color: textSecondary),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvacuationDirectivesCard(
    CycloneSystemModel system,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final evac = system.evacuation;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.alertRed.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_rounded, color: AppColors.alertRed, size: 20),
              const SizedBox(width: 8),
              Text(
                'NDMA Coastal Evacuation Directives',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.alertRed,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'PORT SIGNAL ${evac.portWarningSignal}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            evac.portSignalMeaning,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.alertRed),
          ),
          const SizedBox(height: 12),
          _buildZoneDirective(
            'Red Zone (< 5 km Coast)',
            evac.redZoneAction,
            AppColors.alertRed,
            isDark,
            textPrimary,
          ),
          const SizedBox(height: 8),
          _buildZoneDirective(
            'Orange Zone (5 to 15 km)',
            evac.orangeZoneAction,
            AppColors.alertOrange,
            isDark,
            textPrimary,
          ),
          const SizedBox(height: 8),
          _buildZoneDirective(
            'Yellow Zone (> 15 km Inland)',
            evac.yellowZoneAction,
            Colors.amber,
            isDark,
            textPrimary,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.home_work_rounded, size: 16, color: AppColors.alertGreen),
              const SizedBox(width: 6),
              Text(
                'Multi-Purpose Cyclone Shelters (MPCS): ${evac.sheltersActiveCount} active & manned',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.alertGreen),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildZoneDirective(
    String zoneTitle,
    String action,
    Color zoneColor,
    bool isDark,
    Color textPrimary,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: zoneColor.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: zoneColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            zoneTitle,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: zoneColor),
          ),
          const SizedBox(height: 3),
          Text(
            action,
            style: TextStyle(fontSize: 11, color: textPrimary, height: 1.3),
          ),
        ],
      ),
    );
  }

  Widget _buildVernacularBulletinCard(
    CycloneSystemModel system,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final bulletin = system.vernacularBulletin[_selectedLanguage] ??
        system.vernacularBulletin['en'] ??
        'Official cyclone bulletin active.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.campaign_rounded, color: AppColors.alertOrange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Vernacular Emergency Broadcast',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Language selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _languageNames.entries.map((entry) {
                final isSelected = _selectedLanguage == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: FilterChip(
                    label: Text(entry.value),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedLanguage = entry.key;
                        });
                      }
                    },
                    selectedColor: AppColors.brandBlue.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.brandBlue : textSecondary,
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
              color: isDark ? AppColors.darkSurfaceHighlight : AppColors.lightSurfaceHighlight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              bulletin,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProvenanceFooter(bool isDark, Color textSecondary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Divider(),
        const SizedBox(height: 6),
        Text(
          'Bulletin No: ${_data?.rsmcBulletinNo ?? "RSMC/NIO"} • Issued: ${_data?.issuedAt ?? "Live"}',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          _data?.authorityDisclaimer ?? 'Official RSMC New Delhi Cyclone Warning Service',
          style: TextStyle(fontSize: 10, color: textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cyclone_rounded, color: AppColors.brandBlue),
            SizedBox(width: 8),
            Text('IMD RSMC Cyclone Protocol', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Regional Specialized Meteorological Centre (RSMC) New Delhi:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              SizedBox(height: 4),
              Text(
                'RSMC New Delhi (IMD) is mandated by WMO to track and issue cyclone advisories for all 13 member countries of the North Indian Ocean basin (Bay of Bengal & Arabian Sea).',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 12),
              Text(
                'Official 4-Stage Warning System:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              SizedBox(height: 4),
              Text(
                '1. Stage 1 (Yellow): Pre-Cyclone Watch (72h ahead)\n'
                '2. Stage 2 (Orange): Cyclone Alert (48h ahead)\n'
                '3. Stage 3 (Red): Cyclone Warning (24h ahead)\n'
                '4. Stage 4 (Red): Post-Landfall Outlook (12h ahead)',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 12),
              Text(
                'Dvorak Technique (T-Number):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              SizedBox(height: 4),
              Text(
                'Measures tropical cyclone intensity (T1.0 to T8.0) via satellite infrared/visible pattern recognition and empirical central pressure deficit (ΔP = Pc - 1010 hPa).',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
