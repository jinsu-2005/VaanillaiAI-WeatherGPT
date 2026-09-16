import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/ocean_state_model.dart';
import '../services/api_service.dart';

class OceanStateScreen extends StatefulWidget {
  final OceanStateResponseModel? initialData;
  final ApiService? apiService;

  const OceanStateScreen({
    super.key,
    this.initialData,
    this.apiService,
  });

  @override
  State<OceanStateScreen> createState() => _OceanStateScreenState();
}

class _OceanStateScreenState extends State<OceanStateScreen> {
  late ApiService _apiService;
  OceanStateResponseModel? _data;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedBeachId = 'puri_golden_beach_or';
  String _selectedLangCode = 'en';

  final List<Map<String, String>> _beaches = [
    {'id': 'puri_golden_beach_or', 'name': 'Puri Beach (OR)'},
    {'id': 'kovalam_vizhinjam_kl', 'name': 'Kovalam Beach (KL)'},
    {'id': 'baga_calangute_beach_ga', 'name': 'Baga & Calangute (GA)'},
    {'id': 'marina_elliots_beach_tn', 'name': 'Marina Beach (TN)'},
    {'id': 'rushikonda_rk_beach_ap', 'name': 'Rushikonda (AP)'},
    {'id': 'somnath_veraval_gj', 'name': 'Somnath Beach (GJ)'},
    {'id': 'digha_mandarmani_wb', 'name': 'Digha Beach (WB)'},
  ];

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'label': 'English'},
    {'code': 'hi', 'label': 'हिंदी'},
    {'code': 'or', 'label': 'ଓଡ଼ିଆ'},
    {'code': 'ml', 'label': 'മലയാളം'},
    {'code': 'mr', 'label': 'मराठी'},
    {'code': 'ta', 'label': 'தமிழ்'},
    {'code': 'te', 'label': 'తెలుగు'},
    {'code': 'gu', 'label': 'ગુજરાતી'},
    {'code': 'bn', 'label': 'বাংলা'},
  ];

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    if (widget.initialData != null) {
      _data = widget.initialData;
      _selectedBeachId = widget.initialData!.selectedBeach.beachId;
    } else {
      _fetchOceanState();
    }
  }

  Future<void> _fetchOceanState({String? beachId}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _apiService.getOceanStateAssessment(
        beachId: beachId ?? _selectedBeachId,
      );
      setState(() {
        _data = res;
        _selectedBeachId = res.selectedBeach.beachId;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load INCOIS ocean state telemetry: $e';
        _isLoading = false;
      });
    }
  }

  Color _getTierColor(String tier) {
    switch (tier.toUpperCase()) {
      case 'RED_WARNING':
        return const Color(0xFFEF4444);
      case 'ORANGE_ALERT':
        return const Color(0xFFF97316);
      case 'YELLOW_WATCH':
        return const Color(0xFFEAB308);
      case 'GREEN_NORMAL':
      default:
        return const Color(0xFF10B981);
    }
  }

  String _getTierLabel(String tier) {
    switch (tier.toUpperCase()) {
      case 'RED_WARNING':
        return 'RED WARNING';
      case 'ORANGE_ALERT':
        return 'ORANGE ALERT';
      case 'YELLOW_WATCH':
        return 'YELLOW WATCH';
      case 'GREEN_NORMAL':
      default:
        return 'GREEN NORMAL';
    }
  }

  Color _getFlagColor(String flag) {
    switch (flag.toUpperCase()) {
      case 'DOUBLE_RED_PROHIBITED':
      case 'RED_HIGH_HAZARD':
        return const Color(0xFFEF4444);
      case 'YELLOW_MEDIUM_HAZARD':
        return const Color(0xFFEAB308);
      case 'GREEN_LOW_HAZARD':
      default:
        return const Color(0xFF10B981);
    }
  }

  String _getFlagTitle(String flag) {
    switch (flag.toUpperCase()) {
      case 'DOUBLE_RED_PROHIBITED':
        return 'DOUBLE RED: WATER CLOSED';
      case 'RED_HIGH_HAZARD':
        return 'RED FLAG: HIGH HAZARD & ROUGH SURF';
      case 'YELLOW_MEDIUM_HAZARD':
        return 'YELLOW FLAG: MEDIUM HAZARD & CAUTION';
      case 'GREEN_LOW_HAZARD':
      default:
        return 'GREEN FLAG: LOW HAZARD & CALM';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A111F),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'INCOIS Ocean State Forecast',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              'High Wave, Kallakkadal & Rip Current Engine',
              style: TextStyle(fontSize: 11, color: Colors.cyanAccent),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0A111F),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.cyanAccent),
            onPressed: () => _fetchOceanState(beachId: _selectedBeachId),
            tooltip: 'Refresh Ocean Telemetry',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _data == null) {
      return const Center(
        child: SpinKitWave(
          color: Colors.cyanAccent,
          size: 40.0,
        ),
      );
    }

    if (_errorMessage != null && _data == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.waves_rounded, size: 56, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _fetchOceanState(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry Connection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final data = _data ?? OceanStateResponseModel.defaultFallback();
    final beach = data.selectedBeach;
    final wave = beach.waveMetrics;
    final tierColor = _getTierColor(beach.alertTier);

    return RefreshIndicator(
      color: Colors.cyanAccent,
      backgroundColor: const Color(0xFF131F33),
      onRefresh: () => _fetchOceanState(beachId: _selectedBeachId),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data.isOfflineCached) _buildOfflineBanner(),
            _buildBeachSelector(),
            const SizedBox(height: 14),
            _buildHeroWaveCard(beach, wave, tierColor),
            const SizedBox(height: 16),
            if (beach.swellSurge.isKallakkadalActive || beach.swellSurge.coastalOverwashRisk == 'HIGH')
              _buildKallakkadalCard(beach.swellSurge),
            if (beach.swellSurge.isKallakkadalActive || beach.swellSurge.coastalOverwashRisk == 'HIGH')
              const SizedBox(height: 16),
            _buildRipCurrentHUD(beach.ripCurrent),
            const SizedBox(height: 16),
            _buildWavePhysicsGrid(wave),
            const SizedBox(height: 16),
            _buildSafetyDirectivesCard(beach.directives),
            const SizedBox(height: 16),
            _buildLanguageBroadcastCard(data),
            const SizedBox(height: 16),
            _buildProvenanceCard(data),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFF3B2800),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.6)),
      ),
      child: const Row(
        children: [
          Icon(Icons.wifi_off_rounded, color: Color(0xFFF59E0B), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Offline Mode: Displaying cached INCOIS WAVEWATCH-III numerical wave model run.',
              style: TextStyle(color: Color(0xFFFDE68A), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeachSelector() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _beaches.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = _beaches[index];
          final isSelected = item['id'] == _selectedBeachId;
          return FilterChip(
            selected: isSelected,
            label: Text(item['name']!),
            labelStyle: TextStyle(
              color: isSelected ? Colors.black : Colors.white70,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            backgroundColor: const Color(0xFF142036),
            selectedColor: Colors.cyanAccent,
            checkmarkColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? Colors.cyanAccent : const Color(0xFF233555),
              ),
            ),
            onSelected: (selected) {
              if (selected) {
                _fetchOceanState(beachId: item['id']!);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildHeroWaveCard(
    CoastalBeachSectorModel beach,
    SeaStateWaveMetricsModel wave,
    Color tierColor,
  ) {
    final flagColor = _getFlagColor(beach.directives.lifeguardFlag);
    final flagText = _getFlagTitle(beach.directives.lifeguardFlag);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tierColor.withValues(alpha: 0.22),
            const Color(0xFF111C30),
            const Color(0xFF0B1322),
          ],
        ),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: tierColor.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: tierColor.withValues(alpha: 0.15),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tierColor.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: tierColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.tsunami_rounded, color: tierColor, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      _getTierLabel(beach.alertTier),
                      style: TextStyle(
                        color: tierColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(Icons.flag_rounded, color: flagColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${beach.directives.activeLifeguardTowersCount} Towers Active',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            beach.beachName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${beach.coastalDistrict}, ${beach.state} • ${beach.waterBody}',
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SIGNIFICANT WAVE HEIGHT (Hs)',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        wave.significantWaveHeightM.toStringAsFixed(2),
                        style: TextStyle(
                          color: tierColor,
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'm',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2F4D),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Hmax: ${wave.maximumWaveHeightM.toStringAsFixed(1)}m',
                          style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: flagColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: flagColor, width: 1.2),
            ),
            child: Row(
              children: [
                Icon(Icons.flag_circle_rounded, color: flagColor, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        flagText,
                        style: TextStyle(
                          color: flagColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                      Text(
                        beach.directives.bathingSwimmingAdvisory,
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKallakkadalCard(SwellSurgeKallakkadalMetricsModel surge) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2A0D15),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFE11D48), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFFFB7185), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Kallakkadal (Swell Surge) Early Warning',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE11D48).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'OVERWASH: ${surge.coastalOverwashRisk}',
                  style: const TextStyle(
                    color: Color(0xFFFECDD3),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Source: ${surge.distantSourceBasin} • Swell Period: ${surge.swellWavePeriodS.toStringAsFixed(1)}s',
            style: const TextStyle(color: Color(0xFFFDA4AF), fontSize: 11.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            surge.artisanCraftAnchoringDirective,
            style: const TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.3),
          ),
        ],
      ),
    );
  }

  Widget _buildRipCurrentHUD(RipCurrentMetricsModel rip) {
    final isDeadly = rip.riskLevel == 'HIGH_DEADLY';
    final accentColor = isDeadly ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF131D31),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: accentColor.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.alt_route_rounded, color: accentColor, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Beach Rip Current Hazard HUD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  rip.riskLevel.replaceAll('_', ' '),
                  style: TextStyle(
                    color: accentColor,
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
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF17243C),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Peak Rip Velocity',
                        style: TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${rip.peakRipVelocityMs.toStringAsFixed(2)} m/s',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Fast seaward channel',
                        style: TextStyle(color: Colors.white38, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Identified Rip Channels:',
                      style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    ...rip.ripChannelLocations.take(3).map(
                          (loc) => Padding(
                            padding: const EdgeInsets.only(bottom: 3.0),
                            child: Row(
                              children: [
                                Icon(Icons.arrow_forward_rounded, color: accentColor, size: 12),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    loc,
                                    style: const TextStyle(color: Colors.white, fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1829),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.health_and_safety_rounded, color: Colors.cyanAccent, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rip.ripSurvivalInstruction,
                    style: const TextStyle(color: Colors.cyanAccent, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWavePhysicsGrid(SeaStateWaveMetricsModel wave) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF131D31),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFF1D2E4D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics_rounded, color: Colors.cyanAccent, size: 18),
              SizedBox(width: 8),
              Text(
                'WAVEWATCH-III Numerical Wave Physics',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  'Peak Period (Tp)',
                  '${wave.peakWavePeriodS.toStringAsFixed(1)} s',
                  'Swell cycle duration',
                  Colors.tealAccent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  'Wave Direction',
                  '${wave.meanWaveDirectionDeg.toStringAsFixed(0)}°',
                  'Propagation angle',
                  Colors.blueAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  'Surface Current',
                  '${wave.seaSurfaceCurrentSpeedKnots.toStringAsFixed(1)} kts',
                  'Nearshore drift velocity',
                  Colors.purpleAccent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  'Wave Steepness',
                  wave.waveSteepnessRatio.toStringAsFixed(3),
                  'Hs / wavelength',
                  Colors.orangeAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, String subtitle, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF16233B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: accentColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white38, fontSize: 9.5),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyDirectivesCard(BeachSafetyAndMaritimeDirectivesModel directives) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF131D31),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFF1D2E4D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield_outlined, color: Colors.cyanAccent, size: 18),
              SizedBox(width: 8),
              Text(
                'Beach Lifeguard & Maritime Directives',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDirectiveRow(
            Icons.surfing_rounded,
            'Water Sports Status',
            directives.waterSportsStatus,
            Colors.orangeAccent,
          ),
          const SizedBox(height: 10),
          _buildDirectiveRow(
            Icons.directions_boat_filled_rounded,
            'Artisanal Catamaran Directive',
            directives.countryBoatCatamaranDirective,
            Colors.cyanAccent,
          ),
          const SizedBox(height: 10),
          _buildDirectiveRow(
            Icons.anchor_rounded,
            'Deep Sea Trawler Advisory',
            directives.deepSeaTrawlerAdvisory,
            Colors.greenAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildDirectiveRow(IconData icon, String title, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                text,
                style: const TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageBroadcastCard(OceanStateResponseModel data) {
    final broadcasts = data.vernacularBroadcasts;
    final text = broadcasts[_selectedLangCode] ??
        broadcasts['en'] ??
        'No coastal marine advisory available in the selected language.';

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF131D31),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFF1D2E4D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.record_voice_over_rounded, color: Colors.cyanAccent, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Multi-Lingual Coastal Marine Broadcast',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                data.bulletinNumber,
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _languages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final lang = _languages[index];
                final isSelected = lang['code'] == _selectedLangCode;
                final isAvailable = broadcasts.containsKey(lang['code']);
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedLangCode = lang['code']!;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.cyanAccent
                          : isAvailable
                              ? const Color(0xFF1E304E)
                              : const Color(0xFF121D30),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? Colors.cyanAccent
                            : isAvailable
                                ? const Color(0xFF2E466F)
                                : Colors.white12,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        lang['label']!,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.black
                              : isAvailable
                                  ? Colors.white
                                  : Colors.white38,
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: const Color(0xFF0C1423),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1A2A44)),
            ),
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProvenanceCard(OceanStateResponseModel data) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1423),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFF18273F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_rounded, color: Colors.cyanAccent, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data.provenance,
                  style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Numerical Modeling: ${data.numericalModelWaveWatch}',
            style: const TextStyle(color: Colors.white38, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
