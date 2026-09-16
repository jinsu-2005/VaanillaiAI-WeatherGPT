import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../models/marine_model.dart';
import '../providers/weather_provider.dart';
import '../services/api_service.dart';

class MarineOceanScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLon;
  final String? initialLocationName;

  const MarineOceanScreen({
    super.key,
    this.initialLat,
    this.initialLon,
    this.initialLocationName,
  });

  @override
  State<MarineOceanScreen> createState() => _MarineOceanScreenState();
}

class _MarineOceanScreenState extends State<MarineOceanScreen> {
  final ApiService _apiService = ApiService();
  MarineAdvisoryModel? _advisory;
  bool _isLoading = true;
  String _selectedLang = 'en'; // 'en', 'ta', 'ml', 'hi'

  // Standard coastal testing/preview presets
  static const List<Map<String, dynamic>> _coastalPresets = [
    {
      'name': 'Chennai Marina',
      'lat': 13.0827,
      'lon': 80.2707,
      'sector': 'Tamil Nadu & South Andhra Coast',
    },
    {
      'name': 'Kochi Malabar Coast',
      'lat': 9.9312,
      'lon': 76.2673,
      'sector': 'Kerala & Lakshadweep Sea',
    },
    {
      'name': 'Mumbai Colaba',
      'lat': 18.9220,
      'lon': 72.8347,
      'sector': 'Maharashtra & Konkan Coast',
    },
    {
      'name': 'Visakhapatnam Port',
      'lat': 17.6868,
      'lon': 83.2185,
      'sector': 'North Andhra & Odisha Coast',
    },
    {
      'name': 'Kanyakumari Coast',
      'lat': 8.0883,
      'lon': 77.5385,
      'sector': 'Gulf of Mannar & Comorin Sea',
    },
  ];

  late double _currentLat;
  late double _currentLon;
  late String _currentLocationName;

  @override
  void initState() {
    super.initState();
    final weatherProv = Provider.of<WeatherProvider>(context, listen: false);
    _currentLat = widget.initialLat ?? weatherProv.latitude;
    _currentLon = widget.initialLon ?? weatherProv.longitude;
    _currentLocationName = widget.initialLocationName ?? weatherProv.locationName;
    _loadMarineData();
  }

