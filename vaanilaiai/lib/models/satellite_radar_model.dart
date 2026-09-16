import 'dart:math' as math;

class DwrRadarStationModel {
  final String stationId;
  final String name;
  final String state;
  final double latitude;
  final double longitude;
  final String band;
  final double frequencyGhz;
  final int maxRangeKm;
  final String status;
  final DateTime lastSweepUtc;
  final double? peakReflectivityDbz;
  final int convectiveCellsDetected;
  final double? stormMotionHeadingDeg;
  final double? stormMotionSpeedKmh;
  final String? stationCode;
  final String? radarImageUrl;

  const DwrRadarStationModel({
    required this.stationId,
    required this.name,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.band,
    required this.frequencyGhz,
    required this.maxRangeKm,
    required this.status,
    required this.lastSweepUtc,
    this.peakReflectivityDbz,
    this.convectiveCellsDetected = 0,
    this.stormMotionHeadingDeg,
    this.stormMotionSpeedKmh,
    this.stationCode,
    this.radarImageUrl,
  });

  factory DwrRadarStationModel.fromJson(Map<String, dynamic> json) {
    final code = json['station_code'] as String?;
    final imgUrl = json['radar_image_url'] as String? ??
        (code != null ? 'https://mausam.imd.gov.in/Radar/caz_$code.gif' : null);

    return DwrRadarStationModel(
      stationId: json['station_id'] as String? ?? '',
      name: json['name'] as String? ?? 'IMD DWR Station',
      state: json['state'] as String? ?? 'India',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      band: json['band'] as String? ?? 'S-band (10cm)',
      frequencyGhz: (json['frequency_ghz'] as num?)?.toDouble() ?? 2.8,
      maxRangeKm: (json['max_range_km'] as num?)?.toInt() ?? 250,
      status: json['status'] as String? ?? 'Operational',
      lastSweepUtc: json['last_sweep_utc'] != null
          ? DateTime.tryParse(json['last_sweep_utc'].toString()) ?? DateTime.now()
          : DateTime.now(),
      peakReflectivityDbz: (json['peak_reflectivity_dbz'] as num?)?.toDouble(),
      convectiveCellsDetected: (json['convective_cells_detected'] as num?)?.toInt() ?? 0,
      stormMotionHeadingDeg: (json['storm_motion_heading_deg'] as num?)?.toDouble(),
      stormMotionSpeedKmh: (json['storm_motion_speed_kmh'] as num?)?.toDouble(),
      stationCode: code,
      radarImageUrl: imgUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'station_id': stationId,
      'name': name,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,
      'band': band,
      'frequency_ghz': frequencyGhz,
      'max_range_km': maxRangeKm,
      'status': status,
      'last_sweep_utc': lastSweepUtc.toIso8601String(),
      'peak_reflectivity_dbz': peakReflectivityDbz,
      'convective_cells_detected': convectiveCellsDetected,
      'storm_motion_heading_deg': stormMotionHeadingDeg,
      'storm_motion_speed_kmh': stormMotionSpeedKmh,
      'station_code': stationCode,
      'radar_image_url': radarImageUrl,
    };
  }
}

class MosdacSatelliteProductModel {
  final String productId;
  final String name;
  final String satellite;
  final String sensor;
  final double resolutionKm;
  final String channelWavelength;
  final DateTime latestScanTimeUtc;
  final int refreshIntervalMin;
  final String colorScaleUnit;
  final List<String> colorScaleLabels;
  final List<String> paletteGradient;
  final String synopticInterpretation;
  final String? tileOrImageUrl;
  final List<double> bounds;

  const MosdacSatelliteProductModel({
    required this.productId,
    required this.name,
    required this.satellite,
    required this.sensor,
    required this.resolutionKm,
    required this.channelWavelength,
    required this.latestScanTimeUtc,
    required this.refreshIntervalMin,
    required this.colorScaleUnit,
    required this.colorScaleLabels,
    required this.paletteGradient,
    required this.synopticInterpretation,
    this.tileOrImageUrl,
    this.bounds = const [-10.0, 45.0, 45.0, 110.0],
  });

