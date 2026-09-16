import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/forest_fire_model.dart';
import '../services/api_service.dart';

class ForestFireScreen extends StatefulWidget {
  final ForestFireResponse? initialData;
  final ApiService? apiService;

  const ForestFireScreen({
    super.key,
    this.initialData,
    this.apiService,
  });

  @override
  State<ForestFireScreen> createState() => _ForestFireScreenState();
}

class _ForestFireScreenState extends State<ForestFireScreen> {
  late ApiService _apiService;
  ForestFireResponse? _data;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedZoneId = 'uttarakhand_garhwal_pine';
  String _selectedLangCode = 'en';

  final List<Map<String, String>> _zones = [
    {'id': 'uttarakhand_garhwal_pine', 'name': 'Garhwal Pine (UK)'},
    {'id': 'similipal_tiger_reserve', 'name': 'Similipal Reserve (OR)'},
    {'id': 'bandipur_nagarhole_nilgiri', 'name': 'Bandipur (KA)'},
    {'id': 'gir_national_park_asiatic_lion', 'name': 'Gir Forest (GJ)'},
    {'id': 'nilgiris_shola_grassland', 'name': 'Mudumalai & Nilgiris (TN)'},
    {'id': 'dampa_tiger_reserve_mizoram', 'name': 'Dampa Tiger Reserve (MZ)'},
    {'id': 'melghat_tiger_reserve_satpura', 'name': 'Melghat Satpura (MH)'},
  ];

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'label': 'English'},
    {'code': 'hi', 'label': 'हिंदी'},
    {'code': 'kn', 'label': 'ಕನ್ನಡ'},
    {'code': 'or', 'label': 'ଓଡ଼ିଆ'},
    {'code': 'ta', 'label': 'தமிழ்'},
  ];

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    if (widget.initialData != null) {
      _data = widget.initialData;
      _selectedZoneId = widget.initialData!.selectedZone.zoneId;
    } else {
      _fetchForestFireData();
    }
  }

  Future<void> _fetchForestFireData({String? zoneId}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _apiService.getForestFireAssessment(
        zoneId: zoneId ?? _selectedZoneId,
      );
      setState(() {
        _data = res;
        _selectedZoneId = res.selectedZone.zoneId;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load forest fire analytics: $e';
        _isLoading = false;
      });
    }
  }

  Color _getDangerColor(String tier) {
    switch (tier.toUpperCase()) {
      case 'EXTREME':
        return const Color(0xFFDC2626); // Crimson Red
      case 'VERY_HIGH':
        return const Color(0xFFEA580C); // Dark Orange
      case 'HIGH':
        return const Color(0xFFEAB308); // Amber
      case 'MODERATE':
        return const Color(0xFF3B82F6); // Blue
      case 'LOW':
      default:
        return const Color(0xFF10B981); // Emerald
    }
  }

  String _formatDangerLabel(String tier) {
    switch (tier.toUpperCase()) {
      case 'EXTREME':
        return 'EXTREME FIRE DANGER (FWI > 45)';
      case 'VERY_HIGH':
        return 'VERY HIGH FIRE DANGER (FWI 30-45)';
      case 'HIGH':
        return 'HIGH FIRE DANGER (FWI 15-30)';
      case 'MODERATE':
        return 'MODERATE FIRE DANGER (FWI 5-15)';
      case 'LOW':
      default:
        return 'LOW FIRE DANGER (FWI 0-5)';
    }
  }

  String _formatBiomeLabel(String biome) {
    return biome.replaceAll('_', ' ');
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
              'Forest Fire & Van Agni FWI',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'FSI & ISRO-Bhuvan Fire Weather Early Warning',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFF97316)),
            tooltip: 'Refresh Fire Telemetry',
            onPressed: () => _fetchForestFireData(zoneId: _selectedZoneId),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: SpinKitFadingCircle(
                color: Color(0xFFF97316),
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
                          onPressed: () => _fetchForestFireData(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF97316),
                            foregroundColor: Colors.white,
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
    final zone = _data!.selectedZone;
    final indices = zone.indices;
    final behavior = zone.behavior;
    final directives = zone.directives;
    final dangerColor = _getDangerColor(indices.dangerTier);

    return RefreshIndicator(
      onRefresh: () => _fetchForestFireData(zoneId: _selectedZoneId),
      color: const Color(0xFFF97316),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Zone selector chips
            _buildZoneSelector(),
            const SizedBox(height: 12),

            // Offline caching banner
            if (_data!.isOfflineCached)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFF97316).withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cloud_off, size: 16, color: Color(0xFFF97316)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Operating in Offline Mode (Cached Van Agni FWI Telemetry)',
                        style: TextStyle(fontSize: 12, color: Color(0xFFF97316)),
                      ),
                    ),
                  ],
                ),
              ),

            // Hero Fire Weather Index (FWI) Card
            _buildHeroFwiCard(zone, indices, dangerColor),
            const SizedBox(height: 16),

            // 6-Component Canadian FWI Sub-Indices HUD
            _buildFwiSubIndicesHud(indices),
            const SizedBox(height: 16),

            // Fire Spread Physics & Crown Fire Risk Card
            _buildFireBehaviorCard(behavior, dangerColor),
            const SizedBox(height: 16),

            // Active Satellite Thermal Detections List
            _buildThermalHotspotsCard(zone),
            const SizedBox(height: 16),

            // Wildlife Sanctuary & Forest Ranger Directives
            _buildForestryDirectivesCard(directives),
            const SizedBox(height: 16),

            // Vernacular Forestry Advisory & Language Selector
            _buildVernacularSection(zone),
            const SizedBox(height: 16),

            // Provenance & Standard Footer
            _buildProvenanceFooter(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _zones.map((z) {
          final isSelected = z['id'] == _selectedZoneId;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                z['name']!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.black : const Color(0xFF94A3B8),
                ),
              ),
              selected: isSelected,
              selectedColor: const Color(0xFFF97316),
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onSelected: (selected) {
                if (selected && z['id'] != _selectedZoneId) {
                  setState(() => _selectedZoneId = z['id']!);
                  _fetchForestFireData(zoneId: z['id']);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeroFwiCard(
    ForestFireZoneHotspotModel zone,
    FireWeatherIndicesModel indices,
    Color dangerColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dangerColor.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: dangerColor.withValues(alpha: 0.1),
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
                  color: dangerColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: dangerColor.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_fire_department_rounded, size: 14, color: dangerColor),
                    const SizedBox(width: 5),
                    Text(
                      _formatDangerLabel(indices.dangerTier),
                      style: TextStyle(
                        color: dangerColor,
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
                  _formatBiomeLabel(zone.biomeType),
                  style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            zone.zoneName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${zone.reserveName} (${zone.state})',
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
          const Divider(color: Color(0xFF1E293B), height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('FIRE WEATHER INDEX (FWI)',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        indices.fwiFireWeatherIndex.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: dangerColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('kW/m', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('ACTIVE SATELLITE PIXELS',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.satellite_alt_rounded, size: 16, color: Color(0xFFF97316)),
                      const SizedBox(width: 6),
                      Text(
                        '${zone.activeThermalHotspots.length} Hotspots',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Total FRP: ${zone.totalFrpMw.toStringAsFixed(1)} MW',
                    style: const TextStyle(color: Color(0xFFF97316), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFwiSubIndicesHud(FireWeatherIndicesModel indices) {
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
              Icon(Icons.stacked_line_chart, size: 16, color: Color(0xFFF97316)),
              SizedBox(width: 8),
              Text(
                'CANADIAN FWI SYSTEM SUB-INDICES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Color(0xFFF97316),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildSubIndexTile(
                  label: 'FINE FUEL (FFMC)',
                  value: indices.ffmcFineFuelMoisture.toStringAsFixed(1),
                  subtitle: 'Litter Ignition Potential',
                  color: const Color(0xFFEF4444),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSubIndexTile(
                  label: 'DUFF MOISTURE (DMC)',
                  value: indices.dmcDuffMoisture.toStringAsFixed(1),
                  subtitle: 'Organic Duff Layer',
                  color: const Color(0xFFF97316),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSubIndexTile(
                  label: 'DROUGHT CODE (DC)',
                  value: indices.dcDroughtCode.toInt().toString(),
                  subtitle: 'Deep Soil Moisture Deficit',
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildSubIndexTile(
                  label: 'INITIAL SPREAD (ISI)',
                  value: indices.isiInitialSpreadIndex.toStringAsFixed(1),
                  subtitle: 'Wind-Driven Spread Rate',
                  color: const Color(0xFF38BDF8),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSubIndexTile(
                  label: 'BUILDUP INDEX (BUI)',
                  value: indices.buiBuildupIndex.toStringAsFixed(1),
                  subtitle: 'Combustible Fuel Volume',
                  color: const Color(0xFFA855F7),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSubIndexTile(
                  label: 'FIRE WEATHER (FWI)',
                  value: indices.fwiFireWeatherIndex.toStringAsFixed(1),
                  subtitle: 'Frontal Line Intensity',
                  color: const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubIndexTile({
    required String label,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 9, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _buildFireBehaviorCard(FireBehaviorMetricsModel behavior, Color dangerColor) {
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
              Icon(Icons.whatshot_rounded, size: 16, color: Color(0xFFF97316)),
              SizedBox(width: 8),
              Text(
                'FIRE SPREAD PHYSICS & BEHAVIOR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Color(0xFFF97316),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildBehaviorStat(
                  'Forward Spread Rate',
                  '${behavior.estimatedRateOfSpreadMHr.toInt()} m/hr',
                  Icons.speed,
                  const Color(0xFFF97316),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildBehaviorStat(
                  'Flame Length',
                  '${behavior.flameLengthM.toStringAsFixed(1)} m',
                  Icons.height,
                  const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildBehaviorStat(
                  'Fireline Intensity',
                  '${behavior.firelineIntensityKwM.toInt()} kW/m',
                  Icons.flash_on,
                  const Color(0xFFEF4444),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildBehaviorStat(
                  'Airborne Spotting Risk',
                  '${behavior.spotFireProbabilityPct.toInt()}%',
                  Icons.air,
                  const Color(0xFF38BDF8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: behavior.crownFireRisk
                  ? const Color(0xFFDC2626).withValues(alpha: 0.15)
                  : const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: behavior.crownFireRisk
                    ? const Color(0xFFDC2626).withValues(alpha: 0.4)
                    : const Color(0xFF10B981).withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  behavior.crownFireRisk ? Icons.warning_rounded : Icons.check_circle_outline,
                  size: 16,
                  color: behavior.crownFireRisk ? const Color(0xFFDC2626) : const Color(0xFF10B981),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    behavior.crownFireRisk
                        ? 'CROWN FIRE ACTIVE: Flames transitioning to tree canopy tops'
                        : 'SURFACE FIRE: Combustion confined to leaf litter and duff',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: behavior.crownFireRisk ? const Color(0xFFFCA5A5) : const Color(0xFF6EE7B7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBehaviorStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThermalHotspotsCard(ForestFireZoneHotspotModel zone) {
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
                  Icon(Icons.satellite_alt, size: 16, color: Color(0xFF38BDF8)),
                  SizedBox(width: 8),
                  Text(
                    'ACTIVE SATELLITE THERMAL PIXELS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Color(0xFF38BDF8),
                    ),
                  ),
                ],
              ),
              Text(
                'Total FRP: ${zone.totalFrpMw.toStringAsFixed(1)} MW',
                style: const TextStyle(color: Color(0xFFF97316), fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (zone.activeThermalHotspots.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No thermal anomalies detected in the latest satellite pass.',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
            )
          else
            ...zone.activeThermalHotspots.map((a) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFF97316).withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.sensor.replaceAll('_', ' '),
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${a.latitude.toStringAsFixed(4)}°N, ${a.longitude.toStringAsFixed(4)}°E',
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'FRP: ${a.fireRadiativePowerMw.toStringAsFixed(1)} MW',
                            style: const TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Brightness: ${a.brightnessTempKelvin.toStringAsFixed(1)} K (${a.confidencePct.toInt()}% conf)',
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildForestryDirectivesCard(ForestryProtectionDirectivesModel directives) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF97316).withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield_outlined, size: 16, color: Color(0xFFF97316)),
              SizedBox(width: 8),
              Text(
                'FORESTRY & WILDLIFE PROTECTION DIRECTIVES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Color(0xFFF97316),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF97316).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFF97316).withValues(alpha: 0.3)),
            ),
            child: Text(
              directives.rangerDeploymentAlert,
              style: const TextStyle(color: Color(0xFFFED7AA), fontSize: 12, fontWeight: FontWeight.bold, height: 1.4),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Counter-Fire Break Width:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
              Text(
                '${directives.firebreakClearanceWidthM.toInt()} meters',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Wildlife Corridor & Waterhole Status:', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(directives.wildlifeCorridorStatus, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3)),
          const SizedBox(height: 8),
          const Text('Tribal Produce (NTFP) Gatherer Restriction:', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(directives.tribalNtfpCollectionDirective, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3)),
          if (directives.aerialWaterBombingStandby) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                children: [
                  Icon(Icons.airplanemode_active, size: 14, color: Color(0xFF60A5FA)),
                  SizedBox(width: 6),
                  Text(
                    'IAF Bambi Bucket / Helicopter Aerial Drop: STANDBY READY',
                    style: TextStyle(color: Color(0xFF93C5FD), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVernacularSection(ForestFireZoneHotspotModel zone) {
    final bulletinText = zone.localizedBulletins[_selectedLangCode] ??
        zone.localizedBulletins['en'] ??
        'Forest fire bulletin unavailable.';

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
                  Icon(Icons.translate, size: 16, color: Color(0xFFF97316)),
                  SizedBox(width: 8),
                  Text(
                    'VERNACULAR FORESTRY BULLETIN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Color(0xFFF97316),
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
                    selectedColor: const Color(0xFFF97316),
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
              'Forest Survey of India (Van Agni 2.0) & ISRO-Bhuvan Fire Weather Early Warning',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, height: 1.3),
        ),
        const SizedBox(height: 4),
        const Text(
          'Canadian Fire Weather Index (FWI) System & NASA MODIS/VIIRS Active Fire Products',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF475569), fontSize: 9),
        ),
      ],
    );
  }
}
