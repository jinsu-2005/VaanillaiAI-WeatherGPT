import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/solar_energy_model.dart';
import '../services/api_service.dart';

class SolarEnergyScreen extends StatefulWidget {
  final SolarEnergyResponseModel? initialData;
  final ApiService? apiService;

  const SolarEnergyScreen({
    super.key,
    this.initialData,
    this.apiService,
  });

  @override
  State<SolarEnergyScreen> createState() => _SolarEnergyScreenState();
}

class _SolarEnergyScreenState extends State<SolarEnergyScreen> {
  late ApiService _apiService;
  SolarEnergyResponseModel? _data;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedParkId = 'bhadla_rajasthan';
  String _selectedLangCode = 'en';
  double _selectedRooftopKwp = 3.0; // Default 3 kWp typical household

  final List<Map<String, String>> _parks = [
    {'id': 'bhadla_rajasthan', 'name': 'Bhadla Solar Park (RJ)'},
    {'id': 'pavagada_karnataka', 'name': 'Pavagada Park (KA)'},
    {'id': 'charanka_gujarat', 'name': 'Charanka Park (GJ)'},
    {'id': 'rewa_madhya_pradesh', 'name': 'Rewa Solar (MP)'},
    {'id': 'kurnool_andhra_pradesh', 'name': 'Kurnool Park (AP)'},
    {'id': 'delhi_ncr_rooftop', 'name': 'Delhi-NCR (PM Surya Ghar)'},
    {'id': 'kamuthi_tamil_nadu', 'name': 'Kamuthi Solar (TN)'},
  ];

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'label': 'English'},
    {'code': 'hi', 'label': 'हिंदी'},
    {'code': 'gu', 'label': 'ગુજરાતી'},
    {'code': 'kn', 'label': 'ಕನ್ನಡ'},
    {'code': 'te', 'label': 'తెలుగు'},
    {'code': 'ta', 'label': 'தமிழ்'},
    {'code': 'mr', 'label': 'मराठी'},
  ];

  final List<double> _rooftopSizes = [1.0, 2.0, 3.0, 5.0, 10.0];

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    if (widget.initialData != null) {
      _data = widget.initialData;
      _selectedParkId = widget.initialData!.selectedSector.parkId;
    } else {
      _fetchSolarAssessment();
    }
  }

  Future<void> _fetchSolarAssessment({String? parkId}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _apiService.getSolarEnergyAssessment(
        parkId: parkId ?? _selectedParkId,
      );
      setState(() {
        _data = res;
        _selectedParkId = res.selectedSector.parkId;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load solar energy forecasting data: $e';
        _isLoading = false;
      });
    }
  }

  Color _tierColor(String tier) {
    switch (tier.toUpperCase()) {
      case 'EXCELLENT':
        return const Color(0xFFF59E0B); // Amber gold
      case 'GOOD':
        return const Color(0xFF10B981); // Emerald green
      case 'MODERATE':
        return const Color(0xFF38BDF8); // Sky blue
      case 'POOR':
      default:
        return const Color(0xFF94A3B8); // Slate grey
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('☀️ Solar Radiation & Rooftop PV'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _fetchSolarAssessment(),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _data == null) {
      return const Center(
        child: SpinKitPulse(color: Color(0xFFF59E0B), size: 48.0),
      );
    }
    if (_errorMessage != null && _data == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 48),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: const TextStyle(color: Color(0xFFF87171)), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _fetchSolarAssessment(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final sector = _data!.selectedSector;
    return RefreshIndicator(
      onRefresh: () => _fetchSolarAssessment(),
      color: const Color(0xFFF59E0B),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // ──── Offline Banner ────
          if (_data!.isOfflineCached)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF78350F),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.cloud_off, color: Color(0xFFFBBF24), size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Offline Mode — Calibrated Solar Baseline',
                        style: TextStyle(color: Color(0xFFFBBF24), fontSize: 12)),
                  ),
                ],
              ),
            ),

          // ──── Solar Park Selector Chips ────
          _buildParkSelector(),
          const SizedBox(height: 16),

          // ──── Hero Irradiance & Yield Card ────
          _buildHeroIrradianceCard(sector),
          const SizedBox(height: 16),

          // ──── Photovoltaic Cell Thermal & Efficiency HUD ────
          _buildCellThermalHud(sector),
          const SizedBox(height: 16),

          // ──── PM Surya Ghar Rooftop Solar Economics ────
          _buildRooftopEconomicsCard(sector),
          const SizedBox(height: 16),

          // ──── Soiling & Panel Washing Advisory ────
          _buildSoilingAdvisoryCard(sector),
          const SizedBox(height: 16),

          // ──── Hourly Solar Profile ────
          _buildHourlyForecastCard(sector),
          const SizedBox(height: 16),

          // ──── Multilingual Bulletins ────
          _buildVernacularBulletinCard(sector),
          const SizedBox(height: 16),

          // ──── Provenance Footer ────
          _buildProvenanceFooter(),
        ],
      ),
    );
  }

  // ──────────────── Park Selector ────────────────

  Widget _buildParkSelector() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _parks.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final p = _parks[index];
          final isSelected = p['id'] == _selectedParkId;
          return ChoiceChip(
            label: Text(p['name']!, style: TextStyle(
              color: isSelected ? Colors.black : const Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
            )),
            selected: isSelected,
            selectedColor: const Color(0xFFF59E0B),
            backgroundColor: const Color(0xFF1E293B),
            side: BorderSide(
              color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFF334155),
            ),
            onSelected: (selected) {
              if (selected) {
                setState(() => _selectedParkId = p['id']!);
                _fetchSolarAssessment(parkId: p['id']!);
              }
            },
          );
        },
      ),
    );
  }

  // ──────────────── Hero Irradiance Card ────────────────

  Widget _buildHeroIrradianceCard(SolarParkSectorModel sector) {
    final irr = sector.irradiance;
    final color = _tierColor(sector.radiationTier);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.25), const Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wb_sunny_rounded, color: color, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      '${sector.radiationTier} SOLAR REGIME',
                      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              Text(
                '${sector.installedCapacityMw.toStringAsFixed(0)} MW Capacity',
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            sector.parkName,
            style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
          ),
          Text(
            sector.state,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                irr.ghiWm2.toStringAsFixed(0),
                style: TextStyle(color: color, fontSize: 42, fontWeight: FontWeight.w900),
              ),
              const SizedBox(width: 6),
              const Text('W/m²', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Specific Yield', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                  Text(
                    '${sector.pvPerformance.specificYieldKwhPerKwp.toStringAsFixed(2)} kWh/kWp',
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFF334155), height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniParam('Direct (DNI)', '${irr.dniWm2.toStringAsFixed(0)} W/m²'),
              _buildMiniParam('Diffuse (DHI)', '${irr.dhiWm2.toStringAsFixed(0)} W/m²'),
              _buildMiniParam('Clearness (kt)', irr.clearnessIndexKt.toStringAsFixed(2)),
              _buildMiniParam('Zenith Angle', '${irr.solarZenithAngleDeg.toStringAsFixed(1)}°'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniParam(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ──────────────── PV Cell Thermal & Efficiency HUD ────────────────

  Widget _buildCellThermalHud(SolarParkSectorModel sector) {
    final pv = sector.pvPerformance;
    return _buildGlassCard(
      title: '🔬 Photovoltaic Cell Thermal & Efficiency HUD',
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                'Ambient Temp',
                '${pv.ambientTemperatureC.toStringAsFixed(1)}°C',
                Icons.thermostat_outlined,
                const Color(0xFF38BDF8),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                'PV Cell Temp',
                '${pv.pvCellTemperatureC.toStringAsFixed(1)}°C',
                Icons.local_fire_department_rounded,
                pv.pvCellTemperatureC > 55.0 ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                'Thermal Derating',
                '${pv.temperatureDeratingPct.toStringAsFixed(1)}%',
                Icons.trending_down_rounded,
                const Color(0xFFF97316),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                'System PR',
                '${pv.performanceRatioPct.toStringAsFixed(1)}%',
                Icons.bolt_rounded,
                const Color(0xFF10B981),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'NOCT baseline 45°C. Crystalline Silicon thermal coefficient γ = -0.38%/°C above 25°C.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  // ──────────────── PM Surya Ghar Rooftop Solar Economics ────────────────

  Widget _buildRooftopEconomicsCard(SolarParkSectorModel sector) {
    // Find metrics for currently selected capacity
    final currentMetrics = sector.rooftopEconomics.firstWhere(
      (m) => (m.capacityKwp - _selectedRooftopKwp).abs() < 0.1,
      orElse: () => sector.rooftopEconomics[1], // default 3 kWp
    );

    return _buildGlassCard(
      title: '🏠 PM Surya Ghar Rooftop Solar Calculator',
      children: [
        const Text(
          'Select installed capacity for real-time generation and savings estimates:',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
        ),
        const SizedBox(height: 10),
        // Capacity selector chips
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _rooftopSizes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, idx) {
              final size = _rooftopSizes[idx];
              final isSel = (_selectedRooftopKwp - size).abs() < 0.1;
              return ChoiceChip(
                label: Text('${size.toStringAsFixed(0)} kWp', style: TextStyle(
                  color: isSel ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                )),
                selected: isSel,
                selectedColor: const Color(0xFFF59E0B),
                backgroundColor: const Color(0xFF0F172A),
                side: BorderSide(color: isSel ? const Color(0xFFF59E0B) : const Color(0xFF334155)),
                onSelected: (val) {
                  if (val) setState(() => _selectedRooftopKwp = size);
                },
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Expected Daily Output', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  Text(
                    '${currentMetrics.dailyGenerationKwh.toStringAsFixed(2)} kWh/day',
                    style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Expected Monthly Output', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  Text(
                    '${currentMetrics.monthlyGenerationKwh.toStringAsFixed(0)} kWh/month',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Monthly Electricity Savings', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  Text(
                    '₹${currentMetrics.monthlySavingsInr.toStringAsFixed(0)} / month',
                    style: const TextStyle(color: Color(0xFF10B981), fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('CO₂ Footprint Avoided', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  Text(
                    '${currentMetrics.co2OffsetKgPerMonth.toStringAsFixed(0)} kg CO₂/mo',
                    style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ──────────────── Soiling & Panel Washing Advisory ────────────────

  Widget _buildSoilingAdvisoryCard(SolarParkSectorModel sector) {
    final soil = sector.soilingAdvisory;
    final isUrgent = soil.cleaningUrgency == 'URGENT_CLEANING_REQUIRED';
    final isRec = soil.cleaningRecommended;

    return _buildGlassCard(
      title: '🧹 Dust Soiling & Panel Washing Advisory',
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Dust Soiling Loss', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    '${soil.soilingLossPct.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: isUrgent ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isUrgent
                    ? const Color(0xFF7F1D1D)
                    : isRec
                        ? const Color(0xFF78350F)
                        : const Color(0xFF064E3B),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                soil.cleaningUrgency.replaceAll('_', ' '),
                style: TextStyle(
                  color: isUrgent
                      ? const Color(0xFFFCA5A5)
                      : isRec
                          ? const Color(0xFFFDE68A)
                          : const Color(0xFFA7F3D0),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildInfoRow(Icons.schedule_rounded, 'Optimal Cleaning', soil.optimalCleaningWindow),
        const SizedBox(height: 6),
        _buildInfoRow(Icons.cloudy_snowing, 'Rain Washout Forecast', soil.nextRainWashoutForecast),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String detail) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF94A3B8), size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12, color: Colors.white70),
              children: [
                TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                TextSpan(text: detail),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ──────────────── Hourly Solar Profile ────────────────

  Widget _buildHourlyForecastCard(SolarParkSectorModel sector) {
    final list = sector.hourlyForecast;
    return _buildGlassCard(
      title: '📈 Daylight Generation Profile (Hourly)',
      children: [
        SizedBox(
          height: 136,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, idx) {
              final h = list[idx];
              return Container(
                width: 72,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(h.hour, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600, height: 1.0)),
                    const Icon(Icons.wb_sunny, color: Color(0xFFF59E0B), size: 16),
                    Text(h.ghiWm2.toStringAsFixed(0), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, height: 1.0)),
                    Text('${h.cellTemperatureC.toStringAsFixed(0)}°C', style: const TextStyle(color: Color(0xFFF97316), fontSize: 10, height: 1.0)),
                    Text('${h.estimatedGenerationKwhPerKwp.toStringAsFixed(2)} kWh', style: const TextStyle(color: Color(0xFF10B981), fontSize: 9, height: 1.0)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ──────────────── Multilingual Bulletins ────────────────

  Widget _buildVernacularBulletinCard(SolarParkSectorModel sector) {
    final alerts = sector.vernacularBulletins;
    final text = alerts[_selectedLangCode] ?? alerts['en'] ?? 'Solar forecast unavailable.';

    return _buildGlassCard(
      title: '🌐 Multilingual Solar Energy Advisory',
      children: [
        SizedBox(
          height: 32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _languages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final lang = _languages[index];
              final isSelected = lang['code'] == _selectedLangCode;
              return GestureDetector(
                onTap: () => setState(() => _selectedLangCode = lang['code']!),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFF334155),
                    ),
                  ),
                  child: Text(lang['label']!, style: TextStyle(
                    color: isSelected ? Colors.black : const Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                  )),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
          ),
        ),
      ],
    );
  }

  // ──────────────── Provenance Footer ────────────────

  Widget _buildProvenanceFooter() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📋 ${_data!.bulletinNumber}',
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
          const SizedBox(height: 4),
          Text(_data!.provenance,
              style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11)),
          const SizedBox(height: 4),
          Text(_data!.solarPhysicsModel,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontStyle: FontStyle.italic)),
          const SizedBox(height: 4),
          Text('Overview: ${_data!.nationalSolarOverview}',
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
        ],
      ),
    );
  }

  // ──────────────── Glass Card & Metric Helpers ────────────────

  Widget _buildGlassCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