  factory MosdacSatelliteProductModel.fromJson(Map<String, dynamic> json) {
    final labelsRaw = json['color_scale_labels'] as List? ?? [];
    final gradientRaw = json['palette_gradient'] as List? ?? [];
    final boundsRaw = json['bounds'] as List? ?? [];

    return MosdacSatelliteProductModel(
      productId: json['product_id'] as String? ?? '',
      name: json['name'] as String? ?? 'INSAT-3DR Channel',
      satellite: json['satellite'] as String? ?? 'INSAT-3DR Geostationary (74°E)',
      sensor: json['sensor'] as String? ?? 'Imager',
      resolutionKm: (json['resolution_km'] as num?)?.toDouble() ?? 4.0,
      channelWavelength: json['channel_wavelength'] as String? ?? '',
      latestScanTimeUtc: json['latest_scan_time_utc'] != null
          ? DateTime.tryParse(json['latest_scan_time_utc'].toString()) ?? DateTime.now()
          : DateTime.now(),
      refreshIntervalMin: (json['refresh_interval_min'] as num?)?.toInt() ?? 15,
      colorScaleUnit: json['color_scale_unit'] as String? ?? '',
      colorScaleLabels: labelsRaw.map((e) => e.toString()).toList(),
      paletteGradient: gradientRaw.map((e) => e.toString()).toList(),
      synopticInterpretation: json['synoptic_interpretation'] as String? ?? '',
      tileOrImageUrl: json['tile_or_image_url'] as String?,
      bounds: boundsRaw.map((e) => (e as num).toDouble()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'name': name,
      'satellite': satellite,
      'sensor': sensor,
      'resolution_km': resolutionKm,
      'channel_wavelength': channelWavelength,
      'latest_scan_time_utc': latestScanTimeUtc.toIso8601String(),
      'refresh_interval_min': refreshIntervalMin,
      'color_scale_unit': colorScaleUnit,
      'color_scale_labels': colorScaleLabels,
      'palette_gradient': paletteGradient,
      'synoptic_interpretation': synopticInterpretation,
      'tile_or_image_url': tileOrImageUrl,
      'bounds': bounds,
    };
  }
}

class SatelliteRadarOverviewModel {
  final List<DwrRadarStationModel> dwrStations;
  final List<MosdacSatelliteProductModel> satelliteProducts;
  final DwrRadarStationModel? nearestDwrStation;
  final double? distanceToNearestRadarKm;
  final String localRadarCoverageStatus;
  final String dataProvenance;
  final DateTime generatedAt;
  final bool isOfflineCached;

  const SatelliteRadarOverviewModel({
    required this.dwrStations,
    required this.satelliteProducts,
    this.nearestDwrStation,
    this.distanceToNearestRadarKm,
    required this.localRadarCoverageStatus,
    required this.dataProvenance,
    required this.generatedAt,
    this.isOfflineCached = false,
  });

  factory SatelliteRadarOverviewModel.fromJson(Map<String, dynamic> json, {bool isOfflineCached = false}) {
    final stationsRaw = json['dwr_stations'] as List? ?? [];
    final productsRaw = json['satellite_products'] as List? ?? [];

    DwrRadarStationModel? nearest;
    if (json['nearest_dwr_station'] != null && json['nearest_dwr_station'] is Map<String, dynamic>) {
      nearest = DwrRadarStationModel.fromJson(json['nearest_dwr_station'] as Map<String, dynamic>);
    }

    return SatelliteRadarOverviewModel(
      dwrStations: stationsRaw.map((e) => DwrRadarStationModel.fromJson(e as Map<String, dynamic>)).toList(),
      satelliteProducts: productsRaw.map((e) => MosdacSatelliteProductModel.fromJson(e as Map<String, dynamic>)).toList(),
      nearestDwrStation: nearest,
      distanceToNearestRadarKm: (json['distance_to_nearest_radar_km'] as num?)?.toDouble(),
      localRadarCoverageStatus: json['local_radar_coverage_status'] as String? ?? 'Coverage Unknown',
      dataProvenance: json['data_provenance'] as String? ?? 'ISRO MOSDAC & IMD Doppler Weather Radar Network',
      generatedAt: json['generated_at'] != null
          ? DateTime.tryParse(json['generated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isOfflineCached: isOfflineCached,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dwr_stations': dwrStations.map((e) => e.toJson()).toList(),
      'satellite_products': satelliteProducts.map((e) => e.toJson()).toList(),
      'nearest_dwr_station': nearestDwrStation?.toJson(),
      'distance_to_nearest_radar_km': distanceToNearestRadarKm,
      'local_radar_coverage_status': localRadarCoverageStatus,
      'data_provenance': dataProvenance,
      'generated_at': generatedAt.toIso8601String(),
    };
  }

  static double _haversineDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    const double r = 6371.0;
    final dLat = (lat2 - lat1) * math.pi / 180.0;
    final dLon = (lon2 - lon1) * math.pi / 180.0;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180.0) * math.cos(lat2 * math.pi / 180.0) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return (r * c * 10).round() / 10.0;
  }

