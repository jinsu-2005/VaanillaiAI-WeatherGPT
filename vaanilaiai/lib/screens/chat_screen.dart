import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/weather_provider.dart';
import '../providers/network_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/network_status_badge.dart';
import 'voice_weather_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocus = FocusNode();

  final List<Map<String, String>> _quickPromptChips = [
    {'emoji': '🌧️', 'label': 'Rain Tomorrow', 'query': 'Will it rain tomorrow in my location?'},
    {'emoji': '🌾', 'label': 'Crop Spraying', 'query': 'Is it safe to spray pesticides on crops today?'},
    {'emoji': '🚨', 'label': 'Disaster Alerts', 'query': 'Are there any active cyclone, flood or storm warnings for my district?'},
    {'emoji': '🚗', 'label': 'Travel Safety', 'query': 'What are the travel conditions, fog, and visibility today?'},
    {'emoji': '🍃', 'label': 'Air Quality', 'query': 'What is the current air quality index and pollution level?'},
    {'emoji': '📅', 'label': '7-Day Outlook', 'query': 'Give me a 7-day weather outlook summary.'},
    {'emoji': '⛵', 'label': 'Marine Safety', 'query': 'Is it safe for fishing along the coast today?'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
      final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
      chatProvider.ensurePersonalizedGreeting(
        locationName: weatherProvider.locationName,
        language: localeProvider.currentLanguage,
      );
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _handleSend(String query) {
    if (query.trim().isEmpty) return;
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);

    _textController.clear();
    chatProvider
        .sendMessage(
      query,
      language: localeProvider.currentLanguage,
      latitude: weatherProvider.latitude,
      longitude: weatherProvider.longitude,
      locationName: weatherProvider.locationName,
    )
        .then((_) => _scrollToBottom());

    _scrollToBottom();
    _inputFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatProvider = Provider.of<ChatProvider>(context);
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final networkProvider = Provider.of<NetworkProvider>(context);

    final surfaceColor = AppColors.surface(isDark);
    final borderColor = AppColors.border(isDark);
    final textPrimary = AppColors.textPrimaryC(isDark);
    final textSecondary = AppColors.textSecondaryC(isDark);
    final inputBg = AppColors.surfaceHL(isDark);
    final accentBlue = isDark ? AppColors.brandBlueLight : AppColors.brandBlue;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.brandBlue, AppColors.brandBlueLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('WeatherGPT',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  Text(
                    '${weatherProvider.locationName} · Gemini AI',
                    style: TextStyle(
                        color: textSecondary, fontSize: 11, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          const NetworkStatusBadge(compact: true),
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(Icons.mic_rounded, color: accentBlue),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const VoiceWeatherScreen())),
            tooltip: 'Live Voice Mode',
          ),
          if (chatProvider.messages.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep_outlined, color: textSecondary),
              onPressed: () => chatProvider.clearChat(),
              tooltip: 'Clear Chat',
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
          // Messages List
          Expanded(
            child: chatProvider.messages.isEmpty
                ? _buildEmptyState(
                    textPrimary, textSecondary, borderColor, surfaceColor, isDark, accentBlue)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      final msg = chatProvider.messages[index];
                      return ChatBubble(message: msg);
                    },
                  ),
          ),

          // Typing indicator
          if (chatProvider.isSending) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: accentBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.smart_toy_rounded,
                        color: accentBlue, size: 16),
                  ),
                  const SizedBox(width: 10),
                  SpinKitThreeBounce(color: accentBlue, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    'Querying meteorological models…',
                    style: TextStyle(color: textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 6),

          // Quick Prompt Chips
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _quickPromptChips.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = _quickPromptChips[index];
                return _QuickChip(
                  emoji: item['emoji']!,
                  label: item['label']!,
                  onTap: () => _handleSend(item['query']!),
                  isDark: isDark,
                  borderColor: borderColor,
                  textColor: textPrimary,
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          if (networkProvider.isOffline)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.alertOrange.withValues(alpha: isDark ? 0.18 : 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.alertOrange.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off_rounded, size: 16, color: AppColors.alertOrange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'WeatherGPT is offline. Saved chats are visible, but new AI queries require internet.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFFDBA74) : const Color(0xFF9A3412),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Input Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            decoration: BoxDecoration(
              color: surfaceColor,
              border: Border(top: BorderSide(color: borderColor, width: 0.8)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: inputBg,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Expanded(
                            child: KeyboardListener(
                              focusNode: FocusNode(),
                              onKeyEvent: (event) {
                                if (event is KeyDownEvent &&
                                    event.logicalKey == LogicalKeyboardKey.enter &&
                                    !HardwareKeyboard.instance.isShiftPressed) {
                                  _handleSend(_textController.text);
                                }
                              },
                              child: TextField(
                                controller: _textController,
                                focusNode: _inputFocus,
                                style: TextStyle(color: textPrimary, fontSize: 14),
                                maxLines: 4,
                                minLines: 1,
                                textInputAction: TextInputAction.send,
                                decoration: InputDecoration(
                                  hintText: 'Ask anything in English, தமிழ், हिन्दी…',
                                  hintStyle:
                                      TextStyle(color: textSecondary, fontSize: 13),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  isDense: true,
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                onSubmitted: _handleSend,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.mic_rounded,
                                color: accentBlue, size: 20),
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const VoiceWeatherScreen())),
                            tooltip: 'Voice input',
                            padding: const EdgeInsets.all(8),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Send button with animated state
                  GestureDetector(
                    onTap: () => _handleSend(_textController.text),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: accentBlue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accentBlue.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.send_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);
}

  Widget _buildEmptyState(
    Color textPrimary,
    Color textSecondary,
    Color borderColor,
    Color surfaceColor,
    bool isDark,
    Color accentBlue,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        children: [
          // Hero illustration
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  accentBlue.withValues(alpha: 0.18),
                  accentBlue.withValues(alpha: 0.04),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(Icons.auto_awesome_rounded,
                  color: accentBlue, size: 40),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'WeatherGPT',
            style: TextStyle(
                color: textPrimary, fontSize: 22, fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Your AI meteorologist for India — powered by IMD data, NWP models, and Gemini AI.',
            style: TextStyle(color: textSecondary, fontSize: 13, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          // Sample prompts card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded,
                        color: AppColors.alertYellow, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Try asking',
                      style: TextStyle(
                          color: textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildSamplePrompt('🌧️', '"Will it rain tomorrow in my village?"',
                    accentBlue, textPrimary),
                _buildSamplePrompt('🌾', '"Is today safe for agricultural spraying?"',
                    accentBlue, textPrimary),
                _buildSamplePrompt('🚨', '"Any cyclone or flood warnings nearby?"',
                    accentBlue, textPrimary),
                _buildSamplePrompt('⛵', '"Is it safe for coastal fishing today?"',
                    accentBlue, textPrimary),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Capabilities row
          Row(
            children: [
              _buildCapabilityPill('🇮🇳 India-wide', isDark, borderColor, textSecondary),
              const SizedBox(width: 8),
              _buildCapabilityPill('🌐 3 Languages', isDark, borderColor, textSecondary),
              const SizedBox(width: 8),
              _buildCapabilityPill('📡 Live Data', isDark, borderColor, textSecondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSamplePrompt(
      String emoji, String text, Color accentBlue, Color textPrimary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          // Extract the text inside quotes
          final match = RegExp(r'"([^"]+)"').firstMatch(text);
          if (match != null) _handleSend(match.group(1)!);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                      color: accentBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Icon(Icons.north_east_rounded, color: accentBlue, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCapabilityPill(
      String label, bool isDark, Color borderColor, Color textSecondary) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceHL(isDark),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  final Color borderColor;
  final Color textColor;

  const _QuickChip({
    required this.emoji,
    required this.label,
    required this.onTap,
    required this.isDark,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceHL(isDark),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                  color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
