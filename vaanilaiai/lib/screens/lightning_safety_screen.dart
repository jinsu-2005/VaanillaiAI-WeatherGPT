import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lightning_model.dart';
import '../providers/weather_provider.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class LightningSafetyScreen extends StatefulWidget {
  final LightningAlertModel? initialAlert;

  const LightningSafetyScreen({super.key, this.initialAlert});

  @override
  State<LightningSafetyScreen> createState() => _LightningSafetyScreenState();
}

class _LightningSafetyScreenState extends State<LightningSafetyScreen> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  LightningAlertModel? _alert;
  bool _isLoading = false;
  String _selectedLang = 'en'; // 'en', 'ta', 'hi'

  // 30-30 Countdown Timer State (30 minutes = 1800 seconds)
  Timer? _countdownTimer;
  int _secondsRemaining = 1800;
  bool _isTimerRunning = false;

  late AnimationController _radarPulseController;
  late Animation<double> _radarPulseAnimation;

  @override
  void initState() {
    super.initState();
    _alert = widget.initialAlert;

    _radarPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _radarPulseAnimation = Tween<double>(begin: 0.88, end: 1.15).animate(
      CurvedAnimation(parent: _radarPulseController, curve: Curves.easeInOut),
    );

    if (_alert == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchAlert();
      });
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _radarPulseController.dispose();
    super.dispose();
  }

  Future<void> _fetchAlert() async {
    setState(() => _isLoading = true);
    final wp = Provider.of<WeatherProvider>(context, listen: false);
    final alert = await _apiService.getLightningAlert(
      latitude: wp.latitude,
      longitude: wp.longitude,
      locationName: wp.locationName,
    );
    if (mounted) {
      setState(() {
        _alert = alert;
        _isLoading = false;
      });
    }
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _isTimerRunning = true;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isTimerRunning = false;
        });
      }
    });
  }

  void _resetTimerTo30Min() {
    _countdownTimer?.cancel();
    setState(() {
      _secondsRemaining = 1800;
      _isTimerRunning = true;
    });
    _startTimer();
  }

  void _pauseTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _isTimerRunning = false;
    });
  }

  String _formatTimer(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color _getThreatColor(String threatLevel) {
    switch (threatLevel.toLowerCase()) {
      case 'severe':
      case 'high':
      case 'danger':
        return AppColors.alertRed;
      case 'moderate':
      case 'watch':
        return AppColors.alertOrange;
      case 'safe':
        return AppColors.alertGreen;
      default:
        return AppColors.alertYellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkOutline : AppColors.lightOutline;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Damini Lightning & 30-30 Safety'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Lightning Radar',
            onPressed: _fetchAlert,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _alert == null || _alert!.dataUnavailable
              ? _buildUnavailableState(context, isDark, surfaceColor, borderColor, textPrimary, textSecondary)
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      children: [
                        // Provenance Banner
                        _buildProvenanceBanner(isDark),
                        const SizedBox(height: 16),

                        // Radar Strike Proximity Card
                        _buildRadarCard(_alert!, isDark, surfaceColor, borderColor, textPrimary, textSecondary),
                        const SizedBox(height: 20),

                        // 30-30 Interactive Safety Countdown Timer
                        _buildCountdownTimerSection(isDark, surfaceColor, borderColor, textPrimary, textSecondary),
                        const SizedBox(height: 20),

                        // CAPE Convective Stability Gauge
                        _buildCapeGaugeCard(_alert!, isDark, surfaceColor, borderColor, textPrimary, textSecondary),
                        const SizedBox(height: 20),

                        // Vernacular Farmer Directives
                        _buildVernacularSection(_alert!, isDark, surfaceColor, borderColor, textPrimary, textSecondary),
                        const SizedBox(height: 20),

                        // Field Safety Checklist
                        _buildFieldSafetyRules(_alert!, isDark, surfaceColor, borderColor, textPrimary, textSecondary),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildProvenanceBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceHighlight : AppColors.brandBlueContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkOutline : AppColors.brandBlue.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.sensors_rounded, color: AppColors.brandBlue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IITM Pune Damini Telemetry & NWP Convection',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.brandBlueDark,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Indian Institute of Tropical Meteorology sensor grid & CAPE atmospheric index',
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.brandBlueDark.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarCard(
    LightningAlertModel alert,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final threatColor = _getThreatColor(alert.threatLevel);
    final isDanger = alert.nearestStrikeKm <= 10.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: threatColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: threatColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ScaleTransition(
                scale: isDanger ? _radarPulseAnimation : const AlwaysStoppedAnimation(1.0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: threatColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.flash_on_rounded, color: threatColor, size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${alert.threatLevel.toUpperCase()} THREAT LEVEL',
                      style: TextStyle(
                        color: threatColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      alert.locationName,
                      style: TextStyle(color: textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceHighlight : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  alert.strikeTrend,
                  style: TextStyle(color: textPrimary, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Primary Distance & Delay Stats
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceHighlight : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NEAREST STRIKE',
                        style: TextStyle(color: textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${alert.nearestStrikeKm.toStringAsFixed(1)} km',
                        style: TextStyle(
                          color: threatColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        alert.nearestStrikeKm <= 5.0
                          ? 'Immediate strike zone'
                          : (alert.nearestStrikeKm <= 10.0 ? 'High strike hazard' : 'Watch distance'),
                        style: TextStyle(color: textSecondary, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceHighlight : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FLASH-TO-BANG LAG',
                        style: TextStyle(color: textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${alert.flashToBangDelaySeconds.toStringAsFixed(1)} sec',
                        style: TextStyle(
                          color: alert.flashToBangDelaySeconds < 30.0 ? AppColors.alertRed : AppColors.brandBlue,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        alert.flashToBangDelaySeconds < 30.0
                          ? 'Danger (< 30s threshold)'
                          : 'Over 30s away',
                        style: TextStyle(
                          color: alert.flashToBangDelaySeconds < 30.0 ? AppColors.alertRed : textSecondary,
                          fontSize: 10,
                          fontWeight: alert.flashToBangDelaySeconds < 30.0 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Proximity Zone Visualizer Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Proximity Zone: ${alert.nearestStrikeKm <= 5 ? "Danger (0-5 km)" : alert.nearestStrikeKm <= 10 ? "Warning (5-10 km)" : alert.nearestStrikeKm <= 20 ? "Watch (10-20 km)" : "Safe (> 20 km)"}',
                    style: TextStyle(color: textPrimary, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${alert.strikesLast30m} strikes in last 30m',
                    style: TextStyle(color: textSecondary, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 10,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Container(color: AppColors.alertRed.withValues(alpha: alert.nearestStrikeKm <= 5 ? 1.0 : 0.25)),
                      ),
                      Expanded(
                        flex: 5,
                        child: Container(color: AppColors.alertOrange.withValues(alpha: alert.nearestStrikeKm > 5 && alert.nearestStrikeKm <= 10 ? 1.0 : 0.25)),
                      ),
                      Expanded(
                        flex: 10,
                        child: Container(color: AppColors.alertYellow.withValues(alpha: alert.nearestStrikeKm > 10 && alert.nearestStrikeKm <= 20 ? 1.0 : 0.25)),
                      ),
                      Expanded(
                        flex: 20,
                        child: Container(color: AppColors.alertGreen.withValues(alpha: alert.nearestStrikeKm > 20 ? 1.0 : 0.25)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownTimerSection(
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final isComplete = _secondsRemaining == 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isComplete ? AppColors.alertGreen : (_isTimerRunning ? AppColors.alertRed : borderColor),
          width: _isTimerRunning ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isComplete ? AppColors.alertGreen : AppColors.brandBlue).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isComplete ? Icons.check_circle_rounded : Icons.timer_outlined,
                  color: isComplete ? AppColors.alertGreen : AppColors.brandBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '30-30 Safety Shelter Timer',
                      style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Mandatory 30-minute waiting period after the last thunderclap',
                      style: TextStyle(color: textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Digital Timer Center Box
          Center(
            child: Column(
              children: [
                Text(
                  _formatTimer(_secondsRemaining),
                  style: TextStyle(
                    color: isComplete ? AppColors.alertGreen : textPrimary,
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isComplete
                            ? AppColors.alertGreen
                            : (_isTimerRunning ? AppColors.alertRed : Colors.grey))
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isComplete
                        ? 'SAFE TO RESUME OUTDOOR WORK'
                        : (_isTimerRunning ? 'REMAIN IN INDOOR SHELTER' : 'TIMER PAUSED'),
                    style: TextStyle(
                      color: isComplete
                          ? AppColors.alertGreen
                          : (_isTimerRunning ? AppColors.alertRed : textSecondary),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Timer Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _resetTimerTo30Min,
                icon: const Icon(Icons.restart_alt_rounded, size: 18),
                label: const Text('Heard Thunder (Reset 30m)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.alertRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(width: 10),
              if (_isTimerRunning)
                OutlinedButton(
                  onPressed: _pauseTimer,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Pause'),
                )
              else if (!isComplete)
                OutlinedButton(
                  onPressed: _startTimer,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Resume'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCapeGaugeCard(
    LightningAlertModel alert,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final cape = alert.capeThunderstormIndexJKg;
    Color capeColor = AppColors.alertGreen;
    if (cape >= 2500) {
      capeColor = AppColors.alertRed;
    } else if (cape >= 1500) {
      capeColor = AppColors.alertOrange;
    } else if (cape >= 800) {
      capeColor = AppColors.alertYellow;
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
              const Icon(Icons.cloud_sync_rounded, color: AppColors.brandBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Atmospheric Convective Energy (CAPE)',
                style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${cape.toStringAsFixed(0)} J/kg',
                style: TextStyle(color: capeColor, fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  alert.capeStabilityVerdict,
                  style: TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'CAPE measures buoyancy in the vertical atmospheric column. Values above 1500 J/kg provide violent upward momentum for cloud electrical charge separation.',
            style: TextStyle(color: textSecondary, fontSize: 11, height: 1.3),
          ),
        ],
      ),
    );
  }

  Widget _buildVernacularSection(
    LightningAlertModel alert,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final currentText = alert.vernacularDirectives[_selectedLang] ??
        alert.vernacularDirectives['en'] ??
        'When thunder roars, go indoors. Seek sturdy shelter immediately.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceHighlight : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.brandBlue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.translate_rounded, color: AppColors.brandBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Vernacular Rural Directives',
                style: TextStyle(
                  color: isDark ? textPrimary : AppColors.brandBlueDark,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Language Selector Pills
              Wrap(
                spacing: 6,
                children: [
                  _buildLangChip('en', 'English'),
                  _buildLangChip('ta', 'தமிழ்'),
                  _buildLangChip('hi', 'हिंदी'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            currentText,
            style: TextStyle(
              color: textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLangChip(String code, String label) {
    final isSelected = _selectedLang == code;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedLang = code;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.brandBlue : Colors.grey.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.brandBlue,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildFieldSafetyRules(
    LightningAlertModel alert,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
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
              const Icon(Icons.shield_rounded, color: AppColors.brandBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Agricultural & Open-Field Safety Rules',
                style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...alert.fieldSafetyGuidance.map((rule) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.arrow_right_rounded, color: AppColors.brandBlue, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        rule,
                        style: TextStyle(color: textPrimary, fontSize: 12, height: 1.3),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildUnavailableState(
    BuildContext context,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.flash_off_rounded, color: AppColors.alertOrange, size: 48),
              const SizedBox(height: 16),
              Text(
                'Lightning Radar Telemetry Unavailable',
                style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Live Damini sensor network data is currently unreachable. If you hear thunder or see darkening cumulonimbus clouds, assume high danger and follow the 30-30 safety rule immediately.',
                style: TextStyle(color: textSecondary, fontSize: 13, height: 1.35),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchAlert,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry Connection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
