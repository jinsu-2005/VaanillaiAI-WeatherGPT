import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/storm_surge_model.dart';
import '../services/api_service.dart';

class StormSurgeScreen extends StatefulWidget {
  final StormSurgeResponseModel? initialData;
  final ApiService? apiService;

  const StormSurgeScreen({
    super.key,
    this.initialData,
    this.apiService,
  });

  @override
  State<StormSurgeScreen> createState() => _StormSurgeScreenState();
}

class _StormSurgeScreenState extends State<StormSurgeScreen> {
  late ApiService _apiService;
  StormSurgeResponseModel? _data;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedSectorId = 'sundarbans_wb';
  String _selectedLangCode = 'en';

  final List<Map<String, String>> _sectors = [
    {'id': 'sundarbans_wb', 'name': 'Sundarbans & Hooghly (WB)'},
    {'id': 'paradeep_mahanadi_or', 'name': 'Paradeep & Mahanadi (OR)'},
    {'id': 'krishna_godavari_ap', 'name': 'Krishna-Godavari (AP)'},
    {'id': 'nagapattinam_cauvery_tn', 'name': 'Nagapattinam & Cauvery (TN)'},
    {'id': 'gulf_of_khambhat_gj', 'name': 'Gulf of Khambhat (GJ)'},
    {'id': 'alappuzha_kuttanad_kl', 'name': 'Alappuzha Lowlands (KL)'},
    {'id': 'mumbai_mithi_mh', 'name': 'Mumbai & Mithi (MH)'},
  ];

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'label': 'English'},
    {'code': 'hi', 'label': 'हिंदी'},
    {'code': 'bn', 'label': 'বাংলা'},
    {'code': 'or', 'label': 'ଓଡ଼ିଆ'},
    {'code': 'te', 'label': 'తెలుగు'},
    {'code': 'ta', 'label': 'தமிழ்'},
    {'code': 'gu', 'label': 'ગુજરાતી'},
    {'code': 'ml', 'label': 'മലയാളം'},
    {'code': 'mr', 'label': 'मराठी'},
  ];

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    if (widget.initialData != null) {
      _data = widget.initialData;
      _selectedSectorId = widget.initialData!.selectedSector.sectorId;
    } else {
      _fetchSurgeData();
    }
  }

  Future<void> _fetchSurgeData({String? sectorId}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _apiService.getStormSurgeAssessment(
        sectorId: sectorId ?? _selectedSectorId,
      );
      setState(() {
        _data = res;
        _selectedSectorId = res.selectedSector.sectorId;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load INCOIS storm surge telemetry: $e';
        _isLoading = false;
      });
    }
  }

  Color _getTierColor(String tier) {
    switch (tier.toUpperCase()) {
      case 'EMERGENCY_RED':
        return const Color(0xFFEF4444);
      case 'WARNING_ORANGE':
        return const Color(0xFFF97316);
      case 'WATCH_YELLOW':
        return const Color(0xFFEAB308);
      case 'NORMAL_GREEN':
      default:
        return const Color(0xFF10B981);
    }
  }

  String _getTierLabel(String tier) {
    switch (tier.toUpperCase()) {
      case 'EMERGENCY_RED':
        return 'RED EMERGENCY';
      case 'WARNING_ORANGE':
        return 'ORANGE WARNING';
      case 'WATCH_YELLOW':
        return 'YELLOW WATCH';
      case 'NORMAL_GREEN':
      default:
        return 'NORMAL GREEN';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B111E),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'INCOIS-IMD Storm Surge',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              'ADCIRC-SWAN Hydrodynamics & Tidal Inundation',
              style: TextStyle(fontSize: 11, color: Colors.cyanAccent),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0B111E),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.cyanAccent),
            onPressed: () => _fetchSurgeData(sectorId: _selectedSectorId),
            tooltip: 'Refresh Telemetry',
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
              const Icon(Icons.cloud_off_rounded, size: 56, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _fetchSurgeData(),
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

    final data = _data ?? StormSurgeResponseModel.defaultFallback();
    final sector = data.selectedSector;
    final hydro = sector.hydrodynamics;
    final tierColor = _getTierColor(sector.threatTier);

    return RefreshIndicator(
      color: Colors.cyanAccent,
      backgroundColor: const Color(0xFF131F33),
      onRefresh: () => _fetchSurgeData(sectorId: _selectedSectorId),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data.isOfflineCached) _buildOfflineBanner(),
            _buildSectorSelector(),
            const SizedBox(height: 14),
            _buildHeroSurgeCard(sector, hydro, tierColor),
            const SizedBox(height: 16),
            _buildHydrodynamicsGrid(hydro),
            const SizedBox(height: 16),
            _buildCyclonicForcingCard(sector.cyclonicForcing),
            const SizedBox(height: 16),
            if (sector.tidalBore.borePhenomenonActive || sector.tidalBore.boreHeightM > 0.0)
              _buildTidalBoreCard(sector.tidalBore),
            if (sector.tidalBore.borePhenomenonActive || sector.tidalBore.boreHeightM > 0.0)
              const SizedBox(height: 16),
            _buildSalineInundationCard(sector.inundation),
            const SizedBox(height: 16),
            _buildDirectivesCard(sector.directives),
            const SizedBox(height: 16),
            _buildLanguageBulletinCard(data),
            const SizedBox(height: 16),
            _buildInstitutionalProvenanceCard(data),
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
              'Offline Mode: Displaying cached INCOIS-IMD ADCIRC numerical surge model run.',
              style: TextStyle(color: Color(0xFFFDE68A), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectorSelector() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _sectors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = _sectors[index];
          final isSelected = item['id'] == _selectedSectorId;
          return FilterChip(
            selected: isSelected,
            label: Text(item['name']!),
            labelStyle: TextStyle(
              color: isSelected ? Colors.black : Colors.white70,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            backgroundColor: const Color(0xFF16233B),
            selectedColor: Colors.cyanAccent,
            checkmarkColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? Colors.cyanAccent : const Color(0xFF283A5A),
              ),
            ),
            onSelected: (selected) {
              if (selected) {
                _fetchSurgeData(sectorId: item['id']!);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildHeroSurgeCard(
    EstuarySurgeSectorModel sector,
    HydrodynamicComponentsModel hydro,
    Color tierColor,
  ) {
    final isOvertopping = hydro.overtoppingDepthM > 0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tierColor.withValues(alpha: 0.22),
            const Color(0xFF131E33),
            const Color(0xFF0E1726),
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
                    Icon(Icons.warning_amber_rounded, color: tierColor, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      _getTierLabel(sector.threatTier),
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
              Text(
                sector.tidalPhase.replaceAll('_', ' '),
                style: const TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            sector.sectorName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${sector.waterBody} • ${sector.state}',
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
                    'TOTAL WATER LEVEL (TWL)',
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
                        hydro.totalWaterLevelM.toStringAsFixed(2),
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
                      const SizedBox(width: 8),
                      const Text(
                        'above Chart Datum',
                        style: TextStyle(color: Colors.white38, fontSize: 11),
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
              color: isOvertopping
                  ? const Color(0xFF450A0A)
                  : const Color(0xFF064E3B).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isOvertopping ? const Color(0xFFDC2626) : const Color(0xFF10B981),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isOvertopping ? Icons.waves_rounded : Icons.shield_rounded,
                  color: isOvertopping ? const Color(0xFFFCA5A5) : const Color(0xFF6EE7B7),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOvertopping
                            ? 'OVERTOPPING CRITICAL: +${hydro.overtoppingDepthM.toStringAsFixed(2)} m'
                            : 'SAFE FREEBOARD: ${hydro.freeboardMarginM.toStringAsFixed(2)} m',
                        style: TextStyle(
                          color: isOvertopping
                              ? const Color(0xFFFEE2E2)
                              : const Color(0xFFD1FAE5),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        isOvertopping
                            ? 'TWL exceeds crest (${hydro.coastalEmbankmentCrestM}m). Earthen dykes breaching.'
                            : 'Embankment crest at ${hydro.coastalEmbankmentCrestM}m. Tidal surge contained.',
                        style: TextStyle(
                          color: isOvertopping
                              ? const Color(0xFFFCA5A5)
                              : const Color(0xFFA7F3D0),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, color: Colors.cyanAccent, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Critical Window: ${hydro.peakSurgeWindowUtc}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHydrodynamicsGrid(HydrodynamicComponentsModel hydro) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF121D30),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFF1E3250)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.water_rounded, color: Colors.cyanAccent, size: 18),
              SizedBox(width: 8),
              Text(
                'ADCIRC Hydrodynamic Components',
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
                  'Astronomical Tide',
                  '${hydro.astronomicalTideM.toStringAsFixed(2)} m',
                  'Gravitational pull',
                  Colors.blueAccent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  'Storm Surge Anomaly',
                  '${hydro.stormSurgePeakM.toStringAsFixed(2)} m',
                  'Wind stress & pressure drop',
                  Colors.orangeAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  'Nearshore Wave Setup',
                  '${hydro.waveSetupM.toStringAsFixed(2)} m',
                  'SWAN surf radiation stress',
                  Colors.tealAccent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  'Embankment Crest',
                  '${hydro.coastalEmbankmentCrestM.toStringAsFixed(2)} m',
                  'Dyke / seawall barrier',
                  Colors.purpleAccent,
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

  Widget _buildCyclonicForcingCard(CyclonicForcingParametersModel forcing) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF121D30),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFF1E3250)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.cyclone, color: Colors.amberAccent, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Cyclonic Forcing & Atmospheric Stress',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amberAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  forcing.imdClassification,
                  style: const TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            forcing.cycloneName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Target landfall: ${forcing.landfallPoint} (${forcing.distanceToLandfallKm.toStringAsFixed(0)} km away)',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildSimpleKV('Sustained Winds', '${forcing.sustainedWindSpeedKmh.toStringAsFixed(0)} km/h'),
              ),
              Expanded(
                child: _buildSimpleKV('Central Pressure', '${forcing.centralPressureHpa.toStringAsFixed(0)} hPa'),
              ),
              Expanded(
                child: _buildSimpleKV('Translation Speed', '${forcing.forwardSpeedKmh.toStringAsFixed(0)} km/h'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleKV(String k, String v) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        const SizedBox(height: 2),
        Text(
          v,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildTidalBoreCard(TidalBoreMetricsModel bore) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.surfing_rounded, color: Color(0xFFA78BFA), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Estuarine Tidal Bore Phenomenon',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: bore.borePhenomenonActive
                      ? const Color(0xFFDC2626).withValues(alpha: 0.3)
                      : Colors.white12,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  bore.borePhenomenonActive ? 'ACTIVE BORE' : 'LOW BORE RISK',
                  style: TextStyle(
                    color: bore.borePhenomenonActive ? const Color(0xFFF87171) : Colors.white60,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            bore.riverBasinName,
            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  'Bore Wave Height',
                  '${bore.boreHeightM.toStringAsFixed(2)} m',
                  'Leading tidal wall',
                  const Color(0xFFA78BFA),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  'Upriver Propagation',
                  '${bore.borePropagationSpeedKmh.toStringAsFixed(1)} km/h',
                  'Upstream velocity',
                  const Color(0xFF818CF8),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  'Inland Reach',
                  '${bore.upstreamPenetrationKm.toStringAsFixed(0)} km',
                  'Estuarine penetration',
                  const Color(0xFF38BDF8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            bore.boreSafetyAdvisory,
            style: const TextStyle(color: Color(0xFFDDD6FE), fontSize: 11.5, height: 1.3),
          ),
        ],
      ),
    );
  }

  Widget _buildSalineInundationCard(SalineInundationMetricsModel inundation) {
    final isCritical = inundation.paddyAquacultureContaminationRisk == 'CRITICAL';

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF121D30),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFF1E3250)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.terrain_rounded, color: Colors.tealAccent, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Saline Inundation & Soil Salinization',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isCritical
                      ? const Color(0xFFEF4444).withValues(alpha: 0.25)
                      : const Color(0xFFF59E0B).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'SOIL RISK: ${inundation.paddyAquacultureContaminationRisk}',
                  style: TextStyle(
                    color: isCritical ? const Color(0xFFFCA5A5) : const Color(0xFFFDE68A),
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
                  'Max Inland Ingress',
                  '${inundation.maxInlandIntrusionKm.toStringAsFixed(1)} km',
                  'From coastline / bund',
                  Colors.tealAccent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  'Flooded Area',
                  '${inundation.estimatedInundatedAreaSqKm.toStringAsFixed(0)} km²',
                  'Submerged polders',
                  Colors.lightBlueAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  'Surge Salinity',
                  '${inundation.surgeWaterSalinityPpt.toStringAsFixed(1)} PPT',
                  'PSU seawater ratio',
                  Colors.pinkAccent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  'Embankment Breaches',
                  '${inundation.embankmentBreachesReported}',
                  'Reported fractures',
                  Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDirectivesCard(CoastalInfrastructureDirectivesModel directives) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF121D30),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFF1E3250)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield_outlined, color: Colors.cyanAccent, size: 18),
              SizedBox(width: 8),
              Text(
                'Coastal Infrastructure & Barrier Directives',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDirectiveBullet(
            Icons.lock_clock_rounded,
            'Sluice Gate Operation',
            directives.sluiceGateAction,
            Colors.amberAccent,
          ),
          const SizedBox(height: 10),
          _buildDirectiveBullet(
            Icons.fence_rounded,
            'Storm Surge Barrier Status',
            directives.stormSurgeBarrierStatus,
            Colors.cyanAccent,
          ),
          const SizedBox(height: 10),
          _buildDirectiveBullet(
            Icons.night_shelter_rounded,
            'Cyclone Shelter Mobilization',
            directives.cycloneShelterMobilization,
            Colors.greenAccent,
          ),
          const SizedBox(height: 10),
          _buildDirectiveBullet(
            Icons.directions_boat_rounded,
            'Marine Craft Harbor Directive',
            directives.marineCraftHarborDirective,
            Colors.orangeAccent,
          ),
          const SizedBox(height: 10),
          _buildDirectiveBullet(
            Icons.water_drop_rounded,
            'Potable Well Sealing Order',
            directives.drinkingWaterWellSealingOrder,
            Colors.lightBlueAccent,
          ),
          if (directives.designatedShelters.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'Designated Cyclone & Inundation Shelters:',
              style: TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: directives.designatedShelters.map((s) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16243D),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF233A60)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.home_work_rounded, color: Colors.cyanAccent, size: 12),
                      const SizedBox(width: 5),
                      Text(
                        s,
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDirectiveBullet(IconData icon, String title, String detail, Color color) {
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
                detail,
                style: const TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageBulletinCard(StormSurgeResponseModel data) {
    final bulletins = data.vernacularBulletins;
    final text = bulletins[_selectedLangCode] ??
        bulletins['en'] ??
        'No coastal emergency warning bulletin in the selected language.';

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF121D30),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFF1E3250)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.campaign_rounded, color: Colors.cyanAccent, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Multi-Lingual Coastal Emergency Broadcast',
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
                final isAvailable = bulletins.containsKey(lang['code']);
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
              color: const Color(0xFF0D1624),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1B2C46)),
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

  Widget _buildInstitutionalProvenanceCard(StormSurgeResponseModel data) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1524),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFF1A2A42)),
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
            'Numerical Coupling: ${data.numericalModelCoupling}',
            style: const TextStyle(color: Colors.white38, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
