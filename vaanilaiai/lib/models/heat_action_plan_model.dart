class HeatwaveThermalMetricsModel {
  final double maxTempC;
  final double normalTempC;
  final double departureC;
  final int consecutiveHeatwaveDays;
  final double relativeHumidityPct;
  final double wetBulbTempC;
  final double nightMinTempC;

  const HeatwaveThermalMetricsModel({
    required this.maxTempC,
    required this.normalTempC,
    required this.departureC,
    required this.consecutiveHeatwaveDays,
    required this.relativeHumidityPct,
    required this.wetBulbTempC,
    required this.nightMinTempC,
  });

  factory HeatwaveThermalMetricsModel.fromJson(Map<String, dynamic> json) {
    return HeatwaveThermalMetricsModel(
      maxTempC: (json['max_temp_c'] as num?)?.toDouble() ?? 42.0,
      normalTempC: (json['normal_temp_c'] as num?)?.toDouble() ?? 40.0,
      departureC: (json['departure_c'] as num?)?.toDouble() ?? 2.0,
      consecutiveHeatwaveDays: (json['consecutive_heatwave_days'] as num?)?.toInt() ?? 1,
      relativeHumidityPct: (json['relative_humidity_pct'] as num?)?.toDouble() ?? 25.0,
      wetBulbTempC: (json['wet_bulb_temp_c'] as num?)?.toDouble() ?? 26.0,
      nightMinTempC: (json['night_min_temp_c'] as num?)?.toDouble() ?? 30.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'max_temp_c': maxTempC,
        'normal_temp_c': normalTempC,
        'departure_c': departureC,
        'consecutive_heatwave_days': consecutiveHeatwaveDays,
        'relative_humidity_pct': relativeHumidityPct,
        'wet_bulb_temp_c': wetBulbTempC,
        'night_min_temp_c': nightMinTempC,
      };
}

class SolarUvRadiationMetricsModel {
  final double uvIndex;
  final String uvCategory;
  final String peakUvHour;
  final double ozoneColumnDu;
  final double minimalErythemalDoseRateMedHr;
  final int timeToSunburnMinutes;
  final int recommendedSpf;

  const SolarUvRadiationMetricsModel({
    required this.uvIndex,
    required this.uvCategory,
    required this.peakUvHour,
    required this.ozoneColumnDu,
    required this.minimalErythemalDoseRateMedHr,
    required this.timeToSunburnMinutes,
    required this.recommendedSpf,
  });

  factory SolarUvRadiationMetricsModel.fromJson(Map<String, dynamic> json) {
    return SolarUvRadiationMetricsModel(
      uvIndex: (json['uv_index'] as num?)?.toDouble() ?? 8.0,
      uvCategory: json['uv_category'] as String? ?? 'VERY_HIGH',
      peakUvHour: json['peak_uv_hour'] as String? ?? '11:30 - 15:00',
      ozoneColumnDu: (json['ozone_column_du'] as num?)?.toDouble() ?? 270.0,
      minimalErythemalDoseRateMedHr: (json['minimal_erythemal_dose_rate_med_hr'] as num?)?.toDouble() ?? 2.5,
      timeToSunburnMinutes: (json['time_to_sunburn_minutes'] as num?)?.toInt() ?? 20,
      recommendedSpf: (json['recommended_spf'] as num?)?.toInt() ?? 30,
    );
  }

  Map<String, dynamic> toJson() => {
        'uv_index': uvIndex,
        'uv_category': uvCategory,
        'peak_uv_hour': peakUvHour,
        'ozone_column_du': ozoneColumnDu,
        'minimal_erythemal_dose_rate_med_hr': minimalErythemalDoseRateMedHr,
        'time_to_sunburn_minutes': timeToSunburnMinutes,
        'recommended_spf': recommendedSpf,
      };
}

class MunicipalHeatDirectivesModel {
  final bool coolRoofInitiativeActive;
  final double solarReflectanceIndexSri;
  final String bocwLaborWorkSuspensionHours;
  final int activePyauWaterStations;
  final int hospitalHeatstrokeBeds;
  final bool emergencyCoolingIceBathReady;
  final int orsDistributionBooths;

  const MunicipalHeatDirectivesModel({
    required this.coolRoofInitiativeActive,
    required this.solarReflectanceIndexSri,
    required this.bocwLaborWorkSuspensionHours,
    required this.activePyauWaterStations,
    required this.hospitalHeatstrokeBeds,
    required this.emergencyCoolingIceBathReady,
    required this.orsDistributionBooths,
  });

  factory MunicipalHeatDirectivesModel.fromJson(Map<String, dynamic> json) {
    return MunicipalHeatDirectivesModel(
      coolRoofInitiativeActive: json['cool_roof_initiative_active'] as bool? ?? true,
      solarReflectanceIndexSri: (json['solar_reflectance_index_sri'] as num?)?.toDouble() ?? 78.0,
      bocwLaborWorkSuspensionHours: json['bocw_labor_work_suspension_hours'] as String? ?? '12:00 - 15:00',
      activePyauWaterStations: (json['active_pyau_water_stations'] as num?)?.toInt() ?? 100,
      hospitalHeatstrokeBeds: (json['hospital_heatstroke_beds'] as num?)?.toInt() ?? 25,
      emergencyCoolingIceBathReady: json['emergency_cooling_ice_bath_ready'] as bool? ?? true,
      orsDistributionBooths: (json['ors_distribution_booths'] as num?)?.toInt() ?? 50,
    );
  }

  Map<String, dynamic> toJson() => {
        'cool_roof_initiative_active': coolRoofInitiativeActive,
        'solar_reflectance_index_sri': solarReflectanceIndexSri,
        'bocw_labor_work_suspension_hours': bocwLaborWorkSuspensionHours,
        'active_pyau_water_stations': activePyauWaterStations,
        'hospital_heatstroke_beds': hospitalHeatstrokeBeds,
        'emergency_cooling_ice_bath_ready': emergencyCoolingIceBathReady,
        'ors_distribution_booths': orsDistributionBooths,
      };
}

class HeatActionHotspotZoneModel {
  final String zoneId;
  final String zoneName;
  final String state;
  final String district;
  final double latitude;
  final double longitude;
  final String alertTier;
  final HeatwaveThermalMetricsModel thermalMetrics;
  final SolarUvRadiationMetricsModel uvMetrics;
  final MunicipalHeatDirectivesModel municipalDirectives;
  final List<String> vulnerableDemographics;
  final Map<String, String> localizedBulletins;

  const HeatActionHotspotZoneModel({
    required this.zoneId,
    required this.zoneName,
    required this.state,
    required this.district,
    required this.latitude,
    required this.longitude,
    required this.alertTier,
    required this.thermalMetrics,
    required this.uvMetrics,
    required this.municipalDirectives,
    required this.vulnerableDemographics,
    required this.localizedBulletins,
  });

  factory HeatActionHotspotZoneModel.fromJson(Map<String, dynamic> json) {
    return HeatActionHotspotZoneModel(
      zoneId: json['zone_id'] as String? ?? 'phalodi_churu_thar',
      zoneName: json['zone_name'] as String? ?? 'Phalodi & Churu Desert Corridor',
      state: json['state'] as String? ?? 'Rajasthan',
      district: json['district'] as String? ?? 'Phalodi / Churu',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 27.1300,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 72.3600,
      alertTier: json['alert_tier'] as String? ?? 'EXTREME_HEAT_RED',
      thermalMetrics: HeatwaveThermalMetricsModel.fromJson(
        json['thermal_metrics'] as Map<String, dynamic>? ?? {},
      ),
      uvMetrics: SolarUvRadiationMetricsModel.fromJson(
        json['uv_metrics'] as Map<String, dynamic>? ?? {},
      ),
      municipalDirectives: MunicipalHeatDirectivesModel.fromJson(
        json['municipal_directives'] as Map<String, dynamic>? ?? {},
      ),
      vulnerableDemographics: (json['vulnerable_demographics'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['Outdoor agricultural and construction laborers', 'Elderly residents and children', 'Gig workers'],
      localizedBulletins: (json['localized_bulletins'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v.toString()),
          ) ??
          const {},
    );
  }

  Map<String, dynamic> toJson() => {
        'zone_id': zoneId,
        'zone_name': zoneName,
        'state': state,
        'district': district,
        'latitude': latitude,
        'longitude': longitude,
        'alert_tier': alertTier,
        'thermal_metrics': thermalMetrics.toJson(),
        'uv_metrics': uvMetrics.toJson(),
        'municipal_directives': municipalDirectives.toJson(),
        'vulnerable_demographics': vulnerableDemographics,
        'localized_bulletins': localizedBulletins,
      };
}

class HeatActionPlanResponseModel {
  final String timestamp;
  final String bulletinNumber;
  final String provenance;
  final HeatActionHotspotZoneModel selectedZone;
  final List<HeatActionHotspotZoneModel> allZones;
  final Map<String, String> vernacularBulletins;
  final bool isOfflineCached;

  const HeatActionPlanResponseModel({
    required this.timestamp,
    required this.bulletinNumber,
    required this.provenance,
    required this.selectedZone,
    required this.allZones,
    required this.vernacularBulletins,
    this.isOfflineCached = false,
  });

  factory HeatActionPlanResponseModel.fromJson(
    Map<String, dynamic> json, {
    bool isOfflineCached = false,
  }) {
    return HeatActionPlanResponseModel(
      timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      bulletinNumber: json['bulletin_number'] as String? ?? 'NDMA-IMD/HAP-UVIE/202609-PHALOD',
      provenance: json['provenance'] as String? ??
          'National Disaster Management Authority (NDMA) & IMD National Heat Action Plan Framework',
      selectedZone: HeatActionHotspotZoneModel.fromJson(
        json['selected_zone'] as Map<String, dynamic>? ?? {},
      ),
      allZones: (json['all_zones'] as List<dynamic>?)
              ?.map((e) => HeatActionHotspotZoneModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      vernacularBulletins: (json['vernacular_bulletins'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v.toString()),
          ) ??
          const {},
      isOfflineCached: isOfflineCached || (json['is_offline_cached'] as bool? ?? false),
    );
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp,
        'bulletin_number': bulletinNumber,
        'provenance': provenance,
        'selected_zone': selectedZone.toJson(),
        'all_zones': allZones.map((e) => e.toJson()).toList(),
        'vernacular_bulletins': vernacularBulletins,
        'is_offline_cached': isOfflineCached,
      };

  HeatActionPlanResponseModel copyWithOfflineCached(bool cached) {
    return HeatActionPlanResponseModel(
      timestamp: timestamp,
      bulletinNumber: bulletinNumber,
      provenance: provenance,
      selectedZone: selectedZone,
      allZones: allZones,
      vernacularBulletins: vernacularBulletins,
      isOfflineCached: cached,
    );
  }

  static HeatActionPlanResponseModel defaultFallback() {
    final defaultZone = HeatActionHotspotZoneModel(
      zoneId: 'phalodi_churu_thar',
      zoneName: 'Phalodi & Churu Arid Desert Corridor',
      state: 'Rajasthan',
      district: 'Phalodi / Churu',
      latitude: 27.1300,
      longitude: 72.3600,
      alertTier: 'EXTREME_HEAT_RED',
      thermalMetrics: const HeatwaveThermalMetricsModel(
        maxTempC: 49.8,
        normalTempC: 42.0,
        departureC: 7.8,
        consecutiveHeatwaveDays: 6,
        relativeHumidityPct: 18.0,
        wetBulbTempC: 26.5,
        nightMinTempC: 34.2,
      ),
      uvMetrics: const SolarUvRadiationMetricsModel(
        uvIndex: 13.5,
        uvCategory: 'EXTREME',
        peakUvHour: '11:30 - 15:30',
        ozoneColumnDu: 260.0,
        minimalErythemalDoseRateMedHr: 3.2,
        timeToSunburnMinutes: 12,
        recommendedSpf: 50,
      ),
      municipalDirectives: const MunicipalHeatDirectivesModel(
        coolRoofInitiativeActive: true,
        solarReflectanceIndexSri: 82.0,
        bocwLaborWorkSuspensionHours: '11:00 - 16:00 (Mandatory Afternoon Halt)',
        activePyauWaterStations: 185,
        hospitalHeatstrokeBeds: 45,
        emergencyCoolingIceBathReady: true,
        orsDistributionBooths: 92,
      ),
      vulnerableDemographics: const [
        'Agricultural farm laborers & pastoralists',
        'Elderly persons living in tin/asbestos roof homes',
        'Brick kiln workers & outdoor manual laborers',
        'Chronic kidney disease & cardiovascular patients',
      ],
      localizedBulletins: const {
        'en': 'RED ALERT: Extreme severe heatwave emergency in Phalodi corridor (49.8°C, departure +7.8°C). Mandatory suspension of all outdoor construction work between 11:00 AM and 04:00 PM. High risk of exertional heatstroke. Cool roof shelters and ice-bath triage activated.',
        'hi': 'लाल चेतावनी: फलोदी और चुरु क्षेत्र में भीषण लू की आपात स्थिति (49.8°C)। दोपहर 11 बजे से शाम 4 बजे तक निर्माण कार्य पर पूर्ण प्रतिबंध। लू और हीटस्ट्रोक से बचाव के लिए ओआरएस पिएं और ठंडे आश्रयों में रहें।',
      },
    );

    final ahmedabadZone = HeatActionHotspotZoneModel(
      zoneId: 'ahmedabad_metropolitan',
      zoneName: 'Ahmedabad Municipal Corporation (AMC Heat Action Plan)',
      state: 'Gujarat',
      district: 'Ahmedabad',
      latitude: 23.0225,
      longitude: 72.5714,
      alertTier: 'SEVERE_HEAT_ALERT_ORANGE',
      thermalMetrics: const HeatwaveThermalMetricsModel(
        maxTempC: 44.2,
        normalTempC: 40.5,
        departureC: 3.7,
        consecutiveHeatwaveDays: 4,
        relativeHumidityPct: 32.0,
        wetBulbTempC: 28.1,
        nightMinTempC: 30.5,
      ),
      uvMetrics: const SolarUvRadiationMetricsModel(
        uvIndex: 11.8,
        uvCategory: 'EXTREME',
        peakUvHour: '12:00 - 15:00',
        ozoneColumnDu: 268.0,
        minimalErythemalDoseRateMedHr: 2.8,
        timeToSunburnMinutes: 14,
        recommendedSpf: 50,
      ),
      municipalDirectives: const MunicipalHeatDirectivesModel(
        coolRoofInitiativeActive: true,
        solarReflectanceIndexSri: 84.5,
        bocwLaborWorkSuspensionHours: '12:00 - 16:00 (AMC Directive)',
        activePyauWaterStations: 420,
        hospitalHeatstrokeBeds: 80,
        emergencyCoolingIceBathReady: true,
        orsDistributionBooths: 210,
      ),
      vulnerableDemographics: const [
        'Urban slum residents in non-insulated tin shanties',
        'Traffic police personnel and street vendors',
        'Gig delivery workers and auto-rickshaw drivers',
        'Infants, pregnant women, and geriatric citizens',
      ],
      localizedBulletins: const {
        'en': 'ORANGE ALERT: AMC Heat Action Plan active across Ahmedabad (44.2°C). 420 municipal Pyau kiosks activated. Afternoon labor halted 12:00-16:00.',
        'gu': 'ઓરેન્જ એલર્ટ: અમદાવાદ મ્યુનિસિપલ કોર્પોરેશન હીટ એક્શન પ્લાન સક્રિય (44.2°C). બપોરે 12 થી 4 દરમિયાન ખુલ્લામાં મજૂરી કામ બંધ રાખો. પુષ્કળ પાણી અને છાશ પીવો.',
      },
    );

    return HeatActionPlanResponseModel(
      timestamp: DateTime.now().toIso8601String(),
      bulletinNumber: 'NDMA-IMD/HAP-UVIE/202609-PHALOD',
      provenance: 'National Disaster Management Authority (NDMA) & IMD National Heat Action Plan Framework',
      selectedZone: defaultZone,
      allZones: [defaultZone, ahmedabadZone],
      vernacularBulletins: defaultZone.localizedBulletins,
      isOfflineCached: true,
    );
  }
}
