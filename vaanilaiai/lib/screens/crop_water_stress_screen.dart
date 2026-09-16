import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/crop_water_stress_model.dart';
import '../services/api_service.dart';

class CropWaterStressScreen extends StatefulWidget {
  final CropWaterStressResponseModel? initialData;
  final ApiService? apiService;

  const CropWaterStressScreen({
    super.key,
    this.initialData,
    this.apiService,
  });

  @override
  State<CropWaterStressScreen> createState() => _CropWaterStressScreenState();
}

class _CropWaterStressScreenState extends State<CropWaterStressScreen> {
  late ApiService _apiService;
  CropWaterStressResponseModel? _data;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedZoneId = 'vidarbha_cotton_vertisol';
  String _selectedLangCode = 'en';

  final List<Map<String, String>> _zones = [
    {'id': 'vidarbha_cotton_vertisol', 'name': 'Vidarbha Cotton (MH)'},
    {'id': 'punjab_wheat_rice_alluvium', 'name': 'Punjab Wheat (PB)'},
    {'id': 'telangana_red_soil_maize', 'name': 'Telangana Maize (TG)'},
    {'id': 'saurashtra_groundnut_belt', 'name': 'Saurashtra Groundnut (GJ)'},
    {'id': 'cauvery_delta_paddy_wetland', 'name': 'Cauvery Delta Samba (TN)'},
    {'id': 'bundelkhand_pulses_semiarid', 'name': 'Bundelkhand Pulses (UP/MP)'},
    {'id': 'assam_brahmaputra_tea_valley', 'name': 'Assam Tea Valley (AS)'},
  ];

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'label': 'English'},
    {'code': 'hi', 'label': 'हिंदी'},
    {'code': 'mr', 'label': 'मराठी'},
    {'code': 'pa', 'label': 'ਪੰਜਾਬੀ'},
    {'code': 'te', 'label': 'తెలుగు'},
    {'code': 'gu', 'label': 'ગુજરાતી'},
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
      _fetchCropWaterStressData();
    }
  }

  Future<void> _fetchCropWaterStressData({String? zoneId}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _apiService.getCropWaterStressAssessment(
        zoneId: zoneId ?? _selectedZoneId,
      );
      setState(() {
        _data = res;
        _selectedZoneId = res.selectedZone.zoneId;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load crop water stress analytics: $e';
        _isLoading = false;
      });
    }
  }

  Color _getStressTierColor(String tier) {
    switch (tier.toUpperCase()) {
      case 'SEVERE_DROUGHT_STRESS':
        return const Color(0xFFDC2626); // Crimson Red
      case 'MODERATE_DEFICIT':
        return const Color(0xFFEA580C); // Safety Orange
      case 'MILD_STRESS':
        return const Color(0xFFEAB308); // Amber
      case 'OPTIMAL_TURGOR':
      default:
        return const Color(0xFF10B981); // Emerald Green
    }
  }

  String _formatStressTierLabel(String tier) {
    switch (tier.toUpperCase()) {
      case 'SEVERE_DROUGHT_STRESS':
        return 'SEVERE DROUGHT STRESS (CWSI > 0.7)';
      case 'MODERATE_DEFICIT':
        return 'MODERATE WATER DEFICIT (CWSI 0.4-0.7)';
      case 'MILD_STRESS':
        return 'MILD WATER STRESS (CWSI 0.2-0.4)';
      case 'OPTIMAL_TURGOR':
      default:
        return 'OPTIMAL TURGOR (CWSI < 0.2)';
    }
  }

  String _formatSoilTexture(String texture) {
    return texture.replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090E14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111823),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.grass_rounded, color: Color(0xFF10B981), size: 22),
                SizedBox(width: 8),
                Text(
                  'Crop Water Stress (CWSI)',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Text(
              'ICAR-CRIDA & IMD Soil Moisture Intelligence',
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
            tooltip: 'Refresh analytics',
            onPressed: () => _fetchCropWaterStressData(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitCubeGrid(
                    color: Color(0xFF10B981),
                    size: 44,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Simulating multi-depth soil moisture & FAO-56 Penman ET0...',
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
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _fetchCropWaterStressData(),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Retry Analysis'),
                        ),
                      ],
                    ),
                  ),
                )
              : _data == null
                  ? const SizedBox.shrink()
                  : RefreshIndicator(
                      color: const Color(0xFF10B981),
                      backgroundColor: const Color(0xFF111823),
                      onRefresh: () => _fetchCropWaterStressData(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_data!.isOfflineCached) _buildOfflineBanner(),
                            _buildZoneSelector(),
                            const SizedBox(height: 12),
                            _buildHeroCard(_data!.selectedZone),
                            const SizedBox(height: 14),
                            _buildSoilMoistureHudCard(_data!.selectedZone.soilMoisture),
                            const SizedBox(height: 14),
                            _buildEvapotranspirationCard(_data!.selectedZone.evapotranspiration),
                            const SizedBox(height: 14),
                            _buildPrecisionIrrigationCard(_data!.selectedZone.irrigationDirectives),
                            const SizedBox(height: 14),
                            _buildVernacularBulletinCard(_data!.selectedZone),
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
              'Offline Cached Advisory: Displaying calibrated baseline agronomic water directives.',
              style: TextStyle(color: Color(0xFFFCD34D), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'AGRO-CLIMATIC CROP CORRIDORS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            Text(
              '${_zones.length} Cropping Basins',
              style: TextStyle(
                fontSize: 11,
                color: const Color(0xFF10B981).withValues(alpha: 0.9),
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
            itemCount: _zones.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final zone = _zones[index];
              final isSelected = zone['id'] == _selectedZoneId;
              return ChoiceChip(
                label: Text(
                  zone['name']!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                ),
                selected: isSelected,
                selectedColor: const Color(0xFF059669),
                backgroundColor: const Color(0xFF131D2A),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF34D399) : const Color(0xFF1E293B),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onSelected: (selected) {
                  if (selected && zone['id'] != _selectedZoneId) {
                    _fetchCropWaterStressData(zoneId: zone['id']);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(AgroClimaticZoneModel zone) {
    final tierColor = _getStressTierColor(zone.stressTier);
    final isCritical = zone.stressTier == 'SEVERE_DROUGHT_STRESS' || zone.stressTier == 'MODERATE_DEFICIT';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tierColor.withValues(alpha: 0.22),
            const Color(0xFF111823),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tierColor.withValues(alpha: isCritical ? 0.8 : 0.4),
          width: isCritical ? 1.8 : 1.2,
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
                    Icon(Icons.energy_savings_leaf_outlined, size: 14, color: tierColor),
                    const SizedBox(width: 5),
                    Text(
                      _formatStressTierLabel(zone.stressTier),
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
                '${zone.district}, ${zone.state}',
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
            zone.zoneName,
            style: const TextStyle(
              fontSize: 18.5,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Primary Crop: ${zone.primaryCrop} • Stage: ${zone.growthStage}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B111A).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CROP WATER STRESS (CWSI)',
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
                            zone.evapotranspiration.cropWaterStressIndexCwsi.toStringAsFixed(2),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: tierColor,
                            ),
                          ),
                          const Text(
                            ' / 1.0',
                            style: TextStyle(
                              fontSize: 13,
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
                    color: const Color(0xFF0B111A).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CANOPY DEPARTURE (Tc - Ta)',
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
                            '${zone.evapotranspiration.canopyAirTempDepartureC >= 0 ? '+' : ''}${zone.evapotranspiration.canopyAirTempDepartureC.toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: zone.evapotranspiration.canopyAirTempDepartureC > 0
                                  ? const Color(0xFFF97316)
                                  : const Color(0xFF10B981),
                            ),
                          ),
                          const Text(
                            ' °C',
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
                    const Icon(Icons.terrain, size: 14, color: Color(0xFF10B981)),
                    const SizedBox(width: 6),
                    Text(
                      'Soil Texture: ${_formatSoilTexture(zone.soilTexture)}',
                      style: const TextStyle(fontSize: 11.5, color: Colors.white70),
                    ),
                  ],
                ),
                Text(
                  'RASM: ${zone.soilMoisture.relativeAvailableSoilMoisturePct.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF38BDF8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoilMoistureHudCard(SoilMoistureProfileModel moisture) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111823),
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
                  Icon(Icons.layers, color: Color(0xFF38BDF8), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'VOLUMETRIC SOIL MOISTURE PROFILE',
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
                'FC: ${moisture.fieldCapacityPct.toStringAsFixed(0)}% | PWP: ${moisture.wiltingPointPct.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 10.5,
                  color: Colors.white.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildMoistureDepthBar(
            'Topsoil (0-10 cm)',
            moisture.topsoil10cmPct,
            moisture.fieldCapacityPct,
            moisture.wiltingPointPct,
            const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 10),
          _buildMoistureDepthBar(
            'Root-Zone (10-40 cm)',
            moisture.rootZone40cmPct,
            moisture.fieldCapacityPct,
            moisture.wiltingPointPct,
            const Color(0xFF10B981),
          ),
          const SizedBox(height: 10),
          _buildMoistureDepthBar(
            'Subsoil Storage (40-100 cm)',
            moisture.subsoil100cmPct,
            moisture.fieldCapacityPct,
            moisture.wiltingPointPct,
            const Color(0xFF0EA5E9),
          ),
        ],
      ),
    );
  }

  Widget _buildMoistureDepthBar(
    String depthLabel,
    double valuePct,
    double fcPct,
    double pwpPct,
    Color barColor,
  ) {
    final progress = (valuePct / 50.0).clamp(0.0, 1.0);
    final isBelowWilting = valuePct <= pwpPct;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF151F2E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                depthLabel,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              Row(
                children: [
                  Text(
                    '${valuePct.toStringAsFixed(1)}% VWC',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isBelowWilting ? const Color(0xFFEF4444) : barColor,
                    ),
                  ),
                  if (isBelowWilting)
                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Text(
                        '(BELOW WILTING)',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFF1E293B),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvapotranspirationCard(EvapotranspirationMetricsModel et) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111823),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.wb_sunny_outlined, color: Color(0xFFF59E0B), size: 18),
              SizedBox(width: 8),
              Text(
                'FAO-56 EVAPOTRANSPIRATION & CANOPY THERMAL',
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
                'Reference ET0',
                '${et.referenceEt0MmDay.toStringAsFixed(1)} mm/day',
                'Penman-Monteith potential',
                Icons.water_drop_outlined,
                const Color(0xFF38BDF8),
              ),
              const SizedBox(width: 10),
              _buildMetricTile(
                'Crop Evapo (ETc)',
                '${et.actualEtcMmDay.toStringAsFixed(1)} mm/day',
                'Kc factor: ${et.cropCoefficientKc.toStringAsFixed(2)}',
                Icons.grain,
                const Color(0xFF10B981),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildMetricTile(
                'Canopy Radiometric',
                '${et.canopyTemperatureC.toStringAsFixed(1)}°C',
                'Thermal infrared sensor',
                Icons.thermostat,
                const Color(0xFFF97316),
              ),
              const SizedBox(width: 10),
              _buildMetricTile(
                'Ambient Dry-Bulb',
                '${et.ambientAirTemperatureC.toStringAsFixed(1)}°C',
                'Surface air temp',
                Icons.air,
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
          color: const Color(0xFF151F2E),
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

  Widget _buildPrecisionIrrigationCard(PrecisionIrrigationDirectiveModel directives) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111823),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.water_drop, color: Color(0xFF10B981), size: 18),
              SizedBox(width: 8),
              Text(
                'PRECISION IRRIGATION & AGRONOMIC DIRECTIVES',
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
            Icons.speed,
            'Supplemental Irrigation Depth',
            directives.recommendedIrrigationDepthMm > 0
                ? '${directives.recommendedIrrigationDepthMm.toStringAsFixed(0)} mm Net'
                : 'NO IRRIGATION NEEDED',
            directives.dripRunTimeHours > 0
                ? 'Drip / Sprinkler Run Time: ${directives.dripRunTimeHours.toStringAsFixed(1)} hours'
                : 'Adequate soil moisture reserve in root-zone',
            directives.recommendedIrrigationDepthMm > 0 ? const Color(0xFF38BDF8) : const Color(0xFF10B981),
          ),
          const Divider(color: Color(0xFF1E293B), height: 16),
          _buildDirectiveRow(
            Icons.warning_amber_rounded,
            'Critical Growth Stage',
            directives.criticalGrowthStage,
            'Phenological moisture vulnerability window',
            const Color(0xFFF59E0B),
          ),
          const Divider(color: Color(0xFF1E293B), height: 16),
          _buildDirectiveRow(
            Icons.science_outlined,
            'Anti-Transpirant Foliar Spray',
            directives.antiTranspirantSpray,
            'Reduces stomatal conductance without inhibiting photosynthesis',
            const Color(0xFFA78BFA),
          ),
          const Divider(color: Color(0xFF1E293B), height: 16),
          _buildDirectiveRow(
            Icons.eco_outlined,
            'In-Situ Mulch Recommendation',
            directives.mulchRecommendation,
            'Suppresses soil capillary evaporation and moderates root temperature',
            const Color(0xFF34D399),
          ),
          const Divider(color: Color(0xFF1E293B), height: 16),
          _buildDirectiveRow(
            Icons.agriculture,
            'Intercultivation & Tillage',
            directives.intercultivationTillage,
            'Weed competition elimination and surface crust breakage',
            const Color(0xFFE2E8F0),
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
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

  Widget _buildVernacularBulletinCard(AgroClimaticZoneModel zone) {
    final activeText = zone.localizedBulletins[_selectedLangCode] ??
        zone.localizedBulletins['en'] ??
        'Official Crop Water Stress Advisory Active.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111823),
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
                  Icon(Icons.g_translate, color: Color(0xFF10B981), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'LOCALIZED AGRONOMIC BULLETIN',
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
                'ICAR-CRIDA / IMD',
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
                  selectedColor: const Color(0xFF059669),
                  backgroundColor: const Color(0xFF131D2A),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF34D399) : const Color(0xFF1E293B),
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
              color: const Color(0xFF0B1017),
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

  Widget _buildProvenanceFooter(CropWaterStressResponseModel data) {
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
              const Icon(Icons.verified, size: 14, color: Color(0xFF10B981)),
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
