import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../models/hydro_model.dart';
import '../providers/weather_provider.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class RiverBasinHydroScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLon;
  final String? initialLocationName;
  final String? initialBasin;

  const RiverBasinHydroScreen({
    super.key,
    this.initialLat,
    this.initialLon,
    this.initialLocationName,
    this.initialBasin,
  });

  @override
  State<RiverBasinHydroScreen> createState() => _RiverBasinHydroScreenState();
}

class _RiverBasinHydroScreenState extends State<RiverBasinHydroScreen> {
  final ApiService _apiService = ApiService();
  CwcHydroOverviewModel? _hydroData;
  bool _isLoading = true;
  String? _selectedBasin;
  String _selectedLang = 'en';

  late double _currentLat;
  late double _currentLon;
  late String _currentLocationName;

  @override
  void initState() {
    super.initState();
    final weatherProv = Provider.of<WeatherProvider>(context, listen: false);
    _currentLat = widget.initialLat ?? weatherProv.latitude;
    _currentLon = widget.initialLon ?? weatherProv.longitude;
    _currentLocationName = widget.initialLocationName ?? weatherProv.locationName;
    _selectedBasin = widget.initialBasin;
    _loadHydroData();
  }

  Future<void> _loadHydroData() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiService.getCwcHydroOverview(
        latitude: _currentLat,
        longitude: _currentLon,
        locationName: _currentLocationName,
        basinName: _selectedBasin,
      );
      if (mounted) {
        setState(() {
          _hydroData = res;
          _selectedBasin = res.selectedBasin;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hydroData = CwcHydroOverviewModel.defaultFallback(
            latitude: _currentLat,
            longitude: _currentLon,
            locationName: _currentLocationName,
            basinName: _selectedBasin ?? 'Ganga',
          );
          _isLoading = false;
        });
      }
    }
  }

  void _onBasinSelected(String basin) {
    if (_selectedBasin == basin) return;
    setState(() {
      _selectedBasin = basin;
    });
    _loadHydroData();
  }

  Color _getFloodStageColor(String stage) {
    switch (stage.toLowerCase()) {
      case 'extreme':
        return Colors.purpleAccent;
      case 'danger':
        return AppColors.alertRed;
      case 'warning':
        return AppColors.alertAmber;
      default:
        return AppColors.alertGreen;
    }
  }

  Color _getSpillwayColor(String status) {
    switch (status.toLowerCase()) {
      case 'heavy inflow spillage':
        return AppColors.alertRed;
      case 'controlled discharge':
        return AppColors.alertAmber;
      default:
        return AppColors.alertGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = AppColors.background(isDark);
    final surface = AppColors.surface(isDark);
    final textPrimary = AppColors.textPrimaryC(isDark);
    final textSecondary = AppColors.textSecondaryC(isDark);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CWC River Basin & Dam Telemetry',
              style: TextStyle(
                color: textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Central Water Commission Flood Early Warning',
              style: TextStyle(
                color: textSecondary,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh hydro-telemetry',
            onPressed: _isLoading ? null : _loadHydroData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SpinKitWave(color: AppColors.brandBlue, size: 36),
                  const SizedBox(height: 16),
                  Text(
                    'Querying CWC River Gauges & Dams...',
                    style: TextStyle(color: textSecondary, fontSize: 13),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadHydroData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basin Selector Horizontal Chips
                    _buildBasinSelector(isDark),
                    const SizedBox(height: 16),

                    // Basin Overview Summary Card
                    _buildBasinSummaryCard(isDark, surface, textPrimary, textSecondary),
                    const SizedBox(height: 16),

                    // Nearest River Gauge Station Card
                    if (_hydroData?.nearestGaugeStation != null) ...[
                      _buildNearestGaugeCard(isDark, surface, textPrimary, textSecondary),
                      const SizedBox(height: 16),
                    ],

                    // Nearest Dam Reservoir Card
                    if (_hydroData?.nearestReservoir != null) ...[
                      _buildNearestReservoirCard(isDark, surface, textPrimary, textSecondary),
                      const SizedBox(height: 16),
                    ],

                    // Downstream Riparian Safety & Multilingual Directives
                    _buildDownstreamDirectivesCard(isDark, surface, textPrimary, textSecondary),
                    const SizedBox(height: 16),

                    // Monitored River Gauge Stations List
                    _buildGaugeStationsList(isDark, surface, textPrimary, textSecondary),
                    const SizedBox(height: 16),

                    // Major Dams & Reservoirs in Basin
                    _buildReservoirsList(isDark, surface, textPrimary, textSecondary),
                    const SizedBox(height: 24),

                    // CWC Provenance Footer
                    _buildProvenanceFooter(isDark, textSecondary),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBasinSelector(bool isDark) {
    final basins = _hydroData?.availableBasins ?? [
      'Ganga', 'Brahmaputra', 'Godavari', 'Krishna', 'Cauvery', 'Narmada', 'Mahanadi', 'Periyar & Pamba'
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: basins.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final b = basins[idx];
          final isSelected = _selectedBasin == b;
          return ChoiceChip(
            label: Text(
              b,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            selected: isSelected,
            selectedColor: AppColors.brandBlue,
            backgroundColor: isDark ? const Color(0xFF1E2638) : const Color(0xFFE8EEF5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            showCheckmark: false,
            onSelected: (_) => _onBasinSelected(b),
          );
        },
      ),
    );
  }

  Widget _buildBasinSummaryCard(bool isDark, Color surface, Color textPrimary, Color textSecondary) {
    final summary = _hydroData!.basinSummary;
    final isCached = _hydroData!.isOfflineCached;
    final riskColor = _getFloodStageColor(summary.synopticFloodRisk);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCached ? AppColors.alertAmber.withValues(alpha: 0.6) : AppColors.border(isDark),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.brandBlue.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.water_rounded, color: AppColors.brandBlue, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${summary.basinName} River Basin',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isCached) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.alertAmber.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'OFFLINE',
                                style: TextStyle(
                                  color: AppColors.alertAmber,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        'Major Rivers: ${summary.majorRivers.take(3).join(', ')}',
                        style: TextStyle(color: textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: riskColor),
                ),
                child: Text(
                  '${summary.synopticFloodRisk.toUpperCase()} RISK',
                  style: TextStyle(
                    color: riskColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryStat('Monitored Stations', '${summary.totalStations}', isDark),
              _buildSummaryStat('In Danger / Above Mark', '${summary.stationsInDanger}', isDark,
                  valColor: summary.stationsInDanger > 0 ? AppColors.alertRed : null),
              _buildSummaryStat('In Warning Stage', '${summary.stationsInWarning}', isDark,
                  valColor: summary.stationsInWarning > 0 ? AppColors.alertAmber : null),
              _buildSummaryStat('Dams > 85% FRL', '${summary.highCapacityDamsCount}', isDark,
                  valColor: summary.highCapacityDamsCount > 0 ? AppColors.alertAmber : null),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, String val, bool isDark, {Color? valColor}) {
    return Column(
      children: [
        Text(
          val,
          style: TextStyle(
            color: valColor ?? AppColors.textPrimaryC(isDark),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondaryC(isDark),
            fontSize: 10.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNearestGaugeCard(bool isDark, Color surface, Color textPrimary, Color textSecondary) {
    final st = _hydroData!.nearestGaugeStation!;
    final stageColor = _getFloodStageColor(st.floodStage);

    // Calculate percentage on hydrograph scale
    final totalRange = (st.highestFloodLevelM - st.warningLevelM).abs();
    final currentDelta = st.currentLevelM - st.warningLevelM;
    final progress = totalRange > 0 ? (currentDelta / totalRange).clamp(0.0, 1.0) : 0.5;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: stageColor.withValues(alpha: 0.7), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: stageColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.analytics_rounded, color: stageColor, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        st.name,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'River ${st.river} • ${st.state} • ${st.distanceKm?.toStringAsFixed(1) ?? '--'} km away',
                        style: TextStyle(color: textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: stageColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  st.floodStage.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Current Water Level vs Danger Level
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${st.currentLevelM.toStringAsFixed(2)} m',
                    style: TextStyle(
                      color: stageColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        st.trend.toLowerCase() == 'rising'
                            ? Icons.trending_up_rounded
                            : (st.trend.toLowerCase() == 'falling'
                                ? Icons.trending_down_rounded
                                : Icons.trending_flat_rounded),
                        size: 16,
                        color: st.trend.toLowerCase() == 'rising' ? AppColors.alertRed : AppColors.brandBlue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${st.trend} Trend',
                        style: TextStyle(color: textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Danger Mark: ${st.dangerLevelM.toStringAsFixed(2)} m',
                    style: TextStyle(
                      color: AppColors.alertRed,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Warning Mark: ${st.warningLevelM.toStringAsFixed(2)} m',
                    style: TextStyle(color: textSecondary, fontSize: 11),
                  ),
                  Text(
                    'Historical HFL: ${st.highestFloodLevelM.toStringAsFixed(2)} m',
                    style: TextStyle(color: textSecondary, fontSize: 10.5),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Visual Hydrograph Level Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: isDark ? const Color(0xFF1E2638) : const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(stageColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearestReservoirCard(bool isDark, Color surface, Color textPrimary, Color textSecondary) {
    final dam = _hydroData!.nearestReservoir!;
    final spillColor = _getSpillwayColor(dam.spillwayStatus);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: spillColor.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.brandBlue.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.table_restaurant_rounded, color: AppColors.brandBlue, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dam.name,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'River ${dam.river} • ${dam.state}',
                        style: TextStyle(color: textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: spillColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  dam.spillwayStatus.toUpperCase(),
                  style: TextStyle(
                    color: spillColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    '${dam.storagePercent}%',
                    style: TextStyle(
                      color: dam.storagePercent >= 85.0 ? AppColors.alertAmber : textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Storage of FRL', style: TextStyle(color: textSecondary, fontSize: 10.5)),
                  Text('${dam.currentStorageTmc} / ${dam.liveStorageCapacityTmc} TMC',
                      style: TextStyle(color: textSecondary, fontSize: 9.5)),
                ],
              ),
              Column(
                children: [
                  Text(
                    '${dam.inflowCusecs.round()} cfs',
                    style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text('Catchment Inflow', style: TextStyle(color: textSecondary, fontSize: 10.5)),
                ],
              ),
              Column(
                children: [
                  Text(
                    '${dam.outflowCusecs.round()} cfs',
                    style: TextStyle(color: spillColor, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text('Spillway Outflow', style: TextStyle(color: textSecondary, fontSize: 10.5)),
                  Text('${dam.spillwayGatesOpen} Gates Open', style: TextStyle(color: textSecondary, fontSize: 9.5)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2638) : const Color(0xFFEFF5FC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.shield_outlined, color: spillColor, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dam.downstreamAlert,
                    style: TextStyle(color: textPrimary, fontSize: 11.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownstreamDirectivesCard(bool isDark, Color surface, Color textPrimary, Color textSecondary) {
    final alerts = _hydroData!.vernacularRiparianAlerts;
    final directives = _hydroData!.downstreamDirectives;

    String currentAlert = alerts[_selectedLang] ?? (directives.isNotEmpty ? directives[0] : '');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final chips = [
                _buildLangChip('EN', 'en', isDark),
                const SizedBox(width: 4),
                _buildLangChip('தமிழ்', 'ta', isDark),
                const SizedBox(width: 4),
                _buildLangChip('हिंदी', 'hi', isDark),
                const SizedBox(width: 4),
                _buildLangChip('বাংলা', 'bn', isDark),
                const SizedBox(width: 4),
                _buildLangChip('অসমীয়া', 'as', isDark),
              ];

              if (constraints.maxWidth < 450) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Downstream Riparian Directives',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: chips),
                    ),
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Downstream Riparian Directives',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(children: chips),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B2333) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              currentAlert,
              style: TextStyle(
                color: textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ...directives.map((d) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.brandBlue, size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        d,
                        style: TextStyle(color: textSecondary, fontSize: 11.5),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildLangChip(String label, String code, bool isDark) {
    final isSelected = _selectedLang == code;
    return GestureDetector(
      onTap: () => setState(() => _selectedLang = code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandBlue : (isDark ? const Color(0xFF2A344A) : const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildGaugeStationsList(bool isDark, Color surface, Color textPrimary, Color textSecondary) {
    final stations = _hydroData!.gaugeStations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monitored River Gauge Stations (${stations.length})',
          style: TextStyle(
            color: textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stations.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, idx) {
            final s = stations[idx];
            final stageColor = _getFloodStageColor(s.floodStage);
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border(isDark)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.name,
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'River ${s.river} • ${s.state}',
                          style: TextStyle(color: textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${s.currentLevelM.toStringAsFixed(2)} m',
                        style: TextStyle(
                          color: stageColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Danger: ${s.dangerLevelM.toStringAsFixed(2)} m',
                        style: TextStyle(color: textSecondary, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildReservoirsList(bool isDark, Color surface, Color textPrimary, Color textSecondary) {
    final reservoirs = _hydroData!.reservoirs;
    if (reservoirs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Major Reservoirs & Multi-Purpose Dams (${reservoirs.length})',
          style: TextStyle(
            color: textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reservoirs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, idx) {
            final dam = reservoirs[idx];
            final spillColor = _getSpillwayColor(dam.spillwayStatus);
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border(isDark)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dam.name,
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'River ${dam.river} • ${dam.state}',
                          style: TextStyle(color: textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${dam.storagePercent}% FRL',
                        style: TextStyle(
                          color: dam.storagePercent >= 85.0 ? AppColors.alertAmber : textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        dam.spillwayStatus,
                        style: TextStyle(color: spillColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProvenanceFooter(bool isDark, Color textSecondary) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_user_rounded, color: AppColors.brandBlue, size: 14),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                _hydroData?.provenanceAuthority ??
                    'Central Water Commission (CWC) & Ministry of Jal Shakti Hydro-Telemetry',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Automated River Gauge Telemetry & Multi-Purpose Reservoir Storage Engine',
          style: TextStyle(color: textSecondary.withValues(alpha: 0.8), fontSize: 9.5),
        ),
      ],
    );
  }
}
