import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../models/drought_model.dart';
import '../providers/weather_provider.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class DroughtMonitorScreen extends StatefulWidget {
  final String? initialHotspotId;
  final AgriculturalDroughtResponseModel? initialData;

  const DroughtMonitorScreen({
    super.key,
    this.initialHotspotId,
    this.initialData,
  });

  @override
  State<DroughtMonitorScreen> createState() => _DroughtMonitorScreenState();
}

class _DroughtMonitorScreenState extends State<DroughtMonitorScreen> {
  final ApiService _apiService = ApiService();
  AgriculturalDroughtResponseModel? _data;
  bool _isLoading = true;
  String? _selectedHotspotId;
  String _selectedLanguage = 'en';

  final List<Map<String, String>> _hotspotsList = [
    {'id': 'marathwada_latur', 'label': 'Latur & Marathwada', 'state': 'Maharashtra'},
    {'id': 'rayalaseema_anantapur', 'label': 'Anantapuramu & Rayalaseema', 'state': 'Andhra Pradesh'},
    {'id': 'bundelkhand_jhansi', 'label': 'Jhansi & Bundelkhand', 'state': 'UP / MP'},
    {'id': 'north_interior_karnataka_kalaburagi', 'label': 'Kalaburagi Pulse Bowl', 'state': 'Karnataka'},
    {'id': 'saurashtra_rajkot', 'label': 'Rajkot & Saurashtra', 'state': 'Gujarat'},
    {'id': 'vidarbha_akola', 'label': 'Akola & Vidarbha', 'state': 'Maharashtra'},
    {'id': 'thar_barmer', 'label': 'Barmer & Western Arid Plains', 'state': 'Rajasthan'},
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
      final res = await _apiService.getAgriculturalDroughtAssessment(
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
          _data = AgriculturalDroughtResponseModel.defaultFallback();
          _selectedHotspotId = _data!.selectedHotspot.hotspotId;
          _isLoading = false;
        });
      }
    }
  }

  Color _getSeverityColor(String severity, bool isDark) {
    switch (severity) {
      case 'EMERGENCY_EXTREME_DROUGHT':
        return isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626);
      case 'WARNING_SEVERE_DROUGHT':
        return isDark ? const Color(0xFFF97316) : const Color(0xFFEA580C);
      case 'ALERT_MODERATE_DROUGHT':
        return isDark ? const Color(0xFFEAB308) : const Color(0xFFCA8A04);
      case 'WATCH_MILD_DROUGHT':
        return isDark ? const Color(0xFF3B82F6) : const Color(0xFF2563EB);
      default:
        return isDark ? const Color(0xFF10B981) : const Color(0xFF059669);
    }
  }

  Color _getCgwbCategoryColor(String category, bool isDark) {
    switch (category) {
      case 'OVER_EXPLOITED':
        return isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626);
      case 'CRITICAL':
        return isDark ? const Color(0xFFF97316) : const Color(0xFFEA580C);
      case 'SEMI_CRITICAL':
        return isDark ? const Color(0xFFEAB308) : const Color(0xFFCA8A04);
      default:
        return isDark ? const Color(0xFF10B981) : const Color(0xFF059669);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentBlue = isDark ? AppColors.brandBlueLight : AppColors.brandBlue;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Drought, Soil Moisture & Groundwater',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            Text(
              'IMD SPI • Soil Moisture (RZSM) • CGWB Aquifers',
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
            tooltip: 'Refresh Drought Telemetry',
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
                      _buildHeroSeverityCard(_data!.selectedHotspot, isDark),
                      const SizedBox(height: 16),
                      _buildMeteorologicalSpiGrid(_data!.selectedHotspot.meteorological, isDark),
                      const SizedBox(height: 16),
                      _buildSoilMoistureStressCard(_data!.selectedHotspot.soilMoisture, isDark),
                      const SizedBox(height: 16),
                      _buildGroundwaterCard(_data!.selectedHotspot.groundwater, isDark),
                      const SizedBox(height: 16),
                      _buildAgronomicDirectivesCard(_data!.selectedHotspot.agronomicDirectives, isDark),
                      const SizedBox(height: 16),
                      _buildMultilingualBulletinCard(_data!.vernacularBulletins, isDark),
                      const SizedBox(height: 16),
                      _buildProvenanceFooter(_data!.bulletinNumber, _data!.provenance, isDark),
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
              'Operating in offline drought mode. Showing calibrated agro-climatic dryland baseline.',
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
            Icon(Icons.grass_rounded, size: 16, color: isDark ? AppColors.brandBlueLight : AppColors.brandBlue),
            const SizedBox(width: 6),
            Text(
              'Rainfed Drought Monitoring Belts',
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
                label: Text('${item['label']} • ${item['state']}'),
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

  Widget _buildHeroSeverityCard(DroughtHotspotModel spot, bool isDark) {
    final sevColor = _getSeverityColor(spot.severity, isDark);
    final surfaceColor = AppColors.surface(isDark);
    final textPrimary = AppColors.textPrimaryC(isDark);
    final textSecondary = AppColors.textSecondaryC(isDark);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: sevColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: sevColor.withValues(alpha: 0.08),
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
                  color: sevColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: sevColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 16, color: sevColor),
                    const SizedBox(width: 4),
                    Text(
                      spot.severity.replaceAll('_', ' '),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: sevColor,
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
                    const Icon(Icons.water_drop_outlined, size: 13, color: AppColors.alertOrange),
                    const SizedBox(width: 4),
                    Text(
                      'Rainfall: ${spot.meteorological.rainfallDepartureLpaPct.toStringAsFixed(0)}% LPA',
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
            spot.districtName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          Text(
            '${spot.agroClimaticSubzone} • ${spot.state}',
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
              color: sevColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: sevColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 18, color: sevColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    spot.meteorological.droughtStageVerdict,
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
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: spot.primaryCrops.map((crop) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  crop,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMeteorologicalSpiGrid(MeteorologicalDroughtIndicesModel met, bool isDark) {
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
              const Icon(Icons.show_chart_rounded, size: 18, color: Color(0xFF3B82F6)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Meteorological Drought Indices (IMD Standardized Precipitation Index)',
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
                  'SPI-1 (1 Month)',
                  met.spi1.toStringAsFixed(2),
                  Icons.calendar_view_day_rounded,
                  met.spi1 <= -1.5 ? AppColors.alertRed : AppColors.alertOrange,
                  isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTelemetryCell(
                  'SPI-3 (Seasonal)',
                  met.spi3.toStringAsFixed(2),
                  Icons.date_range_rounded,
                  met.spi3 <= -1.5 ? AppColors.alertRed : AppColors.alertOrange,
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
                  'SPI-6 (Hydrological)',
                  met.spi6.toStringAsFixed(2),
                  Icons.water_damage_rounded,
                  met.spi6 <= -1.5 ? AppColors.alertRed : AppColors.alertOrange,
                  isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTelemetryCell(
                  'Dry Spell Run',
                  '${met.consecutiveDryDays} days',
                  Icons.wb_sunny_rounded,
                  met.consecutiveDryDays >= 20 ? AppColors.alertRed : AppColors.alertAmber,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSoilMoistureStressCard(SoilMoistureStressModel soil, bool isDark) {
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
              const Icon(Icons.opacity_rounded, size: 18, color: AppColors.alertAmber),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Root-Zone Soil Moisture & Crop Water Stress (SMDI)',
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
                  'Root-Zone Moisture',
                  '${soil.rootZoneSoilMoisturePct.toStringAsFixed(1)}%',
                  Icons.grass_rounded,
                  soil.rootZoneSoilMoisturePct <= soil.permanentWiltingPointPct ? AppColors.alertRed : AppColors.alertOrange,
                  isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTelemetryCell(
                  'Plant Available (AWC)',
                  '${soil.availableWaterCapacityMm.toStringAsFixed(1)} mm',
                  Icons.water_drop_rounded,
                  const Color(0xFF06B6D4),
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
                  'SMDI Index',
                  soil.smdi.toStringAsFixed(2),
                  Icons.linear_scale_rounded,
                  soil.smdi <= -2.5 ? AppColors.alertRed : AppColors.alertAmber,
                  isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTelemetryCell(
                  'Crop Stress (CWSI)',
                  soil.cropWaterStressIndex.toStringAsFixed(2),
                  Icons.crisis_alert_rounded,
                  soil.cropWaterStressIndex >= 0.8 ? AppColors.alertRed : AppColors.alertOrange,
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
                const Icon(Icons.speed_rounded, size: 16, color: AppColors.alertOrange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${soil.stressLevel} (Field Cap: ${soil.fieldCapacityPct.toStringAsFixed(0)}% • Wilting Point: ${soil.permanentWiltingPointPct.toStringAsFixed(0)}%)',
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

  Widget _buildGroundwaterCard(GroundwaterAquiferStatusModel gw, bool isDark) {
    final surfaceColor = AppColors.surface(isDark);
    final borderColor = AppColors.border(isDark);
    final textPrimary = AppColors.textPrimaryC(isDark);
    final catColor = _getCgwbCategoryColor(gw.aquiferCategory, isDark);

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
              const Icon(Icons.water_rounded, size: 18, color: Color(0xFF06B6D4)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'CGWB Hydrogeology & Aquifer Depletion Status',
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
                  'Extraction (SOE %)',
                  '${gw.stageOfExtractionPct.toStringAsFixed(1)}%',
                  Icons.pie_chart_outline_rounded,
                  catColor,
                  isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTelemetryCell(
                  'Water Table Depth',
                  '${gw.depthToWaterTableMBgl.toStringAsFixed(1)} m bgl',
                  Icons.arrow_downward_rounded,
                  gw.depthToWaterTableMBgl >= 30 ? AppColors.alertRed : AppColors.brandBlue,
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
                  'Aquifer Classification',
                  gw.aquiferCategory.replaceAll('_', ' '),
                  Icons.security_rounded,
                  catColor,
                  isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTelemetryCell(
                  'Borewell Yield',
                  gw.borewellYieldTrend,
                  Icons.trending_down_rounded,
                  gw.borewellYieldTrend == 'DEPLETED' ? AppColors.alertRed : AppColors.alertOrange,
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: catColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.crisis_alert_rounded, size: 16, color: catColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    gw.irrigationRationingStatus,
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

  Widget _buildAgronomicDirectivesCard(AgronomicDroughtDirectivesModel dir, bool isDark) {
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
              const Icon(Icons.agriculture_rounded, size: 18, color: Color(0xFF10B981)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ICAR-CRIDA Agricultural Drought Directives',
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
          _buildDirectiveTile(Icons.spa_rounded, 'Crop Stage Protection', dir.cropStageAdvisory, AppColors.alertOrange, isDark),
          const SizedBox(height: 8),
          _buildDirectiveTile(Icons.water_drop_rounded, 'Irrigation Scheduling', dir.irrigationScheduling, AppColors.brandBlue, isDark),
          const SizedBox(height: 8),
          _buildDirectiveTile(Icons.shield_outlined, 'Moisture Conservation', dir.moistureConservation, const Color(0xFF10B981), isDark),
          const SizedBox(height: 8),
          _buildDirectiveTile(Icons.swap_horiz_rounded, 'Contingency Crop Switch', dir.contingencyCropSwitch, const Color(0xFFA855F7), isDark),
          const SizedBox(height: 8),
          _buildDirectiveTile(Icons.pets_rounded, 'Livestock & Fodder Care', dir.livestockFodderAdvisory, AppColors.alertAmber, isDark),
        ],
      ),
    );
  }

  Widget _buildDirectiveTile(IconData icon, String title, String description, Color color, bool isDark) {
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
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textPrimaryC(isDark),
                    height: 1.35,
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
      {'code': 'mr', 'label': 'मराठी'},
      {'code': 'te', 'label': 'తెలుగు'},
      {'code': 'kn', 'label': 'ಕನ್ನಡ'},
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
                  'Regional Drought Advisory Bulletin',
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
                backgroundColor: AppColors.surface(isDark),
                side: BorderSide(
                  color: isSel ? accentBlue : AppColors.border(isDark),
                  width: isSel ? 1.5 : 1,
                ),
                labelStyle: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                  color: isSel ? accentBlue : AppColors.textSecondaryC(isDark),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border(isDark)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activeText,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.copy_rounded, size: 14),
                    label: const Text('Copy Bulletin', style: TextStyle(fontSize: 11)),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: activeText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Drought bulletin copied to clipboard.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProvenanceFooter(String bulletinNo, String provenance, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Official Bulletin: $bulletinNo',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondaryC(isDark),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Data Provenance: $provenance',
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textSecondaryC(isDark).withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildTelemetryCell(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(10),
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
                  style: TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textSecondaryC(isDark),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
