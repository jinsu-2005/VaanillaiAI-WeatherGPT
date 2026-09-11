import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../providers/weather_provider.dart';
import '../providers/locale_provider.dart';
import '../theme/app_colors.dart';

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _popularLocations = [
    {'name': 'Nagercoil', 'district': 'Kanyakumari', 'state': 'Tamil Nadu', 'lat': 8.1833, 'lon': 77.4119},
    {'name': 'Chennai', 'district': 'Chennai', 'state': 'Tamil Nadu', 'lat': 13.0827, 'lon': 80.2707},
    {'name': 'Madurai', 'district': 'Madurai', 'state': 'Tamil Nadu', 'lat': 9.9252, 'lon': 78.1198},
    {'name': 'Varanasi', 'district': 'Varanasi', 'state': 'Uttar Pradesh', 'lat': 25.3176, 'lon': 82.9739},
    {'name': 'Bengaluru', 'district': 'Bengaluru Urban', 'state': 'Karnataka', 'lat': 12.9716, 'lon': 77.5946},
    {'name': 'Delhi', 'district': 'New Delhi', 'state': 'Delhi', 'lat': 28.6139, 'lon': 77.2090},
    {'name': 'Mumbai', 'district': 'Mumbai', 'state': 'Maharashtra', 'lat': 19.0760, 'lon': 72.8777},
    {'name': 'Shimla', 'district': 'Shimla', 'state': 'Himachal Pradesh', 'lat': 31.1048, 'lon': 77.1734},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectLocation(String name, String? district, String? state, double lat, double lon) {
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    weatherProvider.updateLocation(
      name: name,
      district: district,
      state: state,
      latitude: lat,
      longitude: lon,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locationProvider = Provider.of<LocationProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    final surfaceColor = AppColors.surface(isDark);
    final surfaceHL = AppColors.surfaceHL(isDark);
    final borderColor = AppColors.border(isDark);
    final textPrimary = AppColors.textPrimaryC(isDark);
    final textSecondary = AppColors.textSecondaryC(isDark);
    final textTertiary = AppColors.textTertiaryC(isDark);
    final accentBlue = isDark ? AppColors.brandBlueLight : AppColors.brandBlue;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search Location / ஊரைத் தேடுக',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input
            Container(
              decoration: BoxDecoration(
                color: surfaceHL,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: textPrimary),
                decoration: InputDecoration(
                  hintText: localeProvider.t('search_placeholder'),
                  hintStyle: TextStyle(color: textTertiary, fontSize: 13),
                  prefixIcon: Icon(Icons.search_rounded, color: accentBlue),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, color: textSecondary, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            locationProvider.clearSearch();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: (val) {
                  locationProvider.search(val);
                  setState(() {});
                },
              ),
            ),

            const SizedBox(height: 20),

            // Results or Popular Grid
            Expanded(
              child: locationProvider.isSearching
                  ? Center(child: SpinKitPulse(color: accentBlue, size: 40))
                  : locationProvider.searchResults.isNotEmpty
                      ? Container(
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: ListView.separated(
                              itemCount: locationProvider.searchResults.length,
                              separatorBuilder: (_, __) => Divider(
                                  color: borderColor, height: 1, indent: 56),
                              itemBuilder: (context, index) {
                                final loc = locationProvider.searchResults[index];
                                return ListTile(
                                  leading: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: (loc.isVillage
                                              ? AppColors.alertGreen
                                              : accentBlue)
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      loc.isVillage
                                          ? Icons.holiday_village_rounded
                                          : Icons.location_city_rounded,
                                      color: loc.isVillage
                                          ? AppColors.alertGreen
                                          : accentBlue,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    loc.name,
                                    style: TextStyle(
                                        color: textPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14),
                                  ),
                                  subtitle: Text(
                                    '${loc.district ?? ""}${loc.state != null ? ", ${loc.state}" : ""}',
                                    style: TextStyle(
                                        color: textSecondary, fontSize: 12),
                                  ),
                                  trailing: loc.isVillage
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.alertGreen
                                                .withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const Text('Village',
                                              style: TextStyle(
                                                  color: AppColors.alertGreen,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700)),
                                        )
                                      : Icon(Icons.chevron_right_rounded,
                                          color: textTertiary, size: 18),
                                  onTap: () => _selectLocation(loc.name,
                                      loc.district, loc.state, loc.latitude,
                                      loc.longitude),
                                );
                              },
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.star_rounded,
                                      color: AppColors.weatherSunny, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Popular Indian Regions',
                                    style: TextStyle(
                                      color: textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _popularLocations.map((loc) {
                                  return InkWell(
                                    onTap: () => _selectLocation(
                                      loc['name'],
                                      loc['district'],
                                      loc['state'],
                                      loc['lat'],
                                      loc['lon'],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: surfaceColor,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: borderColor),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.location_on_rounded,
                                              color: accentBlue, size: 14),
                                          const SizedBox(width: 6),
                                          Text(
                                            loc['name'],
                                            style: TextStyle(
                                                color: textPrimary,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
