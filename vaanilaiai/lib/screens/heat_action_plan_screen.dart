import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/heat_action_plan_model.dart';
import '../services/api_service.dart';

class HeatActionPlanScreen extends StatefulWidget {
  final HeatActionPlanResponseModel? initialData;
  final ApiService? apiService;

  const HeatActionPlanScreen({
    super.key,
    this.initialData,
    this.apiService,
  });

  @override
  State<HeatActionPlanScreen> createState() => _HeatActionPlanScreenState();
}

class _HeatActionPlanScreenState extends State<HeatActionPlanScreen> {
  late ApiService _apiService;
  HeatActionPlanResponseModel? _data;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedZoneId = 'phalodi_churu_thar';
  String _selectedLangCode = 'en';

  final List<Map<String, String>> _zones = [
    {'id': 'phalodi_churu_thar', 'name': 'Phalodi (RJ)'},
    {'id': 'ahmedabad_metropolitan', 'name': 'Ahmedabad AMC (GJ)'},
    {'id': 'titlagarh_jharsuguda_belt', 'name': 'Titlagarh (OR)'},
    {'id': 'nagpur_chandrapur_vidarbha', 'name': 'Vidarbha (MH)'},
    {'id': 'ramagundam_hyderabad_deccan', 'name': 'Ramagundam (TG)'},
    {'id': 'delhi_ncr_urban_heat_island', 'name': 'Delhi-NCR (DL)'},
    {'id': 'banda_prayagraj_bundelkhand', 'name': 'Bundelkhand (UP)'},
  ];

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'label': 'English'},
    {'code': 'hi', 'label': 'हिंदी'},
    {'code': 'gu', 'label': 'ગુજરાતી'},
    {'code': 'te', 'label': 'తెలుగు'},
    {'code': 'or', 'label': 'ଓଡ଼ିଆ'},
  ];

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    if (widget.initialData != null) {
      _data = widget.initialData;
      _selectedZoneId = widget.initialData!.selectedZone.zoneId;
    } else {
      _fetchHeatActionPlanData();
    }
  }

  Future<void> _fetchHeatActionPlanData({String? zoneId}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _apiService.getHeatActionPlanAssessment(
        zoneId: zoneId ?? _selectedZoneId,
      );
      setState(() {
        _data = res;
        _selectedZoneId = res.selectedZone.zoneId;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load heat action plan analytics: $e';
        _isLoading = false;
      });
    }
  }

  Color _getTierColor(String tier) {
    switch (tier.toUpperCase()) {
      case 'EXTREME_HEAT_RED':
        return const Color(0xFFDC2626); // Red Alert
      case 'SEVERE_HEAT_ALERT_ORANGE':
        return const Color(0xFFEA580C); // Orange Alert
      case 'HEAT_ALERT_YELLOW':
        return const Color(0xFFEAB308); // Yellow Watch
      case 'NORMAL_GREEN':
      default:
        return const Color(0xFF10B981); // Green Normal
    }
  }

  String _formatTierLabel(String tier) {
    switch (tier.toUpperCase()) {
      case 'EXTREME_HEAT_RED':
        return 'RED ALERT: EXTREME HEATWAVE';
      case 'SEVERE_HEAT_ALERT_ORANGE':
        return 'ORANGE ALERT: SEVERE HEAT';
      case 'HEAT_ALERT_YELLOW':
        return 'YELLOW ALERT: HEATWAVE WATCH';
      case 'NORMAL_GREEN':
      default:
        return 'NORMAL COMFORT (GREEN)';
    }
  }

  Color _getUvColor(String uvCat) {
    switch (uvCat.toUpperCase()) {
      case 'EXTREME':
        return const Color(0xFF9333EA); // Purple
      case 'VERY_HIGH':
        return const Color(0xFFDC2626); // Red
      case 'HIGH':
        return const Color(0xFFEA580C); // Orange
      case 'MODERATE':
        return const Color(0xFFEAB308); // Amber
      case 'LOW':
      default:
        return const Color(0xFF10B981); // Emerald
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101726),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.sunny, color: Color(0xFFF97316), size: 20),
                SizedBox(width: 8),
                Text(
                  'Heat Action Plan (HAP)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Text(
              'NDMA & IMD Solar UV & Thermal Protection',
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
            onPressed: () => _fetchHeatActionPlanData(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitRing(
                    color: Color(0xFFF97316),
                    size: 48,
                    lineWidth: 4,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Synthesizing NDMA municipal heat thresholds & UV indices...',
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
                            backgroundColor: const Color(0xFFF97316),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _fetchHeatActionPlanData(),
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
                      color: const Color(0xFFF97316),
                      backgroundColor: const Color(0xFF101726),
                      onRefresh: () => _fetchHeatActionPlanData(),
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
                            _buildThermalMetricsGrid(_data!.selectedZone.thermalMetrics),
                            const SizedBox(height: 14),
                            _buildSolarUvHudCard(_data!.selectedZone.uvMetrics),
                            const SizedBox(height: 14),
                            _buildMunicipalDirectivesCard(_data!.selectedZone.municipalDirectives),
                            const SizedBox(height: 14),
                            _buildVulnerableDemographicsCard(_data!.selectedZone.vulnerableDemographics),
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
              'Offline Cached Advisory: Displaying calibrated baseline heat action directives.',
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
              'EXTREME HEAT CORRIDORS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            Text(
              '${_zones.length} Monitored Corridors',
              style: TextStyle(
                fontSize: 11,
                color: const Color(0xFFF97316).withValues(alpha: 0.9),
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
                selectedColor: const Color(0xFFF97316),
                backgroundColor: const Color(0xFF131D31),
                side: BorderSide(
                  color: isSelected ? const Color(0xFFFB923C) : const Color(0xFF1E293B),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onSelected: (selected) {
                  if (selected && zone['id'] != _selectedZoneId) {
                    _fetchHeatActionPlanData(zoneId: zone['id']);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(HeatActionHotspotZoneModel zone) {
    final tierColor = _getTierColor(zone.alertTier);
    final isExtreme = zone.alertTier == 'EXTREME_HEAT_RED';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tierColor.withValues(alpha: 0.22),
            const Color(0xFF111827),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tierColor.withValues(alpha: isExtreme ? 0.8 : 0.4),
          width: isExtreme ? 1.8 : 1.2,
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
                    Icon(Icons.warning_amber_rounded, size: 14, color: tierColor),
                    const SizedBox(width: 5),
                    Text(
                      _formatTierLabel(zone.alertTier),
                      style: TextStyle(
                        color: tierColor,
                        fontSize: 11,
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
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MAXIMUM TEMP',
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
                            zone.thermalMetrics.maxTempC.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: tierColor,
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
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NORMAL DEPARTURE',
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
                            '${zone.thermalMetrics.departureC >= 0 ? '+' : ''}${zone.thermalMetrics.departureC.toStringAsFixed(1)}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFB923C),
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
                    const Icon(Icons.timer_outlined, size: 14, color: Color(0xFFF97316)),
                    const SizedBox(width: 6),
                    Text(
                      'Consecutive Heatwave Days: ${zone.thermalMetrics.consecutiveHeatwaveDays} days',
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
                Text(
                  'Normal: ${zone.thermalMetrics.normalTempC.toStringAsFixed(1)}°C',
                  style: TextStyle(
                    fontSize: 12,
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

  Widget _buildThermalMetricsGrid(HeatwaveThermalMetricsModel thermal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF101726),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F293D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.thermostat, color: Color(0xFFF97316), size: 18),
              SizedBox(width: 8),
              Text(
                'THERMAL STRESS & BIOCLIMATOLOGY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
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
                'Wet-Bulb Temp',
                '${thermal.wetBulbTempC.toStringAsFixed(1)}°C',
                'Stull survival index',
                Icons.water_drop,
                const Color(0xFF38BDF8),
              ),
              const SizedBox(width: 10),
              _buildMetricTile(
                'Midday Humidity',
                '${thermal.relativeHumidityPct.toStringAsFixed(0)}%',
                'Ambient vapor load',
                Icons.waves,
                const Color(0xFF818CF8),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildMetricTile(
                'Night Minimum',
                '${thermal.nightMinTempC.toStringAsFixed(1)}°C',
                'Nocturnal heat load',
                Icons.nightlight_round,
                const Color(0xFFFBBF24),
              ),
              const SizedBox(width: 10),
              _buildMetricTile(
                'Climatological Base',
                '${thermal.normalTempC.toStringAsFixed(1)}°C',
                'Historical normal',
                Icons.calendar_month,
                const Color(0xFF34D399),
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
          color: const Color(0xFF151E33),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1F293D)),
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtext,
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

  Widget _buildSolarUvHudCard(SolarUvRadiationMetricsModel uv) {
    final uvColor = _getUvColor(uv.uvCategory);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF101726),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F293D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.wb_sunny_outlined, color: Color(0xFFFBBF24), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'SOLAR UV RADIATION HUD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: uvColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: uvColor),
                ),
                child: Text(
                  '${uv.uvCategory} HAZARD',
                  style: TextStyle(
                    color: uvColor,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: uvColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: uvColor.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    Text(
                      'UVI',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      uv.uvIndex.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: uvColor,
                      ),
                    ),
                    Text(
                      'Solar Noon',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUvDetailRow(
                      Icons.schedule,
                      'Peak UV Window',
                      uv.peakUvHour,
                      const Color(0xFFF97316),
                    ),
                    const SizedBox(height: 6),
                    _buildUvDetailRow(
                      Icons.timer,
                      'Time to Sunburn',
                      '${uv.timeToSunburnMinutes} minutes (unprotected)',
                      const Color(0xFFEF4444),
                    ),
                    const SizedBox(height: 6),
                    _buildUvDetailRow(
                      Icons.shield,
                      'Dermatological SPF',
                      'SPF ${uv.recommendedSpf}+ Broad-Spectrum',
                      const Color(0xFF38BDF8),
                    ),
                    const SizedBox(height: 6),
                    _buildUvDetailRow(
                      Icons.cloud_circle,
                      'Total Ozone Column',
                      '${uv.ozoneColumnDu.toStringAsFixed(1)} Dobson Units (DU)',
                      const Color(0xFFA78BFA),
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

  Widget _buildUvDetailRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMunicipalDirectivesCard(MunicipalHeatDirectivesModel directives) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF101726),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F293D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_city, color: Color(0xFF38BDF8), size: 18),
              SizedBox(width: 8),
              Text(
                'MUNICIPAL RESILIENCE & WORKER SAFETY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildDirectiveRow(
            Icons.roofing,
            'Cool Roof Initiative',
            directives.coolRoofInitiativeActive ? 'ACTIVE' : 'STANDBY',
            'Mean Solar Reflectance Index: ${directives.solarReflectanceIndexSri.toStringAsFixed(1)} SRI',
            directives.coolRoofInitiativeActive ? const Color(0xFF10B981) : const Color(0xFF6B7280),
          ),
          const Divider(color: Color(0xFF1E293B), height: 16),
          _buildDirectiveRow(
            Icons.front_hand,
            'BOCW Labor Suspension',
            directives.bocwLaborWorkSuspensionHours,
            'Mandatory construction labor shutdown window',
            const Color(0xFFEF4444),
          ),
          const Divider(color: Color(0xFF1E293B), height: 16),
          _buildDirectiveRow(
            Icons.water_drop,
            'Municipal Pyau Water Stations',
            '${directives.activePyauWaterStations} active kiosks',
            'Free clean drinking water stations across transport nodes',
            const Color(0xFF0EA5E9),
          ),
          const Divider(color: Color(0xFF1E293B), height: 16),
          _buildDirectiveRow(
            Icons.local_hospital,
            'Hospital Heatstroke Beds',
            '${directives.hospitalHeatstrokeBeds} Dedicated beds',
            directives.emergencyCoolingIceBathReady
                ? 'Rapid whole-body ice immersion cooling units READY'
                : 'Standard cooling protocols active',
            const Color(0xFFEC4899),
          ),
          const Divider(color: Color(0xFF1E293B), height: 16),
          _buildDirectiveRow(
            Icons.medication,
            'Public ORS Booths',
            '${directives.orsDistributionBooths} distribution points',
            'Oral Rehydration Salt solutions for bus stands & bazaars',
            const Color(0xFFF59E0B),
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
                  Text(
                    primaryText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ],
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

  Widget _buildVulnerableDemographicsCard(List<String> demographics) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF101726),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F293D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.people_outline, color: Color(0xFFF97316), size: 18),
              SizedBox(width: 8),
              Text(
                'HIGH-RISK VULNERABLE DEMOGRAPHICS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: demographics.map((demo) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.circle, size: 6, color: Color(0xFFF97316)),
                    const SizedBox(width: 6),
                    Text(
                      demo,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
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

  Widget _buildVernacularBulletinCard(HeatActionHotspotZoneModel zone) {
    final activeText = zone.localizedBulletins[_selectedLangCode] ??
        zone.localizedBulletins['en'] ??
        'Official Heat Action Advisory Active.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF101726),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F293D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.g_translate, color: Color(0xFF38BDF8), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'LOCALIZED PUBLIC HEALTH BULLETIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Text(
                'NDMA / SDMA',
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
                  selectedColor: const Color(0xFF2563EB),
                  backgroundColor: const Color(0xFF151E33),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF60A5FA) : const Color(0xFF1E293B),
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
              color: const Color(0xFF0F172A),
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

  Widget _buildProvenanceFooter(HeatActionPlanResponseModel data) {
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
              const Icon(Icons.verified, size: 14, color: Color(0xFF38BDF8)),
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
