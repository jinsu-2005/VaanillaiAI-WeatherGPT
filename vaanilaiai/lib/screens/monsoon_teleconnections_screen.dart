import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../models/monsoon_model.dart';
import '../providers/weather_provider.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class MonsoonTeleconnectionsScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLon;
  final String? initialLocationName;

  const MonsoonTeleconnectionsScreen({
    super.key,
    this.initialLat,
    this.initialLon,
    this.initialLocationName,
  });

  @override
  State<MonsoonTeleconnectionsScreen> createState() => _MonsoonTeleconnectionsScreenState();
}

class _MonsoonTeleconnectionsScreenState extends State<MonsoonTeleconnectionsScreen> {
  final ApiService _apiService = ApiService();
  MonsoonIntelligenceModel? _monsoonData;
  bool _isLoading = true;
  String _selectedLang = 'en';
  String _searchQuery = '';
  String _selectedDepartureFilter = 'All';

  late double _currentLat;
  late double _currentLon;
  late String _currentLocationName;

  @override
  void initState() {
    super.initState();
    final weatherProv = Provider.of<WeatherProvider>(context, listen: false);
    _currentLat = widget.initialLat ?? weatherProv.latitude;
    _currentLon = widget.initialLon ?? weatherProv.longitude;
    _currentLocationName = widget.initialLocationName ?? weatherProv.locationName;
    _fetchMonsoonData();
  }

  Future<void> _fetchMonsoonData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getMonsoonIntelligence(
        latitude: _currentLat,
        longitude: _currentLon,
        locationName: _currentLocationName,
      );
      if (mounted) {
        setState(() {
          _monsoonData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading monsoon intelligence: $e');
      if (mounted) {
        setState(() {
          _monsoonData = MonsoonIntelligenceModel.defaultFallback(
            latitude: _currentLat,
            longitude: _currentLon,
            locationName: _currentLocationName,
          );
          _isLoading = false;
        });
      }
    }
  }

  Color _getImdColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'blue':
        return const Color(0xFF1976D2);
      case 'light blue':
        return const Color(0xFF03A9F4);
      case 'green':
        return const Color(0xFF388E3C);
      case 'red':
        return const Color(0xFFD32F2F);
      case 'yellow':
        return const Color(0xFFFBC02D);
      default:
        return const Color(0xFF388E3C);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = AppColors.background(isDark);
    final surface = AppColors.surface(isDark);
    final textPrimary = AppColors.textPrimaryC(isDark);
    final textSecondary = AppColors.textSecondaryC(isDark);
    final accentBlue = isDark ? AppColors.brandBlueLight : AppColors.brandBlue;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monsoon Teleconnections & LRF',
              style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              'IMD Sub-Divisions • Oceanic Drivers (ENSO, IOD, MJO)',
              style: TextStyle(
                color: textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: accentBlue),
            tooltip: 'Refresh Monsoon Intel',
            onPressed: _fetchMonsoonData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: SpinKitWave(
                color: accentBlue,
                size: 40.0,
              ),
            )
          : _monsoonData == null
              ? _buildErrorState(accentBlue)
              : RefreshIndicator(
                  onRefresh: _fetchMonsoonData,
                  color: accentBlue,
                  backgroundColor: surface,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    children: [
                      _buildSubDivisionHeroCard(_monsoonData!.userSubDivision, surface, textPrimary, textSecondary, accentBlue),
                      const SizedBox(height: 16),
                      _buildTeleconnectionsDashboard(_monsoonData!.teleconnections, surface, bg, textPrimary, textSecondary, accentBlue),
                      const SizedBox(height: 16),
                      _buildSeasonalOutlookCard(_monsoonData!.seasonalOutlook, surface, bg, textPrimary, textSecondary),
                      const SizedBox(height: 16),
                      _buildAgriculturalDirectivesCard(
                        _monsoonData!.adaptationDirectives,
                        _monsoonData!.vernacularAdvisories,
                        surface,
                        textPrimary,
                        textSecondary,
                        accentBlue,
                      ),
                      const SizedBox(height: 16),
                      _buildAllSubDivisionsExplorer(_monsoonData!.allSubDivisions, surface, bg, textPrimary, textSecondary, accentBlue),
                      const SizedBox(height: 20),
                      _buildProvenanceFooter(_monsoonData!.provenanceAuthority, _monsoonData!.lastUpdated, surface, textPrimary, textSecondary),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
    );
  }

