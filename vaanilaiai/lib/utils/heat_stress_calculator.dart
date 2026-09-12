import 'dart:math' as math;
import 'package:flutter/material.dart';

enum HeatStressCategory {
  low,
  caution,
  extremeCaution,
  danger,
}

class HeatStressData {
  final double temperature;
  final int humidity;
  final double heatIndex;
  final double wetBulbTemperature;
  final HeatStressCategory category;
  final String categoryName;
  final Color color;
  final String advisory;
  final String workRestGuidance;
  final String hydrationGuidance;

  const HeatStressData({
    required this.temperature,
    required this.humidity,
    required this.heatIndex,
    required this.wetBulbTemperature,
    required this.category,
    required this.categoryName,
    required this.color,
    required this.advisory,
    required this.workRestGuidance,
    required this.hydrationGuidance,
  });
}

class HeatStressCalculator {
  /// Calculates Steadman's Heat Index and Stull's Wet-Bulb temperature.
  static HeatStressData calculate({
    required double temperatureC,
    required int humidityPercent,
  }) {
    final t = temperatureC;
    final rh = humidityPercent.clamp(1, 100).toDouble();

    // 1. Calculate Heat Index
    double hi;
    if (t < 26.7) {
      hi = t;
    } else {
      final tf = t * 1.8 + 32;
      final hiF = -42.379 +
          2.04901523 * tf +
          10.14333127 * rh -
          0.22475541 * tf * rh -
          0.00683783 * tf * tf -
          0.05481717 * rh * rh +
          0.00122874 * tf * tf * rh +
          0.00085282 * tf * rh * rh -
          0.00000199 * tf * tf * rh * rh;
      hi = (hiF - 32) / 1.8;
      if (hi < t) hi = t;
    }

    // 2. Calculate Stull (2011) Wet-Bulb Temperature
    final tw = t * math.atan(0.151977 * math.sqrt(rh + 8.313659)) +
        math.atan(t + rh) -
        math.atan(rh - 1.676331) +
        0.00391838 * math.pow(rh, 1.5) * math.atan(0.023101 * rh) -
        4.686035;

    // 3. Classify thermal stress
    HeatStressCategory category;
    String categoryName;
    Color color;
    String advisory;
    String workRestGuidance;
    String hydrationGuidance;

    if (hi >= 54.0 || tw >= 32.0) {
      category = HeatStressCategory.danger;
      categoryName = 'Danger';
      color = const Color(0xFFFF1744);
      advisory = 'Heat stroke imminent with prolonged outdoor exposure. Suspend intense field work during peak hours.';
      workRestGuidance = 'Suspend direct sun labor. Seek shaded, ventilated shelter immediately.';
      hydrationGuidance = 'Drink 1L cool electrolyte or saline water per hour. Check on elderly and workers.';
    } else if (hi >= 41.0 || tw >= 29.0) {
      category = HeatStressCategory.extremeCaution;
      categoryName = 'Extreme Caution';
      color = const Color(0xFFFF9100);
      advisory = 'Heat cramps and exhaustion likely with physical exertion. Schedule farming operations before 10 AM or after 4 PM.';
      workRestGuidance = '30 minutes work / 30 minutes rest under shaded tree or canopy.';
      hydrationGuidance = 'Drink 1L water or ORS per hour. Avoid sugary beverages.';
    } else if (hi >= 32.0 || tw >= 26.0) {
      category = HeatStressCategory.caution;
      categoryName = 'Caution';
      color = const Color(0xFFFFB300);
      advisory = 'Fatigue possible with prolonged outdoor activity. Watch for mild dehydration symptoms.';
      workRestGuidance = '45 minutes work / 15 minutes rest in shade.';
      hydrationGuidance = 'Drink 750ml water or lemon-salt water per hour.';
    } else {
      category = HeatStressCategory.low;
      categoryName = 'Low Stress';
      color = const Color(0xFF00E676);
      advisory = 'Thermal conditions are comfortable for normal outdoor activities and farming.';
      workRestGuidance = 'Normal work schedule with routine breaks.';
      hydrationGuidance = 'Maintain standard hydration (0.5L water per hour of active labor).';
    }

    return HeatStressData(
      temperature: t,
      humidity: humidityPercent,
      heatIndex: hi,
      wetBulbTemperature: tw,
      category: category,
      categoryName: categoryName,
      color: color,
      advisory: advisory,
      workRestGuidance: workRestGuidance,
      hydrationGuidance: hydrationGuidance,
    );
  }
}
