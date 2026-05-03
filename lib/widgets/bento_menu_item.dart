import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BentoMenuItem extends StatelessWidget {
  const BentoMenuItem({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.page,
    required this.isDark,
    required this.textColor,
  });

  final String title;
  final IconData icon;
  final Color color;
  final Widget page;
  final bool isDark;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: const Duration(milliseconds: 200),
      openColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      closedColor: Colors.transparent,
      closedElevation: 0,
      openElevation: 0,
      closedShape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      openBuilder: (context, _) => page,
      closedBuilder: (context, openContainer) => InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          openContainer();
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: .06)
                    : Colors.black.withValues(alpha: .03),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: textColor.withValues(alpha: .1),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 32),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
