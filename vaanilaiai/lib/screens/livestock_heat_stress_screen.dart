import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/livestock_heat_stress_model.dart';
import '../services/api_service.dart';

class LivestockHeatStressScreen extends StatefulWidget {
  final LivestockHeatStressResponseModel? initialData;
  final ApiService? apiService;

  const LivestockHeatStressScreen({
    super.key,
    this.initialData,
    this.apiService,
  });

  @override
  State<LivestockHeatStressScreen> createState() => _LivestockHeatStressScreenState();
}

class _LivestockHeatStressScreenState extends State<LivestockHeatStressScreen> {
  late ApiService _apiService;
  LivestockHeatStressResponseModel? _data;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedBasinId = 'karnal_kurukshetra_hr';
  String _selectedLangCode = 'en';

  final List<Map<String, String>> _basins = [
    {'id': 'karnal_kurukshetra_hr', 'name': 'Karnal & Kurukshetra (HR)'},
    {'id': 'anand_mehsana_gj', 'name': 'Anand & Mehsana (GJ)'},
    {'id': 'kolhapur_sangli_mh', 'name': 'Kolhapur & Sangli (MH)'},
    {'id': 'salem_erode_tn', 'name': 'Salem & Erode (TN)'},
    {'id': 'bikaner_jodhpur_rj', 'name': 'Bikaner & Jodhpur (RJ)'},
    {'id': 'guntur_krishna_ap', 'name': 'Guntur & Krishna (AP)'},
    {'id': 'mathura_aligarh_up', 'name': 'Mathura & Aligarh (UP)'},
  ];

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'label': 'English'},
    {'code': 'hi', 'label': 'हिंदी'},
    {'code': 'pa', 'label': 'ਪੰਜਾਬੀ'},
    {'code': 'gu', 'label': 'ગુજરાતી'},
    {'code': 'mr', 'label': 'मराठी'},
    {'code': 'ta', 'label': 'தமிழ்'},
    {'code': 'te', 'label': 'తెలుగు'},
  ];

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    if (widget.initialData != null) {
      _data = widget.initialData;
      _selectedBasinId = widget.initialData!.selectedBasin.basinId;
    } else {
      _fetchLivestockAssessment();
    }
  }

  Future<void> _fetchLivestockAssessment({String? basinId}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _apiService.getLivestockHeatStressAssessment(
        basinId: basinId ?? _selectedBasinId,
      );
      setState(() {
        _data = res;
        _selectedBasinId = res.selectedBasin.basinId;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load livestock heat stress biometeorology: $e';
        _isLoading = false;
      });
    }
  }

  Color _getStressColor(String tier) {
    switch (tier.toUpperCase()) {
      case 'SEVERE_EMERGENCY':
        return const Color(0xFFEF4444); // Red
      case 'MODERATE_STRESS':
        return const Color(0xFFF97316); // Orange
      case 'MILD_STRESS':
        return const Color(0xFFEAB308); // Yellow
      case 'NORMAL_COMFORT':
      default:
        return const Color(0xFF10B981); // Emerald
    }
  }

  String _getStressLabel(String tier) {
    switch (tier.toUpperCase()) {
      case 'SEVERE_EMERGENCY':
        return 'SEVERE EMERGENCY';
      case 'MODERATE_STRESS':
        return 'MODERATE STRESS';
      case 'MILD_STRESS':
        return 'MILD STRESS';
      case 'NORMAL_COMFORT':
      default:
        return 'NORMAL COMFORT';
    }
  }

  String _getStressExplanation(String tier) {
    switch (tier.toUpperCase()) {
      case 'SEVERE_EMERGENCY':
        return 'THI > 88: Critical heat apoplexy risk. Severe panting, recumbency, and high mortality threat.';
      case 'MODERATE_STRESS':
        return 'THI 79 - 88: Open-mouth breathing, salivation, and projected 15-28% milk production loss.';
      case 'MILD_STRESS':
        return 'THI 72 - 78: Elevated respiration rate, slight restlessness, and 5-10% dry matter intake dip.';
      case 'NORMAL_COMFORT':
      default:
        return 'THI < 72: Optimal thermo-neutral comfort zone. Full rumination and maximal milk yield capacity.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgDark = const Color(0xFF0F172A);
    final cardDark = const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: isDark ? bgDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Livestock Heat Stress (THI)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFF0284C7),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Assessment',
            onPressed: () => _fetchLivestockAssessment(basinId: _selectedBasinId),
          ),
        ],
      ),
      body: _isLoading && _data == null
          ? const Center(
              child: SpinKitWave(
                color: Color(0xFF0284C7),
                size: 44.0,
              ),
            )
          : _errorMessage != null && _data == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 54, color: Colors.amber),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => _fetchLivestockAssessment(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry Connection'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0284C7),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildContent(isDark, cardDark),
    );
  }

  Widget _buildContent(bool isDark, Color cardDark) {
    final data = _data ?? LivestockHeatStressResponseModel.defaultFallback();
    final basin = data.selectedBasin;
    final tierColor = _getStressColor(basin.stressTier);

    return RefreshIndicator(
      onRefresh: () => _fetchLivestockAssessment(basinId: _selectedBasinId),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Offline banner
            if (data.isOfflineCached)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 18, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Offline Mode: Displaying cached ICAR-NDRI bioclimatic baseline.',
                        style: TextStyle(
                          color: isDark ? Colors.amber.shade200 : Colors.amber.shade900,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Header Institutional Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.3)),
                  ),
                  child: const Text(
                    'ICAR-NDRI & IMD AGROMET',
                    style: TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    basin.prominentDairyCluster,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Dairy Corridor Selector Chips
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _basins.length,
                separatorBuilder: (context, i) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final item = _basins[index];
                  final isSelected = item['id'] == _selectedBasinId;
                  return ChoiceChip(
                    label: Text(
                      item['name']!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF0284C7),
                    backgroundColor: isDark ? cardDark : Colors.grey.shade200,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedBasinId = item['id']!;
                        });
                        _fetchLivestockAssessment(basinId: item['id']);
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Hero THI Thermal Index Card
            _buildHeroThiCard(basin, tierColor, isDark, cardDark),
            const SizedBox(height: 16),

            // Microclimate biometeorology grid
            _buildMicroclimateGrid(basin.microclimate, isDark, cardDark),
            const SizedBox(height: 16),

            // Species & Breed Vulnerability Profiles
            _buildSpeciesVulnerabilitySection(basin.speciesProfiles, isDark, cardDark),
            const SizedBox(height: 16),

            // Farm Shelter & Nutrition Directives
            _buildDirectivesCard(basin.directives, isDark, cardDark),
            const SizedBox(height: 16),

            // Emergency Veterinary Warning Signs
            _buildEmergencySignsCard(basin.directives.veterinaryEmergencySigns, isDark, cardDark),
            const SizedBox(height: 16),

            // Multilingual Vernacular Pastoral Broadcasts
            _buildVernacularBroadcastCard(basin.vernacularBulletins, isDark, cardDark),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroThiCard(DairyCorridorBasinModel basin, Color tierColor, bool isDark, Color cardDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tierColor.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: tierColor.withValues(alpha: 0.12),
            blurRadius: 16,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    basin.basinName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    '${basin.state} • ${basin.latitude.toStringAsFixed(2)}°N, ${basin.longitude.toStringAsFixed(2)}°E',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: tierColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: tierColor, width: 1.2),
                ),
                child: Text(
                  _getStressLabel(basin.stressTier),
                  style: TextStyle(
                    color: tierColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                basin.microclimate.temperatureHumidityIndexThi.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: tierColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'THI (Thom Index)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'BGTHI ${basin.microclimate.blackGlobeHumidityIndexBgthi.toStringAsFixed(1)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                  Text(
                    'Black Globe Index',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _getStressExplanation(basin.stressTier),
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMicroclimateGrid(MicroclimateBiometeorologyModel m, bool isDark, Color cardDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.thermostat_rounded, size: 20, color: Color(0xFF38BDF8)),
              const SizedBox(width: 8),
              Text(
                'Shed Biometeorology & Microclimate',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.wb_sunny_rounded,
                  label: 'Air Temp (Tdb)',
                  value: '${m.dryBulbTemperatureC.toStringAsFixed(1)}°C',
                  color: const Color(0xFFEF4444),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.water_drop_rounded,
                  label: 'Humidity (RH)',
                  value: '${m.relativeHumidityPct.toStringAsFixed(0)}%',
                  color: const Color(0xFF06B6D4),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.dew_point,
                  label: 'Dew Point',
                  value: '${m.dewPointTemperatureC.toStringAsFixed(1)}°C',
                  color: const Color(0xFF3B82F6),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.air_rounded,
                  label: 'Shed Airflow',
                  value: '${m.windSpeedMs.toStringAsFixed(1)} m/s',
                  color: const Color(0xFF10B981),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.flare_rounded,
                  label: 'Solar Radiation',
                  value: '${m.solarRadiationWm2.toStringAsFixed(0)} W/m²',
                  color: const Color(0xFFF59E0B),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
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
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeciesVulnerabilitySection(
    List<SpeciesVulnerabilityProfileModel> profiles,
    bool isDark,
    Color cardDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pets_rounded, size: 20, color: Color(0xFFF97316)),
              const SizedBox(width: 8),
              Text(
                'Species & Breed Impact Vulnerability',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: profiles.map((profile) {
              return _buildBreedVulnerabilityCard(profile, isDark);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBreedVulnerabilityCard(SpeciesVulnerabilityProfileModel profile, bool isDark) {
    Color breedBadgeColor = const Color(0xFF38BDF8);
    if (profile.speciesCategory.contains('BUFFALO')) {
      breedBadgeColor = const Color(0xFF6366F1);
    } else if (profile.speciesCategory.contains('HF') || profile.speciesCategory.contains('CROSSBRED')) {
      breedBadgeColor = const Color(0xFFEF4444);
    } else if (profile.speciesCategory.contains('ZEBU')) {
      breedBadgeColor = const Color(0xFF10B981);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: breedBadgeColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  profile.breedName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '-${profile.estimatedMilkYieldDropPct.toStringAsFixed(1)}% Milk Drop',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSubStat(
                  'Respiration',
                  '${profile.respirationRateBpm} bpm',
                  profile.respirationRateBpm > 70 ? Colors.redAccent : Colors.orangeAccent,
                  isDark,
                ),
              ),
              Expanded(
                child: _buildSubStat(
                  'Core Temp',
                  '${profile.rectalTemperatureC.toStringAsFixed(1)}°C',
                  profile.rectalTemperatureC > 39.5 ? Colors.redAccent : Colors.amber,
                  isDark,
                ),
              ),
              Expanded(
                child: _buildSubStat(
                  'Feed Intake',
                  '-${profile.dryMatterIntakeReductionPct.toStringAsFixed(0)}%',
                  Colors.blueGrey,
                  isDark,
                ),
              ),
              Expanded(
                child: _buildSubStat(
                  'AI Concep.',
                  '-${profile.conceptionRatePenaltyPct.toStringAsFixed(0)}%',
                  Colors.purpleAccent,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubStat(String label, String value, Color valColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: valColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDirectivesCard(FarmShelterAndNutritionDirectivesModel d, bool isDark, Color cardDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.roofing_rounded, size: 20, color: Color(0xFF10B981)),
              const SizedBox(width: 8),
              Text(
                'Farm Shelter & Feeding Directives',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDirectiveRow(
            icon: Icons.ac_unit_rounded,
            title: 'Shed Cooling & Misting',
            content: d.shedCoolingProtocol,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _buildDirectiveRow(
            icon: Icons.water_rounded,
            title: 'Wallowing / Water Bathing',
            content: d.wallowingPondRecommendation,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _buildDirectiveRow(
            icon: Icons.local_drink_rounded,
            title: 'Daily Water Requirement',
            content: '${d.waterRequirementLitersPerAnimal.toStringAsFixed(0)} Liters per milch animal (Ad-libitum)',
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _buildDirectiveRow(
            icon: Icons.grass_rounded,
            title: 'Dietary & Buffer Ration',
            content: d.dietaryRationAdjustment,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _buildDirectiveRow(
            icon: Icons.timer_off_rounded,
            title: 'Grazing Curfew Hours',
            content: d.grazingCurfewHours,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildDirectiveRow({
    required IconData icon,
    required String title,
    required String content,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF0284C7)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                content,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencySignsCard(List<String> signs, bool isDark, Color cardDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.health_and_safety_rounded, size: 20, color: Color(0xFFEF4444)),
              SizedBox(width: 8),
              Text(
                'Immediate Veterinary Red Alert Signs',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            children: signs.map((sign) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.arrow_right_rounded, size: 18, color: Color(0xFFEF4444)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        sign,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.3,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildVernacularBroadcastCard(Map<String, String> bulletins, bool isDark, Color cardDark) {
    final availableLangs = _languages.where((l) => bulletins.containsKey(l['code'])).toList();
    if (availableLangs.isEmpty) return const SizedBox.shrink();

    // Default to first available if selected not present
    final currentLang = bulletins.containsKey(_selectedLangCode) ? _selectedLangCode : availableLangs.first['code']!;
    final broadcastText = bulletins[currentLang] ?? bulletins.values.first;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.translate_rounded, size: 20, color: Color(0xFF8B5CF6)),
              const SizedBox(width: 8),
              Text(
                'Regional Veterinary Advisory Broadcast',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Language selector chips
          Wrap(
            spacing: 6,
            children: availableLangs.map((lang) {
              final isSel = lang['code'] == currentLang;
              return ChoiceChip(
                label: Text(
                  lang['label']!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    color: isSel ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
                selected: isSel,
                selectedColor: const Color(0xFF8B5CF6),
                backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey.shade200,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedLangCode = lang['code']!;
                    });
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.2)),
            ),
            child: Text(
              broadcastText,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
