import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../models/crop_stage_model.dart';
import '../models/marine_model.dart';
import '../providers/advisory_provider.dart';
import '../providers/weather_provider.dart';
import '../providers/locale_provider.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/spray_suitability_gauge.dart';
import '../widgets/travel_risk_gauge.dart';

class AdvisoriesScreen extends StatefulWidget {
  const AdvisoriesScreen({super.key});

  @override
  State<AdvisoriesScreen> createState() => _AdvisoriesScreenState();
}

class _AdvisoriesScreenState extends State<AdvisoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  String _selectedCrop = 'Paddy/Rice';
  String _selectedStage = 'Tillering';
  CropStageAdvisoryModel? _cropStageAdvisory;
  bool _isLoadingCropStage = false;

  MarineAdvisoryModel? _marineAdvisory;
  bool _isLoadingMarine = false;

  final List<String> _crops = [
    'Paddy/Rice',
    'Wheat',
    'Cotton',
    'Sugarcane',
    'Mustard',
    'Pulses (Gram)',
    'Vegetables',
  ];

  final List<String> _stages = [
    'Nursery / Sowing',
    'Tillering',
    'Flowering / Anthesis',
    'Grain Filling',
    'Harvesting',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final weather = Provider.of<WeatherProvider>(context, listen: false);
      Provider.of<AdvisoryProvider>(context, listen: false).fetchAdvisories(
        latitude: weather.latitude,
        longitude: weather.longitude,
        locationName: weather.locationName,
        district: weather.district,
      );
      _fetchCropStageAdvisory();
      _fetchMarineAdvisory();
    });
  }

  Future<void> _fetchCropStageAdvisory() async {
    final weather = Provider.of<WeatherProvider>(context, listen: false);
    setState(() => _isLoadingCropStage = true);
    try {
      final res = await _apiService.getCropStageAdvisory(
        cropType: _selectedCrop,
        stage: _selectedStage,
        latitude: weather.latitude,
        longitude: weather.longitude,
        locationName: weather.locationName,
      );
      if (mounted) {
        setState(() {
          _cropStageAdvisory = res;
          _isLoadingCropStage = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingCropStage = false);
    }
  }

  Future<void> _fetchMarineAdvisory() async {
    final weather = Provider.of<WeatherProvider>(context, listen: false);
    setState(() => _isLoadingMarine = true);
    try {
      final res = await _apiService.getMarineAdvisory(
        latitude: weather.latitude,
        longitude: weather.longitude,
        locationName: weather.locationName,
      );
      if (mounted) {
        setState(() {
          _marineAdvisory = res;
          _isLoadingMarine = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMarine = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final advisoryProvider = Provider.of<AdvisoryProvider>(context);
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final accentBlue = isDark ? AppColors.brandBlueLight : AppColors.brandBlue;
    final textSecondary = AppColors.textSecondaryC(isDark);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localeProvider.t('advisories'),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            Text(
              '${weatherProvider.locationName}${weatherProvider.district != null ? " • ${weatherProvider.district}" : ""}',
              style: TextStyle(
                fontSize: 11,
                color: accentBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: accentBlue,
          indicatorWeight: 2.5,
          labelColor: accentBlue,
          unselectedLabelColor: textSecondary,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          tabs: const [
            Tab(icon: Icon(Icons.agriculture_rounded, size: 18), text: 'Agro-Met'),
            Tab(icon: Icon(Icons.commute_rounded, size: 18), text: 'Travel'),
            Tab(icon: Icon(Icons.sailing_rounded, size: 18), text: 'Marine & PFZ'),
          ],
        ),
      ),
      body: advisoryProvider.isLoading && advisoryProvider.agricultureAdvisory == null
          ? Center(child: SpinKitPulse(color: accentBlue, size: 50))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAgriTab(context, advisoryProvider, isDark),
                    _buildTravelTab(context, advisoryProvider, isDark),
                    _buildMarineTab(context, weatherProvider, isDark),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAgriTab(BuildContext context, AdvisoryProvider provider, bool isDark) {
    final agri = provider.agricultureAdvisory;
    if (agri == null) {
      return _buildEmptyTab(isDark, 'No agricultural advisory available.');
    }

    final surfaceColor = AppColors.surface(isDark);
    final borderColor = AppColors.border(isDark);
    final textPrimary = AppColors.textPrimaryC(isDark);
    final textTertiary = AppColors.textTertiaryC(isDark);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Spray Suitability Gauge
          SpraySuitabilityGauge(advisory: agri),
          const SizedBox(height: 16),

          // 2. Interactive ICAR-GKMS Crop Phenology & Stage Advisor
          Container(
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
                    const Icon(Icons.psychology_alt_rounded, color: AppColors.brandBlue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ICAR-GKMS Precision Crop Phenology',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (_isLoadingCropStage)
                      const SpinKitThreeBounce(color: AppColors.brandBlue, size: 14),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Select crop and vegetative stage for customized bioclimatic advice.',
                  style: TextStyle(color: textTertiary, fontSize: 11),
                ),
                const SizedBox(height: 12),

                // Crop Horizontal Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _crops.map((crop) {
                      final isSel = _selectedCrop == crop;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(crop, style: TextStyle(fontSize: 12, color: isSel ? Colors.white : null)),
                          selected: isSel,
                          selectedColor: AppColors.brandBlue,
                          onSelected: (val) {
                            if (val) {
                              setState(() => _selectedCrop = crop);
                              _fetchCropStageAdvisory();
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),

                // Stage Dropdown
                Row(
                  children: [
                    Text('Growth Stage: ', style: TextStyle(fontSize: 12, color: textPrimary, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E283D) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedStage,
                            isExpanded: true,
                            items: _stages.map((st) => DropdownMenuItem(value: st, child: Text(st, style: const TextStyle(fontSize: 12)))).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedStage = val);
                                _fetchCropStageAdvisory();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Detailed Phenology Directive
                if (_cropStageAdvisory != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A2338) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Vulnerability: ${_cropStageAdvisory!.stageVulnerability}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _cropStageAdvisory!.stageVulnerability.toLowerCase() == 'critical'
                                    ? AppColors.alertRed
                                    : (_cropStageAdvisory!.stageVulnerability.toLowerCase() == 'high' ? AppColors.alertOrange : AppColors.alertGreen),
                              ),
                            ),
                            Text(
                              'Water: ${_cropStageAdvisory!.waterRequirementStatus}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.blueAccent),
                            ),
                          ],
                        ),
                        const Divider(height: 18),
                        _buildAgriDetailRow('Irrigation Directive', _cropStageAdvisory!.irrigationDirective, textPrimary, textTertiary),
                        const SizedBox(height: 8),
                        _buildAgriDetailRow('Spray Directive', _cropStageAdvisory!.chemicalSprayingDirective, textPrimary, textTertiary),
                        const SizedBox(height: 8),
                        _buildAgriDetailRow('Pest Surveillance', _cropStageAdvisory!.pestDiseaseAlert, textPrimary, textTertiary),
                        if (_cropStageAdvisory!.harvestLogisticsAdvice != null) ...[
                          const SizedBox(height: 8),
                          _buildAgriDetailRow('Harvest Advice', _cropStageAdvisory!.harvestLogisticsAdvice!, textPrimary, textTertiary),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Agronomic Action Points
          if (agri.cropSpecificTips.isNotEmpty) ...[
            Container(
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
                      const Icon(Icons.eco_rounded, color: AppColors.alertGreen, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Agronomic Action Points',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...agri.cropSpecificTips.map((tip) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 5, right: 10),
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.alertGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(tip, style: TextStyle(color: textPrimary, fontSize: 13, height: 1.45)),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            agri.officialDisclaimer,
            style: TextStyle(color: textTertiary, fontSize: 10, height: 1.4),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAgriDetailRow(String label, String value, Color textPrimary, Color textTertiary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.brandBlue)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 12, height: 1.35, color: textPrimary)),
      ],
    );
  }

  Widget _buildTravelTab(BuildContext context, AdvisoryProvider provider, bool isDark) {
    final travel = provider.travelAdvisory;
    if (travel == null) {
      return _buildEmptyTab(isDark, 'No travel advisory available.');
    }

    final surfaceColor = AppColors.surface(isDark);
    final borderColor = AppColors.border(isDark);
    final textPrimary = AppColors.textPrimaryC(isDark);
    final accentBlue = isDark ? AppColors.brandBlueLight : AppColors.brandBlue;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TravelRiskGauge(advisory: travel),
          const SizedBox(height: 16),
          Container(
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
                    const Icon(Icons.shield_outlined, color: AppColors.brandBlue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Safe Transit Guidelines',
                      style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...travel.safetyRecommendations.map((rec) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_outline, color: accentBlue, size: 16),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(rec, style: TextStyle(color: textPrimary, fontSize: 13, height: 1.45)),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMarineTab(BuildContext context, WeatherProvider weatherProvider, bool isDark) {
    final marine = _marineAdvisory;
    final surfaceColor = AppColors.surface(isDark);
    final borderColor = AppColors.border(isDark);
    final textPrimary = AppColors.textPrimaryC(isDark);
    final textSecondary = AppColors.textSecondaryC(isDark);
    final textTertiary = AppColors.textTertiaryC(isDark);

    if (marine == null && _isLoadingMarine) {
      return Center(child: SpinKitPulse(color: AppColors.brandBlue, size: 40));
    }

    final waveHeight = marine?.significantWaveHeightM ?? 1.2;
    final seaCondition = marine?.seaCondition ?? 'Moderate';
    final isSafe = marine?.deepSeaNavigationSafe ?? true;
    final conditionColor = isSafe ? AppColors.alertGreen : AppColors.alertRed;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Port Warning Signal Banner
          if (marine != null && marine.portWarningSignalNumber > 0)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.alertRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.alertRed, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_rounded, color: AppColors.alertRed, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          marine.portWarningSignalName.toUpperCase(),
                          style: const TextStyle(color: AppColors.alertRed, fontSize: 13, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          marine.portWarningSignalDescription,
                          style: TextStyle(fontSize: 11.5, color: isDark ? Colors.white70 : Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // 2. Sea State Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: conditionColor.withValues(alpha: 0.5), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      marine?.coastalRegion ?? 'Coastal Waters',
                      style: TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: conditionColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        seaCondition,
                        style: TextStyle(color: conditionColor, fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.waves_rounded, color: AppColors.brandBlue, size: 36),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${waveHeight.toStringAsFixed(1)} m',
                          style: TextStyle(color: textPrimary, fontSize: 28, fontWeight: FontWeight.w800, height: 1.0),
                        ),
                        Text(
                          'Significant Wave Height (Swell: ${marine?.swellPeriodSeconds ?? 9.0}s)',
                          style: TextStyle(color: textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Wind & Ocean Telemetry
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMarineMetric('Coastal Wind', '${marine?.coastalWindKnots ?? 12} kts', '${marine?.coastalWindKmH ?? 22} km/h', textPrimary, textSecondary, textTertiary),
                Container(width: 1, height: 44, color: borderColor),
                _buildMarineMetric('SST (Ocean)', '${marine?.seaSurfaceTemperatureC ?? 28.5}°C', 'Surface Temp', textPrimary, textSecondary, textTertiary),
                Container(width: 1, height: 44, color: borderColor),
                _buildMarineMetric('Chlorophyll', '${marine?.chlorophyllAMgM3 ?? 1.4}', 'mg/m³ Bio-density', textPrimary, textSecondary, textTertiary),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. INCOIS Potential Fishing Zones (PFZ)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.teal.withValues(alpha: 0.4), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.explore_rounded, color: Colors.teal, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'INCOIS Potential Fishing Zones (PFZ)',
                        style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                      ),
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
                          color: isDark ? const Color(0xFF192538) : const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('PFZ VECTOR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.teal)),
                            const SizedBox(height: 4),
                            Text(marine?.pfzBearingDirection ?? '145° SE', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF192538) : const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('DISTANCE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.teal)),
                            const SizedBox(height: 4),
                            Text('${marine?.pfzDistanceNauticalMiles ?? 18.5} NM Offshore', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'PFZ status: ${marine?.potentialFishingZoneStatus ?? "Chlorophyll belt detected."}',
                  style: TextStyle(fontSize: 12, color: textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 5. Fishermen Guidance & Tides
          Container(
            padding: const EdgeInsets.all(18),
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
                    const Icon(Icons.anchor_rounded, color: AppColors.brandBlue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Fishermen & Coastal Navigation',
                        style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildMarineTile(
                  isSafe ? '✅ Safe for Coastal Operations' : '🚨 High Risk — Stay Ashore',
                  marine?.fishermenWarningText ?? 'Safe for traditional and motorized craft up to 50 nautical miles.',
                  isSafe ? AppColors.alertGreen : AppColors.alertRed,
                  textPrimary,
                  textSecondary,
                ),
                _buildMarineTile(
                  'Tide Timings & Heights',
                  'High tide: ${marine?.tideHighTime ?? "01:45 PM"} (${marine?.tideHighHeightM ?? 1.6} m) • Low tide: ${marine?.tideLowTime ?? "07:20 PM"} (${marine?.tideLowHeightM ?? 0.4} m)',
                  AppColors.brandBlue,
                  textPrimary,
                  textSecondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Official Coastal & Ocean Bulletin derived from INCOIS and IMD Marine Division.',
            style: TextStyle(color: textTertiary, fontSize: 10, height: 1.4),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMarineMetric(String label, String value, String sub,
      Color textPrimary, Color textSecondary, Color textTertiary) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
        Text(sub, style: TextStyle(color: textTertiary, fontSize: 9.5)),
      ],
    );
  }

  Widget _buildMarineTile(String title, String desc, Color color,
      Color textPrimary, Color textSecondary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5, right: 10),
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: color)),
                const SizedBox(height: 2),
                Text(desc, style: TextStyle(fontSize: 12, height: 1.4, color: textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTab(bool isDark, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.textSecondaryC(isDark), size: 40),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: AppColors.textSecondaryC(isDark), fontSize: 14)),
        ],
      ),
    );
  }
}
