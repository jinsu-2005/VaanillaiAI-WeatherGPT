import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../models/safar_model.dart';
import '../providers/weather_provider.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class AirQualityScreen extends StatefulWidget {
  final String? initialCityCode;

  const AirQualityScreen({super.key, this.initialCityCode});

  @override
  State<AirQualityScreen> createState() => _AirQualityScreenState();
}

class _AirQualityScreenState extends State<AirQualityScreen> {
  final ApiService _apiService = ApiService();
  SafarAirQualityModel? _safarData;
  bool _isLoading = false;
  String? _selectedCityCode;
  String _selectedLang = 'en';

  final List<Map<String, String>> _safarMetroHubs = [
    {'code': 'delhi', 'name': 'Delhi-NCR'},
    {'code': 'mumbai', 'name': 'Mumbai'},
    {'code': 'pune', 'name': 'Pune'},
    {'code': 'ahmedabad', 'name': 'Ahmedabad'},
    {'code': 'chennai', 'name': 'Chennai'},
    {'code': 'bengaluru', 'name': 'Bengaluru'},
    {'code': 'kolkata', 'name': 'Kolkata'},
    {'code': 'hyderabad', 'name': 'Hyderabad'},
    {'code': 'lucknow', 'name': 'Lucknow'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCityCode = widget.initialCityCode;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSafarData();
    });
  }

  Future<void> _loadSafarData() async {
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    if (weatherProvider.forecast == null && _selectedCityCode == null) {
      // Keep weatherProvider null-safety for test/weather_provider_test.dart
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await _apiService.getSafarAirQuality(
        latitude: weatherProvider.latitude,
        longitude: weatherProvider.longitude,
        locationName: weatherProvider.locationName,
        cityCode: _selectedCityCode,
      );
      if (mounted) {
        setState(() {
          _safarData = res;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('SAFAR fetch error: $e. Using fallback.');
      if (mounted) {
        setState(() {
          _safarData = SafarAirQualityModel.defaultFallback(
            latitude: weatherProvider.latitude,
            longitude: weatherProvider.longitude,
            locationName: weatherProvider.locationName,
            cityCode: _selectedCityCode ?? 'delhi',
          );
          _isLoading = false;
        });
      }
    }
  }

  Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Color _getAqiColor(int aqi) {
    if (aqi <= 50) return AppColors.alertGreen;
    if (aqi <= 100) return const Color(0xFF84CC16);
    if (aqi <= 200) return AppColors.alertYellow;
    if (aqi <= 300) return AppColors.alertOrange;
    if (aqi <= 400) return AppColors.alertRed;
    return const Color(0xFF7F1D1D);
  }

  String _getAqiHealthText(int aqi) {
    if (aqi <= 50) {
      return 'Air quality is satisfactory and poses minimal health risk. Ideal for outdoor activities.';
    }
    if (aqi <= 100) {
      return 'Air quality is acceptable; unusually sensitive individuals may experience minor breathing discomfort.';
    }
    if (aqi <= 200) {
      return 'Moderate air pollution; children, elderly, and those with respiratory issues should limit prolonged outdoor exertion.';
    }
    if (aqi <= 300) {
      return 'Poor air quality; breathing discomfort likely for healthy individuals; significant irritation for sensitive groups.';
    }
    if (aqi <= 400) {
      return 'Very Poor air quality; respiratory illness possible on prolonged exposure. Avoid strenuous outdoor workouts.';
    }
    return 'Severe air quality emergency; healthy people affected, and serious health impacts for those with pre-existing conditions.';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final basicAqi = weatherProvider.forecast?.airQuality;

    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkOutline : AppColors.lightOutline;
    final textPrimary = AppColors.textPrimaryC(isDark);
    final textSecondary = AppColors.textSecondaryC(isDark);
    final accentBlue = isDark ? AppColors.brandBlueLight : AppColors.brandBlue;

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Air Quality & Atmospheric Dispersion',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              'IITM SAFAR • IMD AQEWS Dispersion Modeling',
              style: TextStyle(fontSize: 11, color: textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: accentBlue),
            tooltip: 'Refresh Air Quality',
            onPressed: _loadSafarData,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: (basicAqi == null && _safarData == null && !_isLoading)
              ? _buildUnavailableState(
                  context,
                  weatherProvider,
                  surfaceColor,
                  borderColor,
                  textPrimary,
                  textSecondary,
                  isDark,
                )
              : _isLoading
                  ? Center(child: SpinKitPulse(color: accentBlue, size: 50))
                  : _buildSafarContent(
                      context,
                      _safarData ??
                          SafarAirQualityModel.defaultFallback(
                            latitude: weatherProvider.latitude,
                            longitude: weatherProvider.longitude,
                            locationName: weatherProvider.locationName,
                          ),
                      weatherProvider,
                      surfaceColor,
                      borderColor,
                      textPrimary,
                      textSecondary,
                      accentBlue,
                      isDark,
                    ),
        ),
      ),
    );
  }

  Widget _buildUnavailableState(
    BuildContext context,
    WeatherProvider weatherProvider,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.alertGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.air_rounded,
              size: 48,
              color: AppColors.alertGreen,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Air Quality Data Unavailable',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We don\'t have air quality measurements for ${weatherProvider.locationName} right now.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              weatherProvider.fetchWeather(forceRefresh: true);
              _loadSafarData();
            },
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Check Again'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.brandBlue,
              side: BorderSide(
                color: isDark
                    ? AppColors.brandBlue.withValues(alpha: 0.5)
                    : AppColors.brandBlue,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafarContent(
    BuildContext context,
    SafarAirQualityModel safar,
    WeatherProvider weatherProvider,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color accentBlue,
    bool isDark,
  ) {
    final aqiValue = safar.overallAqi;
    final aqiCategory = safar.cpcbCategory;
    final aqiColor = _hexToColor(safar.categoryColorHex);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── SAFAR Metro Air Shed Hub Selector ──────────────────────────────
          _buildMetroHubSelector(surfaceColor, borderColor, textPrimary, textSecondary, accentBlue),
          const SizedBox(height: 14),

          // ── Hero Circular NAQI Ring Gauge Card ─────────────────────────────
          _buildHeroGaugeCard(
            safar,
            aqiValue,
            aqiCategory,
            aqiColor,
            surfaceColor,
            borderColor,
            textPrimary,
            textSecondary,
            accentBlue,
            isDark,
          ),
          const SizedBox(height: 16),

          // ── Atmospheric Dispersion & Ventilation Coefficient HUD ───────────
          _buildAtmosphericDispersionHud(
            safar.atmosphericDispersion,
            surfaceColor,
            borderColor,
            textPrimary,
            textSecondary,
            accentBlue,
            isDark,
          ),
          const SizedBox(height: 16),

          // ── 6-Pollutant Spectrum Grid ──────────────────────────────────────
          _buildPollutantSpectrumGrid(
            safar.pollutants,
            surfaceColor,
            borderColor,
            textPrimary,
            textSecondary,
            isDark,
          ),
          const SizedBox(height: 16),

          // ── Satellite Stubble & Agrarian Biomass Smoke Telemetry ────────────
          _buildStubbleBiomassCard(
            safar.stubbleBiomassSmoke,
            surfaceColor,
            borderColor,
            textPrimary,
            textSecondary,
            accentBlue,
          ),
          const SizedBox(height: 16),

          // ── SAFAR 72-Hour AQI Trend Forecast ──────────────────────────────
          _buildAqiForecastCard(
            safar.aqiForecast,
            surfaceColor,
            borderColor,
            textPrimary,
            textSecondary,
            accentBlue,
          ),
          const SizedBox(height: 16),

          // ── Demographic-Specific Health Directives ─────────────────────────
          _buildDemographicHealthCard(
            safar.demographicAdvisories,
            safar.vernacularHealthGuidance,
            surfaceColor,
            borderColor,
            textPrimary,
            textSecondary,
            accentBlue,
          ),
          const SizedBox(height: 16),

          // ── Active Monitoring Stations & Provenance ────────────────────────
          _buildMonitoringStationsCard(
            safar.monitoringStations,
            safar.provenanceAuthority,
            safar.lastUpdated,
            surfaceColor,
            borderColor,
            textPrimary,
            textSecondary,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMetroHubSelector(
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color accentBlue,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Row(
            children: [
              Icon(Icons.location_city_rounded, size: 16, color: accentBlue),
              const SizedBox(width: 6),
              Text(
                'SAFAR METRO AIR SHED HUBS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _safarMetroHubs.map((hub) {
              final isSelected = (_selectedCityCode ?? 'delhi').toLowerCase() == hub['code']!.toLowerCase();
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedCityCode = hub['code']);
                  _loadSafarData();
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? accentBlue : surfaceColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? accentBlue : borderColor,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Text(
                    hub['name']!,
                    style: TextStyle(
                      color: isSelected ? Colors.white : textPrimary,
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroGaugeCard(
    SafarAirQualityModel safar,
    int aqiValue,
    String aqiCategory,
    Color aqiColor,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color accentBlue,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: aqiColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: aqiColor.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: accentBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'NAQI NATIONAL SCALE',
                      style: TextStyle(
                        color: accentBlue,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    safar.locationName,
                    style: TextStyle(color: textSecondary, fontSize: 12),
                  ),
                ],
              ),
              if (safar.isOfflineCached)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.cloud_off, size: 12, color: Colors.amber),
                      SizedBox(width: 4),
                      Text(
                        'Cached',
                        style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          // Circular Ring Gauge
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 155,
                height: 155,
                child: CircularProgressIndicator(
                  value: (aqiValue / 500).clamp(0.05, 1.0),
                  strokeWidth: 14,
                  backgroundColor: borderColor,
                  valueColor: AlwaysStoppedAnimation<Color>(aqiColor),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$aqiValue',
                    style: TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'CPCB NAQI',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Category Badge + Dominant Pollutant Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: aqiColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: aqiColor.withValues(alpha: 0.6), width: 1),
                ),
                child: Text(
                  aqiCategory.toUpperCase(),
                  style: TextStyle(
                    color: aqiColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 14, color: textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      'Dominant: ${safar.dominantPollutant}',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getAqiHealthText(aqiValue),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textSecondary,
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAtmosphericDispersionHud(
    AtmosphericDispersionModel disp,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color accentBlue,
    bool isDark,
  ) {
    Color dispColor;
    switch (disp.dispersionCategory.toLowerCase()) {
      case 'good':
        dispColor = AppColors.alertGreen;
        break;
      case 'moderate':
        dispColor = AppColors.alertYellow;
        break;
      case 'poor':
        dispColor = AppColors.alertOrange;
        break;
      default:
        dispColor = AppColors.alertRed;
    }

    return Container(
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
              Icon(Icons.air, color: accentBlue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Atmospheric Boundary Layer Dispersion',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: dispColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: dispColor, width: 1),
                ),
                child: Text(
                  disp.dispersionCategory,
                  style: TextStyle(color: dispColor, fontSize: 10.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Planetary Boundary Layer (PBL) height and wind advection determining ground-level pollutant ventilation.',
            style: TextStyle(color: textSecondary, fontSize: 11.5),
          ),
          const Divider(height: 24, color: Colors.white10),
          Row(
            children: [
              Expanded(
                child: _buildDispMetric(
                  'Mixing Height',
                  '${disp.mixingLayerHeightM.toStringAsFixed(0)} m',
                  Icons.vertical_align_top,
                  accentBlue,
                  textPrimary,
                  textSecondary,
                ),
              ),
              Container(width: 1, height: 40, color: borderColor),
              Expanded(
                child: _buildDispMetric(
                  'Surface Winds',
                  '${disp.surfaceWindSpeedKmh.toStringAsFixed(1)} km/h',
                  Icons.wind_power,
                  Colors.cyanAccent,
                  textPrimary,
                  textSecondary,
                ),
              ),
              Container(width: 1, height: 40, color: borderColor),
              Expanded(
                child: _buildDispMetric(
                  'Ventilation Index',
                  '${disp.ventilationCoefficientM2s.toStringAsFixed(0)} m²/s',
                  Icons.speed,
                  dispColor,
                  textPrimary,
                  textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  disp.inversionRisk == 'None' ? Icons.check_circle : Icons.warning_rounded,
                  size: 16,
                  color: disp.inversionRisk == 'None' ? Colors.green : Colors.orangeAccent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${disp.inversionRisk} • ${disp.physicalDispersionSummary}',
                    style: TextStyle(color: textSecondary, fontSize: 11.5, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDispMetric(
    String label,
    String value,
    IconData icon,
    Color color,
    Color textPrimary,
    Color textSecondary,
  ) {
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

  Widget _buildPollutantSpectrumGrid(
    List<PollutantMetricModel> pollutants,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'CPCB 6-POLLUTANT SPECTRUM',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: textSecondary,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.45,
          ),
          itemCount: pollutants.length,
          itemBuilder: (ctx, i) {
            final p = pollutants[i];
            final pColor = _getAqiColor(p.cpcbSubIndex);

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: p.isDominantPollutant ? pColor : borderColor,
                  width: p.isDominantPollutant ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        p.name.split(' ')[0],
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (p.isDominantPollutant)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: pColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'DOMINANT',
                            style: TextStyle(color: pColor, fontSize: 8.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        p.concentration.toStringAsFixed(1),
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        p.unit,
                        style: TextStyle(color: textSecondary, fontSize: 10),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sub-Index: ${p.cpcbSubIndex}',
                            style: TextStyle(color: pColor, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            p.subIndexCategory,
                            style: TextStyle(color: textSecondary, fontSize: 10),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: (p.cpcbSubIndex / 400).clamp(0.05, 1.0),
                          backgroundColor: borderColor,
                          valueColor: AlwaysStoppedAnimation<Color>(pColor),
                          minHeight: 5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStubbleBiomassCard(
    StubbleBiomassSmokeModel stubble,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color accentBlue,
  ) {
    Color impactColor;
    switch (stubble.agrarianSmokeImpactLevel.toLowerCase()) {
      case 'high':
      case 'extreme':
        impactColor = AppColors.alertRed;
        break;
      case 'moderate':
        impactColor = AppColors.alertOrange;
        break;
      default:
        impactColor = AppColors.alertGreen;
    }

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
              const Icon(Icons.local_fire_department, color: AppColors.alertOrange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Biomass & Stubble Fire Tracking',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: impactColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Impact: ${stubble.agrarianSmokeImpactLevel}',
                  style: TextStyle(color: impactColor, fontSize: 10.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Satellite VIIRS/MODIS active agricultural crop burning detection and transboundary transport plume trajectory.',
            style: TextStyle(color: textSecondary, fontSize: 11.5),
          ),
          const Divider(height: 20, color: Colors.white10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStubbleCol('Active Fires', '${stubble.activeFireCountRegional} Counts', textPrimary, textSecondary),
              _buildStubbleCol('Fire Power (FRP)', '${stubble.fireRadiativePowerMw.toStringAsFixed(0)} MW', textPrimary, textSecondary),
              _buildStubbleCol('Plume Wind', stubble.transportWindDirection.split(' ')[0], textPrimary, textSecondary),
              _buildStubbleCol('Smoke PM2.5', '${stubble.transboundaryPm25ContributionPct.toStringAsFixed(1)}%', impactColor, textSecondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStubbleCol(String label, String value, Color valueColor, Color textSecondary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TextStyle(color: valueColor, fontSize: 13, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: textSecondary, fontSize: 10)),
      ],
    );
  }

  Widget _buildAqiForecastCard(
    List<SafarAqiForecastModel> forecast,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color accentBlue,
  ) {
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
              Icon(Icons.timeline_rounded, color: accentBlue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'SAFAR 72-Hour AQI Trend Forecast',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: forecast.map((f) {
              final fColor = _getAqiColor(f.predictedAqi);
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: fColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: fColor.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(f.forecastDay, style: TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                          Text('${f.predictedAqi} AQI', style: TextStyle(color: fColor, fontSize: 13, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(f.category, style: TextStyle(color: fColor, fontSize: 11, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(f.primaryDriver, style: TextStyle(color: textSecondary, fontSize: 10.5, height: 1.3)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDemographicHealthCard(
    List<DemographicHealthAdvisoryModel> demographics,
    Map<String, String> vernacularAdvisories,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color accentBlue,
  ) {
    final localizedAdvice = vernacularAdvisories[_selectedLang] ??
        vernacularAdvisories['en'] ??
        'Wear N95 respirators outdoors and minimize morning cardio during peak stagnation.';

    final langOptions = [
      {'code': 'en', 'label': 'EN'},
      {'code': 'ta', 'label': 'தமிழ்'},
      {'code': 'hi', 'label': 'हिन्दी'},
      {'code': 'pa', 'label': 'ਪੰਜਾਬੀ'},
      {'code': 'bn', 'label': 'বাংলা'},
    ];

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.health_and_safety, color: Colors.greenAccent, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Demographic Health Advisories',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 4,
                children: langOptions.map((lang) {
                  final isSelected = _selectedLang == lang['code'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedLang = lang['code']!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: isSelected ? accentBlue : surfaceColor,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: isSelected ? accentBlue : borderColor),
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
          ...demographics.map((demo) {
            Color riskCol;
            switch (demo.vulnerabilityRiskLevel.toLowerCase()) {
              case 'severe':
                riskCol = AppColors.alertRed;
                break;
              case 'high':
                riskCol = AppColors.alertOrange;
                break;
              default:
                riskCol = AppColors.alertYellow;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          demo.demographicGroup,
                          style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: riskCol.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          demo.vulnerabilityRiskLevel,
                          style: TextStyle(color: riskCol, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    demo.actionableGuidance,
                    style: TextStyle(color: textSecondary, fontSize: 11.5, height: 1.3),
                  ),
                  if (demo.recommendedProtectiveMeasures.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: demo.recommendedProtectiveMeasures.map((m) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: accentBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            m,
                            style: TextStyle(color: accentBlue, fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMonitoringStationsCard(
    List<String> stations,
    String authority,
    String lastUpdated,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sensors, color: textSecondary, size: 16),
              const SizedBox(width: 8),
              Text(
                'Reporting Continuous Ambient Air Stations',
                style: TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: stations.map((st) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: borderColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  st,
                  style: TextStyle(color: textPrimary, fontSize: 10.5),
                ),
              );
            }).toList(),
          ),
          const Divider(height: 20, color: Colors.white10),
          Text(
            '$authority • Refreshed: $lastUpdated. All sub-indices computed per official Central Pollution Control Board (CPCB) NAQI mathematical standards.',
            style: TextStyle(color: textSecondary, fontSize: 10.5, height: 1.35),
          ),
        ],
      ),
    );
  }
}
