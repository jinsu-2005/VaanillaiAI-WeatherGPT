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

  @override
  void initState() {
    super.initState();
    _fetchLatestRadarPath();
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
          'Live GIS Weather & Radar Map',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.my_location_rounded, color: accentBlue),
            onPressed: () => _mapController.move(currentPoint, 10.0),
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
              initialZoom: 8.0,
              minZoom: 3.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.vaanilai.ai',
              ),
              if (_activeLayer == 'precipitation' && _radarUrlTemplate != null)
                TileLayer(
                  urlTemplate: _radarUrlTemplate!,
                  userAgentPackageName: 'com.vaanilai.ai',
                  tileBuilder: (context, tileWidget, tile) =>
                      Opacity(opacity: 0.65, child: tileWidget),
                ),
              MarkerLayer(
                markers: [
                  // Current location marker
                  Marker(
                    point: currentPoint,
                    width: 150,
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
                              Text(
                                '${weatherProvider.locationName} (${weatherProvider.forecast?.current.temperature.round() ?? "--"}°)',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_drop_down_rounded, color: accentBlue, size: 22),
                      ],
                    ),
                  ),

                  // Alert markers
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

                  // Lightning Hotspot Markers
                  if (_activeLayer == 'lightning') ...[
                    Marker(
                      point: LatLng(currentPoint.latitude + 0.08, currentPoint.longitude + 0.06),
                      width: 44,
                      height: 44,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF1744).withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFF1744), width: 2),
                        ),
                        child: const Icon(Icons.flash_on_rounded, color: Color(0xFFFF1744), size: 24),
                      ),
                    ),
                    Marker(
                      point: LatLng(currentPoint.latitude - 0.05, currentPoint.longitude + 0.09),
                      width: 38,
                      height: 38,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9100).withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFF9100), width: 1.5),
                        ),
                        child: const Icon(Icons.flash_on_rounded, color: Color(0xFFFF9100), size: 20),
                      ),
                    ),
                  ],

                  // Citizen Science Ground Report Markers
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
                    id: 'lightning',
                    label: 'Damini Lightning',
                    icon: Icons.flash_on_rounded,
                    color: const Color(0xFFFF1744),
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
                    id: 'wind',
                    label: 'Wind & Cyclones',
                    icon: Icons.air_rounded,
                    color: AppColors.brandBlueLight,
                  ),
                  const SizedBox(width: 8),
                  _buildLayerPill(
                    id: 'temperature',
                    label: 'Heat Index',
                    icon: Icons.thermostat_rounded,
                    color: AppColors.alertOrange,
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

          // 3. Legend Card
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
                    _activeLayer == 'precipitation'
                        ? 'Precipitation (mm/h)'
                        : _activeLayer == 'lightning'
                            ? 'Lightning Strike Intensity'
                            : _activeLayer == 'citizen'
                                ? 'Crowdsourced Ground Hazards'
                                : _activeLayer == 'wind'
                                    ? 'Wind Velocity (km/h)'
                                    : _activeLayer == 'temperature'
                                        ? 'Heat Index (°C)'
                                        : 'IMD Alert Severity',
                    style: TextStyle(
                      color: mapTextSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 140,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        colors: _activeLayer == 'precipitation'
                            ? [Colors.blue.shade900, Colors.cyan, Colors.yellow, Colors.red]
                            : _activeLayer == 'lightning'
                                ? [Colors.yellow, Colors.orange, Colors.red, Colors.purple]
                                : _activeLayer == 'citizen'
                                    ? [Colors.blue, Colors.teal, Colors.amber, Colors.purple]
                                    : _activeLayer == 'temperature'
                                        ? [Colors.blue, Colors.green, Colors.orange, Colors.red]
                                        : [AppColors.alertYellow, AppColors.alertOrange, AppColors.alertRed],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Time-slider Control Bar
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
                                      ? 'Live Now'
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
