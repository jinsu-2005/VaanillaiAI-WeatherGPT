import 'package:flutter/material.dart';
import '../models/extended_range_prediction_model.dart';
import '../services/api_service.dart';

class ExtendedRangePredictionScreen extends StatefulWidget {
  final String? initialZoneId;
  final ErpResponseModel? initialData;

  const ExtendedRangePredictionScreen({
    super.key,
    this.initialZoneId,
    this.initialData,
  });

  @override
  State<ExtendedRangePredictionScreen> createState() =>
      _ExtendedRangePredictionScreenState();
}

class _ExtendedRangePredictionScreenState
    extends State<ExtendedRangePredictionScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _errorMessage;
  ErpResponseModel? _data;
  String _selectedZoneId = 'vidarbha_central_rainfed';
  String _selectedLanguage = 'en';

  final Map<String, String> _languageNames = {
    'en': 'English',
    'hi': 'हिन्दी (HI)',
    'mr': 'मराठी (MR)',
    'te': 'తెలుగు (TE)',
    'pa': 'ਪੰਜਾਬੀ (PA)',
    'bn': 'বাংলা (BN)',
    'gu': 'ગુજરાતી (GU)',
    'kn': 'ಕನ್ನಡ (KN)',
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialZoneId != null) {
      _selectedZoneId = widget.initialZoneId!;
    }
    if (widget.initialData != null) {
      _data = widget.initialData;
      _isLoading = false;
      _selectedZoneId = widget.initialData!.zoneId;
    } else {
      _loadData();
    }
  }

  Future<void> _loadData({String? zoneId}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      if (zoneId != null) _selectedZoneId = zoneId;
    });

    try {
      final res = await _apiService.getExtendedRangePredictionAssessment(
        zoneId: _selectedZoneId,
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
          _data = ErpResponseModel.defaultFallback();
          _isLoading = false;
        });
      }
    }
  }

  Color _getSpellColor(String spell) {
    switch (spell.toUpperCase()) {
      case 'ACTIVE_SURGE':
        return const Color(0xFF10B981); // Emerald
      case 'NORMAL_MONSOON':
        return const Color(0xFF0284C7); // Ocean Blue
      case 'POST_BREAK_REVIVAL':
        return const Color(0xFF06B6D4); // Cyan
      case 'WEAK_MONSOON':
        return const Color(0xFFD97706); // Amber
      case 'BREAK_MONSOON_CRITICAL':
      default:
        return const Color(0xFFE11D48); // Rose Crimson
    }
  }

  String _formatSpellLabel(String spell) {
    switch (spell.toUpperCase()) {
      case 'ACTIVE_SURGE':
        return 'ACTIVE MONSOON SURGE';
      case 'NORMAL_MONSOON':
        return 'NORMAL MONSOON SPELL';
      case 'POST_BREAK_REVIVAL':
        return 'POST-BREAK REVIVAL PHASE';
      case 'WEAK_MONSOON':
        return 'WEAK / SUBDUED MONSOON';
      case 'BREAK_MONSOON_CRITICAL':
      default:
        return 'BREAK MONSOON CRITICAL';
    }
  }

  Color _getDepartureColor(String tier) {
    switch (tier.toUpperCase()) {
      case 'LARGE_EXCESS':
        return const Color(0xFF059669);
      case 'EXCESS':
        return const Color(0xFF10B981);
      case 'NORMAL':
        return const Color(0xFF0284C7);
      case 'DEFICIENT':
        return const Color(0xFFEA580C);
      case 'LARGE_DEFICIENT':
      case 'NO_RAIN':
      default:
        return const Color(0xFFDC2626);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentZone = _data?.currentZone;
    final spellColor = _getSpellColor(
      currentZone?.fourWeekForecast.isNotEmpty == true
          ? currentZone!.fourWeekForecast.first.monsoonSpellState
          : 'BREAK_MONSOON_CRITICAL',
    );

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B132B) : const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monsoon Extended Range (ERP)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              'IMD, NCMRWF & IITM 4-Week Multi-Model Ensemble',
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
            tooltip: 'Refresh ERP Feeds',
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
                    'Ingesting IITM CFSv2 & NCMRWF NCUM-ER 4-Week Ensembles...',
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
                  _buildZoneSelector(isDark),
                  const SizedBox(height: 16),
                  if (currentZone != null) ...[
                    _buildHeroSpellStatusCard(currentZone, spellColor, isDark),
                    const SizedBox(height: 14),
                    _buildFourWeekMatrixCard(currentZone, isDark),
                    const SizedBox(height: 14),
                    _buildIntraSeasonalPulseCard(currentZone.intraSeasonalPulse, isDark),
                    const SizedBox(height: 14),
                    _buildIcarContingencyCard(currentZone.agriculturalContingency, isDark),
                    const SizedBox(height: 14),
                    _buildVernacularBulletinCard(currentZone, isDark),
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
              'Offline mode active. Displaying calibrated IMD-NCMRWF extended range baseline.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneSelector(bool isDark) {
    final zones = _data?.allZones ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'AGRO-CLIMATIC MONSOON ZONES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            Text(
              '${zones.length} Monitored Belts',
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
            itemCount: zones.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final z = zones[index];
              final isSelected = z.zoneId == _selectedZoneId;
              final spellColor = _getSpellColor(z.currentMonsoonSpell);

              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: spellColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${z.zoneName} (${z.state})',
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
                    _loadData(zoneId: z.zoneId);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSpellStatusCard(
    ErpZoneModel zone,
    Color spellColor,
    bool isDark,
  ) {
    final pulse = zone.intraSeasonalPulse;
    final w1 = zone.fourWeekForecast.isNotEmpty ? zone.fourWeekForecast.first : null;

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
          color: spellColor.withValues(alpha: 0.5),
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
                  color: spellColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: spellColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cyclone, size: 14, color: spellColor),
                    const SizedBox(width: 6),
                    Text(
                      _formatSpellLabel(w1?.monsoonSpellState ?? 'BREAK_MONSOON_CRITICAL'),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: spellColor,
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
                  'Consensus: ${_data?.mmeModelConsensusPct.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0284C7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            zone.zoneName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sub-Division: ${zone.subDivisionName} (${zone.state})',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: zone.dominantCrops.map((crop) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.25)
                      : Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  crop,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Synoptic Trough & Findlater Jet HUD
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
                _buildSynopticMetric(
                  icon: Icons.alt_route,
                  label: 'MONSOON TROUGH',
                  value: '${pulse.monsoonTroughPositionLatitude.toStringAsFixed(1)}°N',
                  sub: pulse.monsoonTroughPositionLatitude >= 28.0
                      ? 'Foothills (Break)'
                      : 'Central Plains (Active)',
                  accent: pulse.monsoonTroughPositionLatitude >= 28.0
                      ? const Color(0xFFE11D48)
                      : const Color(0xFF10B981),
                  isDark: isDark,
                ),
                _buildSynopticDivider(isDark),
                _buildSynopticMetric(
                  icon: Icons.air,
                  label: 'FINDLATER JET',
                  value: '${pulse.findlaterJetSpeedKt.toStringAsFixed(1)} kt',
                  sub: 'Somali 850 hPa LLJ',
                  accent: const Color(0xFF0284C7),
                  isDark: isDark,
                ),
                _buildSynopticDivider(isDark),
                _buildSynopticMetric(
                  icon: Icons.speed,
                  label: 'BSISO PULSE',
                  value: 'Phase ${pulse.bsisoActivePhase}',
                  sub: 'Amp: ${pulse.bsisoAmplitude.toStringAsFixed(2)}',
                  accent: const Color(0xFF8B5CF6),
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSynopticMetric({
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
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
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

  Widget _buildSynopticDivider(bool isDark) {
    return Container(
      height: 38,
      width: 1,
      color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
    );
  }

  Widget _buildFourWeekMatrixCard(ErpZoneModel zone, bool isDark) {
    final weeks = zone.fourWeekForecast;

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
              const Icon(Icons.calendar_month, size: 18, color: Color(0xFF0284C7)),
              const SizedBox(width: 8),
              Text(
                '4-WEEK MULTI-MODEL ENSEMBLE FORECAST MATRIX',
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
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: weeks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final w = weeks[index];
              final depColor = _getDepartureColor(w.departureTier);
              final sign = w.rainfallLpaDeparturePct >= 0 ? '+' : '';

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: depColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          'W${w.weekNumber}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: depColor,
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
                            w.dateRangeLabel,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                '${w.rainfallForecastMm.toStringAsFixed(1)} mm',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                              ),
                              Text(
                                ' (Normal: ${w.normalLpaRainfallMm.toStringAsFixed(1)} mm)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Max Temp: ${w.maxTempAnomalyC >= 0 ? "+" : ""}${w.maxTempAnomalyC.toStringAsFixed(1)}°C | Min Temp: ${w.minTempAnomalyC >= 0 ? "+" : ""}${w.minTempAnomalyC.toStringAsFixed(1)}°C',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: depColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: depColor.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$sign${w.rainfallLpaDeparturePct.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: depColor,
                            ),
                          ),
                          Text(
                            w.departureTier.replaceAll('_', ' '),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: depColor,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildIntraSeasonalPulseCard(
    IntraSeasonalPulseTelemetryModel pulse,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: pulse.breakSpellRisk
              ? const Color(0xFFE11D48).withValues(alpha: 0.6)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.waves, size: 18, color: Color(0xFF8B5CF6)),
              const SizedBox(width: 8),
              Text(
                'INTRA-SEASONAL MONSOON PULSE (BSISO & MJO)',
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
          if (pulse.breakSpellRisk)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE11D48).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE11D48).withValues(alpha: 0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Color(0xFFE11D48), size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'BREAK MONSOON CONDITION: Trough shifted to Himalayan foothills. Suppressed convective rainfall across Central India.',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE11D48),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: _buildTelemetryBox(
                  title: 'BOREAL SUMMER OSCILLATION',
                  value: 'BSISO-1 (Phase ${pulse.bsisoActivePhase})',
                  badge: 'Amp: ${pulse.bsisoAmplitude.toStringAsFixed(2)}',
                  badgeColor: const Color(0xFF8B5CF6),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTelemetryBox(
                  title: 'NORTHWARD PROPAGATION',
                  value: '${pulse.northwardPropagationSpeedDegPerDay.toStringAsFixed(2)}° lat/day',
                  badge: 'Canonical 30-60d Mode',
                  badgeColor: const Color(0xFF0284C7),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTelemetryBox(
                  title: 'MADDEN-JULIAN OSCILLATION',
                  value: pulse.mjoPhase.replaceAll('PHASE_', 'Phase ').replaceAll('_', ' '),
                  badge: 'Amplitude: ${pulse.mjoAmplitude.toStringAsFixed(2)}',
                  badgeColor: const Color(0xFF06B6D4),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTelemetryBox(
                  title: 'SOMALI / FINDLATER JET (850 hPa)',
                  value: '${pulse.findlaterJetSpeedKt.toStringAsFixed(1)} kt',
                  badge: pulse.findlaterJetSpeedKt >= 25.0 ? 'Strong Flow' : 'Subdued Flow',
                  badgeColor: pulse.findlaterJetSpeedKt >= 25.0
                      ? const Color(0xFF10B981)
                      : const Color(0xFFD97706),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryBox({
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
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
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

  Widget _buildIcarContingencyCard(
    IcarDistrictContingencyModel cont,
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
              const Icon(Icons.agriculture, color: Color(0xFF10B981), size: 18),
              const SizedBox(width: 8),
              Text(
                'ICAR-CRIDA DISTRICT CONTINGENCY ADVICE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.9,
                  color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            cont.sowingWindowStatus,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            'Emergency Crop Alternatives:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          ...cont.contingencyCropAlternatives.map((alt) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontWeight: FontWeight.w800)),
                  Expanded(
                    child: Text(
                      alt,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 10),
          _buildContingencyBullet(
            icon: Icons.water_drop,
            title: 'Life-Saving Irrigation',
            desc: cont.irrigationMitigationDirective,
            isDark: isDark,
          ),
          const SizedBox(height: 6),
          _buildContingencyBullet(
            icon: Icons.landscape,
            title: 'In-Situ Moisture Conservation',
            desc: cont.inSituMoistureConservation,
            isDark: isDark,
          ),
          const SizedBox(height: 6),
          _buildContingencyBullet(
            icon: Icons.science,
            title: 'Foliar Intervention',
            desc: cont.standingCropIntervention,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildContingencyBullet({
    required IconData icon,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF10B981)),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 11,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
              ),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: desc),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVernacularBulletinCard(ErpZoneModel zone, bool isDark) {
    final bulletins = zone.vernacularBulletins;
    final activeBulletin =
        bulletins[_selectedLanguage] ?? bulletins['en'] ?? 'Bulletin unavailable.';

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
                    'REGIONAL AGRO-MET BULLETIN',
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
                  'IMD-NCMRWF-IITM Extended Range Multi-Model Ensemble (CFSv2 / NCUM-ER) & ICAR-CRIDA Agricultural Contingency Framework.',
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
