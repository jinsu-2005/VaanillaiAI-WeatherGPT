enum UrbanFloodRiskTier {
  low,
  moderate,
  high,
  severe,
}

class UrbanFloodResult {
  final int riskScore; // 0 to 100
  final UrbanFloodRiskTier tier;
  final String tierName;
  final double estimatedWaterDepthInches;
  final double runoffRateMmPerHour;
  final double drainSurplusMmPerHour;
  final String underpassStatus;
  final String twoWheelerDirective;
  final String carDirective;
  final String pedestrianDirective;
  final String summaryText;

  const UrbanFloodResult({
    required this.riskScore,
    required this.tier,
    required this.tierName,
    required this.estimatedWaterDepthInches,
    required this.runoffRateMmPerHour,
    required this.drainSurplusMmPerHour,
    required this.underpassStatus,
    required this.twoWheelerDirective,
    required this.carDirective,
    required this.pedestrianDirective,
    required this.summaryText,
  });
}

class HourlyFloodRiskPoint {
  final String time;
  final double rainMm;
  final int riskScore;
  final UrbanFloodRiskTier tier;

  const HourlyFloodRiskPoint({
    required this.time,
    required this.rainMm,
    required this.riskScore,
    required this.tier,
  });
}

class UrbanFloodCalculator {
  /// Standard urban stormwater design discharge capacity for Indian municipal drains (mm/hour).
  static const double defaultDrainCapacity = 20.0;

  /// Default urban impervious surface fraction (asphalt, concrete, rooftop density).
  static const double defaultImperviousRatio = 0.75;

