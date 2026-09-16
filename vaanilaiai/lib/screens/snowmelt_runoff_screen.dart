import 'package:flutter/material.dart';
import '../models/snowmelt_runoff_model.dart';
import '../services/api_service.dart';

class SnowmeltRunoffScreen extends StatefulWidget {
  final SnowmeltRunoffResponseModel? initialData;

  const SnowmeltRunoffScreen({super.key, this.initialData});

  @override
  State<SnowmeltRunoffScreen> createState() => _SnowmeltRunoffScreenState();
}

class _SnowmeltRunoffScreenState extends State<SnowmeltRunoffScreen> {
  final ApiService _apiService = ApiService();
  SnowmeltRunoffResponseModel? _data;
  bool _isLoading = false;
  String _selectedBasinId = 'satluj_bhakra';
  String _selectedLanguage = 'en';

  static const Map<String, String> _languageNames = {
    'en': 'English',
    'hi': 'हिन्दी (HI)',
    'pa': 'ਪੰਜਾਬੀ (PA)',
    'ne': 'नेपाली (NE)',
    'ks': 'کٲشُر (KS)',
    'bn': 'বাংলা (BN)',
    'bo': 'བོད་ཡིག (BO)',
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _data = widget.initialData;
      _selectedBasinId = widget.initialData!.basinId;
    } else {
      _loadData();
    }
  }

  Future<void> _loadData({String? basinId}) async {
    setState(() => _isLoading = true);
    final targetBasin = basinId ?? _selectedBasinId;
    final assessment =
        await _apiService.getSnowmeltRunoffAssessment(basinId: targetBasin);
    if (mounted) {
      setState(() {
        _data = assessment;
        _selectedBasinId = targetBasin;
        _isLoading = false;
      });
    }
  }

  Color _getRegimeColor(String regime) {
    switch (regime.toUpperCase()) {
      case 'SEASONAL_SNOWMELT_SURGE':
        return const Color(0xFF0284C7); // Sky Blue
      case 'GLACIAL_ABLATION_PEAK':
        return const Color(0xFF06B6D4); // Cyan Glacier
      case 'RAIN_ON_SNOW_BURST':
        return const Color(0xFFE11D48); // Rose / Magenta alert
      case 'TRANSITIONAL_FREEZE_THAW':
        return const Color(0xFF8B5CF6); // Purple freeze-thaw
      case 'BASEFLOW_DOMINATED':
      default:
        return const Color(0xFF10B981); // Emerald baseflow
    }
  }

  String _formatRegimeLabel(String regime) {
    switch (regime.toUpperCase()) {
      case 'SEASONAL_SNOWMELT_SURGE':
        return 'SEASONAL SNOWMELT SURGE';
      case 'GLACIAL_ABLATION_PEAK':
        return 'GLACIAL ABLATION PEAK';
      case 'RAIN_ON_SNOW_BURST':
        return 'RAIN-ON-SNOW BURST';
      case 'TRANSITIONAL_FREEZE_THAW':
        return 'TRANSITIONAL FREEZE-THAW';
      case 'BASEFLOW_DOMINATED':
      default:
        return 'BASEFLOW DOMINATED';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'OPTIMAL_GENERATION_SURGE':
        return const Color(0xFF059669);
      case 'SPILLWAY_DISCHARGE_WARNING':
        return const Color(0xFFDC2626);
      case 'NORMAL_STORAGE_FILL':
        return const Color(0xFF0284C7);
      case 'SEDIMENT_FLUSHING_ALERT':
        return const Color(0xFFEA580C);
      case 'LEAN_DISCHARGE_CAUTION':
      default:
        return const Color(0xFFD97706);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentBasin = _data?.currentBasin;
    final regimeColor = _getRegimeColor(
      currentBasin?.currentRegime ?? 'SEASONAL_SNOWMELT_SURGE',
    );

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0B132B) : const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Himalayan Snowmelt Runoff (SRM)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              'IMD, CWC, DGRE & ISRO Cryospheric Hydrology',
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
            tooltip: 'Refresh Snowmelt Telemetry',
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
                    'Querying Himalayan Snowmelt SRM Feeds...',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasinSelector(isDark),
                  const SizedBox(height: 14),
                  if (currentBasin != null) ...[
                    _buildHeroCatchmentCard(currentBasin, regimeColor, isDark),
                    const SizedBox(height: 14),
                    _buildCryosphereHudCard(currentBasin.cryosphereTelemetry, isDark),
                    const SizedBox(height: 14),
                    _buildHypsometricElevationMatrix(
                        currentBasin.elevationBands, isDark),
                    const SizedBox(height: 14),
                    _buildHydropowerInflowCard(
                        currentBasin.hydropowerInflows, isDark),
                    const SizedBox(height: 14),
                    _buildRiparianSafetyCard(currentBasin, isDark),
                    const SizedBox(height: 14),
                    _buildVernacularBulletinCard(currentBasin, isDark),
                  ],
                  const SizedBox(height: 16),
                  _buildInstitutionalAttribution(isDark),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildBasinSelector(bool isDark) {
    final basins = _data?.allBasins ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'HIMALAYAN SNOW & GLACIAL CATCHMENTS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color:
                    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            Text(
              '${basins.length} Monitored Basins',
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
            itemCount: basins.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final b = basins[index];
              final isSelected = b.basinId == _selectedBasinId;
              final statusColor = _getStatusColor(b.inflowStatus);

              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${b.basinName.split(' ')[0]} (${b.state.split(' ')[0]})',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? const Color(0xFFE2E8F0)
                                : const Color(0xFF334155)),
                      ),
                    ),
                  ],
                ),
                selected: isSelected,
                selectedColor: const Color(0xFF0284C7),
                backgroundColor:
                    isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                onSelected: (selected) {
                  if (selected) {
                    _loadData(basinId: b.basinId);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCatchmentCard(
    SnowmeltBasinModel basin,
    Color regimeColor,
    bool isDark,
  ) {
    final runoff = basin.runoffMetrics;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0C192E),
                  const Color(0xFF0F2B48),
                  const Color(0xFF16385C),
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
          color: regimeColor.withValues(alpha: 0.5),
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
                  color: regimeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: regimeColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.ac_unit, size: 14, color: regimeColor),
                    const SizedBox(width: 6),
                    Text(
                      _formatRegimeLabel(basin.currentRegime),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: regimeColor,
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
                      : Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Drainage: ${basin.drainageAreaSqKm.toStringAsFixed(0)} km²',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0284C7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            basin.basinName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${basin.mountainRange} · ${basin.state}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1),
            ),
          ),
          const SizedBox(height: 16),
          // Large Flow Telemetry Display
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0B132B).withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHeroMetric(
                  label: 'RIVER DISCHARGE',
                  value: runoff.dailyDischargeCumecs.toStringAsFixed(0),
                  unit: 'cumecs (m³/s)',
                  color: const Color(0xFF0284C7),
                ),
                _buildHeroDivider(isDark),
                _buildHeroMetric(
                  label: 'SNOWMELT FRACTION',
                  value: '${runoff.snowmeltFractionPct.toStringAsFixed(1)}%',
                  unit: 'Cryosphere Contribution',
                  color: const Color(0xFF06B6D4),
                ),
                _buildHeroDivider(isDark),
                _buildHeroMetric(
                  label: 'DIURNAL CREST',
                  value: runoff.peakDiurnalHourIst,
                  unit: '${runoff.peakDiurnalDischargeCumecs.toStringAsFixed(0)} cumecs max',
                  color: const Color(0xFFF59E0B),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroMetric({
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          unit,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroDivider(bool isDark) {
    return Container(
      height: 40,
      width: 1,
      color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
    );
  }

  Widget _buildCryosphereHudCard(
    SnowpackCryosphereTelemetryModel cryo,
    bool isDark,
  ) {
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
              const Icon(Icons.terrain, size: 18, color: Color(0xFF06B6D4)),
              const SizedBox(width: 8),
              Text(
                'CRYOSPHERIC SNOWPACK & ISOTHERM TELEMETRY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color:
                      isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCryoMetricBox(
                  title: 'SNOW LINE ALTITUDE (SLA)',
                  value: '${cryo.snowLineAltitudeM.toStringAsFixed(0)} m',
                  badge: 'Active Snow Base',
                  badgeColor: const Color(0xFF0284C7),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildCryoMetricBox(
                  title: 'FREEZING LEVEL (0°C)',
                  value: '${cryo.freezingLevelIsothermM.toStringAsFixed(0)} m',
                  badge: cryo.freezingLevelIsothermM > cryo.snowLineAltitudeM
                      ? 'Active Thaw Phase'
                      : 'Freezing Phase',
                  badgeColor:
                      cryo.freezingLevelIsothermM > cryo.snowLineAltitudeM
                          ? const Color(0xFFE11D48)
                          : const Color(0xFF10B981),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildCryoMetricBox(
                  title: 'EQUILIBRIUM LINE (ELA)',
                  value: '${cryo.equilibriumLineAltitudeM.toStringAsFixed(0)} m',
                  badge: 'Glacial Balance',
                  badgeColor: const Color(0xFF8B5CF6),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildCryoMetricBox(
                  title: 'SNOW WATER EQUIVALENT',
                  value: '${cryo.basinSnowWaterEquivalentMm.toStringAsFixed(0)} mm',
                  badge: 'NDSI: ${cryo.satelliteNdsiCoveragePct.toStringAsFixed(0)}%',
                  badgeColor: const Color(0xFF06B6D4),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCryoMetricBox({
    required String title,
    required String value,
    required String badge,
    required Color badgeColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
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
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHypsometricElevationMatrix(
    List<ElevationZonalBandModel> bands,
    bool isDark,
  ) {
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
              const Icon(Icons.layers_rounded,
                  size: 18, color: Color(0xFF0284C7)),
              const SizedBox(width: 8),
              Text(
                'MARTINEC-RANGO SRM HYPSOMETRIC ZONAL MATRIX',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color:
                      isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bands.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final b = bands[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          b.bandId.replaceAll('ZONE_', 'Z-'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0284C7),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b.elevationRangeLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Area: ${b.zonalAreaSqKm.toStringAsFixed(0)} km² · SCA: ${b.snowCoverAreaPct.toStringAsFixed(0)}% · Temp: ${b.meanTemperatureC >= 0 ? '+' : ''}${b.meanTemperatureC.toStringAsFixed(1)}°C · DDF: ${b.degreeDayFactorCmPerDegCDay.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${b.dailyMeltVolumeMcm.toStringAsFixed(1)} MCM',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF06B6D4),
                          ),
                        ),
                        const Text(
                          'Daily Melt',
                          style: TextStyle(
                            fontSize: 9.5,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHydropowerInflowCard(
    List<DownstreamHydropowerInflowModel> hydro,
    bool isDark,
  ) {
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
              const Icon(Icons.bolt, color: Color(0xFFF59E0B), size: 18),
              const SizedBox(width: 8),
              Text(
                'DOWNSTREAM HYDROPOWER & DAM STORAGE INFLOW',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color:
                      isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: hydro.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final h = hydro[index];
              final statusColor = _getStatusColor(h.inflowStatus);

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            h.damName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: statusColor),
                          ),
                          child: Text(
                            h.inflowStatus.replaceAll('_', ' '),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${h.riverBasin} · Installed: ${h.installedCapacityMw.toStringAsFixed(0)} MW',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildHydroMetricItem(
                          'Live Inflow',
                          '${h.liveInflowCumecs.toStringAsFixed(0)} cumecs',
                          const Color(0xFF0284C7),
                        ),
                        _buildHydroMetricItem(
                          'Dispatch Cap',
                          '${h.generationCapacityUtilizedPct.toStringAsFixed(0)}%',
                          const Color(0xFF10B981),
                        ),
                        _buildHydroMetricItem(
                          'Daily Gain',
                          '+${h.dailyStorageGainMcm.toStringAsFixed(1)} MCM',
                          const Color(0xFF06B6D4),
                        ),
                        _buildHydroMetricItem(
                          'Freeboard',
                          '${h.spillwayClearanceMarginM.toStringAsFixed(1)} m',
                          const Color(0xFFF59E0B),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHydroMetricItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildRiparianSafetyCard(SnowmeltBasinModel basin, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFD97706).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFD97706).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFD97706), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DOWNSTREAM RIPARIAN & RIVERBED SAFETY DIRECTIVE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFD97706),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  basin.riparianSafetyAdvisory,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.4,
                    color: isDark
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVernacularBulletinCard(SnowmeltBasinModel basin, bool isDark) {
    final bulletins = basin.vernacularBulletins;
    final activeBulletin = bulletins[_selectedLanguage] ??
        bulletins['en'] ??
        'Bulletin unavailable.';

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
                  const Icon(Icons.campaign,
                      color: Color(0xFF0284C7), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'MOUNTAIN BASIN HYDRO-MET BULLETIN',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.9,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
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
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF334155)),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF0284C7),
                    backgroundColor: isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF1F5F9),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedLanguage = entry.key);
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
              color: isDark
                  ? const Color(0xFF0F172A).withValues(alpha: 0.7)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                    isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Text(
              activeBulletin,
              style: TextStyle(
                fontSize: 12,
                height: 1.45,
                color: isDark
                    ? const Color(0xFFE2E8F0)
                    : const Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstitutionalAttribution(bool isDark) {
    return Center(
      child: Text(
        'Data Source: IMD Mountain Weather Division · CWC (Ministry of Jal Shakti) · DRDO-DGRE · NRSC-ISRO',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10,
          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
        ),
      ),
    );
  }
}
