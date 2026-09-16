import 'package:flutter/material.dart';
import '../models/flash_drought_model.dart';
import '../services/api_service.dart';

class FlashDroughtScreen extends StatefulWidget {
  final FlashDroughtResponseModel? initialData;

  const FlashDroughtScreen({super.key, this.initialData});

  @override
  State<FlashDroughtScreen> createState() => _FlashDroughtScreenState();
}

class _FlashDroughtScreenState extends State<FlashDroughtScreen> {
  final ApiService _apiService = ApiService();
  FlashDroughtResponseModel? _data;
  bool _isLoading = false;
  String _selectedHotspotId = 'VIDARBHA_HOTSPOT';
  String _selectedLanguage = 'en';

  static const Map<String, String> _languageNames = {
    'en': 'English',
    'hi': 'हिन्दी (HI)',
    'mr': 'मराठी (MR)',
    'te': 'తెలుగు (TE)',
    'kn': 'ಕನ್ನಡ (KN)',
    'gu': 'ગુજરાતી (GU)',
    'bn': 'বাংলা (BN)',
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _data = widget.initialData;
      _selectedHotspotId = widget.initialData!.hotspot.hotspotId;
    } else {
      _loadData();
    }
  }

  Future<void> _loadData({String? hotspotId}) async {
    setState(() => _isLoading = true);
    final targetHotspot = hotspotId ?? _selectedHotspotId;
    final assessment =
        await _apiService.getFlashDroughtAssessment(hotspotId: targetHotspot);
    if (mounted) {
      setState(() {
        _data = assessment;
        _selectedHotspotId = targetHotspot;
        _isLoading = false;
      });
    }
  }

  Color _getIntensityColor(String tier) {
    switch (tier.toUpperCase()) {
      case 'EXTREME_FLASH_DROUGHT':
        return const Color(0xFFDC2626); // Deep Crimson
      case 'SEVERE_FLASH_DROUGHT':
        return const Color(0xFFEA580C); // Burnt Orange
      case 'MODERATE_FLASH_DROUGHT':
        return const Color(0xFFD97706); // Amber
      case 'FLASH_DROUGHT_WATCH':
        return const Color(0xFFEAB308); // Yellow
      case 'NORMAL_MOISTURE_REGIME':
      default:
        return const Color(0xFF059669); // Emerald
    }
  }

  Color _getVulnerabilityColor(String tier) {
    switch (tier.toUpperCase()) {
      case 'CRITICAL_REPRODUCTIVE_SUSCEPTIBILITY':
        return const Color(0xFFDC2626);
      case 'HIGH_VEGETATIVE_STRESS':
        return const Color(0xFFEA580C);
      case 'MODERATE_ESTABLISHMENT_RISK':
        return const Color(0xFFD97706);
      case 'LOW_MATURITY_RESILIENCE':
      default:
        return const Color(0xFF059669);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hotspot = _data?.hotspot;
    final intensityColor = _getIntensityColor(
      _data?.overallIntensityTier ?? 'SEVERE_FLASH_DROUGHT',
    );

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0B132B) : const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Flash Drought & Soil Desiccation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              'IMD, CWC & ICAR-CRIDA Rapid Drought Engine',
              style: TextStyle(
                fontSize: 11,
                color:
                    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Flash Drought Telemetry',
            onPressed: () => _loadData(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text(
                    'Computing Penman-Monteith Evaporative Demand & EDDI...',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hotspot Selector Chips
                  _buildHotspotSelector(isDark),
                  const SizedBox(height: 16),

                  // Hero Rapid Intensification Card
                  _buildHeroCard(isDark, hotspot, intensityColor),
                  const SizedBox(height: 16),

                  // Atmospheric Evaporative Demand & VPD Card
                  _buildAtmosphericDemandCard(isDark),
                  const SizedBox(height: 16),

                  // 2-Depth Soil Desiccation & ESI Matrix Card
                  _buildSoilDesiccationCard(isDark),
                  const SizedBox(height: 16),

                  // Crop Phenological Vulnerability Card
                  _buildCropVulnerabilityCard(isDark),
                  const SizedBox(height: 16),

                  // ICAR-CRIDA Agronomic Rescue & Pulse Irrigation Directives
                  _buildDirectivesCard(isDark),
                  const SizedBox(height: 16),

                  // 7-Language Vernacular Advisories Card
                  _buildVernacularCard(isDark),
                  const SizedBox(height: 16),

                  // National Rainfed Hotspots Network Grid
                  _buildMonitoredHotspotsGrid(isDark),
                  const SizedBox(height: 16),

                  // Institutional Provenance & Metadata Card
                  _buildInstitutionalMetadataCard(isDark),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildHotspotSelector(bool isDark) {
    final hotspots = _data?.monitoredHotspots ?? [];
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: hotspots.isNotEmpty ? hotspots.length : 7,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (hotspots.isEmpty) return const SizedBox();
          final item = hotspots[index];
          final isSelected = item.hotspotId == _selectedHotspotId;
          final tierColor = _getIntensityColor(item.intensityTier);

          return FilterChip(
            selected: isSelected,
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: tierColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  item.name.replaceAll(' Hotspot', '').replaceAll(' Basin', ''),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
              ],
            ),
            selectedColor: const Color(0xFFD97706),
            backgroundColor:
                isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            onSelected: (selected) {
              if (selected && item.hotspotId != _selectedHotspotId) {
                _loadData(hotspotId: item.hotspotId);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildHeroCard(
      bool isDark, FlashDroughtHotspotModel? hotspot, Color intensityColor) {
    final assessment = _data;
    if (assessment == null || hotspot == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [Colors.white, const Color(0xFFF8FAFC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: intensityColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: intensityColor.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotspot.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${hotspot.districts.join(", ")} • ${hotspot.state}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: intensityColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: intensityColor, width: 1.2),
                ),
                child: Text(
                  assessment.overallIntensityTier.replaceAll('_', ' '),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: intensityColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (assessment.rapidIntensificationDetected)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFDC2626).withValues(alpha: 0.4),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.bolt, color: Color(0xFFDC2626), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'RAPID INTENSIFICATION DETECTED: Root-zone soil moisture dropped ≥20 percentiles in ≤14 days under acute atmospheric evaporative demand.',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildHeroMetricTile(
                  label: '2-Week EDDI',
                  value: '${assessment.atmosphericDemand.eddi2week > 0 ? '+' : ''}${assessment.atmosphericDemand.eddi2week}',
                  icon: Icons.local_fire_department,
                  color: const Color(0xFFEA580C),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildHeroMetricTile(
                  label: 'Root Percentile',
                  value: '${assessment.soilDesiccation.rootzonePercentile}th',
                  icon: Icons.grass,
                  color: const Color(0xFFD97706),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildHeroMetricTile(
                  label: 'Irrigation Cover',
                  value: '${hotspot.irrigationCoveragePct}%',
                  icon: Icons.water,
                  color: const Color(0xFF0284C7),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B132B) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAtmosphericDemandCard(bool isDark) {
    final atm = _data?.atmosphericDemand;
    if (atm == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.wb_sunny, color: Color(0xFFEA580C), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Atmospheric Evaporative Thirst & VPD',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEA580C).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  atm.evaporativeDemandTier.replaceAll('_', ' '),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFEA580C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildParamTile(
                  'Penman-Monteith E0',
                  '${atm.referenceEvapotranspirationE0MmDay} mm/d',
                  'Atmospheric demand',
                  isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildParamTile(
                  'Vapor Pressure Deficit',
                  '${atm.vaporPressureDeficitKpa} kPa',
                  'Severe drying vapor',
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildParamTile(
                  'Daytime Max Temp',
                  '${atm.airTemperatureMaxC}°C',
                  '+${atm.tempMaxDepartureC}°C vs normal',
                  isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildParamTile(
                  'Net Solar Radiation',
                  '${atm.solarRadiationMjM2Day} MJ/m²',
                  'Surface heat flux',
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParamTile(
      String label, String value, String subtext, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoilDesiccationCard(bool isDark) {
    final soil = _data?.soilDesiccation;
    if (soil == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.layers, color: Color(0xFFD97706), size: 20),
                  SizedBox(width: 8),
                  Text(
                    '2-Depth Soil Desiccation & ESI',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  soil.desiccationVelocity.replaceAll('_', ' '),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildParamTile(
                  'Topsoil (0-10 cm)',
                  '${soil.topsoilMoisture010cmPct}% VWC',
                  'Desiccated crust',
                  isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildParamTile(
                  'Root Zone (10-40 cm)',
                  '${soil.rootzoneMoisture1040cmPct}% VWC',
                  'Plummeting storage',
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildParamTile(
                  '14-Day Drop',
                  '-${soil.percentileDrop14days}% pctiles',
                  '${soil.desiccationRatePctPerDay}% VWC/day',
                  isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildParamTile(
                  'Evaporative Stress (ESI)',
                  '${soil.evaporativeStressIndexEsi}',
                  '${soil.consecutiveRainlessDays} rainless days',
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Root-Zone Soil Moisture Percentile relative to Climatology:',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (soil.rootzonePercentile / 100.0).clamp(0.0, 1.0),
              backgroundColor: isDark ? Colors.white12 : Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(
                soil.rootzonePercentile <= 20
                    ? const Color(0xFFDC2626)
                    : const Color(0xFFD97706),
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropVulnerabilityCard(bool isDark) {
    final crop = _data?.cropVulnerability;
    if (crop == null) return const SizedBox();

    final vulnColor = _getVulnerabilityColor(crop.vulnerabilityTier);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: vulnColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.eco, color: Color(0xFF10B981), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Crop Vulnerability: ${crop.primaryCrop}',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: vulnColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  crop.vulnerabilityTier.replaceAll('_', ' '),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: vulnColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Stage: ${crop.currentGrowthStage}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildParamTile(
                  'Projected Yield Loss',
                  '${crop.yieldLossRiskPct}%',
                  'Unmitigated impact',
                  isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildParamTile(
                  'Damage Multiplier',
                  '${crop.damageMultiplier}x',
                  'Phenological weight',
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              crop.transpirationalStressLabel,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectivesCard(bool isDark) {
    final directives = _data?.directives;
    if (directives == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2563EB).withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.healing, color: Color(0xFF2563EB), size: 20),
              SizedBox(width: 8),
              Text(
                'ICAR-CRIDA Emergency Directives',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.sanitizer, color: Color(0xFF2563EB), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    directives.antiTranspirantSprayRecommendation,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...directives.actionableBulletPoints.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        width: 18,
                        height: 18,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2563EB),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
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

  Widget _buildVernacularCard(bool isDark) {
    final bulletins = _data?.vernacularBulletins ?? {};
    final bulletinText = bulletins[_selectedLanguage] ??
        bulletins['en'] ??
        'Advisory currently unavailable.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.language, color: Color(0xFF10B981), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Regional Vernacular Bulletin',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              DropdownButton<String>(
                value: _selectedLanguage,
                underline: const SizedBox(),
                isDense: true,
                items: _languageNames.entries
                    .map((e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value, style: const TextStyle(fontSize: 12)),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedLanguage = val);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              bulletinText,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonitoredHotspotsGrid(bool isDark) {
    final hotspots = _data?.monitoredHotspots ?? [];
    if (hotspots.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'National Monitored Flash Drought Hotspots',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...hotspots.map((h) {
            final isCurrent = h.hotspotId == _selectedHotspotId;
            final tierColor = _getIntensityColor(h.intensityTier);

            return InkWell(
              onTap: () {
                if (h.hotspotId != _selectedHotspotId) {
                  _loadData(hotspotId: h.hotspotId);
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? (isDark
                          ? const Color(0xFFD97706).withValues(alpha: 0.2)
                          : const Color(0xFFFEF3C7))
                      : (isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF8FAFC)),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCurrent
                        ? const Color(0xFFD97706)
                        : (isDark ? Colors.white12 : Colors.black12),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: tierColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            h.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isCurrent
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${h.state} • ${h.primaryCrop} • EDDI: ${h.eddi2week > 0 ? '+' : ''}${h.eddi2week}',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      h.intensityTier.replaceAll('_', ' '),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: tierColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInstitutionalMetadataCard(bool isDark) {
    final meta = _data?.metadata ?? {};

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified,
                color: isDark ? Colors.cyanAccent : const Color(0xFF0284C7),
                size: 16,
              ),
              const SizedBox(width: 6),
              const Text(
                'Institutional Provenance & Scientific Framework',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Authority: ${meta['source_authority'] ?? 'IMD Agromet, CWC & ICAR-CRIDA'}\n'
            'Index: ${meta['scientific_framework'] ?? 'EDDI & Rapid Intensification (Otkin & Mishra et al.)'}\n'
            'Evapotranspiration Standard: ${meta['evapotranspiration_standard'] ?? 'FAO-56 Penman-Monteith'}\n'
            'Contingency Plan: ${meta['agronomic_guidelines'] ?? 'ICAR-CRIDA NICRA Protocols'}',
            style: TextStyle(
              fontSize: 10,
              height: 1.4,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
