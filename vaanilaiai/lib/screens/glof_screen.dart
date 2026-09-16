import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/glof_model.dart';
import '../services/api_service.dart';

class GlofScreen extends StatefulWidget {
  final GlofResponseModel? initialData;
  final ApiService? apiService;

  const GlofScreen({
    super.key,
    this.initialData,
    this.apiService,
  });

  @override
  State<GlofScreen> createState() => _GlofScreenState();
}

class _GlofScreenState extends State<GlofScreen> {
  late ApiService _apiService;
  GlofResponseModel? _data;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedLakeId = 'south_lhonak_sikkim';
  String _selectedLangCode = 'en';

  final List<Map<String, String>> _lakes = [
    {'id': 'south_lhonak_sikkim', 'name': 'South Lhonak (SK)'},
    {'id': 'shako_cho_sikkim', 'name': 'Shako Cho (SK)'},
    {'id': 'chorabari_uttarakhand', 'name': 'Chorabari (UK)'},
    {'id': 'ghepan_gath_himachal', 'name': 'Ghepan Gath (HP)'},
    {'id': 'chamoli_ronti_uttarakhand', 'name': 'Chamoli / Ronti (UK)'},
    {'id': 'pareechu_himachal', 'name': 'Pareechu (HP)'},
    {'id': 'dibang_cluster_arunachal', 'name': 'Dibang Cluster (AR)'},
  ];

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'label': 'English'},
    {'code': 'hi', 'label': 'हिंदी'},
    {'code': 'ne', 'label': 'नेपाली'},
    {'code': 'bo', 'label': 'བོད་སྐད (Bhutia)'},
    {'code': 'pa', 'label': 'ਪੰਜਾਬੀ'},
    {'code': 'bn', 'label': 'বাংলা'},
    {'code': 'as', 'label': 'অসমীয়া'},
  ];

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    if (widget.initialData != null) {
      _data = widget.initialData;
      _selectedLakeId = widget.initialData!.selectedLake.lakeId;
    } else {
      _fetchGlofAssessment();
    }
  }

  Future<void> _fetchGlofAssessment() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _apiService.getGlofAssessment(
        lakeId: _selectedLakeId,
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
          _errorMessage = 'Failed to load live GLOF telemetry. Reverting to calibrated offline baseline.';
          _data = GlofResponseModel.defaultFallback();
          _isLoading = false;
        });
      }
    }
  }

  void _onLakeSelected(String lakeId) {
    if (_selectedLakeId == lakeId) return;
    setState(() {
      _selectedLakeId = lakeId;
    });
    _fetchGlofAssessment();
  }

  Color _getThreatColor(String tier) {
    switch (tier.toUpperCase()) {
      case 'CRITICAL_RED_BREACH_IMMINENT':
        return const Color(0xFFEF4444); // Crimson Red
      case 'HIGH_ORANGE_WARNING':
        return const Color(0xFFF97316); // Bright Orange
      case 'MODERATE_YELLOW_WATCH':
        return const Color(0xFFFBBF24); // Amber Yellow
      case 'LOW_GREEN_MONITOR':
      default:
        return const Color(0xFF10B981); // Emerald Green
    }
  }

  String _formatThreatTitle(String tier) {
    switch (tier.toUpperCase()) {
      case 'CRITICAL_RED_BREACH_IMMINENT':
        return 'CRITICAL RED · BREACH IMMINENT';
      case 'HIGH_ORANGE_WARNING':
        return 'HIGH ORANGE WARNING';
      case 'MODERATE_YELLOW_WATCH':
        return 'MODERATE YELLOW WATCH';
      case 'LOW_GREEN_MONITOR':
      default:
        return 'LOW GREEN MONITOR';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF081524) : const Color(0xFFF1F5F9);
    final cardBg = isDark ? const Color(0xFF0F2338) : Colors.white;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white70 : const Color(0xFF475569);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Himalayan GLOF Early Warning',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'NRSC-ISRO · CWC · NDMA Glacial Lake Radar',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh GLOF Telemetry',
            onPressed: _fetchGlofAssessment,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'GLOF Hydrodynamic Guide',
            onPressed: () => _showGuideDialog(context),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SpinKitPouringHourGlass(
                    color: Color(0xFF38BDF8),
                    size: 50.0,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tracking Moraine Piping & Breach Hydrodynamics...',
                    style: TextStyle(color: secondaryTextColor),
                  ),
                ],
              ),
            )
          : _data == null
              ? Center(
                  child: Text(
                    _errorMessage ?? 'No GLOF telemetry available.',
                    style: TextStyle(color: secondaryTextColor),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchGlofAssessment,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Offline notice banner if served from cache
                        if (_data!.offlineCached)
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFFB74D)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.offline_bolt_rounded, color: Color(0xFFE65100), size: 18),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Serving calibrated NRSC/CWC offline baseline. Connect to network for live SAR altimetry.',
                                    style: TextStyle(color: Color(0xFFE65100), fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // 1. Lake Selector Chips
                        _buildLakeSelector(isDark),
                        const SizedBox(height: 12),

                        // 2. Hero GLOF Threat Banner
                        _buildHeroThreatBanner(isDark, cardBg, primaryTextColor, secondaryTextColor),
                        const SizedBox(height: 16),

                        // 3. Glacial Lake Morphometry & Satellite SAR Card
                        _buildMorphometryCard(isDark, cardBg, primaryTextColor, secondaryTextColor),
                        const SizedBox(height: 16),

                        // 4. Moraine Dam Geotechnical Stability HUD
                        _buildMoraineStabilityCard(isDark, cardBg, primaryTextColor, secondaryTextColor),
                        const SizedBox(height: 16),

                        // 5. Peak Breach Outflow Discharge & Hydrodynamics
                        _buildBreachHydrodynamicsCard(isDark, cardBg, primaryTextColor, secondaryTextColor),
                        const SizedBox(height: 16),

                        // 6. Downstream Flood Wave Timeline & Infrastructure ETA Cascade
                        _buildDownstreamTimelineCard(isDark, cardBg, primaryTextColor, secondaryTextColor),
                        const SizedBox(height: 16),

                        // 7. NDMA Mountain Life-Safety & Evacuation Directives
                        _buildNdmaDirectivesCard(isDark, cardBg, primaryTextColor, secondaryTextColor),
                        const SizedBox(height: 16),

                        // 8. 7-Language Himalayan Bulletin Switcher
                        _buildVernacularBulletinSection(isDark, cardBg, primaryTextColor, secondaryTextColor),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildLakeSelector(bool isDark) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _lakes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final l = _lakes[index];
          final isSelected = l['id'] == _selectedLakeId;
          return ChoiceChip(
            label: Text(l['name']!),
            selected: isSelected,
            selectedColor: const Color(0xFF0284C7),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
            backgroundColor: isDark ? const Color(0xFF132B45) : const Color(0xFFE2E8F0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (_) => _onLakeSelected(l['id']!),
          );
        },
      ),
    );
  }

  Widget _buildHeroThreatBanner(
    bool isDark,
    Color cardBg,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    final lake = _data!.selectedLake;
    final threatColor = _getThreatColor(lake.threatTier);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF112A42), const Color(0xFF0C1E30)]
              : [const Color(0xFFE0F2FE), const Color(0xFFBAE6FD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: threatColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: threatColor.withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
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
                child: Row(
                  children: [
                    Icon(Icons.tsunami_rounded, color: threatColor, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lake.lakeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                            ),
                          ),
                          Text(
                            '${lake.riverBasin} · ${lake.state} · ${lake.elevationM.toStringAsFixed(0)}m MSL',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: secondaryTextColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: threatColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: threatColor, width: 1.2),
                ),
                child: Text(
                  _formatThreatTitle(lake.threatTier),
                  style: TextStyle(
                    color: threatColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                lake.morphometry.waterVolumeMillionM3.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: primaryTextColor,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Million m³ Impounded Volume',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: threatColor,
                      ),
                    ),
                    Text(
                      'Surface Area: ${lake.morphometry.surfaceAreaHa.toStringAsFixed(0)} ha · Max Depth: ${lake.morphometry.maxDepthM.toStringAsFixed(0)}m',
                      style: TextStyle(fontSize: 12, color: secondaryTextColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHeroMetric(
                'Breach Mechanism',
                lake.breachHydrodynamics.triggerMechanism.replaceAll('_', ' '),
                Icons.warning_amber_rounded,
                threatColor,
                secondaryTextColor,
              ),
              _buildHeroMetric(
                'Wave Celerity',
                '${lake.breachHydrodynamics.wavePropagationSpeedKmh.toStringAsFixed(0)} km/h',
                Icons.speed_rounded,
                const Color(0xFF38BDF8),
                secondaryTextColor,
              ),
              _buildHeroMetric(
                'Earliest Arrival',
                '${lake.downstreamImpactTimeline.isNotEmpty ? lake.downstreamImpactTimeline.first.waveArrivalEtaMin : 0} min',
                Icons.timer_rounded,
                const Color(0xFFF59E0B),
                secondaryTextColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroMetric(
    String label,
    String value,
    IconData icon,
    Color iconColor,
    Color secondaryTextColor,
  ) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: iconColor),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, color: secondaryTextColor)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildMorphometryCard(
    bool isDark,
    Color cardBg,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    final morph = _data!.selectedLake.morphometry;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.satellite_alt_rounded, color: Color(0xFF38BDF8), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Glacial Lake Morphometry & Satellite SAR',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFEF4444)),
                ),
                child: Text(
                  '+${morph.expansionRate10yrPct.toStringAsFixed(1)}% 10-Yr Expansion',
                  style: const TextStyle(
                    color: Color(0xFFEF4444),
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
              Expanded(
                child: _buildMetricTile(
                  'Surface Area',
                  '${morph.surfaceAreaHa.toStringAsFixed(0)} ha',
                  '${morph.surfaceAreaKm2.toStringAsFixed(2)} km²',
                  const Color(0xFF38BDF8),
                  primaryTextColor,
                  secondaryTextColor,
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  'Water Depth',
                  'Mean ${morph.meanDepthM.toStringAsFixed(0)}m',
                  'Max ${morph.maxDepthM.toStringAsFixed(0)}m',
                  const Color(0xFF10B981),
                  primaryTextColor,
                  secondaryTextColor,
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  'Storage Volume',
                  '${morph.waterVolumeMillionM3.toStringAsFixed(1)} M m³',
                  'High Hydrostatic Load',
                  const Color(0xFFF59E0B),
                  primaryTextColor,
                  secondaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0B192A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.radar_rounded, size: 16, color: Color(0xFF38BDF8)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    morph.satelliteSensorProvenance,
                    style: TextStyle(fontSize: 11, color: secondaryTextColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoraineStabilityCard(
    bool isDark,
    Color cardBg,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    final geo = _data!.selectedLake.moraineGeotechnics;
    final isCritical = geo.hydraulicPipingIndex >= 1.0 || geo.crestWidthToHeightRatio < 2.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCritical
              ? const Color(0xFFEF4444).withValues(alpha: 0.6)
              : (isDark ? const Color(0xFF1E3A5F) : const Color(0xFFCBD5E1)),
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
                  Icon(Icons.terrain_rounded, color: Color(0xFFF59E0B), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Moraine Dam Geotechnical Stability',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isCritical
                      ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                      : const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCritical ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                  ),
                ),
                child: Text(
                  isCritical ? 'CRITICAL GEOTECHNICAL RISK' : 'STABLE MORAINE DAM',
                  style: TextStyle(
                    color: isCritical ? const Color(0xFFEF4444) : const Color(0xFF10B981),
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
              Expanded(
                child: _buildMetricTile(
                  'Dam Geometry',
                  'Height: ${geo.damHeightM.toStringAsFixed(0)}m',
                  'Ratio Wm/Hm: ${geo.crestWidthToHeightRatio.toStringAsFixed(2)}',
                  const Color(0xFF38BDF8),
                  primaryTextColor,
                  secondaryTextColor,
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  'Freeboard & Thaw',
                  'Freeboard: ${geo.freeboardHeightM.toStringAsFixed(1)}m',
                  'Thaw: ${geo.permafrostDegradationPct.toStringAsFixed(0)}%',
                  const Color(0xFFF59E0B),
                  primaryTextColor,
                  secondaryTextColor,
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  'Piping Index',
                  'i / i_crit = ${geo.hydraulicPipingIndex.toStringAsFixed(2)}',
                  geo.hydraulicPipingIndex >= 1.0 ? 'Piping Imminent' : 'Sub-critical',
                  geo.hydraulicPipingIndex >= 1.0 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                  primaryTextColor,
                  secondaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0B192A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              geo.stabilityStatus,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF59E0B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreachHydrodynamicsCard(
    bool isDark,
    Color cardBg,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    final hydro = _data!.selectedLake.breachHydrodynamics;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.water_rounded, color: Color(0xFF0284C7), size: 20),
              SizedBox(width: 8),
              Text(
                'Breach Hydrodynamics & Peak Outflow',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildBigStat(
                  'Peak Discharge (Qp)',
                  '${hydro.peakOutflowDischargeM3S.toStringAsFixed(0)} m³/s',
                  'Costa/Froehlich Model',
                  const Color(0xFFEF4444),
                ),
              ),
              Expanded(
                child: _buildBigStat(
                  'Breach Time',
                  '${hydro.breachFormationTimeHours.toStringAsFixed(1)} Hours',
                  'Channel incision window',
                  const Color(0xFFF59E0B),
                ),
              ),
              Expanded(
                child: _buildBigStat(
                  'Volume Released',
                  '${hydro.totalBreachVolumeMillionM3.toStringAsFixed(1)} M m³',
                  'Downstream flood surge',
                  const Color(0xFF0284C7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDownstreamTimelineCard(
    bool isDark,
    Color cardBg,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    final timeline = _data!.selectedLake.downstreamImpactTimeline;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.route_rounded, color: Color(0xFF38BDF8), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Downstream Flood Wave Timeline (ETA)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                'Speed: ${_data!.selectedLake.breachHydrodynamics.wavePropagationSpeedKmh.toStringAsFixed(0)} km/h',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF38BDF8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...timeline.asMap().entries.map((entry) {
            final idx = entry.key;
            final node = entry.value;
            final isFirst = idx == 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isFirst
                    ? (isDark ? const Color(0xFF221318) : const Color(0xFFFFF1F2))
                    : (isDark ? const Color(0xFF0B192A) : const Color(0xFFF8FAFC)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isFirst
                      ? const Color(0xFFEF4444).withValues(alpha: 0.5)
                      : (isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE2E8F0)),
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
                          node.nodeName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isFirst ? const Color(0xFFEF4444) : primaryTextColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ETA: ${node.waveArrivalEtaMin} min',
                          style: const TextStyle(
                            color: Color(0xFF0284C7),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '${node.distanceKm.toStringAsFixed(0)} km downstream',
                        style: TextStyle(fontSize: 11, color: secondaryTextColor),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Peak Stage: +${node.peakSurgeDepthM.toStringAsFixed(1)}m',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Evacuate >${node.evacuationZoneElevationM.toStringAsFixed(0)}m',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    node.infrastructureAlert,
                    style: TextStyle(
                      fontSize: 11,
                      color: isFirst ? const Color(0xFFEF4444) : secondaryTextColor,
                      fontWeight: isFirst ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNdmaDirectivesCard(
    bool isDark,
    Color cardBg,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    final directives = _data!.selectedLake.ndmaSafetyDirectives;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield_rounded, color: Color(0xFFEF4444), size: 20),
              SizedBox(width: 8),
              Text(
                'NDMA Mountain Community & Hydropower Directives',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...directives.map((dir) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.arrow_right_rounded, size: 20, color: Color(0xFFEF4444)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      dir,
                      style: TextStyle(fontSize: 12, height: 1.4, color: primaryTextColor),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildVernacularBulletinSection(
    bool isDark,
    Color cardBg,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    final bulletins = _data!.bulletins;
    final currentBulletin = bulletins[_selectedLangCode] ?? bulletins['en'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.campaign_rounded, color: Color(0xFF38BDF8), size: 20),
              SizedBox(width: 8),
              Text(
                'Himalayan Regional Early Warning Bulletin',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _languages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final lang = _languages[index];
                final isSel = lang['code'] == _selectedLangCode;
                return ChoiceChip(
                  label: Text(lang['label']!),
                  selected: isSel,
                  selectedColor: const Color(0xFF0284C7),
                  labelStyle: TextStyle(
                    color: isSel ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    fontSize: 12,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: isDark ? const Color(0xFF132B45) : const Color(0xFFE2E8F0),
                  onSelected: (_) => setState(() => _selectedLangCode = lang['code']!),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0B192A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFCBD5E1),
              ),
            ),
            child: Text(
              currentBulletin,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: primaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(
    String label,
    String val1,
    String val2,
    Color accentColor,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: secondaryTextColor)),
        const SizedBox(height: 4),
        Text(
          val1,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: accentColor),
        ),
        Text(val2, style: TextStyle(fontSize: 11, color: primaryTextColor)),
      ],
    );
  }

  Widget _buildBigStat(String label, String mainVal, String subVal, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          mainVal,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: accent),
        ),
        Text(subVal, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  void _showGuideDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.tsunami_rounded, color: Color(0xFF38BDF8)),
            SizedBox(width: 8),
            Text('Himalayan GLOF Guide'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1. Moraine Dam Peak Breach Discharge (Qp):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Qp ≈ 0.72 × (V_m³)^0.53\nCosta & Froehlich empirical breach formula modeling peak surge flood discharge.',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 10),
              Text(
                '2. Downstream Surge Wave Propagation (ETA):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Mountain gorge celerity reaches 30 to 50 km/h (8-14 m/s), transmitting peak surge waves across river channels with minimal warning windows.',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 10),
              Text(
                '3. NDMA Vertical Evacuation Rule:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Civilians in mountain valleys must evacuate vertically to at least 30 meters above the active riverbed level, rather than fleeing longitudinally along roads.',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 10),
              Text(
                '4. Hydropower Barrage Bottom Flush:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Downstream dam radial gates must immediately flush to empty reservoirs and avoid structural overtopping destruction.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got It'),
          ),
        ],
      ),
    );
  }
}