  Widget _buildErrorState(Color accentBlue) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, color: Colors.white54, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Unable to load Monsoon Intelligence',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _fetchMonsoonData,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(backgroundColor: accentBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildSubDivisionHeroCard(
    SubDivisionalMonsoonModel subDiv,
    Color surface,
    Color textPrimary,
    Color textSecondary,
    Color accentBlue,
  ) {
    final imdColor = _getImdColor(subDiv.departureColor);
    final depPrefix = subDiv.departurePercentage >= 0 ? '+' : '';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            surface,
            imdColor.withValues(alpha: 0.18),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: imdColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: imdColor.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: accentBlue.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: accentBlue, width: 1),
                          ),
                          child: Text(
                            'YOUR MET SUB-DIVISION',
                            style: TextStyle(
                              color: accentBlue,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          subDiv.state,
                          style: TextStyle(color: textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subDiv.name,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: imdColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: imdColor, width: 1.5),
                ),
                child: Column(
                  children: [
                    Text(
                      '$depPrefix${subDiv.departurePercentage}%',
                      style: TextStyle(
                        color: imdColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subDiv.departureCategory,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 24),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'Cumulative Actual',
                  value: '${subDiv.actualRainfallMm.toStringAsFixed(0)} mm',
                  icon: Icons.water_drop,
                  color: Colors.lightBlueAccent,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white10),
              Expanded(
                child: _buildMetricTile(
                  label: 'Climatological Normal',
                  value: '${subDiv.normalRainfallMm.toStringAsFixed(0)} mm',
                  icon: Icons.show_chart,
                  color: Colors.amberAccent,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white10),
              Expanded(
                child: _buildMetricTile(
                  label: 'Soil Moisture',
                  value: '${(subDiv.soilMoistureIndex * 100).toStringAsFixed(0)}%',
                  icon: Icons.grass,
                  color: Colors.greenAccent,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Progress bar for actual vs normal
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rainfall vs Normal Climatology',
                    style: TextStyle(color: textSecondary, fontSize: 11),
                  ),
                  Text(
                    'Drought Status: ${subDiv.droughtRiskLevel}',
                    style: TextStyle(
                      color: subDiv.droughtRiskLevel == 'Normal' ? Colors.greenAccent : Colors.orangeAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: subDiv.normalRainfallMm > 0
                      ? (subDiv.actualRainfallMm / (subDiv.normalRainfallMm * 1.5)).clamp(0.0, 1.0)
                      : 0.5,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(imdColor),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildTeleconnectionsDashboard(
    List<OceanicTeleconnectionModel> teleList,
    Color surface,
    Color bg,
    Color textPrimary,
    Color textSecondary,
    Color accentBlue,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.public, color: accentBlue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Macro-Oceanic Teleconnections',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Coupled Drivers',
                  style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Dynamic SST and convective wave oscillations driving the Indian Summer Monsoon circulation.',
            style: TextStyle(color: textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 14),
          ...teleList.map((tele) => _buildTeleconnectionCard(tele, bg, textPrimary, textSecondary)),
        ],
      ),
    );
  }

  Widget _buildTeleconnectionCard(
    OceanicTeleconnectionModel tele,
    Color bg,
    Color textPrimary,
    Color textSecondary,
  ) {
    final isFavorable = tele.impactOnMonsoon == 'Favorable';
    final impactColor = isFavorable ? Colors.greenAccent : (tele.impactOnMonsoon == 'Neutral' ? Colors.amberAccent : Colors.redAccent);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: impactColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  tele.name,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: impactColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: impactColor, width: 1),
                ),
                child: Text(
                  tele.impactOnMonsoon,
                  style: TextStyle(color: impactColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${tele.currentValue > 0 ? '+' : ''}${tele.currentValue} ${tele.unit}',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tele.phase,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            tele.mechanismSummary,
            style: TextStyle(
              color: textSecondary,
              fontSize: 11,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonalOutlookCard(
    SeasonalForecastOutlookModel outlook,
    Color surface,
    Color bg,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cyclone, color: Colors.cyanAccent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Seasonal Long-Range Forecast (LRF)',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.cyan.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  outlook.onsetStatus,
                  style: const TextStyle(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            outlook.seasonName,
            style: TextStyle(color: textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 14),
          // Tercile probability distribution bar
          Text(
            'Tercile Probability Distribution',
            style: TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 18,
              child: Row(
                children: [
                  Expanded(
                    flex: outlook.probBelowNormalPct,
                    child: Container(
                      color: Colors.redAccent.withValues(alpha: 0.8),
                      child: Center(
                        child: Text(
                          '${outlook.probBelowNormalPct}%',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: outlook.probNormalPct,
                    child: Container(
                      color: Colors.green.withValues(alpha: 0.8),
                      child: Center(
                        child: Text(
                          '${outlook.probNormalPct}%',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: outlook.probAboveNormalPct,
                    child: Container(
                      color: Colors.blueAccent.withValues(alpha: 0.8),
                      child: Center(
                        child: Text(
                          '${outlook.probAboveNormalPct}%',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTercileLegend('Below Normal (${outlook.probBelowNormalPct}%)', Colors.redAccent, textSecondary),
              _buildTercileLegend('Normal (${outlook.probNormalPct}%)', Colors.green, textSecondary),
              _buildTercileLegend('Above Normal (${outlook.probAboveNormalPct}%)', Colors.blueAccent, textSecondary),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bg.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.verified, color: Colors.cyanAccent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    outlook.officialLrfVerdict,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 12,
                      height: 1.35,
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

  Widget _buildTercileLegend(String label, Color color, Color textSecondary) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: textSecondary, fontSize: 9.5),
        ),
      ],
    );
  }

  Widget _buildAgriculturalDirectivesCard(
    List<String> directives,
    Map<String, String> vernacularAdvisories,
    Color surface,
    Color textPrimary,
    Color textSecondary,
    Color accentBlue,
  ) {
    final localizedAdvice = vernacularAdvisories[_selectedLang] ??
        vernacularAdvisories['en'] ??
        (directives.isNotEmpty ? directives.first : 'Monitor official agro-met bulletins.');

    final langOptions = [
      {'code': 'en', 'label': 'EN'},
      {'code': 'ta', 'label': 'தமிழ்'},
      {'code': 'hi', 'label': 'हिन्दी'},
      {'code': 'mr', 'label': 'मराठी'},
      {'code': 'bn', 'label': 'বাংলা'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.agriculture, color: Colors.greenAccent, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Agrarian Directives & Sowing',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Language toggle pills
              Wrap(
                spacing: 4,
                children: langOptions.map((lang) {
                  final isSelected = _selectedLang == lang['code'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedLang = lang['code']!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: isSelected ? accentBlue : Colors.white10,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        lang['label']!,
                        style: TextStyle(
                          color: isSelected ? Colors.white : textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Vernacular advice callout
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.tips_and_updates, color: Colors.greenAccent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    localizedAdvice,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 12,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Recommended Agronomic Measures:',
            style: TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...directives.map(
            (dir) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4, right: 8),
                    child: Icon(Icons.check_circle_outline, color: accentBlue, size: 14),
                  ),
                  Expanded(
                    child: Text(
                      dir,
                      style: TextStyle(color: textPrimary, fontSize: 12, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllSubDivisionsExplorer(
    List<SubDivisionalMonsoonModel> allSubDivs,
    Color surface,
    Color bg,
    Color textPrimary,
    Color textSecondary,
    Color accentBlue,
  ) {
    // Filter sub-divisions by search and departure category
    final filtered = allSubDivs.where((sd) {
      final matchesSearch = sd.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          sd.state.toLowerCase().contains(_searchQuery.toLowerCase());
      if (!matchesSearch) return false;
      if (_selectedDepartureFilter == 'All') return true;
      return sd.departureCategory.toLowerCase() == _selectedDepartureFilter.toLowerCase();
    }).toList();

    final categories = ['All', 'Large Excess', 'Excess', 'Normal', 'Deficient', 'Large Deficient'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.map, color: accentBlue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '36 Meteorological Sub-Divisions',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${allSubDivs.length} Official Zones',
                  style: TextStyle(color: textSecondary, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Search box
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            style: TextStyle(color: textPrimary, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search sub-division (e.g., Konkan, Assam, Rajasthan)',
              hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.6), fontSize: 12),
              prefixIcon: Icon(Icons.search, color: textSecondary, size: 18),
              filled: true,
              fillColor: bg,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Filter pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((cat) {
                final isSelected = _selectedDepartureFilter == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDepartureFilter = cat),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? accentBlue : Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.white : textSecondary,
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          // List of filtered sub-divisions
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No sub-divisions match your criteria.',
                  style: TextStyle(color: textSecondary, fontSize: 12),
                ),
              ),
            )
          else
            ...filtered.map((sd) => _buildSubDivisionRow(sd, bg, textPrimary, textSecondary, accentBlue)),
        ],
      ),
    );
  }

  Widget _buildSubDivisionRow(
    SubDivisionalMonsoonModel sd,
    Color bg,
    Color textPrimary,
    Color textSecondary,
    Color accentBlue,
  ) {
    final imdColor = _getImdColor(sd.departureColor);
    final depPrefix = sd.departurePercentage >= 0 ? '+' : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: sd.isUserSubDivision ? accentBlue : Colors.white10,
          width: sd.isUserSubDivision ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 38,
            decoration: BoxDecoration(
              color: imdColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        sd.name,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 13,
                          fontWeight: sd.isUserSubDivision ? FontWeight.bold : FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (sd.isUserSubDivision)
                      Container(
                        margin: const EdgeInsets.only(left: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: accentBlue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Actual: ${sd.actualRainfallMm.toStringAsFixed(0)} mm | Normal: ${sd.normalRainfallMm.toStringAsFixed(0)} mm',
                  style: TextStyle(color: textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$depPrefix${sd.departurePercentage}%',
                style: TextStyle(
                  color: imdColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                sd.departureCategory,
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProvenanceFooter(
    String authority,
    String lastUpdated,
    Color surface,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user, color: Colors.white54, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Authority & Data Provenance',
                  style: TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$authority • Refreshed: $lastUpdated. All rainfall departures strictly comply with standard IMD percentages and NCMRWF coupled model physics.',
            style: TextStyle(color: textSecondary, fontSize: 11, height: 1.35),
          ),
        ],
      ),
    );
  }
}
