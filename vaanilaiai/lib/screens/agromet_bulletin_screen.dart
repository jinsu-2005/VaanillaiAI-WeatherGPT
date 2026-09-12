import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../models/agromet_bulletin_model.dart';
import '../providers/weather_provider.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class AgrometBulletinScreen extends StatefulWidget {
  const AgrometBulletinScreen({super.key});

  @override
  State<AgrometBulletinScreen> createState() => _AgrometBulletinScreenState();
}

class _AgrometBulletinScreenState extends State<AgrometBulletinScreen> {
  final ApiService _apiService = ApiService();
  DistrictAgrometBulletinModel? _bulletin;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBulletin();
    });
  }

  Future<void> _loadBulletin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final weather = Provider.of<WeatherProvider>(context, listen: false);

    try {
      final res = await _apiService.getDistrictAgrometBulletin(
        latitude: weather.latitude,
        longitude: weather.longitude,
        district: weather.district,
        state: null, // ApiService will resolve
      );
      if (mounted) {
        setState(() {
          _bulletin = res;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not load official agromet bulletin. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  void _shareBulletin() {
    if (_bulletin == null) return;
    final b = _bulletin!;
    final sb = StringBuffer();
    sb.writeln('🌾 *ICAR-IMD DISTRICT AGROMET BULLETIN* 🌾');
    sb.writeln('📍 District: ${b.district}, ${b.state}');
    sb.writeln('📄 Bulletin No: ${b.bulletinNumber}');
    sb.writeln('📅 Validity: ${b.validFrom} to ${b.validUntil}');
    sb.writeln('🏛️ Issued by: ${b.amfuCenter}');
    sb.writeln('');
    sb.writeln('🌤️ *WEATHER SUMMARY:*');
    sb.writeln(b.synopticWeatherSummary);
    sb.writeln('');
    sb.writeln('🚜 *FARM OPERATIONS & ADVICE:*');
    for (final tip in b.generalFarmAdvisories) {
      sb.writeln('• $tip');
    }
    sb.writeln('');
    sb.writeln('🌱 *MAJOR CROP ADVISORIES:*');
    for (final c in b.cropAdvisories) {
      sb.writeln('*${c.cropName}* (${c.stage}) [${c.riskLevel}]: ${c.advisoryText}');
      if (c.pestDiseaseAdvisory != null) {
        sb.writeln('  ⚠️ Pest: ${c.pestDiseaseAdvisory}');
      }
      if (c.recommendedIntervention != null) {
        sb.writeln('  🛡️ Action: ${c.recommendedIntervention}');
      }
    }
    sb.writeln('');
    sb.writeln('🐄 *LIVESTOCK ADVICE:*');
    for (final l in b.livestockAdvisories) {
      sb.writeln('*${l.livestockType}*: ${l.managementAdvice}');
    }
    sb.writeln('');
    sb.writeln('Shared via VaanilaiAI Weather Intelligence.');

    Clipboard.setData(ClipboardData(text: sb.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Agromet Bulletin copied to clipboard! Ready to share on WhatsApp or SMS.'),
        backgroundColor: AppColors.alertGreen,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = AppColors.surface(isDark);
    final borderColor = AppColors.border(isDark);
    final textPrimary = AppColors.textPrimaryC(isDark);
    final textSecondary = AppColors.textSecondaryC(isDark);
    final textTertiary = AppColors.textTertiaryC(isDark);
    final accentBlue = isDark ? AppColors.brandBlueLight : AppColors.brandBlue;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Agromet Bulletin (GKMS)',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
            ),
            if (_bulletin != null)
              Text(
                '${_bulletin!.district} • ${_bulletin!.state}',
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
            icon: const Icon(Icons.share_rounded, size: 20),
            tooltip: 'Share Bulletin Summary',
            onPressed: _bulletin != null ? _shareBulletin : null,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: 'Refresh Bulletin',
            onPressed: _loadBulletin,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: SpinKitPulse(color: accentBlue, size: 50))
          : _errorMessage != null && _bulletin == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.alertOrange, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: textPrimary, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadBulletin,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry Fetch'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBulletin,
                  color: accentBlue,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1080),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Offline Mode Banner if cached
                            if (_bulletin!.isOfflineCached) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.alertOrangeDarkBg : AppColors.alertOrangeBg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.alertOrange.withValues(alpha: 0.5)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.cloud_off_rounded, color: AppColors.alertOrange, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Offline Saved Bulletin',
                                            style: TextStyle(
                                              color: AppColors.alertOrange,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            'Displaying local cached data on device. Pull to refresh when connected to internet.',
                                            style: TextStyle(color: textSecondary, fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // 2. Official Bulletin Issuance Header Card
                            _buildOfficialHeaderCard(surfaceColor, borderColor, textPrimary, textSecondary, textTertiary, accentBlue, isDark),
                            const SizedBox(height: 16),

                            // 3. Synoptic Meteorological Synopsis
                            _buildSynopticSummaryCard(surfaceColor, borderColor, textPrimary, textSecondary, accentBlue, isDark),
                            const SizedBox(height: 16),

                            // 4. 5-Day Agromet Meteorological Forecast Matrix
                            _buildFiveDayForecastMatrix(surfaceColor, borderColor, textPrimary, textSecondary, textTertiary, accentBlue, isDark),
                            const SizedBox(height: 16),

                            // 5. General Farm Operations & Spraying Directive
                            _buildGeneralFarmAdvisories(surfaceColor, borderColor, textPrimary, textSecondary, isDark),
                            const SizedBox(height: 16),

                            // 6. Major District Crops Advisories
                            _buildCropAdvisories(surfaceColor, borderColor, textPrimary, textSecondary, textTertiary, isDark),
                            const SizedBox(height: 16),

                            // 7. Livestock & Poultry Management
                            _buildLivestockAdvisories(surfaceColor, borderColor, textPrimary, textSecondary, isDark),
                            const SizedBox(height: 16),

                            // 8. Official Provenance & Disclaimer
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.verified_user_rounded, color: AppColors.alertGreen, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _bulletin!.provenanceDisclaimer,
                                      style: TextStyle(color: textTertiary, fontSize: 10.5, height: 1.4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildOfficialHeaderCard(
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color textTertiary,
    Color accentBlue,
    bool isDark,
  ) {
    final b = _bulletin!;
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accentBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.military_tech_rounded, size: 14, color: accentBlue),
                    const SizedBox(width: 4),
                    Text(
                      'ICAR - IMD GKMS',
                      style: TextStyle(color: accentBlue, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                b.bulletinNumber,
                style: TextStyle(color: textTertiary, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${b.district} District Agromet Bulletin',
            style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.account_balance_rounded, color: textSecondary, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  b.amfuCenter,
                  style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ISSUE DATE', style: TextStyle(color: textTertiary, fontSize: 10, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(b.issueDate, style: TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('VALIDITY PERIOD', style: TextStyle(color: textTertiary, fontSize: 10, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('${b.validFrom} to ${b.validUntil}', style: TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSynopticSummaryCard(
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color accentBlue,
    bool isDark,
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
              Icon(Icons.wb_sunny_rounded, color: accentBlue, size: 18),
              const SizedBox(width: 8),
              Text(
                'Synoptic Weather Synopsis',
                style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _bulletin!.synopticWeatherSummary,
            style: TextStyle(color: textSecondary, fontSize: 13, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _buildFiveDayForecastMatrix(
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color textTertiary,
    Color accentBlue,
    bool isDark,
  ) {
    final list = _bulletin!.fiveDayForecast;
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
              Icon(Icons.calendar_month_rounded, color: accentBlue, size: 18),
              const SizedBox(width: 8),
              Text(
                '5-Day District Agromet Forecast Matrix',
                style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: list.map((day) {
                return Container(
                  width: 155,
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E283D) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(day.dayName, style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
                          Text(
                            day.date.split('-').length >= 3 ? '${day.date.split('-')[2]}/${day.date.split('-')[1]}' : '',
                            style: TextStyle(color: textTertiary, fontSize: 10),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Rain
                      Row(
                        children: [
                          const Icon(Icons.water_drop_rounded, size: 14, color: AppColors.weatherRain),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${day.rainfallMm} mm',
                              style: TextStyle(color: textPrimary, fontSize: 11.5, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Temp
                      Row(
                        children: [
                          const Icon(Icons.thermostat_rounded, size: 14, color: AppColors.alertOrange),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${day.tempMaxC.toStringAsFixed(0)}° / ${day.tempMinC.toStringAsFixed(0)}°',
                              style: TextStyle(color: textPrimary, fontSize: 11.5),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Humidity
                      Row(
                        children: [
                          Icon(Icons.opacity_rounded, size: 14, color: textTertiary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${day.humidityMorningPct}% / ${day.humidityEveningPct}%',
                              style: TextStyle(color: textSecondary, fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Wind
                      Row(
                        children: [
                          Icon(Icons.air_rounded, size: 14, color: textTertiary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${day.windSpeedKmh.toStringAsFixed(0)}k ${day.windDirectionCardinal}',
                              style: TextStyle(color: textSecondary, fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Cloud Cover Oktas
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF141C2B) : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Cloud: ${day.cloudCoverOcta}/8 Oktas',
                          style: TextStyle(color: textSecondary, fontSize: 9.5, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralFarmAdvisories(
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    final list = _bulletin!.generalFarmAdvisories;
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
              const Icon(Icons.agriculture_rounded, color: AppColors.alertGreen, size: 18),
              const SizedBox(width: 8),
              Text(
                'Farm Operations & Spray Directives',
                style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...list.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6, right: 8),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.alertGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(color: textSecondary, fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCropAdvisories(
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color textTertiary,
    bool isDark,
  ) {
    final crops = _bulletin!.cropAdvisories;
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
              const Icon(Icons.eco_rounded, color: AppColors.alertGreen, size: 18),
              const SizedBox(width: 8),
              Text(
                'Major District Crops - Phenology & Protection',
                style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...crops.map((crop) {
            Color riskColor = AppColors.alertGreen;
            if (crop.riskLevel.toLowerCase() == 'alert' || crop.riskLevel.toLowerCase() == 'warning') {
              riskColor = AppColors.alertRed;
            } else if (crop.riskLevel.toLowerCase() == 'watch') {
              riskColor = AppColors.alertOrange;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1B2438) : const Color(0xFFF8FAFC),
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
                        crop.cropName,
                        style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: riskColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          crop.riskLevel,
                          style: TextStyle(color: riskColor, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stage: ${crop.stage}',
                    style: TextStyle(color: textTertiary, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    crop.advisoryText,
                    style: TextStyle(color: textSecondary, fontSize: 12.5, height: 1.4),
                  ),
                  if (crop.pestDiseaseAdvisory != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.bug_report_rounded, color: AppColors.alertOrange, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            crop.pestDiseaseAdvisory!,
                            style: TextStyle(color: textSecondary, fontSize: 12, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (crop.recommendedIntervention != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.sanitizer_rounded, color: AppColors.brandBlue, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            crop.recommendedIntervention!,
                            style: TextStyle(color: textSecondary, fontSize: 12, height: 1.35),
                          ),
                        ),
                      ],
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

  Widget _buildLivestockAdvisories(
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    final list = _bulletin!.livestockAdvisories;
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
              const Icon(Icons.pets_rounded, color: AppColors.alertOrange, size: 18),
              const SizedBox(width: 8),
              Text(
                'Animal Husbandry & Livestock Management',
                style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...list.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1B2438) : const Color(0xFFF8FAFC),
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
                        item.livestockType,
                        style: TextStyle(color: textPrimary, fontSize: 13.5, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        item.riskLevel,
                        style: TextStyle(
                          color: item.riskLevel.toLowerCase() == 'watch' ? AppColors.alertOrange : AppColors.alertGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.managementAdvice,
                    style: TextStyle(color: textSecondary, fontSize: 12.5, height: 1.4),
                  ),
                  if (item.vaccinationOrDiseaseAlert != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.vaccines_rounded, color: AppColors.alertRed, size: 15),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.vaccinationOrDiseaseAlert!,
                            style: TextStyle(color: textSecondary, fontSize: 12, height: 1.35),
                          ),
                        ),
                      ],
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
}
