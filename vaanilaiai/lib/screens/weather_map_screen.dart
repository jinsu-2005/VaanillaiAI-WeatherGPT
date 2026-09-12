import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../providers/alert_provider.dart';
import '../providers/citizen_provider.dart';
import '../models/citizen_report_model.dart';
import '../models/satellite_radar_model.dart';
import '../services/api_service.dart';
import '../widgets/citizen_report_dialog.dart';
import '../theme/app_colors.dart';

class WeatherMapScreen extends StatefulWidget {
  const WeatherMapScreen({super.key});

  @override
  State<WeatherMapScreen> createState() => _WeatherMapScreenState();
}

class _WeatherMapScreenState extends State<WeatherMapScreen> {
  final MapController _mapController = MapController();
  String _activeLayer = 'precipitation';
  bool _isPlaying = false;
  double _timelineValue = 0.0;
  String? _radarUrlTemplate;

  // Satellite & Doppler Radar State
  SatelliteRadarOverviewModel? _satelliteRadarData;
  bool _isLoadingRadar = false;
  bool _showRadarRangeRings = true;

  @override
  void initState() {
    super.initState();
    _fetchLatestRadarPath();
    _loadSatelliteRadarData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wp = Provider.of<WeatherProvider>(context, listen: false);
      Provider.of<CitizenProvider>(context, listen: false).fetchReports(
        latitude: wp.latitude,
        longitude: wp.longitude,
      );
    });
  }

  Future<void> _fetchLatestRadarPath() async {
    try {
      final response = await http
          .get(Uri.parse('https://api.rainviewer.com/public/weather-maps.json'))
          .timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final host = data['host'] ?? 'https://tilecache.rainviewer.com';
        final past = data['radar']?['past'] as List?;
        if (past != null && past.isNotEmpty) {
          final latestPath = past.last['path'];
          if (mounted) {
            setState(() {
              _radarUrlTemplate = '$host$latestPath/256/{z}/{x}/{y}/2/1_1.png';
            });
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _loadSatelliteRadarData() async {
    if (!mounted) return;
    setState(() => _isLoadingRadar = true);
    final wp = Provider.of<WeatherProvider>(context, listen: false);
    try {
      final data = await ApiService().getSatelliteRadarOverview(
        latitude: wp.latitude,
        longitude: wp.longitude,
        locationName: wp.locationName,
      );
      if (mounted) {
        setState(() {
          _satelliteRadarData = data;
          _isLoadingRadar = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _satelliteRadarData = SatelliteRadarOverviewModel.defaultFallback(
            latitude: wp.latitude,
            longitude: wp.longitude,
            locationName: wp.locationName,
          );
          _isLoadingRadar = false;
        });
      }
    }
  }

  void _showDwrStationDetails(BuildContext context, DwrRadarStationModel station) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wp = Provider.of<WeatherProvider>(context, listen: false);
    final distToUser = const Distance().as(
      LengthUnit.Kilometer,
      LatLng(wp.latitude, wp.longitude),
      LatLng(station.latitude, station.longitude),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF161E31) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.brandBlue.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.radar_rounded, color: AppColors.brandBlue, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          station.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '${station.state} • ${station.band}',
                          style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.alertGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.alertGreen, width: 1),
                    ),
                    child: Text(
                      station.status.toUpperCase(),
                      style: const TextStyle(color: AppColors.alertGreen, fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Radar metrics grid
              Row(
                children: [
                  Expanded(
                    child: _buildStationMetricTile(
                      label: 'Peak Reflectivity',
                      value: station.peakReflectivityDbz != null
                          ? '${station.peakReflectivityDbz!.toStringAsFixed(1)} dBZ'
                          : '--',
                      subtitle: (station.peakReflectivityDbz ?? 0) > 35
                          ? 'Heavy Convection'
                          : 'Moderate / Light Echo',
                      icon: Icons.grain_rounded,
                      color: (station.peakReflectivityDbz ?? 0) > 35 ? AppColors.alertRed : AppColors.brandBlue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStationMetricTile(
                      label: 'Convective Cells',
                      value: '${station.convectiveCellsDetected} Active',
                      subtitle: station.stormMotionSpeedKmh != null
                          ? '${station.stormMotionSpeedKmh!.round()} km/h @ ${station.stormMotionHeadingDeg?.round() ?? 0}°'
                          : 'Stationary',
                      icon: Icons.thunderstorm_rounded,
                      color: station.convectiveCellsDetected > 0 ? AppColors.alertOrange : AppColors.alertGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildStationMetricTile(
                      label: 'Surveillance Range',
                      value: '${station.maxRangeKm} km',
                      subtitle: 'Frequency: ${station.frequencyGhz} GHz',
                      icon: Icons.track_changes_rounded,
                      color: AppColors.brandBlueLight,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStationMetricTile(
                      label: 'Distance from You',
                      value: '$distToUser km',
                      subtitle: distToUser <= 100
                          ? 'Inside 100km Nowcast'
                          : (distToUser <= 250 ? 'Inside 250km Range' : 'Extended Range'),
                      icon: Icons.near_me_rounded,
                      color: distToUser <= 100 ? AppColors.alertGreen : Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Last Volume Sweep: ${station.lastSweepUtc.toLocal().toString().substring(11, 16)} IST',
                    style: const TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      _mapController.move(LatLng(station.latitude, station.longitude), 9.0);
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    icon: const Icon(Icons.center_focus_strong_rounded, size: 15),
                    label: const Text('Center Radar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStationMetricTile({
    required String label,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: color),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showCitizenReportDetails(BuildContext context, CitizenReportModel report) {
    final citizenProvider = Provider.of<CitizenProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF161E31) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.brandBlue.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.report_problem_rounded, color: AppColors.brandBlue, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.reportType,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '${report.locationName} • ${report.createdAt}',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: report.severity == 'Severe'
                          ? AppColors.alertRed
                          : (report.severity == 'Moderate' ? AppColors.alertOrange : AppColors.alertGreen),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      report.severity.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (report.waterDepthInches != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.water_rounded, color: Colors.blue, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Measured Water Depth: ${report.waterDepthInches} inches',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                report.description,
                style: const TextStyle(fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reported by: ${report.reporterRole}',
                    style: const TextStyle(fontSize: 11.5, color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      citizenProvider.upvote(report.id);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ground report verified & upvoted!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    icon: const Icon(Icons.thumb_up_rounded, size: 14),
                    label: Text('${report.upvotes} Upvotes', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final alertProvider = Provider.of<AlertProvider>(context);
    final citizenProvider = Provider.of<CitizenProvider>(context);
    final currentPoint = LatLng(weatherProvider.latitude, weatherProvider.longitude);

    final accentBlue = isDark ? AppColors.brandBlueLight : AppColors.brandBlue;
    final mapCardBg = isDark
        ? AppColors.darkSurface.withValues(alpha: 0.94)
        : Colors.grey.shade900.withValues(alpha: 0.88);
    final mapCardBorder = isDark ? AppColors.darkOutline : Colors.white.withValues(alpha: 0.12);
    final mapTextSecondary = Colors.white70;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Live Satellite & Radar GIS',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          // Range Rings Toggle
          if (_activeLayer == 'imd_dwr')
            IconButton(
              icon: Icon(
                _showRadarRangeRings ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                color: _showRadarRangeRings ? Colors.cyanAccent : Colors.grey,
              ),
              onPressed: () => setState(() => _showRadarRangeRings = !_showRadarRangeRings),
              tooltip: _showRadarRangeRings ? 'Hide 250km Surveillance Rings' : 'Show 250km Surveillance Rings',
            ),
          // Refresh Satellite/Radar Data
          IconButton(
            icon: _isLoadingRadar
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.cyanAccent),
                  )
                : Icon(Icons.refresh_rounded, color: accentBlue),
            onPressed: _isLoadingRadar
                ? null
                : () {
                    _fetchLatestRadarPath();
                    _loadSatelliteRadarData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Refreshing ISRO MOSDAC & IMD Doppler Radar feeds...')),
                    );
                  },
            tooltip: 'Refresh Satellite & Radar Feeds',
          ),
          IconButton(
            icon: Icon(Icons.my_location_rounded, color: accentBlue),
            onPressed: () => _mapController.move(currentPoint, 8.0),
            tooltip: 'Center on Current Location',
          ),
        ],
      ),
      floatingActionButton: _activeLayer == 'citizen'
          ? FloatingActionButton.extended(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const CitizenReportDialog(),
              ),
              backgroundColor: AppColors.brandBlue,
              icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
              label: const Text('Report Hazard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
      body: Stack(
        children: [
          // 1. FlutterMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: currentPoint,
              initialZoom: 7.5,
              minZoom: 3.0,
              maxZoom: 18.0,
            ),
            children: [
              // Base Map Tiles
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.vaanilai.ai',
              ),

              // RainViewer Radar Overlay (when precipitation layer is active)
              if (_activeLayer == 'precipitation' && _radarUrlTemplate != null)
                TileLayer(
                  urlTemplate: _radarUrlTemplate!,
                  userAgentPackageName: 'com.vaanilai.ai',
                  tileBuilder: (context, tileWidget, tile) =>
                      Opacity(opacity: 0.65, child: tileWidget),
                ),

              // Doppler Weather Radar Range Rings Layer (when imd_dwr is active)
              if (_activeLayer == 'imd_dwr' && _satelliteRadarData != null)
                CircleLayer(
                  circles: [
                    for (final station in _satelliteRadarData!.dwrStations) ...[
                      // 100km Nowcasting Range Ring
                      CircleMarker(
                        point: LatLng(station.latitude, station.longitude),
                        radius: 100000,
                        useRadiusInMeter: true,
                        color: Colors.cyan.withValues(alpha: 0.05),
                        borderColor: Colors.cyanAccent.withValues(alpha: 0.55),
                        borderStrokeWidth: 1.3,
                      ),
                      // 250km Surveillance Range Ring
                      if (_showRadarRangeRings)
                        CircleMarker(
                          point: LatLng(station.latitude, station.longitude),
                          radius: station.maxRangeKm * 1000.0,
                          useRadiusInMeter: true,
                          color: Colors.indigo.withValues(alpha: 0.025),
                          borderColor: Colors.indigoAccent.withValues(alpha: 0.35),
                          borderStrokeWidth: 0.9,
                        ),
                    ],
                  ],
                ),

              // Marker Layer
              MarkerLayer(
                markers: [
                  // Current location marker
                  Marker(
                    point: currentPoint,
                    width: 180,
                    height: 70,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.darkSurface.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: accentBlue, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: accentBlue.withValues(alpha: 0.4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_on_rounded, color: accentBlue, size: 14),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '${weatherProvider.locationName} (${weatherProvider.forecast?.current.temperature.round() ?? "--"}°)',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_drop_down_rounded, color: accentBlue, size: 22),
                      ],
                    ),
                  ),

                  // Alert markers (when alerts layer is active)
                  if (_activeLayer == 'alerts')
                    ...alertProvider.activeAlerts.map((alert) {
                      final isRed = alert.severity.toLowerCase() == 'red';
                      final color = isRed ? AppColors.alertRed : AppColors.alertOrange;
                      return Marker(
                        point: currentPoint,
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                            border: Border.all(color: color, width: 2),
                          ),
                          child: Icon(Icons.warning_rounded, color: color, size: 20),
                        ),
                      );
                    }),

                  // IMD Doppler Weather Radar Station Markers (when imd_dwr is active)
                  if (_activeLayer == 'imd_dwr' && _satelliteRadarData != null)
                    ..._satelliteRadarData!.dwrStations.map((station) {
                      final hasConvectiveEcho = (station.peakReflectivityDbz ?? 0) > 30.0;
                      final pinColor = hasConvectiveEcho ? AppColors.alertRed : Colors.cyanAccent;

                      return Marker(
                        point: LatLng(station.latitude, station.longitude),
                        width: 54,
                        height: 54,
                        child: GestureDetector(
                          onTap: () => _showDwrStationDetails(context, station),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.darkSurface.withValues(alpha: 0.95),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: pinColor, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: pinColor.withValues(alpha: 0.4),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Icon(Icons.radar_rounded, color: pinColor, size: 20),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.75),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  station.name.split('(').first.trim().split(' ').first,
                                  style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                  // Citizen Ground Report Markers (when citizen layer is active)
                  if (_activeLayer == 'citizen')
                    ...citizenProvider.reports.map((report) {
                      Color pinColor = Colors.blue;
                      IconData pinIcon = Icons.water_rounded;
                      if (report.reportType.toLowerCase().contains('wind')) {
                        pinColor = Colors.amber;
                        pinIcon = Icons.air_rounded;
                      } else if (report.reportType.toLowerCase().contains('hail')) {
                        pinColor = Colors.purpleAccent;
                        pinIcon = Icons.ac_unit_rounded;
                      }

                      return Marker(
                        point: LatLng(report.latitude, report.longitude),
                        width: 44,
                        height: 44,
                        child: GestureDetector(
                          onTap: () => _showCitizenReportDetails(context, report),
                          child: Container(
                            decoration: BoxDecoration(
                              color: pinColor.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: pinColor.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Icon(pinIcon, color: Colors.white, size: 22),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ],
          ),

          // 2. Layer Switcher Pills
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildLayerPill(
                    id: 'precipitation',
                    label: 'Live Radar',
                    icon: Icons.grain_rounded,
                    color: AppColors.weatherRain,
                  ),
                  const SizedBox(width: 8),
                  _buildLayerPill(
                    id: 'imd_dwr',
                    label: 'IMD Doppler Radar',
                    icon: Icons.radar_rounded,
                    color: Colors.cyanAccent,
                  ),
                  const SizedBox(width: 8),
                  _buildLayerPill(
                    id: 'insat_ctt',
                    label: 'INSAT-3DR CTT',
                    icon: Icons.satellite_alt_rounded,
                    color: const Color(0xFFE040FB),
                  ),
                  const SizedBox(width: 8),
                  _buildLayerPill(
                    id: 'insat_wv',
                    label: 'INSAT-3DR WV',
                    icon: Icons.air_rounded,
                    color: const Color(0xFF40C4FF),
                  ),
                  const SizedBox(width: 8),
                  _buildLayerPill(
                    id: 'insat_vis',
                    label: 'INSAT-3DR VIS',
                    icon: Icons.wb_sunny_rounded,
                    color: const Color(0xFFFFD740),
                  ),
                  const SizedBox(width: 8),
                  _buildLayerPill(
                    id: 'citizen',
                    label: 'Citizen Hazards',
                    icon: Icons.add_location_alt_rounded,
                    color: Colors.tealAccent,
                  ),
                  const SizedBox(width: 8),
                  _buildLayerPill(
                    id: 'alerts',
                    label: 'Disaster Zones',
                    icon: Icons.crisis_alert_rounded,
                    color: AppColors.alertRed,
                  ),
                ],
              ),
            ),
          ),

          // 3. Nearest Radar HUD Badge (Active for IMD DWR layer or general status)
          if (_satelliteRadarData?.nearestDwrStation != null)
            Positioned(
              top: 68,
              left: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  final station = _satelliteRadarData!.nearestDwrStation!;
                  _mapController.move(LatLng(station.latitude, station.longitude), 8.5);
                  _showDwrStationDetails(context, station);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: mapCardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: mapCardBorder, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.cyan.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.radar_rounded, color: Colors.cyanAccent, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Nearest DWR: ${_satelliteRadarData!.nearestDwrStation!.name.split('(').first.trim()}',
                                  style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.cyan.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${_satelliteRadarData!.distanceToNearestRadarKm?.round() ?? "--"} km',
                                    style: const TextStyle(color: Colors.cyanAccent, fontSize: 9.5, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              _satelliteRadarData!.localRadarCoverageStatus.split('(').first.trim(),
                              style: const TextStyle(color: Colors.white70, fontSize: 10),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Colors.white54, size: 18),
                    ],
                  ),
                ),
              ),
            ),

          // 4. INSAT Satellite Synoptic Interpretation Card (when a satellite layer is active)
          if (_activeLayer.startsWith('insat_') && _satelliteRadarData != null) ...[
            _buildSatelliteSynopticCard(mapCardBg, mapCardBorder),
          ],

          // 5. Scientific Legend Card
          Positioned(
            left: 16,
            bottom: 90,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: mapCardBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: mapCardBorder, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getLegendTitle(),
                    style: TextStyle(
                      color: mapTextSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 150,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        colors: _getLegendGradient(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_getLegendMinLabel(), style: const TextStyle(color: Colors.white60, fontSize: 8.5)),
                      const SizedBox(width: 30),
                      Text(_getLegendMaxLabel(), style: const TextStyle(color: Colors.white60, fontSize: 8.5)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 6. Time-slider Control Bar
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: mapCardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: mapCardBorder, width: 1),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: accentBlue,
                      size: 26,
                    ),
                    onPressed: () => setState(() => _isPlaying = !_isPlaying),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('-2h Past', style: TextStyle(color: mapTextSecondary, fontSize: 10)),
                            Text(
                              _timelineValue < 0.5
                                  ? 'Radar Replay'
                                  : _timelineValue < 1.5
                                      ? 'Live Now (ISRO/IMD)'
                                      : '+6h NWP Forecast',
                              style: TextStyle(color: accentBlue, fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                            Text('+6h Forecast', style: TextStyle(color: mapTextSecondary, fontSize: 10)),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            activeTrackColor: accentBlue,
                            inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                            thumbColor: accentBlue,
                          ),
                          child: Slider(
                            value: _timelineValue,
                            min: 0.0,
                            max: 2.0,
                            onChanged: (val) => setState(() => _timelineValue = val),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSatelliteSynopticCard(Color cardBg, Color cardBorder) {
    MosdacSatelliteProductModel? product;
    if (_satelliteRadarData != null && _satelliteRadarData!.satelliteProducts.isNotEmpty) {
      if (_activeLayer == 'insat_ctt') {
        product = _satelliteRadarData!.satelliteProducts.firstWhere(
          (p) => p.productId == 'insat3dr_tir1_ctt',
          orElse: () => _satelliteRadarData!.satelliteProducts.first,
        );
      } else if (_activeLayer == 'insat_wv') {
        product = _satelliteRadarData!.satelliteProducts.firstWhere(
          (p) => p.productId == 'insat3dr_wv',
          orElse: () => _satelliteRadarData!.satelliteProducts.first,
        );
      } else if (_activeLayer == 'insat_vis') {
        product = _satelliteRadarData!.satelliteProducts.firstWhere(
          (p) => p.productId == 'insat3dr_vis',
          orElse: () => _satelliteRadarData!.satelliteProducts.first,
        );
      }
    }

    if (product == null) return const SizedBox.shrink();

    return Positioned(
      bottom: 160,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cardBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.satellite_alt_rounded, color: Color(0xFFE040FB), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    product.name,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${product.resolutionKm}km • ${product.refreshIntervalMin}m Cadence',
                    style: const TextStyle(color: Color(0xFFE040FB), fontSize: 9.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              product.synopticInterpretation,
              style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.3),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payload: ${product.satellite} • ${product.channelWavelength}',
                  style: const TextStyle(color: Colors.grey, fontSize: 9.5),
                ),
                const Text(
                  'ISRO MOSDAC Verified',
                  style: TextStyle(color: Colors.cyanAccent, fontSize: 9.5, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getLegendTitle() {
    switch (_activeLayer) {
      case 'precipitation':
        return 'Precipitation Rate (mm/h)';
      case 'imd_dwr':
        return 'IMD Radar Reflectivity (dBZ)';
      case 'insat_ctt':
        return 'Cloud Top Temp (°C)';
      case 'insat_wv':
        return 'Tropospheric Moisture (% RH)';
      case 'insat_vis':
        return 'Daytime Cloud Albedo (%)';
      case 'citizen':
        return 'Crowdsourced Ground Hazards';
      case 'alerts':
      default:
        return 'IMD Alert Severity';
    }
  }

  List<Color> _getLegendGradient() {
    switch (_activeLayer) {
      case 'precipitation':
        return [Colors.blue.shade900, Colors.cyan, Colors.yellow, Colors.red];
      case 'imd_dwr':
        return [Colors.blue.shade700, Colors.green, Colors.yellow, Colors.orange, Colors.red, Colors.purple];
      case 'insat_ctt':
        return [const Color(0xFF311B92), const Color(0xFF1565C0), const Color(0xFF00ACC1), const Color(0xFF43A047), const Color(0xFFFDD835), const Color(0xFFE53935)];
      case 'insat_wv':
        return [const Color(0xFF212121), const Color(0xFF37474F), const Color(0xFF0277BD), const Color(0xFF29B6F6), const Color(0xFFE1F5FE)];
      case 'insat_vis':
        return [const Color(0xFF1A1A1A), const Color(0xFF616161), const Color(0xFFBDBDBD), Colors.white];
      case 'citizen':
        return [Colors.blue, Colors.teal, Colors.amber, Colors.purple];
      case 'alerts':
      default:
        return [AppColors.alertYellow, AppColors.alertOrange, AppColors.alertRed];
    }
  }

  String _getLegendMinLabel() {
    switch (_activeLayer) {
      case 'precipitation':
        return '0.5 mm/h';
      case 'imd_dwr':
        return '10 dBZ (Virga)';
      case 'insat_ctt':
        return '-80°C (Deep)';
      case 'insat_wv':
        return '< 20% (Dry)';
      case 'insat_vis':
        return '0% (Sea)';
      case 'citizen':
        return 'Minor';
      case 'alerts':
      default:
        return 'Watch';
    }
  }

  String _getLegendMaxLabel() {
    switch (_activeLayer) {
      case 'precipitation':
        return '50+ mm/h';
      case 'imd_dwr':
        return '65+ dBZ (Hail)';
      case 'insat_ctt':
        return '+20°C (Surface)';
      case 'insat_wv':
        return '> 90% (Plume)';
      case 'insat_vis':
        return '85% (Dense)';
      case 'citizen':
        return 'Critical';
      case 'alerts':
      default:
        return 'Warning';
    }
  }

  Widget _buildLayerPill({
    required String id,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _activeLayer == id;
    final bg = isSelected
        ? color.withValues(alpha: 0.22)
        : Colors.grey.shade900.withValues(alpha: 0.85);
    final border = isSelected ? color : Colors.white.withValues(alpha: 0.15);

    return InkWell(
      onTap: () => setState(() => _activeLayer = id),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border, width: isSelected ? 1.5 : 0.8),
          boxShadow: [
            if (isSelected) BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 8),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? color : Colors.white70, size: 15),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
