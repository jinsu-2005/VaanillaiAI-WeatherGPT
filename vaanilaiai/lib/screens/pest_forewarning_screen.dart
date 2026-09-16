import 'package:flutter/material.dart';
import '../models/pest_forewarning_model.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class PestForewarningScreen extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final int? initialZoneId;
  final PestForewarningResponseModel? initialData;

  const PestForewarningScreen({
    super.key,
    this.latitude,
    this.longitude,
    this.initialZoneId,
    this.initialData,
  });

  @override
  State<PestForewarningScreen> createState() => _PestForewarningScreenState();
}

class _PestForewarningScreenState extends State<PestForewarningScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  int? _selectedZoneId;
  PestForewarningResponseModel? _data;
  String _selectedLang = 'en';

  @override
  void initState() {
    super.initState();
    _selectedZoneId = widget.initialZoneId ?? 6;
    if (widget.initialData != null) {
      _data = widget.initialData;
      _selectedZoneId = widget.initialData!.zone.zoneId;
      _isLoading = false;
    } else {
      _loadAssessment();
    }
  }

  Future<void> _loadAssessment({int? zoneId}) async {
    setState(() => _isLoading = true);
    final targetZone = zoneId ?? _selectedZoneId;
    try {
      final res = await _apiService.getPestForewarningData(
        latitude: widget.latitude,
        longitude: widget.longitude,
        zoneId: targetZone,
      );
      if (mounted) {
        setState(() {
          _data = res;
          _selectedZoneId = res.zone.zoneId;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _data = PestForewarningResponseModel.defaultFallback();
          _isLoading = false;
        });
      }
    }
  }

  Color _getRiskColor(String level) {
    switch (level) {
      case 'CRITICAL':
        return const Color(0xFFDC2626); // Red
      case 'HIGH':
        return const Color(0xFFF97316); // Orange
      case 'MODERATE':
        return const Color(0xFFEAB308); // Yellow
      default:
        return const Color(0xFF10B981); // Green
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text(
          'Crop Pest & Disease Forewarning',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Forewarning Feed',
            onPressed: () => _loadAssessment(zoneId: _selectedZoneId),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
              ? Center(
                  child: Text('No forewarning data available.', style: TextStyle(color: textSecondary)),
                )
              : RefreshIndicator(
                  onRefresh: () => _loadAssessment(zoneId: _selectedZoneId),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    children: [
                      // 1. Agro-Climatic Zone Selector
                      _buildZoneSelector(textPrimary, isDark),
                      const SizedBox(height: 16),

                      // 2. Hero Risk & Microclimate Overview Card
                      _buildHeroOverviewCard(cardBg, border, textPrimary, textSecondary),
                      const SizedBox(height: 16),

                      // 3. Canopy Microclimate Telemetry HUD
                      _buildMicroclimateHud(cardBg, border, textPrimary, textSecondary),
                      const SizedBox(height: 16),

                      // 4. Disease & Pest Alerts List
                      _buildAlertsSection(cardBg, border, textPrimary, textSecondary, isDark),
                      const SizedBox(height: 16),

                      // 5. Integrated Pest Management (IPM) Calendar
                      _buildIpmCalendarCard(cardBg, border, textPrimary, textSecondary),
                      const SizedBox(height: 16),

                      // 6. Multilingual Farmer Directives
                      _buildMultilingualSection(cardBg, border, textPrimary, textSecondary, isDark),
                      const SizedBox(height: 20),

                      // 7. Provenance Footer
                      _buildProvenanceFooter(textSecondary),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }

  Widget _buildZoneSelector(Color textPrimary, bool isDark) {
    final zones = _data?.allZones ?? [];
    if (zones.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.map_rounded, color: AppColors.brandBlue, size: 16),
            const SizedBox(width: 6),
            Text(
              'ICAR Agro-Climatic Zones of India',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: zones.map((z) {
              final isSelected = z.zoneId == _selectedZoneId;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: isSelected,
                  label: Text('Zone ${z.zoneId}: ${z.zoneName}'),
                  onSelected: (_) {
                    setState(() => _selectedZoneId = z.zoneId);
                    _loadAssessment(zoneId: z.zoneId);
                  },
                  backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  selectedColor: AppColors.brandBlue.withValues(alpha: 0.25),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.brandBlue : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroOverviewCard(Color cardBg, Color border, Color textPrimary, Color textSecondary) {
    final d = _data!;
    final riskColor = _getRiskColor(d.highestRiskLevel);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: riskColor.withValues(alpha: 0.12),
            blurRadius: 16,
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
                    Text(
                      d.zone.zoneName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'States: ${d.zone.keyStates.join(", ")}',
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: riskColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '${d.highestRiskLevel} RISK',
                  style: TextStyle(
                    color: riskColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Dominant Crops Row
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: d.zone.dominantCrops.map((crop) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: border.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '🌱 $crop',
                  style: TextStyle(fontSize: 11, color: textPrimary, fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Headline Callout
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: riskColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: riskColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: riskColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    d.summaryHeadline,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
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

  Widget _buildMicroclimateHud(Color cardBg, Color border, Color textPrimary, Color textSecondary) {
    final t = _data!.telemetry;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sensors_rounded, color: Colors.blueAccent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Canopy Microclimate Infection Index',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildTile(
                  label: 'Canopy Temp',
                  value: '${t.temperatureC}°C',
                  subText: 'Optimal: 15–22°C',
                  icon: Icons.thermostat_rounded,
                  iconColor: Colors.orange,
                  border: border,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTile(
                  label: 'Relative Humidity',
                  value: '${t.relativeHumidityPct.toInt()}%',
                  subText: 'Fungal threshold >=90%',
                  icon: Icons.water_drop_rounded,
                  iconColor: Colors.blue,
                  border: border,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTile(
                  label: 'Leaf Wetness',
                  value: '${t.leafWetnessHours} Hours',
                  subText: 'Dew persistence',
                  icon: Icons.grass_rounded,
                  iconColor: Colors.green,
                  border: border,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTile(
                  label: 'Aphid GDD (Base 5°C)',
                  value: '${t.growingDegreeDaysBase5.toInt()} GDD',
                  subText: 'Thermal sum',
                  icon: Icons.bolt_rounded,
                  iconColor: Colors.amber,
                  border: border,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required String label,
    required String value,
    required String subText,
    required IconData icon,
    required Color iconColor,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: border.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 10.5, color: textSecondary)),
                Text(
                  value,
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: textPrimary),
                ),
                Text(subText, style: TextStyle(fontSize: 9.5, color: textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection(
    Color cardBg,
    Color border,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    final alerts = _data?.alerts ?? [];
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.bug_report_rounded, color: Colors.redAccent, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Pest & Pathogen Epidemiological Alerts',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...alerts.map((alert) => _buildAlertCard(alert, cardBg, border, textPrimary, textSecondary, isDark)),
      ],
    );
  }

  Widget _buildAlertCard(
    PestDiseaseAlertItemModel alert,
    Color cardBg,
    Color border,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    final riskColor = _getRiskColor(alert.riskLevel);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      '${alert.scientificName} · ${alert.targetCrop}',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontStyle: FontStyle.italic,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  alert.riskLevel,
                  style: TextStyle(
                    color: riskColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Economic Threshold Level Box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.rule_rounded, color: Colors.amber, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Economic Threshold Level (ETL): ',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: alert.economicThresholdLevel,
                          style: TextStyle(fontSize: 11.5, color: textPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Pre-symptomatic forewarning
          Text(
            'Forewarning Mechanism:',
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            alert.preSymptomaticForewarning,
            style: TextStyle(fontSize: 12, color: textSecondary, height: 1.35),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Dual Mitigation: Organic / Biocontrol vs Chemical
          Text(
            '🌿 Eco-Friendly / Biocontrol Directive:',
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.green),
          ),
          const SizedBox(height: 2),
          Text(
            alert.organicBiocontrolDirective,
            style: TextStyle(fontSize: 11.5, color: textPrimary, height: 1.3),
          ),
          const SizedBox(height: 8),

          Text(
            '🧪 Emergency Chemical Directive (Post-ETL):',
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.deepOrangeAccent),
          ),
          const SizedBox(height: 2),
          Text(
            alert.chemicalEmergencyDirective,
            style: TextStyle(fontSize: 11.5, color: textPrimary, height: 1.3),
          ),
        ],
      ),
    );
  }

  Widget _buildIpmCalendarCard(Color cardBg, Color border, Color textPrimary, Color textSecondary) {
    final actions = _data?.ipmCalendarActions ?? [];
    if (actions.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded, color: Colors.teal, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Weekly Integrated Pest Management (IPM) Schedule',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...actions.map(
            (act) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('✅ ', style: TextStyle(fontSize: 12)),
                  Expanded(
                    child: Text(
                      act,
                      style: TextStyle(fontSize: 12, color: textPrimary, height: 1.3),
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

  Widget _buildMultilingualSection(
    Color cardBg,
    Color border,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    final bulletins = _data?.multilingualBulletins ?? {};
    if (bulletins.isEmpty) return const SizedBox.shrink();

    final languages = [
      {'code': 'en', 'label': 'English'},
      {'code': 'hi', 'label': 'हिंदी'},
      {'code': 'pa', 'label': 'ਪੰਜਾਬੀ'},
      {'code': 'te', 'label': 'తెలుగు'},
      {'code': 'ta', 'label': 'தமிழ்'},
    ];

    final currentText = bulletins[_selectedLang] ?? bulletins['en'] ?? '';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.translate_rounded, color: Colors.blueAccent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Multilingual Farmer Directives',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: languages.map((lang) {
                final isSel = _selectedLang == lang['code'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(lang['label']!),
                    selected: isSel,
                    onSelected: (val) {
                      if (val) setState(() => _selectedLang = lang['code']!);
                    },
                    selectedColor: AppColors.brandBlue,
                    backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : textPrimary,
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            child: Text(
              currentText,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w500,
                color: textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProvenanceFooter(Color textSecondary) {
    final disclaimer = _data?.provenanceDisclaimer ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user_rounded, color: Colors.teal.shade400, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              disclaimer,
              style: TextStyle(
                fontSize: 11,
                color: textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
