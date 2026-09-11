import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../providers/weather_provider.dart';
import '../theme/app_colors.dart';
import 'location_search_screen.dart';

class SavedLocationsScreen extends StatelessWidget {
  const SavedLocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locationProvider = Provider.of<LocationProvider>(context);
    final weatherProvider = Provider.of<WeatherProvider>(context);

    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkOutline : AppColors.lightOutline;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final locations = locationProvider.savedLocations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Locations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.brandBlue),
            tooltip: 'Add Indian Location',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LocationSearchScreen()),
              );
            },
          ),
        ],
      ),
      body: locations.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_off_rounded, color: AppColors.brandBlue, size: 56),
                    const SizedBox(height: 16),
                    Text(
                      'No Saved Locations Yet',
                      style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your home village, district, or frequent travel destinations for instant weather insights.',
                      style: TextStyle(color: textSecondary, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.add_location_alt_rounded),
                      label: const Text('Add Location'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LocationSearchScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: locations.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final loc = locations[index];
                final isSelected = weatherProvider.locationName.toLowerCase() == loc.name.toLowerCase();

                return Dismissible(
                  key: Key('loc_${loc.id}_${loc.name}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: AppColors.alertRed,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    locationProvider.removeLocation(loc.id);
                  },
                  child: InkWell(
                    onTap: () {
                      weatherProvider.updateLocation(
                        name: loc.name,
                        district: loc.district,
                        state: loc.state,
                        latitude: loc.latitude,
                        longitude: loc.longitude,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Switched forecast location to ${loc.name}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.brandBlue : borderColor,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            color: isSelected ? AppColors.brandBlue : textSecondary,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      loc.name,
                                      style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                                    ),
                                    if (isSelected) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.brandBlueContainer,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text('Active', style: TextStyle(color: AppColors.brandBlueDark, fontSize: 10, fontWeight: FontWeight.w700)),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${loc.district ?? ""}${loc.state != null ? ", ${loc.state}" : ""}',
                                  style: TextStyle(color: textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected && weatherProvider.forecast != null) ...[
                            Text(
                              '${weatherProvider.forecast!.current.temperature.round()}°',
                              style: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(width: 8),
                          ],
                          IconButton(
                            icon: Icon(Icons.close_rounded, color: textSecondary, size: 18),
                            onPressed: () {
                              locationProvider.removeLocation(loc.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
