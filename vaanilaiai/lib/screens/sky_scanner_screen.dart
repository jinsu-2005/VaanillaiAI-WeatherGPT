import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../models/sky_analysis_model.dart';
import '../providers/weather_provider.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class SkyScannerScreen extends StatefulWidget {
  const SkyScannerScreen({super.key});

  @override
  State<SkyScannerScreen> createState() => _SkyScannerScreenState();
}

class _SkyScannerScreenState extends State<SkyScannerScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnimation;

  bool _isAnalyzing = false;
  SkyAnalysisModel? _analysisResult;
  String _selectedPreset = 'Cumulonimbus (Towering Thunderhead)';

  final List<Map<String, String>> _presets = [
    {
      'title': 'Cumulonimbus (Thunderhead)',
      'desc': 'Dark base with dense vertical anvil and looming thunderstorm',
      'icon': 'thunderstorm',
      'base64': 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
    },
    {
      'title': 'Nimbostratus (Rain Shield)',
      'desc': 'Continuous thick gray layer with falling virga or drizzle',
      'icon': 'grain',
      'base64': 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
    },
    {
      'title': 'Altocumulus (Mackerel Sky)',
      'desc': 'Rippling roll clouds indicating frontal moisture boundary',
      'icon': 'cloud_queue',
      'base64': 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkaGBwAgACbQE3d4qXGgAAAABJRU5ErkJggg==',
    },
    {
      'title': 'Cirrus / Fair Weather',
      'desc': 'High altitude wispy ice crystal filaments in clear blue sky',
      'icon': 'wb_sunny',
      'base64': 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==',
    },
  ];

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanLineAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    super.dispose();
  }

  Future<void> _runAnalysis(String base64Data) async {
    final weather = Provider.of<WeatherProvider>(context, listen: false);
    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
    });

    try {
      final result = await _apiService.analyzeSkyBase64(
        imageBase64: base64Data,
        locationName: weather.locationName,
      );
      if (mounted) {
        setState(() {
          _analysisResult = result;
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vision analysis error: $e')),
        );
      }
    }
  }

  Color _getRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'high':
      case 'severe':
        return const Color(0xFFFF1744);
      case 'moderate':
        return const Color(0xFFFF9100);
      default:
        return const Color(0xFF00E676);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weather = Provider.of<WeatherProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gemini Sky & Cloud Vision AI',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            Text(
              'MoES Multimodal Cloud Genus & Squall Detection',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Optical Viewfinder HUD
            Container(
              height: 240,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0A192F), Color(0xFF1E3A8A), Color(0xFF1E293B)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.brandBlue.withValues(alpha: 0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandBlue.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Corner brackets HUD
                  Positioned(
                    top: 16,
                    left: 16,
                    child: _buildHudBracket(topLeft: true),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: _buildHudBracket(topRight: true),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: _buildHudBracket(bottomLeft: true),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: _buildHudBracket(bottomRight: true),
                  ),

                  // Center Reticle
                  Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.cyanAccent.withValues(alpha: 0.5),
                          width: 1.2,
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.center_focus_strong, color: Colors.cyanAccent, size: 36),
                      ),
                    ),
                  ),

                  // Animated Scanning Laser Line
                  if (_isAnalyzing)
                    AnimatedBuilder(
                      animation: _scanLineAnimation,
                      builder: (context, child) {
                        return Positioned(
                          top: 240 * _scanLineAnimation.value,
                          left: 20,
                          right: 20,
                          child: Container(
                            height: 2.5,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.transparent, Colors.cyanAccent, Colors.transparent],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.cyanAccent.withValues(alpha: 0.8),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                  // HUD Telemetry Overlays
                  Positioned(
                    top: 14,
                    left: 40,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.redAccent,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'LIVE OPTICAL SENSOR',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    bottom: 14,
                    left: 20,
                    right: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'AZ: 184° S • EL: 42°',
                          style: TextStyle(
                            color: Colors.cyanAccent.withValues(alpha: 0.8),
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                        Text(
                          'LOC: ${weather.locationName}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Mode Selector
            Text(
              'SELECT SKY CONDITION OR CAPTURE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 10),

            // Presets List
            ..._presets.map((preset) {
              final isSelected = _selectedPreset == preset['title'];
              return Card(
                elevation: isSelected ? 3 : 0,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: isSelected ? AppColors.brandBlue : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: ListTile(
                  onTap: () {
                    setState(() => _selectedPreset = preset['title']!);
                    _runAnalysis(preset['base64']!);
                  },
                  leading: CircleAvatar(
                    backgroundColor: isSelected ? AppColors.brandBlue : (isDark ? const Color(0xFF222B45) : const Color(0xFFE2E8F0)),
                    child: Icon(
                      _getIconData(preset['icon']!),
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    preset['title']!,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                  ),
                  subtitle: Text(
                    preset['desc']!,
                    style: TextStyle(fontSize: 11.5, color: isDark ? Colors.white60 : Colors.black54),
                  ),
                  trailing: isSelected && _isAnalyzing
                      ? const SpinKitThreeBounce(color: AppColors.brandBlue, size: 18)
                      : const Icon(Icons.arrow_forward_ios, size: 14),
                ),
              );
            }),

            const SizedBox(height: 14),

            // Scan Action Trigger
            ElevatedButton.icon(
              onPressed: _isAnalyzing
                  ? null
                  : () {
                      final found = _presets.firstWhere((p) => p['title'] == _selectedPreset);
                      _runAnalysis(found['base64']!);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: _isAnalyzing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.auto_awesome_rounded),
              label: Text(
                _isAnalyzing ? 'Analyzing Optical Signatures...' : 'Run Vision AI Diagnostic',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),

            const SizedBox(height: 16),

            // Results Card
            if (_analysisResult != null) ...[
              _buildAnalysisResultCard(context, _analysisResult!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHudBracket({
    bool topLeft = false,
    bool topRight = false,
    bool bottomLeft = false,
    bool bottomRight = false,
  }) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border(
          top: (topLeft || topRight)
              ? const BorderSide(color: Colors.cyanAccent, width: 2)
              : BorderSide.none,
          bottom: (bottomLeft || bottomRight)
              ? const BorderSide(color: Colors.cyanAccent, width: 2)
              : BorderSide.none,
          left: (topLeft || bottomLeft)
              ? const BorderSide(color: Colors.cyanAccent, width: 2)
              : BorderSide.none,
          right: (topRight || bottomRight)
              ? const BorderSide(color: Colors.cyanAccent, width: 2)
              : BorderSide.none,
        ),
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'thunderstorm':
        return Icons.thunderstorm_rounded;
      case 'grain':
        return Icons.grain_rounded;
      case 'cloud_queue':
        return Icons.cloud_queue_rounded;
      default:
        return Icons.wb_sunny_rounded;
    }
  }

  Widget _buildAnalysisResultCard(BuildContext context, SkyAnalysisModel result) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final riskColor = _getRiskColor(result.squallRiskLevel);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161E31) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: riskColor.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: riskColor.withValues(alpha: 0.1),
            blurRadius: 18,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.cloud_sync_rounded, color: riskColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.cloudGenus,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'Classification Confidence: ${(result.confidenceScore * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: riskColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${result.squallRiskLevel.toUpperCase()} RISK',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Cloud Description
          Text(
            result.cloudDescription,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark ? Colors.white70 : const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 14),

          // Rain Onset ETA & Coverage Grid
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E283D) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'RAIN ONSET ETA',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.blueAccent),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.rainOnsetEstimatedMinutes != null
                            ? '~${result.rainOnsetEstimatedMinutes} Mins'
                            : 'No Rain Expected',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E283D) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CLOUD COVER',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.teal),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${result.cloudCoveragePercentage}% Sky Fraction',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Actionable Verdict
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: riskColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: riskColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, size: 20, color: riskColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ACTIONABLE DIRECTIVE',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.6),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        result.actionableVerdict,
                        style: TextStyle(fontSize: 12, height: 1.35, color: isDark ? Colors.white : Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Vernacular Summary
          if (result.vernacularSummary.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF182236) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.translate_rounded, size: 18, color: AppColors.brandBlue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.vernacularSummary,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : const Color(0xFF334155),
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
}
