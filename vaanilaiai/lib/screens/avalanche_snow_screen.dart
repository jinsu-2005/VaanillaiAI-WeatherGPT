import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../models/avalanche_snow_model.dart';
import '../providers/weather_provider.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class AvalancheSnowScreen extends StatefulWidget {
  final String? initialSectorId;
  final AvalancheSnowResponseModel? initialData;

  const AvalancheSnowScreen({
    super.key,
    this.initialSectorId,
    this.initialData,
  });

  @override
  State<AvalancheSnowScreen> createState() => _AvalancheSnowScreenState();
}

class _AvalancheSnowScreenState extends State<AvalancheSnowScreen> {
  final ApiService _apiService = ApiService();
  AvalancheSnowResponseModel? _data;
  bool _isLoading = true;
  String? _selectedSectorId;
  String _selectedLanguage = 'en';

  final List<Map<String, String>> _sectorsList = [
    {'id': 'gulmarg_pir_panjal', 'label': 'Gulmarg & Apharwat', 'state': 'J&K'},
    {'id': 'zojila_dras', 'label': 'Zoji La & Dras', 'state': 'Ladakh / J&K'},
    {'id': 'khardungla_leh', 'label': 'Khardung La', 'state': 'Ladakh'},
    {'id': 'rohtang_atal_tunnel', 'label': 'Rohtang & Atal Tunnel', 'state': 'HP'},
    {'id': 'solang_upper_beas', 'label': 'Solang Valley', 'state': 'HP'},
    {'id': 'kalpa_kinnaur_spiti', 'label': 'Kalpa & Spiti', 'state': 'HP'},
    {'id': 'kedarnath_mandakini', 'label': 'Kedarnath Sanctuary', 'state': 'Uttarakhand'},
    {'id': 'badrinath_mana_pass', 'label': 'Badrinath & Mana Pass', 'state': 'Uttarakhand'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _data = widget.initialData;
      _selectedSectorId = widget.initialSectorId ?? widget.initialData!.selectedSector.sectorId;
      _isLoading = false;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final weather = Provider.of<WeatherProvider>(context, listen: false);
        _fetchData(latitude: weather.latitude, longitude: weather.longitude);
      });
    }
  }

  Future<void> _fetchData({double? latitude, double? longitude, String? sectorId}) async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiService.getAvalancheSnowAssessment(
        latitude: latitude,
        longitude: longitude,
        sectorId: sectorId,
      );
      if (mounted) {
        setState(() {
          _data = res;
          _selectedSectorId = res.selectedSector.sectorId;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _data = AvalancheSnowResponseModel.defaultFallback();
          _selectedSectorId = _data!.selectedSector.sectorId;
          _isLoading = false;
        });
      }
    }
  }

  Color _getDangerColor(String level, bool isDark) {
    switch (level) {
      case 'LEVEL_1_LOW':
        return isDark ? const Color(0xFF22C55E) : const Color(0xFF16A34A);
      case 'LEVEL_2_YELLOW_MODERATE':
        return isDark ? const Color(0xFFEAB308) : const Color(0xFFCA8A04);
      case 'LEVEL_3_ORANGE_DANGER':
        return isDark ? const Color(0xFFF97316) : const Color(0xFFEA580C);
      case 'LEVEL_4_RED_HIGH_DANGER':
        return isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626);
      case 'LEVEL_5_BLACK_EXTREME':
        return isDark ? const Color(0xFF991B1B) : const Color(0xFF7F1D1D);
      default:
        return AppColors.brandBlue;
    }
  }

  Color _getPassStatusColor(String status, bool isDark) {
    switch (status) {
      case 'OPEN_NORMAL':
        return isDark ? const Color(0xFF22C55E) : const Color(0xFF16A34A);
      case 'CHAINS_MANDATORY':
      case 'CONVOY_TIMED_ONE_WAY':
        return isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706);
      case 'CLOSED_SNOW_CLEARING':
      case 'BLOCKED_AVALANCHE':
        return isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626);
      default:
        return AppColors.brandBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentBlue = isDark ? AppColors.brandBlueLight : AppColors.brandBlue;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Himalayan Snowpack & Avalanche',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            Text(
              'IMD Mountain Weather • DRDO DGRE',
              style: TextStyle(
                fontSize: 11,
                color: accentBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Telemetry',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _fetchData(sectorId: _selectedSectorId),
          ),
        ],
      ),
      body: _isLoading && _data == null
          ? Center(child: SpinKitPulse(color: accentBlue, size: 50))
          : RefreshIndicator(
              onRefresh: () => _fetchData(sectorId: _selectedSectorId),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOfflineCachedNotice(isDark),
                    _buildSectorSelector(isDark),
                    const SizedBox(height: 16),
                    if (_data != null) ...[
                      _buildHeroDangerCard(_data!.selectedSector, isDark),
                      const SizedBox(height: 16),
                      _buildWesternDisturbanceCard(_data!.westernDisturbance, isDark),
                      const SizedBox(height: 16),
                      _buildSnowpackPhysicsHud(_data!.selectedSector.snowpack, isDark),
                      const SizedBox(height: 16),
                      _buildMountainPassStatusCard(_data!.selectedSector.passStatus, isDark),
                      const SizedBox(height: 16),
                      _buildHighAltitudeSafetyCard(_data!.selectedSector.safety, isDark),
                      const SizedBox(height: 16),
                      _buildMultilingualBulletinCard(_data!.vernacularBulletins, isDark),
                      const SizedBox(height: 16),
                      _buildProvenanceFooter(_data!.dgreAdvisoryBulletinNo, _data!.provenance, isDark),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOfflineCachedNotice(bool isDark) {
    if (_data == null || !_data!.isOfflineCached) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.alertAmber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.alertAmber.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 16, color: AppColors.alertAmber),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Operating in offline high-altitude cache mode. Telemetry calibrated for mountain transit.',
              style: TextStyle(
                fontSize: 11.5,
                color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectorSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.terrain_rounded, size: 16, color: isDark ? AppColors.brandBlueLight : AppColors.brandBlue),
            const SizedBox(width: 6),
            Text(
              'Himalayan Monitoring Sectors',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryC(isDark),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _sectorsList.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final sec = _sectorsList[index];
              final isSelected = sec['id'] == _selectedSectorId;
              final accent = isDark ? AppColors.brandBlueLight : AppColors.brandBlue;

              return ChoiceChip(
                label: Text('${sec['label']} (${sec['state']})'),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    _fetchData(sectorId: sec['id']);
                  }
                },
                selectedColor: accent.withValues(alpha: 0.2),
                backgroundColor: AppColors.surface(isDark),
                side: BorderSide(
                  color: isSelected ? accent : AppColors.border(isDark),
                  width: isSelected ? 1.5 : 1,
                ),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? accent : AppColors.textSecondaryC(isDark),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeroDangerCard(HimalayanSectorModel sector, bool isDark) {
    final dangerColor = _getDangerColor(sector.dangerLevel, isDark);
    final surfaceColor = AppColors.surface(isDark);
    final textPrimary = AppColors.textPrimaryC(isDark);
    final textSecondary = AppColors.textSecondaryC(isDark);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dangerColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: dangerColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: dangerColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: dangerColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 16, color: dangerColor),
                    const SizedBox(width: 4),
                    Text(
                      sector.dangerLevel.replaceAll('_', ' '),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: dangerColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${sector.baseElevationM.toInt()}m - ${sector.peakElevationM.toInt()}m MSL',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            sector.sectorName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          Text(
            '${sector.mountainRange} • ${sector.stateOrUt}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: dangerColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: dangerColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shield_outlined, size: 18, color: dangerColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    sector.dangerRatingText,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.explore_rounded, size: 14, color: textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Critical Hazard Zone: ${sector.snowpack.aspectHazard}',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWesternDisturbanceCard(WesternDisturbanceModel wd, bool isDark) {
    final surfaceColor = AppColors.surface(isDark);
    final borderColor = AppColors.border(isDark);
    final textPrimary = AppColors.textPrimaryC(isDark);
    final textSecondary = AppColors.textSecondaryC(isDark);
    final accentBlue = isDark ? AppColors.brandBlueLight : AppColors.brandBlue;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cyclone_rounded, size: 18, color: accentBlue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Western Disturbance (WD) Synoptics',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.alertAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'WD ${wd.intensity}',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.alertAmber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            wd.synopticSummary,
            style: TextStyle(
              fontSize: 12,
              color: textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTelemetryCell(
                  'Jet Stream (200 hPa)',
                  '${wd.subtropicalJetSpeedKt.toStringAsFixed(0)} kt',
                  Icons.air_rounded,
                  AppColors.brandBlue,
                  isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTelemetryCell(
                  '500 hPa Trough',
                  '${wd.trough500hpaDepthDam.toStringAsFixed(0)} dam',
                  Icons.compress_rounded,
                  const Color(0xFF6366F1),
                  isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTelemetryCell(
                  'Freezing Isotherm',
                  '${wd.freezingLevelM.toStringAsFixed(0)} m',
                  Icons.ac_unit_rounded,
                  const Color(0xFF06B6D4),
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSnowpackPhysicsHud(SnowpackPhysicsModel snow, bool isDark) {
    final surfaceColor = AppColors.surface(isDark);
    final borderColor = AppColors.border(isDark);
    final textPrimary = AppColors.textPrimaryC(isDark);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.snowboarding_rounded, size: 18, color: Color(0xFF06B6D4)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cryospheric Snowpack Physics',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTelemetryCell(
                  '24h Fresh Snow',
                  '${snow.freshSnow24hCm.toStringAsFixed(0)} cm',
                  Icons.cloudy_snowing,
                  AppColors.brandBlue,
                  isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTelemetryCell(
                  'Total Snowpack',
                  '${snow.totalSnowpackDepthCm.toStringAsFixed(0)} cm',
                  Icons.layers_rounded,
                  const Color(0xFF6366F1),
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTelemetryCell(
                  'Snow Water Eq. (SWE)',
                  '${snow.snowWaterEquivalentMm.toStringAsFixed(0)} mm',
                  Icons.water_drop_rounded,
                  const Color(0xFF06B6D4),
                  isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTelemetryCell(
                  'Bulk Density',
                  '${snow.averageDensityKgM3.toStringAsFixed(0)} kg/m³',
                  Icons.fitness_center_rounded,
                  const Color(0xFFA855F7),
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.line_weight_rounded, size: 16, color: AppColors.alertOrange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Critical Weak Plane: ${snow.primaryWeakLayer.replaceAll('_', ' ')} at ${snow.weakLayerDepthCm.toStringAsFixed(0)}cm depth (${snow.criticalSlopeAngleDeg.toStringAsFixed(0)}° slope).',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
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

  Widget _buildMountainPassStatusCard(MountainPassStatusModel pass, bool isDark) {
    final statusColor = _getPassStatusColor(pass.status, isDark);
    final surfaceColor = AppColors.surface(isDark);
    final borderColor = AppColors.border(isDark);
    final textPrimary = AppColors.textPrimaryC(isDark);
    final textSecondary = AppColors.textSecondaryC(isDark);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.commute_rounded, size: 18, color: AppColors.brandBlue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'BRO Mountain Pass Transit Corridor',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  pass.status.replaceAll('_', ' '),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${pass.passName} (${pass.altitudeFt} ft / ${pass.altitudeM.toInt()}m)',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          Text(
            pass.highwayCode,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            pass.broOperationalStatus,
            style: TextStyle(
              fontSize: 12,
              color: textPrimary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              if (pass.chainsRequired)
                Chip(
                  avatar: const Icon(Icons.link_rounded, size: 14, color: AppColors.alertOrange),
                  label: const Text('Metallic Chains Mandatory'),
                  backgroundColor: AppColors.alertOrange.withValues(alpha: 0.1),
                  labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.alertOrange),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ...pass.broEquipmentDeployed.map(
                (eq) => Chip(
                  avatar: const Icon(Icons.build_circle_outlined, size: 14),
                  label: Text(eq),
                  backgroundColor: surfaceColor,
                  side: BorderSide(color: borderColor),
                  labelStyle: TextStyle(fontSize: 11, color: textSecondary),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHighAltitudeSafetyCard(HighAltitudeSafetyModel safety, bool isDark) {
    final surfaceColor = AppColors.surface(isDark);
    final borderColor = AppColors.border(isDark);
    final textPrimary = AppColors.textPrimaryC(isDark);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medical_services_outlined, size: 18, color: AppColors.alertGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'High-Altitude Pilgrim & Backcountry Safety',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildSafetyBadge('AMS Risk', safety.amsRisk, Icons.landscape_rounded, isDark),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSafetyBadge('Hypothermia', safety.hypothermiaRisk, Icons.severe_cold_rounded, isDark),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (safety.bpsGearMandatory)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.alertAmber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.alertAmber.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.backpack_rounded, size: 16, color: AppColors.alertAmber),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'BPS Mandatory: Avalanche Transceiver (Beacon), Probe, and Snow Shovel required.',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.alertAmber),
                    ),
                  ),
                ],
              ),
            ),
          Text(
            safety.travelAdvisory,
            style: TextStyle(
              fontSize: 12,
              color: textPrimary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.phone_in_talk_rounded, size: 14, color: AppColors.alertGreen),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Helpline: ${safety.emergencyHelpline}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.alertGreen,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyBadge(String title, String value, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.textSecondaryC(isDark)),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(fontSize: 10.5, color: AppColors.textSecondaryC(isDark), fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryC(isDark),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMultilingualBulletinCard(Map<String, String> bulletins, bool isDark) {
    final surfaceColor = AppColors.surface(isDark);
    final borderColor = AppColors.border(isDark);
    final textPrimary = AppColors.textPrimaryC(isDark);
    final accentBlue = isDark ? AppColors.brandBlueLight : AppColors.brandBlue;

    final languages = [
      {'code': 'en', 'label': 'English'},
      {'code': 'hi', 'label': 'हिंदी'},
      {'code': 'ur', 'label': 'اردو'},
      {'code': 'pa', 'label': 'ਪੰਜਾਬੀ'},
      {'code': 'bn', 'label': 'বাংলা'},
    ];

    final activeText = bulletins[_selectedLanguage] ?? bulletins['en'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.translate_rounded, size: 18, color: accentBlue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Emergency Avalanche Bulletin',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            children: languages.map((lang) {
              final isSel = lang['code'] == _selectedLanguage;
              return ChoiceChip(
                label: Text(lang['label']!),
                selected: isSel,
                onSelected: (val) {
                  if (val) setState(() => _selectedLanguage = lang['code']!);
                },
                selectedColor: accentBlue.withValues(alpha: 0.2),
                backgroundColor: surfaceColor,
                side: BorderSide(color: isSel ? accentBlue : borderColor),
                labelStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                  color: isSel ? accentBlue : AppColors.textSecondaryC(isDark),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              activeText,
              style: TextStyle(
                fontSize: 12.5,
                color: textPrimary,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProvenanceFooter(String bulletinNo, String provenance, bool isDark) {
    final textTertiary = AppColors.textTertiaryC(isDark);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_user_rounded, size: 14, color: textTertiary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                bulletinNo,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textTertiary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          provenance,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10.5, color: textTertiary),
        ),
      ],
    );
  }

  Widget _buildTelemetryCell(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 10, color: AppColors.textSecondaryC(isDark), fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimaryC(isDark)),
          ),
        ],
      ),
    );
  }
}
