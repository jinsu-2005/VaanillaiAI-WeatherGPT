import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/citizen_report_model.dart';
import '../providers/citizen_provider.dart';
import '../providers/weather_provider.dart';
import '../theme/app_colors.dart';

class CitizenReportDialog extends StatefulWidget {
  const CitizenReportDialog({super.key});

  @override
  State<CitizenReportDialog> createState() => _CitizenReportDialogState();
}

class _CitizenReportDialogState extends State<CitizenReportDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _waterDepthController = TextEditingController();

  String _reportType = 'Waterlogging';
  String _severity = 'Moderate';
  String _reporterRole = 'Citizen';
  bool _isSubmitting = false;

  final List<String> _reportTypes = [
    'Waterlogging',
    'Hailstorm',
    'Wind Damage',
    'Cloudburst',
    'Flash Flood',
    'Lightning Strike',
  ];

  final List<String> _severities = ['Low', 'Moderate', 'Severe'];
  final List<String> _roles = ['Citizen', 'Progressive Farmer', 'Traffic Volunteer', 'Disaster Responder'];

  @override
  void dispose() {
    _descController.dispose();
    _waterDepthController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final weather = Provider.of<WeatherProvider>(context, listen: false);
    final citizenProvider = Provider.of<CitizenProvider>(context, listen: false);

    setState(() => _isSubmitting = true);

    double? depth;
    if (_reportType == 'Waterlogging' && _waterDepthController.text.isNotEmpty) {
      depth = double.tryParse(_waterDepthController.text);
    }

    final newReport = CitizenReportModel(
      id: '',
      reportType: _reportType,
      severity: _severity,
      waterDepthInches: depth,
      description: _descController.text.trim(),
      latitude: weather.latitude,
      longitude: weather.longitude,
      locationName: weather.locationName,
      reporterRole: _reporterRole,
      createdAt: 'Just now',
    );

    final success = await citizenProvider.submitReport(newReport);
    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.of(context).pop(success);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Ground telemetry submitted! Dispatched to disaster response registry.'
                : 'Report logged locally.',
          ),
          backgroundColor: AppColors.brandBlue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? const Color(0xFF161E31) : Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.brandBlue.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_location_alt_rounded, color: AppColors.brandBlue, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Report Ground Weather Hazard',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          'Citizen Science & Flood Telemetry',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Hazard Type
              const Text('HAZARD CLASSIFICATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _reportType,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _reportTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 14))))
                    .toList(),
                onChanged: (val) => setState(() => _reportType = val!),
              ),
              const SizedBox(height: 14),

              // Severity Selector
              const Text('SEVERITY LEVEL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Row(
                children: _severities.map((s) {
                  final isSel = _severity == s;
                  Color col = AppColors.alertGreen;
                  if (s == 'Moderate') col = AppColors.alertOrange;
                  if (s == 'Severe') col = AppColors.alertRed;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(s, style: TextStyle(fontSize: 12, color: isSel ? Colors.white : null)),
                        selected: isSel,
                        selectedColor: col,
                        onSelected: (_) => setState(() => _severity = s),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Water depth if waterlogging
              if (_reportType == 'Waterlogging' || _reportType == 'Flash Flood') ...[
                const Text('ESTIMATED WATER DEPTH (INCHES)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _waterDepthController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'e.g. 6.5 or 12',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    suffixText: 'inches',
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Description
              const Text('SITUATION DESCRIPTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please provide a brief description' : null,
                decoration: InputDecoration(
                  hintText: 'e.g. Waterlogged under railway bridge, vehicles stalled...',
                  hintStyle: const TextStyle(fontSize: 12),
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),

              // Reporter Role
              const Text('YOUR ROLE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _reporterRole,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _roles
                    .map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 13))))
                    .toList(),
                onChanged: (val) => setState(() => _reporterRole = val!),
              ),
              const SizedBox(height: 20),

              // Submit Button
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: _isSubmitting
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_rounded),
                label: Text(
                  _isSubmitting ? 'Transmitting Ground Data...' : 'Submit Ground Hazard Report',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
