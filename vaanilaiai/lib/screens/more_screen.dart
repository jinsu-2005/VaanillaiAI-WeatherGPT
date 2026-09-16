import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import 'air_quality_screen.dart';
import 'sun_moon_screen.dart';
import 'rainfall_history_screen.dart';
import 'saved_locations_screen.dart';
import 'voice_weather_screen.dart';
import 'settings_screen.dart';
import 'advisories_screen.dart';
import 'climate_screen.dart';
import 'heat_stress_screen.dart';
import 'auth_screen.dart';
import 'agromet_bulletin_screen.dart';
import 'urban_flood_screen.dart';
import 'multi_model_nwp_screen.dart';
import 'imd_sop_screen.dart';
import 'lightning_safety_screen.dart';
import 'marine_ocean_screen.dart';
import 'river_basin_hydro_screen.dart';
import 'monsoon_teleconnections_screen.dart';
import 'cyclone_tracker_screen.dart';
import 'fog_nowcast_screen.dart';
import 'coldwave_screen.dart';
import 'pest_forewarning_screen.dart';
import 'avalanche_snow_screen.dart';
import 'convective_storm_screen.dart';
import 'drought_monitor_screen.dart';
import 'marine_heatwave_screen.dart';
import 'cloudburst_screen.dart';
import 'hazmat_screen.dart';
import 'forest_fire_screen.dart';
import 'heat_action_plan_screen.dart';
import 'tsunami_screen.dart';
import 'crop_water_stress_screen.dart';
import 'storm_surge_screen.dart';
import 'ocean_state_screen.dart';
import 'livestock_heat_stress_screen.dart';
import 'earthquake_screen.dart';
import 'solar_energy_screen.dart';
import 'lightning_cell_screen.dart';
import 'wind_energy_screen.dart';
import 'glof_screen.dart';
import 'oil_spill_screen.dart';
import 'urban_heat_island_screen.dart';
import 'potential_fishing_zone_screen.dart';
import 'extended_range_prediction_screen.dart';
import 'snowmelt_runoff_screen.dart';
import 'agri_storage_screen.dart';
import 'flash_drought_screen.dart';
import 'hydro_rating_screen.dart';
import 'saltwater_intrusion_screen.dart';

class MoreScreen extends StatelessWidget {
  final Function(int) onNavigateTab;

