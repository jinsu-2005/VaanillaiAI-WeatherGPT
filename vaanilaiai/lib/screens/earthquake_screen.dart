import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/earthquake_model.dart';
import '../services/api_service.dart';

class EarthquakeScreen extends StatefulWidget {
  final EarthquakeResponseModel? initialData;
  final ApiService? apiService;

  const EarthquakeScreen({
    super.key,
    this.initialData,
    this.apiService,
  });

  @override
  State<EarthquakeScreen> createState() => _EarthquakeScreenState();
}

class _EarthquakeScreenState extends State<EarthquakeScreen> {
  late ApiService _apiService;
  EarthquakeResponseModel? _data;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedProvinceId = 'delhi_ncr_igp';
  String _selectedLangCode = 'en';

  final List<Map<String, String>> _provinces = [
    {'id': 'nw_himalaya_jk_hp', 'name': 'NW Himalaya (J&K/HP)'},
    {'id': 'ne_himalaya_sikkim_assam', 'name': 'NE Himalaya (Assam/Sikkim)'},
    {'id': 'kutch_saurashtra_gj', 'name': 'Kutch-Saurashtra (Gujarat)'},
    {'id': 'delhi_ncr_igp', 'name': 'Delhi-NCR (IGP)'},
    {'id': 'andaman_nicobar_subduction', 'name': 'Andaman & Nicobar'},
    {'id': 'koyna_deccan_mh', 'name': 'Koyna-Deccan (Maharashtra)'},
    {'id': 'uttarakhand_garhwal_uk', 'name': 'Garhwal Himalaya (UK)'},
  ];

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'label': 'English'},
    {'code': 'hi', 'label': 'हिंदी'},
    {'code': 'ur', 'label': 'اردو'},
    {'code': 'as', 'label': 'অসমীয়া'},
    {'code': 'bn', 'label': 'বাংলা'},
    {'code': 'gu', 'label': 'ગુજરાતી'},
    {'code': 'mr', 'label': 'मराठी'},
    {'code': 'ta', 'label': 'தமிழ்'},
  ];

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    if (widget.initialData != null) {
      _data = widget.initialData;
      _selectedProvinceId = widget.initialData!.selectedProvince.provinceId;
    } else {
      _fetchEarthquakeAssessment();
    }
  }

  Future<void> _fetchEarthquakeAssessment({String? provinceId}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _apiService.getEarthquakeAssessment(
        provinceId: provinceId ?? _selectedProvinceId,
      );
      setState(() {
        _data = res;
        _selectedProvinceId = res.selectedProvince.provinceId;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load earthquake seismology data: $e';
        _isLoading = false;
      });
    }
  }

  // ──────────────── Alert Tier Colors ────────────────

  Color _alertTierColor(String tier) {
    switch (tier) {
      case 'RED_DEVASTATING':
        return const Color(0xFFB71C1C);
      case 'ORANGE_DAMAGING':
        return const Color(0xFFE65100);
      case 'YELLOW_MODERATE':
        return const Color(0xFFF9A825);
      case 'GREEN_LIGHT':
        return const Color(0xFF2E7D32);
      default:
        return const Color(0xFF455A64);
    }
  }

  String _alertTierLabel(String tier) {
    switch (tier) {
      case 'RED_DEVASTATING':
        return 'RED — DEVASTATING';
      case 'ORANGE_DAMAGING':
        return 'ORANGE — DAMAGING';
      case 'YELLOW_MODERATE':
        return 'YELLOW — MODERATE';
      case 'GREEN_LIGHT':
        return 'GREEN — LIGHT';
      default:
        return tier;
    }
  }

  IconData _alertTierIcon(String tier) {
    switch (tier) {
      case 'RED_DEVASTATING':
        return Icons.crisis_alert;
      case 'ORANGE_DAMAGING':
        return Icons.warning_amber_rounded;
      case 'YELLOW_MODERATE':
        return Icons.info_outline;
      case 'GREEN_LIGHT':
        return Icons.check_circle_outline;
      default:
        return Icons.help_outline;
    }
  }

  // ──────────────── Magnitude Color ────────────────

  Color _magnitudeColor(double mw) {
    if (mw >= 7.0) return const Color(0xFFB71C1C);
    if (mw >= 6.0) return const Color(0xFFE65100);
    if (mw >= 5.0) return const Color(0xFFF9A825);
    return const Color(0xFF2E7D32);
  }

  // ──────────────── Build ────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text('🌍 Earthquake Seismology'),
        backgroundColor: const Color(0xFF161B22),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchEarthquakeAssessment(),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _data == null) {
      return const Center(
        child: SpinKitPulse(color: Color(0xFFF9A825), size: 48.0),
      );
    }
    if (_errorMessage != null && _data == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFEF5350), size: 48),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: const TextStyle(color: Color(0xFFEF9A9A)), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _fetchEarthquakeAssessment(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_data == null) return const SizedBox.shrink();

    final prov = _data!.selectedProvince;
    return RefreshIndicator(
      onRefresh: () => _fetchEarthquakeAssessment(),
      color: const Color(0xFFF9A825),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // ──── Offline Banner ────
          if (_data!.isOfflineCached)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF4A3000),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.cloud_off, color: Color(0xFFFFA726), size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Offline Mode — Calibrated Seismological Baseline',
                        style: TextStyle(color: Color(0xFFFFA726), fontSize: 12)),
                  ),
                ],
              ),
            ),

          // ──── Province Selector Chips ────
          _buildProvinceSelector(),
          const SizedBox(height: 16),

          // ──── Hero Magnitude Card ────
          _buildMagnitudeHeroCard(prov),
          const SizedBox(height: 16),

          // ──── Alert Tier Badge ────
          _buildAlertTierBadge(prov),
          const SizedBox(height: 16),

          // ──── Source Parameters ────
          _buildSourceParametersCard(prov),
          const SizedBox(height: 16),

          // ──── MMI Felt Intensity ────
          _buildMmiCard(prov),
          const SizedBox(height: 16),

          // ──── Aftershock Probability HUD ────
          _buildAftershockCard(prov),
          const SizedBox(height: 16),

          // ──── BIS Seismic Zone & Structural Vulnerability ────
          _buildStructuralDirectivesCard(prov),
          const SizedBox(height: 16),

          // ──── NDMA DOs and DON'Ts ────
          _buildNdmaDirectivesCard(prov),
          const SizedBox(height: 16),

          // ──── Multilingual Broadcasts ────
          _buildVernacularBulletinCard(prov),
          const SizedBox(height: 16),

          // ──── Provenance Footer ────
          _buildProvenanceFooter(),
        ],
      ),
    );
  }

  // ──────────────── Province Selector ────────────────

  Widget _buildProvinceSelector() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _provinces.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final prov = _provinces[index];
          final isSelected = prov['id'] == _selectedProvinceId;
          return ChoiceChip(
            label: Text(prov['name']!, style: TextStyle(
              color: isSelected ? Colors.black : const Color(0xFF8B949E),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            )),
            selected: isSelected,
            selectedColor: const Color(0xFFF9A825),
            backgroundColor: const Color(0xFF21262D),
            side: BorderSide(
              color: isSelected ? const Color(0xFFF9A825) : const Color(0xFF30363D),
            ),
            onSelected: (selected) {
              if (selected) {
                setState(() => _selectedProvinceId = prov['id']!);
                _fetchEarthquakeAssessment(provinceId: prov['id']!);
              }
            },
          );
        },
      ),
    );
  }

  // ──────────────── Hero Magnitude Card ────────────────

  Widget _buildMagnitudeHeroCard(SeismotectonicProvinceModel prov) {
    final mw = prov.sourceParameters.momentMagnitudeMw;
    final color = _magnitudeColor(mw);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.25), const Color(0xFF161B22)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Magnitude Ring
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 3),
                  color: color.withValues(alpha: 0.12),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('M', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600, height: 1.0)),
                      const SizedBox(height: 2),
                      Text(mw.toStringAsFixed(1),
                          style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w800, height: 1.0)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(prov.provinceName,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(prov.state,
                        style: const TextStyle(color: Color(0xFF8B949E), fontSize: 13)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.layers, color: Color(0xFF8B949E), size: 14),
                        const SizedBox(width: 4),
                        Text('Depth: ${prov.sourceParameters.focalDepthKm.toStringAsFixed(1)} km',
                            style: const TextStyle(color: Color(0xFFE6EDF3), fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Color(0xFF8B949E), size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(prov.sourceParameters.originTimeUtc,
                              style: const TextStyle(color: Color(0xFFE6EDF3), fontSize: 11),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Fault system
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1117),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(prov.dominantFaultSystem,
                style: const TextStyle(color: Color(0xFF8B949E), fontSize: 11),
                textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  // ──────────────── Alert Tier Badge ────────────────

  Widget _buildAlertTierBadge(SeismotectonicProvinceModel prov) {
    final color = _alertTierColor(prov.alertTier);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(_alertTierIcon(prov.alertTier), color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Seismic Alert Level',
                    style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 11, fontWeight: FontWeight.w500)),
                Text(_alertTierLabel(prov.alertTier),
                    style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          // BIS Zone badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1117),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF30363D)),
            ),
            child: Text(
              prov.structuralDirectives.bisSeismicZone.replaceAll('_', ' '),
              style: const TextStyle(color: Color(0xFFF9A825), fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────── Source Parameters Card ────────────────

  Widget _buildSourceParametersCard(SeismotectonicProvinceModel prov) {
    final src = prov.sourceParameters;
    return _buildGlassCard(
      title: '⚡ Seismic Source Parameters',
      children: [
        _buildMetricRow('Moment Magnitude (Mw)', src.momentMagnitudeMw.toStringAsFixed(1)),
        _buildMetricRow('Local Magnitude (ML)', src.localMagnitudeMl.toStringAsFixed(1)),
        _buildMetricRow('Focal Depth', '${src.focalDepthKm.toStringAsFixed(1)} km'),
        _buildMetricRow('Fault Mechanism', src.faultMechanism.replaceAll('_', ' ')),
        _buildMetricRow('Strike Azimuth', '${src.faultPlaneStrikeDeg.toStringAsFixed(0)}°'),
        _buildMetricRow('Rupture Length', '${src.ruptureLengthKm.toStringAsFixed(1)} km'),
        _buildMetricRow('Epicenter', '${src.epicenterLatitude.toStringAsFixed(2)}°N, ${src.epicenterLongitude.toStringAsFixed(2)}°E'),
      ],
    );
  }

  // ──────────────── MMI Intensity Card ────────────────

  Widget _buildMmiCard(SeismotectonicProvinceModel prov) {
    final mmi = prov.mmiAssessment;
    return _buildGlassCard(
      title: '📊 Modified Mercalli Intensity (MMI)',
      children: [
        // MMI Scale badge
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_alertTierColor(prov.alertTier).withValues(alpha: 0.3), const Color(0xFF161B22)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _alertTierColor(prov.alertTier).withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                const Text('MMI Intensity', style: TextStyle(color: Color(0xFF8B949E), fontSize: 11)),
                Text(mmi.epicentralMmi, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
                Text(mmi.perceivedShaking, style: const TextStyle(color: Color(0xFFE6EDF3), fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildMetricRow('Felt Radius', '${mmi.feltRadiusKm.toStringAsFixed(0)} km'),
        _buildMetricRow('DYFI Reports', '${mmi.didYouFeelItReports}'),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1117),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(mmi.potentialDamage,
              style: const TextStyle(color: Color(0xFFE6EDF3), fontSize: 12)),
        ),
      ],
    );
  }

  // ──────────────── Aftershock Probability HUD ────────────────

  Widget _buildAftershockCard(SeismotectonicProvinceModel prov) {
    final aft = prov.aftershockOutlook;
    return _buildGlassCard(
      title: '🔄 Aftershock Probabilistic Outlook',
      children: [
        // 24h probability gauge
        _buildMiniGauge('24h Aftershock Probability (M≥5)', aft.reasenbergJones24hProbabilityPct, 100,
            suffix: '%', color: aft.reasenbergJones24hProbabilityPct > 40 ? const Color(0xFFEF5350) : const Color(0xFFFFA726)),
        const SizedBox(height: 10),
        _buildMetricRow("Båth's Law Largest Aftershock", 'M ${aft.bathLawLargestAftershockMw.toStringAsFixed(1)}'),
        _buildMetricRow('Modified Omori p-value', aft.modifiedOmoriPValue.toStringAsFixed(2)),
        _buildMetricRow('Expected Aftershocks (7 day, M≥3)', '${aft.expectedAftershocks7Day}'),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1117),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.arrow_forward, color: Color(0xFF8B949E), size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(aft.coulombStressTransferDirection,
                    style: const TextStyle(color: Color(0xFFE6EDF3), fontSize: 12)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ──────────────── Structural Vulnerability ────────────────

  Widget _buildStructuralDirectivesCard(SeismotectonicProvinceModel prov) {
    final dir = prov.structuralDirectives;
    return _buildGlassCard(
      title: '🏗️ BIS IS:1893 Structural Assessment',
      children: [
        _buildMetricRow('BIS Seismic Zone', dir.bisSeismicZone.replaceAll('_', ' ')),
        _buildMetricRow('Design PGA', '${dir.designPgaG}g'),
        _buildMetricRow('Building Vulnerability', dir.buildingVulnerabilityClass),
        _buildMetricRow('Inspection Priority', dir.postQuakeInspectionPriority),
        const SizedBox(height: 8),
        _buildRiskRow('Soft-Story Collapse', dir.softStoryCollapseRisk),
        const SizedBox(height: 4),
        _buildRiskRow('Masonry Infill Damage', dir.masonryInfillDamageRisk),
      ],
    );
  }

  Widget _buildRiskRow(String label, String value) {
    final isHigh = value.toUpperCase().contains('CRITICAL') || value.toUpperCase().contains('HIGH');
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isHigh ? const Color(0xFF3D1111) : const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isHigh ? const Color(0xFFEF5350).withValues(alpha: 0.3) : const Color(0xFF30363D),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(
            color: isHigh ? const Color(0xFFEF5350) : const Color(0xFF8B949E),
            fontSize: 11, fontWeight: FontWeight.w600,
          )),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: Color(0xFFE6EDF3), fontSize: 12)),
        ],
      ),
    );
  }

  // ──────────────── NDMA DOs / DON'Ts ────────────────

  Widget _buildNdmaDirectivesCard(SeismotectonicProvinceModel prov) {
    final dir = prov.structuralDirectives;
    return _buildGlassCard(
      title: '🛡️ NDMA Earthquake Safety',
      children: [
        const Text('✅ DOs', style: TextStyle(color: Color(0xFF66BB6A), fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        ...dir.ndmaDos.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: Color(0xFF66BB6A), fontSize: 12)),
                  Expanded(child: Text(d, style: const TextStyle(color: Color(0xFFE6EDF3), fontSize: 12))),
                ],
              ),
            )),
        const SizedBox(height: 12),
        const Text('🚫 DON\'Ts', style: TextStyle(color: Color(0xFFEF5350), fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        ...dir.ndmaDonts.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: Color(0xFFEF5350), fontSize: 12)),
                  Expanded(child: Text(d, style: const TextStyle(color: Color(0xFFE6EDF3), fontSize: 12))),
                ],
              ),
            )),
      ],
    );
  }

  // ──────────────── Vernacular Bulletins ────────────────

  Widget _buildVernacularBulletinCard(SeismotectonicProvinceModel prov) {
    final alerts = prov.vernacularAlerts;
    final bulletinText = alerts[_selectedLangCode] ?? alerts['en'] ?? 'No bulletin available.';
    return _buildGlassCard(
      title: '📡 Multilingual Seismic Emergency Broadcast',
      children: [
        SizedBox(
          height: 32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _languages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final lang = _languages[index];
              final isSelected = lang['code'] == _selectedLangCode;
              return GestureDetector(
                onTap: () => setState(() => _selectedLangCode = lang['code']!),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF9A825) : const Color(0xFF21262D),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFF9A825) : const Color(0xFF30363D),
                    ),
                  ),
                  child: Text(lang['label']!, style: TextStyle(
                    color: isSelected ? Colors.black : const Color(0xFF8B949E),
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  )),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1117),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF30363D)),
          ),
          child: Text(bulletinText,
              style: const TextStyle(color: Color(0xFFE6EDF3), fontSize: 13, height: 1.5)),
        ),
      ],
    );
  }

  // ──────────────── Provenance Footer ────────────────

  Widget _buildProvenanceFooter() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📋 ${_data!.bulletinNumber}',
              style: const TextStyle(color: Color(0xFF8B949E), fontSize: 11)),
          const SizedBox(height: 4),
          Text(_data!.provenance,
              style: const TextStyle(color: Color(0xFF58A6FF), fontSize: 11)),
          const SizedBox(height: 4),
          Text(_data!.seismologicalModel,
              style: const TextStyle(color: Color(0xFF8B949E), fontSize: 10, fontStyle: FontStyle.italic)),
          const SizedBox(height: 4),
          Text('Synopsis: ${_data!.nationalSeismicitySynopsis}',
              style: const TextStyle(color: Color(0xFF8B949E), fontSize: 10)),
        ],
      ),
    );
  }

  // ──────────────── Shared Glass Card ────────────────

  Widget _buildGlassCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFFF9A825), fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: const TextStyle(color: Color(0xFF8B949E), fontSize: 12))),
          Expanded(flex: 3, child: Text(value, style: const TextStyle(color: Color(0xFFE6EDF3), fontSize: 12, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildMiniGauge(String label, double value, double max, {String suffix = '', Color color = const Color(0xFFFFA726)}) {
    final fraction = (value / max).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF8B949E), fontSize: 11))),
            Text('${value.toStringAsFixed(1)}$suffix', style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            backgroundColor: const Color(0xFF21262D),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
