import 'package:flutter/material.dart';
import '../models/urban_heat_island_model.dart';
import '../services/api_service.dart';

class UrbanHeatIslandScreen extends StatefulWidget {
  final String? initialCorridorId;
  final UrbanHeatIslandResponseModel? initialData;

  const UrbanHeatIslandScreen({
    super.key,
    this.initialCorridorId,
    this.initialData,
  });

  @override
  State<UrbanHeatIslandScreen> createState() => _UrbanHeatIslandScreenState();
}

class _UrbanHeatIslandScreenState extends State<UrbanHeatIslandScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _errorMessage;
  UrbanHeatIslandResponseModel? _data;
  String _selectedCorridorId = 'delhi_ncr';
  String _selectedRoofType = 'HIGH_ALBEDO_ELASTOMERIC_WHITE';
  String _selectedLanguage = 'en';

  final List<Map<String, String>> _roofOptions = [
    {
      'key': 'HIGH_ALBEDO_ELASTOMERIC_WHITE',
      'label': 'High-Albedo Elastomeric (SRI 104)',
      'desc': 'Reflective acrylic white coating',
    },
    {
      'key': 'REFLECTIVE_CERAMIC_TILES',
      'label': 'White Ceramic Mosaic (SRI 85)',
      'desc': 'High-emittance glazed floor tiles',
    },
    {
      'key': 'SLAKED_LIME_WASH',
      'label': 'Traditional Lime Wash (SRI 78)',
      'desc': 'Low-cost slaked lime (Chuna) coat',
    },
    {
      'key': 'STANDARD_CONCRETE_UNCOATED',
      'label': 'Standard Uncoated Concrete (SRI 20)',
      'desc': 'Conventional bare weathered roof slab',
    },
    {
      'key': 'CORRUGATED_GALVANIZED_TIN',
      'label': 'Corrugated Galvanized Tin (SRI 12)',
      'desc': 'High heat conductive sheet roof',
    },
  ];

  final Map<String, String> _languageNames = {
    'en': 'English',
    'hi': 'हिन्दी',
    'gu': 'ગુજરાતી',
    'mr': 'मराठी',
    'kn': 'ಕನ್ನಡ',
    'ta': 'தமிழ்',
    'bn': 'বাংলা',
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialCorridorId != null) {
      _selectedCorridorId = widget.initialCorridorId!;
    }
    if (widget.initialData != null) {
      _data = widget.initialData;
      _isLoading = false;
      _selectedCorridorId = widget.initialData!.corridorId;
    } else {
      _loadData();
    }
  }

  Future<void> _loadData({String? corridorId, String? roofType}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      if (corridorId != null) _selectedCorridorId = corridorId;
      if (roofType != null) _selectedRoofType = roofType;
    });

    try {
      final res = await _apiService.getUrbanHeatIslandAssessment(
        corridorId: _selectedCorridorId,
        roofType: _selectedRoofType,
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
          _data = UrbanHeatIslandResponseModel.defaultFallback();
          _isLoading = false;
        });
      }
    }
  }

  Color _getSeverityColor(String threatLevel) {
    switch (threatLevel.toUpperCase()) {
      case 'CRITICAL_EXTREME':
        return const Color(0xFFDC2626); // Deep Red
      case 'HIGH_SEVERE':
        return const Color(0xFFEA580C); // Orange Red
      case 'MODERATE_ELEVATED':
        return const Color(0xFFD97706); // Amber
      default:
        return const Color(0xFF16A34A); // Emerald
    }
  }

  String _formatThreatTitle(String threatLevel) {
    switch (threatLevel.toUpperCase()) {
      case 'CRITICAL_EXTREME':
        return 'CRITICAL EXTREME UHI';
      case 'HIGH_SEVERE':
        return 'HIGH SEVERE UHI';
      case 'MODERATE_ELEVATED':
        return 'MODERATE ELEVATED UHI';
      default:
        return 'LOW NEGLIGIBLE UHI';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final corridor = _data?.currentCorridor;
    final sevColor = _getSeverityColor(corridor?.threatLevel ?? 'HIGH_SEVERE');

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Urban Heat Island & Cool Roofs',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              'IMD Mesonet & NDMA Mission Cool Roofs',
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
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Telemetry',
            onPressed: () => _loadData(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Megacity Selector Chips
                  _buildMegacitySelector(isDark),
                  const SizedBox(height: 14),

                  // Offline error banner if any
                  if (_errorMessage != null) _buildOfflineBanner(isDark),

                  // 2. Hero Thermal Anomaly Card
                  if (corridor != null) _buildHeroThermalCard(corridor, sevColor, isDark),
                  const SizedBox(height: 14),

                  // 3. Tropical Night Alert Banner
                  if (corridor != null) _buildTropicalNightBanner(corridor.surfaceTelemetry, isDark),
                  const SizedBox(height: 14),

                  // 4. Biophysical Canopy HUD
                  if (corridor != null)
                    _buildBiophysicalCanopyCard(corridor.biophysicalMetrics, isDark),
                  const SizedBox(height: 14),

                  // 5. Interactive Cool Roof Simulator
                  if (corridor != null)
                    _buildCoolRoofSimulator(corridor.coolRoofSimulation, isDark),
                  const SizedBox(height: 14),

                  // 6. Microclimate Hotspots Card
                  if (corridor != null && corridor.hotspots.isNotEmpty)
                    _buildHotspotsCard(corridor.hotspots, isDark),
                  const SizedBox(height: 14),

                  // 7. Municipal Heat Directives Card
                  if (corridor != null)
                    _buildMunicipalDirectivesCard(corridor.directives, isDark),
                  const SizedBox(height: 14),

                  // 8. Multilingual Vernacular Bulletin Card
                  if (corridor != null)
                    _buildVernacularBulletinCard(corridor.vernacularBulletins, isDark),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildMegacitySelector(bool isDark) {
    final corridors = _data?.allCorridors ?? [];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: corridors.map((c) {
          final isSelected = c.corridorId == _selectedCorridorId;
          final color = _getSeverityColor(c.threatLevel);
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
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    c.cityName,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12.5,
                      color: isSelected
                          ? (isDark ? Colors.white : Colors.black87)
                          : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+${c.uhiThermalAnomalyDeltaC.toStringAsFixed(1)}°C',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
              selectedColor: color.withValues(alpha: 0.18),
              backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              side: BorderSide(
                color: isSelected ? color : Colors.transparent,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onSelected: (_) => _loadData(corridorId: c.corridorId),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOfflineBanner(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF59E0B)),
      ),
      child: Row(
        children: const [
          Icon(Icons.wifi_off_rounded, color: Color(0xFFB45309), size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Operating on calibrated offline mesonet baseline cache.',
              style: TextStyle(color: Color(0xFF92400E), fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroThermalCard(
      UrbanHeatIslandCorridorModel corridor, Color sevColor, bool isDark) {
    final t = corridor.surfaceTelemetry;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: sevColor.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: sevColor.withValues(alpha: 0.08),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: sevColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: sevColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_fire_department_rounded, color: sevColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      _formatThreatTitle(corridor.threatLevel),
                      style: TextStyle(
                        color: sevColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                corridor.climateZone,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            corridor.cityName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          Text(
            'State: ${corridor.state} · Lat: ${corridor.latitude.toStringAsFixed(2)}°, Lon: ${corridor.longitude.toStringAsFixed(2)}°',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: sevColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UHI THERMAL ANOMALY',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: sevColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+${t.uhiThermalAnomalyDeltaC.toStringAsFixed(1)}°C',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: sevColor,
                        ),
                      ),
                      Text(
                        'Above rural baseline',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    _buildTempRow(
                      'Urban LST Surface',
                      '${t.lstUrbanCelsius.toStringAsFixed(1)}°C',
                      const Color(0xFFEF4444),
                      isDark,
                    ),
                    const SizedBox(height: 6),
                    _buildTempRow(
                      'Rural Baseline LST',
                      '${t.lstRuralBaselineCelsius.toStringAsFixed(1)}°C',
                      const Color(0xFF10B981),
                      isDark,
                    ),
                    const SizedBox(height: 6),
                    _buildTempRow(
                      'Canopy Air Temp (2m)',
                      '${t.canopyAirTempCelsius.toStringAsFixed(1)}°C',
                      const Color(0xFFF59E0B),
                      isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTempRow(String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTropicalNightBanner(SurfaceThermalTelemetryModel t, bool isDark) {
    final isTropical = t.tropicalNightFlag;
    final isSevere = t.severeTropicalNightFlag;

    final bgColor = isSevere
        ? const Color(0xFFEF4444)
        : (isTropical ? const Color(0xFFF59E0B) : const Color(0xFF10B981));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bgColor.withValues(alpha: 0.4), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isTropical ? Icons.nights_stay_rounded : Icons.bedtime_rounded,
            color: bgColor,
            size: 24,
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
                      isSevere
                          ? 'Severe Tropical Night Warning'
                          : (isTropical ? 'Tropical Night Heat Alert' : 'Normal Nocturnal Recovery'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: bgColor,
                      ),
                    ),
                    Text(
                      'T_min: ${t.tropicalNightMinTempCelsius.toStringAsFixed(1)}°C',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: bgColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isTropical
                      ? 'Nighttime temperature remains >= 25°C, preventing human core physiological heat dissipation and drastically multiplying cardiovascular stress and nocturnal heat stroke risk.'
                      : 'Nocturnal minimum below 25°C allows physiological cooling and recovery.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiophysicalCanopyCard(BiophysicalCanopyMetricsModel bio, bool isDark) {
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
              const Icon(Icons.nature_people_rounded, color: Color(0xFF10B981), size: 18),
              const SizedBox(width: 8),
              Text(
                'Biophysical Urban Canopy Dynamics',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Impervious fraction bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Impervious Surface Fraction (ISF)',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              Text(
                '${bio.imperviousSurfaceFractionPct.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: bio.imperviousSurfaceFractionPct / 100.0,
              minHeight: 8,
              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFEF4444)),
            ),
          ),
          const SizedBox(height: 14),

          // 3-grid biophysical metrics
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  'Vegetation Loss Deficit',
                  '+${bio.vegetationCoolingDeficitDeltaC.toStringAsFixed(1)}°C',
                  'NDVI ${bio.ndviUrbanCore.toStringAsFixed(2)} vs ${bio.ndviRuralBaseline.toStringAsFixed(2)}',
                  const Color(0xFFF59E0B),
                  isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  'Anthropogenic Heat Flux (Q_F)',
                  '${bio.anthropogenicHeatFluxWM2.toStringAsFixed(0)} W/m²',
                  'Vehicles & AC exhaust',
                  const Color(0xFFEC4899),
                  isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  'Sky View Factor (SVF)',
                  bio.skyViewFactorSvf.toStringAsFixed(2),
                  'Canyon sky exposure',
                  const Color(0xFF38BDF8),
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(
      String label, String value, String subtitle, Color color, bool isDark) {
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
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 9.5,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCoolRoofSimulator(CoolRoofSimulationModel sim, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF0284C7).withValues(alpha: 0.35),
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
                children: const [
                  Icon(Icons.roofing_rounded, color: Color(0xFF0284C7), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Interactive Cool Roof Simulator',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: sim.ndmaCoolRoofCompliant
                      ? const Color(0xFF10B981).withValues(alpha: 0.15)
                      : const Color(0xFFEF4444).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: sim.ndmaCoolRoofCompliant
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ),
                child: Text(
                  sim.ndmaCoolRoofCompliant ? 'NDMA SRI>=78 PASS' : 'NON-COMPLIANT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: sim.ndmaCoolRoofCompliant
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Select roofing material to calculate thermal mitigation:',
            style: TextStyle(
              fontSize: 11.5,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),

          // Dropdown for materials
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedRoofType,
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                items: _roofOptions.map((opt) {
                  return DropdownMenuItem<String>(
                    value: opt['key']!,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          opt['label']!,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          opt['desc']!,
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    _loadData(roofType: val);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Results grid
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Peak Roof Surface',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF0284C7)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${sim.surfaceTemperatureCelsius.toStringAsFixed(1)}°C',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0284C7)),
                      ),
                      Text(
                        'Drop: ${sim.surfaceTempReductionDeltaC > 0 ? "-${sim.surfaceTempReductionDeltaC.toStringAsFixed(1)}°C" : "None"}',
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF10B981)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Indoor Air Relief',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF10B981)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${sim.indoorCoolingBenefitDeltaC.toStringAsFixed(1)}°C',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF10B981)),
                      ),
                      const Text(
                        'Thermal comfort benefit',
                        style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AC Power Savings',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF8B5CF6)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sim.acEnergyLoadReductionPct > 0
                            ? '${sim.acEnergyLoadReductionPct.toStringAsFixed(1)}%'
                            : '0%',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF8B5CF6)),
                      ),
                      Text(
                        'SRI Index: ${sim.solarReflectanceIndexSri}',
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF8B5CF6)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHotspotsCard(List<MicroclimateHotspotModel> hotspots, bool isDark) {
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
            children: const [
              Icon(Icons.location_searching_rounded, color: Color(0xFFEF4444), size: 18),
              SizedBox(width: 8),
              Text(
                'Identified Microclimate Hotspots',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...hotspots.map((h) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          h.hotspotName,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${h.morphology.replaceAll('_', ' ')} · Cool Shelter: ${h.coolingShelterDistanceM}m',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${h.lstCelsius.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                      Text(
                        '+${h.thermalAnomalyDeltaC.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFEA580C),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMunicipalDirectivesCard(
      MunicipalUhiDirectivesModel d, bool isDark) {
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
            children: const [
              Icon(Icons.shield_outlined, color: Color(0xFF059669), size: 18),
              SizedBox(width: 8),
              Text(
                'Municipal & NDMA Urban Heat Directives',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDirectiveRow(
            'Cool Roof Target',
            '${(d.coolRoofTargetSqMeters / 100000).toStringAsFixed(1)} Lakh m²',
            Icons.brush_rounded,
            isDark,
          ),
          const SizedBox(height: 8),
          _buildDirectiveRow(
            'Urban Green Buffer Corridor',
            '${d.urbanForestryCorridorKm.toStringAsFixed(1)} km',
            Icons.forest_rounded,
            isDark,
          ),
          const SizedBox(height: 8),
          _buildDirectiveRow(
            'Transit Misting Stations',
            '${d.transitMistingStationsCount} operational',
            Icons.water_drop_rounded,
            isDark,
          ),
          const SizedBox(height: 8),
          _buildDirectiveRow(
            'Afternoon Construction Ban',
            d.constructionHeatShiftEnforced ? 'ENFORCED (12:00-16:00)' : 'VOLUNTARY',
            Icons.engineering_rounded,
            isDark,
            isHighlight: d.constructionHeatShiftEnforced,
          ),
          const SizedBox(height: 8),
          _buildDirectiveRow(
            'Public Drinking Water Pyaus',
            '${d.publicPyausDrinkingWaterPoints} active points',
            Icons.local_drink_rounded,
            isDark,
          ),
          const SizedBox(height: 8),
          _buildDirectiveRow(
            'Civic Cooling Centers',
            '${d.emergencyCoolingSheltersActive} shelters open',
            Icons.meeting_room_rounded,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildDirectiveRow(String label, String value, IconData icon, bool isDark,
      {bool isHighlight = false}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isHighlight
              ? const Color(0xFFEF4444)
              : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isHighlight
                ? const Color(0xFFEF4444)
                : (isDark ? Colors.white : const Color(0xFF0F172A)),
          ),
        ),
      ],
    );
  }

  Widget _buildVernacularBulletinCard(
      Map<String, String> bulletins, bool isDark) {
    final currentBulletin = bulletins[_selectedLanguage] ??
        bulletins['en'] ??
        'Urban heat advisory in effect.';

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
                children: const [
                  Icon(Icons.record_voice_over_rounded, color: Color(0xFF38BDF8), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Regional Vernacular Bulletin',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLanguage,
                  dropdownColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                  items: _languageNames.entries.map((e) {
                    return DropdownMenuItem<String>(
                      value: e.key,
                      child: Text(
                        e.value,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedLanguage = val);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
              currentBulletin,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
