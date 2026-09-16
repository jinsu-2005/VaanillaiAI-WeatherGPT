import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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

/// Representation of a single Doppler radar frame from RainViewer.
class _RadarFrame {
  final int time;
  final String path;
  final bool isForecast;

  const _RadarFrame({
    required this.time,
    required this.path,
    this.isForecast = false,
  });

  DateTime get dateTime =>
      DateTime.fromMillisecondsSinceEpoch(time * 1000, isUtc: true).toLocal();

  String formattedTime(DateTime currentNow) {
    final dt = dateTime;
    final timeStr = DateFormat('h:mm a').format(dt);
    final diffMin = dt.difference(currentNow).inMinutes;

    if (diffMin.abs() <= 5) {
      return 'Live ($timeStr)';
    } else if (diffMin < 0) {
      return '$timeStr (${diffMin}m)';
    } else {
      return '$timeStr (+${diffMin}m)';
    }
  }
}

class WeatherMapScreen extends StatefulWidget {
  const WeatherMapScreen({super.key});

  @override
  State<WeatherMapScreen> createState() => _WeatherMapScreenState();
}

class _WeatherMapScreenState extends State<WeatherMapScreen> {
  final MapController _mapController = MapController();

  // Active Layer ID: 'precipitation', 'imd_dwr', 'insat_ctt', 'insat_wv', 'insat_vis', 'citizen', 'alerts'
  String _activeLayer = 'precipitation';

  // Radar Replay & Frame State
  List<_RadarFrame> _radarFrames = [];
  int _currentFrameIndex = 0;
  String _radarHost = 'https://tilecache.rainviewer.com';
  bool _isPlaying = false;
  Timer? _playbackTimer;
  bool _isLoadingRadarFrames = false;

  // Satellite & Doppler Radar State
  SatelliteRadarOverviewModel? _satelliteRadarData;
  bool _isLoadingRadar = false;
  bool _showRadarRangeRings = true;

  // Selected DWR product tab in modal: 'caz' (MaxZ), 'sri' (Surface Rain), 'ppz' (Reflectivity)
  String _selectedDwrProduct = 'caz';

