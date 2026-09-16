import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/wind_energy_model.dart';
import '../services/api_service.dart';

class WindEnergyScreen extends StatefulWidget {
  final WindEnergyResponseModel? initialData;
  final ApiService? apiService;

  const WindEnergyScreen({
    super.key,
    this.initialData,
    this.apiService,
  });

  @override
  State<WindEnergyScreen> createState() => _WindEnergyScreenState();
}

class _WindEnergyScreenState extends State<WindEnergyScreen> {
  late ApiService _apiService;
  WindEnergyResponseModel? _data;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCorridorId = 'muppandal_tamil_nadu';
  int _selectedHubHeightM = 100;
  int _selectedTurbineIndex = 1; // Default to 3.0 MW class
  String _selectedLangCode = 'en';

  final List<Map<String, String>> _corridors = [
    {'id': 'muppandal_tamil_nadu', 'name': 'Muppandal (TN)'},
    {'id': 'jaisalmer_rajasthan', 'name': 'Jaisalmer (RJ)'},
    {'id': 'brahmanvel_maharashtra', 'name': 'Brahmanvel (MH)'},
    {'id': 'damanjodi_odisha', 'name': 'Damanjodi (OD)'},
    {'id': 'kayathar_tamil_nadu', 'name': 'Kayathar (TN)'},
    {'id': 'kutch_gujarat', 'name': 'Kutch (GJ)'},
    {'id': 'chitradurga_karnataka', 'name': 'Chitradurga (KA)'},
  ];

