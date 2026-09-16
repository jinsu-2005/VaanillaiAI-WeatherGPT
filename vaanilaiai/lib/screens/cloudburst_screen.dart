import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/cloudburst_model.dart';
import '../services/api_service.dart';

class CloudburstScreen extends StatefulWidget {
  final CloudburstResponseModel? initialData;
  final ApiService? apiService;

  const CloudburstScreen({
    super.key,
    this.initialData,
    this.apiService,
  });

  @override
  State<CloudburstScreen> createState() => _CloudburstScreenState();
}

class _CloudburstScreenState extends State<CloudburstScreen> {
  late ApiService _apiService;
  CloudburstResponseModel? _data;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCatchmentId = 'kedarnath_mandakini';
  String _selectedLangCode = 'en';

  final List<Map<String, String>> _catchments = [
    {'id': 'kedarnath_mandakini', 'name': 'Kedarnath / Mandakini (UK)'},
    {'id': 'wayanad_vythiri_meppadi', 'name': 'Wayanad / Meppadi (KL)'},
    {'id': 'kullu_manali_beas', 'name': 'Kullu-Manali / Beas (HP)'},
    {'id': 'mahabaleshwar_koyna', 'name': 'Mahabaleshwar / Koyna (MH)'},
    {'id': 'nilgiris_coonoor_ooty', 'name': 'Nilgiris / Coonoor (TN)'},
    {'id': 'chamoli_joshimath_dhauliganga', 'name': 'Joshimath / Chamoli (UK)'},
    {'id': 'darjeeling_teesta_canyon', 'name': 'Darjeeling / Teesta (WB)'},
  ];

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'label': 'English'},
    {'code': 'hi', 'label': 'हिंदी'},
    {'code': 'ml', 'label': 'മലയാളം'},
    {'code': 'mr', 'label': 'मराठी'},
    {'code': 'ta', 'label': 'தமிழ்'},
  ];

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    if (widget.initialData != null) {
      _data = widget.initialData;
      _selectedCatchmentId = widget.initialData!.selectedCatchment.catchmentId;
    } else {
      _fetchCloudburstData();
    }
  }

  Future<void> _fetchCloudburstData({String? catchmentId}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _apiService.getCloudburstAssessment(
        catchmentId: catchmentId ?? _selectedCatchmentId,
      );
      setState(() {
        _data = res;
        _selectedCatchmentId = res.selectedCatchment.catchmentId;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load mountain hazard intelligence: $e';
        _isLoading = false;
      });
    }
  }

  Color _getCategoryColor(String cat) {
    final upper = cat.toUpperCase();
    if (upper.contains('CLOUDBURST') && !upper.contains('MINI')) {
      return const Color(0xFFDC2626); // Crimson
    } else if (upper.contains('MINI')) {
      return const Color(0xFFEA580C); // Dark Orange
    } else if (upper.contains('HEAVY')) {
      return const Color(0xFFEAB308); // Amber
    }
    return const Color(0xFF10B981); // Emerald
  }

  String _formatCategoryLabel(String cat) {
    switch (cat.toUpperCase()) {
      case 'CLOUDBURST':
        return 'CLOUDBURST (≥100 mm/h)';
      case 'MINI_CLOUDBURST':
        return 'MINI-CLOUDBURST (50-99 mm/h)';
      case 'HEAVY_OROGRAPHIC':
        return 'HEAVY OROGRAPHIC RAIN';
      default:
        return 'NORMAL MOUNTAIN RAIN';
    }
  }

  Color _getLandslideColor(String tier) {
    final upper = tier.toUpperCase();
    if (upper.contains('CRITICAL') || upper.contains('FAILURE')) {
      return const Color(0xFFEF4444); // Red
    } else if (upper.contains('HIGH') || upper.contains('WARNING')) {
      return const Color(0xFFF97316); // Orange
    } else if (upper.contains('MODERATE') || upper.contains('WATCH')) {
      return const Color(0xFFEAB308); // Yellow
    }
    return const Color(0xFF10B981); // Emerald
  }

  String _formatLandslideLabel(String tier) {
    switch (tier.toUpperCase()) {
      case 'CRITICAL_IMMINENT_FAILURE':
        return 'CRITICAL IMMINENT FAILURE';
      case 'HIGH_WARNING':
        return 'HIGH LANDSLIDE WARNING';
      case 'MODERATE_WATCH':
        return 'MODERATE LANDSLIDE WATCH';
      default:
        return 'LOW / STABLE SLOPES';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cloudburst & Landslide Debris Flow',
              style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold),
            ),
            Text(
              'Western Ghats & Himalayan Orographic Nowcast',
              style: TextStyle(fontSize: 11, color: Colors.orangeAccent),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Mountain Telemetry',
            onPressed: () => _fetchCloudburstData(catchmentId: _selectedCatchmentId),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: SpinKitPulse(
                color: Colors.orangeAccent,
                size: 55.0,
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.amber),
                        const SizedBox(height: 12),
                        Text(_errorMessage!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _fetchCloudburstData(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _data == null
                  ? const SizedBox.shrink()
                  : RefreshIndicator(
                      onRefresh: () => _fetchCloudburstData(catchmentId: _selectedCatchmentId),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_data!.isOfflineCached) _buildOfflineBanner(),
                            _buildCatchmentSelector(),
                            const SizedBox(height: 16),
                            _buildHeroPrecipitationCard(cardBg),
                            const SizedBox(height: 16),
                            _buildSlopeStabilityCard(cardBg),
                            const SizedBox(height: 16),
                            _buildDebrisHydrodynamicsCard(cardBg),
                            const SizedBox(height: 16),
                            _buildSafetyDirectivesCard(cardBg),
                            const SizedBox(height: 16),
                            _buildMultilingualBulletinCard(cardBg),
                            const SizedBox(height: 16),
                            _buildProvenanceFooter(),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
      ),
      child: const Row(
        children: [
          Icon(Icons.wifi_off, size: 18, color: Colors.amber),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Offline Mode: Displaying cached IMD-GSI Mountain Geohydrology Telemetry.',
              style: TextStyle(fontSize: 12, color: Colors.amber),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatchmentSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SELECT MOUNTAIN CATCHMENT / GORGE',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _catchments.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = _catchments[index];
              final isSelected = cat['id'] == _selectedCatchmentId;
              return ChoiceChip(
                label: Text(
                  cat['name']!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.orangeAccent : null,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected && cat['id'] != _selectedCatchmentId) {
                    setState(() => _selectedCatchmentId = cat['id']!);
                    _fetchCloudburstData(catchmentId: cat['id']!);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeroPrecipitationCard(Color cardBg) {
    final catchment = _data!.selectedCatchment;
    final precip = catchment.orographicPrecipitation;
    final catColor = _getCategoryColor(precip.cloudburstCategory);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardBg,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
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
                        catchment.catchmentName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${catchment.mountainRange} • ${catchment.state} (${catchment.elevationM}m)',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: catColor),
                  ),
                  child: Text(
                    _formatCategoryLabel(precip.cloudburstCategory),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: catColor,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricColumn(
                  'Rain Intensity',
                  '${precip.rainRateMmHr.toStringAsFixed(0)} mm/h',
                  precip.rainRateMmHr >= 100.0 ? 'Cloudburst Rate' : 'Torrential Downpour',
                  catColor,
                ),
                _buildMetricColumn(
                  '3-Hour Total',
                  '${precip.accumulated3hMm.toStringAsFixed(0)} mm',
                  'Rapid Surge',
                  Colors.orangeAccent,
                ),
                _buildMetricColumn(
                  '24-Hour Total',
                  '${precip.accumulated24hMm.toStringAsFixed(0)} mm',
                  'Catchment Load',
                  Colors.amberAccent,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSubMetric(
                  'Doppler Radar Core',
                  '${precip.radarReflectivityDbz.toStringAsFixed(1)} dBZ',
                  Icons.radar,
                  precip.radarReflectivityDbz >= 55 ? Colors.redAccent : Colors.amber,
                ),
                _buildSubMetric(
                  'Cloud Top Height',
                  '${precip.cloudTopHeightKm.toStringAsFixed(1)} km',
                  Icons.cloud,
                  Colors.cyanAccent,
                ),
                _buildSubMetric(
                  'Condensation Level',
                  '${precip.condensationLevelM.toStringAsFixed(0)} m',
                  Icons.arrow_upward,
                  Colors.tealAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlopeStabilityCard(Color cardBg) {
    final stability = _data!.selectedCatchment.slopeStability;
    final riskColor = _getLandslideColor(stability.landslideRiskTier);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardBg,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.terrain_rounded, size: 20, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      'GSI Slope Geotechnical Stability',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: riskColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: riskColor),
                  ),
                  child: Text(
                    _formatLandslideLabel(stability.landslideRiskTier),
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: riskColor),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricColumn(
                  'Factor of Safety (FS)',
                  stability.factorOfSafety.toStringAsFixed(2),
                  stability.factorOfSafety < 1.0 ? 'Active Slump / Failure' : 'Stable Margin',
                  riskColor,
                ),
                _buildMetricColumn(
                  'Pore-Water Pressure',
                  '${(stability.poreWaterPressureRatio * 100).toStringAsFixed(0)}%',
                  stability.poreWaterPressureRatio >= 0.9 ? 'Liquefaction Ready' : 'Sub-saturated',
                  riskColor,
                ),
                _buildMetricColumn(
                  'Slope Angle',
                  '${stability.slopeAngleDegrees.toStringAsFixed(0)}°',
                  stability.slopeAngleDegrees >= 35 ? 'Critical Steepness' : 'Moderate Scarp',
                  Colors.orangeAccent,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSubMetric(
                  '3-Day Antecedent (ARI-3)',
                  '${stability.ari3dayMm.toStringAsFixed(0)} mm',
                  Icons.water_drop,
                  Colors.lightBlueAccent,
                ),
                _buildSubMetric(
                  '15-Day Antecedent (ARI-15)',
                  '${stability.ari15dayMm.toStringAsFixed(0)} mm',
                  Icons.history,
                  Colors.blueAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebrisHydrodynamicsCard(Color cardBg) {
    final hydro = _data!.selectedCatchment.hydrodynamics;
    final stageColor = hydro.flashFloodStage.contains('CATASTROPHIC')
        ? const Color(0xFFEF4444)
        : hydro.flashFloodStage.contains('TORRENTIAL')
            ? const Color(0xFFF97316)
            : const Color(0xFFEAB308);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardBg,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.flood_rounded, size: 20, color: Colors.cyanAccent),
                    SizedBox(width: 8),
                    Text(
                      'Debris Flow & River Hydrodynamics',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: stageColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: stageColor),
                  ),
                  child: Text(
                    hydro.flashFloodStage.replaceAll('_', ' '),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: stageColor),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricColumn(
                  'Peak Discharge',
                  '${hydro.peakDischargeM3S.toStringAsFixed(0)} m³/s',
                  'Runoff Surge',
                  stageColor,
                ),
                _buildMetricColumn(
                  'Debris Slurry Volume',
                  '${(hydro.debrisSlurryVolumeM3 / 1000).toStringAsFixed(0)}k m³',
                  'Boulder Matrix',
                  Colors.amberAccent,
                ),
                _buildMetricColumn(
                  'Boulder Velocity',
                  '${hydro.boulderVelocityMS.toStringAsFixed(1)} m/s',
                  'Surge Front Speed',
                  Colors.cyanAccent,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: stageColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: stageColor.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 18, color: stageColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bridge & Scour Threat: ${hydro.bridgeScourThreat}',
                      style: TextStyle(fontSize: 11, color: stageColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyDirectivesCard(Color cardBg) {
    final dir = _data!.selectedCatchment.directives;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardBg,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.shield_outlined, size: 20, color: Colors.greenAccent),
                SizedBox(width: 8),
                Text(
                  'Mountain Safety & Transit Directives',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildDirectiveItem(
              'Civilian Evacuation Order',
              dir.evacuationOrder,
              Icons.directions_run,
              Colors.redAccent,
            ),
            const SizedBox(height: 10),
            _buildDirectiveItem(
              'Pilgrimage & Trekker Advisory',
              dir.pilgrimageTransitAdvisory,
              Icons.hiking,
              Colors.orangeAccent,
            ),
            const SizedBox(height: 10),
            _buildDirectiveItem(
              'Ghat Road / Mountain Pass Status',
              dir.ghatRoadTransitStatus,
              Icons.traffic,
              Colors.cyanAccent,
            ),
            const SizedBox(height: 10),
            _buildDirectiveItem(
              'Estate & Plantation Protocols',
              dir.plantationWorkerProtocol,
              Icons.agriculture,
              Colors.tealAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectiveItem(String title, String body, IconData icon, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade300, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMultilingualBulletinCard(Color cardBg) {
    final bulletins = _data!.vernacularBulletins;
    final activeText = bulletins[_selectedLangCode] ?? bulletins['en'] ?? 'Bulletin unavailable';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardBg,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.translate, size: 20, color: Colors.tealAccent),
                SizedBox(width: 8),
                Text(
                  'Mountain Emergency Bulletins',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _languages.map((lang) {
                  final isSel = lang['code'] == _selectedLangCode;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: ChoiceChip(
                      label: Text(
                        lang['label']!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSel,
                      visualDensity: VisualDensity.compact,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedLangCode = lang['code']!);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
              ),
              child: Text(
                activeText,
                style: const TextStyle(fontSize: 12, height: 1.45),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, String sub, Color valColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: valColor),
        ),
        const SizedBox(height: 2),
        Text(sub, style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
      ],
    );
  }

  Widget _buildSubMetric(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            Text(
              value,
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProvenanceFooter() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            Text(
              _data!.provenance,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 4),
            Text(
              'GSI National Landslide Early Warning • IMD Mountain Met • Bulletin ${_data!.bulletinNumber}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
