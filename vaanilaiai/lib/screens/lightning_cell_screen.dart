import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lightning_cell_model.dart';
import '../providers/weather_provider.dart';
import '../services/api_service.dart';

class LightningCellScreen extends StatefulWidget {
  final String? initialCorridorId;
  final LightningCellResponseModel? initialAssessment;

  const LightningCellScreen({
    super.key,
    this.initialCorridorId,
    this.initialAssessment,
  });

  @override
  State<LightningCellScreen> createState() => _LightningCellScreenState();
}

class _LightningCellScreenState extends State<LightningCellScreen> {
  final ApiService _apiService = ApiService();
  LightningCellResponseModel? _assessment;
  bool _isLoading = true;
  String _selectedCorridorId = 'mayurbhanj_odisha';
  String _selectedLanguage = 'en';

  final List<Map<String, String>> _corridors = [
    {'id': 'mayurbhanj_odisha', 'name': 'Mayurbhanj (OD)', 'full': 'Mayurbhanj & Chota Nagpur'},
    {'id': 'brahmaputra_assam', 'name': 'Brahmaputra (AS)', 'full': 'Brahmaputra & Meghalaya'},
    {'id': 'gangetic_bengal', 'name': 'Gangetic Bengal (WB)', 'full': 'Gangetic WB & Sundarbans'},
    {'id': 'purvanchal_up_bihar', 'name': 'Sonbhadra (UP/BR)', 'full': 'Sonbhadra & Purvanchal'},
    {'id': 'malnad_karnataka', 'name': 'Malnad (KA)', 'full': 'Malnad & Western Ghats'},
    {'id': 'rayalaseema_ap', 'name': 'Rayalaseema (AP)', 'full': 'Rayalaseema & Coastal AP'},
    {'id': 'central_tribal_mp', 'name': 'Central Tribal (MP)', 'full': 'Central Tribal Belt'},
  ];

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'label': 'English'},
    {'code': 'hi', 'label': 'हिंदी'},
    {'code': 'od', 'label': 'ଓଡ଼ିଆ'},
    {'code': 'bn', 'label': 'বাংলা'},
    {'code': 'te', 'label': 'తెలుగు'},
    {'code': 'mr', 'label': 'मराठी'},
    {'code': 'as', 'label': 'অসমীয়া'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialCorridorId != null) {
      _selectedCorridorId = widget.initialCorridorId!;
    }
    if (widget.initialAssessment != null) {
      _assessment = widget.initialAssessment;
      _isLoading = false;
    } else {
      _loadAssessment();
    }
  }

  Future<void> _loadAssessment() async {
    setState(() => _isLoading = true);
    final weather = Provider.of<WeatherProvider>(context, listen: false);

    try {
      final res = await _apiService.getLightningCellAssessment(
        corridorId: _selectedCorridorId,
        latitude: weather.latitude,
        longitude: weather.longitude,
        language: _selectedLanguage,
      );
      if (mounted) {
        setState(() {
          _assessment = res;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _assessment = LightningCellResponseModel.defaultFallback();
          _isLoading = false;
        });
      }
    }
  }

  Color _getThreatColor(String tier) {
    switch (tier.toUpperCase()) {
      case 'EXTREME':
        return const Color(0xFFDC2626);
      case 'SEVERE':
        return const Color(0xFFEA580C);
      case 'ELEVATED':
        return const Color(0xFFF59E0B);
      case 'MODERATE':
        return const Color(0xFF3B82F6);
      case 'LOW':
      default:
        return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lightning Cell & Downburst Radar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'IITM LLN & IMD Doppler Dual-Pol Network',
              style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Nowcast',
            onPressed: _loadAssessment,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF59E0B),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadAssessment,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOfflineBadge(),
                    _buildCorridorSelector(isDark),
                    const SizedBox(height: 14),
                    _buildHeroThreatCard(isDark),
                    const SizedBox(height: 14),
                    _buildLightningJumpHud(isDark),
                    const SizedBox(height: 14),
                    _buildTotalLightningPartitioning(isDark),
                    const SizedBox(height: 14),
                    _buildRadarHydrometeorCard(isDark),
                    const SizedBox(height: 14),
                    _buildClimatologyCard(isDark),
                    const SizedBox(height: 14),
                    _buildNdmaGuidelinesCard(isDark),
                    const SizedBox(height: 14),
                    _buildVernacularBulletinSection(isDark),
                    const SizedBox(height: 24),
                    _buildProvenanceFooter(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOfflineBadge() {
    if (_assessment == null || !_assessment!.isOfflineFallback) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF59E0B)),
      ),
      child: const Row(
        children: [
          Icon(Icons.wifi_off_rounded, color: Color(0xFFB45309), size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Offline Mode: Displaying calibrated IITM climatological baseline.',
              style: TextStyle(color: Color(0xFF92400E), fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorridorSelector(bool isDark) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _corridors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final item = _corridors[idx];
          final isSelected = item['id'] == _selectedCorridorId;
          return ChoiceChip(
            label: Text(
              item['name']!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
            selected: isSelected,
            selectedColor: const Color(0xFFD97706),
            backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            onSelected: (selected) {
              if (selected && item['id'] != _selectedCorridorId) {
                setState(() => _selectedCorridorId = item['id']!);
                _loadAssessment();
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildHeroThreatCard(bool isDark) {
    final a = _assessment!;
    final threatColor = _getThreatColor(a.threatTier);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [Colors.white, const Color(0xFFF1F5F9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: threatColor.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: threatColor.withValues(alpha: 0.12),
            blurRadius: 10,
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
                      a.corridor.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      a.corridor.state,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: threatColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: threatColor),
                ),
                child: Text(
                  '${a.threatTier} THREAT',
                  style: TextStyle(
                    color: threatColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  title: 'Cell Stage',
                  value: a.cellStage.replaceAll('_', ' '),
                  icon: Icons.thunderstorm_rounded,
                  color: const Color(0xFF38BDF8),
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  title: 'Nearest Cell',
                  value: '${a.nearestCellDistanceKm.toStringAsFixed(1)} km',
                  icon: Icons.radar_rounded,
                  color: const Color(0xFFF59E0B),
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  title: 'Cell Speed',
                  value: '${a.cellSpeedKmh.toStringAsFixed(0)} km/h',
                  icon: Icons.navigation_rounded,
                  color: const Color(0xFF10B981),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLightningJumpHud(bool isDark) {
    final a = _assessment!;
    final jump = a.lightningJump;
    final downburst = a.downburstRisk;
    final isJump = jump.jumpDetected;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isJump ? const Color(0xFFEF4444) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          width: isJump ? 1.8 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.electric_bolt_rounded, color: Color(0xFFF59E0B), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Gatlin-Goodman Lightning Jump (LJA)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isJump ? const Color(0xFFFEE2E2) : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: isJump ? const Color(0xFFEF4444) : const Color(0xFF10B981)),
                ),
                child: Text(
                  isJump ? 'JUMP: ${jump.jumpSeverity}' : 'STABLE',
                  style: TextStyle(
                    color: isJump ? const Color(0xFFB91C1C) : const Color(0xFF047857),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isJump)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sudden updraft acceleration detected (+${jump.deltaFlashRatePerMinSq.toStringAsFixed(1)} fl/min²)! '
                      'Severe ground downburst or hail expected in ~${jump.leadTimeMinutes} minutes (Prob: ${jump.severeWeatherProbabilityPct.toStringAsFixed(0)}%).',
                      style: const TextStyle(color: Color(0xFF991B1B), fontSize: 11.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  title: 'Rate of Change (ΔTLR)',
                  value: '${jump.deltaFlashRatePerMinSq >= 0 ? "+" : ""}${jump.deltaFlashRatePerMinSq.toStringAsFixed(1)} fl/min²',
                  icon: Icons.trending_up_rounded,
                  color: const Color(0xFFE11D48),
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  title: 'Outflow Gust Speed',
                  value: '${downburst.estimatedGustSpeedKmh.toStringAsFixed(0)} km/h',
                  icon: Icons.air_rounded,
                  color: const Color(0xFF2563EB),
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  title: 'DCAPE Downdraft',
                  value: '${downburst.dcapeJKg.toStringAsFixed(0)} J/kg',
                  icon: Icons.compress_rounded,
                  color: const Color(0xFF7C3AED),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            downburst.damagePotential,
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalLightningPartitioning(bool isDark) {
    final tl = _assessment!.totalLightning;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Lightning Partitioning (IC vs CG)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                'Total: ${tl.totalFlashRatePerMin.toStringAsFixed(0)} fl/min',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFD97706)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // IC vs CG Ratio Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  Expanded(
                    flex: tl.intraCloudRatePerMin.toInt(),
                    child: Container(color: const Color(0xFF38BDF8)),
                  ),
                  Expanded(
                    flex: tl.cloudToGroundRatePerMin.toInt().clamp(1, 100),
                    child: Container(color: const Color(0xFFEF4444)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Intra-Cloud (IC): ${tl.intraCloudRatePerMin.toStringAsFixed(1)} fl/min',
                style: const TextStyle(fontSize: 11, color: Color(0xFF0284C7), fontWeight: FontWeight.w600),
              ),
              Text(
                'Cloud-to-Ground (CG): ${tl.cloudToGroundRatePerMin.toStringAsFixed(1)} fl/min',
                style: const TextStyle(fontSize: 11, color: Color(0xFFDC2626), fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  title: 'IC : CG Ratio',
                  value: '${tl.icCgRatio.toStringAsFixed(1)} : 1',
                  icon: Icons.pie_chart_rounded,
                  color: const Color(0xFF0D9488),
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  title: 'Peak Current',
                  value: '${tl.peakStrokeCurrentKa.toStringAsFixed(0)} kA',
                  icon: Icons.offline_bolt_rounded,
                  color: const Color(0xFFD97706),
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  title: '+CG Positive Strokes',
                  value: '${tl.positiveCgPercentage.toStringAsFixed(1)}%',
                  icon: Icons.add_circle_outline_rounded,
                  color: tl.isPositiveCgHazard ? const Color(0xFFDC2626) : const Color(0xFF10B981),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          if (tl.isPositiveCgHazard)
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.local_fire_department_rounded, color: Color(0xFFB45309), size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'High-Energy +CG Strokes Aloft: Continuing currents >40ms produce severe fire ignition and extreme fatality risk.',
                      style: TextStyle(color: Color(0xFF92400E), fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRadarHydrometeorCard(bool isDark) {
    final echo = _assessment!.radarEcho;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.satellite_alt_rounded, color: Color(0xFF2563EB), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Doppler Dual-Pol Radar Classification',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (echo.hailCoreAloftDetected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFEF4444)),
                  ),
                  child: const Text(
                    'HAIL CORE ALOFT',
                    style: TextStyle(color: Color(0xFFDC2626), fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Reporting Station: ${echo.radarStation}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  title: 'Reflectivity (Z_HH)',
                  value: '${echo.reflectivityZhhDbz.toStringAsFixed(1)} dBZ',
                  icon: Icons.layers_rounded,
                  color: const Color(0xFFDC2626),
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  title: 'Diff Refl (Z_DR)',
                  value: '${echo.differentialReflectivityZdrDb.toStringAsFixed(2)} dB',
                  icon: Icons.tune_rounded,
                  color: const Color(0xFF2563EB),
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  title: 'Copolar Coeff (ρ_HV)',
                  value: echo.correlationCoeffRhoHv.toStringAsFixed(2),
                  icon: Icons.hub_rounded,
                  color: const Color(0xFF059669),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Hydrometeor Aloft: ${echo.hydrometeorClassification.replaceAll('_', ' ')}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClimatologyCard(bool isDark) {
    final c = _assessment!.climatology;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'IITM Annual Flash Density Climatology',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF3B82F6)),
                ),
                child: Text(
                  '${c.nationalHazardPercentile.toStringAsFixed(1)}th Percentile',
                  style: const TextStyle(color: Color(0xFF1D4ED8), fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  title: 'Annual Flash Density',
                  value: '${c.annualFlashDensityPerSqKm.toStringAsFixed(1)} fl/km²/yr',
                  icon: Icons.map_rounded,
                  color: const Color(0xFFD97706),
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  title: 'Climatological Tier',
                  value: c.climatologicalTier.replaceAll('_', ' '),
                  icon: Icons.shield_rounded,
                  color: const Color(0xFF9333EA),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '5-Year Climatological Trend: ${c.fiveYearTrend}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildNdmaGuidelinesCard(bool isDark) {
    final ndma = _assessment!.ndmaGuidelines;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.health_and_safety_rounded, color: Color(0xFFD97706), size: 20),
              SizedBox(width: 8),
              Text(
                'NDMA Lightning Safety Action Plan',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Anti-tree warning box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFF87171)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.park_rounded, color: Color(0xFFDC2626), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ndma.antiTreeWarning,
                    style: const TextStyle(color: Color(0xFF991B1B), fontSize: 11.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildGuidelineRow(Icons.accessibility_new_rounded, 'Open-Field Crouch', ndma.lightningCrouchPosture),
          const Divider(height: 16),
          _buildGuidelineRow(Icons.agriculture_rounded, 'Drop Metal Tools', ndma.metalImplementProhibition),
          const Divider(height: 16),
          _buildGuidelineRow(Icons.home_rounded, 'Indoor Shelter', ndma.indoorPuccaShelterGuidance),
          const Divider(height: 16),
          _buildGuidelineRow(Icons.favorite_rounded, 'Immediate CPR', ndma.cprResuscitationGuideline),
        ],
      ),
    );
  }

  Widget _buildGuidelineRow(IconData icon, String title, String body) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFD97706), size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(body, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVernacularBulletinSection(bool isDark) {
    final bulletins = _assessment!.vernacularBulletins;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Regional Language Broadcast Bulletin',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _languages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, idx) {
                final lang = _languages[idx];
                final isSelected = lang['code'] == _selectedLanguage;
                return ChoiceChip(
                  label: Text(
                    lang['label']!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFF2563EB),
                  backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedLanguage = lang['code']!);
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
            child: Text(
              bulletins[_selectedLanguage] ?? bulletins['en'] ?? '',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildProvenanceFooter() {
    return Center(
      child: Column(
        children: [
          const Text(
            'Indian Institute of Tropical Meteorology (IITM Pune, MoES)',
            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          const Text(
            'National Lightning Location Network (LLN) & IMD DWR Network',
            style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 2),
          Text(
            'Observed: ${_assessment?.timestamp.split('T').first ?? 'Live'}',
            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