  final List<int> _hubHeights = [80, 100, 120, 140, 150];

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'label': 'English'},
    {'code': 'ta', 'label': 'தமிழ்'},
    {'code': 'hi', 'label': 'हिंदी'},
    {'code': 'gu', 'label': 'ગુજરાતી'},
    {'code': 'mr', 'label': 'मराठी'},
    {'code': 'kn', 'label': 'ಕನ್ನಡ'},
    {'code': 'od', 'label': 'ଓଡ଼ିଆ'},
  ];

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    if (widget.initialData != null) {
      _data = widget.initialData;
      _selectedCorridorId = widget.initialData!.selectedCorridor.corridorId;
    } else {
      _fetchWindAssessment();
    }
  }

  Future<void> _fetchWindAssessment() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _apiService.getWindEnergyAssessment(
        corridorId: _selectedCorridorId,
      );
      if (mounted) {
        setState(() {
          _data = res;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load wind resource data. Reverting to offline telemetry.';
          _data = WindEnergyResponseModel.defaultFallback();
          _isLoading = false;
        });
      }
    }
  }

  void _onCorridorSelected(String corridorId) {
    if (_selectedCorridorId == corridorId) return;
    setState(() {
      _selectedCorridorId = corridorId;
    });
    _fetchWindAssessment();
  }

  Color _getTierColor(String tier) {
    switch (tier.toUpperCase()) {
      case 'OUTSTANDING':
        return const Color(0xFF00E676); // Vibrant Green
      case 'EXCELLENT':
        return const Color(0xFF00B0FF); // Sky Blue
      case 'GOOD':
        return const Color(0xFF26C6DA); // Cyan
      case 'MODERATE':
        return const Color(0xFFFFB300); // Amber
      case 'MARGINAL':
        return const Color(0xFFFF7043); // Orange
      case 'POOR':
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  Color _getStateColor(String state) {
    switch (state.toUpperCase()) {
      case 'RATED_FULL_LOAD':
        return const Color(0xFF00E676);
      case 'PARTIAL_LOAD_RAMP':
        return const Color(0xFF29B6F6);
      case 'BELOW_CUT_IN':
        return const Color(0xFFFFB300);
      case 'STORM_CUT_OUT':
      default:
        return const Color(0xFFFF1744);
    }
  }

  HubHeightWindVectorModel _getCurrentVector(WindParkCorridorModel corridor) {
    return corridor.hubHeightProfiles.firstWhere(
      (v) => v.heightM == _selectedHubHeightM,
      orElse: () => corridor.hubHeightProfiles.firstWhere(
        (v) => v.heightM == 100,
        orElse: () => corridor.hubHeightProfiles.first,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0A1926) : const Color(0xFFF0F6FA);
    final cardBg = isDark ? const Color(0xFF132B3C) : Colors.white;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF102A43);
    final secondaryTextColor = isDark ? Colors.white70 : const Color(0xFF627D98);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Wind Energy & Hub-Height Atlas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'NIWE · MNRE · IMD National Grid Forecaster',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFF80DEEA) : const Color(0xFF00838F),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Wind Telemetry',
            onPressed: _fetchWindAssessment,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'Wind Atlas Guide',
            onPressed: () => _showGuideDialog(context),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SpinKitRotatingCircle(
                    color: Color(0xFF00B4D8),
                    size: 50.0,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Extrapolating Hub-Height Wind Shear...',
                    style: TextStyle(color: secondaryTextColor),
                  ),
                ],
              ),
            )
          : _data == null
              ? Center(
                  child: Text(
                    _errorMessage ?? 'No wind telemetry available.',
                    style: TextStyle(color: secondaryTextColor),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchWindAssessment,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Offline notice banner if served from cache
                        if (_data!.offlineCached)
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFFB74D)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.offline_bolt_rounded, color: Color(0xFFE65100), size: 18),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Showing offline NIWE baseline data. Connect to live network for live SCADA updates.',
                                    style: TextStyle(color: Color(0xFFE65100), fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // 1. Corridor Selector Chips
                        _buildCorridorSelector(isDark),
                        const SizedBox(height: 12),

                        // 2. Hub-Height Selection Tabs
                        _buildHubHeightTabs(isDark),
                        const SizedBox(height: 16),

                        // 3. Hero Wind Resource & WPD Card
                        _buildHeroWpdCard(isDark, cardBg, primaryTextColor, secondaryTextColor),
                        const SizedBox(height: 16),

                        // 4. Vertical Wind Shear Profile Visualizer
                        _buildVerticalShearVisualizer(isDark, cardBg, primaryTextColor, secondaryTextColor),
                        const SizedBox(height: 16),

                        // 5. Atmospheric Air Density & Elevation HUD
                        _buildAtmosphericDensityCard(isDark, cardBg, primaryTextColor, secondaryTextColor),
                        const SizedBox(height: 16),

                        // 6. Utility Turbine Generation & Farm Power Curve HUD
                        _buildTurbineGenerationCard(isDark, cardBg, primaryTextColor, secondaryTextColor),
                        const SizedBox(height: 16),

                        // 7. Repowering Feasibility Banner
                        _buildRepoweringBanner(isDark, cardBg, primaryTextColor, secondaryTextColor),
                        const SizedBox(height: 16),

                        // 8. 24-Hour Diurnal Generation Forecast
                        _buildHourlyForecastCard(isDark, cardBg, primaryTextColor, secondaryTextColor),
                        const SizedBox(height: 16),

                        // 9. Regional Language Dispatch Bulletins
                        _buildVernacularBulletinSection(isDark, cardBg, primaryTextColor, secondaryTextColor),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildCorridorSelector(bool isDark) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _corridors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final c = _corridors[index];
          final isSelected = c['id'] == _selectedCorridorId;
          return ChoiceChip(
            label: Text(c['name']!),
            selected: isSelected,
            selectedColor: const Color(0xFF00B4D8),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
            backgroundColor: isDark ? const Color(0xFF1B3A4B) : const Color(0xFFE2E8F0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (_) => _onCorridorSelected(c['id']!),
          );
        },
      ),
    );
  }

  Widget _buildHubHeightTabs(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF132B3C) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: _hubHeights.map((h) {
          final isSelected = h == _selectedHubHeightM;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedHubHeightM = h),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF00B4D8)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${h}m',
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : const Color(0xFF486581)),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeroWpdCard(
    bool isDark,
    Color cardBg,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    final corridor = _data!.selectedCorridor;
    final vector = _getCurrentVector(corridor);
    final tierColor = _getTierColor(vector.resourceTier);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0F3044), const Color(0xFF0A2232)]
              : [const Color(0xFFE0F7FA), const Color(0xFFB2EBF2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00B4D8).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B4D8).withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
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
                    const Icon(Icons.wind_power_rounded, color: Color(0xFF00B4D8), size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            corridor.corridorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                            ),
                          ),
                          Text(
                            '${corridor.state} · ${corridor.installedCapacityMw.toStringAsFixed(0)} MW Installed',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: secondaryTextColor),
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
                  color: tierColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: tierColor),
                ),
                child: Text(
                  vector.resourceTier,
                  style: TextStyle(
                    color: tierColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                vector.windSpeedMs.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: primaryTextColor,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'm/s at ${_selectedHubHeightM}m',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00B4D8),
                      ),
                    ),
                    Text(
                      '${vector.windSpeedKmh.toStringAsFixed(1)} km/h · ${vector.cardinalDirection} (${vector.windDirectionDeg.toStringAsFixed(0)}°)',
                      style: TextStyle(fontSize: 12, color: secondaryTextColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricColumn(
                'Wind Power Density',
                '${vector.windPowerDensityWm2.toStringAsFixed(1)} W/m²',
                Icons.electric_bolt_rounded,
                const Color(0xFF00E676),
                secondaryTextColor,
              ),
              _buildMetricColumn(
                '10m Surface Wind',
                '${corridor.surfaceWind10mMs.toStringAsFixed(1)} m/s',
                Icons.grass_rounded,
                const Color(0xFF48CAE4),
                secondaryTextColor,
              ),
              _buildMetricColumn(
                'Terrain Shear (α)',
                corridor.terrainRoughnessAlpha.toStringAsFixed(2),
                Icons.terrain_rounded,
                const Color(0xFFFFB300),
                secondaryTextColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(
    String label,
    String value,
    IconData icon,
    Color iconColor,
    Color secondaryTextColor,
  ) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: secondaryTextColor),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildVerticalShearVisualizer(
    bool isDark,
    Color cardBg,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    final corridor = _data!.selectedCorridor;
    final maxSpeed = corridor.hubHeightProfiles.last.windSpeedMs;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF1B3A4B) : const Color(0xFFCFD8DC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.stacked_bar_chart_rounded, color: Color(0xFF00B4D8), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Vertical Wind Shear Profile (Hellmann Law)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                'α = ${corridor.terrainRoughnessAlpha}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00B4D8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Power-law wind velocity amplification from 10m surface mast to 150m mega-turbine hub:',
            style: TextStyle(fontSize: 12, color: secondaryTextColor),
          ),
          const SizedBox(height: 16),
          ...corridor.hubHeightProfiles.map((v) {
            final isCurrent = v.heightM == _selectedHubHeightM;
            final fraction = (v.windSpeedMs / (maxSpeed * 1.15)).clamp(0.05, 1.0);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 44,
                    child: Text(
                      '${v.heightM}m',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                        color: isCurrent ? const Color(0xFF00B4D8) : secondaryTextColor,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Stack(
                        children: [
                          Container(
                            height: 20,
                            color: isDark ? const Color(0xFF162D3D) : const Color(0xFFE2E8F0),
                          ),
                          FractionallySizedBox(
                            widthFactor: fraction,
                            child: Container(
                              height: 20,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isCurrent
                                      ? [const Color(0xFF00B4D8), const Color(0xFF00E676)]
                                      : [const Color(0xFF48CAE4), const Color(0xFF90E0EF)],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 72,
                    child: Text(
                      '${v.windSpeedMs.toStringAsFixed(1)} m/s',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                        color: isCurrent ? const Color(0xFF00E676) : primaryTextColor,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      '${v.windPowerDensityWm2.toStringAsFixed(0)} W/m²',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 11,
                        color: _getTierColor(v.resourceTier),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAtmosphericDensityCard(
    bool isDark,
    Color cardBg,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    final density = _data!.selectedCorridor.airDensity;
    final weibull = _data!.selectedCorridor.weibull;
    final elevation = _data!.selectedCorridor.elevationM;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF1B3A4B) : const Color(0xFFCFD8DC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.thermostat_rounded, color: Color(0xFF48CAE4), size: 20),
              SizedBox(width: 8),
              Text(
                'Atmospheric Air Density & Weibull Dynamics',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSubMetric(
                  'Air Density (ρ)',
                  '${density.airDensityKgm3.toStringAsFixed(3)} kg/m³',
                  'Ratio: ${density.densityRatio.toStringAsFixed(3)}',
                  const Color(0xFF00B4D8),
                  primaryTextColor,
                  secondaryTextColor,
                ),
              ),
              Expanded(
                child: _buildSubMetric(
                  'Elevation & Temp',
                  '${elevation.toStringAsFixed(0)}m MSL',
                  '${density.surfaceTemperatureC}°C · ${density.surfacePressureHpa.toStringAsFixed(0)} hPa',
                  const Color(0xFFFFB300),
                  primaryTextColor,
                  secondaryTextColor,
                ),
              ),
              Expanded(
                child: _buildSubMetric(
                  'Weibull (k, c)',
                  'k=${weibull.shapeK.toStringAsFixed(2)}',
                  'c=${weibull.scaleCMs} m/s',
                  const Color(0xFF00E676),
                  primaryTextColor,
                  secondaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F2636) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 16, color: Color(0xFF00B4D8)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    density.thermalDeratingNote,
                    style: TextStyle(fontSize: 12, color: secondaryTextColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubMetric(
    String label,
    String val1,
    String val2,
    Color accentColor,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: secondaryTextColor)),
        const SizedBox(height: 4),
        Text(
          val1,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: accentColor),
        ),
        Text(val2, style: TextStyle(fontSize: 11, color: primaryTextColor)),
      ],
    );
  }

  Widget _buildTurbineGenerationCard(
    bool isDark,
    Color cardBg,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    final turbines = _data!.selectedCorridor.turbineProfiles;
    if (turbines.isEmpty) return const SizedBox.shrink();

    final currentTurbine = turbines[_selectedTurbineIndex.clamp(0, turbines.length - 1)];
    final stateColor = _getStateColor(currentTurbine.operatingState);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF1B3A4B) : const Color(0xFFCFD8DC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.tune_rounded, color: Color(0xFF00E676), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Utility Turbine Generation & Losses',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: stateColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: stateColor),
                ),
                child: Text(
                  currentTurbine.operatingState,
                  style: TextStyle(
                    color: stateColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Turbine selector toggle
          Row(
            children: List.generate(turbines.length, (index) {
              final isSel = index == _selectedTurbineIndex;
              final t = turbines[index];
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index == 0 ? 8 : 0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSel
                          ? const Color(0xFF00B4D8)
                          : (isDark ? const Color(0xFF162D3D) : const Color(0xFFE2E8F0)),
                      foregroundColor: isSel ? Colors.white : primaryTextColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: () => setState(() => _selectedTurbineIndex = index),
                    child: Text(
                      '${t.ratedPowerMw.toStringAsFixed(1)} MW (${t.hubHeightM}m Hub)',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          // Generation outputs
          Row(
            children: [
              Expanded(
                child: _buildBigStat(
                  'Net Output',
                  '${currentTurbine.netHourlyOutputMw.toStringAsFixed(2)} MW',
                  'Gross: ${currentTurbine.grossHourlyOutputMw.toStringAsFixed(2)} MW',
                  const Color(0xFF00E676),
                ),
              ),
              Expanded(
                child: _buildBigStat(
                  'Daily Energy',
                  '${currentTurbine.dailyGenerationMwh.toStringAsFixed(1)} MWh',
                  '24-Hour Production',
                  const Color(0xFF00B4D8),
                ),
              ),
              Expanded(
                child: _buildBigStat(
                  'Plant CUF',
                  '${currentTurbine.capacityUtilizationFactorPct.toStringAsFixed(1)}%',
                  'Capacity Factor',
                  const Color(0xFFFFB300),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Text(
            'Balance of Plant & Micro-Siting Losses:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: secondaryTextColor),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLossItem('Wake Loss', '${currentTurbine.wakeLossPct}%'),
              _buildLossItem('BoP / Grid', '${currentTurbine.bopElectricalLossPct}%'),
              _buildLossItem('Blade Soiling', '${currentTurbine.bladeSoilingLossPct}%'),
              _buildLossItem(
                'Speed Envelope',
                '${currentTurbine.cutInSpeedMs} - ${currentTurbine.cutOutSpeedMs} m/s',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBigStat(String label, String mainVal, String subVal, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          mainVal,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: accent),
        ),
        Text(subVal, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildLossItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildRepoweringBanner(
    bool isDark,
    Color cardBg,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    final repower = _data!.selectedCorridor.repowering;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E3A2F), const Color(0xFF142720)]
              : [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.upgrade_rounded, color: Color(0xFF00E676), size: 22),
                  SizedBox(width: 8),
                  Text(
                    'MNRE Wind Repowering Feasibility',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF00E676)),
                ),
                child: Text(
                  '${repower.repoweringPriority} PRIORITY',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00E676),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Upgrading legacy ${repower.legacyTurbineRatingKw.toStringAsFixed(0)} kW turbines to modern ${repower.modernTurbineRatingMw.toStringAsFixed(1)} MW machines expands annual generation by ${repower.energyYieldMultiplier}x on the same site footprint.',
            style: TextStyle(fontSize: 12, color: primaryTextColor),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.eco_rounded, size: 16, color: Color(0xFF00E676)),
              const SizedBox(width: 6),
              Text(
                'Estimated CO₂ Abatement: ${repower.co2AbatementTonsYr.toStringAsFixed(0)} tons / turbine / year',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00E676),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecastCard(
    bool isDark,
    Color cardBg,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    final forecast = _data!.selectedCorridor.hourlyForecast;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF1B3A4B) : const Color(0xFFCFD8DC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.schedule_rounded, color: Color(0xFF00B4D8), size: 20),
              SizedBox(width: 8),
              Text(
                '24-Hour Diurnal Generation Profile',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: forecast.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final h = forecast[index];
                return Container(
                  width: 76,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F2636) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? const Color(0xFF1B3A4B) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        h.hour,
                        style: TextStyle(fontSize: 11, color: secondaryTextColor),
                      ),
                      Text(
                        '${h.windSpeed100mMs} m/s',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00B4D8),
                        ),
                      ),
                      Text(
                        '${h.cufPct.toStringAsFixed(0)}% CUF',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: h.cufPct >= 40.0
                              ? const Color(0xFF00E676)
                              : (h.cufPct >= 25.0 ? const Color(0xFFFFB300) : Colors.grey),
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

  Widget _buildVernacularBulletinSection(
    bool isDark,
    Color cardBg,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    final bulletins = _data!.bulletins;
    final currentBulletin = bulletins[_selectedLangCode] ?? bulletins['en'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF1B3A4B) : const Color(0xFFCFD8DC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.record_voice_over_rounded, color: Color(0xFF00B4D8), size: 20),
              SizedBox(width: 8),
              Text(
                'Regional Operational Dispatch Bulletin',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Language selector chips
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _languages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final lang = _languages[index];
                final isSel = lang['code'] == _selectedLangCode;
                return ChoiceChip(
                  label: Text(lang['label']!),
                  selected: isSel,
                  selectedColor: const Color(0xFF00B4D8),
                  labelStyle: TextStyle(
                    color: isSel ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    fontSize: 12,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: isDark ? const Color(0xFF162D3D) : const Color(0xFFE2E8F0),
                  onSelected: (_) => setState(() => _selectedLangCode = lang['code']!),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F2636) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? const Color(0xFF1B3A4B) : const Color(0xFFCBD5E1),
              ),
            ),
            child: Text(
              currentBulletin,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: primaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGuideDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.wind_power_rounded, color: Color(0xFF00B4D8)),
            SizedBox(width: 8),
            Text('NIWE Wind Atlas Guide'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1. Hellmann Power-Law Wind Shear:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'v(z) = v(10) × (z / 10)^α\nModels wind speed amplification with altitude over various roughness terrains (α = 0.12 - 0.24).',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 10),
              Text(
                '2. Wind Power Density (WPD):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'WPD = ½ × ρ × v³ (W/m²)\nNIWE Class: Outstanding (≥500), Excellent (400-500), Good (300-400), Moderate (250-300), Marginal (200-250), Poor (<200).',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 10),
              Text(
                '3. Thermal-Barometric Air Density (ρ):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'High ambient temperature thins air, reducing kinetic momentum flux per swept area.',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 10),
              Text(
                '4. MNRE Wind Repowering Policy:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Replacing sub-MW legacy turbines with 2.7-3.0 MW high-hub machines increases energy yield 2.5x to 3.5x.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got It'),
          ),
        ],
      ),
    );
  }
}
