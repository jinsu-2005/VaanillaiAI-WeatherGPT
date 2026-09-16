import 'package:flutter/material.dart';
import '../models/agri_storage_model.dart';
import '../services/api_service.dart';

class AgriStorageScreen extends StatefulWidget {
  final AgriStorageResponseModel? initialData;

  const AgriStorageScreen({super.key, this.initialData});

  @override
  State<AgriStorageScreen> createState() => _AgriStorageScreenState();
}

class _AgriStorageScreenState extends State<AgriStorageScreen> {
  final ApiService _apiService = ApiService();
  AgriStorageResponseModel? _data;
  bool _isLoading = false;
  String _selectedMandiId = 'KHANNA_APMC';
  String _selectedLanguage = 'en';

  static const Map<String, String> _languageNames = {
    'en': 'English',
    'hi': 'हिन्दी (HI)',
    'pa': 'ਪੰਜਾਬੀ (PA)',
    'mr': 'मराठी (MR)',
    'te': 'తెలుగు (TE)',
    'gu': 'ગુજરાતી (GU)',
    'bn': 'বাংলা (BN)',
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _data = widget.initialData;
      _selectedMandiId = widget.initialData!.mandi.mandiId;
    } else {
      _loadData();
    }
  }

  Future<void> _loadData({String? mandiId}) async {
    setState(() => _isLoading = true);
    final targetMandi = mandiId ?? _selectedMandiId;
    final assessment =
        await _apiService.getAgriStorageAssessment(mandiId: targetMandi);
    if (mounted) {
      setState(() {
        _data = assessment;
        _selectedMandiId = targetMandi;
        _isLoading = false;
      });
    }
  }

  Color _getRiskColor(String riskTier) {
    switch (riskTier.toUpperCase()) {
      case 'CRITICAL_SPOILAGE_RISK':
        return const Color(0xFFDC2626); // Crimson Red
      case 'HIGH_MOISTURE_SURGE':
        return const Color(0xFFEA580C); // Orange
      case 'MODERATE_WEATHER_ALERT':
        return const Color(0xFFD97706); // Amber
      case 'SAFE_STORAGE_OPTIMAL':
      default:
        return const Color(0xFF059669); // Emerald Green
    }
  }

  Color _getMoistureStateColor(String state) {
    switch (state.toUpperCase()) {
      case 'PERILOUS_FERMENTATION_RISK':
        return const Color(0xFFDC2626);
      case 'UNSAFE_ELEVATED_MOISTURE':
        return const Color(0xFFEA580C);
      case 'ACCEPTABLE_STABLE':
        return const Color(0xFFD97706);
      case 'OPTIMAL_SAFE_DRY':
      default:
        return const Color(0xFF059669);
    }
  }

  Color _getTarpaulinColor(String status) {
    switch (status.toUpperCase()) {
      case 'IMMEDIATE_TIRPAL_DEPLOYMENT':
        return const Color(0xFFDC2626);
      case 'HIGH_PRIORITY_PREPOSITIONING':
        return const Color(0xFFEA580C);
      case 'STANDBY_MONITORING':
        return const Color(0xFFD97706);
      case 'NO_DEPLOYMENT_NEEDED':
      default:
        return const Color(0xFF059669);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mandi = _data?.mandi;
    final riskColor = _getRiskColor(_data?.overallRiskTier ?? 'MODERATE_WEATHER_ALERT');

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0B132B) : const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mandi Storage & Grain Defense',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              'IMD & ICAR-CIPHET Post-Harvest Weather Engine',
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
            tooltip: 'Refresh Mandi Telemetry',
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
                    'Calculating Henderson-Thompson Moisture Dynamics...',
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
                  // Mandi Hub Selector
                  _buildMandiSelector(isDark),
                  const SizedBox(height: 16),

                  // Hero Mandi Spoilage Defense Card
                  _buildHeroRiskCard(isDark, mandi, riskColor),
                  const SizedBox(height: 16),

                  // Henderson-Thompson Equilibrium Moisture Content (EMC) Matrix
                  _buildCropMoistureMatrixCard(isDark),
                  const SizedBox(height: 16),

                  // Fungal Mycotoxin & Aflatoxin B1 HUD
                  _buildAflatoxinHudCard(isDark),
                  const SizedBox(height: 16),

                  // Open Plinth & Drying Yard Telemetry Card
                  _buildOpenYardTelemetryCard(isDark),
                  const SizedBox(height: 16),

                  // Storage Engineering Directives (Dunnage & Tirpal)
                  _buildStorageDirectivesCard(isDark),
                  const SizedBox(height: 16),

                  // 7-Language Vernacular Bulletins
                  _buildVernacularCard(isDark),
                  const SizedBox(height: 16),

                  // National Monitored Mandis Network
                  _buildMonitoredMandisGrid(isDark),
                  const SizedBox(height: 16),

                  // Institutional Provenance & Metadata
                  _buildInstitutionalMetadataCard(isDark),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildMandiSelector(bool isDark) {
    final mandis = _data?.monitoredMandis ?? [];
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: mandis.isNotEmpty ? mandis.length : 7,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (mandis.isEmpty) {
            return const SizedBox();
          }
          final item = mandis[index];
          final isSelected = item.mandiId == _selectedMandiId;
          final tierColor = _getRiskColor(item.riskTier);

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
                  item.name.replaceAll(' APMC', '').replaceAll(' Agricultural Market', ''),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
              ],
            ),
            selectedColor: const Color(0xFF2563EB),
            backgroundColor:
                isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            onSelected: (selected) {
              if (selected && item.mandiId != _selectedMandiId) {
                _loadData(mandiId: item.mandiId);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildHeroRiskCard(
      bool isDark, MandiHubModel? mandi, Color riskColor) {
    final assessment = _data;
    if (assessment == null || mandi == null) return const SizedBox();

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
          color: riskColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: riskColor.withValues(alpha: 0.1),
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
                      mandi.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${mandi.district}, ${mandi.state} • ${mandi.latitude.toStringAsFixed(2)}°N, ${mandi.longitude.toStringAsFixed(2)}°E',
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
                  color: riskColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: riskColor, width: 1.2),
                ),
                child: Text(
                  assessment.overallRiskTier.replaceAll('_', ' '),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: riskColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0F172A).withValues(alpha: 0.6)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.cloud,
                  color: isDark ? Colors.cyanAccent : const Color(0xFF0284C7),
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    assessment.weatherCondition,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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
                  label: 'Ambient Temp',
                  value: '${assessment.ambientTemperatureC}°C',
                  icon: Icons.thermostat,
                  color: const Color(0xFFF59E0B),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildHeroMetricTile(
                  label: 'Ambient Humidity',
                  value: '${assessment.ambientRelativeHumidityPct}%',
                  icon: Icons.water_drop,
                  color: const Color(0xFF38BDF8),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildHeroMetricTile(
                  label: 'Open Plinth',
                  value: '${mandi.openPlinthPct.toStringAsFixed(1)}%',
                  icon: Icons.warehouse,
                  color: const Color(0xFFA855F7),
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

  Widget _buildCropMoistureMatrixCard(bool isDark) {
    final crops = _data?.cropHygroscopicMetrics ?? [];
    if (crops.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.grain, color: Color(0xFFF59E0B), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Henderson-Thompson Equilibrium Moisture (EMC)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Dynamic hygroscopic equilibrium moisture content under ambient microclimate',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 14),
          ...crops.map((c) => _buildCropRow(c, isDark)),
        ],
      ),
    );
  }

  Widget _buildCropRow(CropHygroscopicMetricsModel c, bool isDark) {
    final stateColor = _getMoistureStateColor(c.moistureState);
    final isSurplus = c.moistureSurplusDeficitPct > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: stateColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                c.cropName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: stateColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  c.moistureState.replaceAll('_', ' '),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: stateColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildCropStatCol(
                  'Current MC',
                  '${c.currentMoistureContentPct.toStringAsFixed(1)}%',
                  isDark,
                ),
              ),
              Expanded(
                child: _buildCropStatCol(
                  'Equilibrium EMC',
                  '${c.equilibriumMoistureContentPct.toStringAsFixed(1)}%',
                  isDark,
                ),
              ),
              Expanded(
                child: _buildCropStatCol(
                  'Safe Limit',
                  '${c.safeStorageLimitPct.toStringAsFixed(1)}%',
                  isDark,
                ),
              ),
              Expanded(
                child: _buildCropStatCol(
                  'Delta',
                  '${isSurplus ? '+' : ''}${c.moistureSurplusDeficitPct.toStringAsFixed(1)}%',
                  isDark,
                  valColor: isSurplus ? const Color(0xFFDC2626) : const Color(0xFF059669),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar showing moisture level vs safe limit
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (c.currentMoistureContentPct / 20.0).clamp(0.0, 1.0),
              backgroundColor: isDark ? Colors.white12 : Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(stateColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropStatCol(String label, String value, bool isDark,
      {Color? valColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: valColor,
          ),
        ),
      ],
    );
  }

  Widget _buildAflatoxinHudCard(bool isDark) {
    final fungal = _data?.fungalMycotoxinTelemetry;
    if (fungal == null) return const SizedBox();

    final riskColor = _getRiskColor(fungal.aflatoxinB1RiskLevel);
    final isOverLimit = fungal.projectedAflatoxinPpb > fungal.fssaiLimitUgPerKg;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: riskColor.withValues(alpha: 0.35),
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
                  const Icon(Icons.coronavirus, color: Color(0xFFE11D48), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Aspergillus Flavus & Aflatoxin B1 Threat',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  fungal.aflatoxinB1RiskLevel.replaceAll('_', ' '),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: riskColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildHudTile(
                  label: 'Mold Spore Index',
                  value: '${fungal.moldSporeIncubationIndex.toStringAsFixed(1)} / 10',
                  subtext: 'Optimal: ${fungal.optimalGrowthTempRange}',
                  isDark: isDark,
                  color: const Color(0xFFE11D48),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildHudTile(
                  label: 'Projected Aflatoxin',
                  value: '${fungal.projectedAflatoxinPpb.toStringAsFixed(1)} ppb',
                  subtext: 'FSSAI Limit: ${fungal.fssaiLimitUgPerKg.toStringAsFixed(0)} ppb',
                  isDark: isDark,
                  color: isOverLimit ? const Color(0xFFDC2626) : const Color(0xFF059669),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: riskColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: riskColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'FSSAI Food Safety standard statutory ceiling is 15 µg/kg. Temperatures 25-37°C coupled with RH > 75% trigger acute Aspergillus mold sporulation.',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white70 : Colors.black87,
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

  Widget _buildHudTile({
    required String label,
    required String value,
    required String subtext,
    required bool isDark,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
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
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
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

  Widget _buildOpenYardTelemetryCard(bool isDark) {
    final yard = _data?.openYardTelemetry;
    if (yard == null) return const SizedBox();

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
            children: [
              const Icon(Icons.deck, color: Color(0xFF06B6D4), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Open Plinth & Auction Yard Exposure',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildYardStat(
                  '24h Rain Forecast',
                  '${yard.forecastRain24hMm.toStringAsFixed(1)} mm',
                  Icons.water,
                  isDark,
                ),
              ),
              Expanded(
                child: _buildYardStat(
                  'Hail Probability',
                  '${yard.forecastHailProbabilityPct.toStringAsFixed(0)}%',
                  Icons.ac_unit,
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildYardStat(
                  'Peak Wind Gusts',
                  '${yard.windGustKmh.toStringAsFixed(0)} km/h',
                  Icons.air,
                  isDark,
                ),
              ),
              Expanded(
                child: _buildYardStat(
                  'Dunnage Height',
                  '${yard.dunnagePalletElevationCm.toStringAsFixed(0)} cm (Min: 15)',
                  Icons.layers,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYardStat(
      String label, String value, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF0284C7)),
          const SizedBox(width: 8),
          Expanded(
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
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageDirectivesCard(bool isDark) {
    final directives = _data?.storageDirectives;
    if (directives == null) return const SizedBox();

    final tarpColor = _getTarpaulinColor(directives.tarpaulinStatus);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tarpColor.withValues(alpha: 0.4),
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
                  const Icon(Icons.shield, color: Color(0xFF2563EB), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Mandi Storage Directives',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tarpColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  directives.tarpaulinStatus.replaceAll('_', ' '),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: tarpColor,
                  ),
                ),
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
                const Icon(Icons.wind_power, color: Color(0xFF0284C7), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    directives.aerationFanScheduleRecommendation,
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
          const Text(
            'Mandatory Operational Steps:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          ...directives.recommendedActions.asMap().entries.map(
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
        'Storage advisory currently unavailable.';

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
              Row(
                children: [
                  const Icon(Icons.language, color: Color(0xFF10B981), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Regional Vernacular Advisory',
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

  Widget _buildMonitoredMandisGrid(bool isDark) {
    final mandis = _data?.monitoredMandis ?? [];
    if (mandis.isEmpty) return const SizedBox();

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
            'National Monitored Mandi Hubs',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...mandis.map((m) {
            final isCurrent = m.mandiId == _selectedMandiId;
            final riskColor = _getRiskColor(m.riskTier);

            return InkWell(
              onTap: () {
                if (m.mandiId != _selectedMandiId) {
                  _loadData(mandiId: m.mandiId);
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? (isDark
                          ? const Color(0xFF2563EB).withValues(alpha: 0.2)
                          : const Color(0xFFEFF6FF))
                      : (isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF8FAFC)),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCurrent
                        ? const Color(0xFF2563EB)
                        : (isDark ? Colors.white12 : Colors.black12),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: riskColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isCurrent
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${m.state} • ${m.predominantCrop} • RH: ${m.currentAmbientRhPct}%',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      m.riskTier.replaceAll('_', ' '),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: riskColor,
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
                'Institutional Provenance & Standards',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Authority: ${meta['source_authority'] ?? 'IMD Agromet Division & ICAR-CIPHET'}\n'
            'Statutory Standard: ${meta['statutory_reference'] ?? 'FSSAI Limit (15 ppb)'}\n'
            'Formulation: ${meta['formulation'] ?? 'Modified Henderson-Thompson EMC (ASABE D245.7)'}\n'
            'Warehousing Protocol: ${meta['operational_standard'] ?? 'FCI & CWC CAP Storage Code of Practice'}',
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
