import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../theme/app_colors.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessageModel message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUser = message.role == 'user';

    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkOutline : AppColors.lightOutline;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              margin: const EdgeInsets.only(top: 2, right: 10),
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.brandBlue,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width >= 900
                    ? 680
                    : MediaQuery.of(context).size.width * 0.82,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isUser ? null : surfaceColor,
                gradient: isUser
                    ? const LinearGradient(
                        colors: [AppColors.brandBlue, Color(0xFF1D4ED8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                border: Border.all(
                  color: isUser
                      ? AppColors.brandBlue
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : borderColor),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isUser
                        ? AppColors.brandBlue.withValues(alpha: 0.25)
                        : (isDark
                            ? Colors.black.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.04)),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormattedContent(message.content, isUser, textPrimary, textSecondary),
                  if (message.weatherCard != null) ...[
                    const SizedBox(height: 12),
                    _buildWeatherCard(message.weatherCard!, isDark, isUser, surfaceColor, borderColor, textPrimary, textSecondary),
                  ],
                  if (message.citations.isNotEmpty && !isUser) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: message.citations.map((cite) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurfaceHighlight : AppColors.lightSurfaceHighlight,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: borderColor, width: 0.5),
                          ),
                          child: Text(
                            '📌 $cite',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormattedContent(String rawText, bool isUser, Color textPrimary, Color textSecondary) {
    if (isUser) {
      return Text(
        rawText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          height: 1.45,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    // Clean any triple asterisks *** or raw header hashes #
    String cleaned = rawText.replaceAll(RegExp(r'\*{3,}'), '**');
    cleaned = cleaned.replaceAll(RegExp(r'#{1,6}\s*'), '');

    final lines = cleaned.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) {
        if (i > 0 && i < lines.length - 1) {
          widgets.add(const SizedBox(height: 6));
        }
        continue;
      }

      final isBullet = line.startsWith('•') || line.startsWith('- ') || line.startsWith('* ');
      String content = line;
      if (isBullet) {
        content = line.replaceFirst(RegExp(r'^[•\-\*]\s*'), '');
      }

      final spans = _parseInlineSpans(content, textPrimary, textSecondary);

      if (isBullet) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6, right: 8),
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: AppColors.brandBlue,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(children: spans),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: RichText(
              text: TextSpan(children: spans),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  List<TextSpan> _parseInlineSpans(String text, Color textPrimary, Color textSecondary) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex, match.start),
            style: TextStyle(color: textPrimary, fontSize: 14, height: 1.45),
          ),
        );
      }

      final boldText = match.group(1) ?? '';
      spans.add(
        TextSpan(
          text: boldText,
          style: TextStyle(
            color: textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.45,
          ),
        ),
      );
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastIndex),
          style: TextStyle(color: textPrimary, fontSize: 14, height: 1.45),
        ),
      );
    }

    return spans;
  }

  Widget _buildWeatherCard(
    WeatherCardSummaryModel card,
    bool isDark,
    bool isUser,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUser
            ? AppColors.brandBlueDark
            : (isDark ? AppColors.darkSurfaceHighlight : AppColors.brandBlueContainer),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUser ? Colors.white24 : AppColors.brandBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.locationName,
                style: TextStyle(
                  color: isUser ? Colors.white : textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                card.conditionText,
                style: TextStyle(
                  color: isUser ? Colors.white70 : textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Text(
            '${card.temperature.round()}°C',
            style: TextStyle(
              color: isUser ? Colors.white : AppColors.brandBlue,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
