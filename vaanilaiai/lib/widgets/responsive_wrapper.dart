import 'package:flutter/material.dart';

/// Form factor breakpoints for VaanilaiAI
class ResponsiveBreakpoints {
  static const double compact = 600.0;
  static const double medium = 1024.0;

  static bool isCompact(BuildContext context) =>
      MediaQuery.of(context).size.width < compact;

  static bool isMedium(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= compact && w < medium;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= medium;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;
}

/// A universal responsive content container that enforces optimal reading widths
/// and centers content on tablets and widescreen desktop displays.
class ResponsiveContentWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool fillRemaining;

  const ResponsiveContentWrapper({
    super.key,
    required this.child,
    this.maxWidth = 1140.0,
    this.padding,
    this.fillRemaining = false,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= ResponsiveBreakpoints.medium;
    final isTablet = width >= ResponsiveBreakpoints.compact && !isDesktop;

    final defaultPadding = EdgeInsets.symmetric(
      horizontal: isDesktop ? 32.0 : (isTablet ? 24.0 : 16.0),
      vertical: isDesktop ? 20.0 : 12.0,
    );

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? defaultPadding,
          child: child,
        ),
      ),
    );
  }
}
