import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../models/convective_storm_model.dart';
import '../providers/weather_provider.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class ConvectiveStormScreen extends StatefulWidget {
  final String? initialHotspotId;
  final ConvectiveStormResponseModel? initialData;

  const ConvectiveStormScreen({
    super.key,
    this.initialHotspotId,
    this.initialData,
  });

  @override
  State<ConvectiveStormScreen> createState() => _ConvectiveStormScreenState();
}

class _ConvectiveStormScreenState extends State<ConvectiveStormScreen> {
  final ApiService _apiService = ApiService();
  ConvectiveStormResponseModel? _data;
  bool _isLoading = true;
  String? _selectedHotspotId;
  String _selectedLanguage = 'en';

  final List<Map<String, String>> _hotspotsList = [
    {'id': 'kolkata_gangetic_wb', 'label': 'Kolkata & Gangetic WB', 'phenom': 'Kalbaishakhi'},
    {'id': 'bhubaneswar_coastal_odisha', 'label': 'Bhubaneswar & Coastal Odisha', 'phenom': 'Nor\'wester'},
    {'id': 'guwahati_brahmaputra', 'label': 'Guwahati & Brahmaputra', 'phenom': 'Bordoichila'},
    {'id': 'bikaner_thar_desert', 'label': 'Bikaner & Thar Desert', 'phenom': 'Haboob Dust Wall'},
    {'id': 'hisar_south_haryana', 'label': 'Hisar & South Haryana', 'phenom': 'Andhi Squall'},
    {'id': 'delhi_ncr_convective', 'label': 'Delhi-NCR Hub', 'phenom': 'Gust Front Microburst'},
    {'id': 'patna_middle_ganga', 'label': 'Patna & Middle Ganga', 'phenom': 'Hailstorm'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _data = widget.initialData;
      _selectedHotspotId = widget.initialHotspotId ?? widget.initialData!.selectedHotspot.hotspotId;
      _isLoading = false;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final weather = Provider.of<WeatherProvider>(context, listen: false);
        _fetchData(latitude: weather.latitude, longitude: weather.longitude);
      });
    }
  }

  Future<void> _fetchData({double? latitude, double? longitude, String? hotspotId}) async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiService.getConvectiveStormAssessment(
        latitude: latitude,
        longitude: longitude,
        hotspotId: hotspotId,
      );
      if (mounted) {
        setState(() {
          _data = res;
          _selectedHotspotId = res.selectedHotspot.hotspotId;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _data = ConvectiveStormResponseModel.defaultFallback();
          _selectedHotspotId = _data!.selectedHotspot.hotspotId;
          _isLoading = false;
        });
      }
    }
  }

  Color _getWarningStageColor(String stage, bool isDark) {
    switch (stage) {
      case 'STAGE_4_RED_SEVERE_WARNING':
        return isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626);
      case 'STAGE_3_ORANGE_WARNING':
        return isDark ? const Color(0xFFF97316) : const Color(0xFFEA580C);
      case 'STAGE_2_YELLOW_ALERT':
        return isDark ? const Color(0xFFEAB308) : const Color(0xFFCA8A04);
      case 'STAGE_1_GREEN_WATCH':
      default:
        return isDark ? const Color(0xFF22C55E) : const Color(0xFF16A34A);
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
              'Severe Storm & Haboob Warning',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            Text(
              'Kalbaishakhi • Haboob • Squall Nowcast',
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
            tooltip: 'Refresh Convective Telemetry',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _fetchData(hotspotId: _selectedHotspotId),
          ),
        ],
      ),
      body: _isLoading && _data == null
          ? Center(child: SpinKitPulse(color: accentBlue, size: 50))
          : RefreshIndicator(
              onRefresh: () => _fetchData(hotspotId: _selectedHotspotId),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOfflineCachedNotice(isDark),
                    _buildHotspotSelector(isDark),
                    const SizedBox(height: 16),
                    if (_data != null) ...[
                      _buildHeroWarningCard(_data!.selectedHotspot, isDark),
                      const SizedBox(height: 16),
                      _buildThermodynamicHud(_data!.selectedHotspot.thermodynamics, isDark),
                      const SizedBox(height: 16),
                      _buildDensityCurrentCard(_data!.selectedHotspot.densityCurrent, isDark),
                      const SizedBox(height: 16),
                      _buildAviationGridCard(_data!.selectedHotspot.aviationGrid, isDark),
                      const SizedBox(height: 16),
                      _buildMultilingualBulletinCard(_data!.vernacularBulletins, isDark),
                      const SizedBox(height: 16),
                      _buildProvenanceFooter(_data!.imdBulletinReference, _data!.provenance, isDark),
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
              'Operating in offline nowcast mode. Showing calibrated pre-monsoon convective storm baseline.',
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

  Widget _buildHotspotSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.radar_rounded, size: 16, color: isDark ? AppColors.brandBlueLight : AppColors.brandBlue),
            const SizedBox(width: 6),
            Text(
              'Severe Convective Monitoring Hubs',
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
            itemCount: _hotspotsList.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final item = _hotspotsList[index];
              final isSelected = item['id'] == _selectedHotspotId;
              final accent = isDark ? AppColors.brandBlueLight : AppColors.brandBlue;

              return ChoiceChip(
                label: Text('${item['label']} • ${item['phenom']}'),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    _fetchData(hotspotId: item['id']);
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

  Widget _buildHeroWarningCard(ConvectiveStormHotspotModel spot, bool isDark) {
    final stageColor = _getWarningStageColor(spot.warningStage, isDark);
    final surfaceColor = AppColors.surface(isDark);
    final textPrimary = AppColors.textPrimaryC(isDark);
    final textSecondary = AppColors.textSecondaryC(isDark);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: stageColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: stageColor.withValues(alpha: 0.08),
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
                  color: stageColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: stageColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.flash_on_rounded, size: 16, color: stageColor),
                    const SizedBox(width: 4),
                    Text(
                      spot.warningStage.replaceAll('_', ' '),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: stageColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined, size: 13, color: AppColors.alertOrange),
                    const SizedBox(width: 4),
                    Text(
                      'Valid: ${spot.nowcastValidityHours}h Nowcast',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.alertOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            spot.hotspotName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          Text(
            '${spot.phenomenon.replaceAll('_', ' ')} • ${spot.state}',
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
              color: stageColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: stageColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.storm_rounded, size: 18, color: stageColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    spot.headline,
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
              Icon(Icons.speed_rounded, size: 14, color: textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Doppler Core Reflectivity: ${spot.radarReflectivityDbz.toStringAsFixed(0)} dBZ',
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

  Widget _buildThermodynamicHud(ThermodynamicInstabilityModel thermo, bool isDark) {
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
              const Icon(Icons.analytics_rounded, size: 18, color: Color(0xFF6366F1)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Thermodynamic Convective Instability',
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
                  'CAPE Energy',
                  '${thermo.capeJKg.toStringAsFixed(0)} J/kg',
                  Icons.electric_bolt_rounded,
                  AppColors.alertRed,
                  isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTelemetryCell(
                  'Lifted Index (LI)',
                  '${thermo.liftedIndexC.toStringAsFixed(1)} °C',
                  Icons.vertical_align_top_rounded,
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
                  'George\'s K-Index',
                  '${thermo.kIndexC.toStringAsFixed(0)} °C',
                  Icons.thermostat_rounded,
                  const Color(0xFF06B6D4),
                  isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTelemetryCell(
                  'Total Totals (TT)',
                  '${thermo.totalTotalsC.toStringAsFixed(0)} °C',
                  Icons.calculate_rounded,
                  const Color(0xFFA855F7),
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
                  'SWEAT Index',
                  thermo.sweatIndex.toStringAsFixed(0),
                  Icons.crisis_alert_rounded,
                  AppColors.alertOrange,
                  isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTelemetryCell(
                  '0-6 km Bulk Shear',
                  '${thermo.bulkWindShear06kmKt.toStringAsFixed(0)} kt',
                  Icons.air_rounded,
                  AppColors.brandBlue,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDensityCurrentCard(HaboobDensityCurrentModel haboob, bool isDark) {
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
              const Icon(Icons.waves_rounded, size: 18, color: AppColors.alertAmber),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cold-Pool Haboob & Squall Dynamics',
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
                  'Gust Front Speed',
                  '${haboob.gustFrontSpeedKmh.toStringAsFixed(0)} km/h',
                  Icons.fast_forward_rounded,
                  AppColors.alertRed,
                  isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTelemetryCell(
                  'Dust/Squall Wall',
                  '${haboob.dustWallHeightM.toStringAsFixed(0)} m',
                  Icons.height_rounded,
                  AppColors.alertAmber,
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
                  'Min. Visibility',
                  '${haboob.minimumVisibilityM.toStringAsFixed(0)} m',
                  Icons.visibility_off_rounded,
                  AppColors.alertOrange,
                  isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTelemetryCell(
                  'PM10 Particulate',
                  '${haboob.pm10SurgeUgM3.toStringAsFixed(0)} µg/m³',
                  Icons.grain_rounded,
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
                const Icon(Icons.south_east_rounded, size: 16, color: AppColors.brandBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Propagation: ${haboob.downdraftSpreadDirection} • Cold-pool ΔT: -${haboob.coldPoolTempDropC.toStringAsFixed(1)}°C drop.',
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

  Widget _buildAviationGridCard(AviationGridImpactModel impact, bool isDark) {
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
              const Icon(Icons.flight_takeoff_rounded, size: 18, color: AppColors.brandBlue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Aviation & Power Grid Resilience',
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
          _buildImpactRow(Icons.air_rounded, 'Microburst / LLWS', impact.microburstRisk, AppColors.alertRed, isDark),
          const SizedBox(height: 8),
          _buildImpactRow(Icons.power_rounded, 'Power Grid Risk', impact.powerGridRisk, AppColors.alertOrange, isDark),
          const SizedBox(height: 8),
          _buildImpactRow(Icons.local_airport_rounded, 'Airport Operations', impact.airportAlert, AppColors.brandBlue, isDark),
          const SizedBox(height: 8),
          _buildImpactRow(Icons.home_repair_service_rounded, 'Structural Threat', impact.structuralDamageRisk, AppColors.alertAmber, isDark),
        ],
      ),
    );
  }

  Widget _buildImpactRow(IconData icon, String title, String description, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textPrimaryC(isDark),
                    height: 1.3,
                  ),
                ),
              ],
            ),
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
      {'code': 'bn', 'label': 'বাংলা'},
      {'code': 'or', 'label': 'ଓଡ଼ିଆ'},
      {'code': 'as', 'label': 'অসমীয়া'},
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
                  'Emergency Convective Bulletin',
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

  Widget _buildProvenanceFooter(String refNo, String provenance, bool isDark) {
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
                refNo,
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