  const MoreScreen({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isGuest = authProvider.isGuest;

    final surfaceColor = AppColors.surface(isDark);
    final borderColor = AppColors.border(isDark);
    final textPrimary = AppColors.textPrimaryC(isDark);
    final textSecondary = AppColors.textSecondaryC(isDark);
    final accentBlue = isDark ? AppColors.brandBlueLight : AppColors.brandBlue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Features & Intelligence'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── User Profile Card ────────────────────────────────────────
            InkWell(
              onTap: () {
                if (isGuest) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const AuthScreen()));
                } else {
                  _showProfileDialog(context, authProvider);
                }
              },
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isGuest
                        ? borderColor
                        : accentBlue.withValues(alpha: 0.5),
                    width: isGuest ? 1.0 : 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isGuest ? AppColors.brandBlueContainer : accentBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isGuest
                            ? Icon(Icons.person_outline_rounded,
                                color: accentBlue, size: 28)
                            : Text(
                                user?.displayName.isNotEmpty == true
                                    ? user!.displayName[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800),
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                isGuest
                                    ? 'Guest Citizen'
                                    : (user?.displayName ?? 'User'),
                                style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700),
                              ),
                              if (!isGuest) ...[
                                const SizedBox(width: 6),
                                Icon(Icons.verified_rounded,
                                    color: accentBlue, size: 16),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isGuest
                                ? 'Tap to sign in & sync across devices'
                                : (user?.roleDisplayName ?? ''),
                            style: TextStyle(
                              color: isGuest ? accentBlue : textSecondary,
                              fontSize: 12,
                              fontWeight: isGuest
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isGuest ? Icons.login_rounded : Icons.chevron_right_rounded,
                      color: accentBlue,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Section: Navigation ──────────────────────────────────────
            _sectionHeader('Navigation', textSecondary),
            const SizedBox(height: 8),
            _buildMenuSection(
              context,
              surfaceColor,
              borderColor,
              textPrimary,
              [
                _MenuItem(Icons.dashboard_rounded, 'Dashboard', accentBlue,
                    () => onNavigateTab(0)),
                _MenuItem(Icons.satellite_alt_rounded, 'Satellite & Radar GIS Map', accentBlue,
                    () => onNavigateTab(1)),
                _MenuItem(Icons.smart_toy_rounded, 'AI WeatherGPT', accentBlue,
                    () => onNavigateTab(2)),
                _MenuItem(Icons.crisis_alert_rounded, 'Disaster Alerts', AppColors.alertRed,
                    () => onNavigateTab(3)),
              ],
            ),

            const SizedBox(height: 20),

            // ── Section: Intelligence Tools ──────────────────────────────
            _sectionHeader('Intelligence Tools', textSecondary),
            const SizedBox(height: 8),
            _buildMenuSection(
              context,
              surfaceColor,
              borderColor,
              textPrimary,
              [
                _MenuItem(Icons.agriculture_rounded, 'Agro & Farmer Advisory',
                    AppColors.alertGreen, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AdvisoriesScreen()));
                }),
                _MenuItem(Icons.description_rounded, 'District Agromet Bulletin (GKMS)',
                    AppColors.alertGreen, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AgrometBulletinScreen()));
                }),
                _MenuItem(Icons.trending_up_rounded, 'Climate Trends & 5Y Analysis',
                    AppColors.alertOrange, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ClimateScreen()));
                }),
                _MenuItem(Icons.eco_rounded, 'Air Quality Index (AQI)',
                    AppColors.alertGreen, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AirQualityScreen()));
                }),
                _MenuItem(Icons.water_drop_rounded, 'Rainfall History',
                    AppColors.weatherRain, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const RainfallHistoryScreen()));
                }),
                _MenuItem(Icons.whatshot_rounded, 'Heat Stress & Wet-Bulb Monitor',
                    AppColors.alertOrange, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const HeatStressScreen()));
                }),
                _MenuItem(Icons.water_damage_rounded, 'Urban Flood & Inundation Risk',
                    AppColors.weatherRain, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const UrbanFloodScreen()));
                }),
                _MenuItem(Icons.hub_rounded, 'NWP Multi-Model Ensemble',
                    AppColors.brandBlue, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const MultiModelNwpScreen()));
                }),
                _MenuItem(Icons.shield_outlined, 'IMD Warning Matrix & SOPs',
                    AppColors.alertRed, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ImdSopScreen()));
                }),
                _MenuItem(Icons.flash_on_rounded, 'Damini Lightning & 30-30 Safety',
                    AppColors.alertOrange, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const LightningSafetyScreen()));
                }),
                _MenuItem(Icons.radar_rounded, 'MOSDAC Satellite & DWR Radar',
                    Colors.cyan, () => onNavigateTab(1)),
                _MenuItem(Icons.tsunami_rounded, 'INCOIS Marine & Kallakkadal Swell',
                    Colors.indigoAccent, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const MarineOceanScreen()));
                }),
                _MenuItem(Icons.water_rounded, 'CWC River Basin & Dam Telemetry',
                    Colors.lightBlue, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const RiverBasinHydroScreen()));
                }),
                _MenuItem(Icons.cyclone_rounded, 'Monsoon Teleconnections & LRF',
                    Colors.cyanAccent, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const MonsoonTeleconnectionsScreen()));
                }),
                _MenuItem(Icons.storm_rounded, 'IMD Cyclone & Surge Tracker',
                    AppColors.alertRed, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CycloneTrackerScreen()));
                }),
                _MenuItem(Icons.wb_twilight_rounded, 'Sun & Moon Tracker',
                    AppColors.weatherSunny, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SunMoonScreen()));
                }),
                _MenuItem(Icons.mic_rounded, 'Voice Weather', accentBlue, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const VoiceWeatherScreen()));
                }),
              ],
            ),

            const SizedBox(height: 20),

            // ── Section: Plan to Add ──────────────────────────────────────
            _sectionHeader('Plan to add', textSecondary),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.science_rounded, color: Colors.purpleAccent, size: 20),
                  ),
                  title: Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Upcoming Features',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
                        ),
                        child: const Text(
                          '30 Demos',
                          style: TextStyle(
                            color: Colors.purpleAccent,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    'Preview upcoming models, radar engines & disaster telemetry',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                  children: [
                    Divider(height: 1, color: borderColor),
                    ..._buildPlanToAddItems(context, textPrimary, textSecondary, borderColor),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Section: Account & Settings ──────────────────────────────
            _sectionHeader('Account & Settings', textSecondary),
            const SizedBox(height: 8),
            _buildMenuSection(
              context,
              surfaceColor,
              borderColor,
              textPrimary,
              [
                _MenuItem(Icons.location_on_rounded, 'Manage Locations',
                    accentBlue, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SavedLocationsScreen()));
                }),
                _MenuItem(Icons.settings_rounded, 'Settings & Themes', accentBlue,
                    () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()));
                }),
              ],
            ),

            const SizedBox(height: 24),

            // Footer
            Center(
              child: Text(
                'VaanilaiAI v1.0 · Powered by IMD / MoES & Gemini AI',
                style: TextStyle(
                    color: AppColors.textTertiaryC(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);
}

  Widget _sectionHeader(String title, Color textSecondary) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    List<_MenuItem> items,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;
          return Column(
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: item.iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: item.iconColor, size: 20),
                ),
                title: Text(
                  item.title,
                  style: TextStyle(
                      color: textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
                trailing: Icon(Icons.chevron_right_rounded,
                    color: AppColors.textTertiaryC(
                        Theme.of(context).brightness == Brightness.dark),
                    size: 20),
                onTap: item.onTap,
              ),
              if (!isLast)
                Divider(
                    height: 1,
                    color: borderColor,
                    indent: 62,
                    endIndent: 0),
            ],
          );
        }),
      ),
    );
  }

  List<Widget> _buildPlanToAddItems(BuildContext context, Color textPrimary,
      Color textSecondary, Color borderColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = [
      _MenuItem(Icons.foggy, 'FogPass & Highway Visibility Nowcast',
          Colors.purpleAccent, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const FogNowcastScreen()));
      }),
      _MenuItem(Icons.ac_unit_rounded, 'Cold Wave & Ground Frost Vulnerability',
          const Color(0xFF38BDF8), () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ColdWaveScreen()));
      }),
      _MenuItem(Icons.bug_report_rounded, 'Pest & Disease Forewarning (GKMS)',
          Colors.lightGreen, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PestForewarningScreen()));
      }),
      _MenuItem(Icons.terrain_rounded, 'Himalayan Snow & Avalanche (DGRE)',
          const Color(0xFF0EA5E9), () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AvalancheSnowScreen()));
      }),
      _MenuItem(Icons.flash_on_rounded, 'Severe Storms & Haboobs (Kalbaishakhi)',
          Colors.amber, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ConvectiveStormScreen()));
      }),
      _MenuItem(Icons.grass_rounded, 'Drought & Soil Moisture (CGWB)',
          Colors.orange, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const DroughtMonitorScreen()));
      }),
      _MenuItem(Icons.water_rounded, 'Marine Heatwaves & Coral Bleaching (INCOIS)',
          Colors.cyanAccent, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const MarineHeatwaveScreen()));
      }),
      _MenuItem(Icons.landslide_rounded, 'Cloudburst & Landslide Debris Flow (GSI/IMD)',
          Colors.orangeAccent, () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CloudburstScreen()));
      }),
      _MenuItem(Icons.science_rounded, 'Industrial Hazmat & Toxic Plume (CPCB/NDMA)',
          const Color(0xFFF59E0B), () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const HazmatScreen()));
      }),
      _MenuItem(Icons.local_fire_department_rounded, 'Forest Fire & Van Agni FWI (FSI/ISRO)',
          const Color(0xFFF97316), () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ForestFireScreen()));
      }),
      _MenuItem(Icons.sunny, 'Heat Action Plan & Solar UV (NDMA/IMD)',
          const Color(0xFFEA580C), () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const HeatActionPlanScreen()));
      }),
      _MenuItem(Icons.tsunami_rounded, 'Indian Tsunami Early Warning (INCOIS/ITEWS)',
          const Color(0xFF06B6D4), () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const TsunamiScreen()));
      }),
      _MenuItem(Icons.grass_rounded, 'Crop Water Stress & Soil Moisture (ICAR/IMD)',
          const Color(0xFF10B981), () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CropWaterStressScreen()));
      }),
      _MenuItem(Icons.flood_rounded, 'Storm Surge & Tidal Inundation (INCOIS/IMD)',
          const Color(0xFF38BDF8), () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const StormSurgeScreen()));
      }),
      _MenuItem(Icons.waves_rounded, 'Ocean State Forecast & Rip Currents (INCOIS/OSF)',
          const Color(0xFF06B6D4), () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const OceanStateScreen()));
      }),
      _MenuItem(Icons.pets_rounded, 'Livestock Thermal Stress & THI (ICAR/NDRI)',
          const Color(0xFFF97316), () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const LivestockHeatStressScreen()));
      }),
      _MenuItem(Icons.vibration_rounded, 'Earthquake Seismology & Aftershocks (NCS/NDMA)',
          const Color(0xFFEF4444), () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const EarthquakeScreen()));
      }),
      _MenuItem(Icons.wb_sunny_rounded, 'Solar Radiation & Rooftop PV Yield (NISE/IMD)',
          const Color(0xFFF59E0B), () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SolarEnergyScreen()));
      }),
      _MenuItem(Icons.flash_on_rounded, 'Lightning Cell & Downburst Radar (IITM/IMD)',
          const Color(0xFFEF4444), () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const LightningCellScreen()));
      }),
      _MenuItem(Icons.wind_power_rounded, 'Wind Resource & Hub-Height Atlas (NIWE/IMD)',
          const Color(0xFF00B4D8), () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const WindEnergyScreen()));
      }),
      _MenuItem(Icons.water_damage_rounded, 'Himalayan GLOF Early Warning (NRSC/CWC)',
          const Color(0xFF38BDF8), () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const GlofScreen()));
      }),
      _MenuItem(Icons.oil_barrel_rounded, 'Marine Oil Spill & Habitat Radar (INCOIS/ICG)',
          const Color(0xFF00B4D8), () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const OilSpillScreen()));
      }),
      _MenuItem(Icons.roofing_rounded, 'Urban Heat Island & Cool Roof Engine (IMD/NDMA)',
          const Color(0xFFEA580C), () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const UrbanHeatIslandScreen()));
      }),
      _MenuItem(Icons.set_meal_rounded, 'Potential Fishing Zone & Ocean Color (INCOIS/CMFRI)',
          const Color(0xFF0284C7), () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PotentialFishingZoneScreen()));
      }),
      _MenuItem(Icons.calendar_month_rounded, 'Monsoon Extended Range Prediction (IITM/NCMRWF)',
          const Color(0xFF0284C7), () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ExtendedRangePredictionScreen()));
      }),
      _MenuItem(Icons.terrain_rounded, 'Himalayan Snowmelt Runoff & Glaciers (IMD/CWC)',
          const Color(0xFF06B6D4), () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SnowmeltRunoffScreen()));
      }),
      _MenuItem(Icons.grain, 'Mandi Storage & Grain Defense (IMD/ICAR)',
          const Color(0xFFF59E0B), () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AgriStorageScreen()));
      }),
      _MenuItem(Icons.water_damage_rounded, 'Flash Drought & Soil Desiccation (IMD/CWC)',
          const Color(0xFFEA580C), () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const FlashDroughtScreen()));
      }),
      _MenuItem(Icons.flood_rounded, 'CWC Flood Rating & Embankments (CWC/IMD)',
          const Color(0xFF0284C7), () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const HydroRatingScreen()));
      }),
      _MenuItem(Icons.water, 'Coastal Saline Intrusion & Aquifers (INCOIS/CGWB)',
          const Color(0xFF0284C7), () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SaltwaterIntrusionScreen()));
      }),
    ];

    return List.generate(items.length, (index) {
      final item = items[index];
      final isLast = index == items.length - 1;
      return Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: item.iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: item.iconColor, size: 20),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                        color: textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.purple.withValues(alpha: 0.25)),
                  ),
                  child: const Text(
                    'Demo',
                    style: TextStyle(
                      color: Colors.purpleAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            trailing: Icon(Icons.chevron_right_rounded,
                color: AppColors.textTertiaryC(isDark),
                size: 20),
            onTap: item.onTap,
          ),
          if (!isLast)
            Divider(
                height: 1,
                color: borderColor,
                indent: 62,
                endIndent: 0),
        ],
      );
    });
  }

  void _showProfileDialog(BuildContext context, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface(isDark),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.border(isDark),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.brandBlue,
                child: Text(
                  auth.user?.displayName.isNotEmpty == true
                      ? auth.user!.displayName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                auth.user?.displayName ?? 'User',
                style: TextStyle(
                    color: AppColors.textPrimaryC(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                auth.user?.email ?? '',
                style: TextStyle(
                    color: AppColors.textSecondaryC(isDark), fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                auth.user?.roleDisplayName ?? '',
                style: const TextStyle(
                    color: AppColors.brandBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.alertRed,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign Out to Guest Mode'),
                onPressed: () {
                  auth.signOut();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final Color iconColor;
  final VoidCallback onTap;

  const _MenuItem(this.icon, this.title, this.iconColor, this.onTap);
}
