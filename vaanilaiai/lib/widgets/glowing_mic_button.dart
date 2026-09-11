import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlowingMicButton extends StatefulWidget {
  final bool isListening;
  final VoidCallback onTap;

  const GlowingMicButton({
    super.key,
    required this.isListening,
    required this.onTap,
  });

  @override
  State<GlowingMicButton> createState() => _GlowingMicButtonState();
}

class _GlowingMicButtonState extends State<GlowingMicButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 4.0, end: 16.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isListening ? AppColors.aiCyan : AppColors.surfaceContainerHigh,
              border: Border.all(
                color: AppColors.aiCyan,
                width: widget.isListening ? 2.5 : 1.0,
              ),
              boxShadow: [
                if (widget.isListening)
                  BoxShadow(
                    color: AppColors.aiCyan.withValues(alpha: 0.6),
                    blurRadius: _glowAnimation.value,
                    spreadRadius: _glowAnimation.value / 3,
                  )
                else
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Icon(
              widget.isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
              color: widget.isListening ? AppColors.onAiCyan : AppColors.aiCyan,
              size: 28,
            ),
          ),
        );
      },
    );
  }
}
