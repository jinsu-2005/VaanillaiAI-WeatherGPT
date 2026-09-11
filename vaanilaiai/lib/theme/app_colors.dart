import 'package:flutter/material.dart';

class AppColors {
  // Brand Blue
  static const Color brandBlue = Color(0xFF2563EB);       // #2563EB Royal Blue
  static const Color brandBlueLight = Color(0xFF3B82F6);  // #3B82F6 Vibrant Blue
  static const Color brandBlueDark = Color(0xFF1D4ED8);
  static const Color brandBlueContainer = Color(0xFFDBEAFE);

  // Light Mode Colors
  static const Color lightBackground = Color(0xFFF1F5F9);  // Soft cool grey
  static const Color lightSurface = Color(0xFFFFFFFF);     // Pure White Cards
  static const Color lightSurfaceHighlight = Color(0xFFF8FAFC);
  static const Color lightOutline = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightTextTertiary = Color(0xFF94A3B8);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF0B111E);   // Deep Midnight Slate
  static const Color darkSurface = Color(0xFF162032);      // Elevated Dark Slate
  static const Color darkSurfaceHighlight = Color(0xFF1E2D44);
  static const Color darkOutline = Color(0xFF253349);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextTertiary = Color(0xFF64748B);

  // Alert Tiers (Exact reference colors)
  static const Color alertRed = Color(0xFFEF4444);         // Heavy Rain Warning
  static const Color alertRedBg = Color(0xFFFEE2E2);
  static const Color alertRedDarkBg = Color(0xFF451414);
  static const Color alertRedContainer = Color(0xFF451414);

  static const Color alertOrange = Color(0xFFF97316);      // Thunderstorm Alert
  static const Color alertOrangeBg = Color(0xFFFFEDD5);
  static const Color alertOrangeDarkBg = Color(0xFF45220C);
  static const Color alertOrangeContainer = Color(0xFF45220C);

  static const Color alertYellow = Color(0xFFEAB308);      // Fishermen Warning
  static const Color alertYellowBg = Color(0xFFFEF9C3);
  static const Color alertYellowDarkBg = Color(0xFF423208);
  static const Color alertYellowContainer = Color(0xFF423208);

  static const Color alertGreen = Color(0xFF10B981);       // Good AQI / Safe
  static const Color alertGreenBg = Color(0xFFD1FAE5);
  static const Color alertGreenDarkBg = Color(0xFF063321);
  static const Color alertGreenContainer = Color(0xFF063321);

  // Semantic Weather Icon Colors
  static const Color weatherSunny = Color(0xFFF59E0B);    // Amber — sunny/daytime
  static const Color weatherCloudy = Color(0xFF94A3B8);   // Slate — overcast/cloudy
  static const Color weatherRain = Color(0xFF3B82F6);     // Blue — rain/drizzle
  static const Color weatherStorm = Color(0xFF7C3AED);    // Violet — thunderstorm
  static const Color weatherSnow = Color(0xFFBAE6FD);     // Ice Blue — snow
  static const Color weatherFog = Color(0xFF9CA3AF);      // Grey — fog/mist

  // Legacy / Default theme aliases (dark-mode biased — prefer isDark ternary in widgets)
  static const Color aiCyan = Color(0xFF2563EB);
  static const Color aiContainer = Color(0xFFDBEAFE);
  static const Color onAiCyan = Colors.white;
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryContainer = Color(0xFF162032);
  static const Color surfaceContainer = Color(0xFF162032);
  static const Color surfaceContainerHigh = Color(0xFF1E2D44);
  static const Color surfaceDim = Color(0xFF0B111E);
  static const Color outline = Color(0xFF253349);
  static const Color outlineVariant = Color(0xFF334155);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF64748B);

  // Convenience helpers — use these in widgets instead of hardcoded aliases
  static Color surface(bool isDark) =>
      isDark ? darkSurface : lightSurface;
  static Color surfaceHL(bool isDark) =>
      isDark ? darkSurfaceHighlight : lightSurfaceHighlight;
  static Color border(bool isDark) =>
      isDark ? darkOutline : lightOutline;
  static Color textPrimaryC(bool isDark) =>
      isDark ? darkTextPrimary : lightTextPrimary;
  static Color textSecondaryC(bool isDark) =>
      isDark ? darkTextSecondary : lightTextSecondary;
  static Color textTertiaryC(bool isDark) =>
      isDark ? darkTextTertiary : lightTextTertiary;

  // Atmospheric Condition-Aware Backdrops & Glows
  static const Color glowSunny = Color(0xFFF59E0B);
  static const Color glowRain = Color(0xFF2563EB);
  static const Color glowStorm = Color(0xFF7C3AED);
  static const Color glowCloudy = Color(0xFF475569);
  static const Color glowNight = Color(0xFF312E81);
  static const Color glowSnow = Color(0xFF0284C7);

  /// Resolves the atmospheric ambient glow color based on condition and time of day
  static Color atmosphericGlow(String conditionIcon, bool isDay) {
    final key = conditionIcon.toLowerCase();
    if (!isDay) return glowNight;
    if (key.contains('sunny') || key.contains('clear')) return glowSunny;
    if (key.contains('thunder') || key.contains('storm')) return glowStorm;
    if (key.contains('rain') || key.contains('drizzle') || key.contains('shower')) return glowRain;
    if (key.contains('snow') || key.contains('ice')) return glowSnow;
    return glowCloudy;
  }

  /// Frosted glass card surface color with high-end translucency
  static Color glassCardBg(bool isDark) => isDark
      ? const Color(0xFF131C2D).withValues(alpha: 0.88)
      : Colors.white.withValues(alpha: 0.90);

  /// Specular rim highlight border
  static Color specularBorder(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.12)
      : Colors.white.withValues(alpha: 0.65);
}
