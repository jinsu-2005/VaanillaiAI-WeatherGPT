import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/hazmat_model.dart';
import '../services/api_service.dart';

class HazmatScreen extends StatefulWidget {
  final HazmatDispersionResponse? initialData;
  final ApiService? apiService;

  const HazmatScreen({
    super.key,
    this.initialData,
    this.apiService,
  });

  @override
  State<HazmatScreen> createState() => _HazmatScreenState();
}

class _HazmatScreenState extends State<HazmatScreen> {
  late ApiService _apiService;
  HazmatDispersionResponse? _data;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedClusterId = 'dahej_pcpir_gujarat';
  String _selectedLangCode = 'en';

  final List<Map<String, String>> _clusters = [
    {'id': 'dahej_pcpir_gujarat', 'name': 'Dahej PCPIR (GJ)'},
    {'id': 'manali_industrial_corridor_chennai', 'name': 'Manali Complex (TN)'},
    {'id': 'visakhapatnam_pharma_city', 'name': 'Vizag Pharma City (AP)'},
    {'id': 'rasayani_taloja_midc', 'name': 'Taloja MIDC (MH)'},
    {'id': 'vapi_chemical_estate', 'name': 'Vapi GIDC (GJ)'},
    {'id': 'haldia_industrial_complex', 'name': 'Haldia Complex (WB)'},
    {'id': 'bhopal_mandideep_industrial', 'name': 'Mandideep Bhopal (MP)'},
  ];

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'label': 'English'},
    {'code': 'hi', 'label': 'हिंदी'},
    {'code': 'gu', 'label': 'ગુજરાતી'},
    {'code': 'ta', 'label': 'தமிழ்'},
    {'code': 'te', 'label': 'తెలుగు'},
  ];

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    if (widget.initialData != null) {
      _data = widget.initialData;
      _selectedClusterId = widget.initialData!.selectedCluster.clusterId;
    } else {
      _fetchHazmatData();
    }
  }

  Future<void> _fetchHazmatData({String? clusterId}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _apiService.getHazmatDispersionAssessment(
        clusterId: clusterId ?? _selectedClusterId,
      );
      setState(() {
        _data = res;
        _selectedClusterId = res.selectedCluster.clusterId;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load hazmat plume intelligence: $e';
        _isLoading = false;
      });
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toUpperCase()) {
      case 'CATASTROPHIC_VESSEL_RUPTURE':
        return const Color(0xFFDC2626); // Crimson
      case 'SIGNIFICANT_TANK_LEAK':
        return const Color(0xFFEA580C); // Dark Orange
      case 'CONTROLLED_FLARING':
        return const Color(0xFFEAB308); // Amber
      case 'MINOR_FUGITIVE_EMISSION':
      default:
        return const Color(0xFF10B981); // Emerald
    }
  }

  String _formatSeverityLabel(String severity) {
    switch (severity.toUpperCase()) {
      case 'CATASTROPHIC_VESSEL_RUPTURE':
        return 'CATASTROPHIC VESSEL RUPTURE';
      case 'SIGNIFICANT_TANK_LEAK':
        return 'SIGNIFICANT TANK LEAK';
      case 'CONTROLLED_FLARING':
        return 'CONTROLLED FLARING';
      case 'MINOR_FUGITIVE_EMISSION':
      default:
        return 'MINOR FUGITIVE EMISSION';
    }
  }

  Color _getStabilityColor(String stabilityClass) {
    if (stabilityClass.contains('CLASS_F') || stabilityClass.contains('CLASS_E')) {
      return const Color(0xFFDC2626); // Trapping inversion
    } else if (stabilityClass.contains('CLASS_D')) {
      return const Color(0xFFF59E0B);
    }
    return const Color(0xFF3B82F6);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Industrial Hazmat & Plume',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'CPCB & IMD Toxic Gas Dispersion Nowcast',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFF59E0B)),
            tooltip: 'Refresh Telemetry',
            onPressed: () => _fetchHazmatData(clusterId: _selectedClusterId),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: SpinKitFadingCircle(
                color: Color(0xFFF59E0B),
                size: 48,
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _fetchHazmatData(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF59E0B),
                            foregroundColor: Colors.black,
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_data == null) return const SizedBox();
    final cluster = _data!.selectedCluster;
    final gas = cluster.activeGasProfile;
    final metrics = cluster.dispersionMetrics;
    final atm = cluster.atmosphericTelemetry;
    final proto = cluster.emergencyProtocol;
    final severityColor = _getSeverityColor(metrics.severityTier);

    return RefreshIndicator(
      onRefresh: () => _fetchHazmatData(clusterId: _selectedClusterId),
      color: const Color(0xFFF59E0B),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cluster selector chips
            _buildClusterSelector(),
            const SizedBox(height: 12),

            // Offline caching banner
            if (_data!.isOfflineCached)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cloud_off, size: 16, color: Color(0xFFF59E0B)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Operating in Resilient Offline Baseline Mode (CPCB Stored Telemetry)',
                        style: TextStyle(fontSize: 12, color: Color(0xFFF59E0B)),
                      ),
                    ),
                  ],
                ),
              ),

            // Hero Chemical Plume Card
            _buildHeroPlumeCard(cluster, gas, metrics, severityColor),
            const SizedBox(height: 16),

            // Gaussian Dispersion Footprint HUD (PAD, IIZ, Plume Width, Transit Time)
            _buildPlumeFootprintHud(metrics, atm),
            const SizedBox(height: 16),

            // Chemical Toxicity & AEGL Exposure Benchmarks
            _buildToxicityBenchmarkCard(gas, metrics),
            const SizedBox(height: 16),

            // Micrometeorological Dispersion Conditions
            _buildAtmosphericTelemetryCard(atm),
            const SizedBox(height: 16),

            // Life-Saving Emergency Response Directives
            _buildEmergencyResponseCard(proto),
            const SizedBox(height: 16),

            // Sensitive Downwind Receptors
            _buildSensitiveReceptorsCard(cluster),
            const SizedBox(height: 16),

            // Vernacular Hazard Bulletin & Language Selector
            _buildVernacularBulletinSection(cluster),
            const SizedBox(height: 16),

            // Provenance & Standard Footer
            _buildProvenanceFooter(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildClusterSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _clusters.map((c) {
          final isSelected = c['id'] == _selectedClusterId;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                c['name']!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.black : const Color(0xFF94A3B8),
                ),
              ),
              selected: isSelected,
              selectedColor: const Color(0xFFF59E0B),
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onSelected: (selected) {
                if (selected && c['id'] != _selectedClusterId) {
                  setState(() => _selectedClusterId = c['id']!);
                  _fetchHazmatData(clusterId: c['id']);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeroPlumeCard(
    IndustrialChemicalClusterModel cluster,
    GasToxicityModel gas,
    PlumeDispersionModel metrics,
    Color severityColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: severityColor.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: severityColor.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: severityColor.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 14, color: severityColor),
                    const SizedBox(width: 5),
                    Text(
                      _formatSeverityLabel(metrics.severityTier),
                      style: TextStyle(
                        color: severityColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'CAS: ${gas.casNumber}',
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                gas.commonName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  gas.chemicalFormula,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF38BDF8),
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${cluster.clusterName}, ${cluster.district}, ${cluster.state}',
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
          const Divider(color: Color(0xFF1E293B), height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('GROUND PEAK CONCENTRATION',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        metrics.centerlinePeakConcentrationPpm.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: severityColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('ppm', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('VAPOR DENSITY (AIR=1.0)',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    '${gas.vaporDensityAirRatio.toStringAsFixed(2)}x ${gas.vaporDensityAirRatio > 1.0 ? "(DENSE/SINKS)" : "(LIGHT/RISES)"}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: gas.vaporDensityAirRatio > 1.0 ? const Color(0xFFF87171) : const Color(0xFF38BDF8),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Release Rate: ${metrics.releaseRateKgS.toStringAsFixed(1)} kg/s',
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlumeFootprintHud(PlumeDispersionModel metrics, AtmosphericDispersionModel atm) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield_outlined, size: 16, color: Color(0xFFF59E0B)),
              SizedBox(width: 8),
              Text(
                'GAUSSIAN PLUME DISPERSION FOOTPRINT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildHudTile(
                  label: 'PROTECTIVE ACTION (PAD)',
                  value: '${metrics.protectiveActionDistanceKm.toStringAsFixed(1)} km',
                  subtitle: 'AEGL-2 Boundary Zone',
                  color: const Color(0xFFDC2626),
                  icon: Icons.alt_route,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildHudTile(
                  label: 'INITIAL ISOLATION (IIZ)',
                  value: '${metrics.initialIsolationZoneM.toInt()} m',
                  subtitle: 'Immediate Evacuation',
                  color: const Color(0xFFEA580C),
                  icon: Icons.radio_button_checked,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildHudTile(
                  label: 'CROSSWIND PLUME WIDTH',
                  value: '${metrics.plumeWidth1kmM.toInt()} m',
                  subtitle: 'Spread at 1 km Downwind',
                  color: const Color(0xFF38BDF8),
                  icon: Icons.width_wide,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildHudTile(
                  label: 'TRANSIT TIME TO BUFFER',
                  value: '${metrics.transitTimeBufferMin.toStringAsFixed(1)} min',
                  subtitle: 'Community Impact Time',
                  color: const Color(0xFFF59E0B),
                  icon: Icons.timer_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHudTile({
    required String label,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildToxicityBenchmarkCard(GasToxicityModel gas, PlumeDispersionModel metrics) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.biotech, size: 16, color: Color(0xFF38BDF8)),
              SizedBox(width: 8),
              Text(
                'EPA AEGL & NIOSH IDLH TOXICITY THRESHOLDS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Color(0xFF38BDF8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildThresholdRow('AEGL-1 (Mild Irritation)', '${gas.aegl1Ppm} ppm', const Color(0xFF10B981)),
          _buildThresholdRow('AEGL-2 (Irreversible Effects)', '${gas.aegl2Ppm} ppm', const Color(0xFFEAB308)),
          _buildThresholdRow('AEGL-3 (Life-Threatening)', '${gas.aegl3Ppm} ppm', const Color(0xFFEA580C)),
          _buildThresholdRow('IDLH (Immediately Dangerous)', '${gas.idlhPpm} ppm', const Color(0xFFDC2626)),
          const Divider(color: Color(0xFF1E293B), height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Odor Perception Threshold: ${gas.odorThresholdPpm} ppm',
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
              Text('Mol Weight: ${gas.molecularWeightGMol} g/mol',
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdRow(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildAtmosphericTelemetryCard(AtmosphericDispersionModel atm) {
    final stabColor = _getStabilityColor(atm.pasquillStabilityClass);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.air, size: 16, color: Color(0xFF10B981)),
              SizedBox(width: 8),
              Text(
                'MICROMETEOROLOGICAL DISPERSION CONDITIONS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Pasquill Stability Class:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: stabColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  atm.pasquillStabilityClass.replaceAll('_', ' '),
                  style: TextStyle(color: stabColor, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('10m Surface Wind:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              Text(
                '${atm.windSpeedMS.toStringAsFixed(1)} m/s (${atm.windDirectionCardinal} - ${atm.windDirectionDegrees.toInt()}°)',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Mixing Depth Layer:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              Text(
                '${atm.mixingHeightM.toInt()} m',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Nocturnal Thermal Inversion:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              Text(
                atm.inversionLayerPresent ? 'PRESENT (Trapping Cap Active)' : 'None Detected',
                style: TextStyle(
                  color: atm.inversionLayerPresent ? const Color(0xFFDC2626) : const Color(0xFF10B981),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyResponseCard(EmergencyResponseProtocolModel proto) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.directions_run, size: 16, color: Color(0xFFDC2626)),
              SizedBox(width: 8),
              Text(
                'LIFE-SAVING CROSSWIND EVACUATION DIRECTIVES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Color(0xFFDC2626),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.3)),
            ),
            child: Text(
              proto.crosswindEscapeDirection,
              style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 12, fontWeight: FontWeight.bold, height: 1.4),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Shelter-in-Place Protocol:', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(proto.shelterInPlaceDirectives, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3)),
          const SizedBox(height: 10),
          const Text('Responder PPE Specification:', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(proto.recommendedPpe, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3)),
          const SizedBox(height: 10),
          const Text('Clinical Antidote & Medical Protocol:', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(proto.medicalCountermeasures, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3)),
        ],
      ),
    );
  }

  Widget _buildSensitiveReceptorsCard(IndustrialChemicalClusterModel cluster) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_city, size: 16, color: Color(0xFF94A3B8)),
              SizedBox(width: 8),
              Text(
                'SENSITIVE DOWNWIND RECEPTOR COMMUNITIES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...cluster.sensitiveDownwindReceptors.map((r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_right, size: 16, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(r, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildVernacularBulletinSection(IndustrialChemicalClusterModel cluster) {
    final bulletinText = cluster.localizedBulletins[_selectedLangCode] ??
        cluster.localizedBulletins['en'] ??
        'Hazard bulletin unavailable.';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.translate, size: 16, color: Color(0xFFF59E0B)),
                  SizedBox(width: 8),
                  Text(
                    'VERNACULAR EMERGENCY BULLETIN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
              Text(
                _data?.bulletinNumber ?? '',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 9, fontFamily: 'monospace'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _languages.map((l) {
                final isSelected = l['code'] == _selectedLangCode;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(
                      l['label']!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.black : const Color(0xFF94A3B8),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFFF59E0B),
                    backgroundColor: const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedLangCode = l['code']!);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              bulletinText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProvenanceFooter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Divider(color: Color(0xFF1E293B)),
        const SizedBox(height: 8),
        Text(
          _data?.provenance ??
              'CPCB Central Pollution Control Board & IMD Emergency Response Decision Support System',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, height: 1.3),
        ),
        const SizedBox(height: 4),
        const Text(
          'US DOT Emergency Response Guidebook (ERG-2024) & NDMA Chemical Disaster Guidelines',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF475569), fontSize: 9),
        ),
      ],
    );
  }
}