  /// 100% offline fallback when network is unavailable
  factory SatelliteRadarOverviewModel.defaultFallback({
    required double latitude,
    required double longitude,
    String locationName = 'Location',
  }) {
    final now = DateTime.now();

    final fallbackStations = [
      DwrRadarStationModel(
        stationId: 'dwr_thiruvananthapuram',
        name: 'Thiruvananthapuram DWR',
        state: 'Kerala',
        latitude: 8.48,
        longitude: 76.95,
        band: 'C-band (5cm - Peninsular Convection)',
        frequencyGhz: 5.64,
        maxRangeKm: 250,
        status: 'Operational',
        lastSweepUtc: now,
        peakReflectivityDbz: 29.0,
        convectiveCellsDetected: 1,
        stormMotionHeadingDeg: 50.0,
        stormMotionSpeedKmh: 22.0,
        stationCode: 'tvm',
        radarImageUrl: 'https://mausam.imd.gov.in/Radar/caz_tvm.gif',
      ),
      DwrRadarStationModel(
        stationId: 'dwr_kochi',
        name: 'Kochi (South Western Seaboard DWR)',
        state: 'Kerala',
        latitude: 9.94,
        longitude: 76.26,
        band: 'S-band (10cm - Monsoon Surge)',
        frequencyGhz: 2.86,
        maxRangeKm: 400,
        status: 'Operational',
        lastSweepUtc: now,
        peakReflectivityDbz: 32.0,
        convectiveCellsDetected: 1,
        stormMotionHeadingDeg: 45.0,
        stormMotionSpeedKmh: 22.0,
        stationCode: 'koc',
        radarImageUrl: 'https://mausam.imd.gov.in/Radar/caz_koc.gif',
      ),
      DwrRadarStationModel(
        stationId: 'dwr_chennai_meenambakkam',
        name: 'Chennai (Meenambakkam DWR)',
        state: 'Tamil Nadu',
        latitude: 12.99,
        longitude: 80.18,
        band: 'C-band (5cm - Severe Storm Nowcasting)',
        frequencyGhz: 5.62,
        maxRangeKm: 250,
        status: 'Operational',
        lastSweepUtc: now,
        peakReflectivityDbz: 30.0,
        convectiveCellsDetected: 1,
        stormMotionHeadingDeg: 80.0,
        stormMotionSpeedKmh: 18.0,
        stationCode: 'cni',
        radarImageUrl: 'https://mausam.imd.gov.in/Radar/caz_cni.gif',
      ),
      DwrRadarStationModel(
        stationId: 'dwr_chennai_sriharikota',
        name: 'Chennai (Sriharikota DWR)',
        state: 'Andhra Pradesh / Tamil Nadu',
        latitude: 13.66,
        longitude: 80.23,
        band: 'S-band (10cm - Coastal Cyclone Surveillance)',
        frequencyGhz: 2.85,
        maxRangeKm: 400,
        status: 'Operational',
        lastSweepUtc: now,
        peakReflectivityDbz: 35.0,
        convectiveCellsDetected: 2,
        stormMotionHeadingDeg: 75.0,
        stormMotionSpeedKmh: 20.0,
        stationCode: 'cni',
        radarImageUrl: 'https://mausam.imd.gov.in/Radar/caz_cni.gif',
      ),
      DwrRadarStationModel(
        stationId: 'dwr_mumbai_colaba',
        name: 'Mumbai (Colaba DWR)',
        state: 'Maharashtra',
        latitude: 18.90,
        longitude: 72.81,
        band: 'S-band (10cm - Arabian Sea Surveillance)',
        frequencyGhz: 2.82,
        maxRangeKm: 400,
        status: 'Operational',
        lastSweepUtc: now,
        peakReflectivityDbz: 25.0,
        convectiveCellsDetected: 0,
        stormMotionHeadingDeg: 120.0,
        stormMotionSpeedKmh: 15.0,
        stationCode: 'mum',
        radarImageUrl: 'https://mausam.imd.gov.in/Radar/caz_mum.gif',
      ),
      DwrRadarStationModel(
        stationId: 'dwr_delhi_palam',
        name: 'New Delhi (Palam DWR)',
        state: 'Delhi NCR',
        latitude: 28.58,
        longitude: 77.10,
        band: 'S-band (10cm - Western Disturbance)',
        frequencyGhz: 2.87,
        maxRangeKm: 400,
        status: 'Operational',
        lastSweepUtc: now,
        peakReflectivityDbz: 20.0,
        convectiveCellsDetected: 0,
        stormMotionHeadingDeg: 90.0,
        stormMotionSpeedKmh: 16.0,
        stationCode: 'delhi',
        radarImageUrl: 'https://mausam.imd.gov.in/Radar/caz_delhi.gif',
      ),
      DwrRadarStationModel(
        stationId: 'dwr_kolkata_alipore',
        name: 'Kolkata (Alipore DWR)',
        state: 'West Bengal',
        latitude: 22.53,
        longitude: 88.33,
        band: 'S-band (10cm - Bay of Bengal Cyclone)',
        frequencyGhz: 2.84,
        maxRangeKm: 400,
        status: 'Operational',
        lastSweepUtc: now,
        peakReflectivityDbz: 35.0,
        convectiveCellsDetected: 2,
        stormMotionHeadingDeg: 135.0,
        stormMotionSpeedKmh: 28.0,
        stationCode: 'kol',
        radarImageUrl: 'https://mausam.imd.gov.in/Radar/caz_kol.gif',
      ),
      DwrRadarStationModel(
        stationId: 'dwr_hyderabad',
        name: 'Hyderabad (Begumpet DWR)',
        state: 'Telangana',
        latitude: 17.45,
        longitude: 78.47,
        band: 'C-band (5cm - Deccan Plateau)',
        frequencyGhz: 5.61,
        maxRangeKm: 250,
        status: 'Operational',
        lastSweepUtc: now,
        peakReflectivityDbz: 22.0,
        convectiveCellsDetected: 0,
        stormMotionHeadingDeg: 95.0,
        stormMotionSpeedKmh: 15.0,
        stationCode: 'hyd',
        radarImageUrl: 'https://mausam.imd.gov.in/Radar/caz_hyd.gif',
      ),
      DwrRadarStationModel(
        stationId: 'dwr_bhopal',
        name: 'Bhopal DWR',
        state: 'Madhya Pradesh',
        latitude: 23.26,
        longitude: 77.41,
        band: 'C-band (5cm - Central Plateau)',
        frequencyGhz: 5.65,
        maxRangeKm: 250,
        status: 'Operational',
        lastSweepUtc: now,
        peakReflectivityDbz: 19.0,
        convectiveCellsDetected: 0,
        stormMotionHeadingDeg: 90.0,
        stormMotionSpeedKmh: 17.0,
        stationCode: 'bhp',
        radarImageUrl: 'https://mausam.imd.gov.in/Radar/caz_bhp.gif',
      ),
      DwrRadarStationModel(
        stationId: 'dwr_visakhapatnam',
        name: 'Visakhapatnam (Kailasagiri DWR)',
        state: 'Andhra Pradesh',
        latitude: 17.74,
        longitude: 83.34,
        band: 'S-band (10cm - Eastern Seaboard)',
        frequencyGhz: 2.81,
        maxRangeKm: 400,
        status: 'Operational',
        lastSweepUtc: now,
        peakReflectivityDbz: 30.0,
        convectiveCellsDetected: 1,
        stormMotionHeadingDeg: 60.0,
        stormMotionSpeedKmh: 20.0,
        stationCode: 'vsk',
        radarImageUrl: 'https://mausam.imd.gov.in/Radar/caz_vsk.gif',
      ),
    ];

    final fallbackProducts = [
      MosdacSatelliteProductModel(
        productId: 'insat3dr_tir1_ctt',
        name: 'INSAT-3DR Thermal IR (Cloud Top Temperature)',
        satellite: 'INSAT-3DR Geostationary (74.0°E)',
        sensor: 'Multispectral Imager (TIR-1 Channel)',
        resolutionKm: 4.0,
        channelWavelength: '10.8 µm',
        latestScanTimeUtc: now,
        refreshIntervalMin: 15,
        colorScaleUnit: '°C',
        colorScaleLabels: ['-80°C (Deep Convection)', '-60°C', '-40°C', '-20°C', '0°C', '+20°C (Surface)'],
        paletteGradient: ['#311B92', '#1565C0', '#00ACC1', '#43A047', '#FDD835', '#FB8C00', '#E53935'],
        synopticInterpretation: 'TIR-1 thermal cloud top brightness. Tops colder than -40°C indicate vigorous vertical updrafts.',
        tileOrImageUrl: 'https://mausam.imd.gov.in/Satellite/3Dasiasec_ir1.jpg',
        bounds: const [-10.0, 40.0, 45.0, 115.0],
      ),
      MosdacSatelliteProductModel(
        productId: 'insat3dr_wv',
        name: 'INSAT-3DR Water Vapor (Tropospheric Moisture)',
        satellite: 'INSAT-3DR Geostationary (74.0°E)',
        sensor: 'Multispectral Imager (WV Channel)',
        resolutionKm: 4.0,
        channelWavelength: '6.8 µm',
        latestScanTimeUtc: now,
        refreshIntervalMin: 15,
        colorScaleUnit: '% RH',
        colorScaleLabels: ['Dry (<20%)', 'Moderate (40%)', 'Humid (70%)', 'Saturated (>90%)'],
        paletteGradient: ['#212121', '#37474F', '#0277BD', '#29B6F6', '#E1F5FE'],
        synopticInterpretation: 'Mid-to-upper tropospheric moisture (400-600 hPa). Highlights monsoonal moisture inflow.',
        tileOrImageUrl: 'https://mausam.imd.gov.in/Satellite/3Dasiasec_wv.jpg',
        bounds: const [-10.0, 40.0, 45.0, 115.0],
      ),
      MosdacSatelliteProductModel(
        productId: 'insat3dr_vis',
        name: 'INSAT-3DR Visible Cloud & Fog Albedo',
        satellite: 'INSAT-3DR Geostationary (74.0°E)',
        sensor: 'Multispectral Imager (VIS Channel)',
        resolutionKm: 1.0,
        channelWavelength: '0.65 µm',
        latestScanTimeUtc: now,
        refreshIntervalMin: 15,
        colorScaleUnit: 'Albedo %',
        colorScaleLabels: ['0% (Clear Sea)', '25% (Thin Cloud)', '50% (Stratus/Fog)', '85% (Dense Cloud)'],
        paletteGradient: ['#1A1A1A', '#424242', '#757575', '#BDBDBD', '#FFFFFF'],
        synopticInterpretation: 'High-resolution 1km daytime solar reflectance. Accurately pinpoints low-level fog and dense storm structures.',
        tileOrImageUrl: 'https://mausam.imd.gov.in/Satellite/3Dasiasec_vis.jpg',
        bounds: const [-10.0, 40.0, 45.0, 115.0],
      ),
    ];

    DwrRadarStationModel nearest = fallbackStations.first;
    double minDistance = double.infinity;
    for (final stn in fallbackStations) {
      final dist = _haversineDistanceKm(latitude, longitude, stn.latitude, stn.longitude);
      if (dist < minDistance) {
        minDistance = dist;
        nearest = stn;
      }
    }

    final coverageStatus = minDistance <= 100.0
        ? 'Within 100km Nowcast Range (Dual-Pol Hydrometeor Classification)'
        : (minDistance <= 250.0
            ? 'Within 250km Surveillance Range (Doppler Volume Scan Mode)'
            : 'Beyond Direct DWR Range (Primary Coverage via INSAT-3DR)');

    return SatelliteRadarOverviewModel(
      dwrStations: fallbackStations,
      satelliteProducts: fallbackProducts,
      nearestDwrStation: nearest,
      distanceToNearestRadarKm: minDistance,
      localRadarCoverageStatus: coverageStatus,
      dataProvenance: 'ISRO MOSDAC & IMD Doppler Weather Radar Network',
      generatedAt: now,
      isOfflineCached: true,
    );
  }
}