  Future<void> _loadMarineData() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiService.getMarineAdvisory(
        latitude: _currentLat,
        longitude: _currentLon,
        locationName: _currentLocationName,
      );
      if (mounted) {
        setState(() {
          _advisory = res;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _advisory = MarineAdvisoryModel.defaultFallback(_currentLocationName);
          _isLoading = false;
        });
      }
    }
  }

  void _selectPreset(Map<String, dynamic> preset) {
    setState(() {
      _currentLat = preset['lat'];
      _currentLon = preset['lon'];
      _currentLocationName = preset['name'];
    });
    _loadMarineData();
  }

  Color _getSwellSurgeColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'severe kallakkadal event':
      case 'warning':
        return AppColors.alertRed;
      case 'watch':
        return AppColors.alertAmber;
      default:
        return AppColors.alertGreen;
    }
  }

  Color _getSeaConditionColor(String colorStr) {
    switch (colorStr.toLowerCase()) {
      case 'red':
        return AppColors.alertRed;
      case 'orange':
        return AppColors.alertOrange;
      case 'yellow':
        return AppColors.alertAmber;
      case 'green':
        return AppColors.alertGreen;
      default:
        return AppColors.brandBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = AppColors.background(isDark);
    final surface = AppColors.surface(isDark);
    final textPrimary = AppColors.textPrimaryC(isDark);
    final textSecondary = AppColors.textSecondaryC(isDark);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'INCOIS Ocean & Marine State',
              style: TextStyle(
                color: textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'High Wave, Kallakkadal & Mariner Advisory',
              style: TextStyle(
                color: textSecondary,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh marine forecast',
            onPressed: _isLoading ? null : _loadMarineData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SpinKitWave(color: AppColors.brandBlue, size: 36),
                  const SizedBox(height: 16),
                  Text(
                    'Loading oceanographic state...',
                    style: TextStyle(color: textSecondary, fontSize: 13),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadMarineData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Offline / Provenance Banner
                    _buildHeaderBanner(isDark, surface, textPrimary, textSecondary),
                    const SizedBox(height: 16),

                    // Preset Coastal Locations Pill Bar
                    _buildPresetSelector(isDark),
                    const SizedBox(height: 16),

                    // Inland state notification
                    if (_advisory != null && !_advisory!.isCoastalLocation)
                      _buildInlandNotice(isDark, surface, textPrimary, textSecondary)
                    else if (_advisory != null) ...[
                      // 1. Swell Surge / Kallakkadal Warning Card
                      _buildKallakkadalSurgeCard(isDark, surface, textPrimary, textSecondary),
                      const SizedBox(height: 16),

                      // 2. IMD Port Warning Signal Card (1-11 scale)
                      _buildPortWarningCard(isDark, surface, textPrimary, textSecondary),
                      const SizedBox(height: 16),

                      // 3. Artisanal & Commercial Fishermen Directives (3-Tiers)
                      _buildVesselDirectivesCard(isDark, surface, textPrimary, textSecondary),
                      const SizedBox(height: 16),

                      // 4. Oceanographic Metrics Grid (Wave, Swell, Wind, SST, Tide)
                      _buildOceanMetricsGrid(isDark, surface, textPrimary, textSecondary),
                      const SizedBox(height: 16),

                      // 5. Potential Fishing Zone (PFZ) & Chlorophyll Card
                      _buildPfzCard(isDark, surface, textPrimary, textSecondary),
                      const SizedBox(height: 16),

                      // 6. Multilingual Coastal Directives (EN, TA, ML, HI)
                      _buildMultilingualSection(isDark, surface, textPrimary, textSecondary),
                    ],

                    const SizedBox(height: 24),
                    _buildOfficialFooter(isDark, textSecondary),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderBanner(bool isDark, Color surface, Color textPrimary, Color textSecondary) {
    final advisory = _advisory;
    final isCached = advisory?.isOfflineCached ?? false;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCached ? AppColors.alertAmber.withValues(alpha: 0.6) : AppColors.border(isDark),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.brandBlue.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.waves_rounded, color: AppColors.brandBlue, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        advisory?.coastalSectorName ?? 'Indian Peninsular Waters',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCached) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.alertAmber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'OFFLINE',
                          style: TextStyle(
                            color: AppColors.alertAmber,
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Location: $_currentLocationName • Valid: ${advisory?.date ?? 'Today'}',
                  style: TextStyle(color: textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetSelector(bool isDark) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _coastalPresets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final p = _coastalPresets[idx];
          final isSelected = _currentLocationName == p['name'];
          return ChoiceChip(
            label: Text(
              p['name'],
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            selected: isSelected,
            selectedColor: AppColors.brandBlue,
            backgroundColor: isDark ? const Color(0xFF1E2638) : const Color(0xFFE8EEF5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            showCheckmark: false,
            onSelected: (_) => _selectPreset(p),
          );
        },
      ),
    );
  }

  Widget _buildInlandNotice(bool isDark, Color surface, Color textPrimary, Color textSecondary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Column(
        children: [
          const Icon(Icons.terrain_rounded, color: AppColors.brandBlue, size: 48),
          const SizedBox(height: 12),
          Text(
            'Inland Territory Notice',
            style: TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$_currentLocationName is an inland district with no direct marine coastline. Ocean wave heights, Kallakkadal swell surges, and port signals apply to coastal maritime sectors. You can explore maritime conditions for key ports using the presets above.',
            textAlign: TextAlign.center,
            style: TextStyle(color: textSecondary, fontSize: 12.5, height: 1.4),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.sailing_rounded, size: 18),
            label: const Text('View Chennai Marina Ocean State'),
            onPressed: () => _selectPreset(_coastalPresets[0]),
          ),
        ],
      ),
    );
  }

  Widget _buildKallakkadalSurgeCard(bool isDark, Color surface, Color textPrimary, Color textSecondary) {
    final advisory = _advisory!;
    final surgeRisk = advisory.kallakkadalSurgeRisk;
    final riskColor = _getSwellSurgeColor(surgeRisk);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: riskColor.withValues(alpha: 0.8), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.tsunami_rounded, color: riskColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Kallakkadal Swell Surge',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: riskColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            surgeRisk.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Southern Ocean Swell Inundation Alert',
                      style: TextStyle(color: textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            advisory.kallakkadalExplanation ??
                'Southern Ocean swells (${advisory.swellPeriodSeconds}s period) can cause sudden flooding of foreshore areas even during calm local winds.',
            style: TextStyle(color: textPrimary, fontSize: 12.5, height: 1.4),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B2333) : const Color(0xFFEFF5FC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSwellMetric('Swell Height', '${advisory.swellHeightM.toStringAsFixed(1)} m', isDark),
                _buildSwellMetric('Swell Period', '${advisory.swellPeriodSeconds.toStringAsFixed(1)} s', isDark),
                _buildSwellMetric('Direction', advisory.swellDirectionCardinal, isDark),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.brandBlue, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Physical Warning: Swell surges hit beaches with high kinetic energy. Fishing crafts must remain anchored beyond 3 nautical miles or pulled up beyond the spring high-tide waterline.',
                  style: TextStyle(color: textSecondary, fontSize: 11, height: 1.3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwellMetric(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimaryC(isDark),
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondaryC(isDark),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildPortWarningCard(bool isDark, Color surface, Color textPrimary, Color textSecondary) {
    final advisory = _advisory!;
    final signalNum = advisory.portWarningSignalNumber;
    final hasWarning = signalNum > 0;
    final sigColor = signalNum >= 4
        ? AppColors.alertRed
        : (signalNum >= 1 ? AppColors.alertAmber : AppColors.alertGreen);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: sigColor.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: sigColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.flag_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      hasWarning ? 'SIGNAL $signalNum' : 'NO SIGNAL',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      advisory.portWarningSignalName,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Official IMD 1-11 Port Maritime Scale',
                      style: TextStyle(color: textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            advisory.portWarningSignalDescription,
            style: TextStyle(color: textPrimary, fontSize: 12.5, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildVesselDirectivesCard(bool isDark, Color surface, Color textPrimary, Color textSecondary) {
    final advisory = _advisory!;
    final directives = advisory.vesselCategoryDirectives;

    final catamaranText = directives['catamarans_country_craft'] as String? ??
        'Exercise high vigilance near coastal breakers. Do not beach land during swell alerts.';
    final frpText = directives['motorized_frp_boats'] as String? ??
        'Safe beyond surf break; keep engines idling and avoid shallow reef passes.';
    final trawlerText = directives['mechanized_trawlers'] as String? ??
        'Deep sea voyages permitted; monitor VHF Marine Channel 16 for IMD squall bulletins.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_boat_rounded, color: AppColors.brandBlue, size: 22),
              const SizedBox(width: 10),
              Text(
                'Fleet Safety Directives (3 Tiers)',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildVesselRow(
            title: '1. Catamarans & Traditional Craft',
            desc: catamaranText,
            color: AppColors.alertOrange,
            icon: Icons.sailing_rounded,
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          _buildVesselRow(
            title: '2. FRP Motorized Craft (Outboard)',
            desc: frpText,
            color: AppColors.brandBlue,
            icon: Icons.speed_rounded,
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          _buildVesselRow(
            title: '3. Mechanized Multi-Day Trawlers',
            desc: trawlerText,
            color: AppColors.alertGreen,
            icon: Icons.directions_boat_filled_rounded,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildVesselRow({
    required String title,
    required String desc,
    required Color color,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2234) : const Color(0xFFF6F8FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimaryC(isDark),
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    color: AppColors.textSecondaryC(isDark),
                    fontSize: 11.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOceanMetricsGrid(bool isDark, Color surface, Color textPrimary, Color textSecondary) {
    final advisory = _advisory!;
    final seaColor = _getSeaConditionColor(advisory.seaConditionColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Oceanographic Metrics',
          style: TextStyle(
            color: textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.75,
          children: [
            _buildMetricTile(
              label: 'Significant Wave Height',
              val: '${advisory.significantWaveHeightM.toStringAsFixed(1)} m',
              sub: advisory.seaCondition,
              color: seaColor,
              icon: Icons.water_rounded,
              isDark: isDark,
            ),
            _buildMetricTile(
              label: 'Coastal Winds & Gusts',
              val: '${advisory.coastalWindKnots} kts (${advisory.coastalWindKmH.round()} km/h)',
              sub: 'Gusts ${advisory.windGustsKmH.round()} km/h ${advisory.windDirectionCardinal}',
              color: AppColors.brandBlue,
              icon: Icons.air_rounded,
              isDark: isDark,
            ),
            _buildMetricTile(
              label: 'Sea Surface Temp (SST)',
              val: '${advisory.seaSurfaceTemperatureC.toStringAsFixed(1)}°C',
              sub: 'Tropical Thermal Baseline',
              color: AppColors.alertAmber,
              icon: Icons.thermostat_rounded,
              isDark: isDark,
            ),
            _buildMetricTile(
              label: 'Astronomical Tides',
              val: 'High: ${advisory.tideHighHeightM}m (${advisory.tideHighTime})',
              sub: 'Low: ${advisory.tideLowHeightM}m (${advisory.tideLowTime})',
              color: AppColors.accentTeal,
              icon: Icons.access_time_filled_rounded,
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String val,
    required String sub,
    required Color color,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textSecondaryC(isDark),
                    fontSize: 10.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            val,
            style: TextStyle(
              color: AppColors.textPrimaryC(isDark),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPfzCard(bool isDark, Color surface, Color textPrimary, Color textSecondary) {
    final advisory = _advisory!;
    final isHigh = advisory.potentialFishingZoneStatus.toLowerCase().contains('high');
    final pfzColor = isHigh ? AppColors.alertGreen : AppColors.brandBlue;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.explore_rounded, color: AppColors.brandBlue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'INCOIS Potential Fishing Zone (PFZ)',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: pfzColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  advisory.potentialFishingZoneStatus,
                  style: TextStyle(
                    color: pfzColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bearing & Distance',
                      style: TextStyle(color: textSecondary, fontSize: 11),
                    ),
                    Text(
                      '${advisory.pfzBearingDirection} • ${advisory.pfzDistanceNauticalMiles} NM',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chlorophyll-a Plankton',
                      style: TextStyle(color: textSecondary, fontSize: 11),
                    ),
                    Text(
                      '${advisory.chlorophyllAMgM3} mg/m³',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMultilingualSection(bool isDark, Color surface, Color textPrimary, Color textSecondary) {
    final advisory = _advisory!;
    final directives = advisory.vernacularCoastalDirectives;

    String currentText = advisory.fishermenWarningText;
    if (_selectedLang == 'ta' && directives['ta'] != null) {
      currentText = directives['ta'];
    } else if (_selectedLang == 'ml' && directives['ml'] != null) {
      currentText = directives['ml'];
    } else if (_selectedLang == 'hi' && directives['hi'] != null) {
      currentText = directives['hi'];
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final chips = [
                _buildLangChip('EN', 'en', isDark),
                const SizedBox(width: 4),
                _buildLangChip('தமிழ்', 'ta', isDark),
                const SizedBox(width: 4),
                _buildLangChip('മലയാളം', 'ml', isDark),
                const SizedBox(width: 4),
                _buildLangChip('हिंदी', 'hi', isDark),
              ];

              if (constraints.maxWidth < 420) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Coastal Warnings (Multilingual)',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: chips),
                    ),
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Coastal Warnings (Multilingual)',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(children: chips),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2638) : const Color(0xFFEFF5FC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              currentText,
              style: TextStyle(
                color: textPrimary,
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLangChip(String label, String code, bool isDark) {
    final isSelected = _selectedLang == code;
    return GestureDetector(
      onTap: () => setState(() => _selectedLang = code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandBlue : (isDark ? const Color(0xFF2A344A) : const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildOfficialFooter(bool isDark, Color textSecondary) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_user_rounded, color: AppColors.brandBlue, size: 14),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                _advisory?.officialAuthority ??
                    'INCOIS (Indian National Centre for Ocean Information Services) & IMD Marine Division',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Physical Southern Ocean Swell & Kallakkadal Early Warning Architecture',
          style: TextStyle(color: textSecondary.withValues(alpha: 0.8), fontSize: 9.5),
        ),
      ],
    );
  }
}
