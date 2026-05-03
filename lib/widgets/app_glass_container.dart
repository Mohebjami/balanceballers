import 'package:flutter/material.dart';

class AppGlassContainer extends StatelessWidget {
  const AppGlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 22,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}
