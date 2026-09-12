import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/imd_sop_model.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class ImdSopScreen extends StatefulWidget {
  final String? initialHazard;

  const ImdSopScreen({super.key, this.initialHazard});

  @override
  State<ImdSopScreen> createState() => _ImdSopScreenState();
}

class _ImdSopScreenState extends State<ImdSopScreen> {
  final ApiService _apiService = ApiService();
  late Future<IMDSOPResponseModel> _sopFuture;
  int _selectedStageIndex = 2; // Default to Orange Alert
  String _selectedHazardId = 'cyclone';

  @override
  void initState() {
    super.initState();
    if (widget.initialHazard != null && widget.initialHazard!.isNotEmpty) {
      _selectedHazardId = widget.initialHazard!;
    }
    _loadSop();
  }

  void _loadSop() {
    setState(() {
      _sopFuture = _apiService.getImdSopMatrix();
    });
  }

  void _copyPhoneNumber(BuildContext context, String number, String name) {
    Clipboard.setData(ClipboardData(text: number));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.phone_in_talk_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Copied $name ($number) to clipboard. Dial from phone.',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.brandBlue,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkOutline : AppColors.lightOutline;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('IMD Warning Matrix & SOPs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh SOP Standards',
            onPressed: _loadSop,
          ),
        ],
      ),
      body: FutureBuilder<IMDSOPResponseModel>(
        future: _sopFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final sopData = snapshot.data ?? IMDSOPResponseModel.defaultFallback();

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                children: [
                  // Offline Status or Network Provenance Badge
                  _buildProvenanceBanner(context, sopData, isDark),
                  const SizedBox(height: 16),

                  // Emergency Quick Speed-Dial Panel
                  _buildEmergencyContactsSection(context, sopData.emergencyContacts, isDark),
                  const SizedBox(height: 24),

                  // Section Title: IMD 4-Stage Warning Color Matrix
                  Text(
                    'IMD 4-Stage Warning Color Matrix',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Standard operational warning stages defined by the India Meteorological Department',
                    style: TextStyle(color: textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 12),

                  // Warning Stage Chips / Buttons
                  _buildStageSelector(sopData.warningStages, isDark),
                  const SizedBox(height: 12),

                  // Selected Warning Stage Detail Card
                  if (sopData.warningStages.isNotEmpty &&
                      _selectedStageIndex < sopData.warningStages.length)
                    _buildSelectedStageCard(
                      sopData.warningStages[_selectedStageIndex],
                      isDark,
                      surfaceColor,
                      borderColor,
                      textPrimary,
                      textSecondary,
                    ),

                  const SizedBox(height: 28),

                  // Section Title: Hazard-Specific NDMA SOPs
                  Text(
                    'Hazard Standard Operating Procedures (SOPs)',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Official actionable directives and disaster mitigation protocols by NDMA & MoES',
                    style: TextStyle(color: textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 14),

                  // Hazard Selector Chips
                  _buildHazardSelector(sopData.hazardSops, isDark),
                  const SizedBox(height: 16),

                  // Selected Hazard Content
                  _buildSelectedHazardSop(
                    sopData.hazardSops,
                    isDark,
                    surfaceColor,
                    borderColor,
                    textPrimary,
                    textSecondary,
                  ),

                  const SizedBox(height: 28),

                  // Disclaimer & Legal Act Card
                  _buildDisclaimerCard(sopData.disclaimer, isDark, borderColor),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProvenanceBanner(BuildContext context, IMDSOPResponseModel sopData, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: sopData.isOfflineCached
            ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF))
            : (isDark ? AppColors.darkSurfaceHighlight : AppColors.brandBlueContainer),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: sopData.isOfflineCached
              ? AppColors.brandBlue.withValues(alpha: 0.4)
              : (isDark ? AppColors.darkOutline : AppColors.brandBlue.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            sopData.isOfflineCached ? Icons.offline_pin_rounded : Icons.verified_rounded,
            color: AppColors.brandBlue,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sopData.isOfflineCached
                      ? 'Offline Disaster Resilience Active'
                      : 'Verified Official Operational Guidelines',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.brandBlueDark,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  sopData.source,
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.brandBlueDark.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactsSection(
      BuildContext context, List<EmergencyContactModel> contacts, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.phone_in_talk_rounded, color: AppColors.alertRed, size: 20),
            const SizedBox(width: 8),
            Text(
              'Emergency Helplines (24x7 Toll-Free)',
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.alertRedDarkBg,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: contacts.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isWide ? 3 : 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: isWide ? 2.4 : 2.0,
              ),
              itemBuilder: (context, index) {
                final c = contacts[index];
                return InkWell(
                  onTap: () => _copyPhoneNumber(context, c.phoneNumber, c.name),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.darkOutline : Colors.black12,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.alertRed.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                c.phoneNumber,
                                style: const TextStyle(
                                  color: AppColors.alertRed,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.copy_rounded, size: 14, color: AppColors.brandBlue),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          c.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          c.agency,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildStageSelector(List<IMDWarningStageModel> stages, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: stages.asMap().entries.map((entry) {
          final idx = entry.key;
          final stage = entry.value;
          final isSelected = _selectedStageIndex == idx;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedStageIndex = idx;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? stage.color
                      : (isDark ? AppColors.darkSurface : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: stage.color,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : stage.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      stage.code,
                      style: TextStyle(
                        color: isSelected ? Colors.white : stage.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSelectedStageCard(
    IMDWarningStageModel stage,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: stage.color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: stage.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  stage.code.toUpperCase(),
                  style: TextStyle(
                    color: stage.color,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  stage.name,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceHighlight : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_rounded, color: AppColors.brandBlue, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Operational Directive',
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.brandBlueDark,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stage.actionRequired,
                        style: TextStyle(color: textPrimary, fontSize: 13, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            stage.impactSummary,
            style: TextStyle(color: textSecondary, fontSize: 13, height: 1.35),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Text(
            'PHYSICAL THRESHOLDS',
            style: TextStyle(
              color: textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          _buildThresholdRow(Icons.water_drop_outlined, 'Rainfall', stage.precipitationThreshold, textPrimary, textSecondary),
          const SizedBox(height: 6),
          _buildThresholdRow(Icons.air_rounded, 'Wind Speed', stage.windThreshold, textPrimary, textSecondary),
          const SizedBox(height: 6),
          _buildThresholdRow(Icons.thermostat_rounded, 'Thermal Stress', stage.temperatureThreshold, textPrimary, textSecondary),
        ],
      ),
    );
  }

  Widget _buildThresholdRow(
      IconData icon, String label, String value, Color textPrimary, Color textSecondary) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.brandBlue),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildHazardSelector(List<HazardSOPModel> sops, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: sops.map((h) {
          final isSelected = _selectedHazardId == h.hazardId;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              avatar: Icon(h.icon, size: 16, color: isSelected ? Colors.white : AppColors.brandBlue),
              label: Text(h.title.split('&').first.trim()),
              selected: isSelected,
              onSelected: (val) {
                if (val) {
                  setState(() {
                    _selectedHazardId = h.hazardId;
                  });
                }
              },
              selectedColor: AppColors.brandBlue,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSelectedHazardSop(
    List<HazardSOPModel> sops,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final sop = sops.firstWhere(
      (h) => h.hazardId == _selectedHazardId,
      orElse: () => sops.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hazard Header Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.brandBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(sop.icon, color: AppColors.brandBlue, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sop.title,
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.alertOrange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'IMD ${sop.severityLevel}',
                                style: const TextStyle(
                                  color: AppColors.alertOrange,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              sop.leadTimePhase,
                              style: TextStyle(color: textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'IMMEDIATE CRITICAL ACTIONS',
                style: TextStyle(
                  color: AppColors.alertRed,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              ...sop.immediateActions.map((action) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.bolt_rounded, color: AppColors.alertRed, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            action,
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Do's List Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.alertGreen.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.alertGreen, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Standard Do\'s (Approved Actions)',
                    style: TextStyle(
                      color: isDark ? AppColors.alertGreen : const Color(0xFF1B5E20),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...sop.dos.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.done_all_rounded, color: AppColors.alertGreen, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item,
                            style: TextStyle(color: textPrimary, fontSize: 12, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Don'ts List Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.alertRed.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.cancel_rounded, color: AppColors.alertRed, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Strict Don\'ts (Prohibited Actions)',
                    style: TextStyle(
                      color: isDark ? AppColors.alertRed : const Color(0xFFB71C1C),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...sop.donts.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.close_rounded, color: AppColors.alertRed, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item,
                            style: TextStyle(color: textPrimary, fontSize: 12, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Vulnerable Demographics & Livestock Guidance
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceHighlight : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.family_restroom_rounded, color: AppColors.brandBlue, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vulnerable Groups & Livestock Protection',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sop.vulnerableGuidance,
                      style: TextStyle(color: textSecondary, fontSize: 12, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimerCard(String disclaimer, bool isDark, Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.brandBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              disclaimer,
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