  /// Calculate urban waterlogging risk score and transit safety directives
  /// using the Rational Runoff formula: Q = C * I, net excess = max(0, Q - D_cap).
  static UrbanFloodResult calculate({
    required double peakHourlyRainMm,
    required double threeHourCumulativeMm,
    double drainCapacityMmPerHour = defaultDrainCapacity,
    double imperviousSurfaceRatio = defaultImperviousRatio,
  }) {
    final rainRate = peakHourlyRainMm.clamp(0.0, 150.0);
    final rain3h = threeHourCumulativeMm.clamp(0.0, 300.0);
    final c = imperviousSurfaceRatio.clamp(0.2, 0.95);
    final dCap = drainCapacityMmPerHour.clamp(5.0, 50.0);

    // Runoff generation rate (mm/h)
    final runoffRate = rainRate * c;
    final surplusRate = (runoffRate - dCap).clamp(0.0, 150.0);

    // Compute composite inundation score (0 to 100)
    // Weighted combination of:
    // - Peak rain intensity vs drain capacity (50% weight)
    // - 3-hour antecedent / expected accumulation (35% weight)
    // - Instantaneous surplus rate (15% weight)
    double scoreRaw = 0.0;

    // Intensity component (0-50 pts)
    if (rainRate > 0) {
      scoreRaw += (rainRate / 40.0) * 50.0;
    }

    // 3h Accumulation component (0-35 pts)
    if (rain3h > 0) {
      scoreRaw += (rain3h / 65.0) * 35.0;
    }

    // Direct surplus penalty (0-15 pts)
    if (surplusRate > 0) {
      scoreRaw += (surplusRate / 20.0) * 15.0;
    }

    final int score = scoreRaw.round().clamp(0, 100);

    // Determine Risk Tier
    final UrbanFloodRiskTier tier;
    final String tierName;
    final double estDepthInches;
    final String underpassStatus;
    final String twoWheeler;
    final String car;
    final String pedestrian;
    final String summary;

    if (score >= 76) {
      tier = UrbanFloodRiskTier.severe;
      tierName = 'Severe Inundation Hazard';
      estDepthInches = (6.0 + (score - 75) * 0.28).clamp(6.0, 16.0);
      underpassStatus = 'Submerged / Impassable';
      twoWheeler = '🚫 DO NOT RIDE: High risk of engine hydro-lock, loss of balance, and open manhole traps.';
      car = '🚫 AVOID ARTERIAL ROADS: Water above wheel hubs will enter exhaust/air intake and cause permanent engine damage.';
      pedestrian = '⚡ ELECTRICAL HAZARD: Stay far away from submerged street-lights, transformer plinths, and roadside junction boxes.';
      summary = 'Flash flooding and deep street pooling (>6 inches) underway. City drains overwhelmed. Avoid all non-essential road travel.';
    } else if (score >= 51) {
      tier = UrbanFloodRiskTier.high;
      tierName = 'High Waterlogging Risk';
      estDepthInches = (2.5 + (score - 50) * 0.14).clamp(2.5, 6.0);
      underpassStatus = 'Flooding / Avoid';
      twoWheeler = '⚠️ SEVERE HAZARD: Water level near silencer pipe. Aquaplaning and submerged potholes present major spill risk.';
      car = '⚠️ PROCEED WITH CAUTION: Avoid subways, underpasses, and road shoulders. Drive only in central lanes in low gear.';
      pedestrian = '⚠️ Walk only on elevated footpaths. Watch out for uncovered stormwater drains and swift curb currents.';
      summary = 'Extensive street waterlogging (3 to 6 inches) at road intersections and low-lying railway subways. Expect traffic gridlock.';
    } else if (score >= 26) {
      tier = UrbanFloodRiskTier.moderate;
      tierName = 'Moderate Waterlogging Risk';
      estDepthInches = (0.5 + (score - 25) * 0.08).clamp(0.5, 2.5);
      underpassStatus = 'Caution / Slow Traffic';
      twoWheeler = 'Moderate puddling on curbs. Reduce riding speed to avoid skidding on wet road markings and tar joints.';
      car = 'Maintain safe braking distance. Slow down when approaching puddles to avoid blinding oncoming traffic with spray.';
      pedestrian = 'Curb overflow and shallow puddles. Wear water-resistant footwear and carry umbrella/rain gear.';
      summary = 'Local street ponding and roadside gutter overflow. Traffic slow on major routes, but arterial corridors remain passable.';
    } else {
      tier = UrbanFloodRiskTier.low;
      tierName = 'Low Risk';
      estDepthInches = 0.0;
      underpassStatus = 'Open / Normal Flow';
      twoWheeler = 'Standard road conditions. Normal riding vigilance advised.';
      car = 'Normal street drainage functioning efficiently. No transit delays expected.';
      pedestrian = 'Normal pedestrian transit.';
      summary = 'Municipal stormwater drains running within safe design capacity. No significant water stagnation expected.';
    }

    return UrbanFloodResult(
      riskScore: score,
      tier: tier,
      tierName: tierName,
      estimatedWaterDepthInches: double.parse(estDepthInches.toStringAsFixed(1)),
      runoffRateMmPerHour: double.parse(runoffRate.toStringAsFixed(1)),
      drainSurplusMmPerHour: double.parse(surplusRate.toStringAsFixed(1)),
      underpassStatus: underpassStatus,
      twoWheelerDirective: twoWheeler,
      carDirective: car,
      pedestrianDirective: pedestrian,
      summaryText: summary,
    );
  }

  /// Calculate 24-hour hourly flood risk timeline from hourly precipitation forecasts.
  static List<HourlyFloodRiskPoint> calculateHourlyTimeline(List<dynamic> hourlyList) {
    final List<HourlyFloodRiskPoint> points = [];

    for (int i = 0; i < hourlyList.length && i < 24; i++) {
      final h = hourlyList[i];
      final timeStr = h.time?.toString() ?? 'T00:00';
      final rainMm = (h.precipitation as num?)?.toDouble() ?? 0.0;

      // Estimate 3h window around this hour
      double threeHourSum = rainMm;
      if (i > 0) {
        threeHourSum += ((hourlyList[i - 1].precipitation as num?)?.toDouble() ?? 0.0);
      }
      if (i + 1 < hourlyList.length) {
        threeHourSum += ((hourlyList[i + 1].precipitation as num?)?.toDouble() ?? 0.0);
      }

      final res = calculate(
        peakHourlyRainMm: rainMm,
        threeHourCumulativeMm: threeHourSum,
      );

      points.add(HourlyFloodRiskPoint(
        time: timeStr.split('T').last,
        rainMm: rainMm,
        riskScore: res.riskScore,
        tier: res.tier,
      ));
    }

    return points;
  }
}
