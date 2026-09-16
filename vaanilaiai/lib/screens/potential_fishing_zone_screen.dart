import 'package:flutter/material.dart';
import '../models/potential_fishing_zone_model.dart';
import '../services/api_service.dart';

class PotentialFishingZoneScreen extends StatefulWidget {
  final String? initialSectorId;
  final String? initialCraftType;
  final PfzResponseModel? initialData;

  const PotentialFishingZoneScreen({
    super.key,
    this.initialSectorId,
    this.initialCraftType,
    this.initialData,
  });

  @override
  State<PotentialFishingZoneScreen> createState() =>
      _PotentialFishingZoneScreenState();
}

class _PotentialFishingZoneScreenState
    extends State<PotentialFishingZoneScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _errorMessage;
  PfzResponseModel? _data;
  String _selectedSectorId = 'kochi_malabar';
  String _selectedCraftType = 'TRADITIONAL_MOTORIZED_FRP';
  String _selectedLanguage = 'en';

  final List<Map<String, String>> _craftOptions = [
    {
      'key': 'TRADITIONAL_MOTORIZED_FRP',
      'label': 'FRP Motorized Craft (OBM)',
      'desc': 'Artisanal 8.5–9.5m fibreglass boat, 9.9–25 HP engine',
    },
    {
      'key': 'MECHANIZED_TRAWLER_SINGLE_DAY',
      'label': 'Mechanized Trawler (Single Day)',
      'desc': 'Single-day coastal diesel trawler (35–45ft)',
    },
    {
      'key': 'MECHANIZED_MULTI_DAY_TRAWLER',
      'label': 'Mechanized Multi-Day Trawler',
      'desc': 'Deep-sea multi-day voyage vessel (55–65ft, 160 HP)',
    },
    {
      'key': 'MOTORIZED_CATAMARAN_CANOE',
      'label': 'Traditional Canoe / Catamaran',
      'desc': 'Near-shore beach landing artisanal craft',
    },
  ];

  final Map<String, String> _languageNames = {
    'en': 'English',
    'ml': 'മലയാളം (ML)',
    'ta': 'தமிழ் (TA)',
    'te': 'తెలుగు (TE)',
    'gu': 'ગુજરાતી (GU)',
    'mr': 'मराठी (MR)',
    'bn': 'বাংলা (BN)',
    'od': 'ଓଡ଼ିଆ (OD)',
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialSectorId != null) {
      _selectedSectorId = widget.initialSectorId!;
    }
    if (widget.initialCraftType != null) {
      _selectedCraftType = widget.initialCraftType!;
    }
    if (widget.initialData != null) {
      _data = widget.initialData;
      _isLoading = false;
      _selectedSectorId = widget.initialData!.sectorId;
    } else {
      _loadData();
    }
  }

  Future<void> _loadData({String? sectorId, String? craftType}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      if (sectorId != null) _selectedSectorId = sectorId;
      if (craftType != null) _selectedCraftType = craftType;
    });

    try {
      final res = await _apiService.getPotentialFishingZoneAssessment(
        sectorId: _selectedSectorId,
        craftType: _selectedCraftType,
        language: _selectedLanguage,
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
          _errorMessage = e.toString();
          _data = PfzResponseModel.defaultFallback();
          _isLoading = false;
        });
      }
    }
  }

  Color _getProductivityColor(String tier) {
    switch (tier.toUpperCase()) {
      case 'OPTIMAL_HIGH_YIELD':
      case 'HIGH_BLOOM':
        return const Color(0xFF10B981); // Emerald
      case 'MODERATE_FRONT':
      case 'MODERATE_YIELD':
        return const Color(0xFF0284C7); // Ocean Blue
      case 'MARGINAL_WEAK':
      case 'MARGINAL_YIELD':
        return const Color(0xFFD97706); // Amber
      default:
        return const Color(0xFF64748B); // Slate
    }
  }

  String _formatProductivityLabel(String tier) {
    switch (tier.toUpperCase()) {
      case 'OPTIMAL_HIGH_YIELD':
      case 'HIGH_BLOOM':
        return 'OPTIMAL HIGH YIELD (RICH BLOOM)';
      case 'MODERATE_FRONT':
      case 'MODERATE_YIELD':
        return 'MODERATE YIELD (SST THERMAL FRONT)';
      case 'MARGINAL_WEAK':
      case 'MARGINAL_YIELD':
        return 'MARGINAL YIELD (DIFFUSE)';
      default:
        return 'LOW / BARREN WATER';
    }
  }

  String _formatSpeciesName(String species) {
    return species
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}' : '')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentSector = _data?.currentSector;
    final prodTier = currentSector?.oceanColor.productivityTier ?? 'OPTIMAL_HIGH_YIELD';
    final prodColor = _getProductivityColor(prodTier);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B132B) : const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Potential Fishing Zone (PFZ)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              'INCOIS Ocean Color & CMFRI Conservation Radar',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh PFZ Feeds',
            onPressed: () => _loadData(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF0284C7)),
                  SizedBox(height: 16),
                  Text(
                    'Synthesizing Oceansat-3 OCM & INSAT-3DR SST Feeds...',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => _loadData(),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  if (_errorMessage != null) _buildOfflineBanner(isDark),
                  _buildSectorSelector(isDark),
                  const SizedBox(height: 12),
                  _buildCraftTypeSelector(isDark),
                  const SizedBox(height: 16),
                  if (currentSector != null) ...[
                    _buildHeroVectorCard(currentSector, prodColor, isDark),
                    const SizedBox(height: 14),
                    _buildOceanTelemetryCard(currentSector, isDark),
                    const SizedBox(height: 14),
                    _buildFuelEconomicsCard(currentSector.fuelSavings, isDark),
                    const SizedBox(height: 14),
                    _buildConservationCard(currentSector.conservation, isDark),
                    const SizedBox(height: 14),
                    _buildVernacularBroadcastCard(currentSector, isDark),
                  ],
                  const SizedBox(height: 16),
                  _buildInstitutionalAttribution(isDark),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildOfflineBanner(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFD97706).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD97706).withValues(alpha: 0.4)),
      ),
      child: const Row(
        children: [
          Icon(Icons.wifi_off, color: Color(0xFFD97706), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Offline mode active. Displaying calibrated INCOIS-PFZ satellite baseline.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectorSelector(bool isDark) {
    final sectors = _data?.allSectors ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'COASTAL FISHING HUBS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            Text(
              '${sectors.length} Operational Sectors',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0284C7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: sectors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final s = sectors[index];
              final isSelected = s.sectorId == _selectedSectorId;
              final chipColor = _getProductivityColor(s.productivityTier);

              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: chipColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${s.sectorName} (${s.state})',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155)),
                      ),
                    ),
                  ],
                ),
                selected: isSelected,
                selectedColor: const Color(0xFF0284C7),
                backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                onSelected: (selected) {
                  if (selected) {
                    _loadData(sectorId: s.sectorId);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCraftTypeSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_boat, size: 16, color: Color(0xFF0284C7)),
              const SizedBox(width: 8),
              Text(
                'FISHING CRAFT FLEET PROFILE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedCraftType,
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0284C7)),
              dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              items: _craftOptions.map((opt) {
                return DropdownMenuItem<String>(
                  value: opt['key'],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        opt['label']!,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        opt['desc']!,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  _loadData(craftType: val);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroVectorCard(
    PfzSectorModel sector,
    Color prodColor,
    bool isDark,
  ) {
    final nav = sector.navigationalVector;
    final prodTier = sector.oceanColor.productivityTier;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0F2027),
                  const Color(0xFF203A43),
                  const Color(0xFF2C5364),
                ]
              : [
                  const Color(0xFFE0F2FE),
                  const Color(0xFFBAE6FD),
                  const Color(0xFFE0F2FE),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: prodColor.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: prodColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: prodColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.radar, size: 14, color: prodColor),
                    const SizedBox(width: 6),
                    Text(
                      _formatProductivityLabel(prodTier),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: prodColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Sea: ${sector.coastalSea}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            sector.sectorName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.set_meal, size: 16, color: prodColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Target Pelagics: ${_formatSpeciesName(sector.primarySpecies)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Navigational Compass HUD
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0B132B).withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildVectorMetric(
                  icon: Icons.explore,
                  label: 'TRUE BEARING',
                  value: '${nav.trueBearingDegrees}°',
                  sub: nav.compassDirection,
                  accent: const Color(0xFF0284C7),
                  isDark: isDark,
                ),
                _buildVectorDivider(isDark),
                _buildVectorMetric(
                  icon: Icons.straighten,
                  label: 'DISTANCE',
                  value: '${nav.distanceNauticalMiles.toStringAsFixed(1)} nm',
                  sub: '(${nav.distanceKilometers.toStringAsFixed(1)} km)',
                  accent: const Color(0xFF06B6D4),
                  isDark: isDark,
                ),
                _buildVectorDivider(isDark),
                _buildVectorMetric(
                  icon: Icons.water,
                  label: 'TARGET DEPTH',
                  value: '${nav.targetDepthFathoms} fathoms',
                  sub: '(${nav.targetDepthMeters.toStringAsFixed(0)} m)',
                  accent: const Color(0xFF3B82F6),
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.anchor, size: 14, color: Color(0xFF0284C7)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Base Port: ${nav.landingHarbourName}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Centroid Coordinates: ${nav.centroidLatitude.toStringAsFixed(2)}°N, ${nav.centroidLongitude.toStringAsFixed(2)}°E',
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVectorMetric({
    required IconData icon,
    required String label,
    required String value,
    required String sub,
    required Color accent,
    required bool isDark,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: accent),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        Text(
          sub,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: accent,
          ),
        ),
      ],
    );
  }

  Widget _buildVectorDivider(bool isDark) {
    return Container(
      height: 38,
      width: 1,
      color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
    );
  }

  Widget _buildOceanTelemetryCard(PfzSectorModel sector, bool isDark) {
    final color = sector.oceanColor;
    final sst = sector.thermalFront;
    final isCyclonic = sst.mesoscaleEddyType.toUpperCase().contains('CYCLONIC');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lens_blur, size: 18, color: Color(0xFF10B981)),
              const SizedBox(width: 8),
              Text(
                'OCEAN COLOR & SST THERMAL FRONT HUD',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTelemetryMetricBox(
                  title: 'CHLOROPHYLL-A',
                  value: '${color.chlorophyllAMgM3.toStringAsFixed(2)} mg/m³',
                  badge: color.productivityTier.replaceAll('_', ' '),
                  badgeColor: const Color(0xFF10B981),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTelemetryMetricBox(
                  title: 'DIFFUSE ATTENUATION (k490)',
                  value: '${color.diffuseAttenuationK490.toStringAsFixed(3)} m⁻¹',
                  badge: color.phytoplanktonBloomActive ? 'Active Bloom' : 'Clear Upwelling',
                  badgeColor: const Color(0xFF06B6D4),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTelemetryMetricBox(
                  title: 'SEA SURFACE TEMP (SST)',
                  value: '${sst.seaSurfaceTempCelsius.toStringAsFixed(1)} °C',
                  badge: 'Front: ${sst.sstGradientDegCPerKm.toStringAsFixed(2)} °C/km',
                  badgeColor: const Color(0xFF0284C7),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTelemetryMetricBox(
                  title: 'EDDY UPWELLING DYNAMICS',
                  value: isCyclonic ? 'Cyclonic Cold-Core' : 'Linear Front',
                  badge: 'SSHA: ${sst.seaSurfaceHeightAnomalyCm >= 0 ? "+" : ""}${sst.seaSurfaceHeightAnomalyCm.toStringAsFixed(1)} cm',
                  badgeColor: isCyclonic ? const Color(0xFF8B5CF6) : const Color(0xFF64748B),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryMetricBox({
    required String title,
    required String value,
    required String badge,
    required Color badgeColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              badge,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFuelEconomicsCard(
    EconomicFuelSavingsModel fuel,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F291E)]
              : [const Color(0xFFF0FDF4), const Color(0xFFDCFCE7)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_gas_station, color: Color(0xFF10B981), size: 18),
              const SizedBox(width: 8),
              Text(
                'ARTISANAL FUEL CONSERVATION & SAVINGS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.9,
                  color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFuelMetric(
                label: 'DIESEL SAVED',
                value: '${fuel.dieselSavedLiters.toStringAsFixed(0)} L',
                color: const Color(0xFF10B981),
                isDark: isDark,
              ),
              _buildFuelMetric(
                label: 'RUPEE SAVINGS',
                value: '₹${fuel.rupeeFuelCostSavingsInr.toStringAsFixed(0)}',
                color: const Color(0xFF059669),
                isDark: isDark,
              ),
              _buildFuelMetric(
                label: 'SCOUTING TIME',
                value: '-${fuel.scoutingTimeReductionPct.toStringAsFixed(0)}%',
                color: const Color(0xFF0284C7),
                isDark: isDark,
              ),
              _buildFuelMetric(
                label: 'CO₂ MITIGATION',
                value: '${fuel.carbonEmissionReductionKgCo2.toStringAsFixed(0)} kg',
                color: const Color(0xFF0D9488),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Direct advisory coordinates reduce searching time and fuel consumption for ${fuel.craftType.replaceAll('_', ' ')}.',
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFuelMetric({
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildConservationCard(
    EcologicalConservationBoundaryModel eco,
    bool isDark,
  ) {
    final isViolationRisk = eco.mpaBufferViolationRisk != 'SAFE_OUTSIDE_BUFFER';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isViolationRisk
              ? const Color(0xFFE11D48).withValues(alpha: 0.6)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shield,
                size: 18,
                color: isViolationRisk
                    ? const Color(0xFFE11D48)
                    : const Color(0xFF0284C7),
              ),
              const SizedBox(width: 8),
              Text(
                'CMFRI ECOLOGICAL SAFEGUARDS & MLS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.9,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Protected Marine Area: ${eco.nearestMpaName}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${eco.distanceToMpaBoundaryKm.toStringAsFixed(1)} km clear',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0284C7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Minimum Legal Size (MLS): ${eco.minimumLegalSizeAdvisory}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Artisanal Zone: ${eco.artisanalExclusiveZoneStatus}',
            style: TextStyle(
              fontSize: 10,
              fontStyle: FontStyle.italic,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVernacularBroadcastCard(PfzSectorModel sector, bool isDark) {
    final bulletins = sector.vernacularBulletins;
    final activeBulletin =
        bulletins[_selectedLanguage] ?? bulletins['en'] ?? 'Advisory unavailable.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
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
                  const Icon(Icons.campaign, color: Color(0xFF0284C7), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'COASTAL FISHERMAN BULLETIN',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.9,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const Icon(Icons.volume_up, size: 18, color: Color(0xFF0284C7)),
            ],
          ),
          const SizedBox(height: 10),
          // Language Chips
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _languageNames.entries.map((entry) {
                final isSelected = entry.key == _selectedLanguage;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF0284C7),
                    backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    onSelected: (sel) {
                      if (sel) {
                        setState(() {
                          _selectedLanguage = entry.key;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Text(
              activeBulletin,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstitutionalAttribution(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B132B) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified, color: Color(0xFF0284C7), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _data?.dataSource ??
                  'Operational Service under INCOIS-MoES & ICAR-CMFRI Marine Fisheries Intelligence Framework. Satellite Chlorophyll-a via Oceansat-3 OCM & SST via INSAT-3DR.',
              style: TextStyle(
                fontSize: 10,
                height: 1.3,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
