import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/saltwater_intrusion_model.dart';
import '../services/api_service.dart';

class SaltwaterIntrusionScreen extends StatefulWidget {
  final SaltwaterIntrusionResponseModel? initialData;

  const SaltwaterIntrusionScreen({super.key, this.initialData});

  @override
  State<SaltwaterIntrusionScreen> createState() => _SaltwaterIntrusionScreenState();
}

class _SaltwaterIntrusionScreenState extends State<SaltwaterIntrusionScreen> {
  final ApiService _apiService = ApiService();
  SaltwaterIntrusionResponseModel? _data;
  bool _isLoading = false;
  String _selectedZoneId = 'sundarbans_delta';
  String _selectedLanguage = 'EN';

  static const Map<String, String> _languageNames = {
    'EN': 'English',
    'HI': 'हिन्दी',
    'BN': 'বাংলা',
    'TA': 'தமிழ்',
    'TE': 'తెలుగు',
    'ML': 'മലയാളം',
    'GU': 'ગુજરાતી',
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _data = widget.initialData;
      _selectedZoneId = widget.initialData!.activeZone.zoneId;
    } else {
      _loadData();
    }
  }

  Future<void> _loadData({String? zoneId}) async {
    setState(() => _isLoading = true);
    final targetZone = zoneId ?? _selectedZoneId;
    final assessment = await _apiService.getSaltwaterIntrusionAssessment(zoneId: targetZone);
    if (mounted) {
      setState(() {
        _data = assessment;
        _selectedZoneId = targetZone;
        _isLoading = false;
      });
    }
  }

  Color _getSalinitySeverityColor(String tier) {
    switch (tier.toUpperCase()) {
      case 'HYPERSALINE_SEAWATER_INCURSION':
        return const Color(0xFF7C3AED); // Purple
      case 'SEVERE_SALINE_CONTAMINATION':
        return const Color(0xFFDC2626); // Red
      case 'MODERATE_BRACKISH_INGRESS':
        return const Color(0xFFEA580C); // Orange
      case 'SLIGHT_SALINE_STRESS':
        return const Color(0xFF0284C7); // Light Blue
      case 'NORMAL_FRESHWATER':
      default:
        return const Color(0xFF059669); // Green
    }
  }

  Color _getAquiferVulnerabilityColor(String tier) {
    switch (tier.toUpperCase()) {
      case 'CRITICAL_AQUIFER_CONTAMINATION':
        return const Color(0xFFDC2626);
      case 'ACTIVE_SALINE_UPCONING':
        return const Color(0xFFEA580C);
      case 'VULNERABLE_THINNING':
        return const Color(0xFFD97706);
      case 'SAFE_CONFINED_LENS':
      default:
        return const Color(0xFF059669);
    }
  }

  String _formatTierTitle(String tier) {
    return tier.replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final data = _data;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coastal Saline Intrusion & Aquifers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Salinity Telemetry',
            onPressed: _isLoading ? null : () => _loadData(zoneId: _selectedZoneId),
          ),
        ],
      ),
      body: _isLoading && data == null
          ? const Center(child: CircularProgressIndicator())
          : data == null
              ? const Center(child: Text('Coastal salinity data unavailable.'))
              : RefreshIndicator(
                  onRefresh: () => _loadData(zoneId: _selectedZoneId),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (data.isOfflineCached) _buildOfflineBadge(isDark),
                        _buildZoneSelectorChips(data, isDark),
                        const SizedBox(height: 14),
                        _buildHeroSalinityCard(data.activeZone, isDark),
                        const SizedBox(height: 14),
                        _buildGhybenHerzbergHud(data.activeZone, isDark),
                        const SizedBox(height: 14),
                        _buildEstuarineWedgeCard(data.activeZone, isDark),
                        const SizedBox(height: 14),
                        _buildGroundwaterMineralizationCard(data.activeZone, isDark),
                        const SizedBox(height: 14),
                        _buildDirectivesCard(data.activeZone, isDark),
                        const SizedBox(height: 14),
                        _buildVernacularBulletinSection(data, isDark),
                        const SizedBox(height: 20),
                        _buildProvenanceFooter(data.dataSource, isDark),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildOfflineBadge(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF94A3B8)),
      ),
      child: const Row(
        children: [
          Icon(Icons.cloud_off_rounded, size: 18, color: Color(0xFF64748B)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Showing calibrated offline baseline or cached coastal telemetry.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneSelectorChips(SaltwaterIntrusionResponseModel data, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: data.allZones.map((zone) {
          final isSelected = zone.zoneId == _selectedZoneId;
          final color = _getSalinitySeverityColor(zone.salinitySeverity);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              showCheckmark: false,
              avatar: CircleAvatar(
                backgroundColor: color,
                radius: 5,
              ),
              label: Text(
                '${zone.zoneName} (${zone.stateName})',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? (isDark ? Colors.white : Colors.black87)
                      : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                ),
              ),
              selectedColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              side: BorderSide(
                color: isSelected ? color : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                width: isSelected ? 1.6 : 1.0,
              ),
              onSelected: (selected) {
                if (selected && zone.zoneId != _selectedZoneId) {
                  _loadData(zoneId: zone.zoneId);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeroSalinityCard(CoastalEstuarineZoneModel zone, bool isDark) {
    final severityColor = _getSalinitySeverityColor(zone.salinitySeverity);
    final wedge = zone.estuarineWedge;
    final aq = zone.aquiferMetrics;
    final d = zone.directives;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: severityColor.withValues(alpha: 0.45), width: 1.5),
      ),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: severityColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: severityColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.water_rounded, size: 16, color: severityColor),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            _formatTierTitle(zone.salinitySeverity),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: severityColor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: d.sluiceFlapGateStatus == 'CLOSED'
                        ? const Color(0xFFDC2626).withValues(alpha: 0.15)
                        : const Color(0xFF059669).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: d.sluiceFlapGateStatus == 'CLOSED' ? const Color(0xFFDC2626) : const Color(0xFF059669),
                    ),
                  ),
                  child: Text(
                    'Sluice Gate: ${d.sluiceFlapGateStatus}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: d.sluiceFlapGateStatus == 'CLOSED' ? const Color(0xFFDC2626) : const Color(0xFF059669),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              zone.zoneName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            Text(
              '${zone.coastalDistrict}, ${zone.stateName} • ${zone.coastalBodyType}',
              style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricCol('Saline Wedge', '${wedge.salineWedgeLengthKm} km', const Color(0xFF0284C7)),
                  _buildMetricCol('Groundwater EC', '${aq.electricalConductivityUsCm.toInt()} µS', severityColor),
                  _buildMetricCol('Surface Salinity', '${wedge.surfaceSalinityPpt} ppt', const Color(0xFFEA580C)),
                  _buildMetricCol(
                    'Piezometric Head',
                    '${aq.freshwaterPiezometricHeadMMsl >= 0 ? '+' : ''}${aq.freshwaterPiezometricHeadMMsl.toStringAsFixed(2)} m',
                    aq.freshwaterPiezometricHeadMMsl >= 0 ? const Color(0xFF059669) : const Color(0xFFDC2626),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: severityColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: severityColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule_rounded, color: severityColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pumping Cap: Max ${d.borewellPumpingLimitHours} hrs/day | ${d.sluiceClosureTimingNotice}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: severityColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color),
        ),
      ],
    );
  }

  Widget _buildGhybenHerzbergHud(CoastalEstuarineZoneModel zone, bool isDark) {
    final aq = zone.aquiferMetrics;
    final aqColor = _getAquiferVulnerabilityColor(aq.aquiferVulnerabilityTier);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.layers_rounded, size: 18, color: Color(0xFF0284C7)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ghyben-Herzberg Coastal Freshwater Lens',
                          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: aqColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _formatTierTitle(aq.aquiferVulnerabilityTier),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: aqColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Hydrostatic Principle: z = 40 × hf (Each meter of head supports ~40m fresh lens depth)',
              style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildLensTile('Head (hf)', '${aq.freshwaterPiezometricHeadMMsl.toStringAsFixed(2)}m MSL', isDark),
                const SizedBox(width: 6),
                _buildLensTile('Theoretical Lens (z)', '${aq.theoreticalFreshwaterLensDepthM}m', isDark),
                const SizedBox(width: 6),
                _buildLensTile('Measured Interface', '${aq.measuredSalineInterfaceDepthM}m BGL', isDark),
                const SizedBox(width: 6),
                _buildLensTile('Upconing Rise', '${aq.salineUpconingVelocityCmWeek} cm/wk', isDark),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLensTile(String label, String value, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstuarineWedgeCard(CoastalEstuarineZoneModel zone, bool isDark) {
    final w = zone.estuarineWedge;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.waves_rounded, size: 18, color: Color(0xFF0284C7)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Two-Layer Estuarine Saline Wedge Hydrodynamics',
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Estuary: ${w.estuaryName} • Distance to Sea: ${w.riverMouthDistanceKm} km',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0284C7)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDataField('Inland Wedge Reach', '${w.salineWedgeLengthKm} km', Icons.directions_boat_rounded),
                  _buildDataField('Freshwater Q', '${w.upstreamFreshwaterDischargeCumecs} m³/s', Icons.water_damage_rounded),
                  _buildDataField('Tidal Range', '${w.astronomicalTidalRangeM} m', Icons.height_rounded),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSubDataField('Froude (F₀)', '${w.densimetricFroudeNumber}'),
                _buildSubDataField('Depth (H₀)', '${w.estuaryChannelDepthM}m'),
                _buildSubDataField('Surface Salinity', '${w.surfaceSalinityPpt} ppt'),
                _buildSubDataField('Bottom Bed Salinity', '${w.bottomBedSalinityPpt} ppt'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tidal Phase: ${_formatTierTitle(w.tidalPrismPhase)} (Prism: ${w.tidalPrismVolumeMillionM3} million m³)',
              style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: const Color(0xFF64748B)),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
          ],
        ),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildSubDataField(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildGroundwaterMineralizationCard(CoastalEstuarineZoneModel zone, bool isDark) {
    final aq = zone.aquiferMetrics;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.science_rounded, size: 18, color: Color(0xFFEA580C)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Groundwater Mineralization & Sodicity (WHO/BIS Standards)',
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildMineralTile('Electrical Cond.', '${aq.electricalConductivityUsCm.toInt()} µS/cm', isDark),
                const SizedBox(width: 6),
                _buildMineralTile('TDS', '${aq.totalDissolvedSolidsMgL.toInt()} mg/L', isDark),
                const SizedBox(width: 6),
                _buildMineralTile('SAR (Sodicity)', '${aq.sodiumAdsorptionRatioSar}', isDark),
                const SizedBox(width: 6),
                _buildMineralTile('Chloride (Cl⁻)', '${aq.chlorideConcentrationMgL.toInt()} mg/L', isDark),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Potability Reference: BIS 10500 Chloride Limit is 250 mg/L (Max 1000 mg/L). EC > 1500 indicates brackish ingress.',
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMineralTile(String label, String value, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectivesCard(CoastalEstuarineZoneModel zone, bool isDark) {
    final d = zone.directives;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFF0284C7), width: 1.2),
      ),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.agriculture_rounded, size: 20, color: Color(0xFF0284C7)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ICAR-CSSRI Agricultural & Sluice Gate Directives',
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildDirectiveRow(Icons.lock_clock_rounded, 'Tidal Sluice Operation', d.sluiceClosureTimingNotice),
            const Divider(height: 16),
            _buildDirectiveRow(Icons.grass_rounded, 'Halophytic Crop Strains', d.recommendedSaltTolerantCrops.join(', ')),
            const Divider(height: 16),
            _buildDirectiveRow(Icons.landscape_rounded, 'Gypsum Soil Amendment', 'Apply ${d.gypsumAmendmentDosageTonsHa} tons/ha to displace exchangeable Na⁺ and restore soil flocculation.'),
            const Divider(height: 16),
            _buildDirectiveRow(Icons.local_drink_rounded, 'Desalination & Intakes', d.potableRoMembraneAlert),
            const Divider(height: 16),
            _buildDirectiveRow(Icons.water_drop_rounded, 'Irrigation Guidance', d.irrigationSuitabilityAdvice),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectiveRow(IconData icon, String title, String detail) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF0284C7)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(detail, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVernacularBulletinSection(SaltwaterIntrusionResponseModel data, bool isDark) {
    final bulletinText = data.vernacularBulletins[_selectedLanguage] ?? data.vernacularBulletins['EN'] ?? '';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.translate_rounded, size: 18, color: Color(0xFF0284C7)),
                SizedBox(width: 8),
                Text(
                  'Coastal Riparian Vernacular Bulletin',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _languageNames.entries.map((entry) {
                  final isSelected = entry.key == _selectedLanguage;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFF0284C7),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedLanguage = entry.key);
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
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: SelectableText(
                bulletinText,
                style: const TextStyle(fontSize: 13, height: 1.45, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.copy_rounded, size: 15),
                label: const Text('Copy Bulletin', style: TextStyle(fontSize: 12)),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: bulletinText));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coastal salinity bulletin copied to clipboard.')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProvenanceFooter(String dataSource, bool isDark) {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.verified_user_rounded, size: 20, color: Color(0xFF0284C7)),
          const SizedBox(height: 4),
          Text(
            dataSource,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Ghyben-Herzberg Equilibrium & ICAR-CSSRI Soil Defense',
            style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}
