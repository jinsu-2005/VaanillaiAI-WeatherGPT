import 'package:flutter/material.dart';
import '../models/lightning_model.dart';
import '../theme/app_colors.dart';

class LightningThreatCard extends StatefulWidget {
  final LightningAlertModel alert;
  final VoidCallback? onRefresh;

  const LightningThreatCard({
    super.key,
    required this.alert,
    this.onRefresh,
  });

  @override
  State<LightningThreatCard> createState() => _LightningThreatCardState();
}

class _LightningThreatCardState extends State<LightningThreatCard> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.85, end: 1.18).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getThreatColor() {
    final t = widget.alert.threatLevel.toLowerCase();
    if (t.contains('high') || t.contains('danger') || t.contains('severe')) {
      return const Color(0xFFFF1744);
    } else if (t.contains('moderate') || t.contains('alert') || t.contains('watch')) {
      return const Color(0xFFFF9100);
    }
    return const Color(0xFF00E676);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final threatColor = _getThreatColor();
    final isHigh = widget.alert.threatLevel.toLowerCase().contains('high');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141927) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: threatColor.withValues(alpha: isHigh ? 0.6 : 0.25),
          width: isHigh ? 1.8 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: threatColor.withValues(alpha: isHigh ? 0.15 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: threatColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                ScaleTransition(
                  scale: isHigh ? _glowAnimation : const AlwaysStoppedAnimation(1.0),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: threatColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.flash_on_rounded,
                      color: threatColor,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'DAMINI LIGHTNING RADAR',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: threatColor,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: threatColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.alert.threatLevel.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'MoES / IITM Atmospheric Strike Telemetry',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Stats Grid
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        context,
                        title: 'Nearest Strike',
                        value: '${widget.alert.nearestStrikeKm.toStringAsFixed(1)} km',
                        subtitle: widget.alert.strikeTrend,
                        icon: Icons.radar_rounded,
                        color: threatColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricTile(
                        context,
                        title: 'Strikes (30m)',
                        value: '${widget.alert.strikesLast30m}',
                        subtitle: widget.alert.soundRumbleAudible ? 'Thunder Audible' : 'No Claps Heard',
                        icon: Icons.electric_bolt_rounded,
                        color: widget.alert.strikesLast30m > 0 ? AppColors.alertOrange : AppColors.alertGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricTile(
                        context,
                        title: 'CAPE Index',
                        value: '${widget.alert.capeThunderstormIndexJKg.toInt()} J/kg',
                        subtitle: widget.alert.capeThunderstormIndexJKg > 1000 ? 'High Energy' : 'Stable',
                        icon: Icons.air_rounded,
                        color: Colors.purpleAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 30-30 Safety Rule Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2538) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF2E3852) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.shield_outlined, size: 18, color: AppColors.brandBlue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.alert.safetyRule3030,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                            color: isDark ? Colors.white70 : const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Expandable Guidance Button
                if (widget.alert.fieldSafetyGuidance.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _expanded ? 'Hide Safety Protocol' : 'View Outdoor & Field Safety Rules',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.brandBlue,
                            ),
                          ),
                          Icon(
                            _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: AppColors.brandBlue,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_expanded) ...[
                    const SizedBox(height: 8),
                    ...widget.alert.fieldSafetyGuidance.map(
                      (guide) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(color: AppColors.brandBlue, fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(
                                guide,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark ? Colors.white60 : Colors.black87,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2234) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
