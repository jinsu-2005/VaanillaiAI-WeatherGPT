import 'package:flutter/material.dart';
import '../models/coldwave_model.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class ColdWaveScreen extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String? initialStationId;
  final ColdWaveResponseModel? initialData;

  const ColdWaveScreen({
    super.key,
    this.latitude,
    this.longitude,
    this.initialStationId,
    this.initialData,
  });

  @override
  State<ColdWaveScreen> createState() => _ColdWaveScreenState();
}

class _ColdWaveScreenState extends State<ColdWaveScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _selectedStationId;
  ColdWaveResponseModel? _data;
  String _selectedLang = 'en';

  @override
  void initState() {
    super.initState();
    _selectedStationId = widget.initialStationId ?? 'CHURU_RJ';
    if (widget.initialData != null) {
      _data = widget.initialData;
      _selectedStationId = widget.initialData!.stationId;
      _isLoading = false;
    } else {
      _loadAssessment();
    }
  }

  Future<void> _loadAssessment({String? stationId}) async {
    setState(() => _isLoading = true);
    final targetStation = stationId ?? _selectedStationId;
    try {
      final res = await _apiService.getColdWaveAssessment(
        latitude: widget.latitude,
        longitude: widget.longitude,
        stationId: targetStation,
      );
      if (mounted) {
        setState(() {
          _data = res;
          _selectedStationId = res.stationId;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _data = ColdWaveResponseModel.defaultFallback();
          _isLoading = false;
        });
      }
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'SEVERE_COLD_WAVE':
        return const Color(0xFF7C3AED); // Deep Violet
      case 'COLD_WAVE':
        return const Color(0xFF2563EB); // Royal Blue
      case 'COLD_DAY':
        return const Color(0xFF0EA5E9); // Sky Cyan
      default:
        return const Color(0xFF10B981); // Emerald Green
    }
  }

  Color _getFrostColor(String risk) {
    switch (risk) {
      case 'SEVERE':
        return const Color(0xFFDC2626); // Red
      case 'MODERATE':
        return const Color(0xFFF97316); // Orange
      case 'LIGHT':
        return const Color(0xFFEAB308); // Yellow
      default:
        return const Color(0xFF10B981); // Green
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text(
          'Cold Wave & Frost Engine',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Assessment',
            onPressed: () => _loadAssessment(stationId: _selectedStationId),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
              ? Center(
                  child: Text(
                    'No assessment data available.',
                    style: TextStyle(color: textSecondary),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => _loadAssessment(stationId: _selectedStationId),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    children: [
                      // 1. Station Selector Chips
                      _buildStationSelector(textPrimary, isDark),
                      const SizedBox(height: 16),

                      // 2. Hero Severity & Temperature Card
                      _buildHeroSeverityCard(cardBg, border, textPrimary, textSecondary),
                      const SizedBox(height: 16),

                      // 3. Ground Frost & Radiative Physics HUD
                      _buildGroundFrostPhysicsCard(cardBg, border, textPrimary, textSecondary),
                      const SizedBox(height: 16),

                      // 4. ICAR Rabi Crop Protection Advisories
                      _buildCropAdvisoriesSection(cardBg, border, textPrimary, textSecondary),
                      const SizedBox(height: 16),

                      // 5. Urban Shelter & Hypothermia Directives
                      _buildUrbanShelterCard(cardBg, border, textPrimary, textSecondary),
                      const SizedBox(height: 16),

                      // 6. Multilingual Vernacular Directives
                      _buildMultilingualSection(cardBg, border, textPrimary, textSecondary, isDark),
                      const SizedBox(height: 20),

                      // 7. Provenance Disclaimer
                      _buildProvenanceFooter(textSecondary),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStationSelector(Color textPrimary, bool isDark) {
    final stations = _data?.monitoringStations ?? [];
    if (stations.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on_rounded, color: AppColors.brandBlue, size: 16),
            const SizedBox(width: 6),
            Text(
              'Northern & Himalayan Monitoring Stations',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: stations.map((st) {
              final isSelected = st.stationId == _selectedStationId;
              final sevColor = _getSeverityColor(st.coldWaveSeverity);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: isSelected,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: sevColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('${st.stationName} (${st.tMin}°C)'),
                    ],
                  ),
                  onSelected: (_) {
                    setState(() => _selectedStationId = st.stationId);
                    _loadAssessment(stationId: st.stationId);
                  },
                  backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  selectedColor: AppColors.brandBlue.withValues(alpha: 0.25),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.brandBlue : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSeverityCard(Color cardBg, Color border, Color textPrimary, Color textSecondary) {
    final d = _data!;
    final sevColor = _getSeverityColor(d.coldWaveSeverity);
    final sevLabel = d.coldWaveSeverity.replaceAll('_', ' ');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: sevColor.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Station & Severity Pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${d.stationName}, ${d.state}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Elev: ${d.elevationM.toInt()}m · ${d.isHillStation ? "Hills Station" : "Plains Zone"}',
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: sevColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: sevColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  sevLabel,
                  style: TextStyle(
                    color: sevColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Primary Temperatures Row: Air Min vs Grass Min vs Wind Chill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricColumn(
                label: 'Air Min (1.5m)',
                value: '${d.physics.tAirMin}°C',
                subText: 'Norm ${d.physics.tNormalMin}°C',
                valueColor: sevColor,
                textSecondary: textSecondary,
              ),
              Container(width: 1, height: 48, color: border),
              _buildMetricColumn(
                label: 'Grass Min (5cm)',
                value: '${d.physics.tGrassMin}°C',
                subText: 'Ground Level',
                valueColor: _getFrostColor(d.groundFrostRisk),
                textSecondary: textSecondary,
              ),
              Container(width: 1, height: 48, color: border),
              _buildMetricColumn(
                label: 'Wind Chill',
                value: '${d.physics.windChillC}°C',
                subText: 'Apparent',
                valueColor: AppColors.brandBlue,
                textSecondary: textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Headline Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: sevColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: sevColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.ac_unit_rounded, color: sevColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    d.summaryHeadline,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
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

  Widget _buildMetricColumn({
    required String label,
    required String value,
    required String subText,
    required Color valueColor,
    required Color textSecondary,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: valueColor),
        ),
        const SizedBox(height: 2),
        Text(
          subText,
          style: TextStyle(fontSize: 10.5, color: textSecondary),
        ),
      ],
    );
  }

  Widget _buildGroundFrostPhysicsCard(Color cardBg, Color border, Color textPrimary, Color textSecondary) {
    final d = _data!;
    final p = d.physics;
    final frostColor = _getFrostColor(d.groundFrostRisk);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.dew_point, color: Colors.cyan, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ground Frost Radiation Physics (Stefan-Boltzmann)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: frostColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: frostColor.withValues(alpha: 0.35)),
                ),
                child: Text(
                  '${d.groundFrostRisk} FROST',
                  style: TextStyle(
                    color: frostColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 4 Grid Tiles of Physical Boundary Layer Metrics
          Row(
            children: [
              Expanded(
                child: _buildPhysicsTile(
                  label: 'Net Radiation Loss',
                  value: '${p.netRadiationLossWm2} W/m²',
                  icon: Icons.wb_twilight_rounded,
                  iconColor: Colors.amber,
                  border: border,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildPhysicsTile(
                  label: 'Cloud Cover',
                  value: '${p.skyCoverOktas}/8 Oktas',
                  icon: Icons.cloud_queue_rounded,
                  iconColor: Colors.lightBlue,
                  border: border,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildPhysicsTile(
                  label: 'Surface Winds',
                  value: '${p.windSpeedKmh} km/h',
                  icon: Icons.air_rounded,
                  iconColor: Colors.teal,
                  border: border,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildPhysicsTile(
                  label: 'Dew Point',
                  value: '${p.dewPointC}°C',
                  icon: Icons.water_drop_outlined,
                  iconColor: Colors.blueAccent,
                  border: border,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Physics Note: Terrestrial nocturnal radiation causes grass minimum temperature (T_grass) to drop 3°–5°C colder than standard Stevenson screen thermometers under calm, clear winter skies.',
            style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPhysicsTile({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: border.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 10.5, color: textSecondary),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropAdvisoriesSection(Color cardBg, Color border, Color textPrimary, Color textSecondary) {
    final advisories = _data?.rabiCropAdvisories ?? [];
    if (advisories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.agriculture_rounded, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Text(
              'ICAR Rabi Crop Frost Vulnerability & Directives',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...advisories.map((crop) => _buildCropCard(crop, cardBg, border, textPrimary, textSecondary)),
      ],
    );
  }

  Widget _buildCropCard(
    CropVulnerabilityItemModel crop,
    Color cardBg,
    Color border,
    Color textPrimary,
    Color textSecondary,
  ) {
    final hasHighRisk = crop.yieldLossRiskPct >= 30;
    final riskColor = hasHighRisk ? Colors.redAccent : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  crop.cropName,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${crop.yieldLossRiskPct}% Loss Risk',
                  style: TextStyle(
                    color: riskColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Stage: ${crop.criticalStage}',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.brandBlue),
          ),
          const SizedBox(height: 8),
          Text(
            crop.injuryMechanism,
            style: TextStyle(fontSize: 12, color: textSecondary),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Text(
            'Actionable Countermeasures:',
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: textPrimary),
          ),
          const SizedBox(height: 6),
          ...crop.countermeasures.map(
            (action) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      action,
                      style: TextStyle(fontSize: 11.5, color: textPrimary),
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

  Widget _buildUrbanShelterCard(Color cardBg, Color border, Color textPrimary, Color textSecondary) {
    final shelter = _data?.urbanShelter;
    if (shelter == null) return const SizedBox.shrink();

    final isNightActive = shelter.nightShelterActivated;
    final riskColor = shelter.hypothermiaRisk == 'EXTREME'
        ? Colors.red
        : (shelter.hypothermiaRisk == 'HIGH' ? Colors.orange : Colors.yellow.shade700);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.night_shelter_rounded, color: Colors.indigoAccent, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Urban Rain Basera & Public Health Directive',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isNightActive ? Colors.green.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isNightActive ? 'SHELTERS OPEN' : 'STANDBY',
                  style: TextStyle(
                    color: isNightActive ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.w800,
                    fontSize: 10.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hypothermia Risk',
                      style: TextStyle(fontSize: 11, color: textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      shelter.hypothermiaRisk,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: riskColor),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recommended Attire',
                      style: TextStyle(fontSize: 11, color: textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${shelter.recommendedClothingLayers} Layers (Thermal)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textPrimary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Text(
            'Animal Husbandry & Dairy Cattle Care:',
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: textPrimary),
          ),
          const SizedBox(height: 6),
          ...shelter.livestockProtectionRules.map(
            (rule) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🐄 ', style: TextStyle(fontSize: 12)),
                  Expanded(
                    child: Text(
                      rule,
                      style: TextStyle(fontSize: 11.5, color: textPrimary),
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

  Widget _buildMultilingualSection(
    Color cardBg,
    Color border,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    final bulletins = _data?.multilingualBulletins ?? {};
    if (bulletins.isEmpty) return const SizedBox.shrink();

    final languages = [
      {'code': 'en', 'label': 'English'},
      {'code': 'hi', 'label': 'हिंदी'},
      {'code': 'pa', 'label': 'ਪੰਜਾਬੀ'},
      {'code': 'bn', 'label': 'বাংলা'},
      {'code': 'ur', 'label': 'اردو'},
    ];

    final currentText = bulletins[_selectedLang] ?? bulletins['en'] ?? '';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.translate_rounded, color: Colors.blueAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                'Multilingual Emergency Bulletins',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: languages.map((lang) {
                final isSel = _selectedLang == lang['code'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(lang['label']!),
                    selected: isSel,
                    onSelected: (val) {
                      if (val) setState(() => _selectedLang = lang['code']!);
                    },
                    selectedColor: AppColors.brandBlue,
                    backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : textPrimary,
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            child: Text(
              currentText,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w500,
                color: textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProvenanceFooter(Color textSecondary) {
    final disclaimer = _data?.provenanceDisclaimer ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user_rounded, color: Colors.teal.shade400, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              disclaimer,
              style: TextStyle(
                fontSize: 11,
                color: textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
