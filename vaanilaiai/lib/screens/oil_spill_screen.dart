import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/oil_spill_model.dart';
import '../services/api_service.dart';

class OilSpillScreen extends StatefulWidget {
  final OilSpillResponseModel? initialData;
  final ApiService? apiService;

  const OilSpillScreen({
    super.key,
    this.initialData,
    this.apiService,
  });

  @override
  State<OilSpillScreen> createState() => _OilSpillScreenState();
}

class _OilSpillScreenState extends State<OilSpillScreen> {
  late ApiService _apiService;
  OilSpillResponseModel? _data;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCorridorId = 'gulf_of_kutch_vadinar';
  String _selectedLangCode = 'en';

  final List<Map<String, String>> _corridors = [
    {'id': 'gulf_of_kutch_vadinar', 'name': 'Gulf of Kutch (GJ)'},
    {'id': 'mumbai_harbour_uran', 'name': 'Mumbai & JNPT (MH)'},
    {'id': 'gulf_of_mannar_pamban', 'name': 'Gulf of Mannar (TN)'},
    {'id': 'gahirmatha_olive_ridley', 'name': 'Gahirmatha Turtles (OD)'},
    {'id': 'sundarbans_hooghly', 'name': 'Sundarbans Delta (WB)'},
    {'id': 'vembanad_cochin', 'name': 'Cochin & Vembanad (KL)'},
    {'id': 'andaman_malacca_corridor', 'name': 'Nicobar & Malacca (A&N)'},
  ];

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'label': 'English'},
    {'code': 'ta', 'label': 'தமிழ்'},
    {'code': 'bn', 'label': 'বাংলা'},
    {'code': 'ml', 'label': 'മലയാളം'},
    {'code': 'gu', 'label': 'ગુજરાતી'},
    {'code': 'mr', 'label': 'मराठी'},
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
      _fetchOilSpillAssessment();
    }
  }

  Future<void> _fetchOilSpillAssessment() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _apiService.getOilSpillAssessment(
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
          _errorMessage =
              'Failed to load live INCOIS spill telemetry. Reverting to calibrated offline baseline.';
          _data = OilSpillResponseModel.defaultFallback();
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
    _fetchOilSpillAssessment();
  }

  Color _getTierColor(String tier) {
    switch (tier.toUpperCase()) {
      case 'TIER_3_NATIONAL_NOSDCP':
        return const Color(0xFFEF4444); // Crimson Red
      case 'TIER_2_REGIONAL_COAST_GUARD':
        return const Color(0xFFF97316); // Orange
      case 'TIER_1_LOCAL_PORT':
      default:
        return const Color(0xFFFBBF24); // Amber
    }
  }

  String _formatTierTitle(String tier) {
    switch (tier.toUpperCase()) {
      case 'TIER_3_NATIONAL_NOSDCP':
        return 'TIER 3 · NATIONAL NOS-DCP CRISIS';
      case 'TIER_2_REGIONAL_COAST_GUARD':
        return 'TIER 2 · REGIONAL COAST GUARD';
      case 'TIER_1_LOCAL_PORT':
      default:
        return 'TIER 1 · LOCAL PORT AUTHORITY';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF071426) : const Color(0xFFF1F5F9);
    final cardBg = isDark ? const Color(0xFF0C223E) : Colors.white;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white70 : const Color(0xFF475569);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Marine Oil Spill & Habitat Radar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'INCOIS · Indian Coast Guard (NOS-DCP)',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Spill Telemetry',
            onPressed: _fetchOilSpillAssessment,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'NOS-DCP & Fay Spreading Guide',
            onPressed: () => _showGuideDialog(context),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SpinKitWaveSpinner(
                    color: Color(0xFF00B4D8),
                    size: 60.0,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Modeling Advection Drift & Fay Weathering Kinetics...',
                    style: TextStyle(color: secondaryTextColor),
                  ),
                ],
              ),
            )
          : _data == null
              ? Center(
                  child: Text(
                    _errorMessage ?? 'No oil spill telemetry available.',
                    style: TextStyle(color: secondaryTextColor),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchOilSpillAssessment,
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
                                    'Serving calibrated INCOIS/ICG offline baseline. Connect to network for live AIS radar.',
                                    style: TextStyle(color: Color(0xFFE65100), fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // 1. Coastal Corridor Selector Chips
                        _buildCorridorSelector(isDark),
                        const SizedBox(height: 12),

                        // 2. Hero Oil Spill Severity Banner
                        _buildHeroSpillBanner(isDark, cardBg, primaryTextColor, secondaryTextColor),
                        const SizedBox(height: 16),

                        // 3. Hydrodynamic Drift & 72h Trajectory Waypoints
                        _buildDriftTrajectoryCard(isDark, cardBg, primaryTextColor, secondaryTextColor),
                        const SizedBox(height: 16),

                        // 4. Fay Spreading Regimes & Chemical Weathering HUD
                        _buildSpreadingAndWeatheringCard(isDark, cardBg, primaryTextColor, secondaryTextColor),
                        const SizedBox(height: 16),

                        // 5. Sensitive Marine Habitats & ESI Protection Card
                        _buildSensitiveHabitatsCard(isDark, cardBg, primaryTextColor, secondaryTextColor),
                        const SizedBox(height: 16),

                        // 6. Indian Coast Guard (ICG) NOS-DCP Response Directives
                        _buildIcgDirectivesCard(isDark, cardBg, primaryTextColor, secondaryTextColor),
                        const SizedBox(height: 16),

                        // 7. Multi-Lingual Coastal Emergency Bulletins
                        _buildVernacularBulletinsCard(isDark, cardBg, primaryTextColor, secondaryTextColor),
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
            selectedColor: const Color(0xFF0284C7),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
            backgroundColor: isDark ? const Color(0xFF0F2644) : const Color(0xFFE2E8F0),
            onSelected: (_) => _onCorridorSelected(c['id']!),
          );
        },
      ),
    );
  }

  Widget _buildHeroSpillBanner(
    bool isDark,
    Color cardBg,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    final corridor = _data!.selectedCorridor;
    final tierColor = _getTierColor(corridor.severityTier);
    final earliestEta = corridor.sensitiveHabitats.isNotEmpty
        ? corridor.sensitiveHabitats.first.estimatedImpactEtaHours
        : 12;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tierColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: tierColor.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      corridor.corridorName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${corridor.stateOrUt} · Origin: ${corridor.latitude.toStringAsFixed(2)}°N, ${corridor.longitude.toStringAsFixed(2)}°E',
                      style: TextStyle(fontSize: 12, color: secondaryTextColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: tierColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: tierColor),
                ),
                child: Text(
                  _formatTierTitle(corridor.severityTier),
                  style: TextStyle(
                    color: tierColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                corridor.spillVolumeTonnes.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: primaryTextColor,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tonnes Spilled',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: tierColor,
                      ),
                    ),
                    Text(
                      corridor.oilType.replaceAll('_', ' '),
                      style: TextStyle(fontSize: 11.5, color: secondaryTextColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHeroMetric(
                'Net Drift Speed',
                '${corridor.driftVector.netDriftSpeedKnots.toStringAsFixed(1)} kt',
                Icons.waves_rounded,
                const Color(0xFF38BDF8),
                secondaryTextColor,
              ),
              _buildHeroMetric(
                'Drift Heading',
                '${corridor.driftVector.netDriftDirectionDeg.toStringAsFixed(0)}° Az',
                Icons.navigation_rounded,
                const Color(0xFF00B4D8),
                secondaryTextColor,
              ),
              _buildHeroMetric(
                'Habitat Arrival',
                '$earliestEta Hours',
                Icons.timer_rounded,
                tierColor,
                secondaryTextColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroMetric(
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
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, color: secondaryTextColor)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDriftTrajectoryCard(
    bool isDark,
    Color cardBg,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    final drift = _data!.selectedCorridor.driftVector;
    final waypoints = _data!.selectedCorridor.trajectoryWaypoints;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.alt_route_rounded, color: Color(0xFF38BDF8), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Hydrodynamic Drift & 72h Trajectory',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B4D8).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '3% Leeway + Current',
                  style: TextStyle(
                    color: Color(0xFF00B4D8),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  'Tidal Current',
                  '${drift.surfaceCurrentSpeedKnots.toStringAsFixed(1)} kt',
                  'Heading: ${drift.surfaceCurrentDirectionDeg.toStringAsFixed(0)}°',
                  const Color(0xFF38BDF8),
                  primaryTextColor,
                  secondaryTextColor,
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  'Surface Wind',
                  '${drift.windSpeed10mKnots.toStringAsFixed(1)} kt',
                  'From: ${drift.windDirectionDeg.toStringAsFixed(0)}°',
                  const Color(0xFFF59E0B),
                  primaryTextColor,
                  secondaryTextColor,
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  'Stokes Wave Drift',
                  '${drift.stokesDriftKnots.toStringAsFixed(2)} kt',
                  'Wave advection',
                  const Color(0xFF10B981),
                  primaryTextColor,
                  secondaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Trajectory Waypoints (Landfall Projections):',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...waypoints.map((wp) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF081A30) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '+${wp.timeHorizonHours}h',
                          style: const TextStyle(
                            color: Color(0xFF38BDF8),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${wp.latitude.toStringAsFixed(2)}°N, ${wp.longitude.toStringAsFixed(2)}°E',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${wp.distanceTraveledKm.toStringAsFixed(1)} km · Area: ${wp.slickAreaKm2.toStringAsFixed(1)} km²',
                            style: TextStyle(fontSize: 10.5, color: secondaryTextColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    wp.shorelineHitRisk.replaceAll('_', ' '),
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: wp.shorelineHitRisk.contains('IMMINENT') ||
                              wp.shorelineHitRisk.contains('BEACHED')
                          ? const Color(0xFFEF4444)
                          : const Color(0xFFF59E0B),
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

  Widget _buildSpreadingAndWeatheringCard(
    bool isDark,
    Color cardBg,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    final fay = _data!.selectedCorridor.faySpreading;
    final w = _data!.selectedCorridor.weathering;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.bubble_chart_rounded, color: Color(0xFFF59E0B), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Fay Spreading & Chemical Weathering HUD',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                fay.currentRegime.replaceAll('_', ' '),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildBigStat(
                  'Slick Area',
                  '${fay.slickAreaKm2.toStringAsFixed(1)} km²',
                  'Radius: ${(fay.slickRadiusMeters / 1000.0).toStringAsFixed(1)} km',
                  const Color(0xFF38BDF8),
                ),
              ),
              Expanded(
                child: _buildBigStat(
                  'Avg Thickness',
                  '${fay.averageThicknessMicrons.toStringAsFixed(0)} µm',
                  fay.bonnCode.replaceAll('_', ' '),
                  const Color(0xFFF59E0B),
                ),
              ),
              Expanded(
                child: _buildBigStat(
                  'Evaporation',
                  '${w.evaporatedFractionPct.toStringAsFixed(1)}%',
                  'Flash pt: ${w.flashPointCelsius.toStringAsFixed(0)}°C',
                  const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF081A30) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('Emulsification (Mousse)',
                        style: TextStyle(fontSize: 11, color: secondaryTextColor)),
                    const SizedBox(height: 4),
                    Text(
                      '${w.emulsifiedWaterFractionPct.toStringAsFixed(0)}% Water',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text('Viscosity Surge',
                        style: TextStyle(fontSize: 11, color: secondaryTextColor)),
                    const SizedBox(height: 4),
                    Text(
                      '${w.viscosityIncreaseFactor.toStringAsFixed(0)}x (${w.emulsionViscosityCst.toStringAsFixed(0)} cSt)',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text('Natural Dispersion',
                        style: TextStyle(fontSize: 11, color: secondaryTextColor)),
                    const SizedBox(height: 4),
                    Text(
                      '${w.naturalDispersionFractionPct.toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
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

  Widget _buildSensitiveHabitatsCard(
    bool isDark,
    Color cardBg,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    final habitats = _data!.selectedCorridor.sensitiveHabitats;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.park_rounded, color: Color(0xFF10B981), size: 20),
              SizedBox(width: 8),
              Text(
                'Sensitive Coastal Habitats & ESI Priority',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...habitats.map((hab) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF081A30) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hab.esiRating >= 9
                      ? const Color(0xFFEF4444).withValues(alpha: 0.5)
                      : (isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE2E8F0)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          hab.habitatName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ESI ${hab.esiRating}/10',
                          style: const TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        hab.ecosystemType,
                        style: TextStyle(fontSize: 11, color: secondaryTextColor),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Distance: ${hab.distanceFromSlickKm.toStringAsFixed(1)} km · ETA: ${hab.estimatedImpactEtaHours}h',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0C223E) : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      hab.boomDefensePlan,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF),
                        fontWeight: FontWeight.w500,
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

  Widget _buildIcgDirectivesCard(
    bool isDark,
    Color cardBg,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    final icg = _data!.selectedCorridor.icgDirectives;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.shield_rounded, color: Color(0xFFEF4444), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Indian Coast Guard (NOS-DCP) Directives',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'HOTLINE: 1554',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDirectiveBullet(
            'Lead Authority',
            icg.leadResponseAuthority,
            Icons.account_balance_rounded,
            primaryTextColor,
            secondaryTextColor,
          ),
          _buildDirectiveBullet(
            'Boom Deployment',
            '${icg.containmentBoomType} · Deploy ${icg.recommendedBoomLengthMeters.toStringAsFixed(0)}m (Tow Speed Cap: ${icg.maximumTowingSpeedKnots} kt)',
            Icons.linear_scale_rounded,
            primaryTextColor,
            secondaryTextColor,
          ),
          _buildDirectiveBullet(
            'Skimmer Selection',
            icg.skimmerSelection,
            Icons.build_circle_rounded,
            primaryTextColor,
            secondaryTextColor,
          ),
          _buildDirectiveBullet(
            'Chemical Dispersant',
            '${icg.chemicalDispersantClearance} (${icg.dispersantRestrictions})',
            Icons.science_rounded,
            primaryTextColor,
            secondaryTextColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDirectiveBullet(
    String title,
    String detail,
    IconData icon,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFFEF4444)),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: '$title: ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
                children: [
                  TextSpan(
                    text: detail,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVernacularBulletinsCard(
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
        border: Border.all(color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.campaign_rounded, color: Color(0xFF38BDF8), size: 20),
              SizedBox(width: 8),
              Text(
                'Coastal Multi-Lingual Emergency Bulletin',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
                  selectedColor: const Color(0xFF0284C7),
                  labelStyle: TextStyle(
                    color: isSel ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    fontSize: 12,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: isDark ? const Color(0xFF0F2644) : const Color(0xFFE2E8F0),
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
              color: isDark ? const Color(0xFF081A30) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFCBD5E1),
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

  Widget _buildMetricTile(
    String label,
    String primary,
    String secondary,
    Color accentColor,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: secondaryTextColor)),
        const SizedBox(height: 3),
        Text(
          primary,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: accentColor,
          ),
        ),
        Text(
          secondary,
          style: TextStyle(fontSize: 10, color: secondaryTextColor),
        ),
      ],
    );
  }

  Widget _buildBigStat(
    String label,
    String value,
    String subtitle,
    Color valueColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: valueColor,
          ),
        ),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  void _showGuideDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('INCOIS Oil Spill & NOS-DCP Guide'),
        content: const SingleChildScrollView(
          child: Text(
            '• Advection Kinematics: Surface slicks drift under combined tidal currents, '
            '3% wind leeway at 10m height, and Stokes wave drift.\n\n'
            '• Fay Spreading Regimes: Spreading progresses from Gravity-Inertia (Regime I) '
            'to Gravity-Viscous (Regime II) and Viscous-Surface Tension (Regime III).\n\n'
            '• Chemical Weathering: Volatile hydrocarbons evaporate (30-60%) while water uptake '
            'creates viscous water-in-oil emulsions ("chocolate mousse").\n\n'
            '• Environmental Sensitivity Index (ESI): ESI 10 habitats (corals, mangroves, turtle '
            'rookeries) receive highest containment boom priority.\n\n'
            '• NOS-DCP Response: Tier 1 (<700t), Tier 2 (700-10,000t), and Tier 3 (>10,000t). '
            'Indian Coast Guard hotline 1554.',
            style: TextStyle(fontSize: 13, height: 1.4),
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
