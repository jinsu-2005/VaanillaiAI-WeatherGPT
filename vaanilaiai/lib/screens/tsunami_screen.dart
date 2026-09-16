import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/tsunami_model.dart';
import '../services/api_service.dart';

class TsunamiScreen extends StatefulWidget {
  final TsunamiWarningResponseModel? initialData;
  final ApiService? apiService;

  const TsunamiScreen({
    super.key,
    this.initialData,
    this.apiService,
  });

  @override
  State<TsunamiScreen> createState() => _TsunamiScreenState();
}

class _TsunamiScreenState extends State<TsunamiScreen> {
  late ApiService _apiService;
  TsunamiWarningResponseModel? _data;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedSectorId = 'andaman_nicobar_islands';
  String _selectedLangCode = 'en';

  final List<Map<String, String>> _sectors = [
    {'id': 'andaman_nicobar_islands', 'name': 'Andaman & Nicobar (UT)'},
    {'id': 'tamil_nadu_coromandel_coast', 'name': 'Coromandel Coast (TN/PY)'},
    {'id': 'andhra_pradesh_coast', 'name': 'Andhra Coast (AP)'},
    {'id': 'odisha_bengal_coast', 'name': 'Odisha & Bengal (OR/WB)'},
    {'id': 'kerala_malabar_coast', 'name': 'Malabar Coast (KL)'},
    {'id': 'gujarat_makran_gulf', 'name': 'Gujarat Makran (GJ)'},
    {'id': 'lakshadweep_archipelago', 'name': 'Lakshadweep Atolls (LD)'},
  ];

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'label': 'English'},
    {'code': 'hi', 'label': 'हिंदी'},
    {'code': 'ta', 'label': 'தமிழ்'},
    {'code': 'te', 'label': 'తెలుగు'},
    {'code': 'ml', 'label': 'മലയാളം'},
    {'code': 'bn', 'label': 'বাংলা'},
    {'code': 'or', 'label': 'ଓଡ଼ିଆ'},
  ];

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    if (widget.initialData != null) {
      _data = widget.initialData;
      _selectedSectorId = widget.initialData!.selectedSector.sectorId;
    } else {
      _fetchTsunamiData();
    }
  }

  Future<void> _fetchTsunamiData({String? sectorId}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _apiService.getTsunamiAssessment(
        sectorId: sectorId ?? _selectedSectorId,
      );
      setState(() {
        _data = res;
        _selectedSectorId = res.selectedSector.sectorId;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load INCOIS tsunami telemetry: $e';
        _isLoading = false;
      });
    }
  }

  Color _getTierColor(String tier) {
    switch (tier.toUpperCase()) {
      case 'WARNING_RED':
        return const Color(0xFFEF4444); // Crimson
      case 'ALERT_ORANGE':
        return const Color(0xFFF97316); // Safety Orange
      case 'WATCH_YELLOW':
        return const Color(0xFFEAB308); // Amber
      case 'THREAT_PASSED_GREEN':
      default:
        return const Color(0xFF10B981); // Emerald
    }
  }

  String _formatTierLabel(String tier) {
    switch (tier.toUpperCase()) {
      case 'WARNING_RED':
        return 'RED ALERT: TSUNAMI WARNING';
      case 'ALERT_ORANGE':
        return 'ORANGE ALERT: TSUNAMI THREAT';
      case 'WATCH_YELLOW':
        return 'YELLOW WATCH: TSUNAMI WATCH';
      case 'THREAT_PASSED_GREEN':
      default:
        return 'GREEN: THREAT PASSED (ALL CLEAR)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.tsunami_rounded, color: Color(0xFF06B6D4), size: 22),
                SizedBox(width: 8),
                Text(
                  'Indian Tsunami Early Warning (ITEWS)',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Text(
              'INCOIS MoES National Tsunami Center',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            tooltip: 'Refresh telemetry',
            onPressed: () => _fetchTsunamiData(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitWave(
                    color: Color(0xFF06B6D4),
                    size: 44,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Querying INCOIS DART buoys and tidal sea-level anomalies...',
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 48),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF06B6D4),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _fetchTsunamiData(),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Retry Connection'),
                        ),
                      ],
                    ),
                  ),
                )
              : _data == null
                  ? const SizedBox.shrink()
                  : RefreshIndicator(
                      color: const Color(0xFF06B6D4),
                      backgroundColor: const Color(0xFF0F172A),
                      onRefresh: () => _fetchTsunamiData(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_data!.isOfflineCached) _buildOfflineBanner(),
                            _buildSectorSelector(),
                            const SizedBox(height: 12),
                            _buildHeroCard(_data!.selectedSector),
                            const SizedBox(height: 14),
                            _buildSeismicAndWaveCard(_data!.selectedSector),
                            const SizedBox(height: 14),
                            _buildDartBuoysCard(_data!.selectedSector.dartBuoys),
                            const SizedBox(height: 14),
                            _buildTideGaugesCard(_data!.selectedSector.tideGauges),
                            const SizedBox(height: 14),
                            _buildEvacuationDirectivesCard(_data!.selectedSector.evacuationDirectives),
                            const SizedBox(height: 14),
                            _buildVernacularBulletinCard(_data!.selectedSector),
                            const SizedBox(height: 14),
                            _buildProvenanceFooter(_data!),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.offline_pin, color: Color(0xFFF59E0B), size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Offline Cached Advisory: Displaying calibrated baseline tsunami safety directives.',
              style: TextStyle(color: Color(0xFFFCD34D), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'INDIAN OCEAN COASTAL SECTORS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            Text(
              '${_sectors.length} Monitored Zones',
              style: TextStyle(
                fontSize: 11,
                color: const Color(0xFF06B6D4).withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _sectors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final sector = _sectors[index];
              final isSelected = sector['id'] == _selectedSectorId;
              return ChoiceChip(
                label: Text(
                  sector['name']!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                ),
                selected: isSelected,
                selectedColor: const Color(0xFF0891B2),
                backgroundColor: const Color(0xFF131D31),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF22D3EE) : const Color(0xFF1E293B),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onSelected: (selected) {
                  if (selected && sector['id'] != _selectedSectorId) {
                    _fetchTsunamiData(sectorId: sector['id']);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(CoastalForecastSectorModel sector) {
    final tierColor = _getTierColor(sector.alertTier);
    final isWarning = sector.alertTier == 'WARNING_RED';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tierColor.withValues(alpha: 0.25),
            const Color(0xFF0F172A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tierColor.withValues(alpha: isWarning ? 0.8 : 0.4),
          width: isWarning ? 1.8 : 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tierColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: tierColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_rounded, size: 14, color: tierColor),
                    const SizedBox(width: 5),
                    Text(
                      _formatTierLabel(sector.alertTier),
                      style: TextStyle(
                        color: tierColor,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                sector.state,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            sector.sectorName,
            style: const TextStyle(
              fontSize: 18.5,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Coastal Nodes: ${sector.keyCoastalNodes.join(" • ")}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0F1D).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MAX WAVE AMPLITUDE',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            sector.waveMetrics.maximumExpectedWaveAmplitudeM.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: tierColor,
                            ),
                          ),
                          const Text(
                            ' m',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0F1D).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FIRST WAVE ETA',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${sector.waveMetrics.timeToFirstWaveMinutes}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF06B6D4),
                            ),
                          ),
                          const Text(
                            ' min',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.speed, size: 14, color: Color(0xFF06B6D4)),
                    const SizedBox(width: 6),
                    Text(
                      'Deep Ocean Speed: ${sector.waveMetrics.deepWaterPropagationSpeedKmh.toStringAsFixed(0)} km/h',
                      style: const TextStyle(fontSize: 11.5, color: Colors.white70),
                    ),
                  ],
                ),
                Text(
                  'Shoaling Amplification: ${sector.waveMetrics.shoalingAmplificationFactor.toStringAsFixed(1)}x',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeismicAndWaveCard(CoastalForecastSectorModel sector) {
    final seismic = sector.seismicSource;
    final wave = sector.waveMetrics;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.sensors, color: Color(0xFFF59E0B), size: 18),
              SizedBox(width: 8),
              Text(
                'SEISMIC TSUNAMIGENIC SOURCE & HYDRODYNAMICS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildMetricTile(
                'Earthquake Magnitude',
                'Mw ${seismic.momentMagnitudeMw.toStringAsFixed(1)}',
                'Major megathrust event',
                Icons.vibration,
                const Color(0xFFEF4444),
              ),
              const SizedBox(width: 10),
              _buildMetricTile(
                'Focal Depth',
                '${seismic.focalDepthKm.toStringAsFixed(1)} km',
                'Shallow tsunamigenic',
                Icons.south,
                const Color(0xFFF59E0B),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildMetricTile(
                'Inundation Reach',
                '${wave.estimatedInundationDistanceM.toStringAsFixed(0)} m',
                'Penetration distance inland',
                Icons.waves,
                const Color(0xFF06B6D4),
              ),
              const SizedBox(width: 10),
              _buildMetricTile(
                'Trench Subduction',
                seismic.subductionZone.replaceAll('_', ' '),
                seismic.ruptureMechanism,
                Icons.public,
                const Color(0xFFA78BFA),
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
    String subtext,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF131D31),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtext,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDartBuoysCard(List<DeepOceanDartBuoyModel> buoys) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.radar, color: Color(0xFF06B6D4), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'DEEP-OCEAN DART TSUNAMETER BUOYS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Text(
                '${buoys.length} Active BPR',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF06B6D4),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (buoys.isEmpty)
            const Text(
              'No moored BPR buoys in immediate vicinity.',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            )
          else
            Column(
              children: buoys.map((b) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131D31),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: b.isEventModeTriggered
                          ? const Color(0xFFEF4444).withValues(alpha: 0.6)
                          : const Color(0xFF1E293B),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: b.isEventModeTriggered
                              ? const Color(0xFFEF4444).withValues(alpha: 0.2)
                              : const Color(0xFF06B6D4).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          b.isEventModeTriggered ? Icons.notifications_active : Icons.navigation,
                          size: 18,
                          color: b.isEventModeTriggered ? const Color(0xFFEF4444) : const Color(0xFF06B6D4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  b.buoyId,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: b.isEventModeTriggered
                                        ? const Color(0xFFEF4444).withValues(alpha: 0.2)
                                        : const Color(0xFF10B981).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    b.isEventModeTriggered ? 'EVENT MODE ACTIVE' : 'STANDARD TELEMETRY',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      color: b.isEventModeTriggered ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${b.seaBasin} • Depth: ${b.waterDepthM.toStringAsFixed(0)} m',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  'Deep Wave Amplitude: ${b.deepOceanWaveAmplitudeCm.toStringAsFixed(1)} cm',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF38BDF8),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'ΔP: ${b.pressureAnomalyHpa.toStringAsFixed(1)} hPa',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withValues(alpha: 0.5),
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
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildTideGaugesCard(List<CoastalTideGaugeTelemetryModel> gauges) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.water, color: Color(0xFF38BDF8), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'COASTAL RADAR TIDE GAUGES',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Text(
                'INCOIS Network',
                style: TextStyle(
                  fontSize: 10.5,
                  color: Colors.white.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (gauges.isEmpty)
            const Text(
              'No coastal tide gauges configured for this sector.',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            )
          else
            Column(
              children: gauges.map((tg) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131D31),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.show_chart, color: Color(0xFF06B6D4), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tg.stationName,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Observed: ${tg.observedSeaLevelM.toStringAsFixed(2)} m | Astronomical: ${tg.astronomicalTideM.toStringAsFixed(2)} m',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0891B2).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF0891B2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '+${tg.tsunamiResidualAmplitudeM.toStringAsFixed(2)} m',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF22D3EE),
                              ),
                            ),
                            const Text(
                              'Residual',
                              style: TextStyle(fontSize: 8.5, color: Colors.white60),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildEvacuationDirectivesCard(EvacuationAndMaritimeDirectivesModel directives) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield_outlined, color: Color(0xFFEF4444), size: 18),
              SizedBox(width: 8),
              Text(
                'VERTICAL EVACUATION & MARITIME SAFETY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildDirectiveRow(
            Icons.stairs_outlined,
            'Vertical Evacuation Altitude',
            '≥ ${directives.verticalEvacuationAltitudeM.toStringAsFixed(0)} meters MSL',
            'Evacuate to elevated RCC multi-story structures or hills',
            const Color(0xFFEF4444),
          ),
          const Divider(color: Color(0xFF1E293B), height: 16),
          _buildDirectiveRow(
            Icons.directions_run,
            'Horizontal Evacuation Distance',
            '≥ ${directives.horizontalEvacuationDistanceKm.toStringAsFixed(1)} km inland',
            'Clear beach waterfronts, estuaries, and low-lying coastal roads',
            const Color(0xFFF97316),
          ),
          const Divider(color: Color(0xFF1E293B), height: 16),
          _buildDirectiveRow(
            Icons.directions_boat,
            'Deep-Sea Vessel Directive',
            directives.deepSeaVesselDirective,
            'Deep ocean (>100m depth) is immune to shoaling waves',
            const Color(0xFF06B6D4),
          ),
          const Divider(color: Color(0xFF1E293B), height: 16),
          _buildDirectiveRow(
            Icons.volume_up,
            'Coastal Siren Network',
            directives.coastalSirenNetworkStatus,
            'NDMA & State Disaster Management sirens broadcasting alarm',
            const Color(0xFFF59E0B),
          ),
          const Divider(color: Color(0xFF1E293B), height: 16),
          _buildDirectiveRow(
            Icons.meeting_room,
            'Designated Tsunami Shelters',
            directives.designatedSafeShelterLocations.join(", "),
            'Pre-identified multi-hazard high-ground assembly refuges',
            const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectiveRow(
    IconData icon,
    String title,
    String primaryText,
    String subtitle,
    Color accentColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: accentColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                primaryText,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10.5,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVernacularBulletinCard(CoastalForecastSectorModel sector) {
    final activeText = sector.localizedBulletins[_selectedLangCode] ??
        sector.localizedBulletins['en'] ??
        'Official Tsunami Advisory Active.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.g_translate, color: Color(0xFF06B6D4), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'LOCALIZED COASTAL BROADCAST',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Text(
                'ITEWS / NDMA',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _languages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final lang = _languages[index];
                final isSelected = lang['code'] == _selectedLangCode;
                return ChoiceChip(
                  label: Text(
                    lang['label']!,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? Colors.white : Colors.white60,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFF0891B2),
                  backgroundColor: const Color(0xFF131D31),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF22D3EE) : const Color(0xFF1E293B),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedLangCode = lang['code']!;
                      });
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF080C14),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: Text(
              activeText,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Color(0xFFE2E8F0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProvenanceFooter(TsunamiWarningResponseModel data) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified, size: 14, color: Color(0xFF06B6D4)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  data.provenance,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Bulletin Ref: ${data.bulletinNumber} | Generated: ${data.timestamp}',
            style: TextStyle(
              fontSize: 9.5,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
