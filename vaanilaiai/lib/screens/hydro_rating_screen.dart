import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/hydro_rating_model.dart';
import '../services/api_service.dart';

class HydroRatingScreen extends StatefulWidget {
  final HydroRatingResponseModel? initialData;

  const HydroRatingScreen({super.key, this.initialData});

  @override
  State<HydroRatingScreen> createState() => _HydroRatingScreenState();
}

class _HydroRatingScreenState extends State<HydroRatingScreen> {
  final ApiService _apiService = ApiService();
  HydroRatingResponseModel? _data;
  bool _isLoading = false;
  String _selectedBasinId = 'kosi_baltara';
  String _selectedLanguage = 'EN';

  static const Map<String, String> _languageNames = {
    'EN': 'English',
    'HI': 'हिन्दी',
    'AS': 'অসমীয়া',
    'BN': 'বাংলা',
    'OD': 'ଓଡ଼ିଆ',
    'TE': 'తెలుగు',
    'GU': 'ગુજરાતી',
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _data = widget.initialData;
      _selectedBasinId = widget.initialData!.activeStation.stationId;
    } else {
      _loadData();
    }
  }

  Future<void> _loadData({String? basinId}) async {
    setState(() => _isLoading = true);
    final targetBasin = basinId ?? _selectedBasinId;
    final assessment = await _apiService.getHydroRatingAssessment(basinId: targetBasin);
    if (mounted) {
      setState(() {
        _data = assessment;
        _selectedBasinId = targetBasin;
        _isLoading = false;
      });
    }
  }

  Color _getFloodStageColor(String tier) {
    switch (tier.toUpperCase()) {
      case 'UNPRECEDENTED_FLOOD':
        return const Color(0xFF7C3AED); // Purple
      case 'DANGER_STAGE':
        return const Color(0xFFDC2626); // Red
      case 'WARNING_STAGE':
        return const Color(0xFFD97706); // Amber
      case 'ABOVE_NORMAL':
        return const Color(0xFF2563EB); // Blue
      case 'NORMAL_FLOW':
      default:
        return const Color(0xFF059669); // Green
    }
  }

  Color _getPipingRiskColor(String tier) {
    switch (tier.toUpperCase()) {
      case 'IMMINENT_COLLAPSE_BREACH':
        return const Color(0xFFDC2626);
      case 'HIGH_SANDBOIL_RISK':
        return const Color(0xFFEA580C);
      case 'PIPING_WATCH':
        return const Color(0xFFD97706);
      case 'SAFE_STABLE':
      default:
        return const Color(0xFF059669);
    }
  }

  Color _getFreeboardColor(String tier) {
    switch (tier.toUpperCase()) {
      case 'CREST_OVERTOPPING_BREACH':
        return const Color(0xFFDC2626);
      case 'OVERTOPPING_THREAT':
        return const Color(0xFFEA580C);
      case 'REDUCED_MARGIN':
        return const Color(0xFFD97706);
      case 'OPTIMAL_FREEBOARD':
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
        title: const Text('CWC Flood & Rating Curve Telemetry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Telemetry',
            onPressed: _isLoading ? null : () => _loadData(basinId: _selectedBasinId),
          ),
        ],
      ),
      body: _isLoading && data == null
          ? const Center(child: CircularProgressIndicator())
          : data == null
              ? const Center(child: Text('Hydrological data unavailable.'))
              : RefreshIndicator(
                  onRefresh: () => _loadData(basinId: _selectedBasinId),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (data.isOfflineCached) _buildOfflineBadge(isDark),
                        _buildBasinSelectorChips(data, isDark),
                        const SizedBox(height: 14),
                        _buildHeroFloodStageCard(data.activeStation, isDark),
                        const SizedBox(height: 14),
                        _buildBenchmarksHud(data.activeStation, isDark),
                        const SizedBox(height: 14),
                        _buildRatingCurveManningCard(data.activeStation, isDark),
                        const SizedBox(height: 14),
                        _buildEmbankmentPipingCard(data.activeStation, isDark),
                        const SizedBox(height: 14),
                        _buildGumbelFrequencyCard(data.activeStation, isDark),
                        const SizedBox(height: 14),
                        _buildDirectivesCard(data.activeStation, isDark),
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
              'Showing calibrated offline baseline or cached telemetry.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasinSelectorChips(HydroRatingResponseModel data, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: data.allStations.map((station) {
          final isSelected = station.stationId == _selectedBasinId;
          final stageColor = _getFloodStageColor(station.floodStageTier);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              showCheckmark: false,
              avatar: CircleAvatar(
                backgroundColor: stageColor,
                radius: 5,
              ),
              label: Text(
                '${station.riverName} (${station.stateName})',
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
                color: isSelected ? stageColor : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                width: isSelected ? 1.6 : 1.0,
              ),
              onSelected: (selected) {
                if (selected && station.stationId != _selectedBasinId) {
                  _loadData(basinId: station.stationId);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeroFloodStageCard(RiverBasinHydroStationModel station, bool isDark) {
    final stageColor = _getFloodStageColor(station.floodStageTier);
    final stageM = station.ratingCurve.stageHeightM;
    final dangerM = station.benchmarks.dangerLevelM;
    final hflM = station.benchmarks.highestFloodLevelHflM;
    final diffDanger = (stageM - dangerM);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: stageColor.withValues(alpha: 0.45), width: 1.5),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: stageColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: stageColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flood_rounded, size: 16, color: stageColor),
                      const SizedBox(width: 6),
                      Text(
                        _formatTierTitle(station.floodStageTier),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: stageColor),
                      ),
                    ],
                  ),
                ),
                Text(
                  station.cwcDivision,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${station.stationName} – ${station.riverName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            Text(
              '${station.stateName} • Lat: ${station.latitude}°N, Lon: ${station.longitude}°E',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
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
                  _buildMetricCol('Current Stage', '${stageM.toStringAsFixed(2)} m', stageColor),
                  _buildMetricCol('Danger Level', '${dangerM.toStringAsFixed(2)} m', const Color(0xFFDC2626)),
                  _buildMetricCol('HFL Record', '${hflM.toStringAsFixed(2)} m', const Color(0xFF7C3AED)),
                  _buildMetricCol(
                    'Diff Danger',
                    '${diffDanger >= 0 ? '+' : ''}${diffDanger.toStringAsFixed(2)} m',
                    diffDanger >= 0 ? const Color(0xFFDC2626) : const Color(0xFF059669),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: stageColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: stageColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: stageColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Action Required: ${_formatTierTitle(station.directives.evacuationUrgencyLevel)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: stageColor,
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
          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: color),
        ),
      ],
    );
  }

  Widget _buildBenchmarksHud(RiverBasinHydroStationModel station, bool isDark) {
    final b = station.benchmarks;
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
                Icon(Icons.straighten_rounded, size: 18, color: Color(0xFF0284C7)),
                SizedBox(width: 8),
                Text(
                  'CWC Flood Benchmark Elevations (m MSL)',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildBenchmarkTile('Zero Datum', '${b.zeroFlowDatumM}m', const Color(0xFF64748B), isDark),
                const SizedBox(width: 6),
                _buildBenchmarkTile('Warning', '${b.warningLevelM}m', const Color(0xFFD97706), isDark),
                const SizedBox(width: 6),
                _buildBenchmarkTile('Danger', '${b.dangerLevelM}m', const Color(0xFFDC2626), isDark),
                const SizedBox(width: 6),
                _buildBenchmarkTile('HFL (${b.hflRecordYear})', '${b.highestFloodLevelHflM}m', const Color(0xFF7C3AED), isDark),
                const SizedBox(width: 6),
                _buildBenchmarkTile('Crest Wall', '${b.embankmentCrestM}m', const Color(0xFF059669), isDark),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenchmarkTile(String title, String val, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              val,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingCurveManningCard(RiverBasinHydroStationModel station, bool isDark) {
    final rc = station.ratingCurve;

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.water_rounded, size: 18, color: Color(0xFF0284C7)),
                    SizedBox(width: 8),
                    Text(
                      'Hydrological Rating Curve & Manning Conveyance',
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Rating Equation: Q = ${rc.ratingCoefficientA} × (h - ${rc.zeroFlowDatumH0M})^${rc.hydraulicExponentB}',
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
                  _buildDataField('Discharge (Q)', '${rc.computedDischargeCumecs} cumecs', Icons.speed_rounded),
                  _buildDataField('Mean Velocity', '${rc.meanFlowVelocityMps} m/s', Icons.air_rounded),
                  _buildDataField('Effective Head', '${rc.effectiveHeadM} m', Icons.height_rounded),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSubDataField('Flow Area A', '${rc.wettedCrossSectionAreaM2} m²'),
                _buildSubDataField('Hydraulic Radius Rh', '${rc.hydraulicRadiusM} m'),
                _buildSubDataField("Manning's n", '${rc.manningRoughnessN}'),
                _buildSubDataField('Energy Slope S₀', '${rc.channelEnergySlope}'),
              ],
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

  Widget _buildEmbankmentPipingCard(RiverBasinHydroStationModel station, bool isDark) {
    final emb = station.embankmentSafety;
    final fbColor = _getFreeboardColor(emb.freeboardTier);
    final pipingColor = _getPipingRiskColor(emb.pipingRiskTier);

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
                Icon(Icons.shield_rounded, size: 18, color: Color(0xFFEA580C)),
                SizedBox(width: 8),
                Text(
                  'Embankment Structural Safety & Piping Stability',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: fbColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: fbColor.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Net Freeboard Margin', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        const SizedBox(height: 2),
                        Text(
                          '${emb.freeboardMarginM} meters',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: fbColor),
                        ),
                        Text(_formatTierTitle(emb.freeboardTier), style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: fbColor)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: pipingColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: pipingColor.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Piping Safety Factor (FS)', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        const SizedBox(height: 2),
                        Text(
                          '${emb.pipingFactorOfSafety} (icrit/i)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: pipingColor),
                        ),
                        Text(_formatTierTitle(emb.pipingRiskTier), style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: pipingColor)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSubDataField('Crest Elevation', '${emb.embankmentCrestLevelM}m'),
                _buildSubDataField('Toe Elevation', '${emb.countrysideToeLevelM}m'),
                _buildSubDataField('Exit Gradient (i)', '${emb.exitHydraulicGradient}'),
                _buildSubDataField('Sand Boils', emb.sandBoilDetected ? 'DETECTED' : 'None Reported'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGumbelFrequencyCard(RiverBasinHydroStationModel station, bool isDark) {
    final g = station.gumbelFrequency;
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
                Icon(Icons.timeline_rounded, size: 18, color: Color(0xFF0284C7)),
                SizedBox(width: 8),
                Text(
                  'Gumbel Flood Frequency (Return Period T)',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildGumbelTile('10-Year (Q₁₀)', '${g.discharge10yrCumecs.toInt()}', isDark),
                const SizedBox(width: 6),
                _buildGumbelTile('25-Year (Q₂₅)', '${g.discharge25yrCumecs.toInt()}', isDark),
                const SizedBox(width: 6),
                _buildGumbelTile('50-Year (Q₅₀)', '${g.discharge50yrCumecs.toInt()}', isDark),
                const SizedBox(width: 6),
                _buildGumbelTile('100-Year (Q₁₀₀)', '${g.discharge100yrCumecs.toInt()}', isDark),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Estimated Recurrence: ${_formatTierTitle(g.currentReturnPeriod)} (Annual Exceedance Prob: ${g.annualExceedanceProbabilityPct}%)',
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF0284C7)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGumbelTile(String label, String value, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B))),
            const SizedBox(height: 2),
            Text(
              '$value c',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectivesCard(RiverBasinHydroStationModel station, bool isDark) {
    final d = station.directives;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFDC2626), width: 1.2),
      ),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.campaign_rounded, size: 20, color: Color(0xFFDC2626)),
                SizedBox(width: 8),
                Text(
                  'NDMA & CWC Riparian Protection Directives',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildDirectiveRow(Icons.directions_run_rounded, 'Evacuation Protocol', d.riparianSafetyProtocol),
            const Divider(height: 16),
            _buildDirectiveRow(Icons.remove_red_eye_rounded, 'Embankment Vigil', d.embankmentPatrolFrequency),
            const Divider(height: 16),
            _buildDirectiveRow(Icons.construction_rounded, 'Piping Countermeasure', d.pipingCountermeasureDirective),
            const Divider(height: 16),
            _buildDirectiveRow(Icons.water_drop_rounded, 'Water & Sanitation', d.drinkingWaterSanitationAdvisory),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectiveRow(IconData icon, String title, String detail) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFFDC2626)),
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

  Widget _buildVernacularBulletinSection(HydroRatingResponseModel data, bool isDark) {
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
                  'Riparian Emergency Vernacular Bulletin',
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
                    const SnackBar(content: Text('Vernacular bulletin copied to clipboard.')),
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
            'Calibrated Open-Channel Hydraulics & NDMA Flood SOPs',
            style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}
