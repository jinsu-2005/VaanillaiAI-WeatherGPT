import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/marine_heatwave_model.dart';
import '../services/api_service.dart';

class MarineHeatwaveScreen extends StatefulWidget {
  final MarineHeatwaveResponseModel? initialData;
  final ApiService? apiService;

  const MarineHeatwaveScreen({
    super.key,
    this.initialData,
    this.apiService,
  });

  @override
  State<MarineHeatwaveScreen> createState() => _MarineHeatwaveScreenState();
}

class _MarineHeatwaveScreenState extends State<MarineHeatwaveScreen> {
  late ApiService _apiService;
  MarineHeatwaveResponseModel? _data;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedSectorId = 'gulf_of_mannar_rameshwaram';
  String _selectedLangCode = 'en';

  final List<Map<String, String>> _sectors = [
    {'id': 'gulf_of_mannar_rameshwaram', 'name': 'Gulf of Mannar (TN)'},
    {'id': 'lakshadweep_kavaratti', 'name': 'Lakshadweep (Kavaratti)'},
    {'id': 'andaman_havelock_swaraj', 'name': 'Andaman (Swaraj Dweep)'},
    {'id': 'gulf_of_kutch_mithapur', 'name': 'Gulf of Kutch (Mithapur)'},
    {'id': 'netrani_island_karnataka', 'name': 'Netrani Island (KA)'},
    {'id': 'malvan_marine_sanctuary', 'name': 'Malvan Sanctuary (MH)'},
    {'id': 'coastal_sea_fog_jnpt', 'name': 'JNPT / Mumbai Port (Fog)'},
  ];

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'label': 'English'},
    {'code': 'ta', 'label': 'தமிழ்'},
    {'code': 'ml', 'label': 'മലയാളം'},
    {'code': 'gu', 'label': 'ગુજરાતી'},
    {'code': 'mr', 'label': 'मराठी'},
  ];

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    if (widget.initialData != null) {
      _data = widget.initialData;
      _selectedSectorId = widget.initialData!.selectedSector.hotspotId;
    } else {
      _fetchMarineData();
    }
  }

  Future<void> _fetchMarineData({String? sectorId}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _apiService.getMarineHeatwaveAssessment(
        sectorId: sectorId ?? _selectedSectorId,
      );
      setState(() {
        _data = res;
        _selectedSectorId = res.selectedSector.hotspotId;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load marine intelligence: $e';
        _isLoading = false;
      });
    }
  }

  Color _getBleachingColor(String level) {
    final upper = level.toUpperCase();
    if (upper.contains('ALERT_LEVEL_2') || upper.contains('LEVEL 2')) {
      return const Color(0xFFEF4444); // Red
    } else if (upper.contains('ALERT_LEVEL_1') || upper.contains('LEVEL 1')) {
      return const Color(0xFFF97316); // Orange
    } else if (upper.contains('WARNING')) {
      return const Color(0xFFEAB308); // Yellow
    } else if (upper.contains('WATCH')) {
      return const Color(0xFF38BDF8); // Sky blue
    }
    return const Color(0xFF10B981); // Emerald
  }

  String _formatBleachingLabel(String level) {
    switch (level.toUpperCase()) {
      case 'ALERT_LEVEL_2':
        return 'Alert Level 2 (Severe Mortality)';
      case 'ALERT_LEVEL_1':
        return 'Alert Level 1';
      case 'BLEACHING_WARNING':
        return 'Bleaching Warning';
      case 'BLEACHING_WATCH':
        return 'Bleaching Watch';
      default:
        return 'No Stress';
    }
  }

  Color _getCategoryColor(String category) {
    final upper = category.toUpperCase();
    if (upper.contains('IV') || upper.contains('EXTREME')) {
      return const Color(0xFF9333EA); // Purple
    } else if (upper.contains('III') || upper.contains('SEVERE')) {
      return const Color(0xFFDC2626); // Crimson
    } else if (upper.contains('II') || upper.contains('STRONG')) {
      return const Color(0xFFEA580C); // Dark Orange
    } else if (upper.contains('I') || upper.contains('MODERATE')) {
      return const Color(0xFFD97706); // Amber
    }
    return const Color(0xFF0284C7); // Cyan
  }

  String _formatCategoryLabel(String category) {
    switch (category.toUpperCase()) {
      case 'CATEGORY_IV_EXTREME':
        return 'Category IV Extreme';
      case 'CATEGORY_III_SEVERE':
        return 'Category III Severe';
      case 'CATEGORY_II_STRONG':
        return 'Category II Strong';
      case 'CATEGORY_I_MODERATE':
        return 'Category I Moderate';
      default:
        return category;
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
              'INCOIS Marine Heatwave & Reefs',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Text(
              'Coral Bleaching & Sea Fog Nowcasting',
              style: TextStyle(fontSize: 11, color: Colors.cyanAccent),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Satellite Telemetry',
            onPressed: () => _fetchMarineData(sectorId: _selectedSectorId),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: SpinKitPulse(
                color: Colors.cyan,
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
                          onPressed: () => _fetchMarineData(),
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
                      onRefresh: () => _fetchMarineData(sectorId: _selectedSectorId),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_data!.isOfflineCached) _buildOfflineBanner(),
                            _buildSectorSelector(),
                            const SizedBox(height: 16),
                            _buildHeroStressCard(cardBg),
                            const SizedBox(height: 16),
                            _buildHeatwaveDynamicsCard(cardBg),
                            const SizedBox(height: 16),
                            if (_data!.selectedSector.coastalFog.isFogActive ||
                                _data!.selectedSector.coastalFog.nauticalVisibilityM < 3000) ...[
                              _buildSeaFogCard(cardBg),
                              const SizedBox(height: 16),
                            ],
                            _buildConservationDirectivesCard(cardBg),
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
              'Offline Mode: Displaying cached INCOIS-OOMAD marine telemetry.',
              style: TextStyle(fontSize: 12, color: Colors.amber),
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
        const Text(
          'SELECT MARINE SECTOR / REEF HABITAT',
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
            itemCount: _sectors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final sec = _sectors[index];
              final isSelected = sec['id'] == _selectedSectorId;
              return ChoiceChip(
                label: Text(
                  sec['name']!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.cyanAccent : null,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected && sec['id'] != _selectedSectorId) {
                    setState(() => _selectedSectorId = sec['id']!);
                    _fetchMarineData(sectorId: sec['id']!);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeroStressCard(Color cardBg) {
    final sector = _data!.selectedSector;
    final thermal = sector.thermalStress;
    final alertColor = _getBleachingColor(thermal.bleachingAlertLevel);

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
                        sector.sectorName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${sector.maritimeZone} • ${sector.reefType}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: alertColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: alertColor),
                  ),
                  child: Text(
                    _formatBleachingLabel(thermal.bleachingAlertLevel),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: alertColor,
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
                  'Sea Surface Temp',
                  '${thermal.seaSurfaceTempC.toStringAsFixed(1)}°C',
                  'Anomaly: +${thermal.sstAnomalyC.toStringAsFixed(1)}°C',
                  Colors.orangeAccent,
                ),
                _buildMetricColumn(
                  'Degree Heating Wks',
                  thermal.degreeHeatingWeeks.toStringAsFixed(1),
                  '°C-weeks',
                  alertColor,
                ),
                _buildMetricColumn(
                  'Coral HotSpot',
                  '+${thermal.coralHotspotC.toStringAsFixed(1)}°C',
                  'MMM: ${thermal.climatologicalMmmC.toStringAsFixed(1)}°C',
                  Colors.cyanAccent,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'DHW Accumulation (NOAA CRW Scale)',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey),
                    ),
                    Text(
                      '${thermal.degreeHeatingWeeks.toStringAsFixed(1)} / 16.0',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: alertColor),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (thermal.degreeHeatingWeeks / 16.0).clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(alertColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: alertColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: alertColor.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, size: 20, color: alertColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Coral Taxa: ${sector.dominantCoralTaxa.join(", ")}',
                      style: TextStyle(fontSize: 12, color: alertColor),
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

  Widget _buildMetricColumn(String label, String value, String sub, Color valColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: valColor),
        ),
        const SizedBox(height: 2),
        Text(sub, style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
      ],
    );
  }

  Widget _buildHeatwaveDynamicsCard(Color cardBg) {
    final mhw = _data!.selectedSector.heatwave;
    final catColor = _getCategoryColor(mhw.category);

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
                    Icon(Icons.waves, size: 20, color: Colors.cyan),
                    SizedBox(width: 8),
                    Text(
                      'Marine Heatwave Dynamics',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: catColor),
                  ),
                  child: Text(
                    _formatCategoryLabel(mhw.category),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: catColor),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildInfoTile(
                    'Event Duration',
                    '${mhw.durationDays} Days Active',
                    Icons.timer_outlined,
                  ),
                ),
                Expanded(
                  child: _buildInfoTile(
                    'Peak Anomaly',
                    '+${mhw.peakAnomalyC.toStringAsFixed(1)}°C Peak',
                    Icons.trending_up,
                  ),
                ),
                Expanded(
                  child: _buildInfoTile(
                    'Warm Layer Depth',
                    '${mhw.depthPenetrationM.toStringAsFixed(0)} meters',
                    Icons.layers_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.set_meal, size: 18, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pelagic Fisheries Telemetry: ${mhw.pelagicFishDisplacement}',
                      style: TextStyle(fontSize: 11, color: Colors.amber.shade200),
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

  Widget _buildSeaFogCard(Color cardBg) {
    final fog = _data!.selectedSector.coastalFog;
    final fogColor = fog.nauticalVisibilityM < 500
        ? const Color(0xFFEF4444)
        : fog.nauticalVisibilityM < 1500
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
                    Icon(Icons.foggy, size: 20, color: Colors.lightBlueAccent),
                    SizedBox(width: 8),
                    Text(
                      'Coastal Sea Fog & Port Visibility',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: fogColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: fogColor),
                  ),
                  child: Text(
                    fog.isFogActive ? 'Fog Active' : 'Passage Clear',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fogColor),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricColumn(
                  'Nautical Visibility',
                  '${fog.nauticalVisibilityM.toStringAsFixed(0)}m',
                  fog.nauticalVisibilityM < 500 ? 'Dense Advection Fog' : 'Moderate Passage',
                  fogColor,
                ),
                _buildMetricColumn(
                  'Air-Sea Temp Delta',
                  '${fog.seaAirTempDiffC.toStringAsFixed(1)}°C',
                  fog.seaAirTempDiffC < 0 ? 'Thermal Inversion Active' : 'Neutral Gradient',
                  Colors.cyanAccent,
                ),
                _buildMetricColumn(
                  'Inversion Height',
                  '${fog.marineInversionHeightM.toStringAsFixed(0)}m',
                  'Cap Height',
                  Colors.tealAccent,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: fogColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: fogColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.directions_boat, size: 18, color: fogColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'VTS Guidance: ${fog.vtsChannelStatus}',
                      style: TextStyle(fontSize: 11, color: fogColor),
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

  Widget _buildConservationDirectivesCard(Color cardBg) {
    final dir = _data!.selectedSector.directives;

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
                Icon(Icons.assignment_turned_in, size: 20, color: Colors.greenAccent),
                SizedBox(width: 8),
                Text(
                  'Marine Conservation & Fisher Directives',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildDirectiveItem(
              'Artisanal Fisher Guidance',
              dir.artisanalFisherGuidance,
              Icons.anchor,
              Colors.cyan,
            ),
            const SizedBox(height: 10),
            _buildDirectiveItem(
              'Reef Protection & Tourism',
              '${dir.reefProtectionNotice} ${dir.divingTourismAdvisory}',
              Icons.scuba_diving,
              Colors.orangeAccent,
            ),
            const SizedBox(height: 10),
            _buildDirectiveItem(
              'Artificial Shading & Nursery Action',
              dir.artificialShadingStatus,
              Icons.umbrella,
              Colors.purpleAccent,
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
                  'INCOIS Coastal Bulletins',
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
                color: Colors.cyan.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.cyan.withValues(alpha: 0.2)),
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

  Widget _buildInfoTile(String title, String val, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Colors.cyanAccent),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          val,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
              'INCOIS-OOMAD • NOAA Coral Reef Watch (CRW) 5-km SST • MoES Coastal Mission • Bulletin ${_data!.bulletinNumber}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