  @override
  void initState() {
    super.initState();
    _fetchRainViewerFrames();
    _loadSatelliteRadarData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wp = Provider.of<WeatherProvider>(context, listen: false);
      Provider.of<CitizenProvider>(context, listen: false).fetchReports(
        latitude: wp.latitude,
        longitude: wp.longitude,
      );
    });
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchRainViewerFrames() async {
    if (!mounted) return;
    setState(() => _isLoadingRadarFrames = true);

    try {
      final response = await http
          .get(Uri.parse('https://api.rainviewer.com/public/weather-maps.json'))
          .timeout(const Duration(seconds: 7));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final host = data['host'] as String? ?? 'https://tilecache.rainviewer.com';
        final radar = data['radar'] as Map<String, dynamic>?;

        final List<_RadarFrame> frames = [];

        if (radar != null) {
          final past = radar['past'] as List?;
          if (past != null) {
            for (final f in past) {
              if (f is Map<String, dynamic> && f['time'] != null && f['path'] != null) {
                frames.add(_RadarFrame(
                  time: (f['time'] as num).toInt(),
                  path: f['path'] as String,
                  isForecast: false,
                ));
              }
            }
          }

          final nowcast = radar['nowcast'] as List?;
          if (nowcast != null) {
            for (final f in nowcast) {
              if (f is Map<String, dynamic> && f['time'] != null && f['path'] != null) {
                frames.add(_RadarFrame(
                  time: (f['time'] as num).toInt(),
                  path: f['path'] as String,
                  isForecast: true,
                ));
              }
            }
          }
        }

        if (mounted) {
          setState(() {
            _radarHost = host;
            _radarFrames = frames;
            if (frames.isNotEmpty) {
              _currentFrameIndex = frames.length - 1;
            }
            _isLoadingRadarFrames = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingRadarFrames = false);
      }
    }
  }

  void _togglePlayback() {
    if (_radarFrames.isEmpty) return;

    if (_isPlaying) {
      _playbackTimer?.cancel();
      setState(() => _isPlaying = false);
    } else {
      setState(() => _isPlaying = true);
      _playbackTimer?.cancel();
      _playbackTimer = Timer.periodic(const Duration(milliseconds: 700), (_) {
        if (!mounted) return;
        setState(() {
          _currentFrameIndex = (_currentFrameIndex + 1) % _radarFrames.length;
        });
      });
    }
  }

  void _onSliderChanged(double value) {
    if (_radarFrames.isEmpty) return;
    if (_isPlaying) {
      _playbackTimer?.cancel();
      _isPlaying = false;
    }
    setState(() {
      _currentFrameIndex = value.round().clamp(0, _radarFrames.length - 1);
    });
  }

  String get _currentRadarTileUrl {
    if (_radarFrames.isEmpty || _currentFrameIndex >= _radarFrames.length) {
      return '';
    }
    final frame = _radarFrames[_currentFrameIndex];
    return '$_radarHost${frame.path}/256/{z}/{x}/{y}/2/1_1.png';
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
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF161E31) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final stnCode = station.stationCode ?? 'delhi';
            final liveImgUrl = 'https://mausam.imd.gov.in/Radar/${_selectedDwrProduct}_$stnCode.gif';

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.cyan.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.radar_rounded, color: Colors.cyanAccent, size: 24),
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
                            style: const TextStyle(
                              color: AppColors.alertGreen,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(3),
                      child: Row(
                        children: [
                          _buildDwrProductTab(
                            id: 'caz',
                            label: 'MaxZ Reflectivity',
                            isSelected: _selectedDwrProduct == 'caz',
                            onTap: () => setModalState(() => _selectedDwrProduct = 'caz'),
                          ),
                          _buildDwrProductTab(
                            id: 'ppz',
                            label: 'PPI Echoes',
                            isSelected: _selectedDwrProduct == 'ppz',
                            onTap: () => setModalState(() => _selectedDwrProduct = 'ppz'),
                          ),
                          _buildDwrProductTab(
                            id: 'sri',
                            label: 'Surface Rain',
                            isSelected: _selectedDwrProduct == 'sri',
                            onTap: () => setModalState(() => _selectedDwrProduct = 'sri'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 220,
                        width: double.infinity,
                        color: Colors.black,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.network(
                              liveImgUrl,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(color: Colors.cyanAccent, strokeWidth: 2),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.signal_wifi_connected_no_internet_4_rounded,
                                          color: Colors.grey, size: 32),
                                      const SizedBox(height: 6),
                                      Text(
                                        'IMD ${station.name} Sweep Standby',
                                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.75),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.fiber_manual_record, color: Colors.redAccent, size: 10),
                                    SizedBox(width: 4),
                                    Text(
                                      'IMD MAUSAM LIVE',
                                      style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
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
                                : 'Moderate Echo',
                            icon: Icons.grain_rounded,
                            color: (station.peakReflectivityDbz ?? 0) > 35 ? AppColors.alertRed : Colors.cyanAccent,
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
                            label: 'Distance to You',
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
                          'Last Sweep: ${station.lastSweepUtc.toLocal().toString().substring(11, 16)} IST',
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
                          label: const Text('Center Radar',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDwrProductTab({
    required String id,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.brandBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
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

  void _showHighResSatelliteViewer(BuildContext context, String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              Expanded(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.cyanAccent, strokeWidth: 2),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Pinch to zoom native resolution',
                        style: TextStyle(color: Colors.white60, fontSize: 11)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('ISRO MOSDAC / IMD',
                          style: TextStyle(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
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

    final String insatImageUrl = _activeLayer == 'insat_vis'
        ? 'https://mausam.imd.gov.in/Satellite/3Dasiasec_vis.jpg'
        : (_activeLayer == 'insat_wv'
            ? 'https://mausam.imd.gov.in/Satellite/3Dasiasec_wv.jpg'
            : 'https://mausam.imd.gov.in/Satellite/3Dasiasec_ir1.jpg');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Live Satellite & Radar GIS',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          if (_activeLayer == 'imd_dwr')
            IconButton(
              icon: Icon(
                _showRadarRangeRings ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                color: _showRadarRangeRings ? Colors.cyanAccent : Colors.grey,
              ),
              onPressed: () => setState(() => _showRadarRangeRings = !_showRadarRangeRings),
              tooltip: _showRadarRangeRings ? 'Hide Surveillance Rings' : 'Show Surveillance Rings',
            ),
          IconButton(
            icon: _isLoadingRadar || _isLoadingRadarFrames
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.cyanAccent),
                  )
                : Icon(Icons.refresh_rounded, color: accentBlue),
            onPressed: (_isLoadingRadar || _isLoadingRadarFrames)
                ? null
                : () {
                    _fetchRainViewerFrames();
                    _loadSatelliteRadarData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Refreshing radar and satellite telemetry...')),
                    );
                  },
            tooltip: 'Refresh Weather Layers',
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
              label: const Text('Report Hazard',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
      body: Stack(
        children: [
          // 1. FlutterMap: Interactive, Smooth GIS Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: currentPoint,
              initialZoom: 7.5,
              minZoom: 2.0,
              maxZoom: 18.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              // Base Map Tiles: Esri World Dark Gray Canvas (High contrast dark GIS basemap, 100% free, zero API key required)
              TileLayer(
                urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Dark_Gray_Base/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.vaanilaiai.app',
                minZoom: 1,
                maxZoom: 18,
                maxNativeZoom: 16,
              ),

              // Weather Overlay: INSAT-3DR Geostationary Products
              if (_activeLayer.startsWith('insat_'))
                OverlayImageLayer(
                  overlayImages: [
                    OverlayImage(
                      bounds: LatLngBounds(
                        const LatLng(-10.0, 40.0),
                        const LatLng(45.0, 115.0),
                      ),
                      imageProvider: NetworkImage(insatImageUrl),
                      opacity: 0.72,
                    ),
                  ],
                ),

              // Weather Overlay: RainViewer Live Radar Tiles
              // Clamped to maxNativeZoom: 7 to completely eliminate the "Zoom Level Not Supported" watermark!
              if ((_activeLayer == 'precipitation' || _activeLayer == 'imd_dwr') &&
                  _currentRadarTileUrl.isNotEmpty)
                TileLayer(
                  key: ValueKey(_currentRadarTileUrl),
                  urlTemplate: _currentRadarTileUrl,
                  userAgentPackageName: 'com.vaanilaiai.app',
                  minZoom: 0,
                  maxZoom: 18,
                  maxNativeZoom: 7,
                  tileBuilder: (context, tileWidget, tile) =>
                      Opacity(opacity: 0.72, child: tileWidget),
                ),

              // Reference Labels & Boundaries (Displays cities & borders crisply on top of radar overlays)
              TileLayer(
                urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Dark_Gray_Reference/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.vaanilaiai.app',
                minZoom: 1,
                maxZoom: 18,
                maxNativeZoom: 16,
              ),

              // Doppler Weather Radar Range Rings Layer (when imd_dwr active)
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
                  // User Location marker
                  Marker(
                    point: currentPoint,
                    width: 170,
                    height: 60,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.darkSurface.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: accentBlue, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: accentBlue.withValues(alpha: 0.4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.my_location_rounded, color: accentBlue, size: 13),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '${weatherProvider.locationName} (${weatherProvider.forecast?.current.temperature.round() ?? "--"}°)',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_drop_down_rounded, color: accentBlue, size: 18),
                      ],
                    ),
                  ),

                  // IMD Doppler Weather Radar Station Markers
                  if (_activeLayer == 'imd_dwr' && _satelliteRadarData != null)
                    ..._satelliteRadarData!.dwrStations.map((station) {
                      final hasConvectiveEcho = (station.peakReflectivityDbz ?? 0) > 30.0;
                      final pinColor = hasConvectiveEcho ? AppColors.alertRed : Colors.cyanAccent;

                      return Marker(
                        point: LatLng(station.latitude, station.longitude),
                        width: 50,
                        height: 50,
                        child: GestureDetector(
                          onTap: () => _showDwrStationDetails(context, station),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: AppColors.darkSurface.withValues(alpha: 0.95),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: pinColor, width: 1.8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: pinColor.withValues(alpha: 0.4),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Icon(Icons.radar_rounded, color: pinColor, size: 18),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  station.name.split('(').first.trim().split(' ').first,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                  // Citizen Ground Report Markers
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
                        width: 40,
                        height: 40,
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
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Icon(pinIcon, color: Colors.white, size: 20),
                          ),
                        ),
                      );
                    }),

                  // Disaster Zone Alert Markers
                  if (_activeLayer == 'alerts')
                    ...alertProvider.activeAlerts.map((alert) {
                      final isRed = alert.severity.toLowerCase() == 'red';
                      final color = isRed ? AppColors.alertRed : AppColors.alertOrange;
                      return Marker(
                        point: currentPoint,
                        width: 38,
                        height: 38,
                        child: Container(
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                            border: Border.all(color: color, width: 2),
                          ),
                          child: Icon(Icons.warning_rounded, color: color, size: 18),
                        ),
                      );
                    }),
                ],
              ),
            ],
          ),

          // 2. Layer Switcher Pills (Top Header)
          Positioned(
            top: 12,
            left: 12,
            right: 12,
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

          // 3. Nearest DWR HUD Badge (Context-sensitive: Visible ONLY on IMD DWR Layer)
          if (_activeLayer == 'imd_dwr' && _satelliteRadarData?.nearestDwrStation != null)
            Positioned(
              top: 60,
              left: 12,
              right: 12,
              child: GestureDetector(
                onTap: () {
                  final station = _satelliteRadarData!.nearestDwrStation!;
                  _mapController.move(LatLng(station.latitude, station.longitude), 8.5);
                  _showDwrStationDetails(context, station);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: mapCardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: mapCardBorder, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.cyan.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.radar_rounded, color: Colors.cyanAccent, size: 15),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Nearest DWR: ${_satelliteRadarData!.nearestDwrStation!.name.split('(').first.trim()}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
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
                                    style: const TextStyle(
                                      color: Colors.cyanAccent,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              _satelliteRadarData!.localRadarCoverageStatus.split('(').first.trim(),
                              style: const TextStyle(color: Colors.white70, fontSize: 9.5),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Colors.white54, size: 16),
                    ],
                  ),
                ),
              ),
            ),

          // 4. INSAT High-Res Inspection Chip (Context-sensitive: Visible on INSAT Layers)
          if (_activeLayer.startsWith('insat_'))
            Positioned(
              top: 60,
              right: 12,
              child: GestureDetector(
                onTap: () {
                  final title = _activeLayer == 'insat_vis'
                      ? 'INSAT-3DR Visible Cloud Albedo'
                      : (_activeLayer == 'insat_wv'
                          ? 'INSAT-3DR Tropospheric Water Vapor'
                          : 'INSAT-3DR Thermal IR (Cloud Top Temperature)');
                  _showHighResSatelliteViewer(context, insatImageUrl, title);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: mapCardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE040FB), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.zoom_in_rounded, color: Color(0xFFE040FB), size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Full Res Satellite',
                        style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 5. On-screen Zoom & Recenter Controls (Right Side)
          Positioned(
            right: 12,
            bottom: _activeLayer == 'precipitation' ? 95 : 30,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMapControlBtn(
                  icon: Icons.add,
                  onTap: () {
                    final zoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, zoom + 1.0);
                  },
                ),
                const SizedBox(height: 6),
                _buildMapControlBtn(
                  icon: Icons.remove,
                  onTap: () {
                    final zoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, zoom - 1.0);
                  },
                ),
                const SizedBox(height: 6),
                _buildMapControlBtn(
                  icon: Icons.my_location,
                  onTap: () => _mapController.move(currentPoint, 8.0),
                ),
              ],
            ),
          ),

          // 6. Dynamic Scientific Legend (Bottom Left)
          Positioned(
            left: 12,
            bottom: _activeLayer == 'precipitation' ? 95 : 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: 160,
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: LinearGradient(
                        colors: _getLegendGradient(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 160,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            _getLegendMinLabel(),
                            style: const TextStyle(color: Colors.white60, fontSize: 8),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _getLegendMaxLabel(),
                            style: const TextStyle(color: Colors.white60, fontSize: 8),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 7. Radar Replay Control Bar (Context-sensitive: Visible ONLY on Live Radar)
          if (_activeLayer == 'precipitation')
            Positioned(
              left: 12,
              right: 12,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: mapCardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: mapCardBorder, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                        color: accentBlue,
                        size: 32,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: _radarFrames.isNotEmpty ? _togglePlayback : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('-2h Past', style: TextStyle(color: Colors.white60, fontSize: 9.5)),
                              Text(
                                _radarFrames.isNotEmpty
                                    ? _radarFrames[_currentFrameIndex].formattedTime(DateTime.now())
                                    : (_isLoadingRadarFrames ? 'Loading radar frames...' : 'Live Radar'),
                                style: TextStyle(
                                  color: accentBlue,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Text('Live Now', style: TextStyle(color: Colors.white60, fontSize: 9.5)),
                            ],
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                              activeTrackColor: accentBlue,
                              inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                              thumbColor: accentBlue,
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                            ),
                            child: Slider(
                              value: _radarFrames.isNotEmpty
                                  ? _currentFrameIndex.toDouble()
                                  : 0.0,
                              min: 0.0,
                              max: _radarFrames.isNotEmpty
                                  ? (_radarFrames.length - 1).toDouble()
                                  : 1.0,
                              onChanged: _radarFrames.isNotEmpty ? _onSliderChanged : null,
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

  Widget _buildMapControlBtn({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.grey.shade900.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 18),
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
        ? color.withValues(alpha: 0.24)
        : Colors.grey.shade900.withValues(alpha: 0.85);
    final border = isSelected ? color : Colors.white.withValues(alpha: 0.15);

    return InkWell(
      onTap: () {
        setState(() {
          _activeLayer = id;
          if (_isPlaying) {
            _playbackTimer?.cancel();
            _isPlaying = false;
          }
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border, width: isSelected ? 1.5 : 0.8),
          boxShadow: [
            if (isSelected) BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 6),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? color : Colors.white70, size: 14),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLegendTitle() {
    switch (_activeLayer) {
      case 'precipitation':
        return 'Precipitation (mm/h & dBZ)';
      case 'imd_dwr':
        return 'IMD Doppler Reflectivity (dBZ)';
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
        return 'IMD / NDMA Alert Severity';
    }
  }

  List<Color> _getLegendGradient() {
    switch (_activeLayer) {
      case 'precipitation':
        return [Colors.blue.shade900, Colors.cyan, Colors.yellow, Colors.orange, Colors.red];
      case 'imd_dwr':
        return [Colors.blue.shade700, Colors.green, Colors.yellow, Colors.orange, Colors.red, Colors.purple];
      case 'insat_ctt':
        return [
          const Color(0xFF311B92),
          const Color(0xFF1565C0),
          const Color(0xFF00ACC1),
          const Color(0xFF43A047),
          const Color(0xFFFDD835),
          const Color(0xFFE53935)
        ];
      case 'insat_wv':
        return [
          const Color(0xFF212121),
          const Color(0xFF37474F),
          const Color(0xFF0277BD),
          const Color(0xFF29B6F6),
          const Color(0xFFE1F5FE)
        ];
      case 'insat_vis':
        return [
          const Color(0xFF1A1A1A),
          const Color(0xFF616161),
          const Color(0xFFBDBDBD),
          Colors.white
        ];
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
        return '0.5 mm/h (10 dBZ)';
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
        return '50+ mm/h (65 dBZ)';
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
}
