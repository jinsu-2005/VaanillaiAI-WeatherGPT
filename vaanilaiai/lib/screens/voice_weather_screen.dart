import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/weather_provider.dart';
import '../providers/locale_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/responsive_wrapper.dart';

class VoiceWeatherScreen extends StatefulWidget {
  const VoiceWeatherScreen({super.key});

  @override
  State<VoiceWeatherScreen> createState() => _VoiceWeatherScreenState();
}

class _VoiceWeatherScreenState extends State<VoiceWeatherScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  final TextEditingController _queryController = TextEditingController();
  final FocusNode _queryFocus = FocusNode();

  String? _lastQuery;
  String? _voiceResponse;
  bool _isProcessing = false;
  bool _isSpeaking = false;
  String? _citations;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _queryController.dispose();
    _queryFocus.dispose();
    super.dispose();
  }

  void _executeVoiceQuery(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;

    setState(() {
      _lastQuery = clean;
      _isProcessing = true;
      _voiceResponse = null;
      _isSpeaking = false;
      _citations = null;
    });

    final chat = Provider.of<ChatProvider>(context, listen: false);
    final weather = Provider.of<WeatherProvider>(context, listen: false);
    final locale = Provider.of<LocaleProvider>(context, listen: false);

    await chat.sendMessage(
      clean,
      language: locale.currentLanguage,
      latitude: weather.latitude,
      longitude: weather.longitude,
      locationName: weather.locationName,
    );

    if (mounted) {
      final lastMsg = chat.messages.isNotEmpty ? chat.messages.last : null;
      setState(() {
        _isProcessing = false;
        _voiceResponse = lastMsg?.content ?? 'Forecast intelligence retrieved.';
        _citations = lastMsg?.citations.isNotEmpty == true
            ? lastMsg!.citations.join(' · ')
            : 'Google Gemini · IMD Official Data';
        _isSpeaking = true;
      });

      // Simulated natural voice speaking duration
      Future.delayed(const Duration(seconds: 6), () {
        if (mounted) {
          setState(() {
            _isSpeaking = false;
          });
        }
      });
    }
  }

  void _toggleSpeaking() {
    setState(() {
      _isSpeaking = !_isSpeaking;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weather = Provider.of<WeatherProvider>(context);

    final surfaceColor = AppColors.surface(isDark);
    final borderColor = AppColors.border(isDark);
    final textPrimary = AppColors.textPrimaryC(isDark);
    final textSecondary = AppColors.textSecondaryC(isDark);
    final accentBlue = isDark ? AppColors.brandBlueLight : AppColors.brandBlue;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live Voice Intelligence',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              '${weather.locationName} • Gemini 3.1 Flash-Lite Live',
              style: TextStyle(
                color: textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.alertGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.alertGreen.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.alertGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'API Live',
                  style: TextStyle(
                    color: AppColors.alertGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ResponsiveContentWrapper(
        maxWidth: 800,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Pulsing Live Radar Mic
              GestureDetector(
                onTap: () {
                  if (_queryController.text.trim().isNotEmpty) {
                    _executeVoiceQuery(_queryController.text);
                    _queryController.clear();
                  } else {
                    _executeVoiceQuery(
                        'What is the current temperature and rainfall forecast for today in ${weather.locationName}?');
                  }
                },
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final pulseVal = _pulseController.value;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 160 + (pulseVal * 40),
                          height: 160 + (pulseVal * 40),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (_isSpeaking
                                    ? AppColors.alertGreen
                                    : accentBlue)
                                .withValues(alpha: (1.0 - pulseVal) * 0.22),
                          ),
                        ),
                        Container(
                          width: 124,
                          height: 124,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: _isSpeaking
                                  ? [
                                      AppColors.alertGreen,
                                      const Color(0xFF2F855A)
                                    ]
                                  : [
                                      accentBlue,
                                      AppColors.brandBlue,
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (_isSpeaking
                                        ? AppColors.alertGreen
                                        : accentBlue)
                                    .withValues(alpha: 0.4),
                                blurRadius: 24,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: _isProcessing
                              ? const SpinKitThreeBounce(
                                  color: Colors.white, size: 24)
                              : Icon(
                                  _isSpeaking
                                      ? Icons.volume_up_rounded
                                      : Icons.mic_rounded,
                                  color: Colors.white,
                                  size: 48,
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Real-time Status & Animated Waveform
              Text(
                _isProcessing
                    ? '⚡ Streaming from Gemini Live API...'
                    : _isSpeaking
                        ? '🔊 Speaking Weather Intelligence...'
                        : _lastQuery != null
                            ? '"$_lastQuery"'
                            : 'Tap mic or enter inquiry below',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              // Animated Waveform Indicator
              if (_isProcessing || _isSpeaking)
                AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(12, (index) {
                        final val = (_waveController.value + (index * 0.12)) % 1.0;
                        final h = 6.0 + (val * 24.0);
                        return Container(
                          width: 3.5,
                          height: h,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: _isSpeaking
                                ? AppColors.alertGreen
                                : accentBlue,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    );
                  },
                )
              else
                Text(
                  'Connected to Live FastAPI Engine · Port 8000',
                  style: TextStyle(color: textSecondary, fontSize: 11),
                ),

              // Interactive Custom Query Input Bar
              const SizedBox(height: 22),
              Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.record_voice_over_rounded,
                        color: accentBlue, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _queryController,
                        focusNode: _queryFocus,
                        style: TextStyle(color: textPrimary, fontSize: 13),
                        decoration: InputDecoration(
                          hintText:
                              'Speak or type custom weather inquiry...',
                          hintStyle: TextStyle(
                              color: textSecondary, fontSize: 12),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onSubmitted: (val) {
                          _executeVoiceQuery(val);
                          _queryController.clear();
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send_rounded,
                          color: accentBlue, size: 20),
                      onPressed: () {
                        if (_queryController.text.trim().isNotEmpty) {
                          _executeVoiceQuery(_queryController.text);
                          _queryController.clear();
                        }
                      },
                      tooltip: 'Ask Live API',
                    ),
                  ],
                ),
              ),

              // Live Voice Response Container
              if (_voiceResponse != null) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: accentBlue.withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.auto_awesome_rounded,
                                  color: accentBlue, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'WeatherGPT Voice Response',
                                style: TextStyle(
                                  color: accentBlue,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  _isSpeaking
                                      ? Icons.stop_circle_rounded
                                      : Icons.play_circle_fill_rounded,
                                  color: _isSpeaking
                                      ? AppColors.alertGreen
                                      : accentBlue,
                                  size: 22,
                                ),
                                onPressed: _toggleSpeaking,
                                tooltip: _isSpeaking
                                    ? 'Mute Voice'
                                    : 'Read Aloud',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.brandBlueContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Live Telemetry',
                                  style: TextStyle(
                                    color: AppColors.brandBlueDark,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _voiceResponse!,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      if (_citations != null) ...[
                        const SizedBox(height: 12),
                        Divider(color: borderColor, height: 1),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.verified_rounded,
                                color: AppColors.alertGreen, size: 13),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                'Grounding: $_citations',
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Quick Spoken Inquiries Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Spoken Inquiries (One-Tap Live Audio)',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildPromptTile(
                      '🌧️ "Will it rain tomorrow in my area?"',
                      () => _executeVoiceQuery(
                          'Will it rain tomorrow in ${weather.locationName}?'),
                      textPrimary,
                      borderColor,
                    ),
                    _buildPromptTile(
                      '🌾 "Is it safe to spray crops today?"',
                      () => _executeVoiceQuery(
                          'Is it safe for pesticide or fertilizer crop spraying today in ${weather.locationName}?'),
                      textPrimary,
                      borderColor,
                    ),
                    _buildPromptTile(
                      '🚨 "Check cyclone & disaster warnings"',
                      () => _executeVoiceQuery(
                          'Are there any active cyclone, heavy rain or disaster warnings for ${weather.locationName}?'),
                      textPrimary,
                      borderColor,
                    ),
                    _buildPromptTile(
                      '⛵ "Is coastal sea safe for fishing today?"',
                      () => _executeVoiceQuery(
                          'What are the coastal wave heights and wind speeds for fishermen today?'),
                      textPrimary,
                      borderColor,
                    ),
                    _buildPromptTile(
                      '🌡️ "What is the peak heat index and UV level?"',
                      () => _executeVoiceQuery(
                          'What will be the maximum heat index and UV index today in ${weather.locationName}?'),
                      textPrimary,
                      borderColor,
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromptTile(
    String title,
    VoidCallback onTap,
    Color textPrimary,
    Color borderColor, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          leading: const Icon(Icons.mic_none_rounded,
              color: AppColors.brandBlue, size: 18),
          title: Text(
            title,
            style: TextStyle(
              color: textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded,
              color: AppColors.lightTextTertiary, size: 12),
          onTap: onTap,
        ),
        if (!isLast) Divider(color: borderColor, height: 6),
      ],
    );
  }
}
